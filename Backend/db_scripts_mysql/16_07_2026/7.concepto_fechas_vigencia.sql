-- Convertido automáticamente desde db_scripts/16_07_2026/7.concepto_fechas_vigencia.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   CONCEPTOPAGOEXTRA — fechas de vigencia (inicio / fin)
   + actualizar SPs y catálogo filtrado
   Fecha: 16/07/2026
   ============================================================================ */

SET @col_CONCEPTOPAGOEXTRA_FECHAINICIO := (
    SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'CONCEPTOPAGOEXTRA' AND COLUMN_NAME = 'FECHAINICIO'
);
SET @sql_CONCEPTOPAGOEXTRA_FECHAINICIO := IF(@col_CONCEPTOPAGOEXTRA_FECHAINICIO = 0, 'ALTER TABLE CONCEPTOPAGOEXTRA ADD FECHAINICIO CHAR(8) NULL;

SET @col_CONCEPTOPAGOEXTRA_FECHAFIN := (
    SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'CONCEPTOPAGOEXTRA' AND COLUMN_NAME = 'FECHAFIN'
);
SET @sql_CONCEPTOPAGOEXTRA_FECHAFIN := IF(@col_CONCEPTOPAGOEXTRA_FECHAFIN = 0, 'ALTER TABLE CONCEPTOPAGOEXTRA ADD FECHAFIN CHAR(8) NULL;

DROP PROCEDURE IF EXISTS usp_concepto_listar;

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
IF p_Pagina < 1 THEN SET p_Pagina = 1; END IF;
    IF p_TamanioPagina < 1 THEN SET p_TamanioPagina = 10; END IF'', ''SELECT 1'');
PREPARE stmt FROM @sql_CONCEPTOPAGOEXTRA_FECHAINICIO; EXECUTE stmt; DEALLOCATE PREPARE stmt', 'SELECT 1');
PREPARE stmt FROM @sql_CONCEPTOPAGOEXTRA_FECHAFIN; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SELECT p_TotalRegistros AS TotalRegistros
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_concepto_obtener;

DROP PROCEDURE IF EXISTS usp_concepto_obtener;

DELIMITER $$

CREATE PROCEDURE usp_concepto_obtener(
    IN p_Id VARCHAR(50)
)
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
SET p_IdGenerado = NULL;

    IF p_Nombre IS NULL OR TRIM(p_Nombre) = '' THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa el nombre del concepto.';
        LEAVE main;
    
    END IF;

    IF p_Costo IS NULL OR p_Costo < 0 THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa un costo válido.';
        LEAVE main;
    
    END IF;

    IF p_FechaInicio IS NULL OR LEN(p_FechaInicio) <> 8 THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa la fecha de inicio.';
        LEAVE main;
    
    END IF;

    IF p_FechaFin IS NULL OR LEN(p_FechaFin) <> 8 THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa la fecha final.';
        LEAVE main;
    
    END IF;

    IF EXISTS (SELECT 1 FROM CONCEPTOPAGOEXTRA WHERE NOMBRE = p_Nombre) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ya existe un concepto con ese nombre.';
        LEAVE main;
    
    DECLARE v_NextNum INT;
    SELECT IFNULL(MAX(CAST(REPLACE(IDCONCEPTO, 'CON', '') AS INT)), 0) + 1 INTO v_NextNum
    FROM CONCEPTOPAGOEXTRA;
    SET p_IdGenerado = CONCAT('CON', RIGHT(CONCAT('000', CAST(v_NextNum AS VARCHAR(3))), 3);

    INSERT INTO CONCEPTOPAGOEXTRA (IDCONCEPTO, NOMBRE, COSTO, FECHAINICIO, FECHAFIN, ACTIVO)
    VALUES (
        p_IdGenerado,
        p_Nombre,
        p_Costo,
        p_FechaInicio,
        p_FechaFin,
        CASE WHEN p_Estado = 'Activo' THEN 1 ELSE 0 END);

    SET p_Resultado = 1; SET p_Mensaje = 'Concepto registrado.';
    SELECT p_IdGenerado AS IdGenerado, p_Resultado AS Resultado, p_Mensaje AS Mensaje
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_concepto_actualizar;

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

    IF p_FechaInicio IS NULL OR LEN(p_FechaInicio) <> 8 THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa la fecha de inicio.';
        LEAVE main;
    
    END IF;

    IF p_FechaFin IS NULL OR LEN(p_FechaFin) <> 8 THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa la fecha final.';
        LEAVE main;
    
    END IF;

    IF EXISTS (SELECT 1 FROM CONCEPTOPAGOEXTRA WHERE NOMBRE = p_Nombre AND IDCONCEPTO <> p_Id) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ya existe un concepto con ese nombre.';
        LEAVE main;
    
    UPDATE CONCEPTOPAGOEXTRA SET
        NOMBRE = p_Nombre,
        COSTO = p_Costo,
        FECHAINICIO = p_FechaInicio,
        FECHAFIN = p_FechaFin,
        ACTIVO = CASE WHEN p_Estado = 'Activo' THEN 1 ELSE 0 END
    WHERE IDCONCEPTO = p_Id;

    SET p_Resultado = 1; SET p_Mensaje = 'Concepto actualizado.';
END;

SELECT 'Concepto: fechas de CONCAT(vigencia, SPs) actualizados.';

-- Asegura validación de vigencia al registrar pago extraordinario
    SELECT p_Resultado AS Resultado, p_Mensaje AS Mensaje
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_pagoextra_insertar;

DROP PROCEDURE IF EXISTS usp_pagoextra_insertar;

DELIMITER $$

CREATE PROCEDURE usp_pagoextra_insertar(
    IN p_IdUsuario VARCHAR(50),
    IN p_IdConcepto VARCHAR(50),
    IN p_Monto DECIMAL(10,2),
    IN p_FechaPago CHAR(8),
    IN p_FechaInicio CHAR(8),
    IN p_FechaFin CHAR(8),
    IN p_Observaciones LONGTEXT,
    IN p_IdRegistrador VARCHAR(50),
    OUT p_IdGenerado VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
SET p_IdGenerado = NULL;

    IF p_IdUsuario IS NULL OR TRIM(p_IdUsuario) = '' THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Selecciona un estudiante.';
        LEAVE main;
    
    END IF;

    IF NOT EXISTS (SELECT 1 FROM USUARIO WHERE IDUSUARIO = p_IdUsuario) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'El estudiante no existe.';
        LEAVE main;
    
    END IF;

    IF p_IdConcepto IS NULL OR TRIM(p_IdConcepto) = '' THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Selecciona un concepto.';
        LEAVE main;
    
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM CONCEPTOPAGOEXTRA
        WHERE IDCONCEPTO = p_IdConcepto
          AND ACTIVO = 1
          AND FECHAINICIO IS NOT NULL AND LEN(FECHAINICIO) = 8
          AND FECHAFIN IS NOT NULL AND LEN(FECHAFIN) = 8
          AND CAST(NOW() AS DATE) >= CONCAT(CONVERT(DATE,
                SUBSTRING(FECHAINICIO, 5, 4), SUBSTRING(FECHAINICIO, 3, 2)) + SUBSTRING(FECHAINICIO, 1, 2), 112)
          AND CAST(NOW() AS DATE) <= CONCAT(CONVERT(DATE,
                SUBSTRING(FECHAFIN, 5, 4), SUBSTRING(FECHAFIN, 3, 2)) + SUBSTRING(FECHAFIN, 1, 2), 112)
    )
    BEGIN
        SET p_Resultado = 0; SET p_Mensaje = 'El concepto no está activo o no está vigente en la fecha actual.';
        LEAVE main;
    
    END IF;

    IF p_Monto IS NULL OR p_Monto <= 0 THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa un monto válido.';
        LEAVE main;
    
    END IF;

    IF p_FechaPago IS NULL OR LEN(p_FechaPago) <> 8 THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa la fecha del pago.';
        LEAVE main;
    
    END IF;

    IF p_FechaInicio IS NULL OR LEN(p_FechaInicio) <> 8 THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa la fecha de inicio.';
        LEAVE main;
    
    END IF;

    IF p_FechaFin IS NULL OR LEN(p_FechaFin) <> 8 THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa la fecha final.';
        LEAVE main;
    
    DECLARE v_NextNum INT;
    SELECT IFNULL(MAX(CAST(REPLACE(IDPAGOEXTRA, 'PEX', '') AS INT)), 0) + 1 INTO v_NextNum
    FROM PAGOEXTRAORDINARIO;
    SET p_IdGenerado = CONCAT('PEX', RIGHT(CONCAT('00000', CAST(v_NextNum AS VARCHAR(5))), 5);

    INSERT INTO PAGOEXTRAORDINARIO (
        IDPAGOEXTRA, IDUSUARIO, IDCONCEPTO, MONTO,
        FECHAPAGO, FECHAINICIO, FECHAFIN, OBSERVACIONES, IDREGISTRADOR
    )
    VALUES (
        p_IdGenerado, p_IdUsuario, p_IdConcepto, p_Monto,
        p_FechaPago, p_FechaInicio, p_FechaFin, p_Observaciones, p_IdRegistrador
    );

    SET p_Resultado = 1; SET p_Mensaje = 'Pago extraordinario registrado.';
END;

SELECT 'usp_pagoextra_insertar: valida concepto activo y vigente.';
    SELECT p_IdGenerado AS IdGenerado, p_Resultado AS Resultado, p_Mensaje AS Mensaje
END$$

DELIMITER ;