"""Cuotas mensuales de una matrícula (MENSUALIDAD_CUOTA)."""

from __future__ import annotations

from calendar import monthrange
from datetime import date, timedelta

from django.db import connection
from django.utils import timezone

from . import sp_runner as sp
from .sql_compat import fecha_sort_expr, plan_table


def _db_to_date(s: str | None) -> date | None:
    s = str(s or '').strip()
    if len(s) != 8:
        return None
    try:
        return date(int(s[4:8]), int(s[2:4]), int(s[0:2]))
    except ValueError:
        return None


def _date_to_db(d: date) -> str:
    return d.strftime('%d%m%Y')


def _hoy_db() -> str:
    return timezone.localdate().strftime('%d%m%Y')


def generar_periodos_cuota(fecha_inicio_db: str, fecha_fin_db: str) -> list[tuple[str, str]]:
    """
    Genera periodos 08/03–07/04, 08/04–07/05, … limitados a fecha_fin del contrato.
    El día de cobro es el día de FECHAINICIO; el fin de cada cuota es el día anterior
    al siguiente cobro.
    """
    inicio = _db_to_date(fecha_inicio_db)
    fin_contrato = _db_to_date(fecha_fin_db)
    if not inicio or not fin_contrato or fin_contrato < inicio:
        return []

    dia_cobro = inicio.day
    periodos: list[tuple[str, str]] = []
    n = 0
    while n <= 60:
        y = inicio.year + (inicio.month - 1 + n) // 12
        m = (inicio.month - 1 + n) % 12 + 1
        start = date(y, m, min(dia_cobro, monthrange(y, m)[1]))
        if start > fin_contrato:
            break
        y2 = inicio.year + (inicio.month - 1 + n + 1) // 12
        m2 = (inicio.month - 1 + n + 1) % 12 + 1
        next_start = date(y2, m2, min(dia_cobro, monthrange(y2, m2)[1]))
        end = min(next_start - timedelta(days=1), fin_contrato)
        if end < start:
            end = start
        periodos.append((_date_to_db(start), _date_to_db(end)))
        if end >= fin_contrato:
            break
        n += 1
    return periodos


def _add_months_clamp(d: date, months: int) -> date:
    """Suma meses conservando el día de cobro; clamp al último día del mes destino."""
    y = d.year + (d.month - 1 + months) // 12
    m = (d.month - 1 + months) % 12 + 1
    return date(y, m, min(d.day, monthrange(y, m)[1]))


def _siguiente_id_cuota(cursor) -> str:
    cursor.execute(
        """
        SELECT IFNULL(MAX(CAST(SUBSTRING(IDCUOTA, 4, 10) AS UNSIGNED)), 0) + 1
        FROM MENSUALIDAD_CUOTA WHERE IDCUOTA LIKE 'MCU%%'
        """
        if sp.is_mysql()
        else """
        SELECT ISNULL(MAX(TRY_CAST(SUBSTRING(IDCUOTA, 4, 10) AS INT)), 0) + 1
        FROM MENSUALIDAD_CUOTA WHERE IDCUOTA LIKE 'MCU%'
        """
    )
    num = int((cursor.fetchone() or [1])[0] or 1)
    return f'MCU{num:06d}'


def _costo_plan(cursor, id_plan: str) -> float:
    cursor.execute(
        f'SELECT IFNULL(COSTOMENSUAL, 0) FROM {plan_table()} WHERE IDPLAN = %s'
        if sp.is_mysql()
        else f'SELECT ISNULL(COSTOMENSUAL, 0) FROM {plan_table()} WHERE IDPLAN = %s',
        [id_plan],
    )
    row = cursor.fetchone()
    return float(row[0] or 0) if row else 0.0


def tabla_cuotas_existe(cursor) -> bool:
    if sp.is_mysql():
        cursor.execute(
            """
            SELECT COUNT(*) FROM information_schema.TABLES
            WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'MENSUALIDAD_CUOTA'
            """
        )
    else:
        cursor.execute("SELECT OBJECT_ID('dbo.MENSUALIDAD_CUOTA', 'U')")
    row = cursor.fetchone()
    return bool(row and row[0])


def mensualidad_tiene_cuotas(cursor, id_mensualidad: str) -> bool:
    if not tabla_cuotas_existe(cursor):
        return False
    cursor.execute(
        'SELECT COUNT(*) FROM MENSUALIDAD_CUOTA WHERE IDMENSUALIDAD = %s',
        [id_mensualidad],
    )
    return int((cursor.fetchone() or [0])[0] or 0) > 0


def generar_cuotas_mensualidad(
    id_mensualidad: str,
    fecha_inicio: str,
    fecha_fin: str,
    id_plan: str | None = None,
    monto_cuota: float | None = None,
    id_actor: str | None = None,
) -> int:
    """Crea cuotas para una matrícula nueva. No toca matrículas que ya tienen cuotas."""
    with connection.cursor() as cursor:
        if not tabla_cuotas_existe(cursor):
            return 0
        if mensualidad_tiene_cuotas(cursor, id_mensualidad):
            return 0

        if monto_cuota is None or monto_cuota <= 0:
            if id_plan:
                monto_cuota = _costo_plan(cursor, id_plan)
            if not monto_cuota or monto_cuota <= 0:
                cursor.execute(
                    'SELECT IFNULL(MONTOTOTAL, 0), IDPLAN FROM MENSUALIDAD WHERE IDMENSUALIDAD = %s'
                    if sp.is_mysql()
                    else 'SELECT ISNULL(MONTOTOTAL, 0), IDPLAN FROM MENSUALIDAD WHERE IDMENSUALIDAD = %s',
                    [id_mensualidad],
                )
                row = cursor.fetchone()
                if row:
                    total = float(row[0] or 0)
                    id_plan = id_plan or row[1]
                    monto_cuota = _costo_plan(cursor, id_plan) if id_plan else 0
                    if (not monto_cuota or monto_cuota <= 0) and total > 0:
                        periodos_tmp = generar_periodos_cuota(fecha_inicio, fecha_fin)
                        n = max(len(periodos_tmp), 1)
                        monto_cuota = round(total / n, 2)

        periodos = generar_periodos_cuota(fecha_inicio, fecha_fin)
        if not periodos:
            return 0

        creado = 0
        for i, (fi, ff) in enumerate(periodos, start=1):
            id_cuota = _siguiente_id_cuota(cursor)
            if sp.is_mysql():
                cursor.execute(
                    """
                    INSERT INTO MENSUALIDAD_CUOTA (
                        IDCUOTA, IDMENSUALIDAD, NUMERO, FECHAINICIO, FECHAFIN, MONTO, ESTADO,
                        CREADO_POR, FECHACREACION, HORACREACION
                    ) VALUES (
                        %s, %s, %s, %s, %s, %s, 'Pendiente',
                        %s, fn_fecha_ddmmyyyy(), TIME_FORMAT(NOW(), '%%H:%%i:%%s')
                    )
                    """,
                    [id_cuota, id_mensualidad, i, fi, ff, float(monto_cuota or 0), id_actor],
                )
            else:
                cursor.execute(
                    """
                    INSERT INTO MENSUALIDAD_CUOTA (
                        IDCUOTA, IDMENSUALIDAD, NUMERO, FECHAINICIO, FECHAFIN, MONTO, ESTADO,
                        CREADO_POR, FECHACREACION, HORACREACION
                    ) VALUES (
                        %s, %s, %s, %s, %s, %s, N'Pendiente',
                        %s, dbo.fn_fecha_ddmmyyyy(), CONVERT(CHAR(8), GETDATE(), 108)
                    )
                    """,
                    [id_cuota, id_mensualidad, i, fi, ff, float(monto_cuota or 0), id_actor],
                )
            creado += 1
        return creado


MSG_REDUCIR_CUOTAS_PAGADAS = (
    'No se pueden reducir los meses porque hay cuotas pagadas.'
)


def _es_retirado(estado) -> bool:
    return str(estado or '').strip().lower() == 'retirado'


def _sql_es_retirado(alias_usuario: str) -> str:
    if sp.is_mysql():
        return f"UPPER(TRIM(IFNULL({alias_usuario}.ESTADO, ''))) = 'RETIRADO'"
    return f"UPPER(LTRIM(RTRIM(ISNULL({alias_usuario}.ESTADO, N'')))) = N'RETIRADO'"


def _insertar_cuota(cursor, id_mensualidad, numero, fi, ff, monto, id_actor):
    id_cuota = _siguiente_id_cuota(cursor)
    if sp.is_mysql():
        cursor.execute(
            """
            INSERT INTO MENSUALIDAD_CUOTA (
                IDCUOTA, IDMENSUALIDAD, NUMERO, FECHAINICIO, FECHAFIN, MONTO, ESTADO,
                CREADO_POR, FECHACREACION, HORACREACION
            ) VALUES (
                %s, %s, %s, %s, %s, %s, 'Pendiente',
                %s, fn_fecha_ddmmyyyy(), TIME_FORMAT(NOW(), '%%H:%%i:%%s')
            )
            """,
            [id_cuota, id_mensualidad, numero, fi, ff, float(monto or 0), id_actor],
        )
    else:
        cursor.execute(
            """
            INSERT INTO MENSUALIDAD_CUOTA (
                IDCUOTA, IDMENSUALIDAD, NUMERO, FECHAINICIO, FECHAFIN, MONTO, ESTADO,
                CREADO_POR, FECHACREACION, HORACREACION
            ) VALUES (
                %s, %s, %s, %s, %s, %s, N'Pendiente',
                %s, dbo.fn_fecha_ddmmyyyy(), CONVERT(CHAR(8), GETDATE(), 108)
            )
            """,
            [id_cuota, id_mensualidad, numero, fi, ff, float(monto or 0), id_actor],
        )
    return id_cuota


def _actualizar_fechas_cuota(cursor, id_cuota, fi, ff, id_actor):
    if sp.is_mysql():
        cursor.execute(
            """
            UPDATE MENSUALIDAD_CUOTA SET
                FECHAINICIO = %s,
                FECHAFIN = %s,
                MODIFICADO_POR = %s,
                FECHAMODIFICACION = fn_fecha_ddmmyyyy(),
                HORAMODIFICACION = TIME_FORMAT(NOW(), '%%H:%%i:%%s')
            WHERE IDCUOTA = %s
            """,
            [fi, ff, id_actor, id_cuota],
        )
    else:
        cursor.execute(
            """
            UPDATE MENSUALIDAD_CUOTA SET
                FECHAINICIO = %s,
                FECHAFIN = %s,
                MODIFICADO_POR = %s,
                FECHAMODIFICACION = dbo.fn_fecha_ddmmyyyy(),
                HORAMODIFICACION = CONVERT(CHAR(8), GETDATE(), 108)
            WHERE IDCUOTA = %s
            """,
            [fi, ff, id_actor, id_cuota],
        )


def _cuotas_de_mensualidad(cursor, id_mensualidad: str) -> list[dict]:
    cursor.execute(
        """
        SELECT
            c.IDCUOTA,
            c.NUMERO,
            c.FECHAINICIO,
            c.FECHAFIN,
            c.MONTO,
            c.ESTADO,
            IFNULL(SUM(p.MONTO), 0) AS PAGADO,
            COUNT(p.IDPAGOMENSUALIDAD) AS CANT_PAGOS
        FROM MENSUALIDAD_CUOTA c
        LEFT JOIN PAGOMENSUALIDAD p ON p.IDCUOTA = c.IDCUOTA
        WHERE c.IDMENSUALIDAD = %s
        GROUP BY c.IDCUOTA, c.NUMERO, c.FECHAINICIO, c.FECHAFIN, c.MONTO, c.ESTADO
        ORDER BY c.NUMERO
        """
        if sp.is_mysql()
        else """
        SELECT
            c.IDCUOTA,
            c.NUMERO,
            c.FECHAINICIO,
            c.FECHAFIN,
            c.MONTO,
            c.ESTADO,
            ISNULL(SUM(p.MONTO), 0) AS PAGADO,
            COUNT(p.IDPAGOMENSUALIDAD) AS CANT_PAGOS
        FROM MENSUALIDAD_CUOTA c
        LEFT JOIN PAGOMENSUALIDAD p ON p.IDCUOTA = c.IDCUOTA
        WHERE c.IDMENSUALIDAD = %s
        GROUP BY c.IDCUOTA, c.NUMERO, c.FECHAINICIO, c.FECHAFIN, c.MONTO, c.ESTADO
        ORDER BY c.NUMERO
        """,
        [id_mensualidad],
    )
    return sp.cursor_rows(cursor)


def _cuota_bloquea_eliminacion(row: dict) -> bool:
    if float(row.get('PAGADO') or 0) > 0.0001:
        return True
    if int(row.get('CANT_PAGOS') or 0) > 0:
        return True
    return str(row.get('ESTADO') or '').strip().lower() == 'pagada'


def sincronizar_cuotas_mensualidad(
    cursor,
    id_mensualidad: str,
    fecha_inicio: str,
    fecha_fin: str,
    id_plan: str | None = None,
    id_actor: str | None = None,
    aplicar: bool = True,
) -> tuple[int, str]:
    """Alinea las cuotas con las fechas nuevas de la matrícula.

    Si se reducen periodos y alguna cuota a eliminar tiene pagos, no aplica cambios.
    """
    if not tabla_cuotas_existe(cursor):
        return 1, ''

    periodos = generar_periodos_cuota(fecha_inicio, fecha_fin)
    if not periodos:
        return 0, 'Las fechas de la mensualidad no generan cuotas. Revisa inicio y fin.'

    existentes = _cuotas_de_mensualidad(cursor, id_mensualidad)
    n_nuevo = len(periodos)
    n_actual = len(existentes)

    if n_nuevo < n_actual:
        a_borrar = existentes[n_nuevo:]
        if any(_cuota_bloquea_eliminacion(c) for c in a_borrar):
            return 0, MSG_REDUCIR_CUOTAS_PAGADAS

    if not aplicar:
        return 1, ''

    if n_actual == 0:
        generar_cuotas_mensualidad(
            id_mensualidad,
            fecha_inicio,
            fecha_fin,
            id_plan=id_plan,
            id_actor=id_actor,
        )
        return 1, ''

    for i, (fi, ff) in enumerate(periodos):
        if i < n_actual:
            actual = existentes[i]
            if str(actual.get('FECHAINICIO') or '') != fi or str(actual.get('FECHAFIN') or '') != ff:
                _actualizar_fechas_cuota(cursor, actual['IDCUOTA'], fi, ff, id_actor)
            continue
        monto = float((existentes[-1].get('MONTO') if existentes else 0) or 0)
        if monto <= 0 and id_plan:
            monto = _costo_plan(cursor, id_plan)
        _insertar_cuota(cursor, id_mensualidad, i + 1, fi, ff, monto, id_actor)

    if n_nuevo < n_actual:
        ids = [c['IDCUOTA'] for c in existentes[n_nuevo:]]
        if ids:
            marcas = ','.join(['%s'] * len(ids))
            cursor.execute(
                f'DELETE FROM MENSUALIDAD_CUOTA WHERE IDCUOTA IN ({marcas})',
                ids,
            )

    return 1, ''


def listar_cuotas_mensualidad(id_mensualidad: str) -> list[dict]:
    with connection.cursor() as cursor:
        if not tabla_cuotas_existe(cursor):
            return []
        fs_ini = fecha_sort_expr('c.FECHAINICIO')
        cursor.execute(
            f"""
            SELECT
                c.IDCUOTA,
                c.IDMENSUALIDAD,
                c.NUMERO,
                c.FECHAINICIO,
                c.FECHAFIN,
                c.MONTO,
                c.ESTADO,
                IFNULL(pag.PAGADO, 0) AS PAGADO,
                CASE WHEN IFNULL(c.MONTO, 0) - IFNULL(pag.PAGADO, 0) < 0 THEN 0
                     ELSE IFNULL(c.MONTO, 0) - IFNULL(pag.PAGADO, 0) END AS DEUDA
            FROM MENSUALIDAD_CUOTA c
            LEFT JOIN (
                SELECT IDCUOTA, SUM(MONTO) AS PAGADO
                FROM PAGOMENSUALIDAD
                WHERE IDCUOTA IS NOT NULL
                GROUP BY IDCUOTA
            ) pag ON pag.IDCUOTA = c.IDCUOTA
            WHERE c.IDMENSUALIDAD = %s
            ORDER BY c.NUMERO, {fs_ini}
            """
            if sp.is_mysql()
            else f"""
            SELECT
                c.IDCUOTA,
                c.IDMENSUALIDAD,
                c.NUMERO,
                c.FECHAINICIO,
                c.FECHAFIN,
                c.MONTO,
                c.ESTADO,
                ISNULL(pag.PAGADO, 0) AS PAGADO,
                CASE WHEN ISNULL(c.MONTO, 0) - ISNULL(pag.PAGADO, 0) < 0 THEN 0
                     ELSE ISNULL(c.MONTO, 0) - ISNULL(pag.PAGADO, 0) END AS DEUDA
            FROM MENSUALIDAD_CUOTA c
            OUTER APPLY (
                SELECT SUM(p.MONTO) AS PAGADO
                FROM PAGOMENSUALIDAD p
                WHERE p.IDCUOTA = c.IDCUOTA
            ) pag
            WHERE c.IDMENSUALIDAD = %s
            ORDER BY c.NUMERO, {fs_ini}
            """,
            [id_mensualidad],
        )
        rows = sp.cursor_rows(cursor)

    hoy = _hoy_db()
    hoy_key = hoy[4:8] + hoy[2:4] + hoy[0:2]
    out = []
    for r in rows:
        deuda = float(r.get('DEUDA') or 0)
        pagado = float(r.get('PAGADO') or 0)
        monto = float(r.get('MONTO') or 0)
        fi = str(r.get('FECHAINICIO') or '')
        ff = str(r.get('FECHAFIN') or '')
        fi_key = fi[4:8] + fi[2:4] + fi[0:2] if len(fi) == 8 else ''
        ff_key = ff[4:8] + ff[2:4] + ff[0:2] if len(ff) == 8 else ''

        vencida = bool(ff_key and ff_key < hoy_key and deuda > 0.0001)
        if deuda <= 0.0001 and pagado > 0:
            estado_calc = 'Cancelado'
        elif fi_key and fi_key > hoy_key:
            estado_calc = 'Pendiente'
        elif deuda > 0.0001 and fi_key and fi_key <= hoy_key:
            estado_calc = 'Deuda'
        else:
            estado_calc = 'Pendiente'

        exigible = deuda > 0 and fi_key and fi_key <= hoy_key
        out.append({
            **r,
            'MONTO': monto,
            'PAGADO': pagado,
            'DEUDA': deuda,
            'ESTADO_CALC': estado_calc,
            'EXIGIBLE': exigible,
            'VENCIDA': vencida,
        })
    return out


def deuda_exigible_mensualidad(cursor, id_mensualidad: str) -> float:
    """Deuda exigible: cuotas con FECHAINICIO <= hoy y saldo > 0. Legacy: MONTOTOTAL - PAGADO."""
    cursor.execute(
        """
        SELECT u.ESTADO
        FROM MENSUALIDAD m
        INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
        WHERE m.IDMENSUALIDAD = %s
        """,
        [id_mensualidad],
    )
    est = cursor.fetchone()
    if est and _es_retirado(est[0]):
        return 0.0
    if not tabla_cuotas_existe(cursor):
        return _deuda_legacy(cursor, id_mensualidad)
    if not mensualidad_tiene_cuotas(cursor, id_mensualidad):
        return _deuda_legacy(cursor, id_mensualidad)

    hoy = _hoy_db()
    fs = fecha_sort_expr('c.FECHAINICIO')
    fs_hoy = f"CONCAT(SUBSTRING('{hoy}',5,4), SUBSTRING('{hoy}',3,2), SUBSTRING('{hoy}',1,2))"
    if not sp.is_mysql():
        fs_hoy = f"SUBSTRING('{hoy}',5,4) + SUBSTRING('{hoy}',3,2) + SUBSTRING('{hoy}',1,2)"

    cursor.execute(
        f"""
        SELECT IFNULL(SUM(
            CASE WHEN IFNULL(c.MONTO, 0) - IFNULL(pag.PAGADO, 0) < 0 THEN 0
                 ELSE IFNULL(c.MONTO, 0) - IFNULL(pag.PAGADO, 0) END
        ), 0)
        FROM MENSUALIDAD_CUOTA c
        LEFT JOIN (
            SELECT IDCUOTA, SUM(MONTO) AS PAGADO
            FROM PAGOMENSUALIDAD WHERE IDCUOTA IS NOT NULL
            GROUP BY IDCUOTA
        ) pag ON pag.IDCUOTA = c.IDCUOTA
        WHERE c.IDMENSUALIDAD = %s
          AND {fs} <= {fs_hoy}
        """
        if sp.is_mysql()
        else f"""
        SELECT ISNULL(SUM(
            CASE WHEN ISNULL(c.MONTO, 0) - ISNULL(pag.PAGADO, 0) < 0 THEN 0
                 ELSE ISNULL(c.MONTO, 0) - ISNULL(pag.PAGADO, 0) END
        ), 0)
        FROM MENSUALIDAD_CUOTA c
        OUTER APPLY (
            SELECT SUM(p.MONTO) AS PAGADO FROM PAGOMENSUALIDAD p WHERE p.IDCUOTA = c.IDCUOTA
        ) pag
        WHERE c.IDMENSUALIDAD = %s
          AND {fs} <= {fs_hoy}
        """,
        [id_mensualidad],
    )
    return float((cursor.fetchone() or [0])[0] or 0)


def _deuda_legacy(cursor, id_mensualidad: str) -> float:
    cursor.execute(
        """
        SELECT
            CASE WHEN IFNULL(m.MONTOTOTAL, 0) - IFNULL(pag.PAGADO, 0) < 0 THEN 0
                 ELSE IFNULL(m.MONTOTOTAL, 0) - IFNULL(pag.PAGADO, 0) END
        FROM MENSUALIDAD m
        LEFT JOIN (
            SELECT IDMENSUALIDAD, SUM(MONTO) AS PAGADO
            FROM PAGOMENSUALIDAD GROUP BY IDMENSUALIDAD
        ) pag ON pag.IDMENSUALIDAD = m.IDMENSUALIDAD
        WHERE m.IDMENSUALIDAD = %s
        """
        if sp.is_mysql()
        else """
        SELECT
            CASE WHEN ISNULL(m.MONTOTOTAL, 0) - ISNULL(pag.PAGADO, 0) < 0 THEN 0
                 ELSE ISNULL(m.MONTOTOTAL, 0) - ISNULL(pag.PAGADO, 0) END
        FROM MENSUALIDAD m
        OUTER APPLY (
            SELECT SUM(p.MONTO) AS PAGADO FROM PAGOMENSUALIDAD p WHERE p.IDMENSUALIDAD = m.IDMENSUALIDAD
        ) pag
        WHERE m.IDMENSUALIDAD = %s
        """,
        [id_mensualidad],
    )
    row = cursor.fetchone()
    return float(row[0] or 0) if row else 0.0


def actualizar_monto_cuota(id_cuota: str, monto: float, id_actor: str | None = None, cursor=None) -> tuple[int, str]:
    if monto is None or monto < 0:
        return 0, 'Ingresa un monto válido para la cuota.'

    def _do(cur):
        if not tabla_cuotas_existe(cur):
            return 0, 'El módulo de cuotas no está instalado.'
        cur.execute('SELECT 1 FROM MENSUALIDAD_CUOTA WHERE IDCUOTA = %s', [id_cuota])
        if not cur.fetchone():
            return 0, 'La cuota no existe.'
        if sp.is_mysql():
            cur.execute(
                """
                UPDATE MENSUALIDAD_CUOTA SET
                    MONTO = %s,
                    MODIFICADO_POR = %s,
                    FECHAMODIFICACION = fn_fecha_ddmmyyyy(),
                    HORAMODIFICACION = TIME_FORMAT(NOW(), '%%H:%%i:%%s')
                WHERE IDCUOTA = %s
                """,
                [monto, id_actor, id_cuota],
            )
        else:
            cur.execute(
                """
                UPDATE MENSUALIDAD_CUOTA SET
                    MONTO = %s,
                    MODIFICADO_POR = %s,
                    FECHAMODIFICACION = dbo.fn_fecha_ddmmyyyy(),
                    HORAMODIFICACION = CONVERT(CHAR(8), GETDATE(), 108)
                WHERE IDCUOTA = %s
                """,
                [monto, id_actor, id_cuota],
            )
        return 1, 'Monto de cuota actualizado.'

    if cursor is not None:
        return _do(cursor)
    with connection.cursor() as cur:
        return _do(cur)


def sincronizar_estado_cuota(cursor, id_cuota: str) -> None:
    cursor.execute(
        """
        SELECT c.MONTO, IFNULL(SUM(p.MONTO), 0)
        FROM MENSUALIDAD_CUOTA c
        LEFT JOIN PAGOMENSUALIDAD p ON p.IDCUOTA = c.IDCUOTA
        WHERE c.IDCUOTA = %s
        GROUP BY c.MONTO
        """
        if sp.is_mysql()
        else """
        SELECT c.MONTO, ISNULL(SUM(p.MONTO), 0)
        FROM MENSUALIDAD_CUOTA c
        LEFT JOIN PAGOMENSUALIDAD p ON p.IDCUOTA = c.IDCUOTA
        WHERE c.IDCUOTA = %s
        GROUP BY c.MONTO
        """,
        [id_cuota],
    )
    row = cursor.fetchone()
    if not row:
        return
    monto, pagado = float(row[0] or 0), float(row[1] or 0)
    estado = 'Pagada' if pagado + 0.001 >= monto and monto > 0 else 'Pendiente'
    cursor.execute(
        'UPDATE MENSUALIDAD_CUOTA SET ESTADO = %s WHERE IDCUOTA = %s',
        [estado, id_cuota],
    )


def sql_deuda_exigible_expr(alias_m='m', alias_usuario=None) -> str:
    """
    Expresión SQL reutilizable: si hay cuotas usa deuda exigible; si no, fórmula legacy.
    Requiere que exista MENSUALIDAD_CUOTA (llamar solo tras verificar).
    Si alias_usuario está presente, estudiantes Retirado cuentan 0.
    """
    hoy = _hoy_db()
    if sp.is_mysql():
        fs_c = fecha_sort_expr('c.FECHAINICIO')
        fs_hoy = (
            f"CONCAT(SUBSTRING('{hoy}',5,4), SUBSTRING('{hoy}',3,2), "
            f"SUBSTRING('{hoy}',1,2))"
        )
        inner = f"""
        CASE
            WHEN EXISTS (
                SELECT 1 FROM MENSUALIDAD_CUOTA cx WHERE cx.IDMENSUALIDAD = {alias_m}.IDMENSUALIDAD
            ) THEN (
                SELECT IFNULL(SUM(
                    CASE WHEN IFNULL(c.MONTO, 0) - IFNULL(pg.PAGADO, 0) < 0 THEN 0
                         ELSE IFNULL(c.MONTO, 0) - IFNULL(pg.PAGADO, 0) END
                ), 0)
                FROM MENSUALIDAD_CUOTA c
                LEFT JOIN (
                    SELECT IDCUOTA, SUM(MONTO) AS PAGADO
                    FROM PAGOMENSUALIDAD WHERE IDCUOTA IS NOT NULL
                    GROUP BY IDCUOTA
                ) pg ON pg.IDCUOTA = c.IDCUOTA
                WHERE c.IDMENSUALIDAD = {alias_m}.IDMENSUALIDAD
                  AND {fs_c} <= {fs_hoy}
            )
            ELSE (
                CASE WHEN IFNULL({alias_m}.MONTOTOTAL, 0) - IFNULL((
                    SELECT SUM(p.MONTO) FROM PAGOMENSUALIDAD p
                    WHERE p.IDMENSUALIDAD = {alias_m}.IDMENSUALIDAD
                ), 0) < 0 THEN 0
                ELSE IFNULL({alias_m}.MONTOTOTAL, 0) - IFNULL((
                    SELECT SUM(p.MONTO) FROM PAGOMENSUALIDAD p
                    WHERE p.IDMENSUALIDAD = {alias_m}.IDMENSUALIDAD
                ), 0) END
            )
        END
        """
    else:
        fs_c = fecha_sort_expr('c.FECHAINICIO')
        fs_hoy = f"SUBSTRING('{hoy}',5,4) + SUBSTRING('{hoy}',3,2) + SUBSTRING('{hoy}',1,2)"
        inner = f"""
        CASE
            WHEN EXISTS (
                SELECT 1 FROM MENSUALIDAD_CUOTA cx WHERE cx.IDMENSUALIDAD = {alias_m}.IDMENSUALIDAD
            ) THEN (
                SELECT ISNULL(SUM(
                    CASE WHEN ISNULL(c.MONTO, 0) - ISNULL(pg.PAGADO, 0) < 0 THEN 0
                         ELSE ISNULL(c.MONTO, 0) - ISNULL(pg.PAGADO, 0) END
                ), 0)
                FROM MENSUALIDAD_CUOTA c
                OUTER APPLY (
                    SELECT SUM(p.MONTO) AS PAGADO FROM PAGOMENSUALIDAD p WHERE p.IDCUOTA = c.IDCUOTA
                ) pg
                WHERE c.IDMENSUALIDAD = {alias_m}.IDMENSUALIDAD
                  AND {fs_c} <= {fs_hoy}
            )
            ELSE (
                CASE WHEN ISNULL({alias_m}.MONTOTOTAL, 0) - ISNULL((
                    SELECT SUM(p.MONTO) FROM PAGOMENSUALIDAD p
                    WHERE p.IDMENSUALIDAD = {alias_m}.IDMENSUALIDAD
                ), 0) < 0 THEN 0
                ELSE ISNULL({alias_m}.MONTOTOTAL, 0) - ISNULL((
                    SELECT SUM(p.MONTO) FROM PAGOMENSUALIDAD p
                    WHERE p.IDMENSUALIDAD = {alias_m}.IDMENSUALIDAD
                ), 0) END
            )
        END
        """
    if not alias_usuario:
        return inner
    return f"CASE WHEN {_sql_es_retirado(alias_usuario)} THEN 0 ELSE ({inner}) END"


def _vence_periodo_derivado(fecha_inicio_db, fecha_fin_db, hoy_db: str) -> str | None:
    """Fin del periodo mensual vigente derivado del día de cobro del contrato."""
    periodos = generar_periodos_cuota(fecha_inicio_db, fecha_fin_db)
    if not periodos:
        return str(fecha_fin_db or '').strip() or None
    hoy = _db_to_date(hoy_db)
    if hoy:
        for _ini, fin in periodos:
            f = _db_to_date(fin)
            if f and f >= hoy:
                return fin
    return periodos[-1][1]


def vence_cuota_vigente_map(id_usuarios, hoy_db: str | None = None) -> dict[str, str]:
    """Fecha de vencimiento del periodo mensual vigente por estudiante.

    Usa la cuota vigente cuando ya existen cuotas generadas; en mensualidades
    legadas deriva el periodo desde el día de cobro para no exponer la fecha fin
    del contrato completo.
    """
    ids = [str(u) for u in dict.fromkeys(id_usuarios or []) if u]
    if not ids:
        return {}
    hoy = hoy_db or _hoy_db()
    hoy_date = _db_to_date(hoy)
    resultado: dict[str, str] = {}

    with connection.cursor() as cursor:
        hay_cuotas = tabla_cuotas_existe(cursor)
        for i in range(0, len(ids), 500):
            grupo = ids[i:i + 500]
            marcas = ','.join(['%s'] * len(grupo))

            if hay_cuotas:
                fs_ini = fecha_sort_expr('c.FECHAINICIO')
                fs_fin = fecha_sort_expr('c.FECHAFIN')
                fs_reg = fecha_sort_expr('m.FECHAREGISTRO')
                fs_hoy = (
                    "CONCAT(SUBSTRING(%s,5,4), SUBSTRING(%s,3,2), SUBSTRING(%s,1,2))"
                    if sp.is_mysql()
                    else "SUBSTRING(%s,5,4) + SUBSTRING(%s,3,2) + SUBSTRING(%s,1,2)"
                )
                cursor.execute(
                    f"""
                    SELECT m.IDUSUARIO, c.FECHAFIN
                    FROM MENSUALIDAD_CUOTA c
                    INNER JOIN MENSUALIDAD m ON m.IDMENSUALIDAD = c.IDMENSUALIDAD
                    INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
                    WHERE m.IDUSUARIO IN ({marcas})
                      AND (m.ESTADO IS NULL OR m.ESTADO = 'Activo')
                      AND NOT ({_sql_es_retirado('u')})
                      AND {fs_ini} <= {fs_hoy}
                      AND {fs_fin} >= {fs_hoy}
                    ORDER BY {fs_reg} DESC, c.NUMERO DESC
                    """,
                    grupo + [hoy, hoy, hoy, hoy, hoy, hoy],
                )
                for uid, fin in cursor.fetchall():
                    if fin:
                        resultado.setdefault(str(uid), fin)

            pendientes = [u for u in grupo if u not in resultado]
            if not pendientes:
                continue
            marcas_p = ','.join(['%s'] * len(pendientes))
            cursor.execute(
                f"""
                SELECT m.IDUSUARIO, m.FECHAINICIO, m.FECHAFIN, m.FECHAREGISTRO
                FROM MENSUALIDAD m
                INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
                WHERE m.IDUSUARIO IN ({marcas_p})
                  AND (m.ESTADO IS NULL OR m.ESTADO = 'Activo')
                  AND NOT ({_sql_es_retirado('u')})
                """,
                pendientes,
            )
            mejores: dict[str, tuple] = {}
            for uid, f_ini, f_fin, f_reg in cursor.fetchall():
                uid = str(uid)
                d_ini, d_fin, d_reg = _db_to_date(f_ini), _db_to_date(f_fin), _db_to_date(f_reg)
                vigente = bool(
                    hoy_date and d_ini and d_fin and d_ini <= hoy_date <= d_fin
                )
                orden = (1 if vigente else 0, d_reg or date.min, d_ini or date.min)
                if uid not in mejores or orden > mejores[uid][0]:
                    mejores[uid] = (orden, f_ini, f_fin)
            for uid, (_orden, f_ini, f_fin) in mejores.items():
                fecha = _vence_periodo_derivado(f_ini, f_fin, hoy)
                if fecha:
                    resultado[uid] = fecha

    return resultado


def fecha_vence_cuota_vigente(id_usuario: str, hoy_db: str | None = None) -> str | None:
    """FECHAFIN de la cuota vigente del estudiante; fallback FECHAFIN de mensualidad."""
    hoy = hoy_db or _hoy_db()
    with connection.cursor() as cursor:
        if not tabla_cuotas_existe(cursor):
            return None
        fs_ini = fecha_sort_expr('c.FECHAINICIO')
        fs_fin = fecha_sort_expr('c.FECHAFIN')
        fs_hoy = (
            f"CONCAT(SUBSTRING(%s,5,4), SUBSTRING(%s,3,2), SUBSTRING(%s,1,2))"
            if sp.is_mysql()
            else "SUBSTRING(%s,5,4) + SUBSTRING(%s,3,2) + SUBSTRING(%s,1,2)"
        )
        cursor.execute(
            f"""
            SELECT c.FECHAFIN
            FROM MENSUALIDAD_CUOTA c
            INNER JOIN MENSUALIDAD m ON m.IDMENSUALIDAD = c.IDMENSUALIDAD
            INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
            WHERE m.IDUSUARIO = %s
              AND (m.ESTADO IS NULL OR m.ESTADO = 'Activo')
              AND NOT ({_sql_es_retirado('u')})
              AND {fs_ini} <= {fs_hoy}
              AND {fs_fin} >= {fs_hoy}
            ORDER BY m.FECHAREGISTRO DESC, c.NUMERO DESC
            LIMIT 1
            """
            if sp.is_mysql()
            else f"""
            SELECT TOP 1 c.FECHAFIN
            FROM MENSUALIDAD_CUOTA c
            INNER JOIN MENSUALIDAD m ON m.IDMENSUALIDAD = c.IDMENSUALIDAD
            INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
            WHERE m.IDUSUARIO = %s
              AND (m.ESTADO IS NULL OR m.ESTADO = N'Activo')
              AND NOT ({_sql_es_retirado('u')})
              AND {fs_ini} <= {fs_hoy}
              AND {fs_fin} >= {fs_hoy}
            ORDER BY m.FECHAREGISTRO DESC, c.NUMERO DESC
            """,
            [id_usuario, hoy, hoy, hoy],
        )
        row = cursor.fetchone()
        return row[0] if row else None
