from django.db import connection
from .db_context import prepare_write_cursor
from . import sp_runner as sp


def _read_sp_write_result(cursor):
    return sp.read_write_result(cursor)


def listar_planes(
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
            return sp.call_list(cursor, 'usp_plan_listar', params)
        cursor.execute(
            """
            DECLARE @Total INT;
            EXEC dbo.usp_plan_listar
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


def obtener_plan(id_plan: str):
    return sp.call_obtain('usp_plan_obtener', id_plan)


def _normalizar_hora_entrada(val):
    if val is None:
        return '08:00:00'
    s = str(val).strip()
    if not s:
        return '08:00:00'
    if len(s) == 5 and s[2] == ':':
        return f'{s}:00'
    return s


def insertar_plan(payload: dict, id_usuario=None):
    params = [
        payload.get('IDPLAN') or None,
        payload['NOMBRE'],
        payload.get('DESCRIPCION'),
        payload.get('COSTOMENSUAL'),
        payload.get('DIASASISTENCIA', 63),
        payload.get('IDTURNO') or None,
        _normalizar_hora_entrada(payload.get('HORAENTRADA')),
        int(payload.get('TIEMPOEXTRA') or 0),
        payload.get('ESTADO', 'Activo'),
    ]
    with connection.cursor() as cursor:
        prepare_write_cursor(cursor, id_usuario, payload)
        if sp.is_mysql():
            return sp.call_write(cursor, 'usp_plan_insertar', params)
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200);
            EXEC dbo.usp_plan_insertar
                @Id=%s, @Nombre=%s, @Descripcion=%s, @CostoMensual=%s,
                @DiasAsistencia=%s, @IdTurno=%s, @HoraEntrada=%s, @TiempoExtra=%s, @Estado=%s,
                @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            params,
        )
        return _read_sp_write_result(cursor)


def actualizar_plan(id_plan: str, payload: dict, id_usuario=None):
    params = [
        id_plan,
        payload['NOMBRE'],
        payload.get('DESCRIPCION'),
        payload.get('COSTOMENSUAL'),
        payload.get('DIASASISTENCIA', 63),
        payload.get('IDTURNO') or None,
        _normalizar_hora_entrada(payload.get('HORAENTRADA')),
        int(payload.get('TIEMPOEXTRA') or 0),
        payload.get('ESTADO', 'Activo'),
    ]
    with connection.cursor() as cursor:
        prepare_write_cursor(cursor, id_usuario, payload)
        if sp.is_mysql():
            return sp.call_write(cursor, 'usp_plan_actualizar', params)
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200);
            EXEC dbo.usp_plan_actualizar
                @Id=%s, @Nombre=%s, @Descripcion=%s, @CostoMensual=%s,
                @DiasAsistencia=%s, @IdTurno=%s, @HoraEntrada=%s, @TiempoExtra=%s, @Estado=%s,
                @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            params,
        )
        return _read_sp_write_result(cursor)


def listar_catalogos_plan():
    with connection.cursor() as cursor:
        cursor.execute('SELECT IDTURNO, DESCRIPCION FROM TURNO ORDER BY DESCRIPCION')
        return {'turnos': sp.cursor_rows(cursor)}


def eliminar_plan(id_plan: str, id_usuario=None):
    with connection.cursor() as cursor:
        prepare_write_cursor(cursor, id_usuario)
        if sp.is_mysql():
            return sp.call_write(cursor, 'usp_plan_eliminar', [id_plan])
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200);
            EXEC dbo.usp_plan_eliminar @Id=%s, @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            [id_plan],
        )
        return _read_sp_write_result(cursor)
