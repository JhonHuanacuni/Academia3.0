/* ============================================================================
   CONCEPTOPAGOEXTRA — fechas de vigencia (inicio / fin)
   + actualizar SPs y catálogo filtrado
   Fecha: 16/07/2026
   ============================================================================ */

IF COL_LENGTH('dbo.CONCEPTOPAGOEXTRA', 'FECHAINICIO') IS NULL
BEGIN
    ALTER TABLE dbo.CONCEPTOPAGOEXTRA ADD FECHAINICIO CHAR(8) NULL
        CHECK (FECHAINICIO LIKE '[0-3][0-9][0-1][0-9][0-9][0-9][0-9][0-9]');
END
GO

IF COL_LENGTH('dbo.CONCEPTOPAGOEXTRA', 'FECHAFIN') IS NULL
BEGIN
    ALTER TABLE dbo.CONCEPTOPAGOEXTRA ADD FECHAFIN CHAR(8) NULL
        CHECK (FECHAFIN LIKE '[0-3][0-9][0-1][0-9][0-9][0-9][0-9][0-9]');
END
GO

IF OBJECT_ID('dbo.usp_concepto_listar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_concepto_listar;
GO
CREATE PROCEDURE dbo.usp_concepto_listar
    @Buscar         NVARCHAR(200) = NULL,
    @Estado         NVARCHAR(50)  = NULL,
    @OrdenarPor     NVARCHAR(50)  = 'NOMBRE',
    @Direccion      NVARCHAR(4)   = 'ASC',
    @Pagina         INT           = 1,
    @TamanioPagina  INT           = 10,
    @TotalRegistros INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF @Pagina < 1 SET @Pagina = 1;
    IF @TamanioPagina < 1 SET @TamanioPagina = 10;

    SELECT @TotalRegistros = COUNT(*)
    FROM CONCEPTOPAGOEXTRA c
    WHERE (@Buscar IS NULL OR @Buscar = '' OR
           c.IDCONCEPTO LIKE '%' + @Buscar + '%' OR
           c.NOMBRE     LIKE '%' + @Buscar + '%')
      AND (@Estado IS NULL OR @Estado = '' OR
           (@Estado = 'Activo' AND c.ACTIVO = 1) OR
           (@Estado = 'Inactivo' AND c.ACTIVO = 0));

    SELECT
        c.IDCONCEPTO,
        c.NOMBRE,
        c.COSTO,
        c.FECHAINICIO,
        c.FECHAFIN,
        CASE WHEN c.ACTIVO = 1 THEN 'Activo' ELSE 'Inactivo' END AS ESTADO
    FROM CONCEPTOPAGOEXTRA c
    WHERE (@Buscar IS NULL OR @Buscar = '' OR
           c.IDCONCEPTO LIKE '%' + @Buscar + '%' OR
           c.NOMBRE     LIKE '%' + @Buscar + '%')
      AND (@Estado IS NULL OR @Estado = '' OR
           (@Estado = 'Activo' AND c.ACTIVO = 1) OR
           (@Estado = 'Inactivo' AND c.ACTIVO = 0))
    ORDER BY
        CASE WHEN @OrdenarPor = 'IDCONCEPTO' AND @Direccion = 'ASC'  THEN c.IDCONCEPTO END ASC,
        CASE WHEN @OrdenarPor = 'IDCONCEPTO' AND @Direccion = 'DESC' THEN c.IDCONCEPTO END DESC,
        CASE WHEN @OrdenarPor = 'NOMBRE'     AND @Direccion = 'ASC'  THEN c.NOMBRE END ASC,
        CASE WHEN @OrdenarPor = 'NOMBRE'     AND @Direccion = 'DESC' THEN c.NOMBRE END DESC,
        CASE WHEN @OrdenarPor = 'COSTO'      AND @Direccion = 'ASC'  THEN c.COSTO END ASC,
        CASE WHEN @OrdenarPor = 'COSTO'      AND @Direccion = 'DESC' THEN c.COSTO END DESC,
        CASE WHEN @OrdenarPor = 'FECHAINICIO' AND @Direccion = 'ASC' THEN c.FECHAINICIO END ASC,
        CASE WHEN @OrdenarPor = 'FECHAINICIO' AND @Direccion = 'DESC' THEN c.FECHAINICIO END DESC,
        CASE WHEN @OrdenarPor = 'FECHAFIN' AND @Direccion = 'ASC' THEN c.FECHAFIN END ASC,
        CASE WHEN @OrdenarPor = 'FECHAFIN' AND @Direccion = 'DESC' THEN c.FECHAFIN END DESC,
        CASE WHEN @OrdenarPor = 'ESTADO'     AND @Direccion = 'ASC'  THEN c.ACTIVO END ASC,
        CASE WHEN @OrdenarPor = 'ESTADO'     AND @Direccion = 'DESC' THEN c.ACTIVO END DESC,
        c.NOMBRE
    OFFSET (@Pagina - 1) * @TamanioPagina ROWS
    FETCH NEXT @TamanioPagina ROWS ONLY;
END;
GO

IF OBJECT_ID('dbo.usp_concepto_obtener', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_concepto_obtener;
GO
CREATE PROCEDURE dbo.usp_concepto_obtener
    @Id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        c.IDCONCEPTO,
        c.NOMBRE,
        c.COSTO,
        c.FECHAINICIO,
        c.FECHAFIN,
        CASE WHEN c.ACTIVO = 1 THEN 'Activo' ELSE 'Inactivo' END AS ESTADO
    FROM CONCEPTOPAGOEXTRA c
    WHERE c.IDCONCEPTO = @Id;
END;
GO

IF OBJECT_ID('dbo.usp_concepto_insertar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_concepto_insertar;
GO
CREATE PROCEDURE dbo.usp_concepto_insertar
    @Nombre      NVARCHAR(150),
    @Costo       DECIMAL(10,2),
    @FechaInicio CHAR(8),
    @FechaFin    CHAR(8),
    @Estado      NVARCHAR(50) = 'Activo',
    @IdGenerado  NVARCHAR(50) OUTPUT,
    @Resultado   INT OUTPUT,
    @Mensaje     NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @IdGenerado = NULL;

    IF @Nombre IS NULL OR LTRIM(RTRIM(@Nombre)) = ''
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'Ingresa el nombre del concepto.';
        RETURN;
    END

    IF @Costo IS NULL OR @Costo < 0
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'Ingresa un costo válido.';
        RETURN;
    END

    IF @FechaInicio IS NULL OR LEN(@FechaInicio) <> 8
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'Ingresa la fecha de inicio.';
        RETURN;
    END

    IF @FechaFin IS NULL OR LEN(@FechaFin) <> 8
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'Ingresa la fecha final.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM CONCEPTOPAGOEXTRA WHERE NOMBRE = @Nombre)
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'Ya existe un concepto con ese nombre.';
        RETURN;
    END

    DECLARE @NextNum INT;
    SELECT @NextNum = ISNULL(MAX(TRY_CAST(REPLACE(IDCONCEPTO, 'CON', '') AS INT)), 0) + 1
    FROM CONCEPTOPAGOEXTRA;
    SET @IdGenerado = 'CON' + RIGHT('000' + CAST(@NextNum AS VARCHAR(3)), 3);

    INSERT INTO CONCEPTOPAGOEXTRA (IDCONCEPTO, NOMBRE, COSTO, FECHAINICIO, FECHAFIN, ACTIVO)
    VALUES (
        @IdGenerado,
        @Nombre,
        @Costo,
        @FechaInicio,
        @FechaFin,
        CASE WHEN @Estado = 'Activo' THEN 1 ELSE 0 END
    );

    SET @Resultado = 1; SET @Mensaje = 'Concepto registrado.';
END;
GO

IF OBJECT_ID('dbo.usp_concepto_actualizar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_concepto_actualizar;
GO
CREATE PROCEDURE dbo.usp_concepto_actualizar
    @Id          NVARCHAR(50),
    @Nombre      NVARCHAR(150),
    @Costo       DECIMAL(10,2),
    @FechaInicio CHAR(8),
    @FechaFin    CHAR(8),
    @Estado      NVARCHAR(50) = 'Activo',
    @Resultado   INT OUTPUT,
    @Mensaje     NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM CONCEPTOPAGOEXTRA WHERE IDCONCEPTO = @Id)
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'El concepto no existe.';
        RETURN;
    END

    IF @Nombre IS NULL OR LTRIM(RTRIM(@Nombre)) = ''
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'Ingresa el nombre del concepto.';
        RETURN;
    END

    IF @Costo IS NULL OR @Costo < 0
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'Ingresa un costo válido.';
        RETURN;
    END

    IF @FechaInicio IS NULL OR LEN(@FechaInicio) <> 8
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'Ingresa la fecha de inicio.';
        RETURN;
    END

    IF @FechaFin IS NULL OR LEN(@FechaFin) <> 8
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'Ingresa la fecha final.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM CONCEPTOPAGOEXTRA WHERE NOMBRE = @Nombre AND IDCONCEPTO <> @Id)
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'Ya existe un concepto con ese nombre.';
        RETURN;
    END

    UPDATE CONCEPTOPAGOEXTRA SET
        NOMBRE = @Nombre,
        COSTO = @Costo,
        FECHAINICIO = @FechaInicio,
        FECHAFIN = @FechaFin,
        ACTIVO = CASE WHEN @Estado = 'Activo' THEN 1 ELSE 0 END
    WHERE IDCONCEPTO = @Id;

    SET @Resultado = 1; SET @Mensaje = 'Concepto actualizado.';
END;
GO

PRINT 'Concepto: fechas de vigencia + SPs actualizados.';
GO

-- Asegura validación de vigencia al registrar pago extraordinario
IF OBJECT_ID('dbo.usp_pagoextra_insertar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_pagoextra_insertar;
GO
CREATE PROCEDURE dbo.usp_pagoextra_insertar
    @IdUsuario     NVARCHAR(50),
    @IdConcepto    NVARCHAR(50),
    @Monto         DECIMAL(10,2),
    @FechaPago     CHAR(8),
    @FechaInicio   CHAR(8),
    @FechaFin      CHAR(8),
    @Observaciones NVARCHAR(MAX) = NULL,
    @IdRegistrador NVARCHAR(50) = NULL,
    @IdGenerado    NVARCHAR(50) OUTPUT,
    @Resultado     INT OUTPUT,
    @Mensaje       NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @IdGenerado = NULL;

    IF @IdUsuario IS NULL OR LTRIM(RTRIM(@IdUsuario)) = ''
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'Selecciona un estudiante.';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM USUARIO WHERE IDUSUARIO = @IdUsuario)
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'El estudiante no existe.';
        RETURN;
    END

    IF @IdConcepto IS NULL OR LTRIM(RTRIM(@IdConcepto)) = ''
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'Selecciona un concepto.';
        RETURN;
    END

    IF NOT EXISTS (
        SELECT 1 FROM CONCEPTOPAGOEXTRA
        WHERE IDCONCEPTO = @IdConcepto
          AND ACTIVO = 1
          AND FECHAINICIO IS NOT NULL AND LEN(FECHAINICIO) = 8
          AND FECHAFIN IS NOT NULL AND LEN(FECHAFIN) = 8
          AND CAST(GETDATE() AS DATE) >= CONVERT(DATE,
                SUBSTRING(FECHAINICIO, 5, 4) + SUBSTRING(FECHAINICIO, 3, 2) + SUBSTRING(FECHAINICIO, 1, 2), 112)
          AND CAST(GETDATE() AS DATE) <= CONVERT(DATE,
                SUBSTRING(FECHAFIN, 5, 4) + SUBSTRING(FECHAFIN, 3, 2) + SUBSTRING(FECHAFIN, 1, 2), 112)
    )
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'El concepto no está activo o no está vigente en la fecha actual.';
        RETURN;
    END

    IF @Monto IS NULL OR @Monto <= 0
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'Ingresa un monto válido.';
        RETURN;
    END

    IF @FechaPago IS NULL OR LEN(@FechaPago) <> 8
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'Ingresa la fecha del pago.';
        RETURN;
    END

    IF @FechaInicio IS NULL OR LEN(@FechaInicio) <> 8
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'Ingresa la fecha de inicio.';
        RETURN;
    END

    IF @FechaFin IS NULL OR LEN(@FechaFin) <> 8
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'Ingresa la fecha final.';
        RETURN;
    END

    DECLARE @NextNum INT;
    SELECT @NextNum = ISNULL(MAX(TRY_CAST(REPLACE(IDPAGOEXTRA, 'PEX', '') AS INT)), 0) + 1
    FROM PAGOEXTRAORDINARIO;
    SET @IdGenerado = 'PEX' + RIGHT('00000' + CAST(@NextNum AS VARCHAR(5)), 5);

    INSERT INTO PAGOEXTRAORDINARIO (
        IDPAGOEXTRA, IDUSUARIO, IDCONCEPTO, MONTO,
        FECHAPAGO, FECHAINICIO, FECHAFIN, OBSERVACIONES, IDREGISTRADOR
    )
    VALUES (
        @IdGenerado, @IdUsuario, @IdConcepto, @Monto,
        @FechaPago, @FechaInicio, @FechaFin, @Observaciones, @IdRegistrador
    );

    SET @Resultado = 1; SET @Mensaje = 'Pago extraordinario registrado.';
END;
GO

PRINT 'usp_pagoextra_insertar: valida concepto activo y vigente.';
GO
