/* ============================================================================
   Pagos: detalle de pagos de una mensualidad (modal del listado agrupado)
   Fecha: 24/08/2026
   ============================================================================ */

IF OBJECT_ID('dbo.usp_pago_listar_detalle', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_pago_listar_detalle;
GO
CREATE PROCEDURE dbo.usp_pago_listar_detalle
    @IdMensualidad NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.IDPAGOMENSUALIDAD,
        p.IDMENSUALIDAD,
        p.IDCUOTA,
        c.NUMERO AS CUOTA_NUMERO,
        p.MONTO,
        ISNULL(p.MORA, 0) AS MORA,
        p.MONTO + ISNULL(p.MORA, 0) AS TOTAL_COBRADO,
        p.FECHAPAGO,
        p.HORAPAGO,
        p.IDMETODOPAGO,
        ISNULL(mp.TITULO, '') AS METODOPAGO_TITULO,
        p.OBSERVACIONES,
        UPPER(LTRIM(RTRIM(ISNULL(u.APELLIDO, '') + ' ' + ISNULL(u.NOMBRE, '')))) AS ESTUDIANTE_NOMBRE,
        pl.NOMBRE AS PLAN_NOMBRE
    FROM PAGOMENSUALIDAD p
    INNER JOIN MENSUALIDAD m ON m.IDMENSUALIDAD = p.IDMENSUALIDAD
    INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
    INNER JOIN [PLAN] pl ON pl.IDPLAN = m.IDPLAN
    LEFT JOIN MENSUALIDAD_CUOTA c ON c.IDCUOTA = p.IDCUOTA
    LEFT JOIN METODO_PAGO mp ON mp.IDMETODOPAGO = p.IDMETODOPAGO
    WHERE p.IDMENSUALIDAD = @IdMensualidad
    ORDER BY
        SUBSTRING(p.FECHAPAGO, 5, 4) + SUBSTRING(p.FECHAPAGO, 3, 2) + SUBSTRING(p.FECHAPAGO, 1, 2) DESC,
        p.HORAPAGO DESC,
        p.IDPAGOMENSUALIDAD DESC;
END;
GO

PRINT 'usp_pago_listar_detalle listo.';
GO
