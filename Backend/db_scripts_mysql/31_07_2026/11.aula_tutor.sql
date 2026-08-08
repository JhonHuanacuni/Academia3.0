-- ============================================================================
-- AULA: vincular tutor (IDTUTOR) + SPs CRUD
-- Ejecutar después de 26_07_2026/21.usp_tutor_crud.sql
-- Fecha: 31/07/2026
-- ============================================================================

USE `AcademiaDB`;

SET @col_exists := (
    SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'AULA' AND COLUMN_NAME = 'IDTUTOR'
);
SET @sql := IF(@col_exists = 0,
    'ALTER TABLE AULA ADD COLUMN IDTUTOR VARCHAR(50) NULL, ADD CONSTRAINT FK_AULA_TUTOR FOREIGN KEY (IDTUTOR) REFERENCES TUTOR(IDTUTOR)',
    'SELECT ''Columna AULA.IDTUTOR ya existe'' AS info'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

DROP PROCEDURE IF EXISTS usp_aula_listar;
DROP PROCEDURE IF EXISTS usp_aula_obtener;
DROP PROCEDURE IF EXISTS usp_aula_insertar;
DROP PROCEDURE IF EXISTS usp_aula_actualizar;

DELIMITER $$

CREATE PROCEDURE usp_aula_listar(
    IN p_Buscar VARCHAR(200),
    IN p_Estado VARCHAR(50),
    IN p_OrdenarPor VARCHAR(50),
    IN p_Direccion VARCHAR(4),
    IN p_Pagina INT,
    IN p_TamanioPagina INT,
    OUT p_TotalRegistros INT
)
main: BEGIN
    DECLARE v_offset INT DEFAULT 0;
    IF p_Pagina < 1 THEN SET p_Pagina = 1; END IF;
    IF p_TamanioPagina < 1 THEN SET p_TamanioPagina = 10; END IF;
    SET v_offset = (p_Pagina - 1) * p_TamanioPagina;

    SELECT COUNT(*) INTO p_TotalRegistros
    FROM AULA a
    LEFT JOIN TUTOR t ON t.IDTUTOR = a.IDTUTOR
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           a.IDAULA LIKE CONCAT('%', p_Buscar, '%') OR
           a.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
           a.DESCRIPCION LIKE CONCAT('%', p_Buscar, '%') OR
           IFNULL(t.NOMBRE, '') LIKE CONCAT('%', p_Buscar, '%'))
      AND (p_Estado IS NULL OR p_Estado = '' OR
           (p_Estado = 'Activo' AND a.ACTIVO = 1) OR
           (p_Estado = 'Inactivo' AND a.ACTIVO = 0));

    SELECT
        a.IDAULA,
        a.NOMBRE,
        a.DESCRIPCION,
        a.CAPACIDAD,
        a.ENLACEVIRTUAL,
        a.ENLACECUESTIONARIO,
        a.IDTUTOR,
        IFNULL(t.NOMBRE, '') AS TUTOR_NOMBRE,
        CASE WHEN a.ACTIVO = 1 THEN 'Activo' ELSE 'Inactivo' END AS ESTADO
    FROM AULA a
    LEFT JOIN TUTOR t ON t.IDTUTOR = a.IDTUTOR
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           a.IDAULA LIKE CONCAT('%', p_Buscar, '%') OR
           a.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
           a.DESCRIPCION LIKE CONCAT('%', p_Buscar, '%') OR
           IFNULL(t.NOMBRE, '') LIKE CONCAT('%', p_Buscar, '%'))
      AND (p_Estado IS NULL OR p_Estado = '' OR
           (p_Estado = 'Activo' AND a.ACTIVO = 1) OR
           (p_Estado = 'Inactivo' AND a.ACTIVO = 0))
    ORDER BY
        CASE WHEN p_OrdenarPor = 'IDAULA'    AND p_Direccion = 'ASC'  THEN a.IDAULA END ASC,
        CASE WHEN p_OrdenarPor = 'IDAULA'    AND p_Direccion = 'DESC' THEN a.IDAULA END DESC,
        CASE WHEN p_OrdenarPor = 'NOMBRE'    AND p_Direccion = 'ASC'  THEN a.NOMBRE END ASC,
        CASE WHEN p_OrdenarPor = 'NOMBRE'    AND p_Direccion = 'DESC' THEN a.NOMBRE END DESC,
        CASE WHEN p_OrdenarPor = 'TUTOR_NOMBRE' AND p_Direccion = 'ASC' THEN t.NOMBRE END ASC,
        CASE WHEN p_OrdenarPor = 'TUTOR_NOMBRE' AND p_Direccion = 'DESC' THEN t.NOMBRE END DESC,
        CASE WHEN p_OrdenarPor = 'CAPACIDAD' AND p_Direccion = 'ASC'  THEN a.CAPACIDAD END ASC,
        CASE WHEN p_OrdenarPor = 'CAPACIDAD' AND p_Direccion = 'DESC' THEN a.CAPACIDAD END DESC,
        CASE WHEN p_OrdenarPor = 'ESTADO'    AND p_Direccion = 'ASC'  THEN a.ACTIVO END ASC,
        CASE WHEN p_OrdenarPor = 'ESTADO'    AND p_Direccion = 'DESC' THEN a.ACTIVO END DESC,
        a.NOMBRE
    LIMIT p_TamanioPagina OFFSET v_offset;
END$$

CREATE PROCEDURE usp_aula_obtener(
    IN p_Id VARCHAR(50)
)
main: BEGIN
    SELECT
        a.IDAULA,
        a.NOMBRE,
        a.DESCRIPCION,
        a.CAPACIDAD,
        a.ENLACEVIRTUAL,
        a.ENLACECUESTIONARIO,
        a.IDTUTOR,
        IFNULL(t.NOMBRE, '') AS TUTOR_NOMBRE,
        CASE WHEN a.ACTIVO = 1 THEN 'Activo' ELSE 'Inactivo' END AS ESTADO
    FROM AULA a
    LEFT JOIN TUTOR t ON t.IDTUTOR = a.IDTUTOR
    WHERE a.IDAULA = p_Id;
END$$

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
    IF p_Id IS NULL OR TRIM(p_Id) = '' THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa el código del aula.'; LEAVE main;
    END IF;
    IF p_Nombre IS NULL OR TRIM(p_Nombre) = '' THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa el nombre del aula.'; LEAVE main;
    END IF;
    IF EXISTS (SELECT 1 FROM AULA WHERE IDAULA = p_Id) THEN
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
        p_Id, p_Nombre, p_Descripcion, p_Capacidad,
        CASE WHEN p_Estado = 'Activo' THEN 1 ELSE 0 END,
        p_EnlaceVirtual, p_EnlaceCuestionario,
        NULLIF(TRIM(p_IdTutor), '')
    );

    SET p_Resultado = 1; SET p_Mensaje = 'Aula registrada.';
END$$

CREATE PROCEDURE usp_aula_actualizar(
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
    IF NOT EXISTS (SELECT 1 FROM AULA WHERE IDAULA = p_Id) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'El aula no existe.'; LEAVE main;
    END IF;
    IF p_Nombre IS NULL OR TRIM(p_Nombre) = '' THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa el nombre del aula.'; LEAVE main;
    END IF;
    IF EXISTS (SELECT 1 FROM AULA WHERE NOMBRE = p_Nombre AND IDAULA <> p_Id) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ya existe un aula con ese nombre.'; LEAVE main;
    END IF;
    IF p_IdTutor IS NOT NULL AND TRIM(p_IdTutor) <> ''
       AND NOT EXISTS (SELECT 1 FROM TUTOR WHERE IDTUTOR = p_IdTutor AND ACTIVO = 1) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'El tutor seleccionado no es válido.'; LEAVE main;
    END IF;

    UPDATE AULA SET
        NOMBRE             = p_Nombre,
        DESCRIPCION        = p_Descripcion,
        CAPACIDAD          = p_Capacidad,
        ENLACEVIRTUAL      = p_EnlaceVirtual,
        ENLACECUESTIONARIO = p_EnlaceCuestionario,
        IDTUTOR            = NULLIF(TRIM(p_IdTutor), ''),
        ACTIVO             = CASE WHEN p_Estado = 'Activo' THEN 1 ELSE 0 END
    WHERE IDAULA = p_Id;

    SET p_Resultado = 1; SET p_Mensaje = 'Aula actualizada.';
END$$

DELIMITER ;
