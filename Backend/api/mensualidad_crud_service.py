from django.db import connection
from .db_context import prepare_write_cursor
from .models import Aula
from . import sp_runner as sp
from .sql_compat import concat_nombre_usuario, plan_table


def _read_sp_write_result(cursor):
    return sp.read_write_result(cursor)


def _decimal_or_none(value):
    if value is None or value == '':
        return None
    return float(value)


def _listar_mensualidades_mysql(
    cursor,
    buscar=None,
    deuda=None,
    ordenar_por='FECHAREGISTRO',
    direccion='DESC',
    pagina=1,
    tamanio=10,
):
    buscar = (buscar or '').strip() or None
    deuda = (deuda or '').strip() or None
    ordenar_por = (ordenar_por or 'FECHAREGISTRO').strip()
    direccion = 'DESC' if (direccion or 'DESC').upper() == 'DESC' else 'ASC'
    pagina = max(1, int(pagina or 1))
    tamanio = max(1, int(tamanio or 10))
    offset = (pagina - 1) * tamanio

    sql_base = """
        WITH Base AS (
            SELECT
                m.IDMENSUALIDAD,
                m.IDUSUARIO,
                UPPER(TRIM(CONCAT(IFNULL(u.APELLIDO, ''), ' ', IFNULL(u.NOMBRE, '')))) AS ESTUDIANTE_NOMBRE,
                u.DNI AS ESTUDIANTE_DNI,
                m.IDPLAN,
                pl.NOMBRE AS PLAN_NOMBRE,
                IFNULL(tu.DESCRIPCION, '') AS TURNO_DESCRIPCION,
                m.ESTADOMIEMBRO,
                m.FECHAINICIO,
                m.FECHAFIN,
                m.MONTOTOTAL,
                IFNULL(pag.PAGADO, 0) AS PAGADO,
                CASE WHEN IFNULL(m.MONTOTOTAL, 0) - IFNULL(pag.PAGADO, 0) < 0 THEN 0
                     ELSE IFNULL(m.MONTOTOTAL, 0) - IFNULL(pag.PAGADO, 0) END AS DEUDA,
                COUNT(*) OVER (PARTITION BY m.IDUSUARIO) AS CANT_MENSUALIDADES,
                SUM(
                    CASE WHEN IFNULL(m.MONTOTOTAL, 0) - IFNULL(pag.PAGADO, 0) < 0 THEN 0
                         ELSE IFNULL(m.MONTOTOTAL, 0) - IFNULL(pag.PAGADO, 0) END
                ) OVER (PARTITION BY m.IDUSUARIO) AS DEUDA_TOTAL,
                IFNULL(au.NOMBRE, '') AS AULA_NOMBRE,
                m.IDTUTOR,
                IFNULL(tut.NOMBRE, IFNULL(m.TUTORLEGACY, '')) AS TUTOR_NOMBRE,
                m.REGISTRADOPOR,
                UPPER(TRIM(CONCAT(IFNULL(reg.APELLIDO, ''), ' ', IFNULL(reg.NOMBRE, '')))) AS ASESOR_NOMBRE,
                m.ESTADO,
                m.FECHAREGISTRO,
                ROW_NUMBER() OVER (
                    PARTITION BY m.IDUSUARIO
                    ORDER BY m.FECHAREGISTRO DESC, m.IDMENSUALIDAD DESC
                ) AS RN
            FROM MENSUALIDAD m
            INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
            INNER JOIN `PLAN` pl ON pl.IDPLAN = m.IDPLAN
            LEFT JOIN TURNO tu ON tu.IDTURNO = IFNULL(pl.IDTURNO, m.IDTURNO)
            LEFT JOIN AULA au ON au.IDAULA = m.IDAULA
            LEFT JOIN TUTOR tut ON tut.IDTUTOR = m.IDTUTOR
            LEFT JOIN USUARIO reg ON reg.IDUSUARIO = m.REGISTRADOPOR
            LEFT JOIN LATERAL (
                SELECT SUM(p.MONTO) AS PAGADO
                FROM PAGOMENSUALIDAD p
                WHERE p.IDMENSUALIDAD = m.IDMENSUALIDAD
            ) pag ON TRUE
            WHERE m.ESTADO = 'Activo'
        ),
        Filtrada AS (
            SELECT *
            FROM Base
            WHERE RN = 1
              AND (%s IS NULL OR
                   IDMENSUALIDAD LIKE CONCAT('%%', %s, '%%') OR
                   ESTUDIANTE_DNI LIKE CONCAT('%%', %s, '%%') OR
                   ESTUDIANTE_NOMBRE LIKE CONCAT('%%', %s, '%%') OR
                   PLAN_NOMBRE LIKE CONCAT('%%', %s, '%%') OR
                   AULA_NOMBRE LIKE CONCAT('%%', %s, '%%') OR
                   TUTOR_NOMBRE LIKE CONCAT('%%', %s, '%%'))
              AND (
                  %s IS NULL OR
                  (%s IN ('con', 'Con deuda') AND DEUDA_TOTAL > 0) OR
                  (%s IN ('sin', 'Sin deuda') AND DEUDA_TOTAL <= 0)
              )
        )
    """

    filtros = [buscar, buscar, buscar, buscar, buscar, buscar, buscar, deuda, deuda, deuda]

    cursor.execute(f'{sql_base} SELECT COUNT(*) FROM Filtrada', filtros)
    total = int((cursor.fetchone() or [0])[0])

    columnas_orden = {
        'FECHAREGISTRO': 'FECHAREGISTRO',
        'DEUDA': 'DEUDA_TOTAL',
        'DEUDA_TOTAL': 'DEUDA_TOTAL',
        'CANT_MENSUALIDADES': 'CANT_MENSUALIDADES',
        'ESTUDIANTE_NOMBRE': 'ESTUDIANTE_NOMBRE',
        'PLAN_NOMBRE': 'PLAN_NOMBRE',
        'FECHAINICIO': 'FECHAINICIO',
        'FECHAFIN': 'FECHAFIN',
    }
    col_orden = columnas_orden.get(ordenar_por.upper(), 'FECHAREGISTRO')
    order_sql = f'ORDER BY {col_orden} {direccion}, IDMENSUALIDAD DESC LIMIT %s OFFSET %s'

    cursor.execute(
        f"""
        {sql_base}
        SELECT
            IDMENSUALIDAD,
            IDUSUARIO,
            ESTUDIANTE_NOMBRE,
            ESTUDIANTE_DNI,
            IDPLAN,
            PLAN_NOMBRE,
            TURNO_DESCRIPCION,
            ESTADOMIEMBRO,
            FECHAINICIO,
            FECHAFIN,
            MONTOTOTAL,
            PAGADO,
            DEUDA,
            CANT_MENSUALIDADES,
            DEUDA_TOTAL,
            AULA_NOMBRE,
            IDTUTOR,
            TUTOR_NOMBRE,
            REGISTRADOPOR,
            ASESOR_NOMBRE,
            ESTADO,
            FECHAREGISTRO
        FROM Filtrada
        {order_sql}
        """,
        filtros + [tamanio, offset],
    )
    return sp.cursor_rows(cursor), total


def listar_mensualidades(
    buscar=None,
    deuda=None,
    ordenar_por='FECHAREGISTRO',
    direccion='DESC',
    pagina=1,
    tamanio=10,
):
    deuda = (deuda or '').strip() or None
    params = [buscar or None, deuda, ordenar_por, direccion, pagina, tamanio]
    with connection.cursor() as cursor:
        if sp.is_mysql():
            return _listar_mensualidades_mysql(
                cursor, buscar, deuda, ordenar_por, direccion, pagina, tamanio
            )
        cursor.execute(
            """
            DECLARE @Total INT;
            EXEC dbo.usp_mensualidad_listar
                @Buscar=%s, @Deuda=%s, @OrdenarPor=%s, @Direccion=%s,
                @Pagina=%s, @TamanioPagina=%s, @TotalRegistros=@Total OUTPUT;
            SELECT @Total AS TotalRegistros;
            """,
            params,
        )
        data = sp.cursor_rows(cursor)
        total = 0
        if cursor.nextset() and cursor.description:
            row = cursor.fetchone()
            if row:
                total = int(row[0])
    return data, total


def listar_mensualidades_estudiante(id_usuario: str):
    with connection.cursor() as cursor:
        if sp.is_mysql():
            return sp.call_simple(cursor, 'usp_mensualidad_listar_estudiante', [id_usuario])
        cursor.execute(
            'EXEC dbo.usp_mensualidad_listar_estudiante @IdUsuario=%s',
            [id_usuario],
        )
        return sp.cursor_rows(cursor)


def obtener_mensualidad(id_mensualidad: str):
    return sp.call_obtain('usp_mensualidad_obtener', id_mensualidad)


def listar_pagos_mensualidad(id_mensualidad: str):
    with connection.cursor() as cursor:
        if sp.is_mysql():
            return sp.call_simple(cursor, 'usp_mensualidad_listar_pagos', [id_mensualidad])
        cursor.execute(
            'EXEC dbo.usp_mensualidad_listar_pagos @IdMensualidad=%s',
            [id_mensualidad],
        )
        return sp.cursor_rows(cursor)


def insertar_mensualidad(payload: dict, id_usuario=None):
    params = [
        payload.get('IDMENSUALIDAD') or None,
        payload['IDUSUARIO'],
        payload['IDPLAN'],
        int(payload.get('ESTADOMIEMBRO') or 2),
        payload['FECHAINICIO'],
        payload['FECHAFIN'],
        _decimal_or_none(payload.get('MONTOTOTAL')),
        _decimal_or_none(payload.get('PAGOINICIAL')),
        payload.get('IDMETODOPAGO') or None,
        payload.get('IDAULA') or None,
        payload.get('IDTUTOR') or None,
        payload.get('OBSERVACIONES') or None,
        payload.get('FECHACANCELACION') or None,
        payload.get('REGISTRADOPOR') or None,
    ]
    with connection.cursor() as cursor:
        prepare_write_cursor(cursor, id_usuario, payload)
        if sp.is_mysql():
            return sp.call_write_inout_id(cursor, 'usp_mensualidad_insertar', params[0], params[1:])
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200);
            EXEC dbo.usp_mensualidad_insertar
                @Id=%s, @IdUsuario=%s, @IdPlan=%s, @EstadoMiembro=%s,
                @FechaInicio=%s, @FechaFin=%s, @MontoTotal=%s, @PagoInicial=%s,
                @IdMetodoPago=%s, @IdAula=%s, @IdTutor=%s,
                @Observaciones=%s, @FechaCancelacion=%s, @RegistradoPor=%s,
                @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            params,
        )
        return _read_sp_write_result(cursor)


def actualizar_mensualidad(id_mensualidad: str, payload: dict, id_usuario=None):
    params = [
        id_mensualidad,
        payload['IDUSUARIO'],
        payload['IDPLAN'],
        int(payload.get('ESTADOMIEMBRO') or 2),
        payload['FECHAINICIO'],
        payload['FECHAFIN'],
        _decimal_or_none(payload.get('MONTOTOTAL')),
        payload.get('IDAULA') or None,
        payload.get('IDTUTOR') or None,
        payload.get('OBSERVACIONES') or None,
        payload.get('FECHACANCELACION') or None,
    ]
    with connection.cursor() as cursor:
        prepare_write_cursor(cursor, id_usuario, payload)
        if sp.is_mysql():
            return sp.call_write(cursor, 'usp_mensualidad_actualizar', params)
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200);
            EXEC dbo.usp_mensualidad_actualizar
                @Id=%s, @IdUsuario=%s, @IdPlan=%s, @EstadoMiembro=%s,
                @FechaInicio=%s, @FechaFin=%s, @MontoTotal=%s,
                @IdAula=%s, @IdTutor=%s, @Observaciones=%s, @FechaCancelacion=%s,
                @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            params,
        )
        return _read_sp_write_result(cursor)


def eliminar_mensualidad(id_mensualidad: str, id_usuario: str | None = None):
    from .modulos_services import get_usuario_tipo

    es_admin = get_usuario_tipo((id_usuario or '').strip()) == '3'
    eliminacion_fisica = 1 if es_admin else 0

    with connection.cursor() as cursor:
        prepare_write_cursor(cursor, id_usuario)
        if sp.is_mysql():
            return sp.call_write(
                cursor, 'usp_mensualidad_eliminar', [id_mensualidad, eliminacion_fisica]
            )
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200);
            EXEC dbo.usp_mensualidad_eliminar
                @Id=%s, @EliminacionFisica=%s,
                @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            [id_mensualidad, eliminacion_fisica],
        )
        return _read_sp_write_result(cursor)


def buscar_estudiantes(buscar=None):
    nombre = concat_nombre_usuario('u')
    b = (buscar or '').strip() or None
    term = f'%{b}%' if b else None
    concat_nombre = (
        "CONCAT(IFNULL(u.APELLIDO, ''), ' ', IFNULL(u.NOMBRE, ''))"
        if sp.is_mysql()
        else "ISNULL(u.APELLIDO, '') + ' ' + ISNULL(u.NOMBRE, '')"
    )
    with connection.cursor() as cursor:
        if sp.is_mysql():
            cursor.execute(
                f"""
                SELECT u.IDUSUARIO, u.DNI, u.NOMBRE, u.APELLIDO,
                       {nombre} AS NOMBRE_COMPLETO
                FROM USUARIO u
                WHERE u.IDTIPOUSUARIO = '1'
                  AND u.ESTADO = 'Activo'
                  AND (%s IS NULL OR
                       u.DNI LIKE %s OR u.NOMBRE LIKE %s OR u.APELLIDO LIKE %s OR
                       {concat_nombre} LIKE %s)
                ORDER BY u.APELLIDO, u.NOMBRE
                LIMIT 20
                """,
                [b, term, term, term, term],
            )
            return sp.cursor_rows(cursor)
        cursor.execute(
            'EXEC dbo.usp_mensualidad_buscar_estudiantes @Buscar=%s',
            [buscar or None],
        )
        return sp.cursor_rows(cursor)


def obtener_nombre_registrador(id_usuario: str | None):
    if not id_usuario:
        return ''
    with connection.cursor() as cursor:
        cursor.execute(
            f"""
            SELECT {concat_nombre_usuario('u')}
            FROM USUARIO u
            WHERE u.IDUSUARIO = %s
            """,
            [id_usuario],
        )
        row = cursor.fetchone()
    return (row[0] or '').strip() if row else ''


def listar_catalogos(id_registrador=None):
    catalogos = {
        'planes': [],
        'aulas': [],
        'metodosPago': [],
        'tutores': [],
        'estadosMensualidad': [
            {'value': 2, 'label': 'Activo'},
            {'value': 3, 'label': 'Vencido'},
        ],
    }
    with connection.cursor() as cursor:
        cursor.execute(
            f"""
            SELECT IDPLAN, NOMBRE
            FROM {plan_table()} WHERE ACTIVO = 1 ORDER BY NOMBRE
            """
        )
        catalogos['planes'] = sp.cursor_rows(cursor)

        cursor.execute(
            """
            SELECT IDMETODOPAGO, TITULO
            FROM METODO_PAGO WHERE ACTIVO = 1 ORDER BY TITULO
            """
        )
        catalogos['metodosPago'] = sp.cursor_rows(cursor)

        try:
            cursor.execute(
                """
                SELECT IDTUTOR, NOMBRE
                FROM TUTOR WHERE ACTIVO = 1 ORDER BY NOMBRE
                """
            )
            catalogos['tutores'] = sp.cursor_rows(cursor)
        except Exception:
            catalogos['tutores'] = []

    aulas = Aula.objects.filter(ACTIVO=True).order_by('NOMBRE').values('IDAULA', 'NOMBRE', 'IDTUTOR')
    catalogos['aulas'] = list(aulas)
    if id_registrador:
        catalogos['registradorNombre'] = obtener_nombre_registrador(id_registrador)
    return catalogos
