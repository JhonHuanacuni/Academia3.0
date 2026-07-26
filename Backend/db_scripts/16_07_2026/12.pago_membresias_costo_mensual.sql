/* ============================================================================
   Pagos: últimas membresías incluyen COSTOMENSUAL del plan
   Ejecutar después de 11.plan_costo_mensual.sql
   Fecha: 16/07/2026
   ============================================================================ */

IF OBJECT_ID('dbo.usp_pago_membresias_estudiante', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_pago_membresias_estudiante;
GO
CREATE PROCEDURE dbo.usp_pago_membresias_estudiante
    @IdUsuario NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP 3
        m.IDMEMBRESIA,
        m.IDPLAN,
        pl.NOMBRE AS PLAN_NOMBRE,
        pl.COSTOMENSUAL AS PLAN_COSTOMENSUAL,
        m.IDTURNO,
        m.IDAULA,
        m.IDASESOR,
        m.OBSERVACIONES,
        m.FECHAINICIO,
        m.FECHAFIN,
        m.MONTOTOTAL,
        ISNULL(pag.PAGADO, 0) AS PAGADO,
        CASE
            WHEN ISNULL(m.MONTOTOTAL, 0) - ISNULL(pag.PAGADO, 0) < 0 THEN 0
            ELSE ISNULL(m.MONTOTOTAL, 0) - ISNULL(pag.PAGADO, 0)
        END AS DEUDA,
        m.ESTADOMIEMBRO,
        CASE m.ESTADOMIEMBRO
            WHEN 2 THEN 'Activo'
            WHEN 3 THEN 'Vencido'
            ELSE 'Activo'
        END AS ESTADOMIEMBRO_DESCRIPCION,
        m.ESTADO,
        m.FECHAREGISTRO
    FROM MEMBRESIA m
    INNER JOIN [PLAN] pl ON pl.IDPLAN = m.IDPLAN
    OUTER APPLY (
        SELECT SUM(p.MONTO) AS PAGADO
        FROM PAGOMEMBRESIA p
        WHERE p.IDMEMBRESIA = m.IDMEMBRESIA
    ) pag
    WHERE m.IDUSUARIO = @IdUsuario
      AND m.ESTADO = 'Activo'
    ORDER BY m.FECHAREGISTRO DESC, m.IDMEMBRESIA DESC;
END;
GO

PRINT 'usp_pago_membresias_estudiante: incluye PLAN_COSTOMENSUAL.';
GO
