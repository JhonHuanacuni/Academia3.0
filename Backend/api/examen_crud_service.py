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


def enriquecer_alternativa(row):
    if not row:
        return row
    out = dict(row)
    out['URLPREVIEW'] = _media_url(out.get('IMAGEURL'))
    return out


def enriquecer_pregunta(row):
    if not row:
        return row
    out = dict(row)
    out['URLPREVIEW'] = _media_url(out.get('IMAGEURL'))
    return out


def listar_examenes(
    buscar=None,
    ordenar_por='FECHAINICIO',
    direccion='DESC',
    pagina=1,
    tamanio=10,
):
    params = [buscar or None, ordenar_por, direccion, pagina, tamanio]
    with connection.cursor() as cursor:
        if sp.is_mysql():
            return sp.call_list(cursor, 'usp_examen_listar', params)
        cursor.execute(
            """
            DECLARE @Total INT;
            EXEC dbo.usp_examen_listar
                @Buscar=%s, @OrdenarPor=%s, @Direccion=%s,
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


def obtener_examen(id_examen: str):
    with connection.cursor() as cursor:
        if sp.is_mysql():
            sp.call_simple(cursor, 'usp_examen_obtener', [id_examen])
            rows = sp.cursor_rows(cursor)
            aulas = []
            if cursor.nextset():
                aulas = [r['IDAULA'] for r in sp.cursor_rows(cursor)]
            preguntas = []
            if cursor.nextset():
                preguntas = [enriquecer_pregunta(r) for r in sp.cursor_rows(cursor)]
        else:
            cursor.execute('EXEC dbo.usp_examen_obtener @Id=%s', [id_examen])
            rows = sp.cursor_rows(cursor)
            aulas = []
            if cursor.nextset():
                aulas = [r['IDAULA'] for r in sp.cursor_rows(cursor)]
            preguntas = []
            if cursor.nextset():
                preguntas = [enriquecer_pregunta(r) for r in sp.cursor_rows(cursor)]
    if not rows:
        return None
    out = dict(rows[0])
    out['AULAS'] = aulas
    out['PREGUNTAS'] = preguntas
    return out


def obtener_pregunta(id_examen: str, id_pregunta: str):
    with connection.cursor() as cursor:
        if sp.is_mysql():
            sp.call_simple(cursor, 'usp_examen_pregunta_detalle', [id_examen, id_pregunta])
            rows = sp.cursor_rows(cursor)
            alts = []
            if cursor.nextset():
                alts = [enriquecer_alternativa(r) for r in sp.cursor_rows(cursor)]
        else:
            cursor.execute(
                'EXEC dbo.usp_examen_pregunta_detalle @IdExamen=%s, @IdPregunta=%s',
                [id_examen, id_pregunta],
            )
            rows = sp.cursor_rows(cursor)
            alts = []
            if cursor.nextset():
                alts = [enriquecer_alternativa(r) for r in sp.cursor_rows(cursor)]
    if not rows:
        return None
    out = enriquecer_pregunta(rows[0])
    out['ALTERNATIVAS'] = alts
    return out


def distribucion_examen(tipo=None, id_examen=None):
    with connection.cursor() as cursor:
        if sp.is_mysql():
            sp.call_simple(cursor, 'usp_examen_distribucion', [tipo, id_examen])
            categorias = sp.cursor_rows(cursor)
            materias = []
            if cursor.nextset():
                materias = sp.cursor_rows(cursor)
        else:
            cursor.execute(
                'EXEC dbo.usp_examen_distribucion @Tipo=%s, @IdExamen=%s',
                [tipo, id_examen],
            )
            categorias = sp.cursor_rows(cursor)
            materias = []
            if cursor.nextset():
                materias = sp.cursor_rows(cursor)
    return {'categorias': categorias, 'materias': materias}


def insertar_examen(payload: dict, id_usuario=None):
    params = [
        payload['TITULO'],
        payload.get('DESCRIPCION'),
        int(payload.get('TIPO') or 40),
        int(payload.get('DURACIONMIN') or 120),
        payload.get('FECHAINICIO'),
        payload.get('FECHAFIN'),
        payload.get('HORAINICIO'),
        payload.get('HORAFIN'),
        1 if payload.get('VISIBLE', True) else 0,
        1 if payload.get('TODASLASULA', True) else 0,
        payload['IDUSUARIO'],
        payload.get('AULAS_CSV') or None,
    ]
    with connection.cursor() as cursor:
        prepare_write_cursor(cursor, id_usuario, payload)
        if sp.is_mysql():
            row = sp.call_write_outs(
                cursor,
                'usp_examen_insertar',
                params,
                ['@_sp_r', '@_sp_m', '@_sp_id'],
                ['Resultado', 'Mensaje', 'IdGenerado'],
            )
            return int(row[0] or 0), str(row[1] or ''), row[2]
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200), @Id NVARCHAR(50);
            EXEC dbo.usp_examen_insertar
                @Titulo=%s, @Descripcion=%s, @Tipo=%s, @DuracionMin=%s,
                @FechaInicio=%s, @FechaFin=%s, @HoraInicio=%s, @HoraFin=%s,
                @Visible=%s, @TodasLasAula=%s, @IdUsuario=%s, @AulasCsv=%s,
                @IdGenerado=@Id OUTPUT, @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje, @Id AS IdGenerado;
            """,
            params,
        )
        ok, mensaje, extras = _read_sp_write_result(cursor, extra_cols=['idgenerado'])
        return ok, mensaje, extras.get('idgenerado')


def actualizar_examen(id_examen: str, payload: dict, id_usuario=None):
    params = [
        id_examen,
        payload['TITULO'],
        payload.get('DESCRIPCION'),
        int(payload.get('DURACIONMIN') or 120),
        payload.get('FECHAINICIO'),
        payload.get('FECHAFIN'),
        payload.get('HORAINICIO'),
        payload.get('HORAFIN'),
        1 if payload.get('VISIBLE', True) else 0,
        1 if payload.get('TODASLASULA', True) else 0,
        payload.get('AULAS_CSV') or None,
    ]
    with connection.cursor() as cursor:
        prepare_write_cursor(cursor, id_usuario, payload)
        if sp.is_mysql():
            ok, mensaje = sp.call_write(cursor, 'usp_examen_actualizar', params)
            return ok, mensaje
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200);
            EXEC dbo.usp_examen_actualizar
                @Id=%s, @Titulo=%s, @Descripcion=%s, @DuracionMin=%s,
                @FechaInicio=%s, @FechaFin=%s, @HoraInicio=%s, @HoraFin=%s,
                @Visible=%s, @TodasLasAula=%s, @AulasCsv=%s,
                @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            params,
        )
        ok, mensaje, _ = _read_sp_write_result(cursor)
        return ok, mensaje


def eliminar_examen(id_examen: str, id_usuario=None):
    with connection.cursor() as cursor:
        prepare_write_cursor(cursor, id_usuario)
        if sp.is_mysql():
            ok, mensaje = sp.call_write(cursor, 'usp_examen_eliminar', [id_examen])
            return ok, mensaje
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200);
            EXEC dbo.usp_examen_eliminar @Id=%s, @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            [id_examen],
        )
        ok, mensaje, _ = _read_sp_write_result(cursor)
        return ok, mensaje


def guardar_pregunta(id_examen: str, id_pregunta: str, payload: dict, id_usuario=None):
    params = [
        id_examen,
        id_pregunta,
        payload.get('DESCRIPCION'),
        payload.get('IMAGEURL'),
        1 if payload.get('QUITAR_IMAGEN') else 0,
        payload.get('ALT1') or '',
        payload.get('ALT2') or '',
        payload.get('ALT3') or '',
        payload.get('ALT4') or '',
        payload.get('ALT5') or '',
        payload.get('IMG_ALT1'),
        payload.get('IMG_ALT2'),
        payload.get('IMG_ALT3'),
        payload.get('IMG_ALT4'),
        payload.get('IMG_ALT5'),
        1 if payload.get('QUITAR_IMG_ALT1') else 0,
        1 if payload.get('QUITAR_IMG_ALT2') else 0,
        1 if payload.get('QUITAR_IMG_ALT3') else 0,
        1 if payload.get('QUITAR_IMG_ALT4') else 0,
        1 if payload.get('QUITAR_IMG_ALT5') else 0,
        int(payload.get('CORRECTA_ORDEN') or 1),
    ]
    with connection.cursor() as cursor:
        prepare_write_cursor(cursor, id_usuario, payload)
        if sp.is_mysql():
            ok, mensaje = sp.call_write(cursor, 'usp_examen_pregunta_guardar', params)
            return ok, mensaje
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200);
            EXEC dbo.usp_examen_pregunta_guardar
                @IdExamen=%s, @IdPregunta=%s, @Descripcion=%s, @ImageUrl=%s,
                @QuitarImagen=%s,
                @Alt1=%s, @Alt2=%s, @Alt3=%s, @Alt4=%s, @Alt5=%s,
                @ImgAlt1=%s, @ImgAlt2=%s, @ImgAlt3=%s, @ImgAlt4=%s, @ImgAlt5=%s,
                @QuitarImgAlt1=%s, @QuitarImgAlt2=%s, @QuitarImgAlt3=%s,
                @QuitarImgAlt4=%s, @QuitarImgAlt5=%s,
                @CorrectaOrden=%s, @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            params,
        )
        ok, mensaje, _ = _read_sp_write_result(cursor)
        return ok, mensaje


def listar_catalogos_examen():
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
    return {
        'aulas': aulas,
        'tipos': [
            {'value': 40, 'label': '40 preguntas'},
            {'value': 100, 'label': '100 preguntas'},
        ],
    }


def carpeta_pregunta(id_examen: str, id_pregunta: str) -> Path:
    path = Path(settings.MEDIA_ROOT) / 'examenes' / str(id_examen) / 'preguntas' / str(id_pregunta)
    path.mkdir(parents=True, exist_ok=True)
    return path


def guardar_imagen_pregunta(id_examen: str, id_pregunta: str, uploaded_file) -> str:
    folder = carpeta_pregunta(id_examen, id_pregunta)
    name = (uploaded_file.name or 'imagen.jpg').lower()
    ext = Path(name).suffix
    if ext not in ('.jpg', '.jpeg', '.png', '.webp', '.gif'):
        ext = '.jpg'
    dest = folder / f'imagen{ext}'
    with dest.open('wb') as fh:
        for chunk in uploaded_file.chunks():
            fh.write(chunk)
    return f'examenes/{id_examen}/preguntas/{id_pregunta}/imagen{ext}'


def guardar_imagen_alternativa(id_examen: str, id_pregunta: str, orden: int, uploaded_file) -> str:
    folder = carpeta_pregunta(id_examen, id_pregunta)
    name = (uploaded_file.name or 'alt.jpg').lower()
    ext = Path(name).suffix
    if ext not in ('.jpg', '.jpeg', '.png', '.webp', '.gif'):
        ext = '.jpg'
    dest = folder / f'alt{orden}{ext}'
    with dest.open('wb') as fh:
        for chunk in uploaded_file.chunks():
            fh.write(chunk)
    return f'examenes/{id_examen}/preguntas/{id_pregunta}/alt{orden}{ext}'


def borrar_archivos_examen(id_examen: str):
    folder = Path(settings.MEDIA_ROOT) / 'examenes' / str(id_examen)
    if not folder.exists():
        return
    import shutil
    shutil.rmtree(folder, ignore_errors=True)
