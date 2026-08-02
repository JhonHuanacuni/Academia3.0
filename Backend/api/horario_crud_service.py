from pathlib import Path
from django.conf import settings
from django.db import connection
from .db_context import prepare_write_cursor
from . import sp_runner as sp


def _read_sp_write_result(cursor, extra_cols=None):
    resultado, mensaje = 0, 'Error desconocido'
    extras = {k: None for k in (extra_cols or [])}
    while True:
        if cursor.description:
            row = cursor.fetchone()
            if row:
                cols = [c[0].lower() for c in cursor.description]
                data = dict(zip(cols, row))
                resultado = data.get('resultado', resultado)
                mensaje = data.get('mensaje', mensaje)
                for k in extras:
                    if k.lower() in data:
                        extras[k] = data[k.lower()]
        if not cursor.nextset():
            break
    return int(resultado or 0), str(mensaje or ''), extras


def _media_url(rel_path):
    if not rel_path:
        return None
    rel = str(rel_path).replace('\\', '/').lstrip('/')
    return f'/media/{rel}'


def enriquecer_urls(row):
    if not row:
        return row
    out = dict(row)
    out['URLPREVIEW'] = _media_url(out.get('URLIMAGEN'))
    return out


def listar_horarios(
    buscar=None,
    estado=None,
    ordenar_por='FECHASUBIDA',
    direccion='DESC',
    pagina=1,
    tamanio=10,
):
    params = [buscar or None, estado or None, ordenar_por, direccion, pagina, tamanio]
    with connection.cursor() as cursor:
        if sp.is_mysql():
            data, total = sp.call_list(cursor, 'usp_horario_listar', params)
            return [enriquecer_urls(r) for r in data], total
        cursor.execute(
            """
            DECLARE @Total INT;
            EXEC dbo.usp_horario_listar
                @Buscar=%s, @Estado=%s, @OrdenarPor=%s, @Direccion=%s,
                @Pagina=%s, @TamanioPagina=%s, @TotalRegistros=@Total OUTPUT;
            SELECT @Total AS TotalRegistros;
            """,
            params,
        )
        data = [enriquecer_urls(r) for r in sp.cursor_rows(cursor)]
        total = 0
        if cursor.nextset() and cursor.description:
            row = cursor.fetchone()
            if row:
                total = int(row[0])
    return data, total


def obtener_horario(id_horario: str):
    with connection.cursor() as cursor:
        if sp.is_mysql():
            rows = sp.call_simple(cursor, 'usp_horario_obtener', [id_horario])
            aulas = []
            if cursor.nextset():
                aulas = [r['IDAULA'] for r in sp.cursor_rows(cursor)]
        else:
            cursor.execute('EXEC dbo.usp_horario_obtener @Id=%s', [id_horario])
            rows = sp.cursor_rows(cursor)
            aulas = []
            if cursor.nextset():
                aulas = [r['IDAULA'] for r in sp.cursor_rows(cursor)]
    if not rows:
        return None
    out = enriquecer_urls(rows[0])
    out['AULAS'] = aulas
    return out


def insertar_horario(payload: dict, id_usuario=None):
    params = [
        payload['TITULO'],
        payload.get('DESCRIPCION') or None,
        payload.get('URLIMAGEN') or None,
        payload.get('FECHASUBIDA') or None,
        payload.get('ESTADO', 'Activo'),
        payload.get('AULAS_CSV') or None,
    ]
    with connection.cursor() as cursor:
        prepare_write_cursor(cursor, id_usuario, payload)
        if sp.is_mysql():
            row = sp.call_write_outs(
                cursor,
                'usp_horario_insertar',
                params,
                ['@_sp_r', '@_sp_m', '@_sp_id'],
                ['Resultado', 'Mensaje', 'IdGenerado'],
            )
            return int(row[0] or 0), str(row[1] or ''), row[2]
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200), @Id NVARCHAR(50);
            EXEC dbo.usp_horario_insertar
                @Titulo=%s, @Descripcion=%s, @UrlImagen=%s,
                @FechaSubida=%s, @Estado=%s, @AulasCsv=%s,
                @IdGenerado=@Id OUTPUT, @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje, @Id AS IdGenerado;
            """,
            params,
        )
        ok, mensaje, extras = _read_sp_write_result(cursor, extra_cols=['idgenerado'])
        return ok, mensaje, extras.get('idgenerado')


def actualizar_horario(id_horario: str, payload: dict, id_usuario=None):
    params = [
        id_horario,
        payload['TITULO'],
        payload.get('DESCRIPCION') or None,
        payload.get('URLIMAGEN') or None,
        payload.get('ESTADO', 'Activo'),
        payload.get('AULAS_CSV') or None,
    ]
    with connection.cursor() as cursor:
        prepare_write_cursor(cursor, id_usuario, payload)
        if sp.is_mysql():
            ok, mensaje = sp.call_write(cursor, 'usp_horario_actualizar', params)
            return ok, mensaje
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200);
            EXEC dbo.usp_horario_actualizar
                @Id=%s, @Titulo=%s, @Descripcion=%s, @UrlImagen=%s,
                @Estado=%s, @AulasCsv=%s,
                @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            params,
        )
        ok, mensaje, _ = _read_sp_write_result(cursor)
        return ok, mensaje


def eliminar_horario(id_horario: str, id_usuario=None):
    with connection.cursor() as cursor:
        prepare_write_cursor(cursor, id_usuario)
        if sp.is_mysql():
            ok, mensaje = sp.call_write(cursor, 'usp_horario_eliminar', [id_horario])
            return ok, mensaje
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200);
            EXEC dbo.usp_horario_eliminar @Id=%s, @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            [id_horario],
        )
        ok, mensaje, _ = _read_sp_write_result(cursor)
        return ok, mensaje


def listar_catalogos_horario():
    with connection.cursor() as cursor:
        cursor.execute(
            """
            SELECT IDAULA, NOMBRE
            FROM AULA
            WHERE ACTIVO = 1
            ORDER BY NOMBRE
            """
        )
        aulas = sp.cursor_rows(cursor)
    return {'aulas': aulas}


def carpeta_horario(id_horario: str) -> Path:
    path = Path(settings.MEDIA_ROOT) / 'horarios' / str(id_horario)
    path.mkdir(parents=True, exist_ok=True)
    return path


def guardar_imagen(id_horario: str, uploaded_file) -> str:
    folder = carpeta_horario(id_horario)
    name = (uploaded_file.name or 'imagen.jpg').lower()
    ext = Path(name).suffix
    if ext not in ('.jpg', '.jpeg', '.png', '.webp', '.gif'):
        ext = '.jpg'
    dest = folder / f'imagen{ext}'
    with dest.open('wb') as fh:
        for chunk in uploaded_file.chunks():
            fh.write(chunk)
    return f'horarios/{id_horario}/imagen{ext}'


def borrar_archivos_horario(id_horario: str):
    folder = Path(settings.MEDIA_ROOT) / 'horarios' / str(id_horario)
    if not folder.exists():
        return
    for f in folder.iterdir():
        try:
            f.unlink()
        except OSError:
            pass
    try:
        folder.rmdir()
    except OSError:
        pass
