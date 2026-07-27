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


def listar_justificaciones(
    buscar=None,
    pagina=1,
    tamanio=10,
):
    with connection.cursor() as cursor:
        cursor.execute(
            """
            DECLARE @Total INT;
            EXEC dbo.usp_justificacion_listar
                @Buscar=%s, @Pagina=%s, @TamanioPagina=%s, @TotalRegistros=@Total OUTPUT;
            SELECT @Total AS TotalRegistros;
            """,
            [buscar or None, pagina, tamanio],
        )
        data = _cursor_rows(cursor)
        total = 0
        if cursor.nextset() and cursor.description:
            row = cursor.fetchone()
            if row:
                total = int(row[0])
    return data, total


def obtener_justificacion(id_justificacion: str):
    with connection.cursor() as cursor:
        cursor.execute('EXEC dbo.usp_justificacion_obtener @Id=%s', [id_justificacion])
        rows = _cursor_rows(cursor)
    return rows[0] if rows else None


def insertar_justificacion(payload: dict):
    with connection.cursor() as cursor:
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200);
            EXEC dbo.usp_justificacion_insertar
                @IdUsuario=%s, @Fecha=%s, @IdRegistrador=%s, @Observacion=%s,
                @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            [
                payload['IDUSUARIO'],
                payload['FECHA'],
                payload.get('IDREGISTRADOR') or None,
                payload.get('OBSERVACION'),
            ],
        )
        return _read_sp_write_result(cursor)


def actualizar_justificacion(id_justificacion: str, payload: dict):
    with connection.cursor() as cursor:
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200);
            EXEC dbo.usp_justificacion_actualizar
                @Id=%s, @IdUsuario=%s, @Fecha=%s, @Observacion=%s,
                @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            [
                id_justificacion,
                payload['IDUSUARIO'],
                payload['FECHA'],
                payload.get('OBSERVACION'),
            ],
        )
        return _read_sp_write_result(cursor)


def eliminar_justificacion(id_justificacion: str):
    with connection.cursor() as cursor:
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200);
            EXEC dbo.usp_justificacion_eliminar @Id=%s, @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            [id_justificacion],
        )
        return _read_sp_write_result(cursor)
