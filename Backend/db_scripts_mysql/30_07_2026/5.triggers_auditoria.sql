-- ============================================================================
-- Triggers de auditoría (MySQL 8)
-- Usa @audit_id_usuario establecido desde el backend (db_context.py).
-- Prerequisito: 3.auditoria_tabla.sql
-- ============================================================================

USE `AcademiaDB`;

DROP PROCEDURE IF EXISTS usp_auditoria_instalar_trigger;

DELIMITER $$

CREATE PROCEDURE usp_auditoria_instalar_trigger(
    IN p_Tabla VARCHAR(64),
    IN p_ColumnaPk VARCHAR(64)
)
main: BEGIN
    DECLARE v_trigger VARCHAR(128);
    DECLARE v_json_new LONGTEXT DEFAULT '';
    DECLARE v_json_old LONGTEXT DEFAULT '';
    DECLARE v_sql LONGTEXT;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.TABLES
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = p_Tabla
    ) THEN
        SELECT CONCAT('Tabla omitida (no existe): ', p_Tabla) AS info;
        LEAVE main;
    END IF;

    SELECT GROUP_CONCAT(
        CONCAT('''', COLUMN_NAME, ''', NEW.', COLUMN_NAME)
        ORDER BY ORDINAL_POSITION SEPARATOR ', '
    ) INTO v_json_new
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = p_Tabla;

    SELECT GROUP_CONCAT(
        CONCAT('''', COLUMN_NAME, ''', OLD.', COLUMN_NAME)
        ORDER BY ORDINAL_POSITION SEPARATOR ', '
    ) INTO v_json_old
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = p_Tabla;

    SET v_trigger = CONCAT('tr_', p_Tabla, '_auditoria');

    SET @drop_sql = CONCAT('DROP TRIGGER IF EXISTS `', v_trigger, '_ins`');
    PREPARE stmt FROM @drop_sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
    SET @drop_sql = CONCAT('DROP TRIGGER IF EXISTS `', v_trigger, '_upd`');
    PREPARE stmt FROM @drop_sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
    SET @drop_sql = CONCAT('DROP TRIGGER IF EXISTS `', v_trigger, '_del`');
    PREPARE stmt FROM @drop_sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

    SET @sql = CONCAT(
        'CREATE TRIGGER `', v_trigger, '_ins` AFTER INSERT ON `', p_Tabla, '` FOR EACH ROW ',
        'BEGIN ',
        'DECLARE v_id VARCHAR(50); ',
        'CALL usp_auditoria_siguiente_id(@v_id); ',
        'INSERT INTO AUDITORIA (IDAUDITORIA, TABLA, IDREGISTRO, ACCION, IDUSUARIO, FECHA, HORA, DATOS_ANTES, DATOS_DESPUES) ',
        'VALUES (@v_id, ''', p_Tabla, ''', NEW.', p_ColumnaPk, ', ''INSERT'', @audit_id_usuario, ',
        'fn_fecha_ddmmyyyy(), TIME_FORMAT(NOW(), ''%H:%i:%s''), NULL, JSON_OBJECT(', v_json_new, ')); ',
        'END'
    );
    PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

    SET @sql = CONCAT(
        'CREATE TRIGGER `', v_trigger, '_upd` AFTER UPDATE ON `', p_Tabla, '` FOR EACH ROW ',
        'BEGIN ',
        'DECLARE v_id VARCHAR(50); ',
        'CALL usp_auditoria_siguiente_id(@v_id); ',
        'INSERT INTO AUDITORIA (IDAUDITORIA, TABLA, IDREGISTRO, ACCION, IDUSUARIO, FECHA, HORA, DATOS_ANTES, DATOS_DESPUES) ',
        'VALUES (@v_id, ''', p_Tabla, ''', NEW.', p_ColumnaPk, ', ''UPDATE'', @audit_id_usuario, ',
        'fn_fecha_ddmmyyyy(), TIME_FORMAT(NOW(), ''%H:%i:%s''), JSON_OBJECT(', v_json_old, '), JSON_OBJECT(', v_json_new, ')); ',
        'END'
    );
    PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

    SET @sql = CONCAT(
        'CREATE TRIGGER `', v_trigger, '_del` AFTER DELETE ON `', p_Tabla, '` FOR EACH ROW ',
        'BEGIN ',
        'DECLARE v_id VARCHAR(50); ',
        'CALL usp_auditoria_siguiente_id(@v_id); ',
        'INSERT INTO AUDITORIA (IDAUDITORIA, TABLA, IDREGISTRO, ACCION, IDUSUARIO, FECHA, HORA, DATOS_ANTES, DATOS_DESPUES) ',
        'VALUES (@v_id, ''', p_Tabla, ''', OLD.', p_ColumnaPk, ', ''DELETE'', @audit_id_usuario, ',
        'fn_fecha_ddmmyyyy(), TIME_FORMAT(NOW(), ''%H:%i:%s''), JSON_OBJECT(', v_json_old, '), NULL); ',
        'END'
    );
    PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

    SELECT CONCAT('Triggers instalados: ', v_trigger) AS info;
END$$

DELIMITER ;

CALL usp_auditoria_instalar_trigger('USUARIO', 'IDUSUARIO');
CALL usp_auditoria_instalar_trigger('MENSUALIDAD', 'IDMENSUALIDAD');
CALL usp_auditoria_instalar_trigger('PAGOMENSUALIDAD', 'IDPAGOMENSUALIDAD');
CALL usp_auditoria_instalar_trigger('PAGOEXTRAORDINARIO', 'IDPAGOEXTRA');
CALL usp_auditoria_instalar_trigger('AULA', 'IDAULA');
CALL usp_auditoria_instalar_trigger('PLAN', 'IDPLAN');
CALL usp_auditoria_instalar_trigger('TUTOR', 'IDTUTOR');
CALL usp_auditoria_instalar_trigger('CATEGORIA', 'IDCATEGORIA');
CALL usp_auditoria_instalar_trigger('MATERIA', 'IDMATERIA');
CALL usp_auditoria_instalar_trigger('CONCEPTOPAGOEXTRA', 'IDCONCEPTO');
CALL usp_auditoria_instalar_trigger('LIBRO', 'IDLIBRO');
CALL usp_auditoria_instalar_trigger('HORARIO', 'IDHORARIO');
CALL usp_auditoria_instalar_trigger('EXAMEN', 'IDEXAMEN');
CALL usp_auditoria_instalar_trigger('ASISTENCIA', 'IDASISTENCIA');
CALL usp_auditoria_instalar_trigger('JUSTIFICACION', 'IDJUSTIFICACION');
CALL usp_auditoria_instalar_trigger('NOTAS_IMPORTACION', 'IDIMPORTACION');
CALL usp_auditoria_instalar_trigger('NOTA_IMPORTADA', 'IDNOTA');

SELECT 'Triggers de auditoría instalados (MySQL).' AS info;
