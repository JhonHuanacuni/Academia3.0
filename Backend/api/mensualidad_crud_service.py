from django.db import connection
from .db_context import prepare_write_cursor
from .models import Aula
from . import sp_runner as sp
from .sql_compat import concat_nombre_usuario, plan_table


def _read_sp_write_result(cursor):
    return sp.read_write_result(cursor)


def _decimal_or_none(value):
    if value is None or value == '':
        return None
    return float(value)


def listar_mensualidades(
    buscar=None,
    deuda=None,
    ordenar_por='FECHAREGISTRO',
    direccion='DESC',
    pagina=1,
    tamanio=10,
):
    deuda = (deuda or '').strip() or None
    params = [buscar or None, deuda, ordenar_por, direccion, pagina, tamanio]
    with connection.cursor() as cursor:
        if sp.is_mysql():
            return sp.call_list(cursor, 'usp_mensualidad_listar', params)
        cursor.execute(
            """
            DECLARE @Total INT;
            EXEC dbo.usp_mensualidad_listar
                @Buscar=%s, @Deuda=%s, @OrdenarPor=%s, @Direccion=%s,
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


def listar_mensualidades_estudiante(id_usuario: str):
    with connection.cursor() as cursor:
        if sp.is_mysql():
            return sp.call_simple(cursor, 'usp_mensualidad_listar_estudiante', [id_usuario])
        cursor.execute(
            'EXEC dbo.usp_mensualidad_listar_estudiante @IdUsuario=%s',
            [id_usuario],
        )
        return sp.cursor_rows(cursor)


def obtener_mensualidad(id_mensualidad: str):
    return sp.call_obtain('usp_mensualidad_obtener', id_mensualidad)


def listar_pagos_mensualidad(id_mensualidad: str):
    with connection.cursor() as cursor:
        if sp.is_mysql():
            return sp.call_simple(cursor, 'usp_mensualidad_listar_pagos', [id_mensualidad])
        cursor.execute(
            'EXEC dbo.usp_mensualidad_listar_pagos @IdMensualidad=%s',
            [id_mensualidad],
        )
        return sp.cursor_rows(cursor)


def insertar_mensualidad(payload: dict, id_usuario=None):
    params = [
        payload.get('IDMENSUALIDAD') or None,
        payload['IDUSUARIO'],
        payload['IDPLAN'],
        int(payload.get('ESTADOMIEMBRO') or 2),
        payload['FECHAINICIO'],
        payload['FECHAFIN'],
        _decimal_or_none(payload.get('MONTOTOTAL')),
        _decimal_or_none(payload.get('PAGOINICIAL')),
        payload.get('IDMETODOPAGO') or None,
        payload.get('IDAULA') or None,
        payload.get('IDTUTOR') or None,
        payload.get('OBSERVACIONES') or None,
        payload.get('FECHACANCELACION') or None,
        payload.get('REGISTRADOPOR') or None,
    ]
    with connection.cursor() as cursor:
        prepare_write_cursor(cursor, id_usuario, payload)
        if sp.is_mysql():
            return sp.call_write(cursor, 'usp_mensualidad_insertar', params)
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200);
            EXEC dbo.usp_mensualidad_insertar
                @Id=%s, @IdUsuario=%s, @IdPlan=%s, @EstadoMiembro=%s,
                @FechaInicio=%s, @FechaFin=%s, @MontoTotal=%s, @PagoInicial=%s,
                @IdMetodoPago=%s, @IdAula=%s, @IdTutor=%s,
                @Observaciones=%s, @FechaCancelacion=%s, @RegistradoPor=%s,
                @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            params,
        )
        return _read_sp_write_result(cursor)


def actualizar_mensualidad(id_mensualidad: str, payload: dict, id_usuario=None):
    params = [
        id_mensualidad,
        payload['IDUSUARIO'],
        payload['IDPLAN'],
        int(payload.get('ESTADOMIEMBRO') or 2),
        payload['FECHAINICIO'],
        payload['FECHAFIN'],
        _decimal_or_none(payload.get('MONTOTOTAL')),
        payload.get('IDAULA') or None,
        payload.get('IDTUTOR') or None,
        payload.get('OBSERVACIONES') or None,
        payload.get('FECHACANCELACION') or None,
    ]
    with connection.cursor() as cursor:
        prepare_write_cursor(cursor, id_usuario, payload)
        if sp.is_mysql():
            return sp.call_write(cursor, 'usp_mensualidad_actualizar', params)
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200);
            EXEC dbo.usp_mensualidad_actualizar
                @Id=%s, @IdUsuario=%s, @IdPlan=%s, @EstadoMiembro=%s,
                @FechaInicio=%s, @FechaFin=%s, @MontoTotal=%s,
                @IdAula=%s, @IdTutor=%s, @Observaciones=%s, @FechaCancelacion=%s,
                @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            params,
        )
        return _read_sp_write_result(cursor)


def eliminar_mensualidad(id_mensualidad: str, id_usuario: str | None = None):
    from .modulos_services import get_usuario_tipo

    es_admin = get_usuario_tipo((id_usuario or '').strip()) == '3'
    eliminacion_fisica = 1 if es_admin else 0

    with connection.cursor() as cursor:
        prepare_write_cursor(cursor, id_usuario)
        if sp.is_mysql():
            return sp.call_write(
                cursor, 'usp_mensualidad_eliminar', [id_mensualidad, eliminacion_fisica]
            )
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200);
            EXEC dbo.usp_mensualidad_eliminar
                @Id=%s, @EliminacionFisica=%s,
                @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            [id_mensualidad, eliminacion_fisica],
        )
        return _read_sp_write_result(cursor)


def buscar_estudiantes(buscar=None):
    with connection.cursor() as cursor:
        if sp.is_mysql():
            return sp.call_simple(cursor, 'usp_mensualidad_buscar_estudiantes', [buscar or None])
        cursor.execute(
            'EXEC dbo.usp_mensualidad_buscar_estudiantes @Buscar=%s',
            [buscar or None],
        )
        return sp.cursor_rows(cursor)


def obtener_nombre_registrador(id_usuario: str | None):
    if not id_usuario:
        return ''
    with connection.cursor() as cursor:
        cursor.execute(
            f"""
            SELECT {concat_nombre_usuario('u')}
            FROM USUARIO u
            WHERE u.IDUSUARIO = %s
            """,
            [id_usuario],
        )
        row = cursor.fetchone()
    return (row[0] or '').strip() if row else ''


def listar_catalogos(id_registrador=None):
    catalogos = {
        'planes': [],
        'aulas': [],
        'metodosPago': [],
        'tutores': [],
        'estadosMensualidad': [
            {'value': 2, 'label': 'Activo'},
            {'value': 3, 'label': 'Vencido'},
        ],
    }
    with connection.cursor() as cursor:
        cursor.execute(
            f"""
            SELECT IDPLAN, NOMBRE
            FROM {plan_table()} WHERE ACTIVO = 1 ORDER BY NOMBRE
            """
        )
        catalogos['planes'] = sp.cursor_rows(cursor)

        cursor.execute(
            """
            SELECT IDMETODOPAGO, TITULO
            FROM METODO_PAGO WHERE ACTIVO = 1 ORDER BY TITULO
            """
        )
        catalogos['metodosPago'] = sp.cursor_rows(cursor)

        try:
            cursor.execute(
                """
                SELECT IDTUTOR, NOMBRE
                FROM TUTOR WHERE ACTIVO = 1 ORDER BY NOMBRE
                """
            )
            catalogos['tutores'] = sp.cursor_rows(cursor)
        except Exception:
            catalogos['tutores'] = []

    aulas = Aula.objects.filter(ACTIVO=True).order_by('NOMBRE').values('IDAULA', 'NOMBRE')
    catalogos['aulas'] = list(aulas)
    if id_registrador:
        catalogos['registradorNombre'] = obtener_nombre_registrador(id_registrador)
    return catalogos
