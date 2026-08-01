from pathlib import Path
from django.conf import settings
from django.db import connection
from .db_context import prepare_write_cursor


def _cursor_rows(cursor):
    columns = [col[0] for col in cursor.description] if cursor.description else []
    return [dict(zip(columns, row)) for row in cursor.fetchall()]


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
    out['URLPDF'] = _media_url(out.get('URLCONTENIDO'))
    out['URLPORTADA'] = _media_url(out.get('IMGPORTADA'))
    return out


def listar_libros(
    buscar=None,
    estado=None,
    ordenar_por='FECHASUBIDA',
    direccion='DESC',
    pagina=1,
    tamanio=10,
):
    with connection.cursor() as cursor:
        cursor.execute(
            """
            DECLARE @Total INT;
            EXEC dbo.usp_libro_listar
                @Buscar=%s, @Estado=%s, @OrdenarPor=%s, @Direccion=%s,
                @Pagina=%s, @TamanioPagina=%s, @TotalRegistros=@Total OUTPUT;
            SELECT @Total AS TotalRegistros;
            """,
            [buscar or None, estado or None, ordenar_por, direccion, pagina, tamanio],
        )
        data = [enriquecer_urls(r) for r in _cursor_rows(cursor)]
        total = 0
        if cursor.nextset() and cursor.description:
            row = cursor.fetchone()
            if row:
                total = int(row[0])
    return data, total


def obtener_libro(id_libro: str):
    with connection.cursor() as cursor:
        cursor.execute('EXEC dbo.usp_libro_obtener @Id=%s', [id_libro])
        rows = _cursor_rows(cursor)
        aulas = []
        if cursor.nextset():
            aulas = [r['IDAULA'] for r in _cursor_rows(cursor)]
    if not rows:
        return None
    out = enriquecer_urls(rows[0])
    out['AULAS'] = aulas
    return out


def insertar_libro(payload: dict, id_usuario=None):
    with connection.cursor() as cursor:
        prepare_write_cursor(cursor, id_usuario, payload)
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200), @Id NVARCHAR(50);
            EXEC dbo.usp_libro_insertar
                @Titulo=%s, @Descripcion=%s, @UrlContenido=%s, @ImgPortada=%s,
                @FechaSubida=%s, @Estado=%s, @AulasCsv=%s,
                @IdGenerado=@Id OUTPUT, @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje, @Id AS IdGenerado;
            """,
            [
                payload['TITULO'],
                payload.get('DESCRIPCION') or None,
                payload.get('URLCONTENIDO') or None,
                payload.get('IMGPORTADA') or None,
                payload.get('FECHASUBIDA') or None,
                payload.get('ESTADO', 'Activo'),
                payload.get('AULAS_CSV') or None,
            ],
        )
        ok, mensaje, extras = _read_sp_write_result(cursor, extra_cols=['idgenerado'])
        return ok, mensaje, extras.get('idgenerado')


def actualizar_libro(id_libro: str, payload: dict, id_usuario=None):
    with connection.cursor() as cursor:
        prepare_write_cursor(cursor, id_usuario, payload)
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200);
            EXEC dbo.usp_libro_actualizar
                @Id=%s, @Titulo=%s, @Descripcion=%s, @UrlContenido=%s,
                @ImgPortada=%s, @Estado=%s, @AulasCsv=%s,
                @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            [
                id_libro,
                payload['TITULO'],
                payload.get('DESCRIPCION') or None,
                payload.get('URLCONTENIDO') or None,
                payload.get('IMGPORTADA') or None,
                payload.get('ESTADO', 'Activo'),
                payload.get('AULAS_CSV') or None,
            ],
        )
        ok, mensaje, _ = _read_sp_write_result(cursor)
        return ok, mensaje


def eliminar_libro(id_libro: str, id_usuario=None):
    with connection.cursor() as cursor:
        prepare_write_cursor(cursor, id_usuario)
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200);
            EXEC dbo.usp_libro_eliminar @Id=%s, @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            [id_libro],
        )
        ok, mensaje, _ = _read_sp_write_result(cursor)
        return ok, mensaje


def listar_catalogos_biblioteca():
    with connection.cursor() as cursor:
        cursor.execute(
            """
            SELECT IDAULA, NOMBRE
            FROM AULA
            WHERE ACTIVO = 1
            ORDER BY NOMBRE
            """
        )
        aulas = _cursor_rows(cursor)
    return {'aulas': aulas}


def carpeta_libro(id_libro: str) -> Path:
    path = Path(settings.MEDIA_ROOT) / 'biblioteca' / str(id_libro)
    path.mkdir(parents=True, exist_ok=True)
    return path


def guardar_pdf(id_libro: str, uploaded_file) -> str:
    folder = carpeta_libro(id_libro)
    dest = folder / 'contenido.pdf'
    with dest.open('wb') as fh:
        for chunk in uploaded_file.chunks():
            fh.write(chunk)
    return f'biblioteca/{id_libro}/contenido.pdf'


def guardar_portada(id_libro: str, uploaded_file) -> str:
    folder = carpeta_libro(id_libro)
    name = (uploaded_file.name or 'portada.jpg').lower()
    ext = Path(name).suffix
    if ext not in ('.jpg', '.jpeg', '.png', '.webp', '.gif'):
        ext = '.jpg'
    dest = folder / f'portada{ext}'
    with dest.open('wb') as fh:
        for chunk in uploaded_file.chunks():
            fh.write(chunk)
    return f'biblioteca/{id_libro}/portada{ext}'


def borrar_archivos_libro(id_libro: str):
    folder = Path(settings.MEDIA_ROOT) / 'biblioteca' / str(id_libro)
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
