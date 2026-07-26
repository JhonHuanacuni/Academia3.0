from django.db import connection
from .models import TipoUsuario


def _cursor_rows(cursor):
    columns = [col[0] for col in cursor.description] if cursor.description else []
    return [dict(zip(columns, row)) for row in cursor.fetchall()]


def _read_sp_write_result(cursor):
    """Lee @Resultado y @Mensaje del último result set."""
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


def listar_usuarios(
    buscar=None,
    estado=None,
    ordenar_por='IDUSUARIO',
    direccion='ASC',
    pagina=1,
    tamanio=10,
):
    with connection.cursor() as cursor:
        cursor.execute(
            """
            DECLARE @Total INT;
            EXEC dbo.usp_usuario_listar
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


def obtener_usuario(id_usuario: str):
    with connection.cursor() as cursor:
        cursor.execute('EXEC dbo.usp_usuario_obtener @Id=%s', [id_usuario])
        rows = _cursor_rows(cursor)
    return rows[0] if rows else None


def insertar_usuario(payload: dict):
    with connection.cursor() as cursor:
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200);
            EXEC dbo.usp_usuario_insertar
                @Id=%s, @Contra=%s, @Nombre=%s, @Apellido=%s, @Dni=%s, @Email=%s,
                @IdTipoUsuario=%s, @Estado=%s, @FechaNacimiento=%s, @Direccion=%s,
                @Distrito=%s, @Colegio=%s, @Grado=%s, @TelPersonal=%s,
                @TelApoderado=%s, @NombreApoderado=%s, @Parentesco=%s,
                @SituacionAcademica=%s, @ComoEntero=%s, @Foto=%s,
                @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            [
                payload['IDUSUARIO'], payload['CONTRA'], payload['NOMBRE'],
                payload['APELLIDO'], payload['DNI'], payload['EMAIL'],
                payload['IDTIPOUSUARIO'], payload.get('ESTADO', 'Activo'),
                payload.get('FECHANACIMIENTO'), payload.get('DIRECCION'),
                payload.get('DISTRITO'), payload.get('COLEGIO'), payload.get('GRADO'),
                payload.get('TELPERSONAL'), payload.get('TELAPODERADO'),
                payload.get('NOMBREAPODERADO'), payload.get('PARENTESCO'),
                payload.get('SITUACIONACADEMICA'),
                payload.get('COMOENTERO') or None,
                payload.get('FOTO'),
            ],
        )
        return _read_sp_write_result(cursor)


def actualizar_usuario(id_usuario: str, payload: dict):
    actualizar_foto = 1 if 'FOTO' in payload else 0
    with connection.cursor() as cursor:
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200);
            EXEC dbo.usp_usuario_actualizar
                @Id=%s, @Contra=%s, @Nombre=%s, @Apellido=%s, @Dni=%s, @Email=%s,
                @IdTipoUsuario=%s, @Estado=%s, @FechaNacimiento=%s, @Direccion=%s,
                @Distrito=%s, @Colegio=%s, @Grado=%s, @TelPersonal=%s,
                @TelApoderado=%s, @NombreApoderado=%s, @Parentesco=%s,
                @SituacionAcademica=%s, @ComoEntero=%s, @Foto=%s, @ActualizarFoto=%s,
                @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            [
                id_usuario,
                payload.get('CONTRA') or None,
                payload['NOMBRE'], payload['APELLIDO'], payload['DNI'],
                payload['EMAIL'], payload['IDTIPOUSUARIO'], payload['ESTADO'],
                payload.get('FECHANACIMIENTO'), payload.get('DIRECCION'),
                payload.get('DISTRITO'), payload.get('COLEGIO'), payload.get('GRADO'),
                payload.get('TELPERSONAL'), payload.get('TELAPODERADO'),
                payload.get('NOMBREAPODERADO'), payload.get('PARENTESCO'),
                payload.get('SITUACIONACADEMICA'),
                payload.get('COMOENTERO') or None,
                payload.get('FOTO'),
                actualizar_foto,
            ],
        )
        return _read_sp_write_result(cursor)


def eliminar_usuario(id_usuario: str):
    with connection.cursor() as cursor:
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200);
            EXEC dbo.usp_usuario_eliminar @Id=%s, @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            [id_usuario],
        )
        return _read_sp_write_result(cursor)


def listar_tipos_usuario():
    return list(
        TipoUsuario.objects.values('IDTIPOUSUARIO', 'DESCRIPCION').order_by('IDTIPOUSUARIO')
    )
