/* ============================================================================
   Pago extraordinario: fechas inicio/fin salen del concepto (no del formulario)
   Ejecutar después de 7.concepto_fechas_vigencia.sql
   Fecha: 16/07/2026
   ============================================================================ */

IF OBJECT_ID('dbo.usp_pagoextra_insertar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_pagoextra_insertar;
GO
CREATE PROCEDURE dbo.usp_pagoextra_insertar
    @IdUsuario     NVARCHAR(50),
    @IdConcepto    NVARCHAR(50),
    @Monto         DECIMAL(10,2),
    @FechaPago     CHAR(8),
    @FechaInicio   CHAR(8) = NULL,
    @FechaFin      CHAR(8) = NULL,
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

    -- Vigencia del pago = vigencia del concepto
    SELECT @FechaInicio = FECHAINICIO, @FechaFin = FECHAFIN
    FROM CONCEPTOPAGOEXTRA
    WHERE IDCONCEPTO = @IdConcepto;

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
    @FechaInicio   CHAR(8) = NULL,
    @FechaFin      CHAR(8) = NULL,
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

    SELECT @FechaInicio = FECHAINICIO, @FechaFin = FECHAFIN
    FROM CONCEPTOPAGOEXTRA
    WHERE IDCONCEPTO = @IdConcepto;

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

PRINT 'Pago extraordinario: fechas tomadas del concepto.';
GO
