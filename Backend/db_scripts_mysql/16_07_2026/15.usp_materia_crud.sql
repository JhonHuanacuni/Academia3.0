-- Convertido automáticamente desde db_scripts/16_07_2026/15.usp_materia_crud.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   CRUD MATERIA (con categoría)
   Ejecutar después de 14.usp_categoria_crud.sql
   Fecha: 16/07/2026
   ============================================================================ */

DROP PROCEDURE IF EXISTS usp_materia_listar;

DROP PROCEDURE IF EXISTS usp_materia_listar;

DELIMITER $$

CREATE PROCEDURE usp_materia_listar(
    IN p_Buscar VARCHAR(200),
    IN p_Estado VARCHAR(50),
    IN p_IdCategoria VARCHAR(50),
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
    FROM MATERIA m
    LEFT JOIN CATEGORIA c ON c.IDCATEGORIA = m.IDCATEGORIA
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           m.IDMATERIA LIKE CONCAT('%', p_Buscar, '%') OR
           IFNULL(m.CODIGO, '') LIKE CONCAT('%', p_Buscar, '%') OR
           m.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
           IFNULL(c.NOMBRE, '') LIKE CONCAT('%', p_Buscar, '%'))
      AND (p_Estado IS NULL OR p_Estado = '' OR
           (p_Estado = 'Activo' AND IFNULL(m.ACTIVO, 1) = 1) OR
           (p_Estado = 'Inactivo' AND IFNULL(m.ACTIVO, 1) = 0))
      AND (p_IdCategoria IS NULL OR p_IdCategoria = '' OR m.IDCATEGORIA = p_IdCategoria);

    SELECT
        m.IDMATERIA,
        m.CODIGO,
        m.NOMBRE,
        m.IDCATEGORIA,
        IFNULL(c.NOMBRE, '') AS CATEGORIA_NOMBRE,
        CASE WHEN IFNULL(m.ACTIVO, 1) = 1 THEN 'Activo' ELSE 'Inactivo' END AS ESTADO
    FROM MATERIA m
    LEFT JOIN CATEGORIA c ON c.IDCATEGORIA = m.IDCATEGORIA
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           m.IDMATERIA LIKE CONCAT('%', p_Buscar, '%') OR
           IFNULL(m.CODIGO, '') LIKE CONCAT('%', p_Buscar, '%') OR
           m.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
           IFNULL(c.NOMBRE, '') LIKE CONCAT('%', p_Buscar, '%'))
      AND (p_Estado IS NULL OR p_Estado = '' OR
           (p_Estado = 'Activo' AND IFNULL(m.ACTIVO, 1) = 1) OR
           (p_Estado = 'Inactivo' AND IFNULL(m.ACTIVO, 1) = 0))
      AND (p_IdCategoria IS NULL OR p_IdCategoria = '' OR m.IDCATEGORIA = p_IdCategoria)
    ORDER BY
        CASE WHEN p_OrdenarPor = 'IDMATERIA' AND p_Direccion = 'ASC'  THEN m.IDMATERIA END ASC,
        CASE WHEN p_OrdenarPor = 'IDMATERIA' AND p_Direccion = 'DESC' THEN m.IDMATERIA END DESC,
        CASE WHEN p_OrdenarPor = 'CODIGO' AND p_Direccion = 'ASC'  THEN m.CODIGO END ASC,
        CASE WHEN p_OrdenarPor = 'CODIGO' AND p_Direccion = 'DESC' THEN m.CODIGO END DESC,
        CASE WHEN p_OrdenarPor = 'NOMBRE' AND p_Direccion = 'ASC'  THEN m.NOMBRE END ASC,
        CASE WHEN p_OrdenarPor = 'NOMBRE' AND p_Direccion = 'DESC' THEN m.NOMBRE END DESC,
        CASE WHEN p_OrdenarPor = 'CATEGORIA_NOMBRE' AND p_Direccion = 'ASC'  THEN c.NOMBRE END ASC,
        CASE WHEN p_OrdenarPor = 'CATEGORIA_NOMBRE' AND p_Direccion = 'DESC' THEN c.NOMBRE END DESC,
        CASE WHEN p_OrdenarPor = 'ESTADO' AND p_Direccion = 'ASC'  THEN m.ACTIVO END ASC,
        CASE WHEN p_OrdenarPor = 'ESTADO' AND p_Direccion = 'DESC' THEN m.ACTIVO END DESC,
        m.NOMBRE
    LIMIT p_TamanioPagina OFFSET ((p_Pagina - 1) * p_TamanioPagina);
    SELECT p_TotalRegistros AS TotalRegistros
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_materia_obtener;

DROP PROCEDURE IF EXISTS usp_materia_obtener;

DELIMITER $$

CREATE PROCEDURE usp_materia_obtener(
    IN p_Id VARCHAR(50)
)
main: BEGIN
SELECT
        m.IDMATERIA,
        m.CODIGO,
        m.NOMBRE,
        m.IDCATEGORIA,
        IFNULL(c.NOMBRE, '') AS CATEGORIA_NOMBRE,
        CASE WHEN IFNULL(m.ACTIVO, 1) = 1 THEN 'Activo' ELSE 'Inactivo' END AS ESTADO
    FROM MATERIA m
    LEFT JOIN CATEGORIA c ON c.IDCATEGORIA = m.IDCATEGORIA
    WHERE m.IDMATERIA = p_Id;
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_materia_insertar;

DROP PROCEDURE IF EXISTS usp_materia_insertar;

DELIMITER $$

CREATE PROCEDURE usp_materia_insertar(
    IN p_Id VARCHAR(50),
    IN p_Codigo VARCHAR(50),
    IN p_Nombre VARCHAR(150),
    IN p_IdCategoria VARCHAR(50),
    IN p_Estado VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
IF p_Id IS NULL OR TRIM(p_Id)) = ''
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'Ingresa el código de la materia.'; LEAVE main; 
    IF p_Nombre IS NULL OR TRIM(p_Nombre)) = ''
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'Ingresa el nombre de la materia.'; LEAVE main; 
    IF EXISTS (SELECT 1 FROM MATERIA WHERE IDMATERIA = p_Id)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'El código de materia ya existe.'; LEAVE main; 
    IF EXISTS (SELECT 1 FROM MATERIA WHERE NOMBRE = p_Nombre)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'Ya existe una materia con ese nombre.'; LEAVE main; 
    IF p_IdCategoria IS NOT NULL AND TRIM(p_IdCategoria)) <> ''
       AND NOT EXISTS (SELECT 1 FROM CATEGORIA WHERE IDCATEGORIA = p_IdCategoria)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'La categoría no existe.'; LEAVE main; 
    IF p_Codigo IS NOT NULL AND TRIM(p_Codigo)) <> ''
       AND EXISTS (SELECT 1 FROM MATERIA WHERE CODIGO = p_Codigo)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'Ya existe una materia con ese código corto.'; LEAVE main; 
    INSERT INTO MATERIA (IDMATERIA, CODIGO, NOMBRE, IDCATEGORIA, ACTIVO)
    VALUES (
        p_Id,
        NULLIF(TRIM(p_Codigo)), ''),
        p_Nombre,
        NULLIF(TRIM(p_IdCategoria)), ''),
        CASE WHEN p_Estado = 'Activo' THEN 1 ELSE 0 
    );

    SET p_Resultado = 1; SET p_Mensaje = 'Materia registrada.';
    SELECT p_Resultado AS Resultado, p_Mensaje AS Mensaje
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_materia_actualizar;

DROP PROCEDURE IF EXISTS usp_materia_actualizar;

DELIMITER $$

CREATE PROCEDURE usp_materia_actualizar(
    IN p_Id VARCHAR(50),
    IN p_Codigo VARCHAR(50),
    IN p_Nombre VARCHAR(150),
    IN p_IdCategoria VARCHAR(50),
    IN p_Estado VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
IF NOT EXISTS (SELECT 1 FROM MATERIA WHERE IDMATERIA = p_Id)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'La materia no existe.'; LEAVE main; 
    IF p_Nombre IS NULL OR TRIM(p_Nombre)) = ''
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'Ingresa el nombre de la materia.'; LEAVE main; 
    IF EXISTS (SELECT 1 FROM MATERIA WHERE NOMBRE = p_Nombre AND IDMATERIA <> p_Id)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'Ya existe una materia con ese nombre.'; LEAVE main; 
    IF p_IdCategoria IS NOT NULL AND TRIM(p_IdCategoria)) <> ''
       AND NOT EXISTS (SELECT 1 FROM CATEGORIA WHERE IDCATEGORIA = p_IdCategoria)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'La categoría no existe.'; LEAVE main; 
    IF p_Codigo IS NOT NULL AND TRIM(p_Codigo)) <> ''
       AND EXISTS (SELECT 1 FROM MATERIA WHERE CODIGO = p_Codigo AND IDMATERIA <> p_Id)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'Ya existe una materia con ese código corto.'; LEAVE main; 
    UPDATE MATERIA SET
        CODIGO      = NULLIF(TRIM(p_Codigo)), ''),
        NOMBRE      = p_Nombre,
        IDCATEGORIA = NULLIF(TRIM(p_IdCategoria)), ''),
        ACTIVO      = CASE WHEN p_Estado = 'Activo' THEN 1 ELSE 0 
    WHERE IDMATERIA = p_Id;

    SET p_Resultado = 1; SET p_Mensaje = 'Materia actualizada.';
    SELECT p_Resultado AS Resultado, p_Mensaje AS Mensaje
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_materia_eliminar;

DROP PROCEDURE IF EXISTS usp_materia_eliminar;

DELIMITER $$

CREATE PROCEDURE usp_materia_eliminar(
    IN p_Id VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
IF NOT EXISTS (SELECT 1 FROM MATERIA WHERE IDMATERIA = p_Id)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'La materia no existe.'; LEAVE main; 
    IF OBJECT_ID('PREGUNTA', 'U') IS NOT NULL
       AND EXISTS (SELECT 1 FROM PREGUNTA WHERE IDMATERIA = p_Id)
    BEGIN
        SET p_Resultado = 0;
        SET p_Mensaje = 'No se puede eliminar: la materia tiene preguntas asociadas.';
        LEAVE main;
    
    IF OBJECT_ID('LIBRO_MATERIA', 'U') IS NOT NULL
       AND EXISTS (SELECT 1 FROM LIBRO_MATERIA WHERE IDMATERIA = p_Id)
    BEGIN
        SET p_Resultado = 0;
        SET p_Mensaje = 'No se puede eliminar: la materia está ligada a libros.';
        LEAVE main;
    
    DELETE FROM MATERIA WHERE IDMATERIA = p_Id;
    SET p_Resultado = 1; SET p_Mensaje = 'Materia eliminada.';
END;

SELECT 'SPs usp_materia_* creados.';
    SELECT p_Resultado AS Resultado, p_Mensaje AS Mensaje
END$$

DELIMITER ;
