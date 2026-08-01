from django.db import connection


def _cursor_rows(cursor):
    columns = [col[0] for col in cursor.description] if cursor.description else []
    return [dict(zip(columns, row)) for row in cursor.fetchall()]


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
    with connection.cursor() as cursor:
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
            [
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
            ],
        )
        data = _cursor_rows(cursor)
        total = 0
        if cursor.nextset() and cursor.description:
            row = cursor.fetchone()
            if row:
                total = int(row[0])
    return data, total


def obtener_auditoria(id_auditoria: str):
    with connection.cursor() as cursor:
        cursor.execute('EXEC dbo.usp_auditoria_obtener @Id=%s', [id_auditoria])
        rows = _cursor_rows(cursor)
    return rows[0] if rows else None


def listar_tablas_auditoria():
    with connection.cursor() as cursor:
        cursor.execute('EXEC dbo.usp_auditoria_tablas_catalogo')
        return _cursor_rows(cursor)
