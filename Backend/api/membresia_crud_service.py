from django.db import connection
from .models import Aula


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


def _decimal_or_none(value):
    if value is None or value == '':
        return None
    return float(value)


def listar_membresias(
    buscar=None,
    estado=None,
    ordenar_por='FECHAREGISTRO',
    direccion='DESC',
    pagina=1,
    tamanio=10,
):
    estado = (estado or '').strip() or 'Activo'
    with connection.cursor() as cursor:
        cursor.execute(
            """
            DECLARE @Total INT;
            EXEC dbo.usp_membresia_listar
                @Buscar=%s, @Estado=%s, @OrdenarPor=%s, @Direccion=%s,
                @Pagina=%s, @TamanioPagina=%s, @TotalRegistros=@Total OUTPUT;
            SELECT @Total AS TotalRegistros;
            """,
            [buscar or None, estado, ordenar_por, direccion, pagina, tamanio],
        )
        data = _cursor_rows(cursor)
        total = 0
        if cursor.nextset() and cursor.description:
            row = cursor.fetchone()
            if row:
                total = int(row[0])
    return data, total


def obtener_membresia(id_membresia: str):
    with connection.cursor() as cursor:
        cursor.execute('EXEC dbo.usp_membresia_obtener @Id=%s', [id_membresia])
        rows = _cursor_rows(cursor)
    return rows[0] if rows else None


def insertar_membresia(payload: dict):
    with connection.cursor() as cursor:
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200);
            EXEC dbo.usp_membresia_insertar
                @Id=%s, @IdUsuario=%s, @IdPlan=%s, @IdTurno=%s, @EstadoMiembro=%s,
                @FechaInicio=%s, @FechaFin=%s, @MontoTotal=%s, @PagoInicial=%s,
                @TipoMembresia=%s, @IdMetodoPago=%s, @IdAula=%s, @Asesor=%s,
                @Observaciones=%s, @FechaCancelacion=%s, @RegistradoPor=%s,
                @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            [
                payload.get('IDMEMBRESIA') or None,
                payload['IDUSUARIO'],
                payload['IDPLAN'],
                payload.get('IDTURNO') or None,
                int(payload.get('ESTADOMIEMBRO') or 1),
                payload['FECHAINICIO'],
                payload['FECHAFIN'],
                _decimal_or_none(payload.get('MONTOTOTAL')),
                _decimal_or_none(payload.get('PAGOINICIAL')),
                payload.get('TIPOMEMBRESIA') or None,
                payload.get('IDMETODOPAGO') or None,
                payload.get('IDAULA') or None,
                payload.get('ASESOR') or None,
                payload.get('OBSERVACIONES') or None,
                payload.get('FECHACANCELACION') or None,
                payload.get('REGISTRADOPOR') or None,
            ],
        )
        return _read_sp_write_result(cursor)


def actualizar_membresia(id_membresia: str, payload: dict):
    with connection.cursor() as cursor:
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200);
            EXEC dbo.usp_membresia_actualizar
                @Id=%s, @IdUsuario=%s, @IdPlan=%s, @IdTurno=%s, @EstadoMiembro=%s,
                @FechaInicio=%s, @FechaFin=%s, @MontoTotal=%s, @TipoMembresia=%s,
                @IdAula=%s, @Asesor=%s, @Observaciones=%s, @FechaCancelacion=%s,
                @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            [
                id_membresia,
                payload['IDUSUARIO'],
                payload['IDPLAN'],
                payload.get('IDTURNO') or None,
                int(payload.get('ESTADOMIEMBRO') or 1),
                payload['FECHAINICIO'],
                payload['FECHAFIN'],
                _decimal_or_none(payload.get('MONTOTOTAL')),
                payload.get('TIPOMEMBRESIA') or None,
                payload.get('IDAULA') or None,
                payload.get('ASESOR') or None,
                payload.get('OBSERVACIONES') or None,
                payload.get('FECHACANCELACION') or None,
            ],
        )
        return _read_sp_write_result(cursor)


def eliminar_membresia(id_membresia: str, id_usuario: str | None = None):
    from .modulos_services import get_usuario_tipo

    es_admin = get_usuario_tipo((id_usuario or '').strip()) == '3'
    eliminacion_fisica = 1 if es_admin else 0

    with connection.cursor() as cursor:
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200);
            EXEC dbo.usp_membresia_eliminar
                @Id=%s, @EliminacionFisica=%s,
                @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            [id_membresia, eliminacion_fisica],
        )
        return _read_sp_write_result(cursor)


def buscar_estudiantes(buscar=None):
    with connection.cursor() as cursor:
        cursor.execute(
            'EXEC dbo.usp_membresia_buscar_estudiantes @Buscar=%s',
            [buscar or None],
        )
        return _cursor_rows(cursor)


def listar_catalogos():
    catalogos = {
        'planes': [],
        'turnos': [],
        'aulas': [],
        'metodosPago': [],
        'estadosMiembro': [
            {'value': 1, 'label': 'Nuevo'},
            {'value': 2, 'label': 'Activo'},
            {'value': 3, 'label': 'Vencido'},
            {'value': 4, 'label': 'Cancelado'},
        ],
        'tiposMembresia': [
            {'value': 'Individual', 'label': 'Individual'},
            {'value': 'Grupal', 'label': 'Grupal'},
            {'value': 'Familiar', 'label': 'Familiar'},
        ],
    }
    with connection.cursor() as cursor:
        cursor.execute(
            """
            SELECT IDPLAN, NOMBRE, PRECIO, DURACIONDIAS
            FROM [PLAN] WHERE ACTIVO = 1 ORDER BY NOMBRE
            """
        )
        catalogos['planes'] = _cursor_rows(cursor)

        cursor.execute('SELECT IDTURNO, DESCRIPCION FROM TURNO ORDER BY DESCRIPCION')
        catalogos['turnos'] = _cursor_rows(cursor)

        cursor.execute(
            """
            SELECT IDMETODOPAGO, TITULO
            FROM METODO_PAGO WHERE ACTIVO = 1 ORDER BY TITULO
            """
        )
        catalogos['metodosPago'] = _cursor_rows(cursor)

    aulas = Aula.objects.filter(ACTIVO=True).order_by('NOMBRE').values('IDAULA', 'NOMBRE')
    catalogos['aulas'] = list(aulas)
    return catalogos
