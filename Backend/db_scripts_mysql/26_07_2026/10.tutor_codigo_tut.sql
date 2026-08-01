-- Convertido automáticamente desde db_scripts/26_07_2026/10.tutor_codigo_tut.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   TUTOR: códigos TUT001, TUT002… (renombrar ASE* heredados de ASESOR)
   Ejecutar después de 9.menu_tutores_asesores.sql
   Fecha: 26/07/2026
   ============================================================================ */

IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_MENSUALIDAD_TUTOR')
    ALTER TABLE MENSUALIDAD DROP CONSTRAINT FK_MENSUALIDAD_TUTOR;

UPDATE m
SET m.IDTUTOR = CONCAT('TUT', SUBSTRING(m.IDTUTOR, 4, 47))
FROM MENSUALIDAD m
WHERE m.IDTUTOR LIKE 'ASE%';

UPDATE t
SET t.IDTUTOR = CONCAT('TUT', SUBSTRING(t.IDTUTOR, 4, 47))
FROM TUTOR t
WHERE t.IDTUTOR LIKE 'ASE%';

SET @fk_FK_MENSUALIDAD_TUTOR := (
    SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_SCHEMA = DATABASE() AND CONSTRAINT_NAME = 'FK_MENSUALIDAD_TUTOR'
);
SET @sql_FK_MENSUALIDAD_TUTOR := IF(@fk_FK_MENSUALIDAD_TUTOR = 0, 'ALTER TABLE MENSUALIDAD ADD CONSTRAINT FK_MENSUALIDAD_TUTOR
        FOREIGN KEY (IDTUTOR) REFERENCES TUTOR(IDTUTOR);

DROP PROCEDURE IF EXISTS usp_tutor_insertar;

DROP PROCEDURE IF EXISTS usp_tutor_insertar;

DELIMITER $$

CREATE PROCEDURE usp_tutor_insertar(
    IN p_Id VARCHAR(50),
    IN p_Nombre VARCHAR(150),
    IN p_Estado VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
IF p_Nombre IS NULL OR TRIM(p_Nombre) = '''' THEN
        SET p_Resultado = 0; SET p_Mensaje = ''Ingresa el nombre del tutor.''; LEAVE main;     END IF;

    IF p_Id IS NULL OR TRIM(p_Id) = '''' THEN
SET p_Id = CONCAT(''TUT'', RIGHT(CONCAT(''000'', CAST(v_Next AS CHAR(10))), 3);
    
    SET p_Id = UPPER(TRIM(p_Id);

    IF p_Id NOT LIKE ''TUT[0-9]%'' THEN
        SET p_Resultado = 0; SET p_Mensaje = ''El código debe ser TUT seguido del número (ej. TUT001).''; LEAVE main;     END IF;

    IF EXISTS (SELECT 1 FROM TUTOR WHERE IDTUTOR = p_Id) THEN
        SET p_Resultado = 0; SET p_Mensaje = ''El código de tutor ya existe.''; LEAVE main;     END IF;

    IF EXISTS (SELECT 1 FROM TUTOR WHERE NOMBRE = p_Nombre) THEN
        SET p_Resultado = 0; SET p_Mensaje = ''Ya existe un tutor con ese nombre.''; LEAVE main;     END IF;
    INSERT INTO TUTOR (IDTUTOR, NOMBRE, ACTIVO)
    VALUES (p_Id, p_Nombre, CASE WHEN p_Estado = ''Activo'' THEN 1 ELSE 0 END);

    SET p_Resultado = 1; SET p_Mensaje = ''Tutor registrado.'';
END', 'SELECT 1');
PREPARE stmt FROM @sql_FK_MENSUALIDAD_TUTOR; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SELECT p_Resultado AS Resultado, p_Mensaje AS Mensaje
END$$

DELIMITER ;