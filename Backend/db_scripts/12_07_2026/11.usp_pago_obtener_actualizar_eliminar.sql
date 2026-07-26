/* ============================================================================
   Pagos: obtener, actualizar y eliminar
   Ejecutar después de 10.comoentero_a_usuario.sql
   Fecha: 12/07/2026
   ============================================================================ */

IF OBJECT_ID('dbo.usp_pago_obtener', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_pago_obtener;
GO
CREATE PROCEDURE dbo.usp_pago_obtener
    @Id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.IDPAGOMEMBRESIA,
        p.IDMEMBRESIA,
        p.MONTO,
        p.FECHAPAGO,
        p.HORAPAGO,
        p.OBSERVACIONES,
        p.IDMETODOPAGO,
        ISNULL(mp.TITULO, '') AS METODOPAGO_TITULO,
        m.IDUSUARIO,
        UPPER(LTRIM(RTRIM(ISNULL(u.APELLIDO, '') + ' ' + ISNULL(u.NOMBRE, '')))) AS ESTUDIANTE_NOMBRE,
        u.DNI AS ESTUDIANTE_DNI,
        pl.NOMBRE AS PLAN_NOMBRE,
        m.MONTOTOTAL,
        ISNULL(pag.PAGADO, 0) AS PAGADO,
        CASE
            WHEN ISNULL(m.MONTOTOTAL, 0) - ISNULL(pag.PAGADO, 0) < 0 THEN 0
            ELSE ISNULL(m.MONTOTOTAL, 0) - ISNULL(pag.PAGADO, 0)
        END AS DEUDA
    FROM PAGOMEMBRESIA p
    INNER JOIN MEMBRESIA m ON m.IDMEMBRESIA = p.IDMEMBRESIA
    INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
    INNER JOIN [PLAN] pl ON pl.IDPLAN = m.IDPLAN
    LEFT JOIN METODO_PAGO mp ON mp.IDMETODOPAGO = p.IDMETODOPAGO
    OUTER APPLY (
        SELECT SUM(x.MONTO) AS PAGADO
        FROM PAGOMEMBRESIA x
        WHERE x.IDMEMBRESIA = m.IDMEMBRESIA
    ) pag
    WHERE p.IDPAGOMEMBRESIA = @Id;
END;
GO

IF OBJECT_ID('dbo.usp_pago_actualizar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_pago_actualizar;
GO
CREATE PROCEDURE dbo.usp_pago_actualizar
    @Id             NVARCHAR(50),
    @Monto          DECIMAL(10,2),
    @IdMetodoPago   NVARCHAR(50),
    @FechaPago      CHAR(8) = NULL,
    @Observaciones  NVARCHAR(MAX) = NULL,
    @Resultado      INT OUTPUT,
    @Mensaje        NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM PAGOMEMBRESIA WHERE IDPAGOMEMBRESIA = @Id)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El pago no existe.'; RETURN; END
    IF @Monto IS NULL OR @Monto <= 0
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ingrese un monto válido.'; RETURN; END
    IF @IdMetodoPago IS NULL OR @IdMetodoPago = ''
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Indique el método de pago.'; RETURN; END
    IF NOT EXISTS (SELECT 1 FROM METODO_PAGO WHERE IDMETODOPAGO = @IdMetodoPago AND ACTIVO = 1)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El método de pago no es válido.'; RETURN; END

    DECLARE @IdMembresia NVARCHAR(50);
    DECLARE @MontoAnterior DECIMAL(10,2);
    DECLARE @MontoTotal DECIMAL(10,2);
    DECLARE @PagadoOtros DECIMAL(10,2);
    DECLARE @Maximo DECIMAL(10,2);

    SELECT @IdMembresia = IDMEMBRESIA, @MontoAnterior = MONTO
    FROM PAGOMEMBRESIA WHERE IDPAGOMEMBRESIA = @Id;

    SELECT @MontoTotal = ISNULL(MONTOTOTAL, 0) FROM MEMBRESIA WHERE IDMEMBRESIA = @IdMembresia;
    SELECT @PagadoOtros = ISNULL(SUM(MONTO), 0)
    FROM PAGOMEMBRESIA
    WHERE IDMEMBRESIA = @IdMembresia AND IDPAGOMEMBRESIA <> @Id;

    SET @Maximo = @MontoTotal - @PagadoOtros;
    IF @Maximo < 0 SET @Maximo = 0;
    IF @Monto > @Maximo
    BEGIN
        SET @Resultado = 0;
        SET @Mensaje = 'El monto no puede superar S/ ' + CAST(@Maximo AS NVARCHAR(20)) + '.';
        RETURN;
    END

    UPDATE PAGOMEMBRESIA SET
        MONTO          = @Monto,
        IDMETODOPAGO   = @IdMetodoPago,
        FECHAPAGO      = CASE WHEN @FechaPago IS NOT NULL AND @FechaPago <> '' THEN @FechaPago ELSE FECHAPAGO END,
        OBSERVACIONES  = @Observaciones
    WHERE IDPAGOMEMBRESIA = @Id;

    SET @Resultado = 1;
    SET @Mensaje = 'Pago actualizado.';
END;
GO

IF OBJECT_ID('dbo.usp_pago_eliminar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_pago_eliminar;
GO
CREATE PROCEDURE dbo.usp_pago_eliminar
    @Id         NVARCHAR(50),
    @Resultado  INT OUTPUT,
    @Mensaje    NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM PAGOMEMBRESIA WHERE IDPAGOMEMBRESIA = @Id)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El pago no existe.'; RETURN; END

    DELETE FROM PAGOMEMBRESIA WHERE IDPAGOMEMBRESIA = @Id;

    SET @Resultado = 1;
    SET @Mensaje = 'Pago eliminado.';
END;
GO

PRINT 'SPs pago obtener / actualizar / eliminar creados.';
GO
