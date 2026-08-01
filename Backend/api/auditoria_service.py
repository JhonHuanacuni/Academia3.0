from django.db import connection
from . import sp_runner as sp


def listar_auditoria(
    buscar=None,
    tabla=None,
    accion=None,
    id_usuario=None,
    fecha_desde=None,
    fecha_hasta=None,
    ordenar_por='FECHA',
    direccion='DESC',
    pagina=1,
    tamanio=10,
):
    params = [
        buscar or None,
        tabla or None,
        accion or None,
        id_usuario or None,
        fecha_desde or None,
        fecha_hasta or None,
        ordenar_por,
        direccion,
        pagina,
        tamanio,
    ]
    with connection.cursor() as cursor:
        if sp.is_mysql():
            return sp.call_list(cursor, 'usp_auditoria_listar', params)
        cursor.execute(
            """
            DECLARE @Total INT;
            EXEC dbo.usp_auditoria_listar
                @Buscar=%s, @Tabla=%s, @Accion=%s, @IdUsuario=%s,
                @FechaDesde=%s, @FechaHasta=%s,
                @OrdenarPor=%s, @Direccion=%s,
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


def obtener_auditoria(id_auditoria: str):
    return sp.call_obtain('usp_auditoria_obtener', id_auditoria)


def listar_tablas_auditoria():
    with connection.cursor() as cursor:
        if sp.is_mysql():
            return sp.call_simple(cursor, 'usp_auditoria_tablas_catalogo', [])
        cursor.execute('EXEC dbo.usp_auditoria_tablas_catalogo')
        return sp.cursor_rows(cursor)
