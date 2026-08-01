-- Convertido automáticamente desde db_scripts/16_07_2026/12.pago_membresias_costo_mensual.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   Pagos: últimas membresías incluyen COSTOMENSUAL del plan
   Ejecutar después de 11.plan_costo_mensual.sql
   Fecha: 16/07/2026
   ============================================================================ */

DROP PROCEDURE IF EXISTS usp_pago_membresias_estudiante;

DROP PROCEDURE IF EXISTS usp_pago_membresias_estudiante;

DELIMITER $$

CREATE PROCEDURE usp_pago_membresias_estudiante(
    IN p_IdUsuario VARCHAR(50)
)
main: BEGIN
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
        IFNULL(pag.PAGADO, 0) AS PAGADO,
        CASE
            WHEN IFNULL(m.MONTOTOTAL, 0) - IFNULL(pag.PAGADO, 0) < 0 THEN 0
            ELSE IFNULL(m.MONTOTOTAL, 0) - IFNULL(pag.PAGADO, 0)
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
    WHERE m.IDUSUARIO = p_IdUsuario
      AND m.ESTADO = 'Activo'
    ORDER BY m.FECHAREGISTRO DESC, m.IDMEMBRESIA DESC;
END;

SELECT 'usp_pago_membresias_estudiante: incluye PLAN_COSTOMENSUAL.';
END$$

DELIMITER ;
