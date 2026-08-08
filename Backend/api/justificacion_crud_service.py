from django.db import connection
from .db_context import prepare_write_cursor
from . import sp_runner as sp


def _read_sp_write_result(cursor):
    return sp.read_write_result(cursor)


def listar_justificaciones(
    buscar=None,
    id_tutor=None,
    id_plan=None,
    fecha_desde=None,
    fecha_hasta=None,
    id_turno=None,
    pagina=1,
    tamanio=10,
):
    params = [
        buscar or None,
        id_tutor or None,
        id_plan or None,
        fecha_desde or None,
        fecha_hasta or None,
        id_turno or None,
        pagina,
        tamanio,
    ]
    with connection.cursor() as cursor:
        if sp.is_mysql():
            return sp.call_list(cursor, 'usp_justificacion_listar', params)
        cursor.execute(
            """
            DECLARE @Total INT;
            EXEC dbo.usp_justificacion_listar
                @Buscar=%s, @IdTutor=%s, @IdPlan=%s, @FechaDesde=%s, @FechaHasta=%s,
                @IdTurno=%s, @Pagina=%s, @TamanioPagina=%s, @TotalRegistros=@Total OUTPUT;
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


def obtener_justificacion(id_justificacion: str):
    return sp.call_obtain('usp_justificacion_obtener', id_justificacion)


def insertar_justificacion(payload: dict, id_usuario=None):
    params = [
        payload['IDUSUARIO'],
        payload['FECHA'],
        payload.get('IDREGISTRADOR') or None,
        payload.get('OBSERVACION'),
    ]
    with connection.cursor() as cursor:
        prepare_write_cursor(cursor, id_usuario, payload)
        if sp.is_mysql():
            return sp.call_write(cursor, 'usp_justificacion_insertar', params)
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200);
            EXEC dbo.usp_justificacion_insertar
                @IdUsuario=%s, @Fecha=%s, @IdRegistrador=%s, @Observacion=%s,
                @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            params,
        )
        return _read_sp_write_result(cursor)


def actualizar_justificacion(id_justificacion: str, payload: dict, id_usuario=None):
    params = [
        id_justificacion,
        payload['IDUSUARIO'],
        payload['FECHA'],
        payload.get('OBSERVACION'),
    ]
    with connection.cursor() as cursor:
        prepare_write_cursor(cursor, id_usuario, payload)
        if sp.is_mysql():
            return sp.call_write(cursor, 'usp_justificacion_actualizar', params)
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200);
            EXEC dbo.usp_justificacion_actualizar
                @Id=%s, @IdUsuario=%s, @Fecha=%s, @Observacion=%s,
                @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            params,
        )
        return _read_sp_write_result(cursor)


def eliminar_justificacion(id_justificacion: str, id_usuario=None):
    with connection.cursor() as cursor:
        prepare_write_cursor(cursor, id_usuario)
        if sp.is_mysql():
            return sp.call_write(cursor, 'usp_justificacion_eliminar', [id_justificacion])
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200);
            EXEC dbo.usp_justificacion_eliminar @Id=%s, @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            [id_justificacion],
        )
        return _read_sp_write_result(cursor)
