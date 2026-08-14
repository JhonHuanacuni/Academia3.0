-- ============================================================================
-- Fix: usp_aula_insertar genera IDAULA (AUL001…) si no se envía código
-- El frontend ya no pide código; 31_07_2026/11.aula_tutor.sql lo exigía por error.
-- Fecha: 13/08/2026
-- ============================================================================

USE `AcademiaDB`;

DROP PROCEDURE IF EXISTS usp_aula_insertar;

DELIMITER $$

CREATE PROCEDURE usp_aula_insertar(
    IN p_Id VARCHAR(50),
    IN p_Nombre VARCHAR(100),
    IN p_Descripcion LONGTEXT,
    IN p_Capacidad INT,
    IN p_EnlaceVirtual VARCHAR(255),
    IN p_EnlaceCuestionario VARCHAR(255),
    IN p_IdTutor VARCHAR(50),
    IN p_Estado VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
    DECLARE v_Next INT DEFAULT 0;
    DECLARE v_Id VARCHAR(50);

    IF p_Nombre IS NULL OR TRIM(p_Nombre) = '' THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa el nombre del aula.'; LEAVE main;
    END IF;

    IF p_Id IS NULL OR TRIM(p_Id) = '' THEN
        SELECT IFNULL(MAX(CAST(REPLACE(IDAULA, 'AUL', '') AS UNSIGNED)), 0) + 1 INTO v_Next
        FROM AULA WHERE IDAULA LIKE 'AUL%';
        SET v_Id = CONCAT('AUL', LPAD(CAST(v_Next AS CHAR), 3, '0'));
    ELSE
        SET v_Id = UPPER(TRIM(p_Id));
    END IF;

    IF EXISTS (SELECT 1 FROM AULA WHERE IDAULA = v_Id) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'El código de aula ya existe.'; LEAVE main;
    END IF;
    IF EXISTS (SELECT 1 FROM AULA WHERE NOMBRE = p_Nombre) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ya existe un aula con ese nombre.'; LEAVE main;
    END IF;
    IF p_IdTutor IS NOT NULL AND TRIM(p_IdTutor) <> ''
       AND NOT EXISTS (SELECT 1 FROM TUTOR WHERE IDTUTOR = p_IdTutor AND ACTIVO = 1) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'El tutor seleccionado no es válido.'; LEAVE main;
    END IF;

    INSERT INTO AULA (
        IDAULA, NOMBRE, DESCRIPCION, CAPACIDAD, ACTIVO, ENLACEVIRTUAL, ENLACECUESTIONARIO, IDTUTOR
    ) VALUES (
        v_Id, p_Nombre, p_Descripcion, p_Capacidad,
        CASE WHEN p_Estado = 'Activo' THEN 1 ELSE 0 END,
        p_EnlaceVirtual, p_EnlaceCuestionario,
        NULLIF(TRIM(p_IdTutor), '')
    );

    SET p_Resultado = 1; SET p_Mensaje = 'Aula registrada.';
END$$

DELIMITER ;

SELECT 'usp_aula_insertar: código AUL### autogenerado.' AS info;
