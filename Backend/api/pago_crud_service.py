from django.db import connection
from .db_context import prepare_write_cursor
from . import sp_runner as sp
from .sql_compat import plan_table, fecha_sort_expr, concat_nombre_usuario


def _read_sp_write_result(cursor):
    return sp.read_write_result(cursor)


def _decimal_or_none(value):
    if value is None or value == '':
        return None
    return float(value)


def _listar_pagos_mysql(
    cursor,
    buscar=None,
    ordenar_por='FECHAPAGO',
    direccion='DESC',
    pagina=1,
    tamanio=10,
):
    buscar = (buscar or '').strip() or None
    ordenar_por = (ordenar_por or 'FECHAPAGO').strip()
    direccion = 'DESC' if (direccion or 'DESC').upper() == 'DESC' else 'ASC'
    pagina = max(1, int(pagina or 1))
    tamanio = max(1, int(tamanio or 10))
    offset = (pagina - 1) * tamanio
    nombre = concat_nombre_usuario('u')
    fs_pago = fecha_sort_expr('p.FECHAPAGO')

    where = """
        WHERE (%s IS NULL OR
               p.IDPAGOMENSUALIDAD LIKE CONCAT('%%', %s, '%%') OR
               m.IDMENSUALIDAD LIKE CONCAT('%%', %s, '%%') OR
               u.DNI LIKE CONCAT('%%', %s, '%%') OR
               u.NOMBRE LIKE CONCAT('%%', %s, '%%') OR
               u.APELLIDO LIKE CONCAT('%%', %s, '%%') OR
               pl.NOMBRE LIKE CONCAT('%%', %s, '%%') OR
               IFNULL(mp.TITULO, '') LIKE CONCAT('%%', %s, '%%'))
    """
    filtros = [buscar] * 8

    from_sql = f"""
        FROM PAGOMENSUALIDAD p
        INNER JOIN MENSUALIDAD m ON m.IDMENSUALIDAD = p.IDMENSUALIDAD
        INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
        INNER JOIN {plan_table()} pl ON pl.IDPLAN = m.IDPLAN
        LEFT JOIN METODO_PAGO mp ON mp.IDMETODOPAGO = p.IDMETODOPAGO
        {where}
    """

    cursor.execute(f'SELECT COUNT(*) {from_sql}', filtros)
    total = int((cursor.fetchone() or [0])[0])

    columnas_orden = {
        'FECHAPAGO': fs_pago,
        'MONTO': 'p.MONTO',
        'ESTUDIANTE_NOMBRE': 'u.APELLIDO',
        'IDPAGOMENSUALIDAD': 'p.IDPAGOMENSUALIDAD',
    }
    col_orden = columnas_orden.get(ordenar_por.upper(), fs_pago)
    order_sql = (
        f'ORDER BY {col_orden} {direccion}, {fs_pago} DESC, '
        f'p.HORAPAGO DESC, p.IDPAGOMENSUALIDAD DESC LIMIT %s OFFSET %s'
    )

    cursor.execute(
        f"""
        SELECT
            p.IDPAGOMENSUALIDAD,
            p.IDMENSUALIDAD,
            p.MONTO,
            p.FECHAPAGO,
            p.HORAPAGO,
            p.OBSERVACIONES,
            p.IDMETODOPAGO,
            IFNULL(mp.TITULO, '') AS METODOPAGO_TITULO,
            {nombre} AS ESTUDIANTE_NOMBRE,
            u.DNI AS ESTUDIANTE_DNI,
            pl.NOMBRE AS PLAN_NOMBRE
        {from_sql}
        {order_sql}
        """,
        filtros + [tamanio, offset],
    )
    return sp.cursor_rows(cursor), total


def listar_pagos(
    buscar=None,
    ordenar_por='FECHAPAGO',
    direccion='DESC',
    pagina=1,
    tamanio=10,
):
    params = [buscar or None, ordenar_por, direccion, pagina, tamanio]
    with connection.cursor() as cursor:
        if sp.is_mysql():
            return _listar_pagos_mysql(
                cursor, buscar, ordenar_por, direccion, pagina, tamanio
            )
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
    return data, total


def mensualidades_estudiante(id_usuario: str):
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
            return sp.cursor_rows(cursor)
        cursor.execute(
            'EXEC dbo.usp_pago_mensualidades_estudiante @IdUsuario=%s',
            [id_usuario],
        )
        return sp.cursor_rows(cursor)


def insertar_abono(payload: dict, id_usuario=None):
    id_mensualidad = payload.get('IDMENSUALIDAD')
    monto = _decimal_or_none(payload.get('MONTO'))
    id_metodo = payload.get('IDMETODOPAGO')
    obs = (payload.get('OBSERVACIONES') or '').strip() or 'Abono'
    reg = payload.get('REGISTRADOPOR') or None

    if not id_mensualidad:
        return 0, 'Debe seleccionar una mensualidad.'
    if not monto or monto <= 0:
        return 0, 'Ingrese un monto válido.'
    if not id_metodo:
        return 0, 'Indique el método de pago.'

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
                return 0, 'Esta mensualidad no tiene deuda pendiente.'
            if monto > deuda:
                return 0, f'El abono no puede superar la deuda (S/ {deuda:.2f}).'

            cursor.execute(
                """
                SELECT IFNULL(MAX(CAST(SUBSTRING(IDPAGOMENSUALIDAD, 4, 10) AS UNSIGNED)), 0) + 1
                FROM PAGOMENSUALIDAD WHERE IDPAGOMENSUALIDAD LIKE 'PAG%'
                """
            )
            id_pago = f'PAG{int(cursor.fetchone()[0]):06d}'

            cursor.execute(
                """
                INSERT INTO PAGOMENSUALIDAD (
                    IDPAGOMENSUALIDAD, MONTO, FECHAPAGO, HORAPAGO, OBSERVACIONES,
                    IDMENSUALIDAD, IDMETODOPAGO, IDUSUARIO
                ) VALUES (
                    %s, %s, fn_fecha_ddmmyyyy(), TIME_FORMAT(NOW(), '%%H:%%i:%%s'),
                    %s, %s, %s, %s
                )
                """,
                [id_pago, monto, obs, id_mensualidad, id_metodo, reg],
            )
            return 1, 'Abono registrado correctamente.'

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
    return sp.call_obtain('usp_pago_obtener', id_pago)


def actualizar_pago(id_pago: str, payload: dict, id_usuario=None):
    params = [
        id_pago,
        _decimal_or_none(payload.get('MONTO')),
        payload.get('IDMETODOPAGO'),
        payload.get('FECHAPAGO') or None,
        payload.get('OBSERVACIONES') or None,
    ]
    with connection.cursor() as cursor:
        prepare_write_cursor(cursor, id_usuario, payload)
        if sp.is_mysql():
            return sp.call_write(cursor, 'usp_pago_actualizar', params)
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
        return _read_sp_write_result(cursor)


def eliminar_pago(id_pago: str, id_usuario=None):
    with connection.cursor() as cursor:
        prepare_write_cursor(cursor, id_usuario)
        if sp.is_mysql():
            return sp.call_write(cursor, 'usp_pago_eliminar', [id_pago])
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200);
            EXEC dbo.usp_pago_eliminar
                @Id=%s, @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            [id_pago],
        )
        return _read_sp_write_result(cursor)


def listar_metodos_pago():
    with connection.cursor() as cursor:
        cursor.execute(
            """
            SELECT IDMETODOPAGO, TITULO
            FROM METODO_PAGO WHERE ACTIVO = 1 ORDER BY TITULO
            """
        )
        return sp.cursor_rows(cursor)
