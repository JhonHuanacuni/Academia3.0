"""CRUD de INFORME_CONSULTA — seguimiento de personas que piden información."""

from datetime import datetime

from django.db import connection
from django.utils import timezone

from .db_context import prepare_write_cursor
from .sql_compat import is_mysql, fecha_sort_expr

RESULTADOS = {
    'no_aplica': 'No aplica',
    'interesado': 'Interesado',
    'seguimiento': 'En seguimiento',
    'matriculado': 'Matriculado',
}

CANALES = {
    'presencial': 'Presencial',
    'redes': 'Redes / WhatsApp',
    'telefono': 'Teléfono',
    'otro': 'Otro',
}


def _ahora():
    now = timezone.localtime()
    return now.strftime('%d%m%Y'), now.strftime('%H:%M:%S')


def _solo_digitos(valor):
    if valor is None:
        return None
    digitos = ''.join(c for c in str(valor) if c.isdigit())
    return digitos or None


def _normalizar_fecha(fecha):
    if fecha is None:
        return None
    if isinstance(fecha, datetime):
        return fecha.strftime('%d%m%Y')
    s = str(fecha).strip()
    if not s:
        return None
    if len(s) == 8 and s.isdigit():
        return s
    if '/' in s:
        p = s.split('/')
        if len(p) == 3 and len(p[2]) == 4:
            return f'{p[0].zfill(2)}{p[1].zfill(2)}{p[2]}'
    if '-' in s and len(s) >= 10:
        try:
            return datetime.strptime(s[:10], '%Y-%m-%d').strftime('%d%m%Y')
        except ValueError:
            pass
    return None


def _normalizar_resultado(valor):
    raw = (valor or 'interesado').strip().lower().replace(' ', '_')
    aliases = {
        'noaplica': 'no_aplica',
        'no_aplica': 'no_aplica',
        'lead': 'interesado',
        'interesado': 'interesado',
        'seguir': 'seguimiento',
        'seguimiento': 'seguimiento',
        'en_seguimiento': 'seguimiento',
        'matricula': 'matriculado',
        'matriculado': 'matriculado',
    }
    return aliases.get(raw, 'interesado')


def _normalizar_canal(valor):
    raw = (valor or 'presencial').strip().lower().replace(' ', '_')
    aliases = {
        'presencial': 'presencial',
        'redes': 'redes',
        'whatsapp': 'redes',
        'redes_whatsapp': 'redes',
        'telefono': 'telefono',
        'teléfono': 'telefono',
        'otro': 'otro',
    }
    return aliases.get(raw, 'presencial')


def _marcas(resultado):
    es_no = resultado == 'no_aplica'
    return (1 if es_no else 0), (0 if es_no else 1)


def _row_public(row):
    if not row:
        return None
    resultado = row.get('RESULTADO') or 'interesado'
    canal = row.get('CANAL') or 'presencial'
    return {
        **row,
        'RESULTADO_LABEL': RESULTADOS.get(resultado, resultado),
        'CANAL_LABEL': CANALES.get(canal, canal),
    }


def _cursor_rows(cursor):
    cols = [c[0] for c in cursor.description] if cursor.description else []
    return [dict(zip(cols, r)) for r in cursor.fetchall()]


def _siguiente_id(cursor):
    cursor.execute(
        """
        SELECT COALESCE(MAX(CAST(SUBSTRING(IDINFORMECONSULTA, 4) AS UNSIGNED)), 0) + 1
        FROM INFORME_CONSULTA
        WHERE IDINFORMECONSULTA LIKE 'INC%%'
        """
        if is_mysql()
        else """
        SELECT ISNULL(MAX(CAST(SUBSTRING(IDINFORMECONSULTA, 4, 20) AS INT)), 0) + 1
        FROM INFORME_CONSULTA
        WHERE IDINFORMECONSULTA LIKE 'INC%%'
        """
    )
    n = int(cursor.fetchone()[0] or 1)
    return f'INC{n:06d}'


def listar_informes_consulta(
    buscar=None,
    resultado=None,
    canal=None,
    anio=None,
    mes=None,
    ordenar_por='FECHA',
    direccion='DESC',
    pagina=1,
    tamanio=10,
):
    pagina = max(int(pagina or 1), 1)
    tamanio = max(min(int(tamanio or 10), 100), 1)
    offset = (pagina - 1) * tamanio
    buscar = (buscar or '').strip() or None
    resultado = _normalizar_resultado(resultado) if resultado else None
    if resultado and (resultado not in RESULTADOS):
        resultado = None
    canal = _normalizar_canal(canal) if canal else None
    if canal and canal not in CANALES:
        canal = None

    where = ["(i.ESTADO IS NULL OR i.ESTADO = 'Activo')"]
    params = []

    if buscar:
        like = f'%{buscar}%'
        where.append(
            '(i.NOMBRE LIKE %s OR i.TELEFONO LIKE %s OR i.CICLO_INTERES LIKE %s OR i.OBSERVACION LIKE %s)'
        )
        params.extend([like, like, like, like])
    if resultado:
        where.append('i.RESULTADO = %s')
        params.append(resultado)
    if canal:
        where.append('i.CANAL = %s')
        params.append(canal)
    if anio and mes:
        anio_i, mes_i = int(anio), int(mes)
        desde = f'{anio_i:04d}{mes_i:02d}01'
        if mes_i == 12:
            hasta = f'{anio_i + 1:04d}0101'
        else:
            hasta = f'{anio_i:04d}{mes_i + 1:02d}01'
        fs = fecha_sort_expr('i.FECHA')
        where.append(f'{fs} >= %s AND {fs} < %s')
        params.extend([desde, hasta])

    orden_map = {
        'FECHA': fecha_sort_expr('i.FECHA'),
        'NOMBRE': 'i.NOMBRE',
        'TELEFONO': 'i.TELEFONO',
        'RESULTADO': 'i.RESULTADO',
        'CANAL': 'i.CANAL',
        'IDINFORMECONSULTA': 'i.IDINFORMECONSULTA',
    }
    order_expr = orden_map.get((ordenar_por or 'FECHA').upper(), fecha_sort_expr('i.FECHA'))
    dir_sql = 'DESC' if str(direccion or 'DESC').upper() == 'DESC' else 'ASC'
    where_sql = ' AND '.join(where)

    with connection.cursor() as cursor:
        cursor.execute(
            f'SELECT COUNT(*) FROM INFORME_CONSULTA i WHERE {where_sql}',
            params,
        )
        total = int(cursor.fetchone()[0] or 0)

        if is_mysql():
            cursor.execute(
                f"""
                SELECT
                    i.IDINFORMECONSULTA, i.FECHA, i.NOMBRE, i.TELEFONO,
                    i.CICLO_INTERES, i.CANAL, i.RESULTADO, i.SE_ENTERO,
                    i.OBSERVACION, i.MARCA_NO_APLICA, i.MARCA_INTERESADO, i.ESTADO
                FROM INFORME_CONSULTA i
                WHERE {where_sql}
                ORDER BY {order_expr} {dir_sql}, i.IDINFORMECONSULTA DESC
                LIMIT %s OFFSET %s
                """,
                params + [tamanio, offset],
            )
        else:
            cursor.execute(
                f"""
                SELECT * FROM (
                    SELECT
                        i.IDINFORMECONSULTA, i.FECHA, i.NOMBRE, i.TELEFONO,
                        i.CICLO_INTERES, i.CANAL, i.RESULTADO, i.SE_ENTERO,
                        i.OBSERVACION, i.MARCA_NO_APLICA, i.MARCA_INTERESADO, i.ESTADO,
                        ROW_NUMBER() OVER (ORDER BY {order_expr} {dir_sql}, i.IDINFORMECONSULTA DESC) AS rn
                    FROM INFORME_CONSULTA i
                    WHERE {where_sql}
                ) q
                WHERE rn BETWEEN %s AND %s
                """,
                params + [offset + 1, offset + tamanio],
            )
        rows = [_row_public(r) for r in _cursor_rows(cursor)]
    return rows, total


def obtener_informe_consulta(id_informe):
    with connection.cursor() as cursor:
        cursor.execute(
            """
            SELECT
                IDINFORMECONSULTA, FECHA, NOMBRE, TELEFONO, CICLO_INTERES,
                CANAL, RESULTADO, SE_ENTERO, OBSERVACION,
                MARCA_NO_APLICA, MARCA_INTERESADO, ESTADO
            FROM INFORME_CONSULTA
            WHERE IDINFORMECONSULTA = %s
            """,
            [id_informe],
        )
        rows = _cursor_rows(cursor)
    return _row_public(rows[0]) if rows else None


def insertar_informe_consulta(payload, id_usuario=None):
    fecha = _normalizar_fecha(payload.get('FECHA'))
    nombre = (payload.get('NOMBRE') or '').strip().upper()
    if not fecha:
        return 0, 'La fecha es obligatoria'
    if not nombre:
        return 0, 'El nombre es obligatorio'

    resultado = _normalizar_resultado(payload.get('RESULTADO'))
    canal = _normalizar_canal(payload.get('CANAL'))
    marca_na, marca_int = _marcas(resultado)
    fecha_c, hora_c = _ahora()

    with connection.cursor() as cursor:
        prepare_write_cursor(cursor, id_usuario, payload)
        nuevo_id = _siguiente_id(cursor)
        cursor.execute(
            """
            INSERT INTO INFORME_CONSULTA (
                IDINFORMECONSULTA, FECHA, NOMBRE, TELEFONO, CICLO_INTERES,
                CANAL, RESULTADO, SE_ENTERO, OBSERVACION,
                MARCA_NO_APLICA, MARCA_INTERESADO, ESTADO,
                CREADO_POR, FECHACREACION, HORACREACION
            ) VALUES (
                %s, %s, %s, %s, %s,
                %s, %s, %s, %s,
                %s, %s, 'Activo',
                %s, %s, %s
            )
            """,
            [
                nuevo_id,
                fecha,
                nombre,
                _solo_digitos(payload.get('TELEFONO')),
                (payload.get('CICLO_INTERES') or '').strip().upper() or None,
                canal,
                resultado,
                (payload.get('SE_ENTERO') or '').strip() or None,
                (payload.get('OBSERVACION') or '').strip() or None,
                marca_na,
                marca_int,
                id_usuario,
                fecha_c,
                hora_c,
            ],
        )
    return 1, f'Informe {nuevo_id} registrado'


def actualizar_informe_consulta(id_informe, payload, id_usuario=None):
    actual = obtener_informe_consulta(id_informe)
    if not actual:
        return 0, 'Informe no encontrado'

    fecha = _normalizar_fecha(payload.get('FECHA')) or actual['FECHA']
    nombre = (payload.get('NOMBRE') or actual['NOMBRE'] or '').strip().upper()
    if not nombre:
        return 0, 'El nombre es obligatorio'

    resultado = _normalizar_resultado(payload.get('RESULTADO') or actual.get('RESULTADO'))
    canal = _normalizar_canal(payload.get('CANAL') or actual.get('CANAL'))
    marca_na, marca_int = _marcas(resultado)
    fecha_m, hora_m = _ahora()

    with connection.cursor() as cursor:
        prepare_write_cursor(cursor, id_usuario, payload)
        cursor.execute(
            """
            UPDATE INFORME_CONSULTA SET
                FECHA = %s,
                NOMBRE = %s,
                TELEFONO = %s,
                CICLO_INTERES = %s,
                CANAL = %s,
                RESULTADO = %s,
                SE_ENTERO = %s,
                OBSERVACION = %s,
                MARCA_NO_APLICA = %s,
                MARCA_INTERESADO = %s,
                MODIFICADO_POR = %s,
                FECHAMODIFICACION = %s,
                HORAMODIFICACION = %s
            WHERE IDINFORMECONSULTA = %s
            """,
            [
                fecha,
                nombre,
                _solo_digitos(payload.get('TELEFONO') if 'TELEFONO' in payload else actual.get('TELEFONO')),
                ((payload.get('CICLO_INTERES') if 'CICLO_INTERES' in payload else actual.get('CICLO_INTERES')) or '')
                .strip()
                .upper()
                or None,
                canal,
                resultado,
                ((payload.get('SE_ENTERO') if 'SE_ENTERO' in payload else actual.get('SE_ENTERO')) or '')
                .strip()
                or None,
                ((payload.get('OBSERVACION') if 'OBSERVACION' in payload else actual.get('OBSERVACION')) or '')
                .strip()
                or None,
                marca_na,
                marca_int,
                id_usuario,
                fecha_m,
                hora_m,
                id_informe,
            ],
        )
    return 1, 'Informe actualizado'


def eliminar_informe_consulta(id_informe, id_usuario=None):
    """Baja lógica: no borra la fila."""
    actual = obtener_informe_consulta(id_informe)
    if not actual:
        return 0, 'Informe no encontrado'
    fecha_m, hora_m = _ahora()
    with connection.cursor() as cursor:
        prepare_write_cursor(cursor, id_usuario)
        cursor.execute(
            """
            UPDATE INFORME_CONSULTA SET
                ESTADO = 'Inactivo',
                MODIFICADO_POR = %s,
                FECHAMODIFICACION = %s,
                HORAMODIFICACION = %s
            WHERE IDINFORMECONSULTA = %s
            """,
            [id_usuario, fecha_m, hora_m, id_informe],
        )
    return 1, 'Informe dado de baja'


def telefonos_alumnos_mes(anio, mes):
    """Teléfonos de alumnos con mensualidad que cubre el mes (para marcar coincidencias)."""
    anio_i, mes_i = int(anio), int(mes)
    desde = f'{anio_i:04d}{mes_i:02d}01'
    if mes_i == 12:
        hasta = f'{anio_i + 1:04d}0101'
    else:
        hasta = f'{anio_i:04d}{mes_i + 1:02d}01'
    fs_ini = fecha_sort_expr('m.FECHAINICIO')
    fs_fin = fecha_sort_expr('m.FECHAFIN')
    with connection.cursor() as cursor:
        cursor.execute(
            f"""
            SELECT DISTINCT u.TELPERSONAL, u.TELAPODERADO
            FROM MENSUALIDAD m
            INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO AND u.IDTIPOUSUARIO = '1'
            WHERE (m.ESTADO IS NULL OR m.ESTADO = 'Activo')
              AND ({fs_ini} IS NULL OR {fs_ini} = '' OR {fs_ini} < %s)
              AND ({fs_fin} IS NULL OR {fs_fin} = '' OR {fs_fin} >= %s)
            """,
            [hasta, desde],
        )
        tels = set()
        for row in cursor.fetchall():
            for val in row:
                dig = _solo_digitos(val)
                if dig:
                    tels.add(dig)
    return tels
