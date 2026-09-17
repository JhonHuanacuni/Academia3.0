"""Listado y detalle de resultados de exámenes (intentos virtuales + notas importadas)."""

from django.db import connection

AREA_LABELS = (
    ('act', 'Actitud'),
    ('hm', 'Habilidad matemática'),
    ('hv', 'Habilidad verbal'),
    ('arit', 'Aritmética'),
    ('geo', 'Geometría'),
    ('alge', 'Álgebra'),
    ('trigo', 'Trigonometría'),
    ('lengua', 'Lenguaje'),
    ('lit', 'Literatura'),
    ('psi', 'Psicología'),
    ('civ', 'Cívica'),
    ('hp', 'Historia del Perú'),
    ('hu', 'Historia Universal'),
    ('geo_l', 'Geografía'),
    ('eco', 'Economía'),
    ('filo', 'Filosofía'),
    ('fis', 'Física'),
    ('qui', 'Química'),
    ('bio', 'Biología'),
)


def _cursor_rows(cursor):
    columns = [col[0] for col in cursor.description] if cursor.description else []
    return [dict(zip(columns, row)) for row in cursor.fetchall()]


def _ymd_sql(expr):
    return f"CONCAT(SUBSTRING({expr}, 5, 4), SUBSTRING({expr}, 3, 2), SUBSTRING({expr}, 1, 2))"


def _txt(expr):
    """Fuerza utf8mb4_unicode_ci para que UNION no mezcle collations."""
    return f"CONVERT(({expr}) USING utf8mb4) COLLATE utf8mb4_unicode_ci"


def _titulo_importacion(nombre):
    s = str(nombre or 'Examen presencial').strip()
    lower = s.lower()
    for ext in ('.xlsx', '.xls', '.csv'):
        if lower.endswith(ext):
            s = s[: -len(ext)]
            break
    return s.strip() or 'Examen presencial'


def _parse_id_resultado(valor):
    s = str(valor or '').strip()
    if s.startswith('IMPN-'):
        return 'nota', s[5:]
    if s.startswith('IMPI-'):
        return 'importacion', s[5:]
    return 'virtual', s


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
    origen = (r.get('ORIGEN') or 'virtual').strip().lower() or 'virtual'
    tipo = (r.get('TIPO_EXAMEN') or ('presencial' if origen == 'importado' else 'virtual')).strip().lower()
    examen = r.get('EXAMEN') or ''
    if origen == 'importado':
        examen = _titulo_importacion(examen)
    estado_raw = r.get('ESTADO')
    if estado_raw is None and origen == 'importado':
        estado_raw = 1
    return {
        'IDINTENTOEXAMEN': r.get('IDINTENTOEXAMEN'),
        'IDEXAMEN': r.get('IDEXAMEN'),
        'EXAMEN': examen,
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
        'PORCENTAJE': _serialize_decimal(r.get('PORCENTAJE')),
        'CANTCORRECTAS': r.get('CANTCORRECTAS'),
        'CANTINCORRECTAS': r.get('CANTINCORRECTAS'),
        'CANTSINRESPONDER': r.get('CANTSINRESPONDER'),
        'APROBADO': bool(r.get('APROBADO')) if r.get('APROBADO') is not None else None,
        'ESTADOINTENTO': int(estado_raw or 0),
        'ORIGEN': origen,
        'TIPO_EXAMEN': tipo,
        'TIPO_IMPORTACION': r.get('TIPO_IMPORTACION'),
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
    tamanio=10,
    ordenar_por=None,
    direccion=None,
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
        tamanio = min(100, max(5, int(tamanio or 10)))
    except (TypeError, ValueError):
        tamanio = 10

    return _listar_resultados_sql(
        id_solicitante, buscar, id_examen, id_aula, pagina, tamanio, ordenar_por, direccion
    )


def _listar_resultados_sql(
    id_solicitante, buscar, id_examen, id_aula, pagina, tamanio, ordenar_por=None, direccion=None
):
    offset = (pagina - 1) * tamanio
    solo_propios = _es_estudiante(id_solicitante)
    tipo_id, valor_id = _parse_id_resultado(id_examen) if id_examen else (None, None)
    incluir_virtual = tipo_id != 'importacion'
    incluir_importado = tipo_id != 'virtual' or not id_examen
    if tipo_id == 'nota':
        incluir_virtual = False
        incluir_importado = True

    ymd_i = _ymd_sql('IFNULL(i.FECHAFIN, i.FECHAINICIO)')
    ymd_imp = _ymd_sql('imp.FECHA_EXAMEN')

    virtual_where = ['1 = 1']
    virtual_params = []
    import_where = ["IFNULL(imp.ESTADO, 'Activo') = 'Activo'"]
    import_params = []

    if solo_propios:
        virtual_where.append('i.IDUSUARIO = %s')
        virtual_params.append(id_solicitante)
        import_where.append('n.IDUSUARIO = %s')
        import_params.append(id_solicitante)
    if tipo_id == 'virtual' and valor_id:
        virtual_where.append('i.IDEXAMEN = %s')
        virtual_params.append(valor_id)
    if tipo_id == 'importacion' and valor_id:
        import_where.append('imp.IDIMPORTACION = %s')
        import_params.append(valor_id)
    if tipo_id == 'nota' and valor_id:
        import_where.append('n.IDNOTA = %s')
        import_params.append(valor_id)
    if id_aula:
        virtual_where.append(
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
        virtual_params.extend([id_aula, id_aula])
        import_where.append('imp.IDAULA = %s')
        import_params.append(id_aula)
    if buscar:
        virtual_where.append(
            """(
                u.DNI LIKE CONCAT('%%', %s, '%%')
                OR u.NOMBRE LIKE CONCAT('%%', %s, '%%')
                OR u.APELLIDO LIKE CONCAT('%%', %s, '%%')
                OR e.TITULO LIKE CONCAT('%%', %s, '%%')
                OR i.IDINTENTOEXAMEN LIKE CONCAT('%%', %s, '%%')
            )"""
        )
        virtual_params.extend([buscar] * 5)
        import_where.append(
            """(
                u.DNI LIKE CONCAT('%%', %s, '%%')
                OR u.NOMBRE LIKE CONCAT('%%', %s, '%%')
                OR u.APELLIDO LIKE CONCAT('%%', %s, '%%')
                OR imp.NOMBRE_ARCHIVO LIKE CONCAT('%%', %s, '%%')
            )"""
        )
        import_params.extend([buscar] * 4)

    virtual_sql = f"""
        SELECT
            {_txt('i.IDINTENTOEXAMEN')} AS IDINTENTOEXAMEN,
            {_txt('i.IDEXAMEN')} AS IDEXAMEN,
            {_txt('e.TITULO')} AS EXAMEN,
            {_txt('i.IDUSUARIO')} AS IDUSUARIO,
            {_txt("UPPER(TRIM(CONCAT(IFNULL(u.APELLIDO, ''), ' ', IFNULL(u.NOMBRE, ''))))")} AS ESTUDIANTE,
            {_txt('u.DNI')} AS DNI,
            CAST(IFNULL(i.NUMEROINTENTO, 1) AS SIGNED) AS NUMEROINTENTO,
            {_txt('i.FECHAINICIO')} AS FECHAINICIO,
            {_txt('i.HORAINICIO')} AS HORAINICIO,
            {_txt('i.FECHAFIN')} AS FECHAFIN,
            {_txt('i.HORAFIN')} AS HORAFIN,
            i.PUNTAJEOBTENIDO, i.CANTCORRECTAS, i.CANTINCORRECTAS, i.CANTSINRESPONDER,
            i.APROBADO, IFNULL(i.ESTADO, 0) AS ESTADO,
            IFNULL(e.PUNTAJETOTAL, 0) AS PUNTAJETOTAL, e.PUNTAJEAPROBADO,
            CAST(NULL AS DECIMAL(8,2)) AS PORCENTAJE,
            {_txt("'virtual'")} AS ORIGEN,
            {_txt("'virtual'")} AS TIPO_EXAMEN,
            CAST(NULL AS SIGNED) AS TIPO_IMPORTACION,
            {_txt("""(
                SELECT au.NOMBRE FROM MENSUALIDAD m
                LEFT JOIN AULA au ON au.IDAULA = m.IDAULA
                WHERE m.IDUSUARIO = i.IDUSUARIO AND (m.ESTADO IS NULL OR m.ESTADO = 'Activo')
                ORDER BY m.FECHAREGISTRO DESC LIMIT 1
            )""")} AS AULA,
            {_txt(f"CONCAT({ymd_i}, LPAD(REPLACE(IFNULL(NULLIF(TRIM(IFNULL(i.HORAFIN, i.HORAINICIO)), ''), '00:00:00'), ':', ''), 6, '0'))")} AS FECHA_ORDEN
        FROM INTENTO_EXAMEN i
        INNER JOIN EXAMEN e ON e.IDEXAMEN = i.IDEXAMEN
        LEFT JOIN USUARIO u ON u.IDUSUARIO = i.IDUSUARIO
        WHERE {' AND '.join(virtual_where)}
    """
    import_sql = f"""
        SELECT
            {_txt("CONCAT('IMPN-', n.IDNOTA)")} AS IDINTENTOEXAMEN,
            {_txt("CONCAT('IMPI-', imp.IDIMPORTACION)")} AS IDEXAMEN,
            {_txt('imp.NOMBRE_ARCHIVO')} AS EXAMEN,
            {_txt('n.IDUSUARIO')} AS IDUSUARIO,
            {_txt("UPPER(TRIM(CONCAT(IFNULL(u.APELLIDO, ''), ' ', IFNULL(u.NOMBRE, ''))))")} AS ESTUDIANTE,
            {_txt('u.DNI')} AS DNI,
            CAST(1 AS SIGNED) AS NUMEROINTENTO,
            {_txt('imp.FECHA_EXAMEN')} AS FECHAINICIO,
            {_txt("''")} AS HORAINICIO,
            {_txt('imp.FECHA_EXAMEN')} AS FECHAFIN,
            {_txt("''")} AS HORAFIN,
            n.PUNTAJE AS PUNTAJEOBTENIDO,
            n.CORRECTAS AS CANTCORRECTAS,
            n.INCORRECTAS AS CANTINCORRECTAS,
            n.NO_RESPUESTA AS CANTSINRESPONDER,
            CAST(NULL AS SIGNED) AS APROBADO,
            CAST(1 AS SIGNED) AS ESTADO,
            CAST(NULL AS DECIMAL(8,2)) AS PUNTAJETOTAL,
            CAST(NULL AS DECIMAL(8,2)) AS PUNTAJEAPROBADO,
            n.PORCENTAJE,
            {_txt("'importado'")} AS ORIGEN,
            {_txt("IFNULL(NULLIF(imp.TIPO_EXAMEN, ''), 'presencial')")} AS TIPO_EXAMEN,
            imp.TIPO_IMPORTACION,
            {_txt('au.NOMBRE')} AS AULA,
            {_txt(f"CONCAT({ymd_imp}, '000000')")} AS FECHA_ORDEN
        FROM NOTA_IMPORTADA n
        INNER JOIN NOTAS_IMPORTACION imp ON imp.IDIMPORTACION = n.IDIMPORTACION
        LEFT JOIN USUARIO u ON u.IDUSUARIO = n.IDUSUARIO
        LEFT JOIN AULA au ON au.IDAULA = imp.IDAULA
        WHERE {' AND '.join(import_where)}
    """

    partes = []
    params = []
    if incluir_virtual:
        partes.append(virtual_sql)
        params.extend(virtual_params)
    if incluir_importado:
        partes.append(import_sql)
        params.extend(import_params)
    if not partes:
        return {
            'data': [],
            'total': 0,
            'pagina': pagina,
            'tamanioPagina': tamanio,
            'soloPropios': solo_propios,
        }

    union_sql = ' UNION ALL '.join(partes)
    order_map = {
        'ESTUDIANTE': 't.ESTUDIANTE',
        'DNI': 't.DNI',
        'EXAMEN': 't.EXAMEN',
        'TIPO_EXAMEN': 't.TIPO_EXAMEN',
        'AULA': 't.AULA',
        'FECHAFIN': 't.FECHA_ORDEN',
        'FECHAINICIO': 't.FECHA_ORDEN',
        'PUNTAJEOBTENIDO': 't.PUNTAJEOBTENIDO',
        'CANTCORRECTAS': 't.CANTCORRECTAS',
        'CANTINCORRECTAS': 't.CANTINCORRECTAS',
        'ESTADOINTENTO': 't.ESTADO',
        'APROBADO': 't.APROBADO',
    }
    col_orden = order_map.get(str(ordenar_por or '').strip().upper(), 't.FECHA_ORDEN')
    dir_sql = 'ASC' if str(direccion or '').upper() == 'ASC' else 'DESC'
    with connection.cursor() as cursor:
        cursor.execute(f'SELECT COUNT(*) AS TOTAL FROM ({union_sql}) t', params)
        total = int((_cursor_rows(cursor)[0] or {}).get('TOTAL') or 0)
        cursor.execute(
            f"""
            SELECT * FROM ({union_sql}) t
            ORDER BY {col_orden} {dir_sql}, t.PUNTAJEOBTENIDO DESC, t.IDINTENTOEXAMEN DESC
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

    tipo, valor = _parse_id_resultado(id_intento)
    if tipo in ('nota', 'importacion'):
        return _detalle_importado(valor if tipo == 'nota' else None, id_solicitante, id_intento)

    return _detalle_resultado_sql(id_intento, id_solicitante)


def _areas_desde_nota(row):
    areas = []
    for key, etiqueta in AREA_LABELS:
        col = key.upper()
        val = row.get(col)
        if val is None:
            val = row.get(key)
        if val is None and key == 'geo_l':
            val = row.get('GEO_L') or row.get('GEOL')
        try:
            num = float(val)
        except (TypeError, ValueError):
            continue
        if num <= 0:
            continue
        areas.append({'clave': key, 'etiqueta': etiqueta, 'correctas': int(num)})
    return areas


def _detalle_importado(id_nota, id_solicitante, id_intento):
    solo_propios = _es_estudiante(id_solicitante)
    if not id_nota and str(id_intento).startswith('IMPN-'):
        id_nota = str(id_intento)[5:]
    if not id_nota:
        return None
    with connection.cursor() as cursor:
        cursor.execute(
            """
            SELECT
                n.IDNOTA, n.IDUSUARIO, n.PUNTAJE, n.PORCENTAJE,
                n.CORRECTAS, n.INCORRECTAS, n.NO_RESPUESTA, n.MODO,
                n.ACT, n.HM, n.HV, n.ARIT, n.GEO, n.ALGE, n.TRIGO,
                n.LENGUA, n.LIT, n.PSI, n.CIV, n.HP, n.HU, n.GEO_L,
                n.ECO, n.FILO, n.FIS, n.QUI, n.BIO,
                imp.IDIMPORTACION, imp.NOMBRE_ARCHIVO, imp.FECHA_EXAMEN,
                imp.TIPO_IMPORTACION, IFNULL(NULLIF(imp.TIPO_EXAMEN, ''), 'presencial') AS TIPO_EXAMEN,
                au.NOMBRE AS AULA,
                UPPER(TRIM(CONCAT(IFNULL(u.APELLIDO, ''), ' ', IFNULL(u.NOMBRE, '')))) AS ESTUDIANTE,
                u.DNI
            FROM NOTA_IMPORTADA n
            INNER JOIN NOTAS_IMPORTACION imp ON imp.IDIMPORTACION = n.IDIMPORTACION
            LEFT JOIN USUARIO u ON u.IDUSUARIO = n.IDUSUARIO
            LEFT JOIN AULA au ON au.IDAULA = imp.IDAULA
            WHERE n.IDNOTA = %s AND IFNULL(imp.ESTADO, 'Activo') = 'Activo'
            """,
            [id_nota],
        )
        rows = _cursor_rows(cursor)
    if not rows:
        return None
    row = rows[0]
    if solo_propios and str(row.get('IDUSUARIO')) != id_solicitante:
        raise PermissionError('No tienes permiso para ver este resultado')
    intento = _map_fila_listado({
        'IDINTENTOEXAMEN': f"IMPN-{row.get('IDNOTA')}",
        'IDEXAMEN': f"IMPI-{row.get('IDIMPORTACION')}",
        'EXAMEN': row.get('NOMBRE_ARCHIVO'),
        'IDUSUARIO': row.get('IDUSUARIO'),
        'ESTUDIANTE': row.get('ESTUDIANTE'),
        'DNI': row.get('DNI'),
        'AULA': row.get('AULA'),
        'NUMEROINTENTO': 1,
        'FECHAINICIO': row.get('FECHA_EXAMEN'),
        'FECHAFIN': row.get('FECHA_EXAMEN'),
        'PUNTAJEOBTENIDO': row.get('PUNTAJE'),
        'PORCENTAJE': row.get('PORCENTAJE'),
        'CANTCORRECTAS': row.get('CORRECTAS'),
        'CANTINCORRECTAS': row.get('INCORRECTAS'),
        'CANTSINRESPONDER': row.get('NO_RESPUESTA'),
        'ESTADO': 1,
        'ORIGEN': 'importado',
        'TIPO_EXAMEN': row.get('TIPO_EXAMEN') or row.get('MODO') or 'presencial',
        'TIPO_IMPORTACION': row.get('TIPO_IMPORTACION'),
    })
    return {
        'intento': intento,
        'preguntas': [],
        'areas': _areas_desde_nota(row),
        'soloPropios': solo_propios,
    }


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
            LEFT JOIN USUARIO u ON u.IDUSUARIO = i.IDUSUARIO
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
        'intento': _map_fila_listado({**intento, 'ORIGEN': 'virtual', 'TIPO_EXAMEN': 'virtual'}),
        'preguntas': _map_preguntas(preguntas_raw),
        'areas': [],
        'soloPropios': solo_propios,
    }


def catalogos_resultados(id_solicitante: str):
    id_solicitante = (id_solicitante or '').strip()
    solo_propios = _es_estudiante(id_solicitante)
    ymd_i = _ymd_sql('IFNULL(i.FECHAFIN, i.FECHAINICIO)')
    ymd_imp = _ymd_sql('imp.FECHA_EXAMEN')
    filtro_alumno_v = 'AND i.IDUSUARIO = %s' if solo_propios else ''
    filtro_alumno_i = 'AND n.IDUSUARIO = %s' if solo_propios else ''
    params = [id_solicitante, id_solicitante] if solo_propios else []

    sql = f"""
        SELECT IDEXAMEN, MAX(TITULO) AS TITULO, ORIGEN, MAX(FECHA_ORDEN) AS FECHA_ORDEN
        FROM (
            SELECT
                {_txt('e.IDEXAMEN')} AS IDEXAMEN,
                {_txt('e.TITULO')} AS TITULO,
                {_txt("'virtual'")} AS ORIGEN,
                {_txt(f"CONCAT({ymd_i}, LPAD(REPLACE(IFNULL(NULLIF(TRIM(IFNULL(i.HORAFIN, i.HORAINICIO)), ''), '00:00:00'), ':', ''), 6, '0'))")} AS FECHA_ORDEN
            FROM INTENTO_EXAMEN i
            INNER JOIN EXAMEN e ON e.IDEXAMEN = i.IDEXAMEN
            WHERE IFNULL(i.ESTADO, 0) = 1
              {filtro_alumno_v}
            UNION ALL
            SELECT
                {_txt("CONCAT('IMPI-', imp.IDIMPORTACION)")} AS IDEXAMEN,
                {_txt('imp.NOMBRE_ARCHIVO')} AS TITULO,
                {_txt("'importado'")} AS ORIGEN,
                {_txt(f"CONCAT({ymd_imp}, '000000')")} AS FECHA_ORDEN
            FROM NOTA_IMPORTADA n
            INNER JOIN NOTAS_IMPORTACION imp ON imp.IDIMPORTACION = n.IDIMPORTACION
            WHERE IFNULL(imp.ESTADO, 'Activo') = 'Activo'
              {filtro_alumno_i}
        ) t
        GROUP BY IDEXAMEN, ORIGEN
        ORDER BY FECHA_ORDEN DESC, TITULO
    """
    with connection.cursor() as cursor:
        cursor.execute(sql, params)
        examenes = []
        for row in _cursor_rows(cursor):
            origen = (row.get('ORIGEN') or 'virtual').lower()
            titulo = row.get('TITULO') or ''
            if origen == 'importado':
                titulo = f"{_titulo_importacion(titulo)} (Presencial)"
            examenes.append({
                'IDEXAMEN': row.get('IDEXAMEN'),
                'TITULO': titulo,
                'ORIGEN': origen,
                'FECHA_ORDEN': row.get('FECHA_ORDEN') or '',
            })
        aulas = []
        if not solo_propios:
            cursor.execute(
                """
                SELECT IDAULA, NOMBRE FROM AULA
                WHERE IFNULL(ACTIVO, 1) = 1 ORDER BY NOMBRE
                """
            )
            aulas = _cursor_rows(cursor)
    ultimo = examenes[0] if examenes else None
    return {
        'examenes': examenes,
        'aulas': aulas,
        'soloPropios': solo_propios,
        'ultimoExamen': ultimo,
    }
