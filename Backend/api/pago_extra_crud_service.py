from django.db import connection
from .concepto_crud_service import listar_conceptos_activos


def _cursor_rows(cursor):
    columns = [col[0] for col in cursor.description] if cursor.description else []
    return [dict(zip(columns, row)) for row in cursor.fetchall()]


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
    with connection.cursor() as cursor:
        cursor.execute(
            """
            DECLARE @Total INT;
            EXEC dbo.usp_pagoextra_listar
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


def obtener_pago_extra(id_pago: str):
    with connection.cursor() as cursor:
        cursor.execute('EXEC dbo.usp_pagoextra_obtener @Id=%s', [id_pago])
        rows = _cursor_rows(cursor)
    return rows[0] if rows else None


def insertar_pago_extra(payload: dict):
    with connection.cursor() as cursor:
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200), @Id NVARCHAR(50);
            EXEC dbo.usp_pagoextra_insertar
                @IdUsuario=%s, @IdConcepto=%s, @Monto=%s,
                @FechaPago=%s, @Observaciones=%s, @IdRegistrador=%s,
                @IdGenerado=@Id OUTPUT, @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje, @Id AS IdGenerado;
            """,
            [
                payload['IDUSUARIO'],
                payload['IDCONCEPTO'],
                payload['MONTO'],
                payload['FECHAPAGO'],
                payload.get('OBSERVACIONES') or None,
                payload.get('IDREGISTRADOR') or None,
            ],
        )
        ok, mensaje, extras = _read_sp_write_result(cursor, extra_cols=['idgenerado'])
        return ok, mensaje, extras.get('idgenerado')


def actualizar_pago_extra(id_pago: str, payload: dict):
    with connection.cursor() as cursor:
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200);
            EXEC dbo.usp_pagoextra_actualizar
                @Id=%s, @IdConcepto=%s, @Monto=%s,
                @FechaPago=%s, @Observaciones=%s,
                @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            [
                id_pago,
                payload['IDCONCEPTO'],
                payload['MONTO'],
                payload['FECHAPAGO'],
                payload.get('OBSERVACIONES') or None,
            ],
        )
        ok, mensaje, _ = _read_sp_write_result(cursor)
        return ok, mensaje


def eliminar_pago_extra(id_pago: str):
    with connection.cursor() as cursor:
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
        cursor.execute(
            'EXEC dbo.usp_pagoextra_conceptos_estudiante @IdUsuario=%s',
            [id_usuario],
        )
        return _cursor_rows(cursor)
