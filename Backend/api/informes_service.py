from datetime import datetime, timedelta

from django.db import connection
from django.utils import timezone

from . import sp_runner as sp
from .sql_compat import is_mysql, isnull

DIAS_ES = ('lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom')
DEFAULT_DIAS_ASISTENCIA = 63  # lun–sáb (bits 0–5)


def _hoy_db():
    return timezone.localtime().strftime('%d%m%Y')


def _cursor_rows(cursor):
    columns = [col[0] for col in cursor.description] if cursor.description else []
    return [dict(zip(columns, row)) for row in cursor.fetchall()]


def _normalizar_fecha_db(fecha):
    """Convierte fecha de BD (CHAR8, datetime, DD/MM/YYYY) a DDMMYYYY."""
    if fecha is None:
        return ''
    if isinstance(fecha, datetime):
        return fecha.strftime('%d%m%Y')
    s = str(fecha).strip()
    if not s:
        return ''
    if len(s) == 8 and s.isdigit():
        return s
    if '/' in s:
        partes = s.split('/')
        if len(partes) == 3 and len(partes[2]) == 4:
            return f'{partes[0].zfill(2)}{partes[1].zfill(2)}{partes[2]}'
    if len(s) >= 10 and s[4] == '-':
        try:
            return datetime.strptime(s[:10], '%Y-%m-%d').strftime('%d%m%Y')
        except ValueError:
            pass
    return ''


def _fecha_db_a_date(s):
    norm = _normalizar_fecha_db(s)
    if not norm:
        return None
    return datetime(int(norm[4:8]), int(norm[2:4]), int(norm[0:2])).date()


def _date_a_fecha_db(d):
    if isinstance(d, datetime):
        d = d.date()
    return d.strftime('%d%m%Y')


def _etiqueta_dia(fecha_db):
    d = _fecha_db_a_date(fecha_db)
    if not d:
        return ''
    return f'{DIAS_ES[d.weekday()]} {d.strftime("%d")}'


def _formatear_fecha_db(fecha_db):
    norm = _normalizar_fecha_db(fecha_db)
    if not norm:
        return ''
    return f'{norm[0:2]}/{norm[2:4]}/{norm[4:]}'


def _estado_vencimiento_mensualidad(fecha_fin_db):
    """Retorna 'vencida', 'proxima' o '' según la fecha fin de mensualidad."""
    fin = _fecha_db_a_date(fecha_fin_db)
    if not fin:
        return ''
    hoy = timezone.localdate()
    dias = (fin - hoy).days
    if dias < 0:
        return 'vencida'
    if dias <= 3:
        return 'proxima'
    return ''


def _generar_rango_dias(fecha_desde, fecha_hasta):
    inicio = _fecha_db_a_date(fecha_desde)
    fin = _fecha_db_a_date(fecha_hasta)
    if not inicio or not fin or inicio > fin:
        return []
    hoy = timezone.localdate()
    dias = []
    actual = inicio
    while actual <= fin:
        fecha_db = _date_a_fecha_db(actual)
        dias.append({
            'fecha': fecha_db,
            'etiqueta': _etiqueta_dia(fecha_db),
            'esDomingo': actual.weekday() == 6,
            'esFuturo': actual > hoy,
            'esHoy': actual == hoy,
        })
        actual += timedelta(days=1)
    return dias


def _dia_imputable_falta(dia):
    """True si el día ya pasó o es hoy: sin marca debe contarse como falta automática."""
    return not dia.get('esFuturo')


def _estado_a_codigo(estado, justificado=False):
    if justificado:
        return 'J'
    e = (estado or '').strip().lower()
    if 'tarde' in e or e == 't':
        return 'T'
    if 'justific' in e or e == 'j':
        return 'J'
    if 'retiro' in e or e == 'r':
        return 'J'
    if 'falta' in e or 'ausente' in e or e == 'f':
        return 'F'
    if 'presente' in e or e == 'a' or e:
        return 'A'
    return ''


def _cargar_justificaciones_rango(fecha_desde, fecha_hasta):
    """Mapa {IDUSUARIO: {FECHA: True}} desde JUSTIFICACION (si existe la tabla)."""
    try:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT IDUSUARIO, FECHA
                FROM JUSTIFICACION
                WHERE FECHA >= %s AND FECHA <= %s
                """,
                [fecha_desde, fecha_hasta],
            )
            rows = _cursor_rows(cursor)
    except Exception:
        return {}

    result = {}
    for row in rows:
        uid = str(row.get('IDUSUARIO') or '').strip()
        fecha = _normalizar_fecha_db(row.get('FECHA'))
        if uid and fecha:
            result.setdefault(uid, {})[fecha] = True
    return result


def _cargar_asistencias_estudiantes(fecha_desde, fecha_hasta, id_usuarios):
    """Asistencias del rango solo para los estudiantes ya filtrados del informe.

    Evita inconsistencias del SP: el buscador de estudiantes incluye aula/ciclo,
    pero el de asistencias no; eso hacía que marcas reales salieran como falta.
    """
    ids = [str(u).strip() for u in (id_usuarios or []) if u]
    if not ids:
        return []

    placeholders = ', '.join(['%s'] * len(ids))
    with connection.cursor() as cursor:
        if sp.is_mysql():
            cursor.execute(
                f"""
                SELECT a.IDUSUARIO, a.FECHAREGISTRO, a.ESTADO, a.JUSTIFICADO
                FROM ASISTENCIA a
                WHERE a.IDUSUARIO IN ({placeholders})
                  AND a.FECHAREGISTRO IS NOT NULL
                  AND TRIM(a.FECHAREGISTRO) <> ''
                  AND STR_TO_DATE(a.FECHAREGISTRO, '%%d%%m%%Y')
                      BETWEEN STR_TO_DATE(%s, '%%d%%m%%Y')
                          AND STR_TO_DATE(%s, '%%d%%m%%Y')
                """,
                [*ids, fecha_desde, fecha_hasta],
            )
            return _cursor_rows(cursor)

        cursor.execute(
            f"""
            SELECT a.IDUSUARIO, a.FECHAREGISTRO, a.ESTADO, a.JUSTIFICADO
            FROM ASISTENCIA a
            WHERE a.IDUSUARIO IN ({placeholders})
              AND a.FECHAREGISTRO IS NOT NULL
              AND LTRIM(RTRIM(a.FECHAREGISTRO)) <> ''
              AND CONVERT(
                    date,
                    SUBSTRING(a.FECHAREGISTRO, 5, 4)
                      + SUBSTRING(a.FECHAREGISTRO, 3, 2)
                      + SUBSTRING(a.FECHAREGISTRO, 1, 2),
                    112
                  )
                  BETWEEN CONVERT(
                    date,
                    SUBSTRING(%s, 5, 4) + SUBSTRING(%s, 3, 2) + SUBSTRING(%s, 1, 2),
                    112
                  )
                  AND CONVERT(
                    date,
                    SUBSTRING(%s, 5, 4) + SUBSTRING(%s, 3, 2) + SUBSTRING(%s, 1, 2),
                    112
                  )
            """,
            [
                *ids,
                fecha_desde, fecha_desde, fecha_desde,
                fecha_hasta, fecha_hasta, fecha_hasta,
            ],
        )
        return _cursor_rows(cursor)


def _parse_dias_asistencia(val):
    if val is None:
        return DEFAULT_DIAS_ASISTENCIA
    try:
        mask = int(val) & 0x7F
        return mask if mask else DEFAULT_DIAS_ASISTENCIA
    except (TypeError, ValueError):
        return DEFAULT_DIAS_ASISTENCIA


def _dia_permitido_plan(fecha_db, dias_asistencia):
    d = _fecha_db_a_date(fecha_db)
    if not d:
        return False
    return bool(dias_asistencia & (1 << d.weekday()))


def _dia_cuenta_mensualidad(fecha_db, fecha_inicio_db, fecha_fin_db):
    """True si el día está dentro del período de mensualidad (inicio inclusive, fin inclusive)."""
    fecha = _fecha_db_a_date(fecha_db)
    inicio = _fecha_db_a_date(fecha_inicio_db)
    if not fecha or not inicio:
        return False
    if fecha < inicio:
        return False
    fin = _fecha_db_a_date(fecha_fin_db)
    if fin is not None and fecha > fin:
        return False
    return True


def _dia_cuenta_para_falta(fecha_db, fecha_inicio_db, fecha_fin_db):
    """Alias: faltas solo dentro del período de mensualidad."""
    return _dia_cuenta_mensualidad(fecha_db, fecha_inicio_db, fecha_fin_db)


def _construir_filas(estudiantes, asistencias, dias, justificaciones=None):
    marcas_por_usuario = {}
    for row in asistencias:
        uid = str(row.get('IDUSUARIO') or '').strip()
        fecha = _normalizar_fecha_db(row.get('FECHAREGISTRO'))
        if not uid or not fecha:
            continue
        codigo = _estado_a_codigo(row.get('ESTADO'), row.get('JUSTIFICADO'))
        marcas_por_usuario.setdefault(uid, {})[fecha] = codigo

    justificaciones = justificaciones or {}

    filas = []
    for idx, est in enumerate(estudiantes, start=1):
        uid = str(est.get('IDUSUARIO') or '').strip()
        marcas_usuario = marcas_por_usuario.get(uid, {})
        justif_usuario = justificaciones.get(uid, {}) or justificaciones.get(est.get('IDUSUARIO'), {})
        marcas = {}
        total_asist = total_tard = total_faltas = total_just = 0
        dias_imputables = 0

        fecha_inicio_mem = est.get('FECHA_INICIO_MEM')
        fecha_fin_mem = est.get('FECHA_VENCE') or est.get('FECHA_FIN_MEM')
        dias_asistencia = _parse_dias_asistencia(est.get('DIASASISTENCIA'))
        dias_no_lectivos = set()
        dias_fuera_mensualidad = set()

        for dia in dias:
            fecha = dia['fecha']
            permitido = _dia_permitido_plan(fecha, dias_asistencia)
            en_mensualidad = _dia_cuenta_mensualidad(fecha, fecha_inicio_mem, fecha_fin_mem)
            codigo = marcas_usuario.get(fecha, '')

            if not permitido:
                dias_no_lectivos.add(fecha)
                marcas[fecha] = ''
                continue

            if not en_mensualidad:
                dias_fuera_mensualidad.add(fecha)
                marcas[fecha] = ''
                continue

            if justif_usuario.get(fecha):
                codigo = 'J'
            elif not codigo and _dia_imputable_falta(dia):
                codigo = 'F'

            marcas[fecha] = codigo

            if not _dia_imputable_falta(dia):
                continue

            dias_imputables += 1

            if codigo == 'A':
                total_asist += 1
            elif codigo == 'T':
                total_tard += 1
            elif codigo == 'F':
                total_faltas += 1
            elif codigo == 'J':
                total_just += 1

        denom_pct = dias_imputables - total_just
        if denom_pct > 0:
            asist_pct = round(total_asist / denom_pct * 100)
        elif total_asist > 0:
            asist_pct = 100
        else:
            asist_pct = 0

        fecha_vence = est.get('FECHA_VENCE_CUOTA') or est.get('FECHA_VENCE')
        estado_usuario = str(est.get('ESTADO') or '').strip()
        es_retirado = estado_usuario.lower() == 'retirado'
        tiene_deuda_cuota = bool(est.get('CUOTA_CON_DEUDA'))
        if es_retirado:
            estado_vence = ''
            vence_txt = 'Retirado'
        else:
            estado_vence = _estado_vencimiento_mensualidad(fecha_vence)
            vence_txt = _formatear_fecha_db(fecha_vence)
        filas.append({
            'numero': idx,
            'idusuario': uid,
            'nombres': est.get('NOMBRE_COMPLETO') or '',
            'tutora': est.get('TUTORA') or '',
            'aula': est.get('AULA') or '',
            'ciclo': est.get('CICLO') or '',
            'estado': est.get('ESTADO') or 'ACTIVO',
            'vence': vence_txt,
            'venceEn3Dias': (not es_retirado) and estado_vence == 'proxima',
            'venceVencida': (
                (not es_retirado)
                and estado_vence == 'vencida'
                and ('CUOTA_CON_DEUDA' not in est or tiene_deuda_cuota)
            ),
            'marcas': marcas,
            'diasNoLectivos': list(dias_no_lectivos),
            'diasFueraMensualidad': list(dias_fuera_mensualidad),
            'diasAsistencia': dias_asistencia,
            'fechaInicioMensualidad': _formatear_fecha_db(fecha_inicio_mem),
            'totalAsist': total_asist,
            'totalTard': total_tard,
            'totalFaltas': total_faltas,
            'totalJust': total_just,
            'diasImputables': dias_imputables,
            'asistPct': asist_pct,
        })
    return filas


def _calcular_resumen(filas):
    asist = tard = faltas = 0
    for fila in filas:
        asist += fila.get('totalAsist', 0)
        tard += fila.get('totalTard', 0)
        faltas += fila.get('totalFaltas', 0)
    total = asist + tard + faltas
    if total == 0:
        return {
            'asistAcum': 0,
            'tardanzaAcum': 0,
            'faltasAcum': 0,
            'totalAsistentes': 0,
            'asistPct': 0,
            'tardanzaPct': 0,
            'faltasPct': 0,
            'totalMarcas': 0,
        }
    return {
        'asistAcum': asist,
        'tardanzaAcum': tard,
        'faltasAcum': faltas,
        'totalAsistentes': asist + tard,
        'asistPct': round(asist / total * 100),
        'tardanzaPct': round(tard / total * 100),
        'faltasPct': round(faltas / total * 100),
        'totalMarcas': total,
    }


def _respuesta_informe(fecha_desde, fecha_hasta, dias, filas):
    return {
        'fechaDesde': fecha_desde,
        'fechaHasta': fecha_hasta,
        'dias': dias,
        'filas': filas,
        'total': len(filas),
        'resumen': _calcular_resumen(filas),
    }


def _aplicar_vence_cuota(estudiantes):
    """Completa FECHA_VENCE_CUOTA con la cuota impaga más antigua (no avanza si hay deuda)."""
    try:
        from .cuota_service import vence_cuota_vigente_map
        mapa = vence_cuota_vigente_map([e.get('IDUSUARIO') for e in estudiantes])
    except Exception:
        return estudiantes
    for est in estudiantes:
        if str(est.get('ESTADO') or '').strip().lower() == 'retirado':
            est['FECHA_VENCE_CUOTA'] = None
            est['CUOTA_CON_DEUDA'] = False
            continue
        info = mapa.get(str(est.get('IDUSUARIO') or ''))
        if not info:
            continue
        if isinstance(info, tuple):
            vence, tiene_deuda = info
        else:
            vence, tiene_deuda = info, False
        if vence:
            est['FECHA_VENCE_CUOTA'] = vence
            est['CUOTA_CON_DEUDA'] = bool(tiene_deuda)
    return estudiantes


def _normalizar_estado_usuario(estado):
    e = (estado or '').strip()
    if not e or e.lower() in ('todos', 'all'):
        return None
    if e.lower() == 'activo':
        return 'Activo'
    if e.lower() in ('inactivo', 'retirado'):
        return 'Retirado'
    return e


def _listar_estudiantes_informe(
    fecha_desde,
    fecha_hasta,
    buscar=None,
    id_plan=None,
    estado_usuario=None,
    id_aula=None,
    id_tutor=None,
):
    """Lista estudiantes del informe con filtros opcionales de plan, aula y tutor."""
    buscar = (buscar or '').strip() or None
    id_plan = (id_plan or '').strip() or None
    id_aula = (id_aula or '').strip() or None
    id_tutor = (id_tutor or '').strip() or None
    estado_usuario = _normalizar_estado_usuario(estado_usuario)

    plan_table = '`PLAN`' if is_mysql() else '[PLAN]'
    concat_like = "CONCAT('%%', %s, '%%')" if is_mysql() else "('%%' + %s + '%%')"
    ifnull = 'IFNULL' if is_mysql() else 'ISNULL'
    trim_concat_nombre = (
        f"UPPER(TRIM(CONCAT({ifnull}(u.APELLIDO, ''), ' ', {ifnull}(u.NOMBRE, ''))))"
        if is_mysql()
        else f"UPPER(LTRIM(RTRIM({ifnull}(u.APELLIDO, '') + ' ' + {ifnull}(u.NOMBRE, ''))))"
    )
    ciclo_expr = (
        f"""UPPER(TRIM(CONCAT(
            {ifnull}(pl.NOMBRE, ''),
            CASE WHEN tu.DESCRIPCION IS NOT NULL AND tu.DESCRIPCION <> ''
                 THEN CONCAT(' ', tu.DESCRIPCION) ELSE '' END
        )))"""
        if is_mysql()
        else f"""UPPER(LTRIM(RTRIM(
            {ifnull}(pl.NOMBRE, '') +
            CASE WHEN tu.DESCRIPCION IS NOT NULL AND tu.DESCRIPCION <> ''
                 THEN ' ' + tu.DESCRIPCION ELSE '' END
        )))"""
    )
    tutora_expr = (
        f"""UPPER(TRIM(COALESCE(
            NULLIF(tut_mem.NOMBRE, ''),
            NULLIF(tut_aula.NOMBRE, ''),
            ''
        )))"""
        if is_mysql()
        else f"""UPPER(LTRIM(RTRIM(COALESCE(
            NULLIF(tut_mem.NOMBRE, ''),
            NULLIF(tut_aula.NOMBRE, ''),
            ''
        ))))"""
    )

    if is_mysql():
        mem_join = """
            LEFT JOIN LATERAL (
                SELECT m.IDAULA, m.IDPLAN, m.IDTURNO, m.IDTUTOR, m.FECHAINICIO, m.FECHAFIN
                FROM MENSUALIDAD m
                WHERE m.IDUSUARIO = u.IDUSUARIO
                  AND (m.ESTADO IS NULL OR m.ESTADO = 'Activo')
                ORDER BY
                    CASE
                        WHEN (m.FECHAINICIO IS NULL OR m.FECHAINICIO <= %s)
                         AND (m.FECHAFIN IS NULL OR m.FECHAFIN >= %s)
                        THEN 0 ELSE 1
                    END,
                    m.FECHAREGISTRO DESC,
                    m.FECHAINICIO DESC
                LIMIT 1
            ) mem ON TRUE
            """
    else:
        mem_join = """
            OUTER APPLY (
                SELECT TOP 1 m.IDAULA, m.IDPLAN, m.IDTURNO, m.IDTUTOR,
                       m.FECHAINICIO, m.FECHAFIN
                FROM MENSUALIDAD m
                WHERE m.IDUSUARIO = u.IDUSUARIO
                  AND (m.ESTADO IS NULL OR m.ESTADO = 'Activo')
                ORDER BY
                    CASE
                        WHEN (m.FECHAINICIO IS NULL OR m.FECHAINICIO <= %s)
                         AND (m.FECHAFIN IS NULL OR m.FECHAFIN >= %s)
                        THEN 0 ELSE 1
                    END,
                    m.FECHAREGISTRO DESC,
                    m.FECHAINICIO DESC
            ) mem
            """

    where = ["u.IDTIPOUSUARIO = '1'"]
    params = [fecha_hasta, fecha_desde]

    if estado_usuario:
        where.append(f"UPPER({ifnull}(u.ESTADO, 'Activo')) = UPPER(%s)")
        params.append(estado_usuario)
    if id_plan:
        where.append('mem.IDPLAN = %s')
        params.append(id_plan)
    if id_aula:
        where.append('mem.IDAULA = %s')
        params.append(id_aula)
    if id_tutor:
        where.append('(mem.IDTUTOR = %s OR au.IDTUTOR = %s)')
        params.extend([id_tutor, id_tutor])
    if buscar:
        where.append(
            f"""(
                u.DNI LIKE {concat_like}
                OR u.NOMBRE LIKE {concat_like}
                OR u.APELLIDO LIKE {concat_like}
                OR u.IDUSUARIO LIKE {concat_like}
                OR {ifnull}(au.NOMBRE, '') LIKE {concat_like}
                OR {ifnull}(pl.NOMBRE, '') LIKE {concat_like}
                OR {ifnull}(tu.DESCRIPCION, '') LIKE {concat_like}
                OR {ifnull}(tut_mem.NOMBRE, '') LIKE {concat_like}
            )"""
        )
        params.extend([buscar] * 8)

    sql = f"""
        SELECT
            u.IDUSUARIO,
            {trim_concat_nombre} AS NOMBRE_COMPLETO,
            UPPER({ifnull}(u.ESTADO, 'Activo')) AS ESTADO,
            {tutora_expr} AS TUTORA,
            {ifnull}(au.NOMBRE, '') AS AULA,
            {ciclo_expr} AS CICLO,
            mem.FECHAINICIO AS FECHA_INICIO_MEM,
            mem.FECHAFIN AS FECHA_VENCE,
            mem.IDPLAN,
            mem.IDAULA,
            mem.IDTUTOR,
            {ifnull}(pl.DIASASISTENCIA, 63) AS DIASASISTENCIA
        FROM USUARIO u
        {mem_join}
        LEFT JOIN AULA au ON au.IDAULA = mem.IDAULA
        LEFT JOIN TUTOR tut_mem ON tut_mem.IDTUTOR = mem.IDTUTOR
        LEFT JOIN TUTOR tut_aula ON tut_aula.IDTUTOR = au.IDTUTOR
        LEFT JOIN {plan_table} pl ON pl.IDPLAN = mem.IDPLAN
        LEFT JOIN TURNO tu ON tu.IDTURNO = mem.IDTURNO
        WHERE {' AND '.join(where)}
        ORDER BY u.APELLIDO, u.NOMBRE
    """

    with connection.cursor() as cursor:
        cursor.execute(sql, params)
        return _cursor_rows(cursor)


def informe_asistencias(
    fecha_desde,
    fecha_hasta,
    buscar=None,
    id_plan=None,
    estado_usuario=None,
    id_aula=None,
    id_tutor=None,
):
    fecha_desde = (fecha_desde or '').strip()
    fecha_hasta = (fecha_hasta or '').strip()
    id_plan = (id_plan or '').strip() or None
    id_aula = (id_aula or '').strip() or None
    id_tutor = (id_tutor or '').strip() or None
    estado_usuario = _normalizar_estado_usuario(estado_usuario)
    if not fecha_desde or not fecha_hasta:
        raise ValueError('Debe indicar fecha desde y fecha hasta.')
    if fecha_desde > fecha_hasta:
        raise ValueError('La fecha desde no puede ser mayor que la fecha hasta.')

    dias = _generar_rango_dias(fecha_desde, fecha_hasta)
    if not dias:
        raise ValueError('Rango de fechas inválido.')

    estudiantes = None
    # Preferir SP con filtros de aula/tutor (7 params). Si no existe, SQL propio / SP legado.
    try:
        with connection.cursor() as cursor:
            cursor.execute(
                'CALL usp_asistencia_informe(%s, %s, %s, %s, %s, %s, %s)',
                [fecha_desde, fecha_hasta, buscar, id_plan, estado_usuario, id_aula, id_tutor],
            )
            estudiantes = _cursor_rows(cursor)
            while cursor.nextset():
                pass
    except Exception:
        estudiantes = None

    if estudiantes is None:
        try:
            estudiantes = _listar_estudiantes_informe(
                fecha_desde,
                fecha_hasta,
                buscar=buscar,
                id_plan=id_plan,
                estado_usuario=estado_usuario,
                id_aula=id_aula,
                id_tutor=id_tutor,
            )
        except Exception:
            if id_aula or id_tutor:
                raise
            estudiantes = None

    if estudiantes is None:
        with connection.cursor() as cursor:
            params = [fecha_desde, fecha_hasta, buscar, id_plan, estado_usuario]
            if sp.is_mysql():
                cursor.execute(
                    'CALL usp_asistencia_informe(%s, %s, %s, %s, %s)',
                    params,
                )
            else:
                cursor.execute(
                    """
                    EXEC dbo.usp_asistencia_informe
                        @FechaDesde=%s, @FechaHasta=%s, @Buscar=%s, @IDPlan=%s, @EstadoUsuario=%s;
                    """,
                    params,
                )
            estudiantes = _cursor_rows(cursor)
            while cursor.nextset():
                pass

    asistencias = _cargar_asistencias_estudiantes(
        fecha_desde,
        fecha_hasta,
        [e.get('IDUSUARIO') for e in estudiantes],
    )
    justificaciones = _cargar_justificaciones_rango(fecha_desde, fecha_hasta)
    filas = _construir_filas(_aplicar_vence_cuota(estudiantes), asistencias, dias, justificaciones)
    return _respuesta_informe(fecha_desde, fecha_hasta, dias, filas)


def informe_asistencias_orm(
    fecha_desde,
    fecha_hasta,
    buscar=None,
    id_plan=None,
    estado_usuario=None,
    id_aula=None,
    id_tutor=None,
):
    from django.db.models import Q
    from .models import Usuario, Asistencia

    fecha_desde = (fecha_desde or '').strip()
    fecha_hasta = (fecha_hasta or '').strip()
    id_plan = (id_plan or '').strip() or None
    id_aula = (id_aula or '').strip() or None
    id_tutor = (id_tutor or '').strip() or None
    estado_usuario = _normalizar_estado_usuario(estado_usuario)
    if not fecha_desde or not fecha_hasta:
        raise ValueError('Debe indicar fecha desde y fecha hasta.')

    dias = _generar_rango_dias(fecha_desde, fecha_hasta)
    estudiantes_qs = Usuario.objects.filter(IDTIPOUSUARIO_id='1')
    if estado_usuario:
        estudiantes_qs = estudiantes_qs.filter(ESTADO__iexact=estado_usuario)
    if buscar:
        estudiantes_qs = estudiantes_qs.filter(
            Q(DNI__icontains=buscar)
            | Q(NOMBRE__icontains=buscar)
            | Q(APELLIDO__icontains=buscar)
            | Q(IDUSUARIO__icontains=buscar)
        )
    estudiantes_qs = estudiantes_qs.order_by('APELLIDO', 'NOMBRE')

    meta_por_usuario = _meta_estudiantes_sql(fecha_desde, fecha_hasta, id_plan, estado_usuario)

    estudiantes = []
    for u in estudiantes_qs:
        meta = meta_por_usuario.get(u.IDUSUARIO)
        if id_plan and not meta:
            continue
        meta = meta or {}
        if id_aula and str(meta.get('IDAULA') or '') != id_aula:
            continue
        if id_tutor and str(meta.get('IDTUTOR') or '') != id_tutor:
            continue
        estudiantes.append({
            'IDUSUARIO': u.IDUSUARIO,
            'NOMBRE_COMPLETO': f'{u.APELLIDO} {u.NOMBRE}'.strip().upper(),
            'ESTADO': (u.ESTADO or 'Activo').upper(),
            'TUTORA': meta.get('TUTORA', ''),
            'AULA': meta.get('AULA', ''),
            'CICLO': meta.get('CICLO', ''),
            'FECHA_INICIO_MEM': meta.get('FECHA_INICIO_MEM', ''),
            'FECHA_VENCE': meta.get('FECHA_VENCE', ''),
            'DIASASISTENCIA': meta.get('DIASASISTENCIA', DEFAULT_DIAS_ASISTENCIA),
        })

    user_ids = [e['IDUSUARIO'] for e in estudiantes]
    asist_qs = Asistencia.objects.filter(
        FECHAREGISTRO__gte=fecha_desde,
        FECHAREGISTRO__lte=fecha_hasta,
        IDUSUARIO__in=user_ids,
    )
    asistencias = [
        {
            'IDUSUARIO': a.IDUSUARIO,
            'FECHAREGISTRO': a.FECHAREGISTRO,
            'ESTADO': a.ESTADO,
            'JUSTIFICADO': a.JUSTIFICADO,
        }
        for a in asist_qs
    ]

    justificaciones = _cargar_justificaciones_rango(fecha_desde, fecha_hasta)
    filas = _construir_filas(_aplicar_vence_cuota(estudiantes), asistencias, dias, justificaciones)
    return _respuesta_informe(fecha_desde, fecha_hasta, dias, filas)


def _meta_estudiantes_sql(fecha_desde, fecha_hasta, id_plan=None, estado_usuario=None):
    try:
        plan_filter = ''
        estado_filter = ''
        params = [fecha_hasta, fecha_desde]
        if id_plan:
            plan_filter = ' AND mem.IDPLAN = %s'
            params.append(id_plan)
        if estado_usuario:
            estado_filter = ' AND UPPER(' + isnull('u.ESTADO', "'Activo'") + ') = UPPER(%s)'
            params.append(estado_usuario)

        if is_mysql():
            plan_table = '`PLAN`'
            ciclo_expr = f"""UPPER(TRIM(CONCAT(
                        {isnull('pl.NOMBRE', "''")},
                        CASE WHEN tu.DESCRIPCION IS NOT NULL AND tu.DESCRIPCION <> ''
                             THEN CONCAT(' ', tu.DESCRIPCION) ELSE '' END
                    )))"""
            mem_join = """
                LEFT JOIN (
                    SELECT t.IDUSUARIO, t.IDAULA, t.IDPLAN, t.IDTURNO, t.IDTUTOR,
                           t.FECHAINICIO, t.FECHA_VENCE
                    FROM (
                        SELECT
                            m.IDUSUARIO,
                            m.IDAULA, m.IDPLAN, m.IDTURNO, m.IDTUTOR,
                            m.FECHAINICIO, m.FECHAFIN AS FECHA_VENCE,
                            ROW_NUMBER() OVER (
                                PARTITION BY m.IDUSUARIO
                                ORDER BY
                                    CASE
                                        WHEN (m.FECHAINICIO IS NULL OR m.FECHAINICIO <= %s)
                                         AND (m.FECHAFIN IS NULL OR m.FECHAFIN >= %s)
                                        THEN 0 ELSE 1
                                    END,
                                    m.FECHAREGISTRO DESC,
                                    m.FECHAINICIO DESC
                            ) AS RN
                        FROM MENSUALIDAD m
                        WHERE (m.ESTADO IS NULL OR m.ESTADO = 'Activo')
                    ) t
                    WHERE t.RN = 1
                ) mem ON mem.IDUSUARIO = u.IDUSUARIO
                """
        else:
            plan_table = '[PLAN]'
            ciclo_expr = """UPPER(LTRIM(RTRIM(
                        ISNULL(pl.NOMBRE, '') +
                        CASE WHEN tu.DESCRIPCION IS NOT NULL AND tu.DESCRIPCION <> ''
                             THEN ' ' + tu.DESCRIPCION ELSE '' END
                    )))"""
            mem_join = """
                OUTER APPLY (
                    SELECT TOP 1 m.IDAULA, m.IDPLAN, m.IDTURNO, m.IDTUTOR,
                           m.FECHAINICIO, m.FECHAFIN AS FECHA_VENCE
                    FROM MENSUALIDAD m
                    WHERE m.IDUSUARIO = u.IDUSUARIO
                      AND (m.ESTADO IS NULL OR m.ESTADO = 'Activo')
                    ORDER BY
                        CASE
                            WHEN (m.FECHAINICIO IS NULL OR m.FECHAINICIO <= %s)
                             AND (m.FECHAFIN IS NULL OR m.FECHAFIN >= %s)
                            THEN 0 ELSE 1
                        END,
                        m.FECHAREGISTRO DESC,
                        m.FECHAINICIO DESC
                ) mem
                """

        with connection.cursor() as cursor:
            cursor.execute(
                f"""
                SELECT
                    u.IDUSUARIO,
                    mem.IDPLAN,
                    mem.IDAULA,
                    mem.IDTUTOR,
                    {isnull('pl.DIASASISTENCIA', '63')} AS DIASASISTENCIA,
                    UPPER({isnull('tut.NOMBRE', "''")}) AS TUTORA,
                    {isnull("au.NOMBRE", "''")} AS AULA,
                    {ciclo_expr} AS CICLO,
                    mem.FECHAINICIO AS FECHA_INICIO_MEM,
                    mem.FECHA_VENCE
                FROM USUARIO u
                {mem_join}
                LEFT JOIN AULA au ON au.IDAULA = mem.IDAULA
                LEFT JOIN TUTOR tut ON tut.IDTUTOR = mem.IDTUTOR
                LEFT JOIN {plan_table} pl ON pl.IDPLAN = mem.IDPLAN
                LEFT JOIN TURNO tu ON tu.IDTURNO = mem.IDTURNO
                WHERE u.IDTIPOUSUARIO = '1'
                {estado_filter}
                {plan_filter}
                """,
                params,
            )
            rows = _cursor_rows(cursor)
        return {r['IDUSUARIO']: r for r in rows}
    except Exception:
        return {}


def _columna_existe(tabla, columna):
    try:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT COUNT(*) AS C
                FROM information_schema.COLUMNS
                WHERE TABLE_SCHEMA = DATABASE()
                  AND TABLE_NAME = %s
                  AND COLUMN_NAME = %s
                """,
                [tabla, columna],
            )
            row = cursor.fetchone()
            return bool(row and int(row[0] or 0) > 0)
    except Exception:
        return False


def _agregar_conteo(mapa, clave):
    k = (clave or '').strip() or 'Sin dato'
    mapa[k] = mapa.get(k, 0) + 1


def informe_estudiantes(buscar=None, id_plan=None, estado_usuario=None, id_aula=None, id_tutor=None):
    """Listado de estudiantes (sin matriz de asistencia) + indicadores demográficos."""
    buscar = (buscar or '').strip() or None
    id_plan = (id_plan or '').strip() or None
    id_aula = (id_aula or '').strip() or None
    id_tutor = (id_tutor or '').strip() or None
    estado_usuario = _normalizar_estado_usuario(estado_usuario)

    ifnull = 'IFNULL' if is_mysql() else 'ISNULL'
    plan_table = '`PLAN`' if is_mysql() else '[PLAN]'
    concat_like = "CONCAT('%%', %s, '%%')" if is_mysql() else "('%%' + %s + '%%')"
    tiene_como = _columna_existe('USUARIO', 'COMOENTERO')
    como_select = f"{ifnull}(u.COMOENTERO, '') AS COMOENTERO" if tiene_como else "'' AS COMOENTERO"
    distrito_select = f"{ifnull}(u.DISTRITO, '') AS DISTRITO" if _columna_existe('USUARIO', 'DISTRITO') else "'' AS DISTRITO"
    grado_select = f"{ifnull}(u.GRADO, '') AS GRADO" if _columna_existe('USUARIO', 'GRADO') else "'' AS GRADO"
    dni_select = f"{ifnull}(u.DNI, '') AS DNI"

    nombre_expr = (
        f"UPPER(TRIM(CONCAT({ifnull}(u.APELLIDO, ''), ' ', {ifnull}(u.NOMBRE, ''))))"
        if is_mysql()
        else f"UPPER(LTRIM(RTRIM({ifnull}(u.APELLIDO, '') + ' ' + {ifnull}(u.NOMBRE, ''))))"
    )
    ciclo_expr = (
        f"""UPPER(TRIM(CONCAT(
            {ifnull}(pl.NOMBRE, ''),
            CASE WHEN tu.DESCRIPCION IS NOT NULL AND tu.DESCRIPCION <> ''
                 THEN CONCAT(' ', tu.DESCRIPCION) ELSE '' END
        )))"""
        if is_mysql()
        else f"""UPPER(LTRIM(RTRIM(
            {ifnull}(pl.NOMBRE, '') +
            CASE WHEN tu.DESCRIPCION IS NOT NULL AND tu.DESCRIPCION <> ''
                 THEN ' ' + tu.DESCRIPCION ELSE '' END
        )))"""
    )
    tutora_expr = (
        f"""UPPER(TRIM(COALESCE(
            NULLIF(tut_mem.NOMBRE, ''),
            NULLIF(tut_aula.NOMBRE, ''),
            ''
        )))"""
        if is_mysql()
        else f"""UPPER(LTRIM(RTRIM(COALESCE(
            NULLIF(tut_mem.NOMBRE, ''),
            NULLIF(tut_aula.NOMBRE, ''),
            ''
        ))))"""
    )

    if is_mysql():
        mem_join = """
            LEFT JOIN LATERAL (
                SELECT m.IDAULA, m.IDPLAN, m.IDTURNO, m.IDTUTOR, m.FECHAINICIO, m.FECHAFIN
                FROM MENSUALIDAD m
                WHERE m.IDUSUARIO = u.IDUSUARIO
                  AND (m.ESTADO IS NULL OR m.ESTADO = 'Activo')
                ORDER BY m.FECHAREGISTRO DESC, m.FECHAINICIO DESC
                LIMIT 1
            ) mem ON TRUE
            """
    else:
        mem_join = """
            OUTER APPLY (
                SELECT TOP 1 m.IDAULA, m.IDPLAN, m.IDTURNO, m.IDTUTOR, m.FECHAINICIO, m.FECHAFIN
                FROM MENSUALIDAD m
                WHERE m.IDUSUARIO = u.IDUSUARIO
                  AND (m.ESTADO IS NULL OR m.ESTADO = 'Activo')
                ORDER BY m.FECHAREGISTRO DESC, m.FECHAINICIO DESC
            ) mem
            """

    where = ["u.IDTIPOUSUARIO = '1'"]
    params = []
    if estado_usuario:
        where.append(f"UPPER({ifnull}(u.ESTADO, 'Activo')) = UPPER(%s)")
        params.append(estado_usuario)
    if id_plan:
        where.append('mem.IDPLAN = %s')
        params.append(id_plan)
    if id_aula:
        where.append('mem.IDAULA = %s')
        params.append(id_aula)
    if id_tutor:
        where.append('(mem.IDTUTOR = %s OR au.IDTUTOR = %s)')
        params.extend([id_tutor, id_tutor])
    if buscar:
        where.append(
            f"""(
                u.DNI LIKE {concat_like}
                OR u.NOMBRE LIKE {concat_like}
                OR u.APELLIDO LIKE {concat_like}
                OR u.IDUSUARIO LIKE {concat_like}
                OR {ifnull}(au.NOMBRE, '') LIKE {concat_like}
                OR {ifnull}(pl.NOMBRE, '') LIKE {concat_like}
            )"""
        )
        params.extend([buscar] * 6)

    sql = f"""
        SELECT
            u.IDUSUARIO,
            {nombre_expr} AS NOMBRE_COMPLETO,
            {dni_select},
            UPPER({ifnull}(u.ESTADO, 'Activo')) AS ESTADO,
            {tutora_expr} AS TUTORA,
            {ifnull}(au.NOMBRE, '') AS AULA,
            {ciclo_expr} AS CICLO,
            {como_select},
            {distrito_select},
            {grado_select},
            mem.IDPLAN,
            mem.IDAULA,
            mem.IDTUTOR
        FROM USUARIO u
        {mem_join}
        LEFT JOIN AULA au ON au.IDAULA = mem.IDAULA
        LEFT JOIN TUTOR tut_mem ON tut_mem.IDTUTOR = mem.IDTUTOR
        LEFT JOIN TUTOR tut_aula ON tut_aula.IDTUTOR = au.IDTUTOR
        LEFT JOIN {plan_table} pl ON pl.IDPLAN = mem.IDPLAN
        LEFT JOIN TURNO tu ON tu.IDTURNO = mem.IDTURNO
        WHERE {' AND '.join(where)}
        ORDER BY u.APELLIDO, u.NOMBRE
    """

    with connection.cursor() as cursor:
        cursor.execute(sql, params)
        rows = _cursor_rows(cursor)

    filas = []
    por_como = {}
    por_estado = {}
    por_plan = {}
    por_distrito = {}

    for idx, r in enumerate(rows, start=1):
        como = (r.get('COMOENTERO') or '').strip() or 'Sin dato'
        estado = (r.get('ESTADO') or 'ACTIVO').strip() or 'ACTIVO'
        plan = (r.get('CICLO') or '').strip() or 'Sin plan'
        distrito = (r.get('DISTRITO') or '').strip() or 'Sin distrito'

        _agregar_conteo(por_como, como)
        _agregar_conteo(por_estado, estado.title() if estado else 'Activo')
        _agregar_conteo(por_plan, plan)
        _agregar_conteo(por_distrito, distrito)

        filas.append({
            'numero': idx,
            'idusuario': r.get('IDUSUARIO') or '',
            'nombres': r.get('NOMBRE_COMPLETO') or '',
            'dni': r.get('DNI') or '',
            'estado': estado,
            'tutora': r.get('TUTORA') or '',
            'aula': r.get('AULA') or '',
            'ciclo': r.get('CICLO') or '',
            'comoEntero': como if como != 'Sin dato' else '',
            'distrito': r.get('DISTRITO') or '',
            'grado': r.get('GRADO') or '',
        })

    def _lista_mapa(mapa):
        items = [{'etiqueta': k, 'cantidad': v} for k, v in mapa.items()]
        items.sort(key=lambda x: (-x['cantidad'], x['etiqueta']))
        return items

    total = len(filas)
    return {
        'filas': filas,
        'total': total,
        'resumen': {
            'total': total,
            'activos': por_estado.get('Activo', 0),
            'retirados': por_estado.get('Retirado', 0),
            'porComoEntero': _lista_mapa(por_como),
            'porEstado': _lista_mapa(por_estado),
            'porPlan': _lista_mapa(por_plan),
            'porDistrito': _lista_mapa(por_distrito)[:12],
        },
    }
