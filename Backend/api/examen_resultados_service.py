"""Listado y detalle de resultados de exámenes (intentos finalizados)."""

from django.db import connection


def _cursor_rows(cursor):
    columns = [col[0] for col in cursor.description] if cursor.description else []
    return [dict(zip(columns, row)) for row in cursor.fetchall()]


def _es_estudiante(id_usuario: str) -> bool:
    with connection.cursor() as cursor:
        cursor.execute(
            "SELECT IDTIPOUSUARIO FROM USUARIO WHERE IDUSUARIO = %s",
            [id_usuario],
        )
        row = cursor.fetchone()
    if not row:
        return False
    return str(row[0]) == '1'


def _serialize_decimal(val):
    if val is None:
        return None
    try:
        return float(val)
    except (TypeError, ValueError):
        return val


def _map_fila_listado(r):
    return {
        'IDINTENTOEXAMEN': r.get('IDINTENTOEXAMEN'),
        'IDEXAMEN': r.get('IDEXAMEN'),
        'EXAMEN': r.get('EXAMEN') or '',
        'IDUSUARIO': r.get('IDUSUARIO'),
        'ESTUDIANTE': r.get('ESTUDIANTE') or '',
        'DNI': r.get('DNI') or '',
        'AULA': r.get('AULA') or '',
        'NUMEROINTENTO': r.get('NUMEROINTENTO'),
        'FECHAINICIO': r.get('FECHAINICIO') or '',
        'HORAINICIO': r.get('HORAINICIO') or '',
        'FECHAFIN': r.get('FECHAFIN') or '',
        'HORAFIN': r.get('HORAFIN') or '',
        'PUNTAJEOBTENIDO': _serialize_decimal(r.get('PUNTAJEOBTENIDO')),
        'PUNTAJETOTAL': _serialize_decimal(r.get('PUNTAJETOTAL')),
        'PUNTAJEAPROBADO': _serialize_decimal(r.get('PUNTAJEAPROBADO')),
        'CANTCORRECTAS': r.get('CANTCORRECTAS'),
        'CANTINCORRECTAS': r.get('CANTINCORRECTAS'),
        'CANTSINRESPONDER': r.get('CANTSINRESPONDER'),
        'APROBADO': bool(r.get('APROBADO')) if r.get('APROBADO') is not None else None,
    }


def _map_preguntas(preguntas_raw):
    preguntas = []
    for idx, p in enumerate(preguntas_raw, start=1):
        elegida = p.get('IDALTERNATIVA_ELEGIDA')
        correcta = bool(p.get('ELEGIDA_CORRECTA')) if elegida else False
        sin_respuesta = not elegida
        if sin_respuesta:
            estado = 'blanco'
        elif correcta:
            estado = 'correcta'
        else:
            estado = 'incorrecta'

        preguntas.append({
            'numero': idx,
            'IDPREGUNTA': p.get('IDPREGUNTA'),
            'TITULO': p.get('TITULO') or '',
            'DESCRIPCION': p.get('DESCRIPCION') or '',
            'IMAGEURL': p.get('IMAGEURL') or '',
            'MATERIA': p.get('MATERIA') or '',
            'PUNTAJE': _serialize_decimal(p.get('PUNTAJE')),
            'PUNTAJE_OBTENIDO': _serialize_decimal(p.get('PUNTAJE_OBTENIDO')),
            'estado': estado,
            'respuestaElegida': p.get('RESPUESTA_ELEGIDA') or '',
            'respuestaElegidaImg': p.get('RESPUESTA_ELEGIDA_IMG') or '',
            'respuestaCorrecta': p.get('RESPUESTA_CORRECTA') or '',
            'respuestaCorrectaImg': p.get('RESPUESTA_CORRECTA_IMG') or '',
            'mostrarCorrecta': estado != 'correcta',
        })
    return preguntas


def listar_resultados(
    id_solicitante: str,
    buscar=None,
    id_examen=None,
    id_aula=None,
    pagina=1,
    tamanio=20,
):
    id_solicitante = (id_solicitante or '').strip()
    if not id_solicitante:
        raise ValueError('Falta idusuario')

    buscar = (buscar or '').strip() or None
    id_examen = (id_examen or '').strip() or None
    id_aula = (id_aula or '').strip() or None
    try:
        pagina = max(1, int(pagina or 1))
    except (TypeError, ValueError):
        pagina = 1
    try:
        tamanio = min(100, max(5, int(tamanio or 20)))
    except (TypeError, ValueError):
        tamanio = 20

    try:
        with connection.cursor() as cursor:
            cursor.execute(
                'CALL usp_examen_resultados_listar(%s, %s, %s, %s, %s, %s)',
                [id_solicitante, buscar, id_examen, id_aula, pagina, tamanio],
            )
            meta_rows = _cursor_rows(cursor)
            meta = meta_rows[0] if meta_rows else {}
            cursor.nextset()
            rows = _cursor_rows(cursor)
            while cursor.nextset():
                pass
        return {
            'data': [_map_fila_listado(r) for r in rows],
            'total': int(meta.get('TOTAL') or 0),
            'pagina': int(meta.get('PAGINA') or pagina),
            'tamanioPagina': int(meta.get('TAMANIOPAGINA') or tamanio),
            'soloPropios': bool(meta.get('SOLOPROPIOS')),
        }
    except Exception:
        return _listar_resultados_sql(
            id_solicitante, buscar, id_examen, id_aula, pagina, tamanio
        )


def _listar_resultados_sql(id_solicitante, buscar, id_examen, id_aula, pagina, tamanio):
    offset = (pagina - 1) * tamanio
    solo_propios = _es_estudiante(id_solicitante)
    where = ['IFNULL(i.ESTADO, 0) = 1']
    params = []

    if solo_propios:
        where.append('i.IDUSUARIO = %s')
        params.append(id_solicitante)
    if id_examen:
        where.append('i.IDEXAMEN = %s')
        params.append(id_examen)
    if id_aula:
        where.append(
            """(
                IFNULL(e.TODASLASULA, 1) = 1
                OR EXISTS (
                    SELECT 1 FROM EXAMEN_AULA ea
                    WHERE ea.IDEXAMEN = e.IDEXAMEN AND ea.IDAULA = %s
                )
                OR EXISTS (
                    SELECT 1 FROM MENSUALIDAD m
                    WHERE m.IDUSUARIO = i.IDUSUARIO
                      AND m.IDAULA = %s
                      AND (m.ESTADO IS NULL OR m.ESTADO = 'Activo')
                )
            )"""
        )
        params.extend([id_aula, id_aula])
    if buscar:
        where.append(
            """(
                u.DNI LIKE CONCAT('%%', %s, '%%')
                OR u.NOMBRE LIKE CONCAT('%%', %s, '%%')
                OR u.APELLIDO LIKE CONCAT('%%', %s, '%%')
                OR e.TITULO LIKE CONCAT('%%', %s, '%%')
                OR i.IDINTENTOEXAMEN LIKE CONCAT('%%', %s, '%%')
            )"""
        )
        params.extend([buscar] * 5)

    where_sql = ' AND '.join(where)
    with connection.cursor() as cursor:
        cursor.execute(
            f"""
            SELECT COUNT(*) AS TOTAL
            FROM INTENTO_EXAMEN i
            INNER JOIN EXAMEN e ON e.IDEXAMEN = i.IDEXAMEN
            INNER JOIN USUARIO u ON u.IDUSUARIO = i.IDUSUARIO
            WHERE {where_sql}
            """,
            params,
        )
        total = int((_cursor_rows(cursor)[0] or {}).get('TOTAL') or 0)
        cursor.execute(
            f"""
            SELECT
                i.IDINTENTOEXAMEN, i.IDEXAMEN, e.TITULO AS EXAMEN, i.IDUSUARIO,
                UPPER(TRIM(CONCAT(IFNULL(u.APELLIDO, ''), ' ', IFNULL(u.NOMBRE, '')))) AS ESTUDIANTE,
                u.DNI, i.NUMEROINTENTO, i.FECHAINICIO, i.HORAINICIO, i.FECHAFIN, i.HORAFIN,
                i.PUNTAJEOBTENIDO, i.CANTCORRECTAS, i.CANTINCORRECTAS, i.CANTSINRESPONDER,
                i.APROBADO, IFNULL(e.PUNTAJETOTAL, 0) AS PUNTAJETOTAL, e.PUNTAJEAPROBADO,
                (
                    SELECT au.NOMBRE FROM MENSUALIDAD m
                    LEFT JOIN AULA au ON au.IDAULA = m.IDAULA
                    WHERE m.IDUSUARIO = i.IDUSUARIO AND (m.ESTADO IS NULL OR m.ESTADO = 'Activo')
                    ORDER BY m.FECHAREGISTRO DESC LIMIT 1
                ) AS AULA
            FROM INTENTO_EXAMEN i
            INNER JOIN EXAMEN e ON e.IDEXAMEN = i.IDEXAMEN
            INNER JOIN USUARIO u ON u.IDUSUARIO = i.IDUSUARIO
            WHERE {where_sql}
            ORDER BY
                STR_TO_DATE(IFNULL(i.FECHAFIN, i.FECHAINICIO), '%%d%%m%%Y') DESC,
                IFNULL(i.HORAFIN, i.HORAINICIO) DESC,
                i.IDINTENTOEXAMEN DESC
            LIMIT %s OFFSET %s
            """,
            [*params, tamanio, offset],
        )
        rows = _cursor_rows(cursor)

    return {
        'data': [_map_fila_listado(r) for r in rows],
        'total': total,
        'pagina': pagina,
        'tamanioPagina': tamanio,
        'soloPropios': solo_propios,
    }


def detalle_resultado(id_intento: str, id_solicitante: str):
    id_intento = (id_intento or '').strip()
    id_solicitante = (id_solicitante or '').strip()
    if not id_intento or not id_solicitante:
        raise ValueError('Faltan idintento o idusuario')

    try:
        with connection.cursor() as cursor:
            cursor.execute(
                'CALL usp_examen_resultados_detalle(%s, %s)',
                [id_intento, id_solicitante],
            )
            intentos = _cursor_rows(cursor)
            if not intentos:
                return None
            intento = intentos[0]
            cursor.nextset()
            preguntas_raw = _cursor_rows(cursor)
            while cursor.nextset():
                pass
        return {
            'intento': _map_fila_listado(intento),
            'preguntas': _map_preguntas(preguntas_raw),
            'soloPropios': bool(intento.get('SOLOPROPIOS')),
        }
    except Exception as exc:
        msg = str(exc).lower()
        if 'permiso' in msg:
            raise PermissionError('No tienes permiso para ver este resultado') from exc
        if 'finalizado' in msg:
            raise ValueError('El intento aún no está finalizado') from exc
        if 'no encontrado' in msg:
            return None
        return _detalle_resultado_sql(id_intento, id_solicitante)


def _detalle_resultado_sql(id_intento, id_solicitante):
    solo_propios = _es_estudiante(id_solicitante)
    with connection.cursor() as cursor:
        cursor.execute(
            """
            SELECT
                i.IDINTENTOEXAMEN, i.IDEXAMEN, e.TITULO AS EXAMEN, i.IDUSUARIO,
                UPPER(TRIM(CONCAT(IFNULL(u.APELLIDO, ''), ' ', IFNULL(u.NOMBRE, '')))) AS ESTUDIANTE,
                u.DNI, i.NUMEROINTENTO, i.FECHAINICIO, i.HORAINICIO, i.FECHAFIN, i.HORAFIN,
                i.PUNTAJEOBTENIDO, i.CANTCORRECTAS, i.CANTINCORRECTAS, i.CANTSINRESPONDER,
                i.APROBADO, IFNULL(i.ESTADO, 0) AS ESTADO,
                IFNULL(e.PUNTAJETOTAL, 0) AS PUNTAJETOTAL, e.PUNTAJEAPROBADO
            FROM INTENTO_EXAMEN i
            INNER JOIN EXAMEN e ON e.IDEXAMEN = i.IDEXAMEN
            INNER JOIN USUARIO u ON u.IDUSUARIO = i.IDUSUARIO
            WHERE i.IDINTENTOEXAMEN = %s
            """,
            [id_intento],
        )
        rows = _cursor_rows(cursor)
        if not rows:
            return None
        intento = rows[0]
        if solo_propios and str(intento.get('IDUSUARIO')) != id_solicitante:
            raise PermissionError('No tienes permiso para ver este resultado')
        if int(intento.get('ESTADO') or 0) != 1:
            raise ValueError('El intento aún no está finalizado')

        cursor.execute(
            """
            SELECT
                p.IDPREGUNTA, p.ORDEN, p.TITULO, p.DESCRIPCION, p.IMAGEURL,
                IFNULL(p.PUNTAJE, 1) AS PUNTAJE, m.NOMBRE AS MATERIA,
                ra.IDALTERNATIVA AS IDALTERNATIVA_ELEGIDA,
                ra.PUNTAJEOBTENIDO AS PUNTAJE_OBTENIDO,
                ae.DESCRIPCION AS RESPUESTA_ELEGIDA,
                ae.IMAGEURL AS RESPUESTA_ELEGIDA_IMG,
                IFNULL(ae.ESCORRECTA, 0) AS ELEGIDA_CORRECTA,
                ac.IDALTERNATIVA AS IDALTERNATIVA_CORRECTA,
                ac.DESCRIPCION AS RESPUESTA_CORRECTA,
                ac.IMAGEURL AS RESPUESTA_CORRECTA_IMG
            FROM PREGUNTA p
            LEFT JOIN MATERIA m ON m.IDMATERIA = p.IDMATERIA
            LEFT JOIN RESPUESTA_ALUMNO ra
                ON ra.IDPREGUNTA = p.IDPREGUNTA AND ra.IDINTENTOEXAMEN = %s
            LEFT JOIN ALTERNATIVA ae ON ae.IDALTERNATIVA = ra.IDALTERNATIVA
            LEFT JOIN ALTERNATIVA ac
                ON ac.IDPREGUNTA = p.IDPREGUNTA AND IFNULL(ac.ESCORRECTA, 0) = 1
            WHERE p.IDEXAMEN = %s
            ORDER BY IFNULL(p.ORDEN, 9999), p.IDPREGUNTA
            """,
            [id_intento, intento.get('IDEXAMEN')],
        )
        preguntas_raw = _cursor_rows(cursor)

    return {
        'intento': _map_fila_listado(intento),
        'preguntas': _map_preguntas(preguntas_raw),
        'soloPropios': solo_propios,
    }


def catalogos_resultados(id_solicitante: str):
    id_solicitante = (id_solicitante or '').strip()
    solo_propios = _es_estudiante(id_solicitante)
    with connection.cursor() as cursor:
        if solo_propios:
            cursor.execute(
                """
                SELECT DISTINCT e.IDEXAMEN, e.TITULO
                FROM INTENTO_EXAMEN i
                INNER JOIN EXAMEN e ON e.IDEXAMEN = i.IDEXAMEN
                WHERE i.IDUSUARIO = %s AND IFNULL(i.ESTADO, 0) = 1
                ORDER BY e.TITULO
                """,
                [id_solicitante],
            )
        else:
            cursor.execute(
                """
                SELECT e.IDEXAMEN, e.TITULO
                FROM EXAMEN e
                ORDER BY e.TITULO
                """
            )
        examenes = _cursor_rows(cursor)
        if solo_propios:
            aulas = []
        else:
            cursor.execute(
                """
                SELECT IDAULA, NOMBRE FROM AULA
                WHERE IFNULL(ACTIVO, 1) = 1 ORDER BY NOMBRE
                """
            )
            aulas = _cursor_rows(cursor)
    return {'examenes': examenes, 'aulas': aulas, 'soloPropios': solo_propios}
