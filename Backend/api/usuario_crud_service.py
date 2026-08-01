from django.db import connection

from .db_context import prepare_write_cursor
from .models import TipoUsuario
from . import sp_runner as sp


def _read_sp_write_result(cursor):
    return sp.read_write_result(cursor)


def listar_usuarios(
    buscar=None,
    estado=None,
    ordenar_por='IDUSUARIO',
    direccion='ASC',
    pagina=1,
    tamanio=10,
):
    params = [buscar or None, estado or None, ordenar_por, direccion, pagina, tamanio]
    with connection.cursor() as cursor:
        if sp.is_mysql():
            return sp.call_list(cursor, 'usp_usuario_listar', params)
        cursor.execute(
            """
            DECLARE @Total INT;
            EXEC dbo.usp_usuario_listar
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


def obtener_usuario(id_usuario: str):
    return sp.call_obtain('usp_usuario_obtener', id_usuario)


def insertar_usuario(payload: dict, id_usuario=None):
    id_val = payload.get('IDUSUARIO') or payload.get('DNI')
    contra_val = payload.get('CONTRA') or payload.get('DNI') or payload.get('IDUSUARIO')
    rest = [
        payload['NOMBRE'],
        payload['APELLIDO'], payload['DNI'], payload['EMAIL'],
        payload['IDTIPOUSUARIO'], payload.get('ESTADO', 'Activo'),
        payload.get('FECHANACIMIENTO'), payload.get('DIRECCION'),
        payload.get('DISTRITO'), payload.get('COLEGIO'), payload.get('GRADO'),
        payload.get('TELPERSONAL'), payload.get('TELAPODERADO'),
        payload.get('NOMBREAPODERADO'), payload.get('PARENTESCO'),
        payload.get('SITUACIONACADEMICA'),
        payload.get('COMOENTERO') or None,
        payload.get('FOTO'),
    ]
    with connection.cursor() as cursor:
        prepare_write_cursor(cursor, id_usuario, payload)
        if sp.is_mysql():
            return sp.call_write_inout(cursor, 'usp_usuario_insertar', id_val, contra_val, rest)
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
            [id_val, contra_val, *rest],
        )
        return _read_sp_write_result(cursor)


def actualizar_usuario(id_usuario: str, payload: dict, id_actor=None):
    actualizar_foto = 1 if 'FOTO' in payload else 0
    params = [
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
    ]
    with connection.cursor() as cursor:
        prepare_write_cursor(cursor, id_actor, payload)
        if sp.is_mysql():
            return sp.call_write(cursor, 'usp_usuario_actualizar', params)
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
            params,
        )
        return _read_sp_write_result(cursor)


def eliminar_usuario(id_usuario: str, id_actor=None):
    row = obtener_usuario(id_usuario)
    if not row:
        return 0, 'El usuario no existe.'

    estado = (row.get('ESTADO') or '').strip()
    eliminacion_fisica = 1 if estado == 'Retirado' else 0

    with connection.cursor() as cursor:
        prepare_write_cursor(cursor, id_actor)
        if sp.is_mysql():
            return sp.call_write(cursor, 'usp_usuario_eliminar', [id_usuario, eliminacion_fisica])
        cursor.execute(
            """
            SET QUOTED_IDENTIFIER ON;
            SET ANSI_NULLS ON;
            DECLARE @R INT, @M NVARCHAR(200);
            EXEC dbo.usp_usuario_eliminar
                @Id=%s, @EliminacionFisica=%s,
                @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            [id_usuario, eliminacion_fisica],
        )
        return _read_sp_write_result(cursor)


def resetear_contra_usuario(id_usuario: str, id_actor=None):
    with connection.cursor() as cursor:
        prepare_write_cursor(cursor, id_actor)
        if sp.is_mysql():
            return sp.call_write(cursor, 'usp_usuario_resetear_contra', [id_usuario])
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200);
            EXEC dbo.usp_usuario_resetear_contra @Id=%s, @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            [id_usuario],
        )
        return _read_sp_write_result(cursor)


def listar_tipos_usuario():
    return list(
        TipoUsuario.objects.values('IDTIPOUSUARIO', 'DESCRIPCION').order_by('IDTIPOUSUARIO')
    )
