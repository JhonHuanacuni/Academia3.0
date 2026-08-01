-- ============================================================================
-- CRUD CONCEPTOPAGOEXTRA — Mantenedor de conceptos — MySQL 8
-- Prerequisito: 1.concepto_pago_extra_tabla.sql (+ 7 si la tabla ya existía)
-- Fecha: 16/07/2026
-- ============================================================================

USE `AcademiaDB`;

DROP PROCEDURE IF EXISTS usp_concepto_listar;

DELIMITER $$

CREATE PROCEDURE usp_concepto_listar(
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
    FROM CONCEPTOPAGOEXTRA c
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           c.IDCONCEPTO LIKE CONCAT('%', p_Buscar, '%') OR
           c.NOMBRE     LIKE CONCAT('%', p_Buscar, '%'))
      AND (p_Estado IS NULL OR p_Estado = '' OR
           (p_Estado = 'Activo' AND c.ACTIVO = 1) OR
           (p_Estado = 'Inactivo' AND c.ACTIVO = 0));

    SELECT
        c.IDCONCEPTO,
        c.NOMBRE,
        c.COSTO,
        c.FECHAINICIO,
        c.FECHAFIN,
        CASE WHEN c.ACTIVO = 1 THEN 'Activo' ELSE 'Inactivo' END AS ESTADO
    FROM CONCEPTOPAGOEXTRA c
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           c.IDCONCEPTO LIKE CONCAT('%', p_Buscar, '%') OR
           c.NOMBRE     LIKE CONCAT('%', p_Buscar, '%'))
      AND (p_Estado IS NULL OR p_Estado = '' OR
           (p_Estado = 'Activo' AND c.ACTIVO = 1) OR
           (p_Estado = 'Inactivo' AND c.ACTIVO = 0))
    ORDER BY
        CASE WHEN p_OrdenarPor = 'IDCONCEPTO' AND p_Direccion = 'ASC'  THEN c.IDCONCEPTO END ASC,
        CASE WHEN p_OrdenarPor = 'IDCONCEPTO' AND p_Direccion = 'DESC' THEN c.IDCONCEPTO END DESC,
        CASE WHEN p_OrdenarPor = 'NOMBRE'     AND p_Direccion = 'ASC'  THEN c.NOMBRE END ASC,
        CASE WHEN p_OrdenarPor = 'NOMBRE'     AND p_Direccion = 'DESC' THEN c.NOMBRE END DESC,
        CASE WHEN p_OrdenarPor = 'COSTO'      AND p_Direccion = 'ASC'  THEN c.COSTO END ASC,
        CASE WHEN p_OrdenarPor = 'COSTO'      AND p_Direccion = 'DESC' THEN c.COSTO END DESC,
        CASE WHEN p_OrdenarPor = 'FECHAINICIO' AND p_Direccion = 'ASC' THEN c.FECHAINICIO END ASC,
        CASE WHEN p_OrdenarPor = 'FECHAINICIO' AND p_Direccion = 'DESC' THEN c.FECHAINICIO END DESC,
        CASE WHEN p_OrdenarPor = 'FECHAFIN' AND p_Direccion = 'ASC' THEN c.FECHAFIN END ASC,
        CASE WHEN p_OrdenarPor = 'FECHAFIN' AND p_Direccion = 'DESC' THEN c.FECHAFIN END DESC,
        CASE WHEN p_OrdenarPor = 'ESTADO'     AND p_Direccion = 'ASC'  THEN c.ACTIVO END ASC,
        CASE WHEN p_OrdenarPor = 'ESTADO'     AND p_Direccion = 'DESC' THEN c.ACTIVO END DESC,
        c.NOMBRE
    LIMIT p_TamanioPagina OFFSET v_offset;
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_concepto_obtener;

DELIMITER $$

CREATE PROCEDURE usp_concepto_obtener(IN p_Id VARCHAR(50))
main: BEGIN
    SELECT
        c.IDCONCEPTO,
        c.NOMBRE,
        c.COSTO,
        c.FECHAINICIO,
        c.FECHAFIN,
        CASE WHEN c.ACTIVO = 1 THEN 'Activo' ELSE 'Inactivo' END AS ESTADO
    FROM CONCEPTOPAGOEXTRA c
    WHERE c.IDCONCEPTO = p_Id;
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_concepto_insertar;

DELIMITER $$

CREATE PROCEDURE usp_concepto_insertar(
    IN p_Nombre VARCHAR(150),
    IN p_Costo DECIMAL(10,2),
    IN p_FechaInicio CHAR(8),
    IN p_FechaFin CHAR(8),
    IN p_Estado VARCHAR(50),
    OUT p_IdGenerado VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
    DECLARE v_NextNum INT DEFAULT 0;

    SET p_IdGenerado = NULL;

    IF p_Nombre IS NULL OR TRIM(p_Nombre) = '' THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa el nombre del concepto.';
        LEAVE main;
    END IF;

    IF p_Costo IS NULL OR p_Costo < 0 THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa un costo válido.';
        LEAVE main;
    END IF;

    IF p_FechaInicio IS NULL OR CHAR_LENGTH(p_FechaInicio) <> 8 THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa la fecha de inicio.';
        LEAVE main;
    END IF;

    IF p_FechaFin IS NULL OR CHAR_LENGTH(p_FechaFin) <> 8 THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa la fecha final.';
        LEAVE main;
    END IF;

    IF EXISTS (SELECT 1 FROM CONCEPTOPAGOEXTRA WHERE NOMBRE = p_Nombre) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ya existe un concepto con ese nombre.';
        LEAVE main;
    END IF;

    SELECT IFNULL(MAX(CAST(REPLACE(IDCONCEPTO, 'CON', '') AS UNSIGNED)), 0) + 1 INTO v_NextNum
    FROM CONCEPTOPAGOEXTRA;
    SET p_IdGenerado = CONCAT('CON', LPAD(CAST(v_NextNum AS CHAR), 3, '0'));

    INSERT INTO CONCEPTOPAGOEXTRA (IDCONCEPTO, NOMBRE, COSTO, FECHAINICIO, FECHAFIN, ACTIVO)
    VALUES (
        p_IdGenerado,
        p_Nombre,
        p_Costo,
        p_FechaInicio,
        p_FechaFin,
        CASE WHEN p_Estado = 'Activo' THEN 1 ELSE 0 END
    );

    SET p_Resultado = 1; SET p_Mensaje = 'Concepto registrado.';
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_concepto_actualizar;

DELIMITER $$

CREATE PROCEDURE usp_concepto_actualizar(
    IN p_Id VARCHAR(50),
    IN p_Nombre VARCHAR(150),
    IN p_Costo DECIMAL(10,2),
    IN p_FechaInicio CHAR(8),
    IN p_FechaFin CHAR(8),
    IN p_Estado VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
    IF NOT EXISTS (SELECT 1 FROM CONCEPTOPAGOEXTRA WHERE IDCONCEPTO = p_Id) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'El concepto no existe.';
        LEAVE main;
    END IF;

    IF p_Nombre IS NULL OR TRIM(p_Nombre) = '' THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa el nombre del concepto.';
        LEAVE main;
    END IF;

    IF p_Costo IS NULL OR p_Costo < 0 THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa un costo válido.';
        LEAVE main;
    END IF;

    IF p_FechaInicio IS NULL OR CHAR_LENGTH(p_FechaInicio) <> 8 THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa la fecha de inicio.';
        LEAVE main;
    END IF;

    IF p_FechaFin IS NULL OR CHAR_LENGTH(p_FechaFin) <> 8 THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa la fecha final.';
        LEAVE main;
    END IF;

    IF EXISTS (SELECT 1 FROM CONCEPTOPAGOEXTRA WHERE NOMBRE = p_Nombre AND IDCONCEPTO <> p_Id) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ya existe un concepto con ese nombre.';
        LEAVE main;
    END IF;

    UPDATE CONCEPTOPAGOEXTRA SET
        NOMBRE = p_Nombre,
        COSTO = p_Costo,
        FECHAINICIO = p_FechaInicio,
        FECHAFIN = p_FechaFin,
        ACTIVO = CASE WHEN p_Estado = 'Activo' THEN 1 ELSE 0 END
    WHERE IDCONCEPTO = p_Id;

    SET p_Resultado = 1; SET p_Mensaje = 'Concepto actualizado.';
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_concepto_eliminar;

DELIMITER $$

CREATE PROCEDURE usp_concepto_eliminar(
    IN p_Id VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
    IF NOT EXISTS (SELECT 1 FROM CONCEPTOPAGOEXTRA WHERE IDCONCEPTO = p_Id) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'El concepto no existe.';
        LEAVE main;
    END IF;

    IF EXISTS (
        SELECT 1 FROM information_schema.TABLES
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'PAGOEXTRAORDINARIO'
    ) AND EXISTS (SELECT 1 FROM PAGOEXTRAORDINARIO WHERE IDCONCEPTO = p_Id) THEN
        SET p_Resultado = 0;
        SET p_Mensaje = 'No se puede eliminar: el concepto tiene pagos asociados.';
        LEAVE main;
    END IF;

    DELETE FROM CONCEPTOPAGOEXTRA WHERE IDCONCEPTO = p_Id;

    SET p_Resultado = 1; SET p_Mensaje = 'Concepto eliminado.';
END$$

DELIMITER ;
