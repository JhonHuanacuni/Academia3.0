from django.db import connection
from .db_context import prepare_write_cursor
from . import sp_runner as sp
from .sql_compat import is_mysql, len_expr


def _read_sp_write_result(cursor):
    return sp.read_write_result(cursor)


def listar_conceptos(
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
            return sp.call_list(cursor, 'usp_concepto_listar', params)
        cursor.execute(
            """
            DECLARE @Total INT;
            EXEC dbo.usp_concepto_listar
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


def obtener_concepto(id_concepto: str):
    return sp.call_obtain('usp_concepto_obtener', id_concepto)


def insertar_concepto(payload: dict, id_usuario=None):
    params = [
        payload['NOMBRE'],
        payload.get('COSTO', 0),
        payload.get('FECHAINICIO'),
        payload.get('FECHAFIN'),
        payload.get('ESTADO', 'Activo'),
    ]
    with connection.cursor() as cursor:
        prepare_write_cursor(cursor, id_usuario, payload)
        if sp.is_mysql():
            row = sp.call_write_outs(
                cursor,
                'usp_concepto_insertar',
                params,
                ['@_sp_id', '@_sp_r', '@_sp_m'],
                ['IdGenerado', 'Resultado', 'Mensaje'],
            )
            return int(row[1] or 0), str(row[2] or '')
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200), @Id NVARCHAR(50);
            EXEC dbo.usp_concepto_insertar
                @Nombre=%s, @Costo=%s, @FechaInicio=%s, @FechaFin=%s, @Estado=%s,
                @IdGenerado=@Id OUTPUT, @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            params,
        )
        return _read_sp_write_result(cursor)


def actualizar_concepto(id_concepto: str, payload: dict, id_usuario=None):
    params = [
        id_concepto,
        payload['NOMBRE'],
        payload.get('COSTO', 0),
        payload.get('FECHAINICIO'),
        payload.get('FECHAFIN'),
        payload.get('ESTADO', 'Activo'),
    ]
    with connection.cursor() as cursor:
        prepare_write_cursor(cursor, id_usuario, payload)
        if sp.is_mysql():
            return sp.call_write(cursor, 'usp_concepto_actualizar', params)
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200);
            EXEC dbo.usp_concepto_actualizar
                @Id=%s, @Nombre=%s, @Costo=%s, @FechaInicio=%s, @FechaFin=%s, @Estado=%s,
                @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            params,
        )
        return _read_sp_write_result(cursor)


def eliminar_concepto(id_concepto: str, id_usuario=None):
    with connection.cursor() as cursor:
        prepare_write_cursor(cursor, id_usuario)
        if sp.is_mysql():
            return sp.call_write(cursor, 'usp_concepto_eliminar', [id_concepto])
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200);
            EXEC dbo.usp_concepto_eliminar @Id=%s, @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            [id_concepto],
        )
        return _read_sp_write_result(cursor)


def listar_conceptos_activos():
    """Solo conceptos Activo y vigentes (hoy entre FECHAINICIO y FECHAFIN)."""
    with connection.cursor() as cursor:
        if is_mysql():
            cursor.execute(
                f"""
                SELECT IDCONCEPTO, NOMBRE, COSTO, FECHAINICIO, FECHAFIN
                FROM CONCEPTOPAGOEXTRA
                WHERE ACTIVO = 1
                  AND FECHAINICIO IS NOT NULL AND {len_expr('FECHAINICIO')} = 8
                  AND FECHAFIN IS NOT NULL AND {len_expr('FECHAFIN')} = 8
                  AND CURDATE() >= STR_TO_DATE(FECHAINICIO, '%d%m%Y')
                  AND CURDATE() <= STR_TO_DATE(FECHAFIN, '%d%m%Y')
                ORDER BY NOMBRE
                """
            )
        else:
            cursor.execute(
                """
                SELECT IDCONCEPTO, NOMBRE, COSTO, FECHAINICIO, FECHAFIN
                FROM CONCEPTOPAGOEXTRA
                WHERE ACTIVO = 1
                  AND FECHAINICIO IS NOT NULL AND LEN(FECHAINICIO) = 8
                  AND FECHAFIN IS NOT NULL AND LEN(FECHAFIN) = 8
                  AND CAST(GETDATE() AS DATE) >= CONVERT(DATE,
                        SUBSTRING(FECHAINICIO, 5, 4) + SUBSTRING(FECHAINICIO, 3, 2) + SUBSTRING(FECHAINICIO, 1, 2), 112)
                  AND CAST(GETDATE() AS DATE) <= CONVERT(DATE,
                        SUBSTRING(FECHAFIN, 5, 4) + SUBSTRING(FECHAFIN, 3, 2) + SUBSTRING(FECHAFIN, 1, 2), 112)
                ORDER BY NOMBRE
                """
            )
        return sp.cursor_rows(cursor)
