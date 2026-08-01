-- Convertido automáticamente desde db_scripts/26_07_2026/19.usp_mensualidad_listar_pagos.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   usp_mensualidad_listar_pagos
   Ejecutar después de 18.usp_usuario_resetear_contra.sql
   Fecha: 27/07/2026
   ============================================================================ */

DROP PROCEDURE IF EXISTS usp_mensualidad_listar_pagos;

DROP PROCEDURE IF EXISTS usp_mensualidad_listar_pagos;

DELIMITER $$

CREATE PROCEDURE usp_mensualidad_listar_pagos(
    IN p_IdMensualidad VARCHAR(50)
)
main: BEGIN
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = p_IdMensualidad) THEN
        RAISERROR('La mensualidad no existe.', 16, 1);
        LEAVE main;
    
    SELECT
        p.IDPAGOMENSUALIDAD,
        p.MONTO,
        p.FECHAPAGO,
        p.HORAPAGO,
        p.OBSERVACIONES,
        IFNULL(mp.TITULO, '') AS METODOPAGO_TITULO,
        UPPER(TRIM(
            CONCAT(IFNULL(reg.APELLIDO, ''), ' ') + IFNULL(reg.NOMBRE, '')
        ))) AS REGISTRADO_POR
    FROM PAGOMENSUALIDAD p
    LEFT JOIN METODO_PAGO mp ON mp.IDMETODOPAGO = p.IDMETODOPAGO
    LEFT JOIN USUARIO reg ON reg.IDUSUARIO = p.IDUSUARIO
    WHERE p.IDMENSUALIDAD = p_IdMensualidad
    ORDER BY p.FECHAPAGO DESC, p.HORAPAGO DESC, p.IDPAGOMENSUALIDAD DESC;
END;

SELECT 'usp_mensualidad_listar_pagos listo.';
END$$

DELIMITER ;