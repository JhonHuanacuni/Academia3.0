from django.db import connection


def _cursor_rows(cursor):
    columns = [col[0] for col in cursor.description] if cursor.description else []
    return [dict(zip(columns, row)) for row in cursor.fetchall()]


def _read_sp_write_result(cursor):
    resultado, mensaje = 0, 'Error desconocido'
    while True:
        if cursor.description:
            row = cursor.fetchone()
            if row:
                cols = [c[0].lower() for c in cursor.description]
                data = dict(zip(cols, row))
                resultado = data.get('resultado', resultado)
                mensaje = data.get('mensaje', mensaje)
        if not cursor.nextset():
            break
    return int(resultado or 0), str(mensaje or '')


def _decimal_or_none(value):
    if value is None or value == '':
        return None
    return float(value)


def listar_pagos(
    buscar=None,
    ordenar_por='FECHAPAGO',
    direccion='DESC',
    pagina=1,
    tamanio=10,
):
    with connection.cursor() as cursor:
        cursor.execute(
            """
            DECLARE @Total INT;
            EXEC dbo.usp_pago_listar
                @Buscar=%s, @OrdenarPor=%s, @Direccion=%s,
                @Pagina=%s, @TamanioPagina=%s, @TotalRegistros=@Total OUTPUT;
            SELECT @Total AS TotalRegistros;
            """,
            [buscar or None, ordenar_por, direccion, pagina, tamanio],
        )
        data = _cursor_rows(cursor)
        total = 0
        if cursor.nextset() and cursor.description:
            row = cursor.fetchone()
            if row:
                total = int(row[0])
    return data, total


def mensualidades_estudiante(id_usuario: str):
    with connection.cursor() as cursor:
        cursor.execute(
            'EXEC dbo.usp_pago_mensualidades_estudiante @IdUsuario=%s',
            [id_usuario],
        )
        return _cursor_rows(cursor)


def insertar_abono(payload: dict):
    with connection.cursor() as cursor:
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200);
            EXEC dbo.usp_pago_insertar_abono
                @IdMensualidad=%s, @Monto=%s, @IdMetodoPago=%s,
                @Observaciones=%s, @RegistradoPor=%s,
                @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            [
                payload.get('IDMENSUALIDAD'),
                _decimal_or_none(payload.get('MONTO')),
                payload.get('IDMETODOPAGO'),
                payload.get('OBSERVACIONES') or None,
                payload.get('REGISTRADOPOR') or None,
            ],
        )
        return _read_sp_write_result(cursor)


def obtener_pago(id_pago: str):
    with connection.cursor() as cursor:
        cursor.execute('EXEC dbo.usp_pago_obtener @Id=%s', [id_pago])
        rows = _cursor_rows(cursor)
    return rows[0] if rows else None


def actualizar_pago(id_pago: str, payload: dict):
    with connection.cursor() as cursor:
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200);
            EXEC dbo.usp_pago_actualizar
                @Id=%s, @Monto=%s, @IdMetodoPago=%s, @FechaPago=%s,
                @Observaciones=%s,
                @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            [
                id_pago,
                _decimal_or_none(payload.get('MONTO')),
                payload.get('IDMETODOPAGO'),
                payload.get('FECHAPAGO') or None,
                payload.get('OBSERVACIONES') or None,
            ],
        )
        return _read_sp_write_result(cursor)


def eliminar_pago(id_pago: str):
    with connection.cursor() as cursor:
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
        return _cursor_rows(cursor)
