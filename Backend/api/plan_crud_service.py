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


def listar_planes(
    buscar=None,
    estado=None,
    ordenar_por='NOMBRE',
    direccion='ASC',
    pagina=1,
    tamanio=10,
):
    with connection.cursor() as cursor:
        cursor.execute(
            """
            DECLARE @Total INT;
            EXEC dbo.usp_plan_listar
                @Buscar=%s, @Estado=%s, @OrdenarPor=%s, @Direccion=%s,
                @Pagina=%s, @TamanioPagina=%s, @TotalRegistros=@Total OUTPUT;
            SELECT @Total AS TotalRegistros;
            """,
            [buscar or None, estado or None, ordenar_por, direccion, pagina, tamanio],
        )
        data = _cursor_rows(cursor)
        total = 0
        if cursor.nextset() and cursor.description:
            row = cursor.fetchone()
            if row:
                total = int(row[0])
    return data, total


def obtener_plan(id_plan: str):
    with connection.cursor() as cursor:
        cursor.execute('EXEC dbo.usp_plan_obtener @Id=%s', [id_plan])
        rows = _cursor_rows(cursor)
    return rows[0] if rows else None


def insertar_plan(payload: dict):
    with connection.cursor() as cursor:
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200);
            EXEC dbo.usp_plan_insertar
                @Id=%s, @Nombre=%s, @Descripcion=%s, @CostoMensual=%s,
                @DiasAsistencia=%s, @Estado=%s,
                @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            [
                payload['IDPLAN'],
                payload['NOMBRE'],
                payload.get('DESCRIPCION'),
                payload.get('COSTOMENSUAL'),
                payload.get('DIASASISTENCIA', 63),
                payload.get('ESTADO', 'Activo'),
            ],
        )
        return _read_sp_write_result(cursor)


def actualizar_plan(id_plan: str, payload: dict):
    with connection.cursor() as cursor:
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200);
            EXEC dbo.usp_plan_actualizar
                @Id=%s, @Nombre=%s, @Descripcion=%s, @CostoMensual=%s,
                @DiasAsistencia=%s, @Estado=%s,
                @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            [
                id_plan,
                payload['NOMBRE'],
                payload.get('DESCRIPCION'),
                payload.get('COSTOMENSUAL'),
                payload.get('DIASASISTENCIA', 63),
                payload.get('ESTADO', 'Activo'),
            ],
        )
        return _read_sp_write_result(cursor)


def eliminar_plan(id_plan: str):
    with connection.cursor() as cursor:
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200);
            EXEC dbo.usp_plan_eliminar @Id=%s, @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            [id_plan],
        )
        return _read_sp_write_result(cursor)
