"""Servicio de importación de notas desde Excel Scantron (portado de Intranet Vita)."""
from __future__ import annotations

import json
from datetime import datetime
from decimal import Decimal, InvalidOperation, ROUND_HALF_UP

from django.db import connection
from .db_context import prepare_write_cursor
from . import sp_runner as sp
from .sql_compat import concat_nombre_usuario, is_mysql

CORRECTA = Decimal('20').quantize(Decimal('0.001'), rounding=ROUND_HALF_UP)
INCORRECTA = Decimal('-1.125').quantize(Decimal('0.001'), rounding=ROUND_HALF_UP)

AREA_KEYS = (
    'act', 'hm', 'hv', 'arit', 'geo', 'alge', 'trigo', 'lengua', 'lit',
    'psi', 'civ', 'hp', 'hu', 'geo_l', 'eco', 'filo', 'fis', 'qui', 'bio',
)


def _cursor_rows(cursor):
    return sp.cursor_rows(cursor)


def _cast_tipo_importacion(col: str) -> str:
    if is_mysql():
        return f'CAST({col} AS CHAR)'
    return f'CAST({col} AS NVARCHAR(10))'


def _select_top() -> str:
    return '' if is_mysql() else 'TOP 1 '


def _limit_suffix() -> str:
    return 'LIMIT 1' if is_mysql() else ''


def _paginate_sql(offset: int, tamanio: int) -> str:
    if is_mysql():
        return f'LIMIT {int(tamanio)} OFFSET {int(offset)}'
    return f'OFFSET {int(offset)} ROWS FETCH NEXT {int(tamanio)} ROWS ONLY'


def _normalize_key(key: str) -> str:
    return ''.join(str(key or '').lower().split())


def _buscar_en_mapa(row: dict, *keys):
    if not row:
        return None
    normalized = {_normalize_key(k): v for k, v in row.items()}
    for key in keys:
        val = normalized.get(_normalize_key(key))
        if val is not None and str(val).strip() not in ('', '-', 'N/A'):
            return val
    return None


def _extraer_decimal(row: dict, *keys):
    val = _buscar_en_mapa(row, *keys)
    if val is None:
        return None
    try:
        if isinstance(val, (int, float, Decimal)):
            return Decimal(str(val))
        s = str(val).strip().replace(',', '.')
        s = ''.join(c for c in s if c.isdigit() or c in '.-')
        if not s or s in ('0', '-', '.'):
            return None
        return Decimal(s)
    except (InvalidOperation, ValueError):
        return None


def _parse_pts(value):
    if value is None:
        return None, False
    try:
        if isinstance(value, (int, float, Decimal)):
            pts = Decimal(str(value)).quantize(Decimal('0.001'), rounding=ROUND_HALF_UP)
            return pts, True
        s = str(value).strip()
        if not s or s in ('', '-', 'N/A'):
            return None, False
        pts = Decimal(s.replace(',', '.')).quantize(Decimal('0.001'), rounding=ROUND_HALF_UP)
        return pts, True
    except (InvalidOperation, ValueError):
        return None, False


def _contar_correctas(puntos: list, start: int, end: int) -> int:
    total = 0
    for i in range(start, min(end, len(puntos))):
        pts = puntos[i]
        if pts is not None and pts.compare(CORRECTA) == 0:
            total += 1
    return total


def _obtener_areas_ordenadas(tipo_area: str | None) -> list[str]:
    area = (tipo_area or 'A').upper()
    areas: list[str] = []

    def extend(key: str, count: int):
        areas.extend([key] * count)

    if area == 'B':
        extend('act', 10); extend('hm', 10); extend('hv', 10)
        extend('arit', 4); extend('geo', 4); extend('alge', 4); extend('trigo', 3)
        extend('lengua', 6); extend('lit', 4); extend('psi', 4); extend('civ', 4)
        extend('hp', 2); extend('hu', 2); extend('geo_l', 4); extend('eco', 4)
        extend('filo', 4); extend('fis', 7); extend('qui', 7); extend('bio', 7)
    elif area == 'C':
        extend('act', 10); extend('hm', 10); extend('hv', 10)
        extend('arit', 4); extend('geo', 4); extend('alge', 4); extend('trigo', 3)
        extend('lengua', 7); extend('lit', 4); extend('psi', 4); extend('civ', 4)
        extend('hp', 3); extend('hu', 2); extend('geo_l', 4); extend('eco', 4)
        extend('filo', 4); extend('fis', 7); extend('qui', 6); extend('bio', 6)
    elif area == 'D':
        extend('act', 10); extend('hm', 10); extend('hv', 10)
        extend('arit', 4); extend('geo', 4); extend('alge', 4); extend('trigo', 2)
        extend('lengua', 8); extend('lit', 4); extend('psi', 6); extend('civ', 4)
        extend('hp', 3); extend('hu', 3); extend('geo_l', 4); extend('eco', 8)
        extend('filo', 4); extend('fis', 4); extend('qui', 4); extend('bio', 4)
    elif area == 'E':
        extend('act', 10); extend('hm', 10); extend('hv', 10)
        extend('arit', 2); extend('geo', 2); extend('alge', 2); extend('trigo', 2)
        extend('lengua', 8); extend('lit', 6); extend('psi', 6); extend('civ', 4)
        extend('hp', 5); extend('hu', 5); extend('geo_l', 5); extend('eco', 5)
        extend('filo', 6); extend('fis', 4); extend('qui', 4); extend('bio', 4)
    else:
        extend('act', 10); extend('hm', 10); extend('hv', 10)
        extend('arit', 4); extend('geo', 3); extend('alge', 3); extend('trigo', 2)
        extend('lengua', 7); extend('lit', 4); extend('psi', 6); extend('civ', 4)
        extend('hp', 3); extend('hu', 2); extend('geo_l', 4); extend('eco', 4)
        extend('filo', 4); extend('fis', 5); extend('qui', 7); extend('bio', 8)

    while len(areas) < 100:
        areas.append('bio')
    return areas[:100]


def _calcular_areas_40(puntos: list) -> dict:
    return {
        'hm': _contar_correctas(puntos, 0, 4),
        'hv': _contar_correctas(puntos, 4, 8),
        'arit': _contar_correctas(puntos, 8, 10),
        'geo': _contar_correctas(puntos, 10, 12),
        'alge': _contar_correctas(puntos, 12, 14),
        'trigo': _contar_correctas(puntos, 14, 16),
        'lengua': _contar_correctas(puntos, 16, 18),
        'psi': _contar_correctas(puntos, 18, 20),
        'civ': _contar_correctas(puntos, 20, 22),
        'hp': _contar_correctas(puntos, 22, 24),
        'hu': _contar_correctas(puntos, 24, 26),
        'geo_l': _contar_correctas(puntos, 26, 28),
        'eco': _contar_correctas(puntos, 28, 30),
        'filo': _contar_correctas(puntos, 30, 32),
        'fis': _contar_correctas(puntos, 32, 34),
        'qui': _contar_correctas(puntos, 34, 36),
        'bio': _contar_correctas(puntos, 36, 40),
        'act': 0,
        'lit': 0,
    }


def _fecha_db_hoy():
    return datetime.now().strftime('%d%m%Y')


def _fecha_db_desde_input(fecha: str | None) -> str:
    if not fecha:
        return datetime.now().strftime('%d%m%Y')
    s = str(fecha).strip()
    if len(s) == 10 and s[4] == '-':
        y, m, d = s.split('-')
        return f'{d}{m}{y}'
    if len(s) == 8 and s.isdigit():
        return s
    return datetime.now().strftime('%d%m%Y')


def listar_aulas_activas():
    with connection.cursor() as cursor:
        cursor.execute(
            """
            SELECT IDAULA, NOMBRE, CAPACIDAD
            FROM AULA
            WHERE ACTIVO = 1
            ORDER BY NOMBRE
            """
        )
        return _cursor_rows(cursor)


def _buscar_usuario_por_dni(dni: str):
    trim_dni = 'TRIM(DNI)' if is_mysql() else 'LTRIM(RTRIM(DNI))'
    with connection.cursor() as cursor:
        cursor.execute(
            f"""
            SELECT {_select_top()}IDUSUARIO, DNI, NOMBRE, APELLIDO
            FROM USUARIO
            WHERE {trim_dni} = %s AND ESTADO = 'Activo'
            {_limit_suffix()}
            """,
            [dni],
        )
        rows = _cursor_rows(cursor)
        return rows[0] if rows else None


def _verificar_duplicado(id_aula, tipo_importacion, tipo_area, fecha_examen_db):
    if not id_aula:
        return None
    null_area = "IFNULL(TIPO_AREA_ACADEMICA, '')" if is_mysql() else "ISNULL(TIPO_AREA_ACADEMICA, '')"
    with connection.cursor() as cursor:
        cursor.execute(
            f"""
            SELECT {_select_top()}IDIMPORTACION, NOMBRE_ARCHIVO
            FROM NOTAS_IMPORTACION
            WHERE IDAULA = %s
              AND TIPO_IMPORTACION = %s
              AND {null_area} = COALESCE(%s, '')
              AND FECHA_EXAMEN = %s
              AND ESTADO = 'Activo'
            {_limit_suffix()}
            """,
            [id_aula, tipo_importacion, tipo_area or '', fecha_examen_db],
        )
        rows = _cursor_rows(cursor)
        return rows[0] if rows else None


def _insertar_importacion(payload, id_usuario, fecha_examen_db):
    now = datetime.now().strftime('%d%m%Y %H:%M:%S')
    modo = (payload.get('modo') or 'presencial').lower()
    params = [
        payload.get('nombre_archivo') or 'importacion.xlsx',
        now,
        fecha_examen_db,
        id_usuario,
        payload.get('id_aula') or payload.get('salon_id'),
        int(payload.get('tipo_importacion') or 40),
        modo,
        payload.get('tipo_area_academica') if int(payload.get('tipo_importacion') or 40) == 100 else None,
    ]
    with connection.cursor() as cursor:
        prepare_write_cursor(cursor, id_usuario, {'IDUSUARIO': id_usuario})
        if is_mysql():
            cursor.execute(
                """
                INSERT INTO NOTAS_IMPORTACION (
                    NOMBRE_ARCHIVO, FECHA_IMPORTACION, FECHA_EXAMEN, IMPORTADO_POR,
                    IDAULA, TIPO_IMPORTACION, TIPO_EXAMEN, TIPO_AREA_ACADEMICA, ESTADO
                ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, 'Activo')
                """,
                params,
            )
            cursor.execute('SELECT LAST_INSERT_ID()')
            return int(cursor.fetchone()[0])
        cursor.execute(
            """
            INSERT INTO NOTAS_IMPORTACION (
                NOMBRE_ARCHIVO, FECHA_IMPORTACION, FECHA_EXAMEN, IMPORTADO_POR,
                IDAULA, TIPO_IMPORTACION, TIPO_EXAMEN, TIPO_AREA_ACADEMICA, ESTADO
            )
            OUTPUT INSERTED.IDIMPORTACION
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, 'Activo')
            """,
            params,
        )
        return int(cursor.fetchone()[0])


def _upsert_nota(id_importacion, id_usuario, modo, puntaje, porcentaje,
                 correctas, incorrectas, no_respuesta, detalle_areas):
    detalle_json = json.dumps(detalle_areas, ensure_ascii=False)
    params = {
        'act': detalle_areas.get('act', 0),
        'hm': detalle_areas.get('hm', 0),
        'hv': detalle_areas.get('hv', 0),
        'arit': detalle_areas.get('arit', 0),
        'geo': detalle_areas.get('geo', 0),
        'alge': detalle_areas.get('alge', 0),
        'trigo': detalle_areas.get('trigo', 0),
        'lengua': detalle_areas.get('lengua', 0),
        'lit': detalle_areas.get('lit', 0),
        'psi': detalle_areas.get('psi', 0),
        'civ': detalle_areas.get('civ', 0),
        'hp': detalle_areas.get('hp', 0),
        'hu': detalle_areas.get('hu', 0),
        'geo_l': detalle_areas.get('geo_l', 0),
        'eco': detalle_areas.get('eco', 0),
        'filo': detalle_areas.get('filo', 0),
        'fis': detalle_areas.get('fis', 0),
        'qui': detalle_areas.get('qui', 0),
        'bio': detalle_areas.get('bio', 0),
    }
    with connection.cursor() as cursor:
        prepare_write_cursor(cursor, id_usuario, {'IDUSUARIO': id_usuario})
        cursor.execute(
            """
            SELECT IDNOTA FROM NOTA_IMPORTADA
            WHERE IDIMPORTACION = %s AND IDUSUARIO = %s
            """,
            [id_importacion, id_usuario],
        )
        exists = cursor.fetchone()
        if exists:
            cursor.execute(
                """
                UPDATE NOTA_IMPORTADA SET
                    MODO=%s, PUNTAJE=%s, PORCENTAJE=%s, CORRECTAS=%s, INCORRECTAS=%s,
                    NO_RESPUESTA=%s, DETALLE_AREAS=%s,
                    ACT=%s, HM=%s, HV=%s, ARIT=%s, GEO=%s, ALGE=%s, TRIGO=%s,
                    LENGUA=%s, LIT=%s, PSI=%s, CIV=%s, HP=%s, HU=%s, GEO_L=%s,
                    ECO=%s, FILO=%s, FIS=%s, QUI=%s, BIO=%s
                WHERE IDIMPORTACION=%s AND IDUSUARIO=%s
                """,
                [
                    modo, puntaje, porcentaje, correctas, incorrectas, no_respuesta, detalle_json,
                    params['act'], params['hm'], params['hv'], params['arit'], params['geo'],
                    params['alge'], params['trigo'], params['lengua'], params['lit'], params['psi'],
                    params['civ'], params['hp'], params['hu'], params['geo_l'], params['eco'],
                    params['filo'], params['fis'], params['qui'], params['bio'],
                    id_importacion, id_usuario,
                ],
            )
        else:
            cursor.execute(
                """
                INSERT INTO NOTA_IMPORTADA (
                    IDIMPORTACION, IDUSUARIO, MODO, PUNTAJE, PORCENTAJE,
                    CORRECTAS, INCORRECTAS, NO_RESPUESTA, DETALLE_AREAS,
                    ACT, HM, HV, ARIT, GEO, ALGE, TRIGO, LENGUA, LIT, PSI, CIV,
                    HP, HU, GEO_L, ECO, FILO, FIS, QUI, BIO
                ) VALUES (
                    %s,%s,%s,%s,%s,%s,%s,%s,%s,
                    %s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s
                )
                """,
                [
                    id_importacion, id_usuario, modo, puntaje, porcentaje,
                    correctas, incorrectas, no_respuesta, detalle_json,
                    params['act'], params['hm'], params['hv'], params['arit'], params['geo'],
                    params['alge'], params['trigo'], params['lengua'], params['lit'], params['psi'],
                    params['civ'], params['hp'], params['hu'], params['geo_l'], params['eco'],
                    params['filo'], params['fis'], params['qui'], params['bio'],
                ],
            )


def importar_notas(payload: dict, id_usuario: str | None):
    data = payload.get('data') or []
    if not isinstance(data, list) or not data:
        raise ValueError('No hay filas para importar.')

    tipo_importacion = int(payload.get('tipo_importacion') or 40)
    if tipo_importacion not in (40, 100):
        raise ValueError('tipo_importacion debe ser 40 o 100.')

    tipo_area = payload.get('tipo_area_academica') if tipo_importacion == 100 else None
    id_aula = payload.get('id_aula') or payload.get('salon_id')
    fecha_examen_db = _fecha_db_desde_input(payload.get('fecha_examen'))
    modo = (payload.get('modo') or 'presencial').lower()

    dup = _verificar_duplicado(id_aula, tipo_importacion, tipo_area, fecha_examen_db)
    if dup:
        raise ValueError(
            f"Ya existe una importación para ese salón, tipo y fecha ('{dup['NOMBRE_ARCHIVO']}'). "
            'Elimínela antes de volver a importar.'
        )

    id_importacion = _insertar_importacion(payload, id_usuario, fecha_examen_db)

    notas_creadas = 0
    estudiantes_no_encontrados = 0
    filas_sin_dni = 0
    filas_sin_puntaje = 0
    errores: list[str] = []

    areas_ordenadas = _obtener_areas_ordenadas(tipo_area) if tipo_importacion == 100 else None

    for i, row in enumerate(data):
        if not isinstance(row, dict):
            continue
        try:
            dni_obj = _buscar_en_mapa(
                row, 'Student Dni', 'Student DNI', 'DNI', 'dni', 'DNI_ESTUDIANTE',
            )
            if not dni_obj:
                filas_sin_dni += 1
                if len(errores) < 10:
                    errores.append(f'Fila {i + 1} sin DNI')
                continue

            dni = str(dni_obj).strip()
            if not dni or dni == '0':
                filas_sin_dni += 1
                continue

            estudiante = _buscar_usuario_por_dni(dni)
            if not estudiante:
                estudiantes_no_encontrados += 1
                if len(errores) < 10:
                    errores.append(f'Estudiante no encontrado con DNI: {dni} (fila {i + 1})')
                continue

            puntaje = _extraer_decimal(
                row, 'Earned Points', 'Puntaje', 'Nota', 'Total', 'Puntos',
            )
            porcentaje = _extraer_decimal(
                row, 'Percent Correct', 'Porcentaje', '%', 'Porc',
            )

            puntos: list = []
            correctas = incorrectas = no_respuesta = 0
            area_puntajes = {k: 0 for k in AREA_KEYS} if tipo_importacion == 100 else None

            for pregunta_num in range(1, tipo_importacion + 1):
                pts_obj = _buscar_en_mapa(
                    row,
                    f'#{pregunta_num} Points Earned',
                    f'#{pregunta_num} Points earned',
                )
                pts, pts_valido = _parse_pts(pts_obj)
                puntos.append(pts)

                if pts_valido and pts is not None:
                    if pts.compare(CORRECTA) == 0:
                        correctas += 1
                    elif pts.compare(INCORRECTA) == 0:
                        incorrectas += 1
                else:
                    no_respuesta += 1

                if tipo_importacion == 100 and areas_ordenadas and pts is not None:
                    if pts.compare(CORRECTA) == 0:
                        idx = pregunta_num - 1
                        if 0 <= idx < len(areas_ordenadas):
                            area_key = areas_ordenadas[idx]
                            area_puntajes[area_key] = area_puntajes.get(area_key, 0) + 1

            total_actual = correctas + incorrectas + no_respuesta
            if total_actual != tipo_importacion:
                no_respuesta = tipo_importacion - (correctas + incorrectas)

            if tipo_importacion == 40:
                detalle_areas = _calcular_areas_40(puntos)
            else:
                detalle_areas = dict(area_puntajes or {})

            if puntaje is None and porcentaje is not None:
                puntaje = Decimal(str((float(porcentaje) / 100.0) * tipo_importacion))

            if puntaje is None:
                filas_sin_puntaje += 1
                if len(errores) < 10:
                    errores.append(f'Fila {i + 1} sin puntaje (DNI: {dni})')
                continue

            if porcentaje is None:
                porcentaje = Decimal(str((float(puntaje) / tipo_importacion) * 100.0))

            row_modo = (row.get('Modo') or row.get('modo') or modo or 'presencial').lower()

            _upsert_nota(
                id_importacion,
                estudiante['IDUSUARIO'],
                row_modo,
                puntaje,
                porcentaje,
                correctas,
                incorrectas,
                no_respuesta,
                detalle_areas,
            )
            notas_creadas += 1
        except Exception as exc:
            if len(errores) < 10:
                errores.append(f'Error fila {i + 1}: {exc}')

    return {
        'created': notas_creadas,
        'total': len(data),
        'importacion_id': id_importacion,
        'estudiantes_no_encontrados': estudiantes_no_encontrados,
        'filas_sin_dni': filas_sin_dni,
        'filas_sin_puntaje': filas_sin_puntaje,
        'message': f'Se importaron {notas_creadas} notas correctamente de {len(data)} filas',
        'errores': errores,
    }


def listar_importaciones(
    buscar=None,
    tipo=None,
    ordenar_por='FECHA_EXAMEN',
    direccion='DESC',
    pagina=1,
    tamanio=10,
):
    offset = max(0, (int(pagina) - 1) * int(tamanio))
    orden_sql = {
        'NOMBRE_ARCHIVO': 'i.NOMBRE_ARCHIVO',
        'FECHA_EXAMEN': 'i.FECHA_EXAMEN',
        'FECHA_IMPORTACION': 'i.FECHA_IMPORTACION',
        'TIPO_IMPORTACION': 'i.TIPO_IMPORTACION',
        'AULA_NOMBRE': 'a.NOMBRE',
        'TOTAL_NOTAS': 'TOTAL_NOTAS',
        'IMPORTADO_POR': 'IMPORTADO_POR',
    }.get(ordenar_por, 'i.FECHA_EXAMEN')
    dir_sql = 'DESC' if str(direccion).upper() == 'DESC' else 'ASC'
    buscar_like = f'%{buscar}%' if buscar else None
    cast_tipo = _cast_tipo_importacion('i.TIPO_IMPORTACION')
    importado_por = concat_nombre_usuario('u')

    filtro_buscar = f"""
              AND (%s IS NULL OR (
                    i.NOMBRE_ARCHIVO LIKE %s OR
                    a.NOMBRE LIKE %s OR
                    u.NOMBRE LIKE %s OR
                    u.APELLIDO LIKE %s OR
                    u.DNI LIKE %s OR
                    {cast_tipo} LIKE %s
              ))
              AND (%s IS NULL OR {cast_tipo} = %s)
    """
    params_base = [
        buscar_like, buscar_like, buscar_like, buscar_like, buscar_like, buscar_like, buscar_like,
        tipo, tipo,
    ]

    with connection.cursor() as cursor:
        cursor.execute(
            f"""
            SELECT COUNT(*)
            FROM NOTAS_IMPORTACION i
            LEFT JOIN AULA a ON a.IDAULA = i.IDAULA
            LEFT JOIN USUARIO u ON u.IDUSUARIO = i.IMPORTADO_POR
            WHERE i.ESTADO = 'Activo'
            {filtro_buscar}
            """,
            params_base,
        )
        total = int(cursor.fetchone()[0])

        list_params = params_base
        cursor.execute(
            f"""
            SELECT
                i.IDIMPORTACION,
                i.NOMBRE_ARCHIVO,
                i.FECHA_IMPORTACION,
                i.FECHA_EXAMEN,
                i.TIPO_IMPORTACION,
                i.TIPO_EXAMEN,
                i.TIPO_AREA_ACADEMICA,
                i.IDAULA,
                a.NOMBRE AS AULA_NOMBRE,
                a.CAPACIDAD AS AULA_CAPACIDAD,
                u.IDUSUARIO AS IMPORTADO_POR_ID,
                {importado_por} AS IMPORTADO_POR,
                (SELECT COUNT(*) FROM NOTA_IMPORTADA n WHERE n.IDIMPORTACION = i.IDIMPORTACION) AS TOTAL_NOTAS
            FROM NOTAS_IMPORTACION i
            LEFT JOIN AULA a ON a.IDAULA = i.IDAULA
            LEFT JOIN USUARIO u ON u.IDUSUARIO = i.IMPORTADO_POR
            WHERE i.ESTADO = 'Activo'
            {filtro_buscar}
            ORDER BY {orden_sql} {dir_sql}, i.IDIMPORTACION DESC
            {_paginate_sql(offset, tamanio)}
            """,
            list_params,
        )
        return _cursor_rows(cursor), total


def obtener_importacion(id_importacion):
    importado_por = concat_nombre_usuario('u')
    estudiante_nombre = concat_nombre_usuario('u')
    with connection.cursor() as cursor:
        cursor.execute(
            f"""
            SELECT
                i.IDIMPORTACION,
                i.NOMBRE_ARCHIVO,
                i.FECHA_IMPORTACION,
                i.FECHA_EXAMEN,
                i.TIPO_IMPORTACION,
                i.TIPO_EXAMEN,
                i.TIPO_AREA_ACADEMICA,
                i.IDAULA,
                a.NOMBRE AS AULA_NOMBRE,
                a.CAPACIDAD AS AULA_CAPACIDAD,
                {importado_por} AS IMPORTADO_POR
            FROM NOTAS_IMPORTACION i
            LEFT JOIN AULA a ON a.IDAULA = i.IDAULA
            LEFT JOIN USUARIO u ON u.IDUSUARIO = i.IMPORTADO_POR
            WHERE i.IDIMPORTACION = %s AND i.ESTADO = 'Activo'
            """,
            [id_importacion],
        )
        rows = _cursor_rows(cursor)
        if not rows:
            return None

        cursor.execute(
            f"""
            SELECT
                n.IDNOTA,
                n.IDUSUARIO,
                u.DNI AS ESTUDIANTE_DNI,
                {estudiante_nombre} AS ESTUDIANTE_NOMBRE,
                n.MODO,
                n.PUNTAJE,
                n.PORCENTAJE,
                n.CORRECTAS,
                n.INCORRECTAS,
                n.NO_RESPUESTA
            FROM NOTA_IMPORTADA n
            INNER JOIN USUARIO u ON u.IDUSUARIO = n.IDUSUARIO
            WHERE n.IDIMPORTACION = %s
            ORDER BY ESTUDIANTE_NOMBRE
            """,
            [id_importacion],
        )
        notas = _cursor_rows(cursor)
    return {'importacion': rows[0], 'notas': notas}


def eliminar_importacion(id_importacion, id_usuario=None):
    with connection.cursor() as cursor:
        prepare_write_cursor(cursor, id_usuario)
        cursor.execute(
            "SELECT 1 FROM NOTAS_IMPORTACION WHERE IDIMPORTACION = %s AND ESTADO = 'Activo'",
            [id_importacion],
        )
        if not cursor.fetchone():
            return False, 'La importación no existe o ya fue eliminada.'
        cursor.execute('DELETE FROM NOTA_IMPORTADA WHERE IDIMPORTACION = %s', [id_importacion])
        cursor.execute(
            "UPDATE NOTAS_IMPORTACION SET ESTADO = 'Inactivo' WHERE IDIMPORTACION = %s",
            [id_importacion],
        )
    return True, 'Importación eliminada correctamente.'
