-- ============================================================================
-- Corrige usp_concepto_insertar (script 6 lo reemplazó por versión sin fechas).
-- Fecha: 04/08/2026
-- ============================================================================

USE `AcademiaDB`;

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

SELECT 'usp_concepto_insertar corregido (fechas de vigencia).' AS info;
