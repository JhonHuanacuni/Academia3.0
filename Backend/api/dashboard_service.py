from datetime import date, datetime, timedelta

from django.db import connection
from django.utils import timezone

from .informes_service import _calcular_resumen, _hoy_db, informe_asistencias
from .usuario_crud_service import obtener_usuario
from .examen_estudiante_service import ranking_aula_ultimo_examen
from .sql_compat import fecha_sort_expr, is_mysql, isnull, ym_from_fechapago, len_expr


def _cursor_rows(cursor):
    columns = [col[0] for col in cursor.description] if cursor.description else []
    return [dict(zip(columns, row)) for row in cursor.fetchall()]


def _inicio_mes_db():
    hoy = timezone.localdate()
    return hoy.replace(day=1).strftime('%d%m%Y')


def _fecha_db(d):
    return d.strftime('%d%m%Y')


def _normalizar_rango(fecha_desde=None, fecha_hasta=None):
    hoy = timezone.localdate()

    def parsear(valor, predeterminado):
        valor = str(valor or '').strip()
        if not valor:
            return predeterminado
        for formato in ('%Y-%m-%d', '%d%m%Y'):
            try:
                return datetime.strptime(valor, formato).date()
            except ValueError:
                continue
        raise ValueError('Las fechas del dashboard no tienen un formato válido.')

    desde = parsear(fecha_desde, hoy.replace(day=1))
    hasta = parsear(fecha_hasta, hoy)
    if desde > hasta:
        raise ValueError('La fecha inicial no puede ser mayor que la fecha final.')
    return desde, hasta


def _rol_desde_tipo(id_tipo):
    mapping = {
        '1': 'estudiante',
        '2': 'docente',
        '3': 'administrador',
    }
    return mapping.get(str(id_tipo or '').strip(), 'estudiante')


def _es_admin(id_tipo):
    return str(id_tipo or '').strip() == '3'


def _es_estudiante(id_tipo):
    return str(id_tipo or '').strip() == '1'


def _es_docente(id_tipo):
    return str(id_tipo or '').strip() == '2'


def _conteo_usuarios(estado_usuario=None):
    estado = estado_usuario if estado_usuario in ('Activo', 'Retirado') else None
    filtro_estado = f" AND ESTADO = '{estado}'" if estado else ''
    with connection.cursor() as cursor:
        cursor.execute(
            f"""
            SELECT
                SUM(CASE WHEN IDTIPOUSUARIO = '1' AND ESTADO = 'Activo'{filtro_estado} THEN 1 ELSE 0 END) AS ESTUDIANTES_ACTIVOS,
                SUM(CASE WHEN IDTIPOUSUARIO = '1' AND ESTADO = 'Retirado'{filtro_estado} THEN 1 ELSE 0 END) AS ESTUDIANTES_RETIRADOS,
                SUM(CASE WHEN IDTIPOUSUARIO = '2' AND ESTADO = 'Activo' THEN 1 ELSE 0 END) AS DOCENTES_ACTIVOS,
                SUM(CASE WHEN IDTIPOUSUARIO = '3' AND ESTADO = 'Activo' THEN 1 ELSE 0 END) AS ADMINS_ACTIVOS
            FROM USUARIO
            """,
        )
        row = cursor.fetchone()
    if not row:
        return {}
    cols = ['ESTUDIANTES_ACTIVOS', 'ESTUDIANTES_RETIRADOS', 'DOCENTES_ACTIVOS', 'ADMINS_ACTIVOS']
    return dict(zip(cols, [int(v or 0) for v in row]))


def _stats_mensualidades(estado_usuario=None):
    hoy = _hoy_db()
    limite_prox = _fecha_db(timezone.localdate() + timedelta(days=3))
    estado = estado_usuario if estado_usuario in ('Activo', 'Retirado') else None
    filtro_estado = f"AND us.ESTADO = '{estado}'" if estado else ''
    from .cuota_service import sql_deuda_exigible_expr, tabla_cuotas_existe
    from .sql_compat import fecha_sort_expr

    with connection.cursor() as cursor:
        usa_cuotas = tabla_cuotas_existe(cursor)
        if usa_cuotas:
            deuda_expr = sql_deuda_exigible_expr('m')
            fs_ini = fecha_sort_expr('c.FECHAINICIO')
            fs_fin = fecha_sort_expr('c.FECHAFIN')
            if is_mysql():
                fs_hoy = (
                    f"CONCAT(SUBSTRING('{hoy}',5,4), SUBSTRING('{hoy}',3,2), "
                    f"SUBSTRING('{hoy}',1,2))"
                )
                fecha_vence_expr = f"""
                    IFNULL((
                        SELECT c.FECHAFIN
                        FROM MENSUALIDAD_CUOTA c
                        WHERE c.IDMENSUALIDAD = m.IDMENSUALIDAD
                          AND {fs_ini} <= {fs_hoy}
                          AND {fs_fin} >= {fs_hoy}
                        ORDER BY c.NUMERO DESC
                        LIMIT 1
                    ), m.FECHAFIN)
                """
            else:
                fs_hoy = (
                    f"SUBSTRING('{hoy}',5,4) + SUBSTRING('{hoy}',3,2) + "
                    f"SUBSTRING('{hoy}',1,2)"
                )
                fecha_vence_expr = f"""
                    ISNULL((
                        SELECT TOP 1 c.FECHAFIN
                        FROM MENSUALIDAD_CUOTA c
                        WHERE c.IDMENSUALIDAD = m.IDMENSUALIDAD
                          AND {fs_ini} <= {fs_hoy}
                          AND {fs_fin} >= {fs_hoy}
                        ORDER BY c.NUMERO DESC
                    ), m.FECHAFIN)
                """
        else:
            deuda_expr = (
                f"""CASE WHEN {isnull('m.MONTOTOTAL', '0')} - {isnull('pag.PAGADO', '0')} < 0 THEN 0
                         ELSE {isnull('m.MONTOTOTAL', '0')} - {isnull('pag.PAGADO', '0')} END"""
                if is_mysql()
                else """CASE WHEN ISNULL(m.MONTOTOTAL, 0) - ISNULL(pag.PAGADO, 0) < 0 THEN 0
                         ELSE ISNULL(m.MONTOTOTAL, 0) - ISNULL(pag.PAGADO, 0) END"""
            )
            fecha_vence_expr = 'm.FECHAFIN'

        if is_mysql():
            sql = f"""
                SELECT
                    SUM(CASE WHEN u.DEUDA > 0 THEN 1 ELSE 0 END) AS CON_DEUDA,
                    SUM(CASE WHEN u.DEUDA > 0 THEN u.DEUDA ELSE 0 END) AS DEUDA_TOTAL,
                    SUM(CASE WHEN u.DEUDA > 0 AND u.FECHAFIN IS NOT NULL AND u.FECHAFIN <> ''
                              AND u.FECHAFIN < %s THEN 1 ELSE 0 END) AS VENCIDAS,
                    SUM(CASE WHEN u.DEUDA > 0 AND u.FECHAFIN IS NOT NULL AND u.FECHAFIN <> ''
                              AND u.FECHAFIN >= %s AND u.FECHAFIN <= %s THEN 1 ELSE 0 END) AS VENCEN_PROXIMO
                FROM (
                    SELECT
                        m.IDUSUARIO,
                        ({fecha_vence_expr}) AS FECHAFIN,
                        ({deuda_expr}) AS DEUDA,
                        ROW_NUMBER() OVER (
                            PARTITION BY m.IDUSUARIO
                            ORDER BY m.FECHAREGISTRO DESC, m.IDMENSUALIDAD DESC
                        ) AS RN
                    FROM MENSUALIDAD m
                    INNER JOIN USUARIO us ON us.IDUSUARIO = m.IDUSUARIO
                        AND us.IDTIPOUSUARIO = '1'
                        {filtro_estado}
                    LEFT JOIN (
                        SELECT IDMENSUALIDAD, SUM(MONTO) AS PAGADO
                        FROM PAGOMENSUALIDAD
                        GROUP BY IDMENSUALIDAD
                    ) pag ON pag.IDMENSUALIDAD = m.IDMENSUALIDAD
                    WHERE m.ESTADO = 'Activo'
                ) u
                WHERE u.RN = 1
                """
        else:
            sql = f"""
                ;WITH Base AS (
                    SELECT
                        m.IDUSUARIO,
                        ({fecha_vence_expr}) AS FECHAFIN,
                        ({deuda_expr}) AS DEUDA,
                        ROW_NUMBER() OVER (
                            PARTITION BY m.IDUSUARIO
                            ORDER BY m.FECHAREGISTRO DESC, m.IDMENSUALIDAD DESC
                        ) AS RN
                    FROM MENSUALIDAD m
                    INNER JOIN USUARIO us ON us.IDUSUARIO = m.IDUSUARIO
                        AND us.IDTIPOUSUARIO = '1'
                        {filtro_estado}
                    OUTER APPLY (
                        SELECT SUM(p.MONTO) AS PAGADO FROM PAGOMENSUALIDAD p WHERE p.IDMENSUALIDAD = m.IDMENSUALIDAD
                    ) pag
                    WHERE m.ESTADO = 'Activo'
                ),
                Ultima AS (
                    SELECT IDUSUARIO, FECHAFIN, DEUDA
                    FROM Base
                    WHERE RN = 1
                )
                SELECT
                    SUM(CASE WHEN DEUDA > 0 THEN 1 ELSE 0 END) AS CON_DEUDA,
                    SUM(CASE WHEN DEUDA > 0 THEN DEUDA ELSE 0 END) AS DEUDA_TOTAL,
                    SUM(CASE WHEN DEUDA > 0 AND FECHAFIN IS NOT NULL AND FECHAFIN <> '' AND FECHAFIN < %s THEN 1 ELSE 0 END) AS VENCIDAS,
                    SUM(CASE WHEN DEUDA > 0 AND FECHAFIN IS NOT NULL AND FECHAFIN <> ''
                              AND FECHAFIN >= %s AND FECHAFIN <= %s THEN 1 ELSE 0 END) AS VENCEN_PROXIMO
                FROM Ultima
                """
        cursor.execute(sql, [hoy, hoy, limite_prox])
        row = cursor.fetchone()
    if not row:
        return {}
    return {
        'conDeuda': int(row[0] or 0),
        'deudaTotal': float(row[1] or 0),
        'vencidas': int(row[2] or 0),
        'vencenProximo': int(row[3] or 0),
    }


def _deuda_cuotas_periodo(fecha_desde, fecha_hasta, estado_usuario=None):
    from .cuota_service import tabla_cuotas_existe

    estado = estado_usuario if estado_usuario in ('Activo', 'Retirado') else None
    filtro_estado = f"AND u.ESTADO = '{estado}'" if estado else ''
    with connection.cursor() as cursor:
        if not tabla_cuotas_existe(cursor):
            return 0
        fs_inicio = fecha_sort_expr('c.FECHAINICIO')
        fs_fin = fecha_sort_expr('c.FECHAFIN')
        cursor.execute(
            f"""
            SELECT COALESCE(SUM(
                CASE WHEN q.SALDO < 0 THEN 0 ELSE q.SALDO END
            ), 0)
            FROM (
                SELECT
                    c.IDCUOTA,
                    COALESCE(c.MONTO, 0) - COALESCE(SUM(p.MONTO), 0) AS SALDO
                FROM MENSUALIDAD_CUOTA c
                INNER JOIN MENSUALIDAD m ON m.IDMENSUALIDAD = c.IDMENSUALIDAD
                INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
                    AND u.IDTIPOUSUARIO = '1'
                    {filtro_estado}
                LEFT JOIN PAGOMENSUALIDAD p ON p.IDCUOTA = c.IDCUOTA
                WHERE (m.ESTADO IS NULL OR m.ESTADO = 'Activo')
                  AND {fs_inicio} <= %s
                  AND {fs_fin} >= %s
                GROUP BY c.IDCUOTA, c.MONTO
            ) q
            """,
            [fecha_hasta.strftime('%Y%m%d'), fecha_desde.strftime('%Y%m%d')],
        )
        row = cursor.fetchone()
    return float(row[0] or 0) if row else 0


def _stats_pagos(fecha_desde, fecha_hasta, estado_usuario=None):
    desde_db = _fecha_db(fecha_desde)
    hasta_db = _fecha_db(fecha_hasta)
    fs_pago = fecha_sort_expr('p.FECHAPAGO')
    fs_desde = fecha_desde.strftime('%Y%m%d')
    fs_hasta = fecha_hasta.strftime('%Y%m%d')
    estado = estado_usuario if estado_usuario in ('Activo', 'Retirado') else None
    filtro_estado = f"AND u.ESTADO = '{estado}'" if estado else ''
    with connection.cursor() as cursor:
        cursor.execute(
            f"""
            SELECT
                COUNT(CASE WHEN {fs_pago} >= %s AND {fs_pago} <= %s THEN 1 END) AS CANTIDAD,
                {isnull("SUM(COALESCE(p.MONTO, 0) + COALESCE(p.MORA, 0))", '0')} AS TOTAL_HISTORICO,
                {isnull(f"SUM(CASE WHEN {fs_pago} >= %s AND {fs_pago} <= %s THEN COALESCE(p.MONTO, 0) + COALESCE(p.MORA, 0) ELSE 0 END)", '0')} AS TOTAL_PERIODO
            FROM PAGOMENSUALIDAD p
            INNER JOIN MENSUALIDAD m ON m.IDMENSUALIDAD = p.IDMENSUALIDAD
            INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
                AND u.IDTIPOUSUARIO = '1'
                {filtro_estado}
            """,
            [fs_desde, fs_hasta, fs_desde, fs_hasta],
        )
        row = cursor.fetchone()
    return {
        'cantidad': int(row[0] or 0) if row else 0,
        'totalHistorico': float(row[1] or 0) if row else 0,
        'periodo': float(row[2] or 0) if row else 0,
        'fechaDesde': desde_db,
        'fechaHasta': hasta_db,
    }


def _asistencias_hoy(estado_usuario=None):
    hoy = _hoy_db()
    estado = estado_usuario if estado_usuario in ('Activo', 'Retirado') else None
    filtro_estado = f"AND u.ESTADO = '{estado}'" if estado else ''
    stats = {'total': 0, 'presente': 0, 'tarde': 0, 'falta': 0}
    with connection.cursor() as cursor:
        cursor.execute(
            f"""
            SELECT {isnull('a.ESTADO', "''")}, COUNT(*)
            FROM ASISTENCIA a
            INNER JOIN USUARIO u ON u.IDUSUARIO = a.IDUSUARIO
                {filtro_estado}
            WHERE a.FECHAREGISTRO = %s
            GROUP BY a.ESTADO
            """,
            [hoy],
        )
        for estado, cnt in cursor.fetchall():
            n = int(cnt or 0)
            stats['total'] += n
            e = (estado or '').strip().lower()
            if e in ('presente', 'asistencia', 'p'):
                stats['presente'] += n
            elif e in ('tarde', 'tardanza', 't'):
                stats['tarde'] += n
            elif e in ('falta', 'f'):
                stats['falta'] += n
    return stats


def _resumen_asistencia(fecha_desde, fecha_hasta, estado_usuario=None):
    try:
        data = informe_asistencias(
            _fecha_db(fecha_desde),
            _fecha_db(fecha_hasta),
            estado_usuario=estado_usuario,
        )
        resumen = data.get('resumen') or _calcular_resumen(data.get('filas') or [])
        return {
            **resumen,
            'totalEstudiantes': data.get('total') or 0,
        }
    except Exception:
        return {
            'asistAcum': 0,
            'tardanzaAcum': 0,
            'faltasAcum': 0,
            'asistPct': 0,
            'tardanzaPct': 0,
            'faltasPct': 0,
            'totalMarcas': 0,
            'totalEstudiantes': 0,
        }


def _pagos_diarios_mes():
    """Pagos agrupados por día del mes en curso."""
    inicio_mes = _inicio_mes_db()
    hoy = _hoy_db()
    hoy_date = timezone.localdate()
    inicio_date = hoy_date.replace(day=1)

    with connection.cursor() as cursor:
        cursor.execute(
            """
            SELECT p.FECHAPAGO, SUM(p.MONTO) AS TOTAL
            FROM PAGOMENSUALIDAD p
            WHERE p.FECHAPAGO >= %s AND p.FECHAPAGO <= %s
            GROUP BY p.FECHAPAGO
            """,
            [inicio_mes, hoy],
        )
        por_fecha = {row[0]: float(row[1] or 0) for row in cursor.fetchall()}

    items = []
    actual = inicio_date
    while actual <= hoy_date:
        key = _fecha_db(actual)
        items.append({
            'key': key,
            'etiqueta': str(actual.day),
            'valor': por_fecha.get(key, 0),
        })
        actual += timedelta(days=1)
    return items


def _pagos_mensuales(fecha_desde, fecha_hasta, estado_usuario=None):
    """Pagos agrupados por cada mes incluido en el rango."""
    meses = []
    actual = fecha_desde.replace(day=1)
    ultimo = fecha_hasta.replace(day=1)
    while actual <= ultimo:
        meses.append(actual)
        actual = (actual.replace(day=28) + timedelta(days=4)).replace(day=1)

    labels = {
        1: 'Ene', 2: 'Feb', 3: 'Mar', 4: 'Abr', 5: 'May', 6: 'Jun',
        7: 'Jul', 8: 'Ago', 9: 'Sep', 10: 'Oct', 11: 'Nov', 12: 'Dic',
    }

    with connection.cursor() as cursor:
        ym_expr = ym_from_fechapago()
        len_col = len_expr('p.FECHAPAGO')
        fs_pago = fecha_sort_expr('p.FECHAPAGO')
        estado = estado_usuario if estado_usuario in ('Activo', 'Retirado') else None
        filtro_estado = f"AND u.ESTADO = '{estado}'" if estado else ''
        cursor.execute(
            f"""
            SELECT
                {ym_expr} AS YM,
                SUM(COALESCE(p.MONTO, 0) + COALESCE(p.MORA, 0)) AS TOTAL
            FROM PAGOMENSUALIDAD p
            INNER JOIN MENSUALIDAD m ON m.IDMENSUALIDAD = p.IDMENSUALIDAD
            INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
                AND u.IDTIPOUSUARIO = '1'
                {filtro_estado}
            WHERE {len_col} = 8
              AND {fs_pago} >= %s
              AND {fs_pago} <= %s
            GROUP BY {ym_expr}
            """,
            [fecha_desde.strftime('%Y%m%d'), fecha_hasta.strftime('%Y%m%d')],
        )
        por_mes = {row[0]: float(row[1] or 0) for row in cursor.fetchall()}

    items = []
    for d in meses:
        ym = d.strftime('%Y%m')
        items.append({
            'key': ym,
            'etiqueta': labels.get(d.month, str(d.month)),
            'valor': por_mes.get(ym, 0),
        })
    return items


def _chart_estudiantes(usuarios, finanzas=None, estado_usuario=None):
    activos = int(usuarios.get('ESTUDIANTES_ACTIVOS') or 0)
    retirados = int(usuarios.get('ESTUDIANTES_RETIRADOS') or 0)
    data = {
        'activos': activos,
        'retirados': retirados,
        'total': activos + retirados,
        'seleccionados': retirados if estado_usuario == 'Retirado' else activos + (retirados if not estado_usuario else 0),
        'etiquetaSeleccion': estado_usuario or 'Todos',
    }
    if finanzas is not None:
        con_deuda = int(finanzas.get('conDeuda') or 0)
        data['conDeuda'] = con_deuda
        data['alDia'] = max(data['seleccionados'] - con_deuda, 0)
    return data


def _chart_pagos(fecha_desde, fecha_hasta, estado_usuario=None):
    mensuales = _pagos_mensuales(fecha_desde, fecha_hasta, estado_usuario)
    return {
        'mensuales': mensuales,
        'totalPeriodo': sum(i['valor'] for i in mensuales),
    }


def obtener_dashboard(id_usuario, fecha_desde=None, fecha_hasta=None, estado_usuario='Activo'):
    if not id_usuario:
        raise ValueError('Indica el usuario de sesión.')

    usuario = obtener_usuario(id_usuario)
    if not usuario:
        raise ValueError('Usuario no encontrado.')

    id_tipo = str(usuario.get('IDTIPOUSUARIO') or '').strip()
    rol = _rol_desde_tipo(id_tipo)
    desde, hasta = _normalizar_rango(fecha_desde, fecha_hasta)
    estado = str(estado_usuario or '').strip().capitalize()
    if estado in ('Todos', ''):
        estado = None
    elif estado not in ('Activo', 'Retirado'):
        raise ValueError('El estado del estudiante no es válido.')

    base = {
        'rol': rol,
        'idtipousuario': id_tipo,
        'filtros': {
            'fechaDesde': desde.isoformat(),
            'fechaHasta': hasta.isoformat(),
            'estadoEstudiante': estado or 'Todos',
        },
        'asistenciasHoy': _asistencias_hoy(estado),
        'asistenciaMes': _resumen_asistencia(desde, hasta, estado),
    }

    if _es_admin(id_tipo):
        usuarios = _conteo_usuarios(estado)
        finanzas = _stats_mensualidades(estado)
        deuda_periodo = _deuda_cuotas_periodo(desde, hasta, estado)
        pagos = _stats_pagos(desde, hasta, estado)
        base.update({
            'kpis': {
                'estudiantesActivos': usuarios.get('ESTUDIANTES_ACTIVOS', 0),
                'deudaTotal': finanzas.get('deudaTotal', 0),
                'deudaPeriodo': deuda_periodo,
                'cobradoTotal': pagos.get('totalHistorico', 0),
                'pagosMes': pagos.get('periodo', 0),
                'mensualidadesConDeuda': finanzas.get('conDeuda', 0),
            },
            'graficos': {
                'estudiantes': _chart_estudiantes(usuarios, finanzas, estado),
                'pagos': _chart_pagos(desde, hasta, estado),
            },
            'acciones': [
                {'page': 'mensualidades', 'label': 'Mensualidades'},
                {'page': 'pagos', 'label': 'Pagos'},
                {'page': 'informes-asistencias', 'label': 'Informes'},
                {'page': 'asistencias-listado', 'label': 'Asistencias'},
            ],
        })
        return base

    if _es_docente(id_tipo):
        usuarios = _conteo_usuarios(estado)
        base.update({
            'kpis': {
                'estudiantesActivos': usuarios.get('ESTUDIANTES_ACTIVOS', 0),
                'asistenciasHoy': base['asistenciasHoy']['total'],
                'asistenciaPct': base['asistenciaMes'].get('asistPct', 0),
                'faltasMes': base['asistenciaMes'].get('faltasAcum', 0),
            },
            'graficos': {
                'estudiantes': _chart_estudiantes(usuarios),
            },
            'acciones': [
                {'page': 'asistencias-marcar', 'label': 'Marcar'},
                {'page': 'asistencias-listado', 'label': 'Listado'},
                {'page': 'asistencias-justificacion', 'label': 'Justificar'},
                {'page': 'informes-asistencias', 'label': 'Informes'},
            ],
        })
        return base

    if _es_estudiante(id_tipo):
        ranking = ranking_aula_ultimo_examen(id_usuario)
        base.update({
            'kpis': {},
            'acciones': [
                {'page': 'academico-examenes', 'label': 'Exámenes'},
                {'page': 'academico-biblioteca', 'label': 'Biblioteca'},
                {'page': 'academico-horario', 'label': 'Horario'},
            ],
            'ultimoExamen': ranking,
        })
        return base

    base.update({'kpis': {}, 'acciones': []})
    return base
