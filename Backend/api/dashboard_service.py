from datetime import timedelta

from django.db import connection
from django.utils import timezone

from .informes_service import _calcular_resumen, _hoy_db, informe_asistencias
from .usuario_crud_service import obtener_usuario
from .examen_estudiante_service import ranking_aula_ultimo_examen
from .sql_compat import is_mysql, isnull, ym_from_fechapago, len_expr


def _cursor_rows(cursor):
    columns = [col[0] for col in cursor.description] if cursor.description else []
    return [dict(zip(columns, row)) for row in cursor.fetchall()]


def _inicio_mes_db():
    hoy = timezone.localdate()
    return hoy.replace(day=1).strftime('%d%m%Y')


def _fecha_db(d):
    return d.strftime('%d%m%Y')


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


def _conteo_usuarios():
    with connection.cursor() as cursor:
        cursor.execute(
            """
            SELECT
                SUM(CASE WHEN IDTIPOUSUARIO = '1' AND ESTADO = 'Activo' THEN 1 ELSE 0 END) AS ESTUDIANTES_ACTIVOS,
                SUM(CASE WHEN IDTIPOUSUARIO = '1' AND ESTADO = 'Retirado' THEN 1 ELSE 0 END) AS ESTUDIANTES_RETIRADOS,
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


def _stats_mensualidades():
    hoy = _hoy_db()
    limite_prox = _fecha_db(timezone.localdate() + timedelta(days=3))
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
                        AND us.ESTADO = 'Activo'
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
                        AND us.ESTADO = 'Activo'
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


def _stats_pagos():
    hoy = _hoy_db()
    inicio_mes = _inicio_mes_db()
    with connection.cursor() as cursor:
        cursor.execute(
            f"""
            SELECT
                COUNT(CASE WHEN p.FECHAPAGO = %s THEN 1 END) AS CANT_HOY,
                {isnull("SUM(CASE WHEN p.FECHAPAGO = %s THEN p.MONTO ELSE 0 END)", '0')} AS HOY,
                {isnull("SUM(CASE WHEN p.FECHAPAGO >= %s AND p.FECHAPAGO <= %s THEN p.MONTO ELSE 0 END)", '0')} AS MES
            FROM PAGOMENSUALIDAD p
            """,
            [hoy, hoy, inicio_mes, hoy],
        )
        row = cursor.fetchone()
    return {
        'cantHoy': int(row[0] or 0) if row else 0,
        'hoy': float(row[1] or 0) if row else 0,
        'mes': float(row[2] or 0) if row else 0,
    }


def _asistencias_hoy():
    hoy = _hoy_db()
    stats = {'total': 0, 'presente': 0, 'tarde': 0, 'falta': 0}
    with connection.cursor() as cursor:
        cursor.execute(
            f"""
            SELECT {isnull('ESTADO', "''")}, COUNT(*)
            FROM ASISTENCIA
            WHERE FECHAREGISTRO = %s
            GROUP BY ESTADO
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


def _resumen_asistencia_mes():
    try:
        data = informe_asistencias(_inicio_mes_db(), _hoy_db(), estado_usuario='Activo')
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


def _pagos_mensuales(cant_meses=6):
    """Pagos agrupados por mes (últimos N meses)."""
    hoy = timezone.localdate().replace(day=1)
    meses = []
    for i in range(cant_meses - 1, -1, -1):
        d = hoy
        for _ in range(i):
            d = (d.replace(day=1) - timedelta(days=1)).replace(day=1)
        meses.append(d)

    labels = {
        1: 'Ene', 2: 'Feb', 3: 'Mar', 4: 'Abr', 5: 'May', 6: 'Jun',
        7: 'Jul', 8: 'Ago', 9: 'Sep', 10: 'Oct', 11: 'Nov', 12: 'Dic',
    }

    with connection.cursor() as cursor:
        ym_expr = ym_from_fechapago()
        len_col = len_expr('p.FECHAPAGO')
        cursor.execute(
            f"""
            SELECT
                {ym_expr} AS YM,
                SUM(p.MONTO) AS TOTAL
            FROM PAGOMENSUALIDAD p
            WHERE {len_col} = 8
            GROUP BY {ym_expr}
            """,
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


def _chart_estudiantes(usuarios, finanzas=None):
    activos = int(usuarios.get('ESTUDIANTES_ACTIVOS') or 0)
    retirados = int(usuarios.get('ESTUDIANTES_RETIRADOS') or 0)
    data = {
        'activos': activos,
        'retirados': retirados,
        'total': activos + retirados,
    }
    if finanzas is not None:
        con_deuda = int(finanzas.get('conDeuda') or 0)
        data['conDeuda'] = con_deuda
        data['alDia'] = max(activos - con_deuda, 0)
    return data


def _chart_pagos():
    mensuales = _pagos_mensuales(6)
    return {
        'mensuales': mensuales,
        'totalPeriodo': sum(i['valor'] for i in mensuales),
    }


def obtener_dashboard(id_usuario):
    if not id_usuario:
        raise ValueError('Indica el usuario de sesión.')

    usuario = obtener_usuario(id_usuario)
    if not usuario:
        raise ValueError('Usuario no encontrado.')

    id_tipo = str(usuario.get('IDTIPOUSUARIO') or '').strip()
    rol = _rol_desde_tipo(id_tipo)

    base = {
        'rol': rol,
        'idtipousuario': id_tipo,
        'asistenciasHoy': _asistencias_hoy(),
        'asistenciaMes': _resumen_asistencia_mes(),
    }

    if _es_admin(id_tipo):
        usuarios = _conteo_usuarios()
        finanzas = _stats_mensualidades()
        pagos = _stats_pagos()
        base.update({
            'kpis': {
                'estudiantesActivos': usuarios.get('ESTUDIANTES_ACTIVOS', 0),
                'deudaTotal': finanzas.get('deudaTotal', 0),
                'pagosMes': pagos.get('mes', 0),
                'mensualidadesConDeuda': finanzas.get('conDeuda', 0),
            },
            'graficos': {
                'estudiantes': _chart_estudiantes(usuarios, finanzas),
                'pagos': _chart_pagos(),
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
        usuarios = _conteo_usuarios()
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
