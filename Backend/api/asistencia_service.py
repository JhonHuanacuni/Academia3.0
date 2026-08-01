from datetime import datetime, timedelta

from django.db import connection
from .db_context import prepare_write_cursor
from django.utils import timezone


def _cursor_rows(cursor):
    columns = [col[0] for col in cursor.description] if cursor.description else []
    return [dict(zip(columns, row)) for row in cursor.fetchall()]


def _read_marcar_outputs(cursor):
    """Lee outputs del SP usp_asistencia_marcar."""
    resultado, mensaje, id_asistencia = 0, 'Error desconocido', None
    # pyodbc puede devolver múltiples result sets
    while True:
        if cursor.description:
            cols = [c[0].lower() for c in cursor.description]
            row = cursor.fetchone()
            if row:
                data = dict(zip(cols, row))
                if 'resultado' in data:
                    resultado = int(data.get('resultado') or 0)
                if 'mensaje' in data:
                    mensaje = str(data.get('mensaje') or mensaje)
                if 'idasistencia' in data:
                    id_asistencia = data.get('idasistencia')
        if not cursor.nextset():
            break
    return resultado, mensaje, id_asistencia


def _parse_hora(val):
    if val is None:
        return None
    if hasattr(val, 'hour') and hasattr(val, 'minute'):
        return val.hour, val.minute
    s = str(val).strip()
    if not s:
        return None
    parts = s.split(':')
    if len(parts) >= 2:
        return int(parts[0]), int(parts[1])
    return None


def _limite_tardanza_desde_plan(hora_entrada, tiempo_extra_min):
    parsed = _parse_hora(hora_entrada)
    if not parsed:
        parsed = (8, 0)
    h, m = parsed
    extra = int(tiempo_extra_min or 0)
    base = datetime(2000, 1, 1, h, m, 0)
    limite = base + timedelta(minutes=extra)
    return limite.time()


def _obtener_limite_tardanza_usuario(id_usuario):
    with connection.cursor() as cursor:
        cursor.execute(
            """
            SELECT TOP 1 p.HORAENTRADA, ISNULL(p.TIEMPOEXTRA, 0)
            FROM MENSUALIDAD m
            INNER JOIN [PLAN] p ON p.IDPLAN = m.IDPLAN
            WHERE m.IDUSUARIO = %s
              AND (m.ESTADO IS NULL OR m.ESTADO = 'Activo')
            ORDER BY m.FECHAREGISTRO DESC, m.FECHAINICIO DESC
            """,
            [id_usuario],
        )
        row = cursor.fetchone()
    if not row:
        return _limite_tardanza_desde_plan('08:00:00', 0)
    return _limite_tardanza_desde_plan(row[0], row[1])


def _estado_asistencia_por_hora(id_usuario):
    limite = _obtener_limite_tardanza_usuario(id_usuario)
    ahora = timezone.localtime().time()
    return 'Presente' if ahora <= limite else 'Tarde'


def marcar_asistencia_por_dni(dni: str, id_registrador: str = None):
    dni = (dni or '').strip()
    if not dni:
        return 0, 'Ingresa un DNI válido.', None, None

    with connection.cursor() as cursor:
        prepare_write_cursor(cursor, id_registrador)
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200), @Id NVARCHAR(50);
            EXEC dbo.usp_asistencia_marcar
                @Dni=%s, @IdRegistrador=%s,
                @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT, @IdAsistencia=@Id OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje, @Id AS IdAsistencia;
            """,
            [dni, id_registrador],
        )
        resultado, mensaje, id_asistencia = _read_marcar_outputs(cursor)

    if resultado != 1:
        return resultado, mensaje, None, None

    row = _obtener_asistencia(id_asistencia)
    return resultado, mensaje, id_asistencia, row


def _obtener_asistencia(id_asistencia: str):
    with connection.cursor() as cursor:
        cursor.execute(
            """
            SELECT a.IDASISTENCIA, a.FECHAREGISTRO, a.HORAINICIO, a.ESTADO,
                   u.IDUSUARIO, u.NOMBRE, u.APELLIDO, u.DNI
            FROM ASISTENCIA a
            INNER JOIN USUARIO u ON u.IDUSUARIO = a.IDUSUARIO
            WHERE a.IDASISTENCIA = %s
            """,
            [id_asistencia],
        )
        rows = _cursor_rows(cursor)
    return rows[0] if rows else None


def marcar_asistencia_orm(dni: str, id_registrador: str = None):
    """Fallback si el SP no está instalado."""
    from .models import Usuario, Asistencia
    import uuid

    dni = (dni or '').strip()
    usuario = Usuario.objects.filter(DNI=dni, ESTADO='Activo').first()
    if not usuario:
        return 0, 'Usuario no encontrado con ese DNI.', None, None

    hoy = timezone.localtime().strftime('%d%m%Y')
    hora = timezone.localtime().strftime('%H:%M:%S')

    if Asistencia.objects.filter(IDUSUARIO=usuario.IDUSUARIO, FECHAREGISTRO=hoy).exists():
        return 0, 'Este estudiante ya tiene su asistencia registrada para hoy.', None, None

    estado = _estado_asistencia_por_hora(usuario.IDUSUARIO)
    id_asist = f"AS_{uuid.uuid4().hex[:12].upper()}"

    Asistencia.objects.create(
        IDASISTENCIA=id_asist,
        FECHAREGISTRO=hoy,
        HORAINICIO=hora,
        ESTADO=estado,
        JUSTIFICADO=False,
        IDUSUARIO=usuario.IDUSUARIO,
    )

    row = {
        'IDASISTENCIA': id_asist,
        'FECHAREGISTRO': hoy,
        'HORAINICIO': hora,
        'ESTADO': estado,
        'IDUSUARIO': usuario.IDUSUARIO,
        'NOMBRE': usuario.NOMBRE,
        'APELLIDO': usuario.APELLIDO,
        'DNI': usuario.DNI,
    }
    return 1, 'Asistencia registrada.', id_asist, row


def listar_asistencias(fecha=None, buscar=None, pagina=1, tamanio=50):
    with connection.cursor() as cursor:
        cursor.execute(
            """
            DECLARE @Total INT;
            EXEC dbo.usp_asistencia_listar
                @Fecha=%s, @Buscar=%s, @OrdenarPor='HORAINICIO', @Direccion='DESC',
                @Pagina=%s, @TamanioPagina=%s, @TotalRegistros=@Total OUTPUT;
            SELECT @Total AS TotalRegistros;
            """,
            [fecha, buscar, pagina, tamanio],
        )
        data = _cursor_rows(cursor)
        total = 0
        if cursor.nextset() and cursor.description:
            row = cursor.fetchone()
            if row:
                total = int(row[0])
    return data, total


def listar_asistencias_orm(fecha=None, buscar=None):
    from django.db.models import Q
    from .models import Asistencia, Usuario
    hoy = fecha or timezone.localtime().strftime('%d%m%Y')
    qs = Asistencia.objects.filter(FECHAREGISTRO=hoy)
    if buscar:
        user_ids = Usuario.objects.filter(
            Q(DNI__icontains=buscar)
            | Q(NOMBRE__icontains=buscar)
            | Q(APELLIDO__icontains=buscar)
            | Q(IDUSUARIO__icontains=buscar)
        ).values_list('IDUSUARIO', flat=True)
        qs = qs.filter(IDUSUARIO__in=list(user_ids))
    rows = []
    for a in qs.order_by('-HORAINICIO'):
        u = Usuario.objects.filter(IDUSUARIO=a.IDUSUARIO).first()
        if not u:
            continue
        rows.append({
            'IDASISTENCIA': a.IDASISTENCIA,
            'FECHAREGISTRO': a.FECHAREGISTRO,
            'HORAINICIO': a.HORAINICIO,
            'ESTADO': a.ESTADO,
            'IDUSUARIO': u.IDUSUARIO,
            'NOMBRE': u.NOMBRE,
            'APELLIDO': u.APELLIDO,
            'DNI': u.DNI,
        })
    return rows, len(rows)


def obtener_usuario_por_dni(dni: str):
    from .models import Usuario
    return Usuario.objects.filter(DNI=dni.strip(), ESTADO='Activo').values(
        'IDUSUARIO', 'NOMBRE', 'APELLIDO', 'DNI', 'EMAIL',
    ).first()


def respuesta_marcar(row):
    if not row:
        return {}
    foto = row.get('FOTOPERFIL')
    foto_url = f'/media/{foto}' if foto else None
    return {
        'id': row['IDASISTENCIA'],
        'fecha': row['FECHAREGISTRO'],
        'hora': row['HORAINICIO'],
        'estado': (row.get('ESTADO') or 'Presente').lower(),
        'nombres': row.get('NOMBRE'),
        'apellidos': row.get('APELLIDO'),
        'dni': row.get('DNI'),
        'idusuario': row.get('IDUSUARIO'),
        'fotoUrl': foto_url,
    }
