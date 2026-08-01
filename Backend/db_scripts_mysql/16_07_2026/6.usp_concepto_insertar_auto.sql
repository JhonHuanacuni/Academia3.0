-- ============================================================================
-- Concepto: código autoincremental (CON001, CON002…)
-- NOTA: Si ya corriste 7.concepto_fechas_vigencia.sql, ese script reemplaza insertar.
-- Fecha: 16/07/2026
-- ============================================================================

USE `AcademiaDB`;

DROP PROCEDURE IF EXISTS usp_concepto_insertar;

DELIMITER $$

CREATE PROCEDURE usp_concepto_insertar(
    IN p_Nombre VARCHAR(150),
    IN p_Costo DECIMAL(10,2),
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

    IF EXISTS (SELECT 1 FROM CONCEPTOPAGOEXTRA WHERE NOMBRE = p_Nombre) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ya existe un concepto con ese nombre.';
        LEAVE main;
    END IF;

    SELECT IFNULL(MAX(CAST(REPLACE(IDCONCEPTO, 'CON', '') AS UNSIGNED)), 0) + 1 INTO v_NextNum
    FROM CONCEPTOPAGOEXTRA;
    SET p_IdGenerado = CONCAT('CON', LPAD(CAST(v_NextNum AS CHAR), 3, '0'));

    INSERT INTO CONCEPTOPAGOEXTRA (IDCONCEPTO, NOMBRE, COSTO, ACTIVO)
    VALUES (
        p_IdGenerado,
        p_Nombre,
        p_Costo,
        CASE WHEN p_Estado = 'Activo' THEN 1 ELSE 0 END
    );

    SET p_Resultado = 1; SET p_Mensaje = 'Concepto registrado.';
END$$

DELIMITER ;
