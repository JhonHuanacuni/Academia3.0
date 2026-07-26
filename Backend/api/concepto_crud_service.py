from django.db import connection


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


def listar_conceptos(
    buscar=None,
    estado=None,
    ordenar_por='NOMBRE',
    direccion='ASC',
    pagina=1,
    tamanio=10,
):
    with connection.cursor() as cursor:
        cursor.execute(
            """
            DECLARE @Total INT;
            EXEC dbo.usp_concepto_listar
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


def obtener_concepto(id_concepto: str):
    with connection.cursor() as cursor:
        cursor.execute('EXEC dbo.usp_concepto_obtener @Id=%s', [id_concepto])
        rows = _cursor_rows(cursor)
    return rows[0] if rows else None


def insertar_concepto(payload: dict):
    with connection.cursor() as cursor:
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200), @Id NVARCHAR(50);
            EXEC dbo.usp_concepto_insertar
                @Nombre=%s, @Costo=%s, @FechaInicio=%s, @FechaFin=%s, @Estado=%s,
                @IdGenerado=@Id OUTPUT, @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            [
                payload['NOMBRE'],
                payload.get('COSTO', 0),
                payload.get('FECHAINICIO'),
                payload.get('FECHAFIN'),
                payload.get('ESTADO', 'Activo'),
            ],
        )
        return _read_sp_write_result(cursor)


def actualizar_concepto(id_concepto: str, payload: dict):
    with connection.cursor() as cursor:
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200);
            EXEC dbo.usp_concepto_actualizar
                @Id=%s, @Nombre=%s, @Costo=%s, @FechaInicio=%s, @FechaFin=%s, @Estado=%s,
                @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            [
                id_concepto,
                payload['NOMBRE'],
                payload.get('COSTO', 0),
                payload.get('FECHAINICIO'),
                payload.get('FECHAFIN'),
                payload.get('ESTADO', 'Activo'),
            ],
        )
        return _read_sp_write_result(cursor)


def eliminar_concepto(id_concepto: str):
    with connection.cursor() as cursor:
        cursor.execute(
            """
            DECLARE @R INT, @M NVARCHAR(200);
            EXEC dbo.usp_concepto_eliminar @Id=%s, @Resultado=@R OUTPUT, @Mensaje=@M OUTPUT;
            SELECT @R AS Resultado, @M AS Mensaje;
            """,
            [id_concepto],
        )
        return _read_sp_write_result(cursor)


def listar_conceptos_activos():
    """Solo conceptos Activo y vigentes (hoy entre FECHAINICIO y FECHAFIN)."""
    with connection.cursor() as cursor:
        cursor.execute(
            """
            SELECT IDCONCEPTO, NOMBRE, COSTO, FECHAINICIO, FECHAFIN
            FROM CONCEPTOPAGOEXTRA
            WHERE ACTIVO = 1
              AND FECHAINICIO IS NOT NULL AND LEN(FECHAINICIO) = 8
              AND FECHAFIN IS NOT NULL AND LEN(FECHAFIN) = 8
              AND CAST(GETDATE() AS DATE) >= CONVERT(DATE,
                    SUBSTRING(FECHAINICIO, 5, 4) + SUBSTRING(FECHAINICIO, 3, 2) + SUBSTRING(FECHAINICIO, 1, 2), 112)
              AND CAST(GETDATE() AS DATE) <= CONVERT(DATE,
                    SUBSTRING(FECHAFIN, 5, 4) + SUBSTRING(FECHAFIN, 3, 2) + SUBSTRING(FECHAFIN, 1, 2), 112)
            ORDER BY NOMBRE
            """
        )
        return _cursor_rows(cursor)
