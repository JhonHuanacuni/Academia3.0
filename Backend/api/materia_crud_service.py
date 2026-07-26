from django.db import connection
from .categoria_crud_service import listar_categorias_activas


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


def listar_materias(
    buscar=None,
    estado=None,
    id_categoria=None,
    ordenar_por='NOMBRE',
    direccion='ASC',
    pagina=1,
    tamanio=10,
):
    with connection.cursor() as cursor:
        cursor.execute(
            """
            DECLARE @Total INT;
            EXEC dbo.usp_materia_listar
                @Buscar=%s, @Estado=%s, @IdCategoria=%s, @OrdenarPor=%s, @Direccion=%s,
                @Pagina=%s, @TamanioPagina=%s, @TotalRegistros=@Total OUTPUT;
            SELECT @Total AS TotalRegistros;
            """,
            [
                buscar or None,
                estado or None,
                id_categoria or None,
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


def obtener_materia(id_materia: str):
    with connection.cursor() as cursor:
        cursor.execute('EXEC dbo.usp_materia_obtener @Id=%s', [id_materia])
        rows = _cursor_rows(cursor)
    return rows[0] if rows else None


def insertar_materia(payload: dict):
    with connection.cursor() as cursor:
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200), @Id NVARCHAR(50);
            EXEC dbo.usp_materia_insertar
                @Codigo=%s, @Nombre=%s, @IdCategoria=%s, @Estado=%s,
                @IdGenerado=@Id OUTPUT, @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            [
                payload.get('CODIGO'),
                payload['NOMBRE'],
                payload.get('IDCATEGORIA') or None,
                payload.get('ESTADO', 'Activo'),
            ],
        )
        return _read_sp_write_result(cursor)


def actualizar_materia(id_materia: str, payload: dict):
    with connection.cursor() as cursor:
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200);
            EXEC dbo.usp_materia_actualizar
                @Id=%s, @Codigo=%s, @Nombre=%s, @IdCategoria=%s, @Estado=%s,
                @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            [
                id_materia,
                payload.get('CODIGO'),
                payload['NOMBRE'],
                payload.get('IDCATEGORIA') or None,
                payload.get('ESTADO', 'Activo'),
            ],
        )
        return _read_sp_write_result(cursor)


def eliminar_materia(id_materia: str):
    with connection.cursor() as cursor:
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
