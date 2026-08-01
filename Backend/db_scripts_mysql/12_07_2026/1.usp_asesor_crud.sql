-- Convertido automáticamente desde db_scripts/12_07_2026/1.usp_asesor_crud.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   CRUD ASESOR — Mantenedor de asesores (módulo Académico)
   Ejecutar después de 6.asesor_tabla.sql (11_07_2026)
   Fecha: 12/07/2026
   ============================================================================ */

DROP PROCEDURE IF EXISTS usp_asesor_listar;

DROP PROCEDURE IF EXISTS usp_asesor_listar;

DELIMITER $$

CREATE PROCEDURE usp_asesor_listar(
    IN p_Buscar VARCHAR(200),
    IN p_Estado VARCHAR(50),
    IN p_OrdenarPor VARCHAR(50),
    IN p_Direccion VARCHAR(4),
    IN p_Pagina INT,
    IN p_TamanioPagina INT,
    OUT p_TotalRegistros INT
)
main: BEGIN
IF p_Pagina < 1 THEN SET p_Pagina = 1; END IF;
    IF p_TamanioPagina < 1 THEN SET p_TamanioPagina = 10; END IF;

    SELECT COUNT(*) INTO p_TotalRegistros
    FROM ASESOR a
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           a.IDASESOR LIKE CONCAT('%', p_Buscar, '%') OR
           a.NOMBRE   LIKE CONCAT('%', p_Buscar, '%'))
      AND (p_Estado IS NULL OR p_Estado = '' OR
           (p_Estado = 'Activo' AND a.ACTIVO = 1) OR
           (p_Estado = 'Inactivo' AND a.ACTIVO = 0));

    SELECT
        a.IDASESOR,
        a.NOMBRE,
        CASE WHEN a.ACTIVO = 1 THEN 'Activo' ELSE 'Inactivo' END AS ESTADO
    FROM ASESOR a
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           a.IDASESOR LIKE CONCAT('%', p_Buscar, '%') OR
           a.NOMBRE   LIKE CONCAT('%', p_Buscar, '%'))
      AND (p_Estado IS NULL OR p_Estado = '' OR
           (p_Estado = 'Activo' AND a.ACTIVO = 1) OR
           (p_Estado = 'Inactivo' AND a.ACTIVO = 0))
    ORDER BY
        CASE WHEN p_OrdenarPor = 'IDASESOR' AND p_Direccion = 'ASC'  THEN a.IDASESOR END ASC,
        CASE WHEN p_OrdenarPor = 'IDASESOR' AND p_Direccion = 'DESC' THEN a.IDASESOR END DESC,
        CASE WHEN p_OrdenarPor = 'NOMBRE'   AND p_Direccion = 'ASC'  THEN a.NOMBRE END ASC,
        CASE WHEN p_OrdenarPor = 'NOMBRE'   AND p_Direccion = 'DESC' THEN a.NOMBRE END DESC,
        CASE WHEN p_OrdenarPor = 'ESTADO'   AND p_Direccion = 'ASC'  THEN a.ACTIVO END ASC,
        CASE WHEN p_OrdenarPor = 'ESTADO'   AND p_Direccion = 'DESC' THEN a.ACTIVO END DESC,
        a.NOMBRE
    LIMIT p_TamanioPagina OFFSET ((p_Pagina - 1) * p_TamanioPagina);
    SELECT p_TotalRegistros AS TotalRegistros
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_asesor_obtener;

DROP PROCEDURE IF EXISTS usp_asesor_obtener;

DELIMITER $$

CREATE PROCEDURE usp_asesor_obtener(
    IN p_Id VARCHAR(50)
)
main: BEGIN
SELECT
        a.IDASESOR,
        a.NOMBRE,
        CASE WHEN a.ACTIVO = 1 THEN 'Activo' ELSE 'Inactivo' END AS ESTADO
    FROM ASESOR a
    WHERE a.IDASESOR = p_Id;
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_asesor_insertar;

DROP PROCEDURE IF EXISTS usp_asesor_insertar;

DELIMITER $$

CREATE PROCEDURE usp_asesor_insertar(
    IN p_Id VARCHAR(50),
    IN p_Nombre VARCHAR(150),
    IN p_Estado VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
IF p_Id IS NULL OR TRIM(p_Id) = '' THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa el código del asesor.';
        LEAVE main;
    
    END IF;

    IF p_Nombre IS NULL OR TRIM(p_Nombre) = '' THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa el nombre del asesor.';
        LEAVE main;
    
    END IF;

    IF EXISTS (SELECT 1 FROM ASESOR WHERE IDASESOR = p_Id) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'El código de asesor ya existe.';
        LEAVE main;
    
    END IF;

    IF EXISTS (SELECT 1 FROM ASESOR WHERE NOMBRE = p_Nombre) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ya existe un asesor con ese nombre.';
        LEAVE main;
    
    INSERT INTO ASESOR (IDASESOR, NOMBRE, ACTIVO)
    VALUES (
        p_Id,
        p_Nombre,
        CASE WHEN p_Estado = 'Activo' THEN 1 ELSE 0 END);

    SET p_Resultado = 1; SET p_Mensaje = 'Asesor registrado.';
    SELECT p_Resultado AS Resultado, p_Mensaje AS Mensaje
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_asesor_actualizar;

DROP PROCEDURE IF EXISTS usp_asesor_actualizar;

DELIMITER $$

CREATE PROCEDURE usp_asesor_actualizar(
    IN p_Id VARCHAR(50),
    IN p_Nombre VARCHAR(150),
    IN p_Estado VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
IF NOT EXISTS (SELECT 1 FROM ASESOR WHERE IDASESOR = p_Id) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'El asesor no existe.';
        LEAVE main;
    
    END IF;

    IF p_Nombre IS NULL OR TRIM(p_Nombre) = '' THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa el nombre del asesor.';
        LEAVE main;
    
    END IF;

    IF EXISTS (SELECT 1 FROM ASESOR WHERE NOMBRE = p_Nombre AND IDASESOR <> p_Id) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ya existe un asesor con ese nombre.';
        LEAVE main;
    
    UPDATE ASESOR SET
        NOMBRE = p_Nombre,
        ACTIVO = CASE WHEN p_Estado = 'Activo' THEN 1 ELSE 0 END
    WHERE IDASESOR = p_Id;

    SET p_Resultado = 1; SET p_Mensaje = 'Asesor actualizado.';
    SELECT p_Resultado AS Resultado, p_Mensaje AS Mensaje
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_asesor_eliminar;

DROP PROCEDURE IF EXISTS usp_asesor_eliminar;

DELIMITER $$

CREATE PROCEDURE usp_asesor_eliminar(
    IN p_Id VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
IF NOT EXISTS (SELECT 1 FROM ASESOR WHERE IDASESOR = p_Id) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'El asesor no existe.';
        LEAVE main;
    
    END IF;

    IF EXISTS (SELECT 1 FROM MEMBRESIA WHERE IDASESOR = p_Id) THEN
        SET p_Resultado = 0;
        SET p_Mensaje = 'No se puede eliminar: el asesor tiene membresías asociadas.';
        LEAVE main;
    
    DELETE FROM ASESOR WHERE IDASESOR = p_Id;

    SET p_Resultado = 1; SET p_Mensaje = 'Asesor eliminado.';
END;

SELECT 'SPs usp_asesor_* creados.';
    SELECT p_Resultado AS Resultado, p_Mensaje AS Mensaje
END$$

DELIMITER ;