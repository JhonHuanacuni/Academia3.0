from django.db import connection
from .db_context import prepare_write_cursor
from .models import Aula, Materia
from . import sp_runner as sp


def _read_sp_write_result(cursor):
    return sp.read_write_result(cursor)


def listar_clases_grabadas(
    buscar=None,
    estado=None,
    id_materia=None,
    id_aula=None,
    id_usuario=None,
    ordenar_por='FECHASUBIDA',
    direccion='DESC',
    pagina=1,
    tamanio=10,
):
    params = [
        buscar or None,
        estado or None,
        id_materia or None,
        id_aula or None,
        id_usuario or None,
        ordenar_por,
        direccion,
        pagina,
        tamanio,
    ]
    with connection.cursor() as cursor:
        if sp.is_mysql():
            return sp.call_list(cursor, 'usp_clase_grabada_listar', params)
        cursor.execute(
            """
            DECLARE @Total INT;
            EXEC dbo.usp_clase_grabada_listar
                @Buscar=%s, @Estado=%s, @IdMateria=%s, @IdAula=%s, @IdUsuario=%s,
                @OrdenarPor=%s, @Direccion=%s, @Pagina=%s, @TamanioPagina=%s,
                @TotalRegistros=@Total OUTPUT;
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


def listar_materias_clase_grabada(id_aula=None, id_usuario=None):
    with connection.cursor() as cursor:
        if sp.is_mysql():
            return sp.call_simple(
                cursor,
                'usp_clase_grabada_materias',
                [id_aula or None, id_usuario or None],
            )
        cursor.execute(
            'EXEC dbo.usp_clase_grabada_materias @IdAula=%s, @IdUsuario=%s',
            [id_aula or None, id_usuario or None],
        )
        return sp.cursor_rows(cursor)


def obtener_clase_grabada(id_clase: str):
    return sp.call_obtain('usp_clase_grabada_obtener', id_clase)


def insertar_clase_grabada(payload: dict, id_usuario=None):
    params = [
        payload['IDAULA'],
        payload['IDMATERIA'],
        payload['ENLACE'],
        payload['DETALLES'],
        payload.get('ESTADO', 'Activo'),
    ]
    with connection.cursor() as cursor:
        prepare_write_cursor(cursor, id_usuario, payload)
        if sp.is_mysql():
            row = sp.call_write_outs(
                cursor,
                'usp_clase_grabada_insertar',
                params,
                ['@_sp_id', '@_sp_r', '@_sp_m'],
                ['IdGenerado', 'Resultado', 'Mensaje'],
            )
            return row[0], int(row[1] or 0), str(row[2] or '')
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200), @Id NVARCHAR(50);
            EXEC dbo.usp_clase_grabada_insertar
                @IdAula=%s, @IdMateria=%s, @Enlace=%s, @Detalles=%s, @Estado=%s,
                @IdGenerado=@Id OUTPUT, @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @Id AS IdGenerado, @R AS Resultado, @M AS Mensaje;
            """,
            params,
        )
        row = cursor.fetchone()
        if row:
            return row[0], int(row[1] or 0), str(row[2] or '')
        return None, 0, 'Error al insertar'


def actualizar_clase_grabada(id_clase: str, payload: dict, id_usuario=None):
    params = [
        id_clase,
        payload['IDAULA'],
        payload['IDMATERIA'],
        payload['ENLACE'],
        payload['DETALLES'],
        payload.get('ESTADO', 'Activo'),
    ]
    with connection.cursor() as cursor:
        prepare_write_cursor(cursor, id_usuario, payload)
        if sp.is_mysql():
            return sp.call_write(cursor, 'usp_clase_grabada_actualizar', params)
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200);
            EXEC dbo.usp_clase_grabada_actualizar
                @Id=%s, @IdAula=%s, @IdMateria=%s, @Enlace=%s, @Detalles=%s, @Estado=%s,
                @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            params,
        )
        return _read_sp_write_result(cursor)


def eliminar_clase_grabada(id_clase: str, id_usuario=None):
    with connection.cursor() as cursor:
        prepare_write_cursor(cursor, id_usuario)
        if sp.is_mysql():
            return sp.call_write(cursor, 'usp_clase_grabada_eliminar', [id_clase])
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200);
            EXEC dbo.usp_clase_grabada_eliminar @Id=%s, @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            [id_clase],
        )
        return _read_sp_write_result(cursor)


def listar_catalogos_clase_grabada():
    aulas = list(
        Aula.objects.filter(ACTIVO=True).order_by('NOMBRE').values('IDAULA', 'NOMBRE')
    )
    materias = list(
        Materia.objects.filter(ACTIVO=True).order_by('NOMBRE').values('IDMATERIA', 'NOMBRE')
    )
    return {'aulas': aulas, 'materias': materias}
