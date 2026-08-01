from django.db import connection
from .db_context import prepare_write_cursor
from .categoria_crud_service import listar_categorias_activas
from . import sp_runner as sp


def _read_sp_write_result(cursor):
    return sp.read_write_result(cursor)


def listar_materias(
    buscar=None,
    estado=None,
    id_categoria=None,
    ordenar_por='NOMBRE',
    direccion='ASC',
    pagina=1,
    tamanio=10,
):
    params = [
        buscar or None,
        estado or None,
        id_categoria or None,
        ordenar_por,
        direccion,
        pagina,
        tamanio,
    ]
    with connection.cursor() as cursor:
        if sp.is_mysql():
            return sp.call_list(cursor, 'usp_materia_listar', params)
        cursor.execute(
            """
            DECLARE @Total INT;
            EXEC dbo.usp_materia_listar
                @Buscar=%s, @Estado=%s, @IdCategoria=%s, @OrdenarPor=%s, @Direccion=%s,
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


def obtener_materia(id_materia: str):
    return sp.call_obtain('usp_materia_obtener', id_materia)


def insertar_materia(payload: dict, id_usuario=None):
    params = [
        payload.get('CODIGO'),
        payload['NOMBRE'],
        payload.get('IDCATEGORIA') or None,
        payload.get('ESTADO', 'Activo'),
    ]
    with connection.cursor() as cursor:
        prepare_write_cursor(cursor, id_usuario, payload)
        if sp.is_mysql():
            return sp.call_write(cursor, 'usp_materia_insertar', params)
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200), @Id NVARCHAR(50);
            EXEC dbo.usp_materia_insertar
                @Codigo=%s, @Nombre=%s, @IdCategoria=%s, @Estado=%s,
                @IdGenerado=@Id OUTPUT, @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            params,
        )
        return _read_sp_write_result(cursor)


def actualizar_materia(id_materia: str, payload: dict, id_usuario=None):
    params = [
        id_materia,
        payload.get('CODIGO'),
        payload['NOMBRE'],
        payload.get('IDCATEGORIA') or None,
        payload.get('ESTADO', 'Activo'),
    ]
    with connection.cursor() as cursor:
        prepare_write_cursor(cursor, id_usuario, payload)
        if sp.is_mysql():
            return sp.call_write(cursor, 'usp_materia_actualizar', params)
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200);
            EXEC dbo.usp_materia_actualizar
                @Id=%s, @Codigo=%s, @Nombre=%s, @IdCategoria=%s, @Estado=%s,
                @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            params,
        )
        return _read_sp_write_result(cursor)


def eliminar_materia(id_materia: str, id_usuario=None):
    with connection.cursor() as cursor:
        prepare_write_cursor(cursor, id_usuario)
        if sp.is_mysql():
            return sp.call_write(cursor, 'usp_materia_eliminar', [id_materia])
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200);
            EXEC dbo.usp_materia_eliminar @Id=%s, @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            [id_materia],
        )
        return _read_sp_write_result(cursor)


def listar_catalogos_materia():
    cats = listar_categorias_activas()
    return {
        'categorias': [
            {'value': c['IDCATEGORIA'], 'label': c['NOMBRE']}
            for c in cats
        ],
    }
