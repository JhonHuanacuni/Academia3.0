-- ============================================================================
-- Columnas de auditoría en tablas principales — MySQL 8
-- Fecha: 31/07/2026
-- ============================================================================

USE `AcademiaDB`;

DROP PROCEDURE IF EXISTS usp_auditoria_agregar_columnas;

DELIMITER $$

CREATE PROCEDURE usp_auditoria_agregar_columnas(IN p_Tabla VARCHAR(128))
main: BEGIN
    DECLARE v_tbl INT DEFAULT 0;
    DECLARE v_col INT DEFAULT 0;

    SELECT COUNT(*) INTO v_tbl
    FROM information_schema.TABLES
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = p_Tabla;

    IF v_tbl = 0 THEN
        SELECT CONCAT('Tabla omitida (no existe): ', p_Tabla) AS info;
        LEAVE main;
    END IF;

    SELECT COUNT(*) INTO v_col FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = p_Tabla AND COLUMN_NAME = 'CREADO_POR';
    IF v_col = 0 THEN
        SET @sql = CONCAT('ALTER TABLE `', p_Tabla, '` ADD COLUMN CREADO_POR VARCHAR(50) NULL');
        PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
    END IF;

    SELECT COUNT(*) INTO v_col FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = p_Tabla AND COLUMN_NAME = 'FECHACREACION';
    IF v_col = 0 THEN
        SET @sql = CONCAT('ALTER TABLE `', p_Tabla, '` ADD COLUMN FECHACREACION CHAR(8) NULL');
        PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
    END IF;

    SELECT COUNT(*) INTO v_col FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = p_Tabla AND COLUMN_NAME = 'HORACREACION';
    IF v_col = 0 THEN
        SET @sql = CONCAT('ALTER TABLE `', p_Tabla, '` ADD COLUMN HORACREACION CHAR(8) NULL');
        PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
    END IF;

    SELECT COUNT(*) INTO v_col FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = p_Tabla AND COLUMN_NAME = 'MODIFICADO_POR';
    IF v_col = 0 THEN
        SET @sql = CONCAT('ALTER TABLE `', p_Tabla, '` ADD COLUMN MODIFICADO_POR VARCHAR(50) NULL');
        PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
    END IF;

    SELECT COUNT(*) INTO v_col FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = p_Tabla AND COLUMN_NAME = 'FECHAMODIFICACION';
    IF v_col = 0 THEN
        SET @sql = CONCAT('ALTER TABLE `', p_Tabla, '` ADD COLUMN FECHAMODIFICACION CHAR(8) NULL');
        PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
    END IF;

    SELECT COUNT(*) INTO v_col FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = p_Tabla AND COLUMN_NAME = 'HORAMODIFICACION';
    IF v_col = 0 THEN
        SET @sql = CONCAT('ALTER TABLE `', p_Tabla, '` ADD COLUMN HORAMODIFICACION CHAR(8) NULL');
        PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
    END IF;

    SELECT CONCAT('Columnas de auditoría verificadas en ', p_Tabla, '.') AS info;
END$$

DELIMITER ;

CALL usp_auditoria_agregar_columnas('USUARIO');
CALL usp_auditoria_agregar_columnas('MENSUALIDAD');
CALL usp_auditoria_agregar_columnas('PAGOMENSUALIDAD');
CALL usp_auditoria_agregar_columnas('PAGOEXTRAORDINARIO');
CALL usp_auditoria_agregar_columnas('AULA');
CALL usp_auditoria_agregar_columnas('PLAN');
CALL usp_auditoria_agregar_columnas('TUTOR');
CALL usp_auditoria_agregar_columnas('CATEGORIA');
CALL usp_auditoria_agregar_columnas('MATERIA');
CALL usp_auditoria_agregar_columnas('CONCEPTOPAGOEXTRA');
CALL usp_auditoria_agregar_columnas('LIBRO');
CALL usp_auditoria_agregar_columnas('HORARIO');
CALL usp_auditoria_agregar_columnas('EXAMEN');
CALL usp_auditoria_agregar_columnas('ASISTENCIA');
CALL usp_auditoria_agregar_columnas('JUSTIFICACION');
CALL usp_auditoria_agregar_columnas('NOTAS_IMPORTACION');
CALL usp_auditoria_agregar_columnas('NOTA_IMPORTADA');

DROP PROCEDURE IF EXISTS usp_auditoria_agregar_columnas;

UPDATE MENSUALIDAD
SET CREADO_POR = COALESCE(CREADO_POR, REGISTRADOPOR),
    FECHACREACION = COALESCE(FECHACREACION, FECHAREGISTRO),
    HORACREACION = COALESCE(HORACREACION, HORAREGISTRO)
WHERE REGISTRADOPOR IS NOT NULL OR FECHAREGISTRO IS NOT NULL;

UPDATE NOTAS_IMPORTACION
SET CREADO_POR = COALESCE(CREADO_POR, IMPORTADO_POR)
WHERE IMPORTADO_POR IS NOT NULL;

UPDATE JUSTIFICACION
SET CREADO_POR = COALESCE(CREADO_POR, IDREGISTRADOR),
    HORACREACION = COALESCE(HORACREACION, HORAREGISTRO)
WHERE IDREGISTRADOR IS NOT NULL;

SELECT 'Columnas de auditoría listas.' AS info;
