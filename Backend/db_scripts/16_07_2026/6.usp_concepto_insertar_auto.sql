/* ============================================================================
   Concepto: código autoincremental (CON001, CON002...)
   NOTA: Si vas a ejecutar 7.concepto_fechas_vigencia.sql, ese script ya incluye
   el insertar actualizado con fechas. Este 6 solo aplica si aún no corriste el 7.
   Fecha: 16/07/2026
   ============================================================================ */

IF OBJECT_ID('dbo.usp_concepto_insertar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_concepto_insertar;
GO
CREATE PROCEDURE dbo.usp_concepto_insertar
    @Nombre     NVARCHAR(150),
    @Costo      DECIMAL(10,2),
    @Estado     NVARCHAR(50) = 'Activo',
    @IdGenerado NVARCHAR(50) OUTPUT,
    @Resultado  INT OUTPUT,
    @Mensaje    NVARCHAR(200) OUTPUT
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

    IF EXISTS (SELECT 1 FROM CONCEPTOPAGOEXTRA WHERE NOMBRE = @Nombre)
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'Ya existe un concepto con ese nombre.';
        RETURN;
    END

    DECLARE @NextNum INT;
    SELECT @NextNum = ISNULL(MAX(TRY_CAST(REPLACE(IDCONCEPTO, 'CON', '') AS INT)), 0) + 1
    FROM CONCEPTOPAGOEXTRA;
    SET @IdGenerado = 'CON' + RIGHT('000' + CAST(@NextNum AS VARCHAR(3)), 3);

    INSERT INTO CONCEPTOPAGOEXTRA (IDCONCEPTO, NOMBRE, COSTO, ACTIVO)
    VALUES (
        @IdGenerado,
        @Nombre,
        @Costo,
        CASE WHEN @Estado = 'Activo' THEN 1 ELSE 0 END
    );

    SET @Resultado = 1; SET @Mensaje = 'Concepto registrado.';
END;
GO

PRINT 'usp_concepto_insertar: código autoincremental (obsoleto si ya corriste el script 7).';
GO
