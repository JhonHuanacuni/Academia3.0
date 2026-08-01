-- ============================================================================
-- TUTOR: códigos TUT001, TUT002… (renombrar ASE* heredados de ASESOR) — MySQL 8
-- Ejecutar después de 9.menu_tutores_asesores.sql
-- Fecha: 26/07/2026
-- ============================================================================

USE `AcademiaDB`;

SET @fk_FK_MENSUALIDAD_TUTOR := (
    SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_SCHEMA = DATABASE() AND CONSTRAINT_NAME = 'FK_MENSUALIDAD_TUTOR'
);
SET @sql_drop_fk := IF(
    @fk_FK_MENSUALIDAD_TUTOR > 0,
    'ALTER TABLE MENSUALIDAD DROP FOREIGN KEY FK_MENSUALIDAD_TUTOR',
    'SELECT 1'
);
PREPARE stmt FROM @sql_drop_fk;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

UPDATE MENSUALIDAD m
SET m.IDTUTOR = CONCAT('TUT', SUBSTRING(m.IDTUTOR, 4))
WHERE m.IDTUTOR LIKE 'ASE%';

UPDATE TUTOR t
SET t.IDTUTOR = CONCAT('TUT', SUBSTRING(t.IDTUTOR, 4))
WHERE t.IDTUTOR LIKE 'ASE%';

SET @fk_FK_MENSUALIDAD_TUTOR := (
    SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_SCHEMA = DATABASE() AND CONSTRAINT_NAME = 'FK_MENSUALIDAD_TUTOR'
);
SET @sql_add_fk := IF(
    @fk_FK_MENSUALIDAD_TUTOR = 0,
    'ALTER TABLE MENSUALIDAD ADD CONSTRAINT FK_MENSUALIDAD_TUTOR FOREIGN KEY (IDTUTOR) REFERENCES TUTOR(IDTUTOR)',
    'SELECT 1'
);
PREPARE stmt FROM @sql_add_fk;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

DROP PROCEDURE IF EXISTS usp_tutor_insertar;

DELIMITER $$

CREATE PROCEDURE usp_tutor_insertar(
    INOUT p_Id VARCHAR(50),
    IN p_Nombre VARCHAR(150),
    IN p_Estado VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
    DECLARE v_Next INT DEFAULT 0;

    IF p_Nombre IS NULL OR TRIM(p_Nombre) = '' THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa el nombre del tutor.';
        LEAVE main;
    END IF;

    IF p_Id IS NULL OR TRIM(p_Id) = '' THEN
        SELECT IFNULL(MAX(CAST(SUBSTRING(IDTUTOR, 4, 10) AS UNSIGNED)), 0) + 1 INTO v_Next
        FROM TUTOR WHERE IDTUTOR LIKE 'TUT%';
        SET p_Id = CONCAT('TUT', LPAD(CAST(v_Next AS CHAR), 3, '0'));
    END IF;

    SET p_Id = UPPER(TRIM(p_Id));

    IF p_Id NOT REGEXP '^TUT[0-9]+$' THEN
        SET p_Resultado = 0; SET p_Mensaje = 'El código debe ser TUT seguido del número (ej. TUT001).';
        LEAVE main;
    END IF;

    IF EXISTS (SELECT 1 FROM TUTOR WHERE IDTUTOR = p_Id) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'El código de tutor ya existe.';
        LEAVE main;
    END IF;

    IF EXISTS (SELECT 1 FROM TUTOR WHERE NOMBRE = p_Nombre) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ya existe un tutor con ese nombre.';
        LEAVE main;
    END IF;

    INSERT INTO TUTOR (IDTUTOR, NOMBRE, ACTIVO)
    VALUES (p_Id, p_Nombre, CASE WHEN p_Estado = 'Activo' THEN 1 ELSE 0 END);

    SET p_Resultado = 1; SET p_Mensaje = 'Tutor registrado.';
END$$

DELIMITER ;
