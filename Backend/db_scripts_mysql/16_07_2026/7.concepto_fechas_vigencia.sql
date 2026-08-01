-- ============================================================================
-- CONCEPTOPAGOEXTRA — fechas de vigencia + usp_pagoextra_insertar — MySQL 8
-- Fecha: 16/07/2026
-- ============================================================================

USE `AcademiaDB`;

SET @col_CONCEPTOPAGOEXTRA_FECHAINICIO := (
    SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'CONCEPTOPAGOEXTRA' AND COLUMN_NAME = 'FECHAINICIO'
);
SET @sql_CONCEPTOPAGOEXTRA_FECHAINICIO := IF(
    @col_CONCEPTOPAGOEXTRA_FECHAINICIO = 0,
    'ALTER TABLE CONCEPTOPAGOEXTRA ADD COLUMN FECHAINICIO CHAR(8) NULL',
    'SELECT 1'
);
PREPARE stmt FROM @sql_CONCEPTOPAGOEXTRA_FECHAINICIO;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @col_CONCEPTOPAGOEXTRA_FECHAFIN := (
    SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'CONCEPTOPAGOEXTRA' AND COLUMN_NAME = 'FECHAFIN'
);
SET @sql_CONCEPTOPAGOEXTRA_FECHAFIN := IF(
    @col_CONCEPTOPAGOEXTRA_FECHAFIN = 0,
    'ALTER TABLE CONCEPTOPAGOEXTRA ADD COLUMN FECHAFIN CHAR(8) NULL',
    'SELECT 1'
);
PREPARE stmt FROM @sql_CONCEPTOPAGOEXTRA_FECHAFIN;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

DROP PROCEDURE IF EXISTS usp_pagoextra_insertar;

DELIMITER $$

CREATE PROCEDURE usp_pagoextra_insertar(
    IN p_IdUsuario VARCHAR(50),
    IN p_IdConcepto VARCHAR(50),
    IN p_Monto DECIMAL(10,2),
    IN p_FechaPago CHAR(8),
    IN p_FechaInicio CHAR(8),
    IN p_FechaFin CHAR(8),
    IN p_Observaciones LONGTEXT,
    IN p_IdRegistrador VARCHAR(50),
    OUT p_IdGenerado VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
    DECLARE v_NextNum INT DEFAULT 0;
    DECLARE v_Hoy DATE DEFAULT CURDATE();

    SET p_IdGenerado = NULL;

    IF p_IdUsuario IS NULL OR TRIM(p_IdUsuario) = '' THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Selecciona un estudiante.'; LEAVE main;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM USUARIO WHERE IDUSUARIO = p_IdUsuario) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'El estudiante no existe.'; LEAVE main;
    END IF;
    IF p_IdConcepto IS NULL OR TRIM(p_IdConcepto) = '' THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Selecciona un concepto.'; LEAVE main;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM CONCEPTOPAGOEXTRA
        WHERE IDCONCEPTO = p_IdConcepto
          AND ACTIVO = 1
          AND FECHAINICIO IS NOT NULL AND CHAR_LENGTH(FECHAINICIO) = 8
          AND FECHAFIN IS NOT NULL AND CHAR_LENGTH(FECHAFIN) = 8
          AND v_Hoy >= STR_TO_DATE(CONCAT(SUBSTRING(FECHAINICIO, 5, 4), SUBSTRING(FECHAINICIO, 3, 2), SUBSTRING(FECHAINICIO, 1, 2)), '%Y%m%d')
          AND v_Hoy <= STR_TO_DATE(CONCAT(SUBSTRING(FECHAFIN, 5, 4), SUBSTRING(FECHAFIN, 3, 2), SUBSTRING(FECHAFIN, 1, 2)), '%Y%m%d')
    ) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'El concepto no está activo o no está vigente en la fecha actual.'; LEAVE main;
    END IF;

    IF p_Monto IS NULL OR p_Monto <= 0 THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa un monto válido.'; LEAVE main;
    END IF;
    IF p_FechaPago IS NULL OR CHAR_LENGTH(p_FechaPago) <> 8 THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa la fecha del pago.'; LEAVE main;
    END IF;
    IF p_FechaInicio IS NULL OR CHAR_LENGTH(p_FechaInicio) <> 8 THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa la fecha de inicio.'; LEAVE main;
    END IF;
    IF p_FechaFin IS NULL OR CHAR_LENGTH(p_FechaFin) <> 8 THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa la fecha final.'; LEAVE main;
    END IF;

    SELECT IFNULL(MAX(CAST(REPLACE(IDPAGOEXTRA, 'PEX', '') AS UNSIGNED)), 0) + 1 INTO v_NextNum
    FROM PAGOEXTRAORDINARIO;
    SET p_IdGenerado = CONCAT('PEX', LPAD(v_NextNum, 5, '0'));

    INSERT INTO PAGOEXTRAORDINARIO (
        IDPAGOEXTRA, IDUSUARIO, IDCONCEPTO, MONTO,
        FECHAPAGO, FECHAINICIO, FECHAFIN, OBSERVACIONES, IDREGISTRADOR
    ) VALUES (
        p_IdGenerado, p_IdUsuario, p_IdConcepto, p_Monto,
        p_FechaPago, p_FechaInicio, p_FechaFin, p_Observaciones, p_IdRegistrador
    );

    SET p_Resultado = 1; SET p_Mensaje = 'Pago extraordinario registrado.';
END$$

DELIMITER ;

SELECT 'Concepto: fechas de vigencia + usp_pagoextra_insertar listos.' AS info;
