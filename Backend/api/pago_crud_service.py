from django.db import connection
from .db_context import prepare_write_cursor
from . import sp_runner as sp


def _read_sp_write_result(cursor):
    return sp.read_write_result(cursor)


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
    params = [buscar or None, ordenar_por, direccion, pagina, tamanio]
    with connection.cursor() as cursor:
        if sp.is_mysql():
            return sp.call_list(cursor, 'usp_pago_listar', params)
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
            return sp.call_simple(cursor, 'usp_pago_mensualidades_estudiante', [id_usuario])
        cursor.execute(
            'EXEC dbo.usp_pago_mensualidades_estudiante @IdUsuario=%s',
            [id_usuario],
        )
        return sp.cursor_rows(cursor)


def insertar_abono(payload: dict, id_usuario=None):
    params = [
        payload.get('IDMENSUALIDAD'),
        _decimal_or_none(payload.get('MONTO')),
        payload.get('IDMETODOPAGO'),
        payload.get('OBSERVACIONES') or None,
        payload.get('REGISTRADOPOR') or None,
    ]
    with connection.cursor() as cursor:
        prepare_write_cursor(cursor, id_usuario, payload)
        if sp.is_mysql():
            return sp.call_write(cursor, 'usp_pago_insertar_abono', params)
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200);
            EXEC dbo.usp_pago_insertar_abono
                @IdMensualidad=%s, @Monto=%s, @IdMetodoPago=%s,
                @Observaciones=%s, @RegistradoPor=%s,
                @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            params,
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
