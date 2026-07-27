from django.db import connection


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


def listar_aulas(
    buscar=None,
    estado=None,
    ordenar_por='NOMBRE',
    direccion='ASC',
    pagina=1,
    tamanio=10,
):
    with connection.cursor() as cursor:
        cursor.execute(
            """
            DECLARE @Total INT;
            EXEC dbo.usp_aula_listar
                @Buscar=%s, @Estado=%s, @OrdenarPor=%s, @Direccion=%s,
                @Pagina=%s, @TamanioPagina=%s, @TotalRegistros=@Total OUTPUT;
            SELECT @Total AS TotalRegistros;
            """,
            [buscar or None, estado or None, ordenar_por, direccion, pagina, tamanio],
        )
        data = _cursor_rows(cursor)
        total = 0
        if cursor.nextset() and cursor.description:
            row = cursor.fetchone()
            if row:
                total = int(row[0])
    return data, total


def obtener_aula(id_aula: str):
    with connection.cursor() as cursor:
        cursor.execute('EXEC dbo.usp_aula_obtener @Id=%s', [id_aula])
        rows = _cursor_rows(cursor)
    return rows[0] if rows else None


def insertar_aula(payload: dict):
    with connection.cursor() as cursor:
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200);
            EXEC dbo.usp_aula_insertar
                @Id=%s, @Nombre=%s, @Descripcion=%s, @Capacidad=%s,
                @EnlaceVirtual=%s, @EnlaceCuestionario=%s, @Estado=%s,
                @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            [
                payload.get('IDAULA') or None,
                payload['NOMBRE'],
                payload.get('DESCRIPCION'),
                _int_or_none(payload.get('CAPACIDAD')),
                payload.get('ENLACEVIRTUAL'),
                payload.get('ENLACECUESTIONARIO'),
                payload.get('ESTADO', 'Activo'),
            ],
        )
        return _read_sp_write_result(cursor)


def actualizar_aula(id_aula: str, payload: dict):
    with connection.cursor() as cursor:
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200);
            EXEC dbo.usp_aula_actualizar
                @Id=%s, @Nombre=%s, @Descripcion=%s, @Capacidad=%s,
                @EnlaceVirtual=%s, @EnlaceCuestionario=%s, @Estado=%s,
                @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            [
                id_aula,
                payload['NOMBRE'],
                payload.get('DESCRIPCION'),
                _int_or_none(payload.get('CAPACIDAD')),
                payload.get('ENLACEVIRTUAL'),
                payload.get('ENLACECUESTIONARIO'),
                payload.get('ESTADO', 'Activo'),
            ],
        )
        return _read_sp_write_result(cursor)


def eliminar_aula(id_aula: str):
    with connection.cursor() as cursor:
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
