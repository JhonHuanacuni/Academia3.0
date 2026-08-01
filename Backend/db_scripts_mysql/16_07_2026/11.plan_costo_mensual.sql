-- Convertido automáticamente desde db_scripts/16_07_2026/11.plan_costo_mensual.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   PLAN: columna CONCAT(COSTOMENSUAL, SPs) actualizados
   Fecha: 16/07/2026
   ============================================================================ */

SET @col_PLAN_COSTOMENSUAL := (
    SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'PLAN' AND COLUMN_NAME = 'COSTOMENSUAL'
);
SET @sql_PLAN_COSTOMENSUAL := IF(@col_PLAN_COSTOMENSUAL = 0, 'ALTER TABLE `PLAN` ADD COSTOMENSUAL DECIMAL(10,2) NULL', 'SELECT 1');
PREPARE stmt FROM @sql_PLAN_COSTOMENSUAL; EXECUTE stmt; DEALLOCATE PREPARE stmt;
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
        p.COSTOMENSUAL,
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
        CASE WHEN p_OrdenarPor = 'COSTOMENSUAL' AND p_Direccion = 'ASC'  THEN p.COSTOMENSUAL END ASC,
        CASE WHEN p_OrdenarPor = 'COSTOMENSUAL' AND p_Direccion = 'DESC' THEN p.COSTOMENSUAL END DESC,
        CASE WHEN p_OrdenarPor = 'ESTADO' AND p_Direccion = 'ASC'  THEN p.ACTIVO END ASC,
        CASE WHEN p_OrdenarPor = 'ESTADO' AND p_Direccion = 'DESC' THEN p.ACTIVO END DESC,
        p.NOMBRE
    LIMIT p_TamanioPagina OFFSET ((p_Pagina - 1) * p_TamanioPagina);
    SELECT p_TotalRegistros AS TotalRegistros
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
        p.COSTOMENSUAL,
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
    IN p_CostoMensual DECIMAL(10,2),
    IN p_Estado VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
IF p_Id IS NULL OR TRIM(p_Id) = ''
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'Ingresa el código del plan.'; LEAVE main; 
    END IF;

    IF p_Nombre IS NULL OR TRIM(p_Nombre) = ''
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'Ingresa el nombre del plan.'; LEAVE main; 
    END IF;

    IF p_CostoMensual IS NOT NULL AND p_CostoMensual < 0
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'El costo mensual no puede ser negativo.'; LEAVE main; 
    END IF;

    IF EXISTS (SELECT 1 FROM `PLAN` WHERE IDPLAN = p_Id)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'El código de plan ya existe.'; LEAVE main; 
    END IF;

    IF EXISTS (SELECT 1 FROM `PLAN` WHERE NOMBRE = p_Nombre)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'Ya existe un plan con ese nombre.'; LEAVE main; 
    INSERT INTO `PLAN` (IDPLAN, NOMBRE, DESCRIPCION, COSTOMENSUAL, ACTIVO)
    VALUES (
        p_Id,
        p_Nombre,
        p_Descripcion,
        p_CostoMensual,
        CASE WHEN p_Estado = 'Activo' THEN 1 ELSE 0 END);

    SET p_Resultado = 1; SET p_Mensaje = 'Plan registrado.';
    SELECT p_Resultado AS Resultado, p_Mensaje AS Mensaje
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_plan_actualizar;

DROP PROCEDURE IF EXISTS usp_plan_actualizar;

DELIMITER $$

CREATE PROCEDURE usp_plan_actualizar(
    IN p_Id VARCHAR(50),
    IN p_Nombre VARCHAR(100),
    IN p_Descripcion VARCHAR(255),
    IN p_CostoMensual DECIMAL(10,2),
    IN p_Estado VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
IF NOT EXISTS (SELECT 1 FROM `PLAN` WHERE IDPLAN = p_Id)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'El plan no existe.'; LEAVE main; 
    END IF;

    IF p_Nombre IS NULL OR TRIM(p_Nombre) = ''
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'Ingresa el nombre del plan.'; LEAVE main; 
    END IF;

    IF p_CostoMensual IS NOT NULL AND p_CostoMensual < 0
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'El costo mensual no puede ser negativo.'; LEAVE main; 
    END IF;

    IF EXISTS (SELECT 1 FROM `PLAN` WHERE NOMBRE = p_Nombre AND IDPLAN <> p_Id)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'Ya existe un plan con ese nombre.'; LEAVE main; 
    UPDATE `PLAN` SET
        NOMBRE        = p_Nombre,
        DESCRIPCION   = p_Descripcion,
        COSTOMENSUAL  = p_CostoMensual,
        ACTIVO        = CASE WHEN p_Estado = 'Activo' THEN 1 ELSE 0 END
    WHERE IDPLAN = p_Id;

    SET p_Resultado = 1; SET p_Mensaje = 'Plan actualizado.';
END;

SELECT 'PLAN.COSTOMENSUAL y usp_plan_* actualizados.';
    SELECT p_Resultado AS Resultado, p_Mensaje AS Mensaje
END$$

DELIMITER ;