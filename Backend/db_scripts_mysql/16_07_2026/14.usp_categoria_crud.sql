-- Convertido automáticamente desde db_scripts/16_07_2026/14.usp_categoria_crud.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   CRUD CATEGORIA
   Ejecutar después de 13.categoria_materia_tablas.sql
   Fecha: 16/07/2026
   ============================================================================ */

DROP PROCEDURE IF EXISTS usp_categoria_listar;

DROP PROCEDURE IF EXISTS usp_categoria_listar;

DELIMITER $$

CREATE PROCEDURE usp_categoria_listar(
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

    SET v_offset = (p_Pagina - 1) * p_TamanioPagina;
    SELECT COUNT(*) INTO p_TotalRegistros
    FROM CATEGORIA c
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           c.IDCATEGORIA LIKE CONCAT('%', p_Buscar, '%') OR
           c.NOMBRE LIKE CONCAT('%', p_Buscar, '%'))
      AND (p_Estado IS NULL OR p_Estado = '' OR
           (p_Estado = 'Activo' AND c.ACTIVO = 1) OR
           (p_Estado = 'Inactivo' AND c.ACTIVO = 0));

    SELECT
        c.IDCATEGORIA,
        c.NOMBRE,
        c.PORCENTAJE,
        c.ORDEN,
        CASE WHEN c.ACTIVO = 1 THEN 'Activo' ELSE 'Inactivo' END AS ESTADO
    FROM CATEGORIA c
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           c.IDCATEGORIA LIKE CONCAT('%', p_Buscar, '%') OR
           c.NOMBRE LIKE CONCAT('%', p_Buscar, '%'))
      AND (p_Estado IS NULL OR p_Estado = '' OR
           (p_Estado = 'Activo' AND c.ACTIVO = 1) OR
           (p_Estado = 'Inactivo' AND c.ACTIVO = 0))
    ORDER BY
        CASE WHEN p_OrdenarPor = 'IDCATEGORIA' AND p_Direccion = 'ASC'  THEN c.IDCATEGORIA END ASC,
        CASE WHEN p_OrdenarPor = 'IDCATEGORIA' AND p_Direccion = 'DESC' THEN c.IDCATEGORIA END DESC,
        CASE WHEN p_OrdenarPor = 'NOMBRE' AND p_Direccion = 'ASC'  THEN c.NOMBRE END ASC,
        CASE WHEN p_OrdenarPor = 'NOMBRE' AND p_Direccion = 'DESC' THEN c.NOMBRE END DESC,
        CASE WHEN p_OrdenarPor = 'PORCENTAJE' AND p_Direccion = 'ASC'  THEN c.PORCENTAJE END ASC,
        CASE WHEN p_OrdenarPor = 'PORCENTAJE' AND p_Direccion = 'DESC' THEN c.PORCENTAJE END DESC,
        CASE WHEN p_OrdenarPor = 'ORDEN' AND p_Direccion = 'ASC'  THEN c.ORDEN END ASC,
        CASE WHEN p_OrdenarPor = 'ORDEN' AND p_Direccion = 'DESC' THEN c.ORDEN END DESC,
        CASE WHEN p_OrdenarPor = 'ESTADO' AND p_Direccion = 'ASC'  THEN c.ACTIVO END ASC,
        CASE WHEN p_OrdenarPor = 'ESTADO' AND p_Direccion = 'DESC' THEN c.ACTIVO END DESC,
        c.ORDEN, c.NOMBRE
    LIMIT p_TamanioPagina OFFSET v_offset;
    SELECT p_TotalRegistros AS TotalRegistros
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_categoria_obtener;

DROP PROCEDURE IF EXISTS usp_categoria_obtener;

DELIMITER $$

CREATE PROCEDURE usp_categoria_obtener(
    IN p_Id VARCHAR(50)
)
main: BEGIN
SELECT
        c.IDCATEGORIA,
        c.NOMBRE,
        c.PORCENTAJE,
        c.ORDEN,
        CASE WHEN c.ACTIVO = 1 THEN 'Activo' ELSE 'Inactivo' END AS ESTADO
    FROM CATEGORIA c
    WHERE c.IDCATEGORIA = p_Id;
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_categoria_insertar;

DROP PROCEDURE IF EXISTS usp_categoria_insertar;

DELIMITER $$

CREATE PROCEDURE usp_categoria_insertar(
    IN p_Id VARCHAR(50),
    IN p_Nombre VARCHAR(100),
    IN p_Porcentaje DECIMAL(5,2),
    IN p_Orden INT,
    IN p_Estado VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
IF p_Id IS NULL OR TRIM(p_Id) = '' THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa el código de la categoría.'; LEAVE main;     END IF;

    IF p_Nombre IS NULL OR TRIM(p_Nombre) = '' THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa el nombre de la categoría.'; LEAVE main;     END IF;

    IF p_Porcentaje IS NOT NULL AND (p_Porcentaje < 0 OR p_Porcentaje > 100) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'El porcentaje debe estar entre 0 y 100.'; LEAVE main;     END IF;

    IF EXISTS (SELECT 1 FROM CATEGORIA WHERE IDCATEGORIA = p_Id) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'El código de categoría ya existe.'; LEAVE main;     END IF;

    IF EXISTS (SELECT 1 FROM CATEGORIA WHERE NOMBRE = p_Nombre) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ya existe una categoría con ese nombre.'; LEAVE main;     END IF;
    INSERT INTO CATEGORIA (IDCATEGORIA, NOMBRE, PORCENTAJE, ORDEN, ACTIVO)
    VALUES (
        p_Id,
        p_Nombre,
        p_Porcentaje,
        IFNULL(p_Orden, 0),
        CASE WHEN p_Estado = 'Activo' THEN 1 ELSE 0 END);

    SET p_Resultado = 1; SET p_Mensaje = 'Categoría registrada.';
    SELECT p_Resultado AS Resultado, p_Mensaje AS Mensaje
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_categoria_actualizar;

DROP PROCEDURE IF EXISTS usp_categoria_actualizar;

DELIMITER $$

CREATE PROCEDURE usp_categoria_actualizar(
    IN p_Id VARCHAR(50),
    IN p_Nombre VARCHAR(100),
    IN p_Porcentaje DECIMAL(5,2),
    IN p_Orden INT,
    IN p_Estado VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
IF NOT EXISTS (SELECT 1 FROM CATEGORIA WHERE IDCATEGORIA = p_Id) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'La categoría no existe.'; LEAVE main;     END IF;

    IF p_Nombre IS NULL OR TRIM(p_Nombre) = '' THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa el nombre de la categoría.'; LEAVE main;     END IF;

    IF p_Porcentaje IS NOT NULL AND (p_Porcentaje < 0 OR p_Porcentaje > 100) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'El porcentaje debe estar entre 0 y 100.'; LEAVE main;     END IF;

    IF EXISTS (SELECT 1 FROM CATEGORIA WHERE NOMBRE = p_Nombre AND IDCATEGORIA <> p_Id) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ya existe una categoría con ese nombre.'; LEAVE main;     END IF;
    UPDATE CATEGORIA SET
        NOMBRE     = p_Nombre,
        PORCENTAJE = p_Porcentaje,
        ORDEN      = IFNULL(p_Orden, 0),
        ACTIVO     = CASE WHEN p_Estado = 'Activo' THEN 1 ELSE 0 END
    WHERE IDCATEGORIA = p_Id;

    SET p_Resultado = 1; SET p_Mensaje = 'Categoría actualizada.';
    SELECT p_Resultado AS Resultado, p_Mensaje AS Mensaje
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_categoria_eliminar;

DROP PROCEDURE IF EXISTS usp_categoria_eliminar;

DELIMITER $$

CREATE PROCEDURE usp_categoria_eliminar(
    IN p_Id VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
IF NOT EXISTS (SELECT 1 FROM CATEGORIA WHERE IDCATEGORIA = p_Id) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'La categoría no existe.'; LEAVE main;     END IF;

    IF EXISTS (SELECT 1 FROM MATERIA WHERE IDCATEGORIA = p_Id) THEN
        SET p_Resultado = 0;
        SET p_Mensaje = 'No se puede eliminar: hay materias asociadas.';
        LEAVE main;
    
    DELETE FROM CATEGORIA WHERE IDCATEGORIA = p_Id;
    SET p_Resultado = 1; SET p_Mensaje = 'Categoría eliminada.';
END;

SELECT 'SPs usp_categoria_* creados.';
    SELECT p_Resultado AS Resultado, p_Mensaje AS Mensaje
END$$

DELIMITER ;