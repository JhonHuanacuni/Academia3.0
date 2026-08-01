from django.db import connection
from .db_context import prepare_write_cursor


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


def listar_categorias(
    buscar=None,
    estado=None,
    ordenar_por='ORDEN',
    direccion='ASC',
    pagina=1,
    tamanio=10,
):
    with connection.cursor() as cursor:
        cursor.execute(
            """
            DECLARE @Total INT;
            EXEC dbo.usp_categoria_listar
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


def obtener_categoria(id_categoria: str):
    with connection.cursor() as cursor:
        cursor.execute('EXEC dbo.usp_categoria_obtener @Id=%s', [id_categoria])
        rows = _cursor_rows(cursor)
    return rows[0] if rows else None


def insertar_categoria(payload: dict, id_usuario=None):
    with connection.cursor() as cursor:
        prepare_write_cursor(cursor, id_usuario, payload)
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200), @Id NVARCHAR(50);
            EXEC dbo.usp_categoria_insertar
                @Nombre=%s, @Porcentaje=%s, @Orden=%s, @Estado=%s,
                @IdGenerado=@Id OUTPUT, @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            [
                payload['NOMBRE'],
                payload.get('PORCENTAJE'),
                int(payload.get('ORDEN') or 0),
                payload.get('ESTADO', 'Activo'),
            ],
        )
        return _read_sp_write_result(cursor)


def actualizar_categoria(id_categoria: str, payload: dict, id_usuario=None):
    with connection.cursor() as cursor:
        prepare_write_cursor(cursor, id_usuario, payload)
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200);
            EXEC dbo.usp_categoria_actualizar
                @Id=%s, @Nombre=%s, @Porcentaje=%s, @Orden=%s, @Estado=%s,
                @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            [
                id_categoria,
                payload['NOMBRE'],
                payload.get('PORCENTAJE'),
                int(payload.get('ORDEN') or 0),
                payload.get('ESTADO', 'Activo'),
            ],
        )
        return _read_sp_write_result(cursor)


def eliminar_categoria(id_categoria: str, id_usuario=None):
    with connection.cursor() as cursor:
        prepare_write_cursor(cursor, id_usuario)
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200);
            EXEC dbo.usp_categoria_eliminar @Id=%s, @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            [id_categoria],
        )
        return _read_sp_write_result(cursor)


def listar_categorias_activas():
    with connection.cursor() as cursor:
        cursor.execute(
            """
            SELECT IDCATEGORIA, NOMBRE, PORCENTAJE, ORDEN
            FROM CATEGORIA
            WHERE ACTIVO = 1
            ORDER BY ORDEN, NOMBRE
            """
        )
        return _cursor_rows(cursor)
