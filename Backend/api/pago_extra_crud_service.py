from django.db import connection
from .db_context import prepare_write_cursor
from .concepto_crud_service import listar_conceptos_activos
from . import sp_runner as sp


def _read_sp_write_result(cursor, extra_cols=None):
    resultado, mensaje = 0, 'Error desconocido'
    extras = {k: None for k in (extra_cols or [])}
    while True:
        if cursor.description:
            row = cursor.fetchone()
            if row:
                cols = [c[0].lower() for c in cursor.description]
                data = dict(zip(cols, row))
                resultado = data.get('resultado', resultado)
                mensaje = data.get('mensaje', mensaje)
                for k in extras:
                    if k.lower() in data:
                        extras[k] = data[k.lower()]
        if not cursor.nextset():
            break
    return int(resultado or 0), str(mensaje or ''), extras


def listar_pagos_extra(
    buscar=None,
    ordenar_por='FECHAPAGO',
    direccion='DESC',
    pagina=1,
    tamanio=10,
):
    params = [buscar or None, ordenar_por, direccion, pagina, tamanio]
    with connection.cursor() as cursor:
        if sp.is_mysql():
            return sp.call_list(cursor, 'usp_pagoextra_listar', params)
        cursor.execute(
            """
            DECLARE @Total INT;
            EXEC dbo.usp_pagoextra_listar
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


def obtener_pago_extra(id_pago: str):
    return sp.call_obtain('usp_pagoextra_obtener', id_pago)


def _call_pagoextra_insertar_mysql(cursor, bind):
    """usp_pagoextra_insertar: 4 IN + 2 INOUT (fechas del concepto) + 2 IN + 3 OUT."""
    cursor.execute(
        'SET @_in_fi = NULL, @_in_ff = NULL, @_sp_id = NULL, @_sp_r = 0, @_sp_m = NULL'
    )
    cursor.execute(
        """
        CALL usp_pagoextra_insertar(
            %s, %s, %s, %s, @_in_fi, @_in_ff, %s, %s,
            @_sp_id, @_sp_r, @_sp_m
        )
        """,
        bind,
    )
    sp.drain_sets(cursor)
    cursor.execute(
        'SELECT @_sp_id AS IdGenerado, @_sp_r AS Resultado, @_sp_m AS Mensaje'
    )
    return cursor.fetchone()


def _call_pagoextra_actualizar_mysql(cursor, bind):
    """usp_pagoextra_actualizar: 4 IN + 2 INOUT + 1 IN + 2 OUT."""
    cursor.execute('SET @_in_fi = NULL, @_in_ff = NULL, @_sp_r = 0, @_sp_m = NULL')
    cursor.execute(
        """
        CALL usp_pagoextra_actualizar(
            %s, %s, %s, %s, @_in_fi, @_in_ff, %s, @_sp_r, @_sp_m
        )
        """,
        bind,
    )
    sp.drain_sets(cursor)
    cursor.execute('SELECT @_sp_r AS Resultado, @_sp_m AS Mensaje')
    return cursor.fetchone()


def insertar_pago_extra(payload: dict, id_usuario=None):
    bind = [
        payload['IDUSUARIO'],
        payload['IDCONCEPTO'],
        payload['MONTO'],
        payload['FECHAPAGO'],
        payload.get('OBSERVACIONES') or None,
        payload.get('IDREGISTRADOR') or None,
    ]
    with connection.cursor() as cursor:
        prepare_write_cursor(cursor, id_usuario, payload)
        if sp.is_mysql():
            row = _call_pagoextra_insertar_mysql(cursor, bind)
            if not row:
                return 0, 'Error desconocido', None
            return int(row[1] or 0), str(row[2] or ''), row[0]
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200), @Id NVARCHAR(50);
            EXEC dbo.usp_pagoextra_insertar
                @IdUsuario=%s, @IdConcepto=%s, @Monto=%s,
                @FechaPago=%s, @Observaciones=%s, @IdRegistrador=%s,
                @IdGenerado=@Id OUTPUT, @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje, @Id AS IdGenerado;
            """,
            bind,
        )
        ok, mensaje, extras = _read_sp_write_result(cursor, extra_cols=['idgenerado'])
        return ok, mensaje, extras.get('idgenerado')


def actualizar_pago_extra(id_pago: str, payload: dict, id_usuario=None):
    bind = [
        id_pago,
        payload['IDCONCEPTO'],
        payload['MONTO'],
        payload['FECHAPAGO'],
        payload.get('OBSERVACIONES') or None,
    ]
    with connection.cursor() as cursor:
        prepare_write_cursor(cursor, id_usuario, payload)
        if sp.is_mysql():
            row = _call_pagoextra_actualizar_mysql(cursor, bind)
            if not row:
                return 0, 'Error desconocido'
            return int(row[0] or 0), str(row[1] or '')
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200);
            EXEC dbo.usp_pagoextra_actualizar
                @Id=%s, @IdConcepto=%s, @Monto=%s,
                @FechaPago=%s, @Observaciones=%s,
                @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            bind,
        )
        ok, mensaje, _ = _read_sp_write_result(cursor)
        return ok, mensaje


def eliminar_pago_extra(id_pago: str, id_usuario=None):
    with connection.cursor() as cursor:
        prepare_write_cursor(cursor, id_usuario)
        if sp.is_mysql():
            ok, mensaje = sp.call_write(cursor, 'usp_pagoextra_eliminar', [id_pago])
            return ok, mensaje
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200);
            EXEC dbo.usp_pagoextra_eliminar @Id=%s, @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            [id_pago],
        )
        ok, mensaje, _ = _read_sp_write_result(cursor)
        return ok, mensaje


def listar_catalogos_pago_extra():
    return {'conceptos': listar_conceptos_activos()}


def conceptos_estudiante(id_usuario: str):
    with connection.cursor() as cursor:
        if sp.is_mysql():
            return sp.call_simple(cursor, 'usp_pagoextra_conceptos_estudiante', [id_usuario])
        cursor.execute(
            'EXEC dbo.usp_pagoextra_conceptos_estudiante @IdUsuario=%s',
            [id_usuario],
        )
        return sp.cursor_rows(cursor)
