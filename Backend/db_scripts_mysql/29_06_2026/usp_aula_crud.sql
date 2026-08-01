-- Convertido automáticamente desde db_scripts/29_06_2026/usp_aula_crud.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   CRUD AULA — Mantenedor de aulas (módulo Académico)
   5 SPs estándar: listar, obtener, insertar, actualizar, eliminar
   Fecha: 29/06/2026
   ============================================================================ */

DROP PROCEDURE IF EXISTS usp_aula_listar;

DROP PROCEDURE IF EXISTS usp_aula_listar;

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
IF p_Pagina < 1 THEN SET p_Pagina = 1; END IF;
    IF p_TamanioPagina < 1 THEN SET p_TamanioPagina = 10; END IF;

    SELECT COUNT(*) INTO p_TotalRegistros
    FROM AULA a
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           a.IDAULA      LIKE CONCAT('%', p_Buscar, '%') OR
           a.NOMBRE      LIKE CONCAT('%', p_Buscar, '%') OR
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
           a.IDAULA      LIKE CONCAT('%', p_Buscar, '%') OR
           a.NOMBRE      LIKE CONCAT('%', p_Buscar, '%') OR
           a.DESCRIPCION LIKE CONCAT('%', p_Buscar, '%'))
      AND (p_Estado IS NULL OR p_Estado = '' OR
           (p_Estado = 'Activo' AND a.ACTIVO = 1) OR
           (p_Estado = 'Inactivo' AND a.ACTIVO = 0))
    ORDER BY
        CASE WHEN p_OrdenarPor = 'IDAULA'   AND p_Direccion = 'ASC'  THEN a.IDAULA END ASC,
        CASE WHEN p_OrdenarPor = 'IDAULA'   AND p_Direccion = 'DESC' THEN a.IDAULA END DESC,
        CASE WHEN p_OrdenarPor = 'NOMBRE'   AND p_Direccion = 'ASC'  THEN a.NOMBRE END ASC,
        CASE WHEN p_OrdenarPor = 'NOMBRE'   AND p_Direccion = 'DESC' THEN a.NOMBRE END DESC,
        CASE WHEN p_OrdenarPor = 'CAPACIDAD' AND p_Direccion = 'ASC' THEN CAST(a.CAPACIDAD AS VARCHAR(20)) END ASC,
        CASE WHEN p_OrdenarPor = 'CAPACIDAD' AND p_Direccion = 'DESC' THEN CAST(a.CAPACIDAD AS VARCHAR(20)) END DESC,
        CASE WHEN p_OrdenarPor = 'ESTADO'   AND p_Direccion = 'ASC'  THEN a.ACTIVO END ASC,
        CASE WHEN p_OrdenarPor = 'ESTADO'   AND p_Direccion = 'DESC' THEN a.ACTIVO END DESC,
        a.NOMBRE
    LIMIT p_TamanioPagina OFFSET ((p_Pagina - 1) * p_TamanioPagina);
    SELECT p_TotalRegistros AS TotalRegistros
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_aula_obtener;

DROP PROCEDURE IF EXISTS usp_aula_obtener;

DELIMITER $$

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

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_aula_insertar;

DROP PROCEDURE IF EXISTS usp_aula_insertar;

DELIMITER $$

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
IF p_Id IS NULL OR TRIM(p_Id)) = ''
    BEGIN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa el código del aula.';
        LEAVE main;
    
    IF p_Nombre IS NULL OR TRIM(p_Nombre)) = ''
    BEGIN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa el nombre del aula.';
        LEAVE main;
    
    IF EXISTS (SELECT 1 FROM AULA WHERE IDAULA = p_Id)
    BEGIN
        SET p_Resultado = 0; SET p_Mensaje = 'El código de aula ya existe.';
        LEAVE main;
    
    IF EXISTS (SELECT 1 FROM AULA WHERE NOMBRE = p_Nombre)
    BEGIN
        SET p_Resultado = 0; SET p_Mensaje = 'Ya existe un aula con ese nombre.';
        LEAVE main;
    
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

    SET p_Resultado = 1; SET p_Mensaje = 'Aula registrada.';
    SELECT p_Resultado AS Resultado, p_Mensaje AS Mensaje
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_aula_actualizar;

DROP PROCEDURE IF EXISTS usp_aula_actualizar;

DELIMITER $$

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
IF NOT EXISTS (SELECT 1 FROM AULA WHERE IDAULA = p_Id)
    BEGIN
        SET p_Resultado = 0; SET p_Mensaje = 'El aula no existe.';
        LEAVE main;
    
    IF p_Nombre IS NULL OR TRIM(p_Nombre)) = ''
    BEGIN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa el nombre del aula.';
        LEAVE main;
    
    IF EXISTS (SELECT 1 FROM AULA WHERE NOMBRE = p_Nombre AND IDAULA <> p_Id)
    BEGIN
        SET p_Resultado = 0; SET p_Mensaje = 'Ya existe un aula con ese nombre.';
        LEAVE main;
    
    UPDATE AULA SET
        NOMBRE             = p_Nombre,
        DESCRIPCION        = p_Descripcion,
        CAPACIDAD          = p_Capacidad,
        ENLACEVIRTUAL      = p_EnlaceVirtual,
        ENLACECUESTIONARIO = p_EnlaceCuestionario,
        ACTIVO             = CASE WHEN p_Estado = 'Activo' THEN 1 ELSE 0 
    WHERE IDAULA = p_Id;

    SET p_Resultado = 1; SET p_Mensaje = 'Aula actualizada.';
    SELECT p_Resultado AS Resultado, p_Mensaje AS Mensaje
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_aula_eliminar;

DROP PROCEDURE IF EXISTS usp_aula_eliminar;

DELIMITER $$

CREATE PROCEDURE usp_aula_eliminar(
    IN p_Id VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
IF NOT EXISTS (SELECT 1 FROM AULA WHERE IDAULA = p_Id)
    BEGIN
        SET p_Resultado = 0; SET p_Mensaje = 'El aula no existe.';
        LEAVE main;
    
    IF EXISTS (SELECT 1 FROM MEMBRESIA WHERE IDAULA = p_Id)
    BEGIN
        SET p_Resultado = 0;
        SET p_Mensaje = 'No se puede eliminar: el aula tiene membresías asociadas.';
        LEAVE main;
    
    DELETE FROM AULA WHERE IDAULA = p_Id;

    SET p_Resultado = 1; SET p_Mensaje = 'Aula eliminada.';
END;

SELECT 'SPs usp_aula_* creados.';
    SELECT p_Resultado AS Resultado, p_Mensaje AS Mensaje
END$$

DELIMITER ;
