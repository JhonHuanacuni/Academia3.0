-- ============================================================================
-- CRUD TUTOR — Mantenedor de tutores (MySQL 8)
-- Faltaba en la migración rename (SQL Server lo tenía embebido).
-- Ejecutar después de 10.tutor_codigo_tut.sql
-- Fecha: 02/08/2026
-- ============================================================================

USE `AcademiaDB`;

DROP PROCEDURE IF EXISTS usp_tutor_listar;

DELIMITER $$

CREATE PROCEDURE usp_tutor_listar(
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

    IF p_Pagina IS NULL OR p_Pagina < 1 THEN SET p_Pagina = 1; END IF;
    IF p_TamanioPagina IS NULL OR p_TamanioPagina < 1 THEN SET p_TamanioPagina = 10; END IF;

    SET v_offset = (p_Pagina - 1) * p_TamanioPagina;

    SELECT COUNT(*) INTO p_TotalRegistros
    FROM TUTOR a
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           a.IDTUTOR LIKE CONCAT('%', p_Buscar, '%') OR
           a.NOMBRE   LIKE CONCAT('%', p_Buscar, '%'))
      AND (p_Estado IS NULL OR p_Estado = '' OR
           (p_Estado = 'Activo' AND a.ACTIVO = 1) OR
           (p_Estado = 'Inactivo' AND a.ACTIVO = 0));

    SELECT
        a.IDTUTOR,
        a.NOMBRE,
        CASE WHEN a.ACTIVO = 1 THEN 'Activo' ELSE 'Inactivo' END AS ESTADO
    FROM TUTOR a
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           a.IDTUTOR LIKE CONCAT('%', p_Buscar, '%') OR
           a.NOMBRE   LIKE CONCAT('%', p_Buscar, '%'))
      AND (p_Estado IS NULL OR p_Estado = '' OR
           (p_Estado = 'Activo' AND a.ACTIVO = 1) OR
           (p_Estado = 'Inactivo' AND a.ACTIVO = 0))
    ORDER BY
        CASE WHEN p_OrdenarPor = 'IDTUTOR' AND p_Direccion = 'ASC'  THEN a.IDTUTOR END ASC,
        CASE WHEN p_OrdenarPor = 'IDTUTOR' AND p_Direccion = 'DESC' THEN a.IDTUTOR END DESC,
        CASE WHEN p_OrdenarPor = 'NOMBRE'   AND p_Direccion = 'ASC'  THEN a.NOMBRE END ASC,
        CASE WHEN p_OrdenarPor = 'NOMBRE'   AND p_Direccion = 'DESC' THEN a.NOMBRE END DESC,
        CASE WHEN p_OrdenarPor = 'ESTADO'   AND p_Direccion = 'ASC'  THEN a.ACTIVO END ASC,
        CASE WHEN p_OrdenarPor = 'ESTADO'   AND p_Direccion = 'DESC' THEN a.ACTIVO END DESC,
        a.NOMBRE
    LIMIT p_TamanioPagina OFFSET v_offset;
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_tutor_obtener;

DELIMITER $$

CREATE PROCEDURE usp_tutor_obtener(
    IN p_Id VARCHAR(50)
)
main: BEGIN
    SELECT
        a.IDTUTOR,
        a.NOMBRE,
        CASE WHEN a.ACTIVO = 1 THEN 'Activo' ELSE 'Inactivo' END AS ESTADO
    FROM TUTOR a
    WHERE a.IDTUTOR = p_Id;
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_tutor_actualizar;

DELIMITER $$

CREATE PROCEDURE usp_tutor_actualizar(
    IN p_Id VARCHAR(50),
    IN p_Nombre VARCHAR(150),
    IN p_Estado VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
    IF NOT EXISTS (SELECT 1 FROM TUTOR WHERE IDTUTOR = p_Id) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'El tutor no existe.';
        LEAVE main;
    END IF;

    IF p_Nombre IS NULL OR TRIM(p_Nombre) = '' THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa el nombre del tutor.';
        LEAVE main;
    END IF;

    IF EXISTS (SELECT 1 FROM TUTOR WHERE NOMBRE = p_Nombre AND IDTUTOR <> p_Id) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ya existe un tutor con ese nombre.';
        LEAVE main;
    END IF;

    UPDATE TUTOR SET
        NOMBRE = p_Nombre,
        ACTIVO = CASE WHEN p_Estado = 'Activo' THEN 1 ELSE 0 END
    WHERE IDTUTOR = p_Id;

    SET p_Resultado = 1; SET p_Mensaje = 'Tutor actualizado.';
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_tutor_eliminar;

DELIMITER $$

CREATE PROCEDURE usp_tutor_eliminar(
    IN p_Id VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
    IF NOT EXISTS (SELECT 1 FROM TUTOR WHERE IDTUTOR = p_Id) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'El tutor no existe.';
        LEAVE main;
    END IF;

    IF EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDTUTOR = p_Id) THEN
        SET p_Resultado = 0;
        SET p_Mensaje = 'No se puede eliminar: el tutor tiene mensualidades asociadas.';
        LEAVE main;
    END IF;

    DELETE FROM TUTOR WHERE IDTUTOR = p_Id;

    SET p_Resultado = 1; SET p_Mensaje = 'Tutor eliminado.';
END$$

DELIMITER ;
