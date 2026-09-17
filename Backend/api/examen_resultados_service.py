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


def _fecha_desde_orden(fecha_orden):
    s = str(fecha_orden or '')
    if len(s) >= 8:
        return f'{s[6:8]}{s[4:6]}{s[0:4]}'
    return ''


def _map_fila_tabla(r):
    estado_raw = r.get('ESTADO')
    if estado_raw is None:
        estado_raw = 1
    return {
        'IDINTENTOEXAMEN': r.get('IDINTENTOEXAMEN'),
        'ESTUDIANTE': r.get('ESTUDIANTE') or '',
        'DNI': r.get('DNI') or '',
        'PUNTAJEOBTENIDO': _serialize_decimal(r.get('PUNTAJEOBTENIDO')),
        'CANTCORRECTAS': r.get('CANTCORRECTAS'),
        'CANTINCORRECTAS': r.get('CANTINCORRECTAS'),
        'ESTADOINTENTO': int(estado_raw or 0),
        'EXAMEN': _titulo_importacion(r.get('EXAMEN')) if r.get('EXAMEN') else '',
        'FECHAFIN': r.get('FECHAFIN') or '',
    }


def listar_resultados(
    id_solicitante: str,
    buscar=None,
    id_examen=None,
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
    try:
        pagina = max(1, int(pagina or 1))
    except (TypeError, ValueError):
        pagina = 1
    try:
        tamanio = min(100, max(5, int(tamanio or 10)))
    except (TypeError, ValueError):
        tamanio = 10

    return _listar_resultados_sql(
        id_solicitante, buscar, id_examen, pagina, tamanio, ordenar_por, direccion
    )


def _listar_resultados_sql(
    id_solicitante, buscar, id_examen, pagina, tamanio, ordenar_por=None, direccion=None
):
    vacio = {
        'data': [],
        'total': 0,
        'pagina': pagina,
        'tamanioPagina': tamanio,
        'soloPropios': False,
    }
    offset = (pagina - 1) * tamanio
    solo_propios = _es_estudiante(id_solicitante)
    vacio['soloPropios'] = solo_propios
    if not id_examen and not solo_propios:
        return vacio

    if id_examen:
        tipo_id, valor_id = _parse_id_resultado(id_examen)
        incluir_virtual = tipo_id == 'virtual'
        incluir_importado = tipo_id in ('importacion', 'nota')
        if not incluir_virtual and not incluir_importado:
            return vacio
    else:
        tipo_id, valor_id = None, None
        incluir_virtual = True
        incluir_importado = True

    ymd_i = _ymd_sql('IFNULL(i.FECHAFIN, i.FECHAINICIO)')
    ymd_imp = _ymd_sql('imp.FECHA_EXAMEN')
    est_vacio = _txt("''")
    estudiante_expr = (
        est_vacio
        if solo_propios
        else _txt("UPPER(TRIM(CONCAT(IFNULL(u.APELLIDO, ''), ' ', IFNULL(u.NOMBRE, ''))))")
    )
    dni_expr = est_vacio if solo_propios else _txt('u.DNI')

    virtual_where = ['IFNULL(i.ESTADO, 0) = 1']
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
    if buscar and not solo_propios:
        virtual_where.append(
            """(
                u.DNI LIKE CONCAT('%%', %s, '%%')
                OR u.NOMBRE LIKE CONCAT('%%', %s, '%%')
                OR u.APELLIDO LIKE CONCAT('%%', %s, '%%')
            )"""
        )
        virtual_params.extend([buscar] * 3)
        import_where.append(
            """(
                u.DNI LIKE CONCAT('%%', %s, '%%')
                OR u.NOMBRE LIKE CONCAT('%%', %s, '%%')
                OR u.APELLIDO LIKE CONCAT('%%', %s, '%%')
            )"""
        )
        import_params.extend([buscar] * 3)

    join_usuario_v = '' if solo_propios else 'LEFT JOIN USUARIO u ON u.IDUSUARIO = i.IDUSUARIO'
    join_usuario_i = '' if solo_propios else 'LEFT JOIN USUARIO u ON u.IDUSUARIO = n.IDUSUARIO'
    join_examen = 'INNER JOIN EXAMEN e ON e.IDEXAMEN = i.IDEXAMEN' if solo_propios else ''
    examen_v = _txt('e.TITULO') if solo_propios else _txt("''")
    examen_i = _txt('imp.NOMBRE_ARCHIVO') if solo_propios else _txt("''")
    fecha_v = _txt('IFNULL(i.FECHAFIN, i.FECHAINICIO)') if solo_propios else _txt("''")
    fecha_i = _txt('imp.FECHA_EXAMEN') if solo_propios else _txt("''")

    virtual_sql = f"""
        SELECT
            {_txt('i.IDINTENTOEXAMEN')} AS IDINTENTOEXAMEN,
            {estudiante_expr} AS ESTUDIANTE,
            {dni_expr} AS DNI,
            {examen_v} AS EXAMEN,
            {fecha_v} AS FECHAFIN,
            i.PUNTAJEOBTENIDO,
            i.CANTCORRECTAS,
            i.CANTINCORRECTAS,
            IFNULL(i.ESTADO, 0) AS ESTADO,
            {_txt(f"CONCAT({ymd_i}, LPAD(REPLACE(IFNULL(NULLIF(TRIM(IFNULL(i.HORAFIN, i.HORAINICIO)), ''), '00:00:00'), ':', ''), 6, '0'))")} AS FECHA_ORDEN
        FROM INTENTO_EXAMEN i
        {join_examen}
        {join_usuario_v}
        WHERE {' AND '.join(virtual_where)}
    """
    import_sql = f"""
        SELECT
            {_txt("CONCAT('IMPN-', n.IDNOTA)")} AS IDINTENTOEXAMEN,
            {estudiante_expr} AS ESTUDIANTE,
            {dni_expr} AS DNI,
            {examen_i} AS EXAMEN,
            {fecha_i} AS FECHAFIN,
            n.PUNTAJE AS PUNTAJEOBTENIDO,
            n.CORRECTAS AS CANTCORRECTAS,
            n.INCORRECTAS AS CANTINCORRECTAS,
            CAST(1 AS SIGNED) AS ESTADO,
            {_txt(f"CONCAT({ymd_imp}, '000000')")} AS FECHA_ORDEN
        FROM NOTA_IMPORTADA n
        INNER JOIN NOTAS_IMPORTACION imp ON imp.IDIMPORTACION = n.IDIMPORTACION
        {join_usuario_i}
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
        return vacio

    union_sql = ' UNION ALL '.join(partes)
    order_map = {
        'ESTUDIANTE': 't.ESTUDIANTE',
        'DNI': 't.DNI',
        'EXAMEN': 't.EXAMEN',
        'FECHAFIN': 't.FECHA_ORDEN',
        'PUNTAJEOBTENIDO': 't.PUNTAJEOBTENIDO',
        'CANTCORRECTAS': 't.CANTCORRECTAS',
        'CANTINCORRECTAS': 't.CANTINCORRECTAS',
        'ESTADOINTENTO': 't.ESTADO',
    }
    default_orden = 't.FECHA_ORDEN' if solo_propios else 't.PUNTAJEOBTENIDO'
    col_orden = order_map.get(str(ordenar_por or '').strip().upper(), default_orden)
    dir_sql = 'ASC' if str(direccion or '').upper() == 'ASC' else 'DESC'
    with connection.cursor() as cursor:
        cursor.execute(f'SELECT COUNT(*) AS TOTAL FROM ({union_sql}) t', params)
        total = int((_cursor_rows(cursor)[0] or {}).get('TOTAL') or 0)
        cursor.execute(
            f"""
            SELECT IDINTENTOEXAMEN, ESTUDIANTE, DNI, EXAMEN, FECHAFIN, PUNTAJEOBTENIDO,
                   CANTCORRECTAS, CANTINCORRECTAS, ESTADO
            FROM ({union_sql}) t
            ORDER BY {col_orden} {dir_sql}, t.PUNTAJEOBTENIDO DESC, t.IDINTENTOEXAMEN DESC
            LIMIT %s OFFSET %s
            """,
            [*params, tamanio, offset],
        )
        rows = _cursor_rows(cursor)

    return {
        'data': [_map_fila_tabla(r) for r in rows],
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
        SELECT
            IDEXAMEN,
            MAX(TITULO) AS TITULO,
            ORIGEN,
            MAX(FECHA_ORDEN) AS FECHA_ORDEN,
            MAX(AULA) AS AULA,
            MAX(TIPO_IMPORTACION) AS TIPO_IMPORTACION
        FROM (
            SELECT
                {_txt('e.IDEXAMEN')} AS IDEXAMEN,
                {_txt('e.TITULO')} AS TITULO,
                {_txt("'virtual'")} AS ORIGEN,
                {_txt(f"CONCAT({ymd_i}, LPAD(REPLACE(IFNULL(NULLIF(TRIM(IFNULL(i.HORAFIN, i.HORAINICIO)), ''), '00:00:00'), ':', ''), 6, '0'))")} AS FECHA_ORDEN,
                {_txt("""(
                    SELECT au.NOMBRE FROM EXAMEN_AULA ea
                    INNER JOIN AULA au ON au.IDAULA = ea.IDAULA
                    WHERE ea.IDEXAMEN = e.IDEXAMEN
                    ORDER BY au.NOMBRE LIMIT 1
                )""")} AS AULA,
                CAST(NULL AS SIGNED) AS TIPO_IMPORTACION
            FROM INTENTO_EXAMEN i
            INNER JOIN EXAMEN e ON e.IDEXAMEN = i.IDEXAMEN
            WHERE IFNULL(i.ESTADO, 0) = 1
              {filtro_alumno_v}
            UNION ALL
            SELECT
                {_txt("CONCAT('IMPI-', imp.IDIMPORTACION)")} AS IDEXAMEN,
                {_txt('imp.NOMBRE_ARCHIVO')} AS TITULO,
                {_txt("'importado'")} AS ORIGEN,
                {_txt(f"CONCAT({ymd_imp}, '000000')")} AS FECHA_ORDEN,
                {_txt('au.NOMBRE')} AS AULA,
                imp.TIPO_IMPORTACION
            FROM NOTA_IMPORTADA n
            INNER JOIN NOTAS_IMPORTACION imp ON imp.IDIMPORTACION = n.IDIMPORTACION
            LEFT JOIN AULA au ON au.IDAULA = imp.IDAULA
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
                titulo = _titulo_importacion(titulo)
            examenes.append({
                'IDEXAMEN': row.get('IDEXAMEN'),
                'TITULO': titulo,
                'ORIGEN': origen,
                'FECHA': _fecha_desde_orden(row.get('FECHA_ORDEN')),
                'AULA': row.get('AULA') or '',
                'TIPO_IMPORTACION': row.get('TIPO_IMPORTACION'),
            })
    ultimo = examenes[0] if examenes else None
    return {
        'examenes': examenes,
        'soloPropios': solo_propios,
        'ultimoExamen': ultimo,
    }
