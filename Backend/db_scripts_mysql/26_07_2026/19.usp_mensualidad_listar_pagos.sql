-- ============================================================================
-- usp_mensualidad_listar_pagos — MySQL 8
-- Ejecutar después de 18.usp_usuario_resetear_contra.sql
-- Fecha: 27/07/2026
-- ============================================================================

USE `AcademiaDB`;

DROP PROCEDURE IF EXISTS usp_mensualidad_listar_pagos;

DELIMITER $$

CREATE PROCEDURE usp_mensualidad_listar_pagos(IN p_IdMensualidad VARCHAR(50))
main: BEGIN
    IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = p_IdMensualidad) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La mensualidad no existe.';
        LEAVE main;
    END IF;

    SELECT
        p.IDPAGOMENSUALIDAD,
        p.MONTO,
        p.FECHAPAGO,
        p.HORAPAGO,
        p.OBSERVACIONES,
        IFNULL(mp.TITULO, '') AS METODOPAGO_TITULO,
        UPPER(TRIM(CONCAT(IFNULL(reg.APELLIDO, ''), ' ', IFNULL(reg.NOMBRE, '')))) AS REGISTRADO_POR
    FROM PAGOMENSUALIDAD p
    LEFT JOIN METODO_PAGO mp ON mp.IDMETODOPAGO = p.IDMETODOPAGO
    LEFT JOIN USUARIO reg ON reg.IDUSUARIO = p.IDUSUARIO
    WHERE p.IDMENSUALIDAD = p_IdMensualidad
    ORDER BY p.FECHAPAGO DESC, p.HORAPAGO DESC, p.IDPAGOMENSUALIDAD DESC;
END$$

DELIMITER ;
