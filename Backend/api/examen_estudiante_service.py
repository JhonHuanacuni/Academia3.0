from django.db import connection

from .examen_crud_service import _cursor_rows, _read_sp_write_result, _media_url, enriquecer_pregunta


def enriquecer_alt_segura(row):
    """Alternativa sin ESCORRECTA."""
    if not row:
        return row
    return {
        'IDALTERNATIVA': row.get('IDALTERNATIVA'),
        'DESCRIPCION': row.get('DESCRIPCION'),
        'ORDEN': row.get('ORDEN'),
        'IMAGEURL': row.get('IMAGEURL'),
        'URLPREVIEW': _media_url(row.get('IMAGEURL')),
    }


def listar_examenes_estudiante(id_usuario: str):
    with connection.cursor() as cursor:
        cursor.execute(
            'EXEC dbo.usp_examen_estudiante_listar @IdUsuario=%s',
            [id_usuario],
        )
        return _cursor_rows(cursor)


def iniciar_intento(id_examen: str, id_usuario: str):
    with connection.cursor() as cursor:
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200), @Id NVARCHAR(50);
            EXEC dbo.usp_examen_intento_iniciar
                @IdExamen=%s, @IdUsuario=%s,
                @IdIntento=@Id OUTPUT, @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje, @Id AS IdIntento;
            """,
            [id_examen, id_usuario],
        )
        ok, mensaje, extras = _read_sp_write_result(cursor, extra_cols=['idintento'])
        return ok, mensaje, extras.get('idintento')


def estado_intento(id_intento: str, id_usuario: str):
    with connection.cursor() as cursor:
        cursor.execute(
            'EXEC dbo.usp_examen_intento_estado @IdIntento=%s, @IdUsuario=%s',
            [id_intento, id_usuario],
        )
        header_rows = _cursor_rows(cursor)
        if not header_rows:
            return None
        header = dict(header_rows[0])
        resultado = int(header.get('Resultado') or header.get('RESULTADO') or 0)
        if resultado == 0:
            return {
                'ok': False,
                'mensaje': header.get('Mensaje') or header.get('MENSAJE') or 'Error',
            }

        respondidas = []
        if cursor.nextset():
            respondidas = _cursor_rows(cursor)

        pregunta = None
        if cursor.nextset():
            preg_rows = _cursor_rows(cursor)
            if preg_rows:
                pregunta = enriquecer_pregunta(preg_rows[0])
                pregunta.pop('ESCORRECTA', None)
            if cursor.nextset():
                alternativas = [enriquecer_alt_segura(r) for r in _cursor_rows(cursor)]
                if pregunta is not None:
                    pregunta['ALTERNATIVAS'] = alternativas

        return {
            'ok': True,
            'intento': header,
            'respondidas': respondidas,
            'pregunta': pregunta,
        }


def responder_intento(id_intento: str, id_usuario: str, id_pregunta: str, id_alternativa: str):
    with connection.cursor() as cursor:
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200), @Ord INT, @Ult BIT, @Agot BIT;
            EXEC dbo.usp_examen_intento_responder
                @IdIntento=%s, @IdUsuario=%s, @IdPregunta=%s, @IdAlternativa=%s,
                @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT,
                @OrdenSiguiente=@Ord OUTPUT, @EsUltima=@Ult OUTPUT, @TiempoAgotado=@Agot OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje,
                   @Ord AS OrdenSiguiente, @Ult AS EsUltima, @Agot AS TiempoAgotado;
            """,
            [id_intento, id_usuario, id_pregunta, id_alternativa],
        )
        ok, mensaje, extras = _read_sp_write_result(
            cursor,
            extra_cols=['ordensiguiente', 'esultima', 'tiempoagotado'],
        )
        return ok, mensaje, {
            'ordenSiguiente': extras.get('ordensiguiente'),
            'esUltima': bool(extras.get('esultima')),
            'tiempoAgotado': bool(extras.get('tiempoagotado')),
        }


def finalizar_intento(id_intento: str, id_usuario: str):
    with connection.cursor() as cursor:
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200);
            EXEC dbo.usp_examen_intento_finalizar
                @IdIntento=%s, @IdUsuario=%s,
                @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            [id_intento, id_usuario],
        )
        ok = 0
        mensaje = 'Error desconocido'
        resumen = None
        while True:
            if cursor.description:
                rows = _cursor_rows(cursor)
                if not rows:
                    pass
                else:
                    first = rows[0]
                    keys = {str(k).lower() for k in first.keys()}
                    if 'idintentoexamen' in keys:
                        resumen = first
                    if 'resultado' in keys:
                        ok = int(first.get('Resultado') or first.get('RESULTADO') or ok)
                        mensaje = first.get('Mensaje') or first.get('MENSAJE') or mensaje
            if not cursor.nextset():
                break

    if resumen is None and ok:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT i.IDINTENTOEXAMEN, i.IDEXAMEN, e.TITULO,
                       i.PUNTAJEOBTENIDO, i.CANTCORRECTAS, i.CANTINCORRECTAS,
                       i.CANTSINRESPONDER, i.APROBADO,
                       (SELECT COUNT(*) FROM PREGUNTA WHERE IDEXAMEN = i.IDEXAMEN) AS CANTPREGUNTAS,
                       ISNULL(e.PUNTAJETOTAL, 0) AS PUNTAJETOTAL
                FROM INTENTO_EXAMEN i
                INNER JOIN EXAMEN e ON e.IDEXAMEN = i.IDEXAMEN
                WHERE i.IDINTENTOEXAMEN = %s AND i.IDUSUARIO = %s
                """,
                [id_intento, id_usuario],
            )
            rows = _cursor_rows(cursor)
            if rows:
                resumen = rows[0]

    return ok, mensaje, resumen
