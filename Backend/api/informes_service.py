from datetime import datetime, timedelta

from django.db import connection
from django.utils import timezone

DIAS_ES = ('lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom')


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
    return datetime(int(norm[4:8]), int(norm[2:4]), int(norm[0:2]))


def _date_a_fecha_db(d):
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


def _estado_vencimiento_membresia(fecha_fin_db):
    """Retorna 'vencida', 'proxima' o '' según la fecha fin de membresía."""
    fin = _fecha_db_a_date(fecha_fin_db)
    if not fin:
        return ''
    hoy = timezone.localdate()
    dias = (fin.date() - hoy).days
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
    hoy_db = _hoy_db()
    dias = []
    actual = inicio
    while actual <= fin:
        fecha_db = _date_a_fecha_db(actual)
        dias.append({
            'fecha': fecha_db,
            'etiqueta': _etiqueta_dia(fecha_db),
            'esDomingo': actual.weekday() == 6,
            'esFuturo': fecha_db > hoy_db,
        })
        actual += timedelta(days=1)
    return dias


def _estado_a_codigo(estado, justificado=False):
    e = (estado or '').strip().lower()
    if 'tarde' in e or e == 't':
        return 'T'
    if 'retiro' in e or e == 'r':
        return 'R'
    if 'falta' in e or 'ausente' in e or e == 'f':
        return 'F'
    if justificado:
        return 'R'
    if 'presente' in e or e == 'a' or e:
        return 'A'
    return ''


def _dia_cuenta_para_falta(fecha_db, fecha_inicio_db, fecha_fin_db):
    """True si el día está dentro del período de membresía para evaluar faltas."""
    inicio = _normalizar_fecha_db(fecha_inicio_db)
    if not inicio:
        return False
    fecha = _normalizar_fecha_db(fecha_db)
    if not fecha or fecha < inicio:
        return False
    fin = _normalizar_fecha_db(fecha_fin_db)
    if fin and fecha > fin:
        return False
    return True


def _construir_filas(estudiantes, asistencias, dias):
    marcas_por_usuario = {}
    for row in asistencias:
        uid = row.get('IDUSUARIO')
        fecha = row.get('FECHAREGISTRO')
        if not uid or not fecha:
            continue
        codigo = _estado_a_codigo(row.get('ESTADO'), row.get('JUSTIFICADO'))
        marcas_por_usuario.setdefault(uid, {})[fecha] = codigo

    filas = []
    for idx, est in enumerate(estudiantes, start=1):
        uid = est['IDUSUARIO']
        marcas_usuario = marcas_por_usuario.get(uid, {})
        marcas = {}
        total_asist = total_tard = total_faltas = 0

        fecha_inicio_mem = est.get('FECHA_INICIO_MEM')
        fecha_fin_mem = est.get('FECHA_VENCE') or est.get('FECHA_FIN_MEM')

        for dia in dias:
            fecha = dia['fecha']
            codigo = marcas_usuario.get(fecha, '')
            # Falta solo en días lectivos transcurridos y dentro del período de membresía
            if not codigo and not dia['esDomingo'] and not dia.get('esFuturo'):
                if _dia_cuenta_para_falta(fecha, fecha_inicio_mem, fecha_fin_mem):
                    codigo = 'F'
            marcas[fecha] = codigo
            if codigo == 'A':
                total_asist += 1
            elif codigo == 'T':
                total_tard += 1
            elif codigo == 'F':
                total_faltas += 1

        fecha_vence = est.get('FECHA_VENCE')
        estado_vence = _estado_vencimiento_membresia(fecha_vence)
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
            'totalAsist': total_asist,
            'totalTard': total_tard,
            'totalFaltas': total_faltas,
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


def _normalizar_estado_usuario(estado):
    e = (estado or '').strip()
    if not e or e.lower() in ('todos', 'all'):
        return None
    if e.lower() == 'activo':
        return 'Activo'
    if e.lower() == 'inactivo':
        return 'Inactivo'
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
        cursor.execute(
            """
            EXEC dbo.usp_asistencia_informe
                @FechaDesde=%s, @FechaHasta=%s, @Buscar=%s, @IDPlan=%s, @EstadoUsuario=%s;
            """,
            [fecha_desde, fecha_hasta, buscar, id_plan, estado_usuario],
        )
        estudiantes = _cursor_rows(cursor)
        asistencias = []
        if cursor.nextset() and cursor.description:
            asistencias = _cursor_rows(cursor)

    filas = _construir_filas(estudiantes, asistencias, dias)
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

    filas = _construir_filas(estudiantes, asistencias, dias)
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
            estado_filter = ' AND UPPER(ISNULL(u.ESTADO, ''Activo'')) = UPPER(%s)'
            params.append(estado_usuario)

        with connection.cursor() as cursor:
            cursor.execute(
                f"""
                SELECT
                    u.IDUSUARIO,
                    mem.IDPLAN,
                    UPPER(ISNULL(tut.NOMBRE, '')) AS TUTORA,
                    ISNULL(au.NOMBRE, '') AS AULA,
                    UPPER(LTRIM(RTRIM(
                        ISNULL(pl.NOMBRE, '') +
                        CASE WHEN tu.DESCRIPCION IS NOT NULL AND tu.DESCRIPCION <> ''
                             THEN ' ' + tu.DESCRIPCION ELSE '' END
                    ))) AS CICLO,
                    mem.FECHAINICIO AS FECHA_INICIO_MEM,
                    mem.FECHA_VENCE
                FROM USUARIO u
                OUTER APPLY (
                    SELECT TOP 1 m.IDAULA, m.IDPLAN, m.IDTURNO,
                           m.FECHAINICIO, m.FECHAFIN AS FECHA_VENCE
                    FROM MEMBRESIA m
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
                LEFT JOIN AULA au ON au.IDAULA = mem.IDAULA
                LEFT JOIN USUARIO tut ON tut.IDUSUARIO = au.IDTUTORA
                LEFT JOIN [PLAN] pl ON pl.IDPLAN = mem.IDPLAN
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
