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
        uid = row.get('IDUSUARIO')
        fecha = _normalizar_fecha_db(row.get('FECHA'))
        if uid and fecha:
            result.setdefault(uid, {})[fecha] = True
    return result


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
        uid = row.get('IDUSUARIO')
        fecha = _normalizar_fecha_db(row.get('FECHAREGISTRO'))
        if not uid or not fecha:
            continue
        codigo = _estado_a_codigo(row.get('ESTADO'), row.get('JUSTIFICADO'))
        marcas_por_usuario.setdefault(uid, {})[fecha] = codigo

    justificaciones = justificaciones or {}

    filas = []
    for idx, est in enumerate(estudiantes, start=1):
        uid = est['IDUSUARIO']
        marcas_usuario = marcas_por_usuario.get(uid, {})
        justif_usuario = justificaciones.get(uid, {})
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
        estado_vence = _estado_vencimiento_mensualidad(fecha_vence)
        filas.append({
            'numero': idx,
            'idusuario': uid,
            'nombres': est.get('NOMBRE_COMPLETO') or '',
            'tutora': est.get('TUTORA') or '',
            'aula': est.get('AULA') or '',
            'ciclo': est.get('CICLO') or '',
            'estado': est.get('ESTADO') or 'ACTIVO',
            'vence': _formatear_fecha_db(fecha_vence),
            'venceEn3Dias': estado_vence == 'proxima',
            'venceVencida': estado_vence == 'vencida',
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
            'asistPct': 0,
            'tardanzaPct': 0,
            'faltasPct': 0,
            'totalMarcas': 0,
        }
    return {
        'asistAcum': asist,
        'tardanzaAcum': tard,
        'faltasAcum': faltas,
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
    """Completa FECHA_VENCE_CUOTA con el vencimiento de la cuota vigente."""
    try:
        from .cuota_service import vence_cuota_vigente_map
        mapa = vence_cuota_vigente_map([e.get('IDUSUARIO') for e in estudiantes])
    except Exception:
        return estudiantes
    for est in estudiantes:
        vence = mapa.get(str(est.get('IDUSUARIO') or ''))
        if vence:
            est['FECHA_VENCE_CUOTA'] = vence
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


def informe_asistencias(fecha_desde, fecha_hasta, buscar=None, id_plan=None, estado_usuario=None):
    fecha_desde = (fecha_desde or '').strip()
    fecha_hasta = (fecha_hasta or '').strip()
    id_plan = (id_plan or '').strip() or None
    estado_usuario = _normalizar_estado_usuario(estado_usuario)
    if not fecha_desde or not fecha_hasta:
        raise ValueError('Debe indicar fecha desde y fecha hasta.')
    if fecha_desde > fecha_hasta:
        raise ValueError('La fecha desde no puede ser mayor que la fecha hasta.')

    dias = _generar_rango_dias(fecha_desde, fecha_hasta)
    if not dias:
        raise ValueError('Rango de fechas inválido.')

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
        asistencias = []
        if cursor.nextset() and cursor.description:
            asistencias = _cursor_rows(cursor)

    justificaciones = _cargar_justificaciones_rango(fecha_desde, fecha_hasta)
    filas = _construir_filas(_aplicar_vence_cuota(estudiantes), asistencias, dias, justificaciones)
    return _respuesta_informe(fecha_desde, fecha_hasta, dias, filas)


def informe_asistencias_orm(fecha_desde, fecha_hasta, buscar=None, id_plan=None, estado_usuario=None):
    from django.db.models import Q
    from .models import Usuario, Asistencia

    fecha_desde = (fecha_desde or '').strip()
    fecha_hasta = (fecha_hasta or '').strip()
    id_plan = (id_plan or '').strip() or None
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
                    SELECT t.IDUSUARIO, t.IDAULA, t.IDPLAN, t.IDTURNO,
                           t.FECHAINICIO, t.FECHA_VENCE
                    FROM (
                        SELECT
                            m.IDUSUARIO,
                            m.IDAULA, m.IDPLAN, m.IDTURNO,
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
                    SELECT TOP 1 m.IDAULA, m.IDPLAN, m.IDTURNO,
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
                    {isnull('pl.DIASASISTENCIA', '63')} AS DIASASISTENCIA,
                    UPPER({isnull('tut.NOMBRE', "''")}) AS TUTORA,
                    {isnull("au.NOMBRE", "''")} AS AULA,
                    {ciclo_expr} AS CICLO,
                    mem.FECHAINICIO AS FECHA_INICIO_MEM,
                    mem.FECHA_VENCE
                FROM USUARIO u
                {mem_join}
                LEFT JOIN AULA au ON au.IDAULA = mem.IDAULA
                LEFT JOIN USUARIO tut ON tut.IDUSUARIO = au.IDTUTORA
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
