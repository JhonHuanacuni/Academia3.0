-- Convertido automáticamente desde db_scripts/16_07_2026/6.usp_concepto_insertar_auto.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   Concepto: código autoincremental (CON001, CON002...)
   NOTA: Si vas a ejecutar 7.concepto_fechas_vigencia.sql, ese script ya incluye
   el insertar actualizado con fechas. Este 6 solo aplica si aún no corriste el 7.
   Fecha: 16/07/2026
   ============================================================================ */

DROP PROCEDURE IF EXISTS usp_concepto_insertar;

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
    
    DECLARE v_NextNum INT;
    SELECT IFNULL(MAX(CAST(REPLACE(IDCONCEPTO, 'CON', '') AS INT)), 0) + 1 INTO v_NextNum
    FROM CONCEPTOPAGOEXTRA;
    SET p_IdGenerado = CONCAT('CON', RIGHT(CONCAT('000', CAST(v_NextNum AS VARCHAR(3))), 3);

    INSERT INTO CONCEPTOPAGOEXTRA (IDCONCEPTO, NOMBRE, COSTO, ACTIVO)
    VALUES (
        p_IdGenerado,
        p_Nombre,
        p_Costo,
        CASE WHEN p_Estado = 'Activo' THEN 1 ELSE 0 END);

    SET p_Resultado = 1; SET p_Mensaje = 'Concepto registrado.';
END;

SELECT 'usp_concepto_insertar: código autoincremental (obsoleto si ya corriste el script 7).';
    SELECT p_IdGenerado AS IdGenerado, p_Resultado AS Resultado, p_Mensaje AS Mensaje
END$$

DELIMITER ;