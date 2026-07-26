/* ============================================================================
   SPs membresía: soporte IDASESOR (catálogo ASESOR)
   Ejecutar después de 6.asesor_tabla.sql
   Fecha: 12/07/2026
   ============================================================================ */

IF OBJECT_ID('dbo.usp_membresia_listar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_membresia_listar;
GO
CREATE PROCEDURE dbo.usp_membresia_listar
    @Buscar         NVARCHAR(200) = NULL,
    @Estado         NVARCHAR(50)  = NULL,
    @OrdenarPor     NVARCHAR(50)  = 'FECHAREGISTRO',
    @Direccion      NVARCHAR(4)   = 'DESC',
    @Pagina         INT           = 1,
    @TamanioPagina  INT           = 10,
    @TotalRegistros INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    IF @Pagina < 1 SET @Pagina = 1;
    IF @TamanioPagina < 1 SET @TamanioPagina = 10;
    IF @Estado IS NULL OR @Estado = '' SET @Estado = 'Activo';

    SELECT @TotalRegistros = COUNT(*)
    FROM MEMBRESIA m
    INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
    INNER JOIN [PLAN] pl ON pl.IDPLAN = m.IDPLAN
    LEFT JOIN AULA au ON au.IDAULA = m.IDAULA
    LEFT JOIN TURNO tu ON tu.IDTURNO = m.IDTURNO
    LEFT JOIN ASESOR ase ON ase.IDASESOR = m.IDASESOR
    WHERE m.ESTADO = @Estado
      AND (@Buscar IS NULL OR @Buscar = '' OR
           m.IDMEMBRESIA LIKE '%' + @Buscar + '%' OR
           u.DNI LIKE '%' + @Buscar + '%' OR
           u.NOMBRE LIKE '%' + @Buscar + '%' OR
           u.APELLIDO LIKE '%' + @Buscar + '%' OR
           pl.NOMBRE LIKE '%' + @Buscar + '%' OR
           ISNULL(au.NOMBRE, '') LIKE '%' + @Buscar + '%' OR
           ISNULL(ase.NOMBRE, '') LIKE '%' + @Buscar + '%' OR
           ISNULL(m.COMOENTERO, '') LIKE '%' + @Buscar + '%');

    SELECT
        m.IDMEMBRESIA,
        m.IDUSUARIO,
        UPPER(LTRIM(RTRIM(ISNULL(u.APELLIDO, '') + ' ' + ISNULL(u.NOMBRE, '')))) AS ESTUDIANTE_NOMBRE,
        u.DNI AS ESTUDIANTE_DNI,
        m.IDPLAN,
        pl.NOMBRE AS PLAN_NOMBRE,
        ISNULL(tu.DESCRIPCION, '') AS TURNO_DESCRIPCION,
        m.ESTADOMIEMBRO,
        CASE m.ESTADOMIEMBRO
            WHEN 1 THEN 'Nuevo'
            WHEN 2 THEN 'Activo'
            WHEN 3 THEN 'Vencido'
            WHEN 4 THEN 'Cancelado'
            ELSE '—'
        END AS ESTADOMIEMBRO_DESCRIPCION,
        m.FECHAINICIO,
        m.FECHAFIN,
        m.MONTOTOTAL,
        m.COMOENTERO,
        ISNULL(au.NOMBRE, '') AS AULA_NOMBRE,
        m.IDASESOR,
        ISNULL(ase.NOMBRE, ISNULL(m.ASESOR, '')) AS ASESOR_NOMBRE,
        m.ESTADO,
        m.FECHAREGISTRO
    FROM MEMBRESIA m
    INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
    INNER JOIN [PLAN] pl ON pl.IDPLAN = m.IDPLAN
    LEFT JOIN AULA au ON au.IDAULA = m.IDAULA
    LEFT JOIN TURNO tu ON tu.IDTURNO = m.IDTURNO
    LEFT JOIN ASESOR ase ON ase.IDASESOR = m.IDASESOR
    WHERE m.ESTADO = @Estado
      AND (@Buscar IS NULL OR @Buscar = '' OR
           m.IDMEMBRESIA LIKE '%' + @Buscar + '%' OR
           u.DNI LIKE '%' + @Buscar + '%' OR
           u.NOMBRE LIKE '%' + @Buscar + '%' OR
           u.APELLIDO LIKE '%' + @Buscar + '%' OR
           pl.NOMBRE LIKE '%' + @Buscar + '%' OR
           ISNULL(au.NOMBRE, '') LIKE '%' + @Buscar + '%' OR
           ISNULL(ase.NOMBRE, '') LIKE '%' + @Buscar + '%' OR
           ISNULL(m.COMOENTERO, '') LIKE '%' + @Buscar + '%')
    ORDER BY
        CASE WHEN @OrdenarPor = 'IDMEMBRESIA' AND @Direccion = 'ASC'  THEN m.IDMEMBRESIA END ASC,
        CASE WHEN @OrdenarPor = 'IDMEMBRESIA' AND @Direccion = 'DESC' THEN m.IDMEMBRESIA END DESC,
        CASE WHEN @OrdenarPor = 'ESTUDIANTE_NOMBRE' AND @Direccion = 'ASC'  THEN u.APELLIDO END ASC,
        CASE WHEN @OrdenarPor = 'ESTUDIANTE_NOMBRE' AND @Direccion = 'DESC' THEN u.APELLIDO END DESC,
        CASE WHEN @OrdenarPor = 'FECHAINICIO' AND @Direccion = 'ASC'  THEN m.FECHAINICIO END ASC,
        CASE WHEN @OrdenarPor = 'FECHAINICIO' AND @Direccion = 'DESC' THEN m.FECHAINICIO END DESC,
        CASE WHEN @OrdenarPor = 'FECHAFIN' AND @Direccion = 'ASC'  THEN m.FECHAFIN END ASC,
        CASE WHEN @OrdenarPor = 'FECHAFIN' AND @Direccion = 'DESC' THEN m.FECHAFIN END DESC,
        CASE WHEN @OrdenarPor = 'MONTOTOTAL' AND @Direccion = 'ASC'  THEN m.MONTOTOTAL END ASC,
        CASE WHEN @OrdenarPor = 'MONTOTOTAL' AND @Direccion = 'DESC' THEN m.MONTOTOTAL END DESC,
        CASE WHEN @OrdenarPor = 'FECHAREGISTRO' AND @Direccion = 'ASC'  THEN m.FECHAREGISTRO END ASC,
        CASE WHEN @OrdenarPor = 'FECHAREGISTRO' AND @Direccion = 'DESC' THEN m.FECHAREGISTRO END DESC,
        m.IDMEMBRESIA DESC
    OFFSET (@Pagina - 1) * @TamanioPagina ROWS
    FETCH NEXT @TamanioPagina ROWS ONLY;
END;
GO

IF OBJECT_ID('dbo.usp_membresia_obtener', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_membresia_obtener;
GO
CREATE PROCEDURE dbo.usp_membresia_obtener
    @Id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        m.IDMEMBRESIA,
        m.IDUSUARIO,
        UPPER(LTRIM(RTRIM(ISNULL(u.APELLIDO, '') + ' ' + ISNULL(u.NOMBRE, '')))) AS ESTUDIANTE_NOMBRE,
        u.DNI AS ESTUDIANTE_DNI,
        m.IDPLAN,
        pl.NOMBRE AS PLAN_NOMBRE,
        m.IDTURNO,
        ISNULL(tu.DESCRIPCION, '') AS TURNO_DESCRIPCION,
        m.ESTADOMIEMBRO,
        m.FECHAINICIO,
        m.FECHAFIN,
        m.MONTOTOTAL,
        m.COMOENTERO,
        m.IDAULA,
        ISNULL(au.NOMBRE, '') AS AULA_NOMBRE,
        m.IDASESOR,
        ISNULL(ase.NOMBRE, ISNULL(m.ASESOR, '')) AS ASESOR_NOMBRE,
        m.OBSERVACIONES,
        m.FECHACANCELACION,
        m.ESTADO,
        m.FECHAREGISTRO,
        m.REGISTRADOPOR,
        ISNULL(pag.PAGOINICIAL, 0) AS PAGOINICIAL,
        pag.IDMETODOPAGO
    FROM MEMBRESIA m
    INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
    INNER JOIN [PLAN] pl ON pl.IDPLAN = m.IDPLAN
    LEFT JOIN AULA au ON au.IDAULA = m.IDAULA
    LEFT JOIN TURNO tu ON tu.IDTURNO = m.IDTURNO
    LEFT JOIN ASESOR ase ON ase.IDASESOR = m.IDASESOR
    OUTER APPLY (
        SELECT TOP 1 p.MONTO AS PAGOINICIAL, p.IDMETODOPAGO
        FROM PAGOMEMBRESIA p
        WHERE p.IDMEMBRESIA = m.IDMEMBRESIA
        ORDER BY p.FECHAPAGO, p.IDPAGOMEMBRESIA
    ) pag
    WHERE m.IDMEMBRESIA = @Id;
END;
GO

IF OBJECT_ID('dbo.usp_membresia_insertar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_membresia_insertar;
GO
CREATE PROCEDURE dbo.usp_membresia_insertar
    @Id                 NVARCHAR(50) = NULL,
    @IdUsuario          NVARCHAR(50),
    @IdPlan             NVARCHAR(50),
    @IdTurno            NVARCHAR(50)  = NULL,
    @EstadoMiembro      INT           = 1,
    @FechaInicio        CHAR(8),
    @FechaFin           CHAR(8),
    @MontoTotal         DECIMAL(10,2),
    @PagoInicial        DECIMAL(10,2) = NULL,
    @ComoEntero         NVARCHAR(100) = NULL,
    @IdMetodoPago       NVARCHAR(50)  = NULL,
    @IdAula             NVARCHAR(50)  = NULL,
    @IdAsesor           NVARCHAR(50)  = NULL,
    @Observaciones      NVARCHAR(MAX) = NULL,
    @FechaCancelacion   CHAR(8)       = NULL,
    @RegistradoPor      NVARCHAR(50)  = NULL,
    @Resultado          INT OUTPUT,
    @Mensaje            NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF @IdUsuario IS NULL OR @IdUsuario = ''
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Debe seleccionar un estudiante.'; RETURN; END
    IF @FechaInicio IS NULL OR @FechaFin IS NULL
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ingrese fecha de inicio y fin.'; RETURN; END
    IF @MontoTotal IS NULL
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ingrese el monto total.'; RETURN; END

    IF NOT EXISTS (SELECT 1 FROM USUARIO WHERE IDUSUARIO = @IdUsuario AND IDTIPOUSUARIO = '1')
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El estudiante no existe o no es válido.'; RETURN; END
    IF NOT EXISTS (SELECT 1 FROM [PLAN] WHERE IDPLAN = @IdPlan)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El plan seleccionado no es válido.'; RETURN; END

    IF @IdAsesor IS NOT NULL AND @IdAsesor <> ''
       AND NOT EXISTS (SELECT 1 FROM ASESOR WHERE IDASESOR = @IdAsesor AND ACTIVO = 1)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El asesor seleccionado no es válido.'; RETURN; END

    IF @PagoInicial IS NOT NULL AND @PagoInicial > 0
       AND (@IdMetodoPago IS NULL OR @IdMetodoPago = '')
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Indique el método de pago del pago inicial.'; RETURN; END

    IF @Id IS NULL OR @Id = ''
    BEGIN
        DECLARE @Next INT = ISNULL((
            SELECT MAX(TRY_CAST(SUBSTRING(IDMEMBRESIA, 4, 10) AS INT))
            FROM MEMBRESIA WHERE IDMEMBRESIA LIKE 'MEM%'
        ), 0) + 1;
        SET @Id = 'MEM' + RIGHT('000000' + CAST(@Next AS VARCHAR(10)), 6);
    END

    IF EXISTS (SELECT 1 FROM MEMBRESIA WHERE IDMEMBRESIA = @Id)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'La membresía ya existe.'; RETURN; END

    INSERT INTO MEMBRESIA (
        IDMEMBRESIA, FECHAINICIO, FECHAFIN, ESTADOMIEMBRO, MONTOTOTAL, OBSERVACIONES,
        FECHAREGISTRO, HORAREGISTRO, IDPLAN, IDAULA, IDTURNO, IDUSUARIO, REGISTRADOPOR,
        COMOENTERO, IDASESOR, FECHACANCELACION, ESTADO
    ) VALUES (
        @Id, @FechaInicio, @FechaFin, @EstadoMiembro, @MontoTotal, @Observaciones,
        dbo.fn_fecha_ddmmyyyy(), CONVERT(CHAR(8), GETDATE(), 108),
        @IdPlan, @IdAula, @IdTurno, @IdUsuario, @RegistradoPor,
        @ComoEntero, @IdAsesor, @FechaCancelacion, 'Activo'
    );

    IF @PagoInicial IS NOT NULL AND @PagoInicial > 0
    BEGIN
        DECLARE @IdPago NVARCHAR(50) = 'PAG' + RIGHT('000000' + CAST((
            ISNULL((SELECT MAX(TRY_CAST(SUBSTRING(IDPAGOMEMBRESIA, 4, 10) AS INT))
                    FROM PAGOMEMBRESIA WHERE IDPAGOMEMBRESIA LIKE 'PAG%'), 0) + 1
        ) AS VARCHAR(10)), 6);

        INSERT INTO PAGOMEMBRESIA (
            IDPAGOMEMBRESIA, MONTO, FECHAPAGO, HORAPAGO, OBSERVACIONES,
            IDMEMBRESIA, IDMETODOPAGO, IDUSUARIO
        ) VALUES (
            @IdPago, @PagoInicial, dbo.fn_fecha_ddmmyyyy(), CONVERT(CHAR(8), GETDATE(), 108),
            'Pago inicial', @Id, @IdMetodoPago, @RegistradoPor
        );
    END

    SET @Resultado = 1; SET @Mensaje = 'Membresía registrada.';
END;
GO

IF OBJECT_ID('dbo.usp_membresia_actualizar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_membresia_actualizar;
GO
CREATE PROCEDURE dbo.usp_membresia_actualizar
    @Id                 NVARCHAR(50),
    @IdUsuario          NVARCHAR(50),
    @IdPlan             NVARCHAR(50),
    @IdTurno            NVARCHAR(50)  = NULL,
    @EstadoMiembro      INT,
    @FechaInicio        CHAR(8),
    @FechaFin           CHAR(8),
    @MontoTotal         DECIMAL(10,2),
    @ComoEntero         NVARCHAR(100) = NULL,
    @IdAula             NVARCHAR(50)  = NULL,
    @IdAsesor           NVARCHAR(50)  = NULL,
    @Observaciones      NVARCHAR(MAX) = NULL,
    @FechaCancelacion   CHAR(8)       = NULL,
    @Resultado          INT OUTPUT,
    @Mensaje            NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM MEMBRESIA WHERE IDMEMBRESIA = @Id)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'La membresía no existe.'; RETURN; END
    IF NOT EXISTS (SELECT 1 FROM USUARIO WHERE IDUSUARIO = @IdUsuario AND IDTIPOUSUARIO = '1')
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El estudiante no es válido.'; RETURN; END
    IF NOT EXISTS (SELECT 1 FROM [PLAN] WHERE IDPLAN = @IdPlan)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El plan no es válido.'; RETURN; END

    IF @IdAsesor IS NOT NULL AND @IdAsesor <> ''
       AND NOT EXISTS (SELECT 1 FROM ASESOR WHERE IDASESOR = @IdAsesor AND ACTIVO = 1)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El asesor seleccionado no es válido.'; RETURN; END

    UPDATE MEMBRESIA SET
        IDUSUARIO        = @IdUsuario,
        IDPLAN           = @IdPlan,
        IDTURNO          = @IdTurno,
        ESTADOMIEMBRO    = @EstadoMiembro,
        FECHAINICIO      = @FechaInicio,
        FECHAFIN         = @FechaFin,
        MONTOTOTAL       = @MontoTotal,
        COMOENTERO       = @ComoEntero,
        IDAULA           = @IdAula,
        IDASESOR         = @IdAsesor,
        OBSERVACIONES    = @Observaciones,
        FECHACANCELACION = @FechaCancelacion
    WHERE IDMEMBRESIA = @Id;

    SET @Resultado = 1; SET @Mensaje = 'Membresía actualizada.';
END;
GO

PRINT 'usp_membresia actualizados con IDASESOR.';
GO
