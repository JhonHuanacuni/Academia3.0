/* ============================================================================
   CRUD PAGOEXTRAORDINARIO
   Prerequisito: 3.pago_extraordinario_tabla.sql
   Fecha: 16/07/2026
   ============================================================================ */

IF OBJECT_ID('dbo.usp_pagoextra_listar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_pagoextra_listar;
GO
CREATE PROCEDURE dbo.usp_pagoextra_listar
    @Buscar         NVARCHAR(200) = NULL,
    @OrdenarPor     NVARCHAR(50)  = 'FECHAPAGO',
    @Direccion      NVARCHAR(4)   = 'DESC',
    @Pagina         INT           = 1,
    @TamanioPagina  INT           = 10,
    @TotalRegistros INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF @Pagina < 1 SET @Pagina = 1;
    IF @TamanioPagina < 1 SET @TamanioPagina = 10;

    SELECT @TotalRegistros = COUNT(*)
    FROM PAGOEXTRAORDINARIO p
    INNER JOIN USUARIO u ON u.IDUSUARIO = p.IDUSUARIO
    INNER JOIN CONCEPTOPAGOEXTRA c ON c.IDCONCEPTO = p.IDCONCEPTO
    WHERE (@Buscar IS NULL OR @Buscar = '' OR
           p.IDPAGOEXTRA LIKE '%' + @Buscar + '%' OR
           u.NOMBRE LIKE '%' + @Buscar + '%' OR
           u.APELLIDO LIKE '%' + @Buscar + '%' OR
           u.DNI LIKE '%' + @Buscar + '%' OR
           c.NOMBRE LIKE '%' + @Buscar + '%');

    SELECT
        p.IDPAGOEXTRA,
        p.IDUSUARIO,
        UPPER(LTRIM(RTRIM(ISNULL(u.APELLIDO, '') + ' ' + ISNULL(u.NOMBRE, '')))) AS ESTUDIANTE_NOMBRE,
        u.DNI AS ESTUDIANTE_DNI,
        p.IDCONCEPTO,
        c.NOMBRE AS CONCEPTO_NOMBRE,
        p.MONTO,
        p.FECHAPAGO,
        p.FECHAINICIO,
        p.FECHAFIN,
        p.OBSERVACIONES
    FROM PAGOEXTRAORDINARIO p
    INNER JOIN USUARIO u ON u.IDUSUARIO = p.IDUSUARIO
    INNER JOIN CONCEPTOPAGOEXTRA c ON c.IDCONCEPTO = p.IDCONCEPTO
    WHERE (@Buscar IS NULL OR @Buscar = '' OR
           p.IDPAGOEXTRA LIKE '%' + @Buscar + '%' OR
           u.NOMBRE LIKE '%' + @Buscar + '%' OR
           u.APELLIDO LIKE '%' + @Buscar + '%' OR
           u.DNI LIKE '%' + @Buscar + '%' OR
           c.NOMBRE LIKE '%' + @Buscar + '%')
    ORDER BY
        CASE WHEN @OrdenarPor = 'FECHAPAGO' AND @Direccion = 'ASC'  THEN p.FECHAPAGO END ASC,
        CASE WHEN @OrdenarPor = 'FECHAPAGO' AND @Direccion = 'DESC' THEN p.FECHAPAGO END DESC,
        CASE WHEN @OrdenarPor = 'MONTO' AND @Direccion = 'ASC' THEN p.MONTO END ASC,
        CASE WHEN @OrdenarPor = 'MONTO' AND @Direccion = 'DESC' THEN p.MONTO END DESC,
        CASE WHEN @OrdenarPor = 'ESTUDIANTE_NOMBRE' AND @Direccion = 'ASC' THEN u.APELLIDO END ASC,
        CASE WHEN @OrdenarPor = 'ESTUDIANTE_NOMBRE' AND @Direccion = 'DESC' THEN u.APELLIDO END DESC,
        CASE WHEN @OrdenarPor = 'CONCEPTO_NOMBRE' AND @Direccion = 'ASC' THEN c.NOMBRE END ASC,
        CASE WHEN @OrdenarPor = 'CONCEPTO_NOMBRE' AND @Direccion = 'DESC' THEN c.NOMBRE END DESC,
        p.FECHAPAGO DESC, p.IDPAGOEXTRA DESC
    OFFSET (@Pagina - 1) * @TamanioPagina ROWS
    FETCH NEXT @TamanioPagina ROWS ONLY;
END;
GO

IF OBJECT_ID('dbo.usp_pagoextra_obtener', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_pagoextra_obtener;
GO
CREATE PROCEDURE dbo.usp_pagoextra_obtener
    @Id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.IDPAGOEXTRA,
        p.IDUSUARIO,
        UPPER(LTRIM(RTRIM(ISNULL(u.APELLIDO, '') + ' ' + ISNULL(u.NOMBRE, '')))) AS ESTUDIANTE_NOMBRE,
        u.DNI AS ESTUDIANTE_DNI,
        p.IDCONCEPTO,
        c.NOMBRE AS CONCEPTO_NOMBRE,
        c.COSTO AS CONCEPTO_COSTO,
        p.MONTO,
        p.FECHAPAGO,
        p.FECHAINICIO,
        p.FECHAFIN,
        p.OBSERVACIONES
    FROM PAGOEXTRAORDINARIO p
    INNER JOIN USUARIO u ON u.IDUSUARIO = p.IDUSUARIO
    INNER JOIN CONCEPTOPAGOEXTRA c ON c.IDCONCEPTO = p.IDCONCEPTO
    WHERE p.IDPAGOEXTRA = @Id;
END;
GO

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

IF OBJECT_ID('dbo.usp_pagoextra_actualizar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_pagoextra_actualizar;
GO
CREATE PROCEDURE dbo.usp_pagoextra_actualizar
    @Id            NVARCHAR(50),
    @IdConcepto    NVARCHAR(50),
    @Monto         DECIMAL(10,2),
    @FechaPago     CHAR(8),
    @FechaInicio   CHAR(8),
    @FechaFin      CHAR(8),
    @Observaciones NVARCHAR(MAX) = NULL,
    @Resultado     INT OUTPUT,
    @Mensaje       NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM PAGOEXTRAORDINARIO WHERE IDPAGOEXTRA = @Id)
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'El pago no existe.';
        RETURN;
    END

    IF @IdConcepto IS NULL OR LTRIM(RTRIM(@IdConcepto)) = ''
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'Selecciona un concepto.';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM CONCEPTOPAGOEXTRA WHERE IDCONCEPTO = @IdConcepto)
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'El concepto no existe.';
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
       OR @FechaFin IS NULL OR LEN(@FechaFin) <> 8
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'Ingresa las fechas de inicio y fin.';
        RETURN;
    END

    UPDATE PAGOEXTRAORDINARIO SET
        IDCONCEPTO = @IdConcepto,
        MONTO = @Monto,
        FECHAPAGO = @FechaPago,
        FECHAINICIO = @FechaInicio,
        FECHAFIN = @FechaFin,
        OBSERVACIONES = @Observaciones
    WHERE IDPAGOEXTRA = @Id;

    SET @Resultado = 1; SET @Mensaje = 'Pago extraordinario actualizado.';
END;
GO

IF OBJECT_ID('dbo.usp_pagoextra_eliminar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_pagoextra_eliminar;
GO
CREATE PROCEDURE dbo.usp_pagoextra_eliminar
    @Id        NVARCHAR(50),
    @Resultado INT OUTPUT,
    @Mensaje   NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM PAGOEXTRAORDINARIO WHERE IDPAGOEXTRA = @Id)
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'El pago no existe.';
        RETURN;
    END

    DELETE FROM PAGOEXTRAORDINARIO WHERE IDPAGOEXTRA = @Id;

    SET @Resultado = 1; SET @Mensaje = 'Pago extraordinario eliminado.';
END;
GO

PRINT 'SPs usp_pagoextra_* creados.';
GO
