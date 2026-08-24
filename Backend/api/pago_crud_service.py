from django.db import connection
from .db_context import prepare_write_cursor
from . import sp_runner as sp
from .sql_compat import plan_table, concat_nombre_usuario


def _read_sp_write_result(cursor):
    return sp.read_write_result(cursor)


def _decimal_or_none(value):
    if value is None or value == '':
        return None
    return float(value)


def _mora_valida(value):
    mora = _decimal_or_none(value)
    return 0.0 if mora is None else mora


def _enriquecer_mora(cursor, pagos):
    """Añade mora y total cobrado a resultados de SP antiguos de SQL Server."""
    ids = [p.get('IDPAGOMENSUALIDAD') for p in pagos if p.get('IDPAGOMENSUALIDAD')]
    if not ids:
        return pagos
    placeholders = ','.join(['%s'] * len(ids))
    cursor.execute(
        f'SELECT IDPAGOMENSUALIDAD, ISNULL(MORA, 0) FROM PAGOMENSUALIDAD '
        f'WHERE IDPAGOMENSUALIDAD IN ({placeholders})',
        ids,
    )
    moras = {row[0]: float(row[1] or 0) for row in cursor.fetchall()}
    for pago in pagos:
        mora = moras.get(pago.get('IDPAGOMENSUALIDAD'), 0.0)
        pago['MORA'] = mora
        pago['TOTAL_COBRADO'] = float(pago.get('MONTO') or 0) + mora
    return pagos


def _sp_ausente(exc):
    msg = str(exc).lower()
    return '1305' in str(exc) or 'does not exist' in msg or 'could not find stored procedure' in msg


def _listar_pagos_agrupado_mysql(
    cursor,
    buscar=None,
    ordenar_por='ESTUDIANTE_NOMBRE',
    direccion='ASC',
    pagina=1,
    tamanio=10,
):
    buscar = (buscar or '').strip() or None
    ordenar_por = (ordenar_por or 'ESTUDIANTE_NOMBRE').strip()
    direccion = 'DESC' if (direccion or 'ASC').upper() == 'DESC' else 'ASC'
    pagina = max(1, int(pagina or 1))
    tamanio = max(1, int(tamanio or 10))
    offset = (pagina - 1) * tamanio
    nombre = concat_nombre_usuario('u')

    where = """
        WHERE (%s IS NULL OR
               u.NOMBRE LIKE CONCAT('%%', %s, '%%') OR
               u.APELLIDO LIKE CONCAT('%%', %s, '%%') OR
               CONCAT(IFNULL(u.APELLIDO, ''), ' ', IFNULL(u.NOMBRE, '')) LIKE CONCAT('%%', %s, '%%') OR
               u.DNI LIKE CONCAT('%%', %s, '%%') OR
               pl.NOMBRE LIKE CONCAT('%%', %s, '%%'))
    """
    filtros = [buscar] * 6

    from .cuota_service import sql_deuda_exigible_expr, tabla_cuotas_existe

    hay_cuotas = tabla_cuotas_existe(cursor)
    deuda_sql = sql_deuda_exigible_expr('m') if hay_cuotas else """
        CASE WHEN IFNULL(m.MONTOTOTAL, 0) - IFNULL(pag.PAGADO, 0) < 0 THEN 0
             ELSE IFNULL(m.MONTOTOTAL, 0) - IFNULL(pag.PAGADO, 0) END
    """
    cuota_join = """
        LEFT JOIN MENSUALIDAD_CUOTA ca ON ca.IDCUOTA = (
            SELECT c.IDCUOTA
            FROM MENSUALIDAD_CUOTA c
            WHERE c.IDMENSUALIDAD = m.IDMENSUALIDAD
            ORDER BY
                CASE
                    WHEN STR_TO_DATE(c.FECHAINICIO, '%%d%%m%%Y') <= CURDATE()
                     AND STR_TO_DATE(c.FECHAFIN, '%%d%%m%%Y') >= CURDATE() THEN 0
                    WHEN STR_TO_DATE(c.FECHAINICIO, '%%d%%m%%Y') <= CURDATE() THEN 1
                    ELSE 2
                END,
                CASE
                    WHEN STR_TO_DATE(c.FECHAINICIO, '%%d%%m%%Y') <= CURDATE()
                     AND STR_TO_DATE(c.FECHAFIN, '%%d%%m%%Y') >= CURDATE() THEN c.NUMERO
                    WHEN STR_TO_DATE(c.FECHAINICIO, '%%d%%m%%Y') <= CURDATE() THEN -c.NUMERO
                    ELSE c.NUMERO
                END
            LIMIT 1
        )
    """ if hay_cuotas else 'LEFT JOIN (SELECT NULL AS IDCUOTA, NULL AS NUMERO, NULL AS FECHAINICIO, NULL AS FECHAFIN) ca ON 1 = 0'

    from_sql = f"""
        FROM MENSUALIDAD m
        INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
        INNER JOIN {plan_table()} pl ON pl.IDPLAN = m.IDPLAN
        INNER JOIN (
            SELECT p1.IDMENSUALIDAD, p1.IDPAGOMENSUALIDAD
            FROM PAGOMENSUALIDAD p1
            INNER JOIN (
                SELECT p.IDMENSUALIDAD, MAX(p.IDPAGOMENSUALIDAD) AS ID_ULT
                FROM PAGOMENSUALIDAD p
                INNER JOIN (
                    SELECT IDMENSUALIDAD, MAX(STR_TO_DATE(FECHAPAGO, '%%d%%m%%Y')) AS MAX_F
                    FROM PAGOMENSUALIDAD
                    GROUP BY IDMENSUALIDAD
                ) mx ON mx.IDMENSUALIDAD = p.IDMENSUALIDAD
                   AND STR_TO_DATE(p.FECHAPAGO, '%%d%%m%%Y') = mx.MAX_F
                GROUP BY p.IDMENSUALIDAD
            ) pick ON pick.ID_ULT = p1.IDPAGOMENSUALIDAD
        ) ult ON ult.IDMENSUALIDAD = m.IDMENSUALIDAD
        LEFT JOIN (
            SELECT IDMENSUALIDAD, SUM(MONTO) AS PAGADO
            FROM PAGOMENSUALIDAD
            GROUP BY IDMENSUALIDAD
        ) pag ON pag.IDMENSUALIDAD = m.IDMENSUALIDAD
        {cuota_join}
        LEFT JOIN (
            SELECT IDCUOTA, SUM(MONTO) AS PAGADO
            FROM PAGOMENSUALIDAD
            WHERE IDCUOTA IS NOT NULL
            GROUP BY IDCUOTA
        ) pagc ON pagc.IDCUOTA = ca.IDCUOTA
        {where}
    """

    cursor.execute(f'SELECT COUNT(*) {from_sql}', filtros)
    total = int((cursor.fetchone() or [0])[0])

    columnas_orden = {
        'ESTUDIANTE_NOMBRE': 'u.APELLIDO',
        'PLAN_NOMBRE': 'pl.NOMBRE',
        'CUOTA_NUMERO': 'ca.NUMERO',
        'TOTAL': 'IFNULL(ca.MONTO, m.MONTOTOTAL)',
        'DEUDA': 'DEUDA',
        'PAGADO': 'PAGADO',
        'FECHAINICIO_CUOTA': "STR_TO_DATE(IFNULL(ca.FECHAINICIO, m.FECHAINICIO), '%%d%%m%%Y')",
        'FECHA': "STR_TO_DATE(IFNULL(ca.FECHAINICIO, m.FECHAINICIO), '%%d%%m%%Y')",
    }
    col_orden = columnas_orden.get(ordenar_por.upper(), 'u.APELLIDO')
    if col_orden in ('DEUDA', 'PAGADO'):
        order_sql = f'ORDER BY {col_orden} {direccion}, u.APELLIDO ASC LIMIT %s OFFSET %s'
    else:
        order_sql = f'ORDER BY {col_orden} {direccion}, u.APELLIDO ASC LIMIT %s OFFSET %s'

    cursor.execute(
        f"""
        SELECT
            ult.IDPAGOMENSUALIDAD,
            m.IDMENSUALIDAD,
            m.IDUSUARIO,
            {nombre} AS ESTUDIANTE_NOMBRE,
            u.DNI AS ESTUDIANTE_DNI,
            pl.NOMBRE AS PLAN_NOMBRE,
            ca.NUMERO AS CUOTA_NUMERO,
            IFNULL(ca.MONTO, m.MONTOTOTAL) AS TOTAL,
            CASE
                WHEN ca.IDCUOTA IS NOT NULL THEN IFNULL(pagc.PAGADO, 0)
                ELSE IFNULL(pag.PAGADO, 0)
            END AS PAGADO,
            ({deuda_sql}) AS DEUDA,
            IFNULL(ca.FECHAINICIO, m.FECHAINICIO) AS FECHAINICIO_CUOTA,
            IFNULL(ca.FECHAFIN, m.FECHAFIN) AS FECHAFIN_CUOTA
        {from_sql}
        {order_sql}
        """,
        filtros + [tamanio, offset],
    )
    return sp.cursor_rows(cursor), total


def listar_pagos(
    buscar=None,
    ordenar_por='ESTUDIANTE_NOMBRE',
    direccion='ASC',
    pagina=1,
    tamanio=10,
):
    params = [buscar or None, ordenar_por, direccion, pagina, tamanio]
    with connection.cursor() as cursor:
        if sp.is_mysql():
            try:
                return sp.call_list(cursor, 'usp_pago_listar_agrupado', params)
            except Exception as exc:
                if not _sp_ausente(exc):
                    raise
                return _listar_pagos_agrupado_mysql(
                    cursor, buscar, ordenar_por, direccion, pagina, tamanio
                )
        try:
            cursor.execute(
                """
                DECLARE @Total INT;
                EXEC dbo.usp_pago_listar_agrupado
                    @Buscar=%s, @OrdenarPor=%s, @Direccion=%s,
                    @Pagina=%s, @TamanioPagina=%s, @TotalRegistros=@Total OUTPUT;
                SELECT @Total AS TotalRegistros;
                """,
                params,
            )
            data = sp.cursor_rows(cursor)
            total = 0
            if cursor.nextset() and cursor.description:
                row = cursor.fetchone()
                if row:
                    total = int(row[0])
            return data, total
        except Exception as exc:
            if not _sp_ausente(exc):
                raise
            cursor.execute(
                """
                DECLARE @Total INT;
                EXEC dbo.usp_pago_listar
                    @Buscar=%s, @OrdenarPor=%s, @Direccion=%s,
                    @Pagina=%s, @TamanioPagina=%s, @TotalRegistros=@Total OUTPUT;
                SELECT @Total AS TotalRegistros;
                """,
                params,
            )
            data = sp.cursor_rows(cursor)
            total = 0
            if cursor.nextset() and cursor.description:
                row = cursor.fetchone()
                if row:
                    total = int(row[0])
            data = _enriquecer_mora(cursor, data)
            return data, total


def listar_pagos_detalle(id_mensualidad: str):
    with connection.cursor() as cursor:
        if sp.is_mysql():
            try:
                return sp.call_simple(cursor, 'usp_pago_listar_detalle', [id_mensualidad])
            except Exception as exc:
                if not _sp_ausente(exc):
                    raise
        else:
            cursor.execute(
                'EXEC dbo.usp_pago_listar_detalle @IdMensualidad=%s',
                [id_mensualidad],
            )
            return sp.cursor_rows(cursor)
        cursor.execute(
            """
            SELECT
                p.IDPAGOMENSUALIDAD,
                p.IDMENSUALIDAD,
                p.IDCUOTA,
                c.NUMERO AS CUOTA_NUMERO,
                p.MONTO,
                IFNULL(p.MORA, 0) AS MORA,
                p.MONTO + IFNULL(p.MORA, 0) AS TOTAL_COBRADO,
                p.FECHAPAGO,
                p.HORAPAGO,
                p.IDMETODOPAGO,
                IFNULL(mp.TITULO, '') AS METODOPAGO_TITULO,
                p.OBSERVACIONES,
                UPPER(TRIM(CONCAT(IFNULL(u.APELLIDO, ''), ' ', IFNULL(u.NOMBRE, ''))))
                    AS ESTUDIANTE_NOMBRE,
                pl.NOMBRE AS PLAN_NOMBRE
            FROM PAGOMENSUALIDAD p
            INNER JOIN MENSUALIDAD m ON m.IDMENSUALIDAD = p.IDMENSUALIDAD
            INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
            INNER JOIN {plan} pl ON pl.IDPLAN = m.IDPLAN
            LEFT JOIN MENSUALIDAD_CUOTA c ON c.IDCUOTA = p.IDCUOTA
            LEFT JOIN METODO_PAGO mp ON mp.IDMETODOPAGO = p.IDMETODOPAGO
            WHERE p.IDMENSUALIDAD = %s
            ORDER BY
                STR_TO_DATE(p.FECHAPAGO, '%%d%%m%%Y') DESC,
                p.HORAPAGO DESC,
                p.IDPAGOMENSUALIDAD DESC
            """.format(plan=plan_table()),
            [id_mensualidad],
        )
        return sp.cursor_rows(cursor)


def mensualidades_estudiante(id_usuario: str):
    from .cuota_service import (
        deuda_exigible_mensualidad,
        listar_cuotas_mensualidad,
        tabla_cuotas_existe,
    )

    with connection.cursor() as cursor:
        if sp.is_mysql():
            cursor.execute(
                f"""
                SELECT
                    m.IDMENSUALIDAD,
                    m.IDPLAN,
                    pl.NOMBRE AS PLAN_NOMBRE,
                    m.IDTURNO,
                    m.IDAULA,
                    m.IDTUTOR,
                    m.OBSERVACIONES,
                    m.FECHAINICIO,
                    m.FECHAFIN,
                    m.MONTOTOTAL,
                    IFNULL(pag.PAGADO, 0) AS PAGADO,
                    CASE WHEN IFNULL(m.MONTOTOTAL, 0) - IFNULL(pag.PAGADO, 0) < 0 THEN 0
                         ELSE IFNULL(m.MONTOTOTAL, 0) - IFNULL(pag.PAGADO, 0) END AS DEUDA,
                    m.ESTADOMIEMBRO,
                    CASE m.ESTADOMIEMBRO
                        WHEN 2 THEN 'Activo'
                        WHEN 3 THEN 'Vencido'
                        ELSE 'Activo'
                    END AS ESTADOMIEMBRO_DESCRIPCION,
                    m.ESTADO,
                    m.FECHAREGISTRO
                FROM MENSUALIDAD m
                INNER JOIN {plan_table()} pl ON pl.IDPLAN = m.IDPLAN
                LEFT JOIN LATERAL (
                    SELECT SUM(p.MONTO) AS PAGADO
                    FROM PAGOMENSUALIDAD p
                    WHERE p.IDMENSUALIDAD = m.IDMENSUALIDAD
                ) pag ON TRUE
                WHERE m.IDUSUARIO = %s
                  AND m.ESTADO = 'Activo'
                ORDER BY m.FECHAREGISTRO DESC, m.IDMENSUALIDAD DESC
                LIMIT 3
                """,
                [id_usuario],
            )
            rows = sp.cursor_rows(cursor)
        else:
            cursor.execute(
                'EXEC dbo.usp_pago_mensualidades_estudiante @IdUsuario=%s',
                [id_usuario],
            )
            rows = sp.cursor_rows(cursor)

        if not tabla_cuotas_existe(cursor):
            return rows

        out = []
        for r in rows:
            id_m = r.get('IDMENSUALIDAD')
            cuotas = listar_cuotas_mensualidad(id_m)
            deuda = deuda_exigible_mensualidad(cursor, id_m) if cuotas else float(r.get('DEUDA') or 0)
            out.append({
                **r,
                'DEUDA': deuda,
                'DEUDA_EXIGIBLE': deuda,
                'TIENE_CUOTAS': len(cuotas) > 0,
                'CUOTAS': cuotas,
            })
        return out


def insertar_abono(payload: dict, id_usuario=None):
    id_mensualidad = payload.get('IDMENSUALIDAD')
    id_cuota = (payload.get('IDCUOTA') or '').strip() or None
    monto = _decimal_or_none(payload.get('MONTO'))
    id_metodo = payload.get('IDMETODOPAGO')
    obs = (payload.get('OBSERVACIONES') or '').strip() or 'Abono'
    reg = payload.get('REGISTRADOPOR') or None
    monto_cuota_edit = _decimal_or_none(payload.get('MONTO_CUOTA'))
    mora = _mora_valida(payload.get('MORA'))

    if not id_mensualidad:
        return 0, 'Debe seleccionar una mensualidad.'
    if not monto or monto <= 0:
        return 0, 'Ingrese un monto válido.'
    if not id_metodo:
        return 0, 'Indique el método de pago.'
    if mora < 0:
        return 0, 'La mora no puede ser negativa.'
    if mora > 0 and not id_cuota:
        return 0, 'La mora solo puede registrarse en el pago de una cuota.'

    from .cuota_service import (
        actualizar_monto_cuota,
        mensualidad_tiene_cuotas,
        sincronizar_estado_cuota,
        tabla_cuotas_existe,
    )

    with connection.cursor() as cursor:
        prepare_write_cursor(cursor, id_usuario, payload)
        if sp.is_mysql():
            cursor.execute(
                "SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = %s AND ESTADO = 'Activo'",
                [id_mensualidad],
            )
            if not cursor.fetchone():
                return 0, 'La mensualidad no existe o está inactiva.'

            cursor.execute(
                'SELECT 1 FROM METODO_PAGO WHERE IDMETODOPAGO = %s AND ACTIVO = 1',
                [id_metodo],
            )
            if not cursor.fetchone():
                return 0, 'El método de pago no es válido.'

            tiene_cuotas = tabla_cuotas_existe(cursor) and mensualidad_tiene_cuotas(
                cursor, id_mensualidad
            )

            if tiene_cuotas:
                if not id_cuota:
                    return 0, 'Selecciona la cuota que estás cobrando.'
                cursor.execute(
                    """
                    SELECT MONTO FROM MENSUALIDAD_CUOTA
                    WHERE IDCUOTA = %s AND IDMENSUALIDAD = %s
                    """,
                    [id_cuota, id_mensualidad],
                )
                row_c = cursor.fetchone()
                if not row_c:
                    return 0, 'La cuota no pertenece a esta mensualidad.'

                if monto_cuota_edit is not None and monto_cuota_edit >= 0:
                    ok_m, msg_m = actualizar_monto_cuota(
                        id_cuota, monto_cuota_edit, id_usuario, cursor=cursor
                    )
                    if not ok_m:
                        return ok_m, msg_m
                    monto_base = monto_cuota_edit
                else:
                    monto_base = float(row_c[0] or 0)

                cursor.execute(
                    'SELECT IFNULL(SUM(MONTO), 0) FROM PAGOMENSUALIDAD WHERE IDCUOTA = %s',
                    [id_cuota],
                )
                pagado = float(cursor.fetchone()[0])
                deuda = max(0.0, float(monto_base) - pagado)
            else:
                cursor.execute(
                    'SELECT IFNULL(MONTOTOTAL, 0) FROM MENSUALIDAD WHERE IDMENSUALIDAD = %s',
                    [id_mensualidad],
                )
                monto_total = float(cursor.fetchone()[0])
                cursor.execute(
                    'SELECT IFNULL(SUM(MONTO), 0) FROM PAGOMENSUALIDAD WHERE IDMENSUALIDAD = %s',
                    [id_mensualidad],
                )
                pagado = float(cursor.fetchone()[0])
                deuda = max(0.0, monto_total - pagado)

            if deuda <= 0:
                return 0, 'Esta cuota/mensualidad no tiene deuda pendiente.'
            if monto > deuda + 0.001:
                return 0, f'El abono no puede superar la deuda (S/ {deuda:.2f}).'

            cursor.execute(
                """
                SELECT IFNULL(MAX(CAST(SUBSTRING(IDPAGOMENSUALIDAD, 4, 10) AS UNSIGNED)), 0) + 1
                FROM PAGOMENSUALIDAD WHERE IDPAGOMENSUALIDAD LIKE 'PAG%%'
                """
            )
            id_pago = f'PAG{int(cursor.fetchone()[0]):06d}'

            cursor.execute(
                """
                INSERT INTO PAGOMENSUALIDAD (
                    IDPAGOMENSUALIDAD, MONTO, MORA, FECHAPAGO, HORAPAGO, OBSERVACIONES,
                    IDMENSUALIDAD, IDMETODOPAGO, IDUSUARIO, IDCUOTA
                ) VALUES (
                    %s, %s, %s, fn_fecha_ddmmyyyy(), TIME_FORMAT(NOW(), '%%H:%%i:%%s'),
                    %s, %s, %s, %s, %s
                )
                """,
                [id_pago, monto, mora, obs, id_mensualidad, id_metodo, reg, id_cuota],
            )
            if id_cuota:
                sincronizar_estado_cuota(cursor, id_cuota)
            return 1, 'Abono registrado correctamente.'

        # SQL Server: SP legacy (sin cuota) + extensión mínima si hay IDCUOTA
        tiene_cuotas = tabla_cuotas_existe(cursor) and mensualidad_tiene_cuotas(
            cursor, id_mensualidad
        )
        if tiene_cuotas and not id_cuota:
            return 0, 'Selecciona la cuota que estás cobrando.'
        if id_cuota:
            if monto_cuota_edit is not None and monto_cuota_edit >= 0:
                ok_m, msg_m = actualizar_monto_cuota(
                    id_cuota, monto_cuota_edit, id_usuario, cursor=cursor
                )
                if not ok_m:
                    return ok_m, msg_m
            cursor.execute(
                """
                DECLARE @R INT, @M NVARCHAR(200);
                DECLARE @IdPago NVARCHAR(50);
                SELECT @IdPago = 'PAG' + RIGHT('000000' + CAST(
                    ISNULL(MAX(TRY_CAST(SUBSTRING(IDPAGOMENSUALIDAD, 4, 10) AS INT)), 0) + 1 AS NVARCHAR
                ), 6) FROM PAGOMENSUALIDAD WHERE IDPAGOMENSUALIDAD LIKE 'PAG%';
                INSERT INTO PAGOMENSUALIDAD (
                    IDPAGOMENSUALIDAD, MONTO, MORA, FECHAPAGO, HORAPAGO, OBSERVACIONES,
                    IDMENSUALIDAD, IDMETODOPAGO, IDUSUARIO, IDCUOTA
                ) VALUES (
                    @IdPago, %s, %s, dbo.fn_fecha_ddmmyyyy(), CONVERT(CHAR(8), GETDATE(), 108),
                    %s, %s, %s, %s, %s
                );
                SELECT 1 AS Resultado, N'Abono registrado correctamente.' AS Mensaje;
                """,
                [monto, mora, obs, id_mensualidad, id_metodo, reg, id_cuota],
            )
            sincronizar_estado_cuota(cursor, id_cuota)
            return _read_sp_write_result(cursor)

        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200);
            EXEC dbo.usp_pago_insertar_abono
                @IdMensualidad=%s, @Monto=%s, @IdMetodoPago=%s,
                @Observaciones=%s, @RegistradoPor=%s,
                @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            [id_mensualidad, monto, id_metodo, obs, reg],
        )
        return _read_sp_write_result(cursor)


def obtener_pago(id_pago: str):
    row = sp.call_obtain('usp_pago_obtener', id_pago)
    if not row:
        return None
    with connection.cursor() as cursor:
        cursor.execute(
            """
            SELECT ISNULL(p.MORA, 0), p.IDCUOTA, c.NUMERO, c.MONTO, c.FECHAINICIO, c.FECHAFIN
            FROM PAGOMENSUALIDAD p
            LEFT JOIN MENSUALIDAD_CUOTA c ON c.IDCUOTA = p.IDCUOTA
            WHERE p.IDPAGOMENSUALIDAD = %s
            """
            if not sp.is_mysql()
            else """
            SELECT IFNULL(p.MORA, 0), p.IDCUOTA, c.NUMERO, c.MONTO, c.FECHAINICIO, c.FECHAFIN
            FROM PAGOMENSUALIDAD p
            LEFT JOIN MENSUALIDAD_CUOTA c ON c.IDCUOTA = p.IDCUOTA
            WHERE p.IDPAGOMENSUALIDAD = %s
            """,
            [id_pago],
        )
        extra = cursor.fetchone()
    mora = float(extra[0] or 0) if extra else 0.0
    row['MORA'] = mora
    row['IDCUOTA'] = extra[1] if extra else None
    row['CUOTA_NUMERO'] = extra[2] if extra else None
    row['MONTO_CUOTA'] = float(extra[3] or 0) if extra and extra[3] is not None else None
    row['FECHAINICIO_CUOTA'] = extra[4] if extra else None
    row['FECHAFIN_CUOTA'] = extra[5] if extra else None
    row['TOTAL_COBRADO'] = float(row.get('MONTO') or 0) + mora
    return row


def actualizar_pago(id_pago: str, payload: dict, id_usuario=None):
    mora_enviada = _decimal_or_none(payload.get('MORA')) if 'MORA' in payload else None
    params = [
        id_pago,
        _decimal_or_none(payload.get('MONTO')),
        payload.get('IDMETODOPAGO'),
        payload.get('FECHAPAGO') or None,
        payload.get('OBSERVACIONES') or None,
    ]
    with connection.cursor() as cursor:
        prepare_write_cursor(cursor, id_usuario, payload)
        cursor.execute(
            'SELECT IDCUOTA, MORA FROM PAGOMENSUALIDAD WHERE IDPAGOMENSUALIDAD = %s',
            [id_pago],
        )
        pago_row = cursor.fetchone()
        id_cuota = pago_row[0] if pago_row else None
        mora = (
            mora_enviada
            if mora_enviada is not None
            else (float(pago_row[1] or 0) if pago_row else 0.0)
        )
        if mora < 0:
            return 0, 'La mora no puede ser negativa.'
        if mora > 0 and not id_cuota:
            return 0, 'La mora solo puede registrarse en el pago de una cuota.'
        if sp.is_mysql():
            resultado = sp.call_write(cursor, 'usp_pago_actualizar', params)
        else:
            cursor.execute(
                """
                DECLARE @R INT, @M NVARCHAR(200);
                EXEC dbo.usp_pago_actualizar
                    @Id=%s, @Monto=%s, @IdMetodoPago=%s, @FechaPago=%s,
                    @Observaciones=%s,
                    @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
                SELECT @R AS Resultado, @M AS Mensaje;
                """,
                params,
            )
            resultado = _read_sp_write_result(cursor)
        if resultado[0]:
            cursor.execute(
                'UPDATE PAGOMENSUALIDAD SET MORA = %s WHERE IDPAGOMENSUALIDAD = %s',
                [mora, id_pago],
            )
            if id_cuota:
                from .cuota_service import sincronizar_estado_cuota
                sincronizar_estado_cuota(cursor, id_cuota)
        return resultado


def eliminar_pago(id_pago: str, id_usuario=None):
    with connection.cursor() as cursor:
        prepare_write_cursor(cursor, id_usuario)
        cursor.execute(
            'SELECT IDCUOTA FROM PAGOMENSUALIDAD WHERE IDPAGOMENSUALIDAD = %s',
            [id_pago],
        )
        pago_row = cursor.fetchone()
        id_cuota = pago_row[0] if pago_row else None
        if sp.is_mysql():
            resultado = sp.call_write(cursor, 'usp_pago_eliminar', [id_pago])
        else:
            cursor.execute(
                """
                DECLARE @R INT, @M NVARCHAR(200);
                EXEC dbo.usp_pago_eliminar
                    @Id=%s, @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
                SELECT @R AS Resultado, @M AS Mensaje;
                """,
                [id_pago],
            )
            resultado = _read_sp_write_result(cursor)
        if resultado[0] and id_cuota:
            from .cuota_service import sincronizar_estado_cuota
            sincronizar_estado_cuota(cursor, id_cuota)
        return resultado


def listar_metodos_pago():
    with connection.cursor() as cursor:
        cursor.execute(
            """
            SELECT IDMETODOPAGO, TITULO
            FROM METODO_PAGO WHERE ACTIVO = 1 ORDER BY TITULO
            """
        )
        return sp.cursor_rows(cursor)
