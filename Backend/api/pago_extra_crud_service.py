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


def insertar_pago_extra(payload: dict, id_usuario=None):
    params = [
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
            row = sp.call_write_outs(
                cursor,
                'usp_pagoextra_insertar',
                params,
                ['@_sp_r', '@_sp_m', '@_sp_id'],
                ['Resultado', 'Mensaje', 'IdGenerado'],
            )
            return int(row[0] or 0), str(row[1] or ''), row[2]
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200), @Id NVARCHAR(50);
            EXEC dbo.usp_pagoextra_insertar
                @IdUsuario=%s, @IdConcepto=%s, @Monto=%s,
                @FechaPago=%s, @Observaciones=%s, @IdRegistrador=%s,
                @IdGenerado=@Id OUTPUT, @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje, @Id AS IdGenerado;
            """,
            params,
        )
        ok, mensaje, extras = _read_sp_write_result(cursor, extra_cols=['idgenerado'])
        return ok, mensaje, extras.get('idgenerado')


def actualizar_pago_extra(id_pago: str, payload: dict, id_usuario=None):
    params = [
        id_pago,
        payload['IDCONCEPTO'],
        payload['MONTO'],
        payload['FECHAPAGO'],
        payload.get('OBSERVACIONES') or None,
    ]
    with connection.cursor() as cursor:
        prepare_write_cursor(cursor, id_usuario, payload)
        if sp.is_mysql():
            ok, mensaje = sp.call_write(cursor, 'usp_pagoextra_actualizar', params)
            return ok, mensaje
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200);
            EXEC dbo.usp_pagoextra_actualizar
                @Id=%s, @IdConcepto=%s, @Monto=%s,
                @FechaPago=%s, @Observaciones=%s,
                @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            params,
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
