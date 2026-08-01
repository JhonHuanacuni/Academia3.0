-- Convertido automáticamente desde db_scripts/12_07_2026/3.usp_plan_crud.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   CRUD PLAN — Mantenedor de planes (módulo Académico)
   Solo catálogo: código, nombre, descripción, activo.
   Duración y monto viven en MEMBRESIA (FECHAINICIO/FECHAFIN/MONTOTOTAL).
   Fecha: 12/07/2026
   ============================================================================ */

DROP PROCEDURE IF EXISTS usp_plan_listar;

DROP PROCEDURE IF EXISTS usp_plan_listar;

DELIMITER $$

CREATE PROCEDURE usp_plan_listar(
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

    SET @v_offset = (p_Pagina - 1) * p_TamanioPagina;
    SELECT COUNT(*) INTO p_TotalRegistros
    FROM `PLAN` p
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           p.IDPLAN      LIKE CONCAT('%', p_Buscar, '%') OR
           p.NOMBRE      LIKE CONCAT('%', p_Buscar, '%') OR
           p.DESCRIPCION LIKE CONCAT('%', p_Buscar, '%'))
      AND (p_Estado IS NULL OR p_Estado = '' OR
           (p_Estado = 'Activo' AND p.ACTIVO = 1) OR
           (p_Estado = 'Inactivo' AND p.ACTIVO = 0));

    SELECT
        p.IDPLAN,
        p.NOMBRE,
        p.DESCRIPCION,
        CASE WHEN p.ACTIVO = 1 THEN 'Activo' ELSE 'Inactivo' END AS ESTADO
    FROM `PLAN` p
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           p.IDPLAN      LIKE CONCAT('%', p_Buscar, '%') OR
           p.NOMBRE      LIKE CONCAT('%', p_Buscar, '%') OR
           p.DESCRIPCION LIKE CONCAT('%', p_Buscar, '%'))
      AND (p_Estado IS NULL OR p_Estado = '' OR
           (p_Estado = 'Activo' AND p.ACTIVO = 1) OR
           (p_Estado = 'Inactivo' AND p.ACTIVO = 0))
    ORDER BY
        CASE WHEN p_OrdenarPor = 'IDPLAN' AND p_Direccion = 'ASC'  THEN p.IDPLAN END ASC,
        CASE WHEN p_OrdenarPor = 'IDPLAN' AND p_Direccion = 'DESC' THEN p.IDPLAN END DESC,
        CASE WHEN p_OrdenarPor = 'NOMBRE' AND p_Direccion = 'ASC'  THEN p.NOMBRE END ASC,
        CASE WHEN p_OrdenarPor = 'NOMBRE' AND p_Direccion = 'DESC' THEN p.NOMBRE END DESC,
        CASE WHEN p_OrdenarPor = 'ESTADO' AND p_Direccion = 'ASC'  THEN p.ACTIVO END ASC,
        CASE WHEN p_OrdenarPor = 'ESTADO' AND p_Direccion = 'DESC' THEN p.ACTIVO END DESC,
        p.NOMBRE
    LIMIT p_TamanioPagina OFFSET @v_offset;
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_plan_obtener;

DROP PROCEDURE IF EXISTS usp_plan_obtener;

DELIMITER $$

CREATE PROCEDURE usp_plan_obtener(
    IN p_Id VARCHAR(50)
)
main: BEGIN
SELECT
        p.IDPLAN,
        p.NOMBRE,
        p.DESCRIPCION,
        CASE WHEN p.ACTIVO = 1 THEN 'Activo' ELSE 'Inactivo' END AS ESTADO
    FROM `PLAN` p
    WHERE p.IDPLAN = p_Id;
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_plan_insertar;

DROP PROCEDURE IF EXISTS usp_plan_insertar;

DELIMITER $$

CREATE PROCEDURE usp_plan_insertar(
    IN p_Id VARCHAR(50),
    IN p_Nombre VARCHAR(100),
    IN p_Descripcion VARCHAR(255),
    IN p_Estado VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
IF p_Id IS NULL OR TRIM(p_Id) = '' THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa el código del plan.'; LEAVE main;     END IF;

    IF p_Nombre IS NULL OR TRIM(p_Nombre) = '' THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa el nombre del plan.'; LEAVE main;     END IF;

    IF EXISTS (SELECT 1 FROM `PLAN` WHERE IDPLAN = p_Id) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'El código de plan ya existe.'; LEAVE main;     END IF;

    IF EXISTS (SELECT 1 FROM `PLAN` WHERE NOMBRE = p_Nombre) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ya existe un plan con ese nombre.'; LEAVE main;     END IF;
    INSERT INTO `PLAN` (IDPLAN, NOMBRE, DESCRIPCION, ACTIVO)
    VALUES (
        p_Id,
        p_Nombre,
        p_Descripcion,
        CASE WHEN p_Estado = 'Activo' THEN 1 ELSE 0 END);

    SET p_Resultado = 1; SET p_Mensaje = 'Plan registrado.';
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_plan_actualizar;

DROP PROCEDURE IF EXISTS usp_plan_actualizar;

DELIMITER $$

CREATE PROCEDURE usp_plan_actualizar(
    IN p_Id VARCHAR(50),
    IN p_Nombre VARCHAR(100),
    IN p_Descripcion VARCHAR(255),
    IN p_Estado VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
IF NOT EXISTS (SELECT 1 FROM `PLAN` WHERE IDPLAN = p_Id) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'El plan no existe.'; LEAVE main;     END IF;

    IF p_Nombre IS NULL OR TRIM(p_Nombre) = '' THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa el nombre del plan.'; LEAVE main;     END IF;

    IF EXISTS (SELECT 1 FROM `PLAN` WHERE NOMBRE = p_Nombre AND IDPLAN <> p_Id) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ya existe un plan con ese nombre.'; LEAVE main;     END IF;
    UPDATE `PLAN` SET
        NOMBRE      = p_Nombre,
        DESCRIPCION = p_Descripcion,
        ACTIVO      = CASE WHEN p_Estado = 'Activo' THEN 1 ELSE 0 END
    WHERE IDPLAN = p_Id;

    SET p_Resultado = 1; SET p_Mensaje = 'Plan actualizado.';
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_plan_eliminar;

DROP PROCEDURE IF EXISTS usp_plan_eliminar;

DELIMITER $$

CREATE PROCEDURE usp_plan_eliminar(
    IN p_Id VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
IF NOT EXISTS (SELECT 1 FROM `PLAN` WHERE IDPLAN = p_Id) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'El plan no existe.'; LEAVE main;     END IF;

    IF EXISTS (SELECT 1 FROM MEMBRESIA WHERE IDPLAN = p_Id) THEN
        SET p_Resultado = 0;
        SET p_Mensaje = 'No se puede eliminar: el plan tiene membresías asociadas.';
        LEAVE main;
    
    END IF;

    DELETE FROM `PLAN` WHERE IDPLAN = p_Id;

    SET p_Resultado = 1; SET p_Mensaje = 'Plan eliminado.';
END$$

DELIMITER ;