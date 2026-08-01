-- ============================================================================
-- CRUD AULA — Mantenedor de aulas (módulo Académico) — MySQL 8
-- ============================================================================

USE `AcademiaDB`;

DROP PROCEDURE IF EXISTS usp_aula_listar;
DROP PROCEDURE IF EXISTS usp_aula_obtener;
DROP PROCEDURE IF EXISTS usp_aula_insertar;
DROP PROCEDURE IF EXISTS usp_aula_actualizar;
DROP PROCEDURE IF EXISTS usp_aula_eliminar;

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
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           a.IDAULA LIKE CONCAT('%', p_Buscar, '%') OR
           a.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
           a.DESCRIPCION LIKE CONCAT('%', p_Buscar, '%'))
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
        CASE WHEN a.ACTIVO = 1 THEN 'Activo' ELSE 'Inactivo' END AS ESTADO
    FROM AULA a
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           a.IDAULA LIKE CONCAT('%', p_Buscar, '%') OR
           a.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
           a.DESCRIPCION LIKE CONCAT('%', p_Buscar, '%'))
      AND (p_Estado IS NULL OR p_Estado = '' OR
           (p_Estado = 'Activo' AND a.ACTIVO = 1) OR
           (p_Estado = 'Inactivo' AND a.ACTIVO = 0))
    ORDER BY
        CASE WHEN p_OrdenarPor = 'IDAULA'    AND p_Direccion = 'ASC'  THEN a.IDAULA END ASC,
        CASE WHEN p_OrdenarPor = 'IDAULA'    AND p_Direccion = 'DESC' THEN a.IDAULA END DESC,
        CASE WHEN p_OrdenarPor = 'NOMBRE'    AND p_Direccion = 'ASC'  THEN a.NOMBRE END ASC,
        CASE WHEN p_OrdenarPor = 'NOMBRE'    AND p_Direccion = 'DESC' THEN a.NOMBRE END DESC,
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
        CASE WHEN a.ACTIVO = 1 THEN 'Activo' ELSE 'Inactivo' END AS ESTADO
    FROM AULA a
    WHERE a.IDAULA = p_Id;
END$$

CREATE PROCEDURE usp_aula_insertar(
    IN p_Id VARCHAR(50),
    IN p_Nombre VARCHAR(100),
    IN p_Descripcion LONGTEXT,
    IN p_Capacidad INT,
    IN p_EnlaceVirtual VARCHAR(255),
    IN p_EnlaceCuestionario VARCHAR(255),
    IN p_Estado VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
    IF p_Id IS NULL OR TRIM(p_Id) = '' THEN
        SET p_Resultado = 0;
        SET p_Mensaje = 'Ingresa el código del aula.';
        LEAVE main;
    END IF;

    IF p_Nombre IS NULL OR TRIM(p_Nombre) = '' THEN
        SET p_Resultado = 0;
        SET p_Mensaje = 'Ingresa el nombre del aula.';
        LEAVE main;
    END IF;

    IF EXISTS (SELECT 1 FROM AULA WHERE IDAULA = p_Id) THEN
        SET p_Resultado = 0;
        SET p_Mensaje = 'El código de aula ya existe.';
        LEAVE main;
    END IF;

    IF EXISTS (SELECT 1 FROM AULA WHERE NOMBRE = p_Nombre) THEN
        SET p_Resultado = 0;
        SET p_Mensaje = 'Ya existe un aula con ese nombre.';
        LEAVE main;
    END IF;

    INSERT INTO AULA (
        IDAULA, NOMBRE, DESCRIPCION, CAPACIDAD, ACTIVO, ENLACEVIRTUAL, ENLACECUESTIONARIO
    ) VALUES (
        p_Id,
        p_Nombre,
        p_Descripcion,
        p_Capacidad,
        CASE WHEN p_Estado = 'Activo' THEN 1 ELSE 0 END,
        p_EnlaceVirtual,
        p_EnlaceCuestionario
    );

    SET p_Resultado = 1;
    SET p_Mensaje = 'Aula registrada.';
END$$

CREATE PROCEDURE usp_aula_actualizar(
    IN p_Id VARCHAR(50),
    IN p_Nombre VARCHAR(100),
    IN p_Descripcion LONGTEXT,
    IN p_Capacidad INT,
    IN p_EnlaceVirtual VARCHAR(255),
    IN p_EnlaceCuestionario VARCHAR(255),
    IN p_Estado VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
    IF NOT EXISTS (SELECT 1 FROM AULA WHERE IDAULA = p_Id) THEN
        SET p_Resultado = 0;
        SET p_Mensaje = 'El aula no existe.';
        LEAVE main;
    END IF;

    IF p_Nombre IS NULL OR TRIM(p_Nombre) = '' THEN
        SET p_Resultado = 0;
        SET p_Mensaje = 'Ingresa el nombre del aula.';
        LEAVE main;
    END IF;

    IF EXISTS (SELECT 1 FROM AULA WHERE NOMBRE = p_Nombre AND IDAULA <> p_Id) THEN
        SET p_Resultado = 0;
        SET p_Mensaje = 'Ya existe un aula con ese nombre.';
        LEAVE main;
    END IF;

    UPDATE AULA SET
        NOMBRE             = p_Nombre,
        DESCRIPCION        = p_Descripcion,
        CAPACIDAD          = p_Capacidad,
        ENLACEVIRTUAL      = p_EnlaceVirtual,
        ENLACECUESTIONARIO = p_EnlaceCuestionario,
        ACTIVO             = CASE WHEN p_Estado = 'Activo' THEN 1 ELSE 0 END
    WHERE IDAULA = p_Id;

    SET p_Resultado = 1;
    SET p_Mensaje = 'Aula actualizada.';
END$$

CREATE PROCEDURE usp_aula_eliminar(
    IN p_Id VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
    IF NOT EXISTS (SELECT 1 FROM AULA WHERE IDAULA = p_Id) THEN
        SET p_Resultado = 0;
        SET p_Mensaje = 'El aula no existe.';
        LEAVE main;
    END IF;

    IF EXISTS (SELECT 1 FROM MEMBRESIA WHERE IDAULA = p_Id) THEN
        SET p_Resultado = 0;
        SET p_Mensaje = 'No se puede eliminar: el aula tiene membresías asociadas.';
        LEAVE main;
    END IF;

    DELETE FROM AULA WHERE IDAULA = p_Id;

    SET p_Resultado = 1;
    SET p_Mensaje = 'Aula eliminada.';
END$$

DELIMITER ;

SELECT 'SPs usp_aula_* creados.' AS info;