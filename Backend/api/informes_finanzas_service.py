"""Informes de Aulas, Caja e Seguimiento (conversión de interesados)."""

from calendar import monthrange
from collections import defaultdict
from datetime import date

from django.db import connection
from django.utils import timezone

from .informe_consulta_crud_service import (
    CANALES,
    RESULTADOS,
    _solo_digitos,
    telefonos_alumnos_mes,
)
from .sql_compat import concat_nombre_usuario, fecha_sort_expr, is_mysql, isnull, plan_table


MESES_ES = {
    1: 'Enero', 2: 'Febrero', 3: 'Marzo', 4: 'Abril',
    5: 'Mayo', 6: 'Junio', 7: 'Julio', 8: 'Agosto',
    9: 'Septiembre', 10: 'Octubre', 11: 'Noviembre', 12: 'Diciembre',
}


def _cursor_rows(cursor):
    cols = [c[0] for c in cursor.description] if cursor.description else []
    return [dict(zip(cols, r)) for r in cursor.fetchall()]


def _parse_anio_mes(anio, mes, permitir_anio_completo=False):
    hoy = timezone.localdate()
    try:
        anio_i = int(anio) if anio not in (None, '') else hoy.year
    except (TypeError, ValueError):
        raise ValueError('Año inválido')
    if anio_i < 2000 or anio_i > 2100:
        raise ValueError('Año fuera de rango')

    mes_raw = '' if mes is None else str(mes).strip().lower()
    if permitir_anio_completo and mes_raw in ('', '0', 'all', 'todos', 'anio', 'año'):
        return anio_i, 0, date(anio_i, 1, 1), date(anio_i, 12, 31)

    try:
        mes_i = int(mes) if mes not in (None, '') else hoy.month
    except (TypeError, ValueError):
        raise ValueError('Mes inválido')
    if mes_i < 1 or mes_i > 12:
        raise ValueError('El mes debe estar entre 1 y 12')
    ultimo = monthrange(anio_i, mes_i)[1]
    return anio_i, mes_i, date(anio_i, mes_i, 1), date(anio_i, mes_i, ultimo)


def _ymd(d: date) -> str:
    return d.strftime('%Y%m%d')


def _fmt_monto(n):
    return round(float(n or 0), 2)


def _fmt_fecha_vista(fecha_db):
    s = str(fecha_db or '').strip()
    if len(s) == 8 and s.isdigit():
        return f'{s[0:2]}/{s[2:4]}/{s[4:8]}'
    return s or '—'


# ─── Aulas ───────────────────────────────────────────────────────────────────


def informe_aulas(anio=None, mes=None, id_aula=None):
    """Ocupación y cobranza por aula (sin utilidad / pago docente)."""
    anio_i, mes_i, desde, hasta = _parse_anio_mes(anio, mes)
    id_aula = (id_aula or '').strip() or None
    fs_ini = fecha_sort_expr('m.FECHAINICIO')
    fs_fin = fecha_sort_expr('m.FECHAFIN')
    plan_tbl = plan_table()
    nombre = concat_nombre_usuario('u')

    params = [_ymd(hasta), _ymd(desde)]
    filtro_aula = ''
    if id_aula:
        filtro_aula = 'AND a.IDAULA = %s'
        params.append(id_aula)

    with connection.cursor() as cursor:
        cursor.execute(
            f"""
            SELECT
                a.IDAULA,
                a.NOMBRE AS AULA,
                COALESCE(a.CAPACIDAD, 0) AS AFORO,
                m.IDMENSUALIDAD,
                m.IDUSUARIO,
                m.IDPLAN,
                {isnull('pl.NOMBRE', "''")} AS PLAN_NOMBRE,
                COALESCE(m.MONTOTOTAL, 0) AS MONTOTOTAL,
                COALESCE(pag.PAGADO, 0) AS PAGADO,
                {nombre} AS ESTUDIANTE,
                {isnull('u.ESTADO', "'Activo'")} AS ESTADO_ALUMNO
            FROM AULA a
            LEFT JOIN MENSUALIDAD m
                ON m.IDAULA = a.IDAULA
               AND (m.ESTADO IS NULL OR m.ESTADO = 'Activo')
               AND ({fs_ini} = '' OR {fs_ini} IS NULL OR {fs_ini} <= %s)
               AND ({fs_fin} = '' OR {fs_fin} IS NULL OR {fs_fin} >= %s)
            LEFT JOIN USUARIO u
                ON u.IDUSUARIO = m.IDUSUARIO
               AND u.IDTIPOUSUARIO = '1'
               AND UPPER({isnull('u.ESTADO', "'Activo'")}) = 'ACTIVO'
            LEFT JOIN {plan_tbl} pl ON pl.IDPLAN = m.IDPLAN
            LEFT JOIN (
                SELECT IDMENSUALIDAD, SUM(COALESCE(MONTO, 0)) AS PAGADO
                FROM PAGOMENSUALIDAD
                GROUP BY IDMENSUALIDAD
            ) pag ON pag.IDMENSUALIDAD = m.IDMENSUALIDAD
            WHERE (a.ACTIVO = 1 OR a.ACTIVO IS NULL)
              {filtro_aula}
            ORDER BY a.NOMBRE, pl.NOMBRE
            """,
            params,
        )
        rows = _cursor_rows(cursor)

    por_aula = {}
    ciclos_por_aula = defaultdict(lambda: defaultdict(int))

    for r in rows:
        aid = r['IDAULA']
        if aid not in por_aula:
            por_aula[aid] = {
                'idAula': aid,
                'aula': r['AULA'] or aid,
                'aforo': int(r['AFORO'] or 0),
                'alumnos': 0,
                'cancelaron': 0,
                'deben': 0,
                'ingresoMes': 0.0,
                'cobrado': 0.0,
                'porCobrar': 0.0,
                '_vistos': set(),
            }
        item = por_aula[aid]
        uid = r.get('IDUSUARIO')
        mid = r.get('IDMENSUALIDAD')
        if not uid or not mid or uid in item['_vistos']:
            continue
        # Solo contar si el join a usuario activo trajo fila
        if not r.get('ESTADO_ALUMNO'):
            continue
        item['_vistos'].add(uid)

        monto = _fmt_monto(r.get('MONTOTOTAL'))
        pagado = _fmt_monto(r.get('PAGADO'))
        cancelado = pagado >= monto and monto > 0

        item['alumnos'] += 1
        item['ingresoMes'] += monto
        if cancelado:
            item['cancelaron'] += 1
            item['cobrado'] += monto
        else:
            item['deben'] += 1
            item['cobrado'] += min(pagado, monto)

        plan = (r.get('PLAN_NOMBRE') or 'Sin plan').strip() or 'Sin plan'
        ciclos_por_aula[aid][plan] += 1

    filas = []
    for aid, item in sorted(por_aula.items(), key=lambda x: (x[1]['aula'] or '')):
        aforo = item['aforo']
        alumnos = item['alumnos']
        ocupacion = round((alumnos / aforo) * 100, 1) if aforo > 0 else None
        cobrado = _fmt_monto(item['cobrado'])
        ingreso = _fmt_monto(item['ingresoMes'])
        por_cobrar = _fmt_monto(max(ingreso - cobrado, 0))
        filas.append({
            'idAula': aid,
            'aula': item['aula'],
            'aforo': aforo,
            'alumnos': alumnos,
            'ocupacion': ocupacion,
            'cancelaron': item['cancelaron'],
            'deben': item['deben'],
            'ingresoMes': ingreso,
            'cobrado': cobrado,
            'porCobrar': por_cobrar,
        })

    # Totales (suma de filas; ocupación promedio ponderado)
    tot_alumnos = sum(f['alumnos'] for f in filas)
    tot_aforo = sum(f['aforo'] for f in filas)
    totales = {
        'aforo': tot_aforo,
        'alumnos': tot_alumnos,
        'ocupacion': round((tot_alumnos / tot_aforo) * 100, 1) if tot_aforo else None,
        'cancelaron': sum(f['cancelaron'] for f in filas),
        'deben': sum(f['deben'] for f in filas),
        'ingresoMes': _fmt_monto(sum(f['ingresoMes'] for f in filas)),
        'cobrado': _fmt_monto(sum(f['cobrado'] for f in filas)),
        'porCobrar': _fmt_monto(sum(f['porCobrar'] for f in filas)),
    }

    # Matriz ciclos × aula
    planes = sorted({p for mapa in ciclos_por_aula.values() for p in mapa})
    matriz = []
    for aid, item in sorted(por_aula.items(), key=lambda x: (x[1]['aula'] or '')):
        fila_m = {'idAula': aid, 'aula': item['aula'], 'porPlan': {}}
        for p in planes:
            fila_m['porPlan'][p] = ciclos_por_aula[aid].get(p, 0)
        matriz.append(fila_m)

    resumen = {
        'periodo': f'{MESES_ES[mes_i]} {anio_i}',
        'anio': anio_i,
        'mes': mes_i,
        'totalAulas': len(filas),
        'alumnos': totales['alumnos'],
        'ocupacion': totales['ocupacion'],
        'ingresoMes': totales['ingresoMes'],
        'cobrado': totales['cobrado'],
        'porCobrar': totales['porCobrar'],
        'pctCobrado': (
            round((totales['cobrado'] / totales['ingresoMes']) * 100, 1)
            if totales['ingresoMes'] else 0
        ),
    }

    return {
        'anio': anio_i,
        'mes': mes_i,
        'periodo': resumen['periodo'],
        'filas': filas,
        'totales': totales,
        'matrizCiclos': {'planes': planes, 'filas': matriz},
        'resumen': resumen,
        'total': len(filas),
    }


# ─── Caja (solo ingresos) ────────────────────────────────────────────────────


def informe_caja(anio=None, mes=None):
    """Ingresos del mes (o todo el año) desde PAGOMENSUALIDAD + PAGOEXTRAORDINARIO."""
    anio_i, mes_i, desde, hasta = _parse_anio_mes(anio, mes, permitir_anio_completo=True)
    fs_pago = fecha_sort_expr('p.FECHAPAGO')
    nombre = concat_nombre_usuario('u')
    plan_tbl = plan_table()
    ymd_desde, ymd_hasta = _ymd(desde), _ymd(hasta)

    with connection.cursor() as cursor:
        cursor.execute(
            f"""
            SELECT
                p.IDPAGOMENSUALIDAD AS ID,
                'mensualidad' AS TIPO,
                p.FECHAPAGO,
                p.IDPAGOMENSUALIDAD AS RECIBO,
                {nombre} AS NOMBRE,
                {isnull('pl.NOMBRE', "''")} AS CICLO,
                {isnull('mp.TITULO', "'Sin medio'")} AS MEDIO,
                COALESCE(p.MONTO, 0) + COALESCE(p.MORA, 0) AS MONTO
            FROM PAGOMENSUALIDAD p
            INNER JOIN MENSUALIDAD m ON m.IDMENSUALIDAD = p.IDMENSUALIDAD
            INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO AND u.IDTIPOUSUARIO = '1'
            LEFT JOIN {plan_tbl} pl ON pl.IDPLAN = m.IDPLAN
            LEFT JOIN METODO_PAGO mp ON mp.IDMETODOPAGO = p.IDMETODOPAGO
            WHERE {fs_pago} >= %s AND {fs_pago} <= %s

            UNION ALL

            SELECT
                p.IDPAGOEXTRA AS ID,
                'extraordinario' AS TIPO,
                p.FECHAPAGO,
                p.IDPAGOEXTRA AS RECIBO,
                {nombre} AS NOMBRE,
                {isnull('c.NOMBRE', "'Pago extraordinario'")} AS CICLO,
                'Extraordinario' AS MEDIO,
                COALESCE(p.MONTO, 0) AS MONTO
            FROM PAGOEXTRAORDINARIO p
            INNER JOIN USUARIO u ON u.IDUSUARIO = p.IDUSUARIO AND u.IDTIPOUSUARIO = '1'
            LEFT JOIN CONCEPTOPAGOEXTRA c ON c.IDCONCEPTO = p.IDCONCEPTO
            WHERE {fecha_sort_expr('p.FECHAPAGO')} >= %s
              AND {fecha_sort_expr('p.FECHAPAGO')} <= %s
            """,
            [ymd_desde, ymd_hasta, ymd_desde, ymd_hasta],
        )
        raw = _cursor_rows(cursor)

    # Reordenar cronológicamente (FECHAPAGO es DDMMYYYY)
    raw.sort(key=lambda r: (
        (str(r.get('FECHAPAGO') or '')[4:8] + str(r.get('FECHAPAGO') or '')[2:4] + str(r.get('FECHAPAGO') or '')[0:2])
        if r.get('FECHAPAGO') and len(str(r.get('FECHAPAGO'))) == 8
        else '',
        str(r.get('NOMBRE') or ''),
    ))

    filas = []
    por_medio = defaultdict(lambda: {'monto': 0.0, 'cantidad': 0})
    por_fecha = defaultdict(lambda: {'monto': 0.0, 'cantidad': 0, 'items': []})
    por_dia_chart = defaultdict(float)
    total_ingresos = 0.0

    for r in raw:
        monto = _fmt_monto(r.get('MONTO'))
        medio = (r.get('MEDIO') or 'Sin medio').strip() or 'Sin medio'
        fecha_vista = _fmt_fecha_vista(r.get('FECHAPAGO'))
        item = {
            'id': r.get('ID'),
            'tipo': r.get('TIPO'),
            'fecha': fecha_vista,
            'fechaDb': r.get('FECHAPAGO'),
            'recibo': r.get('RECIBO') or '',
            'nombre': r.get('NOMBRE') or '',
            'ciclo': r.get('CICLO') or '',
            'medio': medio,
            'monto': monto,
        }
        filas.append(item)
        total_ingresos += monto
        por_medio[medio]['monto'] += monto
        por_medio[medio]['cantidad'] += 1
        por_fecha[fecha_vista]['monto'] += monto
        por_fecha[fecha_vista]['cantidad'] += 1
        por_fecha[fecha_vista]['items'].append(item)
        if r.get('FECHAPAGO') and len(str(r.get('FECHAPAGO'))) == 8:
            fp = str(r.get('FECHAPAGO'))
            if mes_i == 0:
                mes_num = int(fp[2:4])
                por_dia_chart[mes_num] += monto
            else:
                dia = int(fp[0:2])
                por_dia_chart[dia] += monto

    medios = [
        {
            'etiqueta': k,
            'monto': _fmt_monto(v['monto']),
            'cantidad': v['cantidad'],
            'pct': round((v['monto'] / total_ingresos) * 100, 1) if total_ingresos else 0,
        }
        for k, v in sorted(por_medio.items(), key=lambda x: -x[1]['monto'])
    ]

    gruposFecha = []
    for fecha, g in sorted(
        por_fecha.items(),
        key=lambda x: (
            x[1]['items'][0]['fechaDb'][4:8] + x[1]['items'][0]['fechaDb'][2:4] + x[1]['items'][0]['fechaDb'][0:2]
            if x[1]['items'] and x[1]['items'][0].get('fechaDb') and len(str(x[1]['items'][0]['fechaDb'])) == 8
            else ''
        ),
    ):
        gruposFecha.append({
            'fecha': fecha,
            'monto': _fmt_monto(g['monto']),
            'cantidad': g['cantidad'],
            'items': g['items'],
        })

    if mes_i == 0:
        chartDiario = [
            {
                'etiqueta': MESES_ES[m][:3],
                'valor': _fmt_monto(por_dia_chart.get(m, 0)),
            }
            for m in range(1, 13)
            if por_dia_chart.get(m, 0) > 0
        ]
        dias_periodo = max((hasta - desde).days + 1, 1)
        periodo_label = f'Año {anio_i}'
        chart_titulo = 'Ingresos por mes'
    else:
        # Solo días con movimiento: evita barras vacías y scroll inútil
        chartDiario = [
            {'etiqueta': str(d), 'valor': _fmt_monto(v)}
            for d, v in sorted(por_dia_chart.items())
            if v > 0
        ]
        dias_periodo = max(hasta.day, 1)
        periodo_label = f'{MESES_ES[mes_i]} {anio_i}'
        chart_titulo = 'Ingresos por día'

    resumen = {
        'periodo': periodo_label,
        'anio': anio_i,
        'mes': mes_i,
        'chartTitulo': chart_titulo,
        'totalIngresos': _fmt_monto(total_ingresos),
        'cantidadPagos': len(filas),
        'cantidadMedios': len(medios),
        'promedioDiario': _fmt_monto(total_ingresos / dias_periodo) if dias_periodo else 0,
        'porMedio': medios,
    }

    return {
        'anio': anio_i,
        'mes': mes_i,
        'periodo': resumen['periodo'],
        'filas': filas,
        'gruposFecha': gruposFecha,
        'medios': medios,
        'chartDiario': chartDiario,
        'resumen': resumen,
        'total': len(filas),
    }


# ─── Seguimiento / conversión ────────────────────────────────────────────────


def informe_seguimiento(anio=None, mes=None):
    """KPIs y listado del seguimiento de interesados (INFORME_CONSULTA)."""
    anio_i, mes_i, desde, hasta = _parse_anio_mes(anio, mes)
    fs = fecha_sort_expr('i.FECHA')
    ymd_desde, ymd_hasta = _ymd(desde), _ymd(hasta)

    with connection.cursor() as cursor:
        cursor.execute(
            f"""
            SELECT
                i.IDINFORMECONSULTA, i.FECHA, i.NOMBRE, i.TELEFONO,
                i.CICLO_INTERES, i.CANAL, i.RESULTADO, i.SE_ENTERO,
                i.OBSERVACION, i.MARCA_NO_APLICA, i.MARCA_INTERESADO
            FROM INFORME_CONSULTA i
            WHERE (i.ESTADO IS NULL OR i.ESTADO = 'Activo')
              AND {fs} >= %s AND {fs} <= %s
            ORDER BY {fs} DESC, i.IDINFORMECONSULTA DESC
            """,
            [ymd_desde, ymd_hasta],
        )
        rows = _cursor_rows(cursor)

    try:
        tels_alumnos = telefonos_alumnos_mes(anio_i, mes_i)
    except Exception:
        tels_alumnos = set()

    total = len(rows)
    no_aplica = sum(1 for r in rows if int(r.get('MARCA_NO_APLICA') or 0) == 1)
    interesados = sum(1 for r in rows if int(r.get('MARCA_INTERESADO') or 0) == 1)
    seguimiento = sum(1 for r in rows if (r.get('RESULTADO') or '') == 'seguimiento')
    matriculados = sum(1 for r in rows if (r.get('RESULTADO') or '') == 'matriculado')
    conversion = round((matriculados / interesados) * 100, 1) if interesados else None

    por_resultado = defaultdict(int)
    por_canal = defaultdict(int)
    por_ciclo = defaultdict(int)
    por_dia = defaultdict(int)

    filas = []
    for r in rows:
        resultado = r.get('RESULTADO') or 'interesado'
        canal = r.get('CANAL') or 'presencial'
        tel = _solo_digitos(r.get('TELEFONO'))
        en_alumnos = bool(tel and tel in tels_alumnos)
        por_resultado[resultado] += 1
        por_canal[canal] += 1
        ciclo = (r.get('CICLO_INTERES') or '').strip() or 'Sin ciclo'
        por_ciclo[ciclo] += 1
        if r.get('FECHA') and len(str(r.get('FECHA'))) == 8:
            por_dia[int(str(r.get('FECHA'))[0:2])] += 1

        filas.append({
            'id': r.get('IDINFORMECONSULTA'),
            'fecha': _fmt_fecha_vista(r.get('FECHA')),
            'nombre': r.get('NOMBRE') or '',
            'telefono': r.get('TELEFONO') or '',
            'ciclo': r.get('CICLO_INTERES') or '',
            'canal': CANALES.get(canal, canal),
            'resultado': RESULTADOS.get(resultado, resultado),
            'resultadoKey': resultado,
            'seEntero': r.get('SE_ENTERO') or '',
            'observacion': r.get('OBSERVACION') or '',
            'enAlumnos': en_alumnos,
        })

    def _dist(mapa, labels=None):
        items = []
        for k, cant in sorted(mapa.items(), key=lambda x: -x[1]):
            items.append({
                'etiqueta': (labels or {}).get(k, k),
                'cantidad': cant,
                'pct': round((cant / total) * 100, 1) if total else 0,
            })
        return items

    resumen = {
        'periodo': f'{MESES_ES[mes_i]} {anio_i}',
        'anio': anio_i,
        'mes': mes_i,
        'total': total,
        'noAplica': no_aplica,
        'noAplicaPct': round((no_aplica / total) * 100, 1) if total else 0,
        'interesados': interesados,
        'interesadosPct': round((interesados / total) * 100, 1) if total else 0,
        'seguimiento': seguimiento,
        'matriculados': matriculados,
        'matriculadosPct': round((matriculados / total) * 100, 1) if total else 0,
        'conversion': conversion,
        'porResultado': _dist(por_resultado, RESULTADOS),
        'porCanal': _dist(por_canal, CANALES),
        'porCiclo': _dist(por_ciclo),
        'chartDiario': [
            {'etiqueta': str(d), 'valor': por_dia.get(d, 0)}
            for d in range(1, hasta.day + 1)
        ],
    }

    return {
        'anio': anio_i,
        'mes': mes_i,
        'periodo': resumen['periodo'],
        'filas': filas,
        'resumen': resumen,
        'total': total,
    }
