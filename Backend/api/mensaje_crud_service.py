from django.db import connection
from .db_context import prepare_write_cursor
from . import sp_runner as sp


def _read_sp_write_result(cursor):
    return sp.read_write_result(cursor)


def listar_mensajes(
    buscar=None,
    estado=None,
    destinatario=None,
    ordenar_por='FECHACREACION',
    direccion='DESC',
    pagina=1,
    tamanio=10,
):
    params = [
        buscar or None,
        estado or None,
        destinatario or None,
        ordenar_por,
        direccion,
        pagina,
        tamanio,
    ]
    with connection.cursor() as cursor:
        return sp.call_list(cursor, 'usp_mensaje_listar', params)


def obtener_mensaje(id_mensaje: str):
    return sp.call_obtain('usp_mensaje_obtener', id_mensaje)


def insertar_mensaje(payload: dict, id_usuario=None):
    params = [
        (payload.get('TITULO') or '').strip(),
        (payload.get('MENSAJE') or '').strip(),
        payload.get('FECHAINICIO'),
        payload.get('FECHAFIN'),
        payload.get('DESTINATARIO') or 'Estudiantes',
        payload.get('ESTADO') or 'Activo',
    ]
    with connection.cursor() as cursor:
        prepare_write_cursor(cursor, id_usuario, payload)
        row = sp.call_write_outs(
            cursor,
            'usp_mensaje_insertar',
            params,
            ['@_sp_id', '@_sp_r', '@_sp_m'],
            ['IdGenerado', 'Resultado', 'Mensaje'],
        )
        return int(row[1] or 0), str(row[2] or '')


def actualizar_mensaje(id_mensaje: str, payload: dict, id_usuario=None):
    params = [
        id_mensaje,
        (payload.get('TITULO') or '').strip(),
        (payload.get('MENSAJE') or '').strip(),
        payload.get('FECHAINICIO'),
        payload.get('FECHAFIN'),
        payload.get('DESTINATARIO') or 'Estudiantes',
        payload.get('ESTADO') or 'Activo',
    ]
    with connection.cursor() as cursor:
        prepare_write_cursor(cursor, id_usuario, payload)
        return sp.call_write(cursor, 'usp_mensaje_actualizar', params)


def eliminar_mensaje(id_mensaje: str, id_usuario=None):
    with connection.cursor() as cursor:
        prepare_write_cursor(cursor, id_usuario)
        return sp.call_write(cursor, 'usp_mensaje_eliminar', [id_mensaje])


def listar_mensajes_vigentes(id_tipo_usuario: str):
    tipo = str(id_tipo_usuario or '').strip() or '1'
    with connection.cursor() as cursor:
        return sp.call_simple(cursor, 'usp_mensaje_vigentes', [tipo])
