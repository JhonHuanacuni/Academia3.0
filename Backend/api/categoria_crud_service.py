from django.db import connection
from .db_context import prepare_write_cursor
from . import sp_runner as sp


def _read_sp_write_result(cursor):
    return sp.read_write_result(cursor)


def listar_categorias(
    buscar=None,
    estado=None,
    ordenar_por='ORDEN',
    direccion='ASC',
    pagina=1,
    tamanio=10,
):
    params = [buscar or None, estado or None, ordenar_por, direccion, pagina, tamanio]
    with connection.cursor() as cursor:
        if sp.is_mysql():
            return sp.call_list(cursor, 'usp_categoria_listar', params)
        cursor.execute(
            """
            DECLARE @Total INT;
            EXEC dbo.usp_categoria_listar
                @Buscar=%s, @Estado=%s, @OrdenarPor=%s, @Direccion=%s,
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


def obtener_categoria(id_categoria: str):
    return sp.call_obtain('usp_categoria_obtener', id_categoria)


def insertar_categoria(payload: dict, id_usuario=None):
    params = [
        payload['NOMBRE'],
        payload.get('PORCENTAJE'),
        int(payload.get('ORDEN') or 0),
        payload.get('ESTADO', 'Activo'),
    ]
    with connection.cursor() as cursor:
        prepare_write_cursor(cursor, id_usuario, payload)
        if sp.is_mysql():
            return sp.call_write(cursor, 'usp_categoria_insertar', params)
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200), @Id NVARCHAR(50);
            EXEC dbo.usp_categoria_insertar
                @Nombre=%s, @Porcentaje=%s, @Orden=%s, @Estado=%s,
                @IdGenerado=@Id OUTPUT, @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            params,
        )
        return _read_sp_write_result(cursor)


def actualizar_categoria(id_categoria: str, payload: dict, id_usuario=None):
    params = [
        id_categoria,
        payload['NOMBRE'],
        payload.get('PORCENTAJE'),
        int(payload.get('ORDEN') or 0),
        payload.get('ESTADO', 'Activo'),
    ]
    with connection.cursor() as cursor:
        prepare_write_cursor(cursor, id_usuario, payload)
        if sp.is_mysql():
            return sp.call_write(cursor, 'usp_categoria_actualizar', params)
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200);
            EXEC dbo.usp_categoria_actualizar
                @Id=%s, @Nombre=%s, @Porcentaje=%s, @Orden=%s, @Estado=%s,
                @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            params,
        )
        return _read_sp_write_result(cursor)


def eliminar_categoria(id_categoria: str, id_usuario=None):
    with connection.cursor() as cursor:
        prepare_write_cursor(cursor, id_usuario)
        if sp.is_mysql():
            return sp.call_write(cursor, 'usp_categoria_eliminar', [id_categoria])
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
        return sp.cursor_rows(cursor)
