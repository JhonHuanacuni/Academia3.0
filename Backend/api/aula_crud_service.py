from django.db import connection
from .db_context import prepare_write_cursor
from . import sp_runner as sp


def _read_sp_write_result(cursor):
    return sp.read_write_result(cursor)


def listar_aulas(
    buscar=None,
    estado=None,
    ordenar_por='NOMBRE',
    direccion='ASC',
    pagina=1,
    tamanio=10,
):
    params = [buscar or None, estado or None, ordenar_por, direccion, pagina, tamanio]
    with connection.cursor() as cursor:
        if sp.is_mysql():
            return sp.call_list(cursor, 'usp_aula_listar', params)
        cursor.execute(
            """
            DECLARE @Total INT;
            EXEC dbo.usp_aula_listar
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


def obtener_aula(id_aula: str):
    return sp.call_obtain('usp_aula_obtener', id_aula)


def insertar_aula(payload: dict, id_usuario=None):
    params = [
        payload.get('IDAULA') or None,
        payload['NOMBRE'],
        payload.get('DESCRIPCION'),
        _int_or_none(payload.get('CAPACIDAD')),
        payload.get('ENLACEVIRTUAL'),
        payload.get('ENLACECUESTIONARIO'),
        payload.get('IDTUTOR') or None,
        payload.get('ESTADO', 'Activo'),
    ]
    with connection.cursor() as cursor:
        prepare_write_cursor(cursor, id_usuario, payload)
        if sp.is_mysql():
            return sp.call_write(cursor, 'usp_aula_insertar', params)
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200);
            EXEC dbo.usp_aula_insertar
                @Id=%s, @Nombre=%s, @Descripcion=%s, @Capacidad=%s,
                @EnlaceVirtual=%s, @EnlaceCuestionario=%s, @IdTutor=%s, @Estado=%s,
                @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            params,
        )
        return _read_sp_write_result(cursor)


def actualizar_aula(id_aula: str, payload: dict, id_usuario=None):
    params = [
        id_aula,
        payload['NOMBRE'],
        payload.get('DESCRIPCION'),
        _int_or_none(payload.get('CAPACIDAD')),
        payload.get('ENLACEVIRTUAL'),
        payload.get('ENLACECUESTIONARIO'),
        payload.get('IDTUTOR') or None,
        payload.get('ESTADO', 'Activo'),
    ]
    with connection.cursor() as cursor:
        prepare_write_cursor(cursor, id_usuario, payload)
        if sp.is_mysql():
            return sp.call_write(cursor, 'usp_aula_actualizar', params)
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200);
            EXEC dbo.usp_aula_actualizar
                @Id=%s, @Nombre=%s, @Descripcion=%s, @Capacidad=%s,
                @EnlaceVirtual=%s, @EnlaceCuestionario=%s, @IdTutor=%s, @Estado=%s,
                @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            params,
        )
        return _read_sp_write_result(cursor)


def eliminar_aula(id_aula: str, id_usuario=None):
    with connection.cursor() as cursor:
        prepare_write_cursor(cursor, id_usuario)
        if sp.is_mysql():
            return sp.call_write(cursor, 'usp_aula_eliminar', [id_aula])
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200);
            EXEC dbo.usp_aula_eliminar @Id=%s, @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            [id_aula],
        )
        return _read_sp_write_result(cursor)


def _int_or_none(value):
    if value is None or value == '':
        return None
    return int(value)
