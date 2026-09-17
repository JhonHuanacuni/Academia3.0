from django.db import connection

from . import sp_runner as sp
from .examen_crud_service import _read_sp_write_result, _media_url, enriquecer_pregunta
from .sql_compat import isnull


def enriquecer_alt_segura(row):
    """Alternativa sin ESCORRECTA."""
    if not row:
        return row
    return {
        'IDALTERNATIVA': row.get('IDALTERNATIVA'),
        'DESCRIPCION': row.get('DESCRIPCION'),
        'ORDEN': row.get('ORDEN'),
        'IMAGEURL': row.get('IMAGEURL'),
        'URLPREVIEW': _media_url(row.get('IMAGEURL')),
    }


def listar_examenes_estudiante(id_usuario: str):
    with connection.cursor() as cursor:
        if sp.is_mysql():
            return sp.call_simple(cursor, 'usp_examen_estudiante_listar', [id_usuario])
        cursor.execute(
            'EXEC dbo.usp_examen_estudiante_listar @IdUsuario=%s',
            [id_usuario],
        )
        return sp.cursor_rows(cursor)


def iniciar_intento(id_examen: str, id_usuario: str):
    with connection.cursor() as cursor:
        if sp.is_mysql():
            row = sp.call_write_outs(
                cursor,
                'usp_examen_intento_iniciar',
                [id_examen, id_usuario],
                ['@_sp_id', '@_sp_r', '@_sp_m'],
                ['IdIntento', 'Resultado', 'Mensaje'],
            )
            if not row:
                return 0, 'Error desconocido', None
            return int(row[1] or 0), str(row[2] or ''), row[0]
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200), @Id NVARCHAR(50);
            EXEC dbo.usp_examen_intento_iniciar
                @IdExamen=%s, @IdUsuario=%s,
                @IdIntento=@Id OUTPUT, @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje, @Id AS IdIntento;
            """,
            [id_examen, id_usuario],
        )
        ok, mensaje, extras = _read_sp_write_result(cursor, extra_cols=['idintento'])
        return ok, mensaje, extras.get('idintento')


def estado_intento(id_intento: str, id_usuario: str):
    with connection.cursor() as cursor:
        if sp.is_mysql():
            cursor.execute(
                'CALL usp_examen_intento_estado(%s, %s)',
                [id_intento, id_usuario],
            )
        else:
            cursor.execute(
                'EXEC dbo.usp_examen_intento_estado @IdIntento=%s, @IdUsuario=%s',
                [id_intento, id_usuario],
            )
        header_rows = sp.cursor_rows(cursor)
        if not header_rows:
            return None
        header = dict(header_rows[0])
        resultado = int(header.get('Resultado') or header.get('RESULTADO') or 0)
        if resultado == 0:
            return {
                'ok': False,
                'mensaje': header.get('Mensaje') or header.get('MENSAJE') or 'Error',
            }

        respondidas = []
        if cursor.nextset():
            respondidas = sp.cursor_rows(cursor)

        pregunta = None
        if cursor.nextset():
            preg_rows = sp.cursor_rows(cursor)
            if preg_rows:
                pregunta = enriquecer_pregunta(preg_rows[0])
                pregunta.pop('ESCORRECTA', None)
            if cursor.nextset():
                alternativas = [enriquecer_alt_segura(r) for r in sp.cursor_rows(cursor)]
                if pregunta is not None:
                    pregunta['ALTERNATIVAS'] = alternativas

        return {
            'ok': True,
            'intento': header,
            'respondidas': respondidas,
            'pregunta': pregunta,
        }


def responder_intento(id_intento: str, id_usuario: str, id_pregunta: str, id_alternativa: str):
    with connection.cursor() as cursor:
        if sp.is_mysql():
            row = sp.call_write_outs(
                cursor,
                'usp_examen_intento_responder',
                [id_intento, id_usuario, id_pregunta, id_alternativa],
                ['@_sp_r', '@_sp_m', '@_sp_ord', '@_sp_ult', '@_sp_agot'],
                ['Resultado', 'Mensaje', 'OrdenSiguiente', 'EsUltima', 'TiempoAgotado'],
            )
            if not row:
                return 0, 'Error desconocido', {}
            ok = int(row[0] or 0)
            mensaje = str(row[1] or '')
            extras = {
                'ordensiguiente': row[2],
                'esultima': row[3],
                'tiempoagotado': row[4],
            }
        else:
            cursor.execute(
                """
                DECLARE @R INT, @M NVARCHAR(200), @Ord INT, @Ult BIT, @Agot BIT;
                EXEC dbo.usp_examen_intento_responder
                    @IdIntento=%s, @IdUsuario=%s, @IdPregunta=%s, @IdAlternativa=%s,
                    @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT,
                    @OrdenSiguiente=@Ord OUTPUT, @EsUltima=@Ult OUTPUT, @TiempoAgotado=@Agot OUTPUT;
                SELECT @R AS Resultado, @M AS Mensaje,
                       @Ord AS OrdenSiguiente, @Ult AS EsUltima, @Agot AS TiempoAgotado;
                """,
                [id_intento, id_usuario, id_pregunta, id_alternativa],
            )
            ok, mensaje, extras = _read_sp_write_result(
                cursor,
                extra_cols=['ordensiguiente', 'esultima', 'tiempoagotado'],
            )
        return ok, mensaje, {
            'ordenSiguiente': extras.get('ordensiguiente'),
            'esUltima': bool(extras.get('esultima')),
            'tiempoAgotado': bool(extras.get('tiempoagotado')),
        }


def finalizar_intento(id_intento: str, id_usuario: str):
    with connection.cursor() as cursor:
        if sp.is_mysql():
            cursor.execute('SET @_sp_r = 0, @_sp_m = NULL')
            cursor.execute(
                'CALL usp_examen_intento_finalizar(%s, %s, @_sp_r, @_sp_m)',
                [id_intento, id_usuario],
            )
        else:
            cursor.execute(
                """
                DECLARE @R INT, @M NVARCHAR(200);
                EXEC dbo.usp_examen_intento_finalizar
                    @IdIntento=%s, @IdUsuario=%s,
                    @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
                SELECT @R AS Resultado, @M AS Mensaje;
                """,
                [id_intento, id_usuario],
            )
        ok = 0
        mensaje = 'Error desconocido'
        resumen = None
        while True:
            if cursor.description:
                rows = sp.cursor_rows(cursor)
                if not rows:
                    pass
                else:
                    first = rows[0]
                    keys = {str(k).lower() for k in first.keys()}
                    if 'idintentoexamen' in keys:
                        resumen = first
                    if 'resultado' in keys:
                        ok = int(first.get('Resultado') or first.get('RESULTADO') or ok)
                        mensaje = first.get('Mensaje') or first.get('MENSAJE') or mensaje
            if not cursor.nextset():
                break

        if sp.is_mysql():
            cursor.execute('SELECT @_sp_r AS Resultado, @_sp_m AS Mensaje')
            row = cursor.fetchone()
            if row:
                ok = int(row[0] or ok)
                mensaje = str(row[1] or mensaje)

    if resumen is None and ok:
        with connection.cursor() as cursor:
            cursor.execute(
                f"""
                SELECT i.IDINTENTOEXAMEN, i.IDEXAMEN, e.TITULO,
                       i.PUNTAJEOBTENIDO, i.CANTCORRECTAS, i.CANTINCORRECTAS,
                       i.CANTSINRESPONDER, i.APROBADO,
                       (SELECT COUNT(*) FROM PREGUNTA WHERE IDEXAMEN = i.IDEXAMEN) AS CANTPREGUNTAS,
                       {isnull('e.PUNTAJETOTAL', '0')} AS PUNTAJETOTAL
                FROM INTENTO_EXAMEN i
                INNER JOIN EXAMEN e ON e.IDEXAMEN = i.IDEXAMEN
                WHERE i.IDINTENTOEXAMEN = %s AND i.IDUSUARIO = %s
                """,
                [id_intento, id_usuario],
            )
            rows = sp.cursor_rows(cursor)
            if rows:
                resumen = rows[0]

    return ok, mensaje, resumen


def _fecha_ymd_sql(expr):
    return (
        f"CONCAT(SUBSTRING({expr}, 5, 4), SUBSTRING({expr}, 3, 2), SUBSTRING({expr}, 1, 2))"
    )


def _nublar_dni(dni, es_yo):
    if es_yo:
        return str(dni or '')
    return ''


def _titulo_importacion(nombre):
    s = str(nombre or 'Examen presencial').strip()
    lower = s.lower()
    for ext in ('.xlsx', '.xls', '.csv'):
        if lower.endswith(ext):
            s = s[: -len(ext)]
            break
    return s.strip() or 'Examen presencial'


def _normalizar_ranking_filas(ranking, id_usuario, total_preg=None):
    id_usuario = str(id_usuario or '')
    total = float(total_preg or 0) or 0
    for idx, row in enumerate(ranking, start=1):
        es_yo = str(row.get('IDUSUARIO') or '') == id_usuario
        row['ES_YO'] = 1 if es_yo else 0
        row['POSICION'] = int(row.get('POSICION') or idx)
        row['DNI'] = _nublar_dni(row.get('DNI'), es_yo)
        row['DNI_NUBLADO'] = 0 if es_yo else 1
        if es_yo:
            row['NOMBRE_COMPLETO'] = row.get('NOMBRE_COMPLETO') or ''
        else:
            row['NOMBRE_COMPLETO'] = ''
        for key in ('PUNTAJEOBTENIDO', 'PCT_CORRECTAS', 'PCT_ERRORES', 'PCT_BLANCO', 'PORCENTAJE'):
            if row.get(key) is not None:
                try:
                    row[key] = float(row[key])
                except (TypeError, ValueError):
                    pass
        for key in ('POSICION', 'CANTCORRECTAS', 'CANTINCORRECTAS', 'CANTSINRESPONDER', 'ES_YO', 'APROBADO'):
            if row.get(key) is not None:
                try:
                    row[key] = int(row[key])
                except (TypeError, ValueError):
                    pass
        if total > 0:
            c = float(row.get('CANTCORRECTAS') or 0)
            e = float(row.get('CANTINCORRECTAS') or 0)
            b = float(row.get('CANTSINRESPONDER') or 0)
            if row.get('PCT_CORRECTAS') is None:
                row['PCT_CORRECTAS'] = round(c / total * 100, 1)
            if row.get('PCT_ERRORES') is None:
                row['PCT_ERRORES'] = round(e / total * 100, 1)
            if row.get('PCT_BLANCO') is None:
                row['PCT_BLANCO'] = round(b / total * 100, 1)
    return ranking


def ranking_aula_ultimo_examen(id_usuario: str):
    """Último examen que rindió el estudiante (virtual o importado) + ranking."""
    id_usuario = (id_usuario or '').strip()
    if not id_usuario:
        return {'examen': None, 'ranking': [], 'miPosicion': None, 'miPuntaje': None}

    ymd_i = _fecha_ymd_sql('i.FECHAFIN')
    ymd_imp = _fecha_ymd_sql('imp.FECHA_EXAMEN')

    with connection.cursor() as cursor:
        cursor.execute(
            f"""
            SELECT
                i.IDEXAMEN, e.TITULO, IFNULL(e.PUNTAJETOTAL, 0) AS PUNTAJETOTAL,
                i.FECHAFIN, i.HORAFIN,
                (SELECT COUNT(*) FROM PREGUNTA p WHERE p.IDEXAMEN = i.IDEXAMEN) AS TOTALPREGUNTAS,
                CONCAT({ymd_i}, LPAD(REPLACE(IFNULL(NULLIF(TRIM(i.HORAFIN), ''), '00:00:00'), ':', ''), 6, '0')) AS ORDEN
            FROM INTENTO_EXAMEN i
            INNER JOIN EXAMEN e ON e.IDEXAMEN = i.IDEXAMEN
            WHERE i.IDUSUARIO = %s
              AND IFNULL(i.ESTADO, 0) = 1
              AND i.FECHAFIN IS NOT NULL AND CHAR_LENGTH(i.FECHAFIN) = 8
            ORDER BY ORDEN DESC, i.IDINTENTOEXAMEN DESC
            LIMIT 1
            """,
            [id_usuario],
        )
        virtual = sp.cursor_rows(cursor)
        cursor.execute(
            f"""
            SELECT
                n.IDNOTA, n.IDIMPORTACION, n.PUNTAJE, n.PORCENTAJE,
                imp.FECHA_EXAMEN, imp.NOMBRE_ARCHIVO, imp.TIPO_IMPORTACION,
                IFNULL(NULLIF(imp.TIPO_EXAMEN, ''), 'presencial') AS TIPO_EXAMEN,
                imp.IDAULA, au.NOMBRE AS AULA_NOMBRE,
                CONCAT({ymd_imp}, '000000') AS ORDEN
            FROM NOTA_IMPORTADA n
            INNER JOIN NOTAS_IMPORTACION imp ON imp.IDIMPORTACION = n.IDIMPORTACION
            LEFT JOIN AULA au ON au.IDAULA = imp.IDAULA
            WHERE n.IDUSUARIO = %s
              AND IFNULL(imp.ESTADO, 'Activo') = 'Activo'
              AND imp.FECHA_EXAMEN IS NOT NULL AND CHAR_LENGTH(imp.FECHA_EXAMEN) = 8
            ORDER BY ORDEN DESC, n.IDNOTA DESC
            LIMIT 1
            """,
            [id_usuario],
        )
        importado = sp.cursor_rows(cursor)

    v = virtual[0] if virtual else None
    imp = importado[0] if importado else None
    usar_importado = False
    if imp and not v:
        usar_importado = True
    elif imp and v:
        usar_importado = str(imp.get('ORDEN') or '') >= str(v.get('ORDEN') or '')

    if usar_importado:
        return _ranking_importacion(id_usuario, imp)
    if v:
        return _ranking_virtual(id_usuario, v)
    return {'examen': None, 'ranking': [], 'miPosicion': None, 'miPuntaje': None}


def _ranking_virtual(id_usuario, examen_row):
    id_examen = examen_row.get('IDEXAMEN')
    total_preg = int(examen_row.get('TOTALPREGUNTAS') or 0) or 1
    with connection.cursor() as cursor:
        cursor.execute(
            """
            SELECT au.NOMBRE
            FROM MENSUALIDAD m
            LEFT JOIN AULA au ON au.IDAULA = m.IDAULA
            WHERE m.IDUSUARIO = %s AND (m.ESTADO IS NULL OR m.ESTADO = 'Activo')
            ORDER BY m.FECHAREGISTRO DESC, m.IDMENSUALIDAD DESC
            LIMIT 1
            """,
            [id_usuario],
        )
        aula_row = cursor.fetchone()
        aula_nombre = aula_row[0] if aula_row else ''
        cursor.execute(
            """
            SELECT
                t.IDUSUARIO, u.DNI,
                UPPER(TRIM(CONCAT(IFNULL(u.APELLIDO, ''), ' ', IFNULL(u.NOMBRE, '')))) AS NOMBRE_COMPLETO,
                t.PUNTAJEOBTENIDO, t.CANTCORRECTAS, t.CANTINCORRECTAS, t.CANTSINRESPONDER, t.APROBADO
            FROM (
                SELECT
                    i.IDUSUARIO, i.PUNTAJEOBTENIDO, i.CANTCORRECTAS, i.CANTINCORRECTAS,
                    i.CANTSINRESPONDER, i.APROBADO,
                    ROW_NUMBER() OVER (
                        PARTITION BY i.IDUSUARIO
                        ORDER BY i.PUNTAJEOBTENIDO DESC, i.NUMEROINTENTO DESC, i.IDINTENTOEXAMEN DESC
                    ) AS RN
                FROM INTENTO_EXAMEN i
                WHERE i.IDEXAMEN = %s AND IFNULL(i.ESTADO, 0) = 1
            ) t
            INNER JOIN USUARIO u ON u.IDUSUARIO = t.IDUSUARIO
            WHERE t.RN = 1
            ORDER BY t.PUNTAJEOBTENIDO DESC, t.CANTCORRECTAS DESC, NOMBRE_COMPLETO
            """,
            [id_examen],
        )
        ranking = sp.cursor_rows(cursor)

    ranking = _normalizar_ranking_filas(ranking, id_usuario, total_preg)
    mi_fila = next((r for r in ranking if r.get('ES_YO') == 1), None)
    return {
        'examen': {
            'IDEXAMEN': id_examen,
            'TITULO': examen_row.get('TITULO') or '',
            'PUNTAJETOTAL': examen_row.get('PUNTAJETOTAL'),
            'AULA_NOMBRE': aula_nombre or '',
            'ORIGEN': 'virtual',
            'TIPO_EXAMEN': 'virtual',
            'TOTALPREGUNTAS': total_preg,
        },
        'ranking': ranking,
        'miPosicion': mi_fila.get('POSICION') if mi_fila else None,
        'miPuntaje': float(mi_fila['PUNTAJEOBTENIDO']) if mi_fila and mi_fila.get('PUNTAJEOBTENIDO') is not None else None,
    }


def _ranking_importacion(id_usuario, imp_row):
    id_importacion = imp_row.get('IDIMPORTACION')
    total_preg = int(imp_row.get('TIPO_IMPORTACION') or 0) or 40
    with connection.cursor() as cursor:
        cursor.execute(
            """
            SELECT
                n.IDUSUARIO, u.DNI,
                UPPER(TRIM(CONCAT(IFNULL(u.APELLIDO, ''), ' ', IFNULL(u.NOMBRE, '')))) AS NOMBRE_COMPLETO,
                n.PUNTAJE AS PUNTAJEOBTENIDO,
                n.CORRECTAS AS CANTCORRECTAS,
                n.INCORRECTAS AS CANTINCORRECTAS,
                n.NO_RESPUESTA AS CANTSINRESPONDER,
                n.PORCENTAJE
            FROM NOTA_IMPORTADA n
            INNER JOIN USUARIO u ON u.IDUSUARIO = n.IDUSUARIO
            WHERE n.IDIMPORTACION = %s
            ORDER BY n.PUNTAJE DESC, n.CORRECTAS DESC, NOMBRE_COMPLETO
            """,
            [id_importacion],
        )
        ranking = sp.cursor_rows(cursor)

    ranking = _normalizar_ranking_filas(ranking, id_usuario, total_preg)
    mi_fila = next((r for r in ranking if r.get('ES_YO') == 1), None)
    tipo = (imp_row.get('TIPO_EXAMEN') or 'presencial').strip().lower() or 'presencial'
    return {
        'examen': {
            'IDEXAMEN': f"IMPI-{id_importacion}",
            'IDIMPORTACION': id_importacion,
            'TITULO': _titulo_importacion(imp_row.get('NOMBRE_ARCHIVO')),
            'PUNTAJETOTAL': None,
            'AULA_NOMBRE': imp_row.get('AULA_NOMBRE') or '',
            'ORIGEN': 'importado',
            'TIPO_EXAMEN': tipo,
            'TIPO_IMPORTACION': total_preg,
            'TOTALPREGUNTAS': total_preg,
        },
        'ranking': ranking,
        'miPosicion': mi_fila.get('POSICION') if mi_fila else None,
        'miPuntaje': float(mi_fila['PUNTAJEOBTENIDO']) if mi_fila and mi_fila.get('PUNTAJEOBTENIDO') is not None else None,
    }

