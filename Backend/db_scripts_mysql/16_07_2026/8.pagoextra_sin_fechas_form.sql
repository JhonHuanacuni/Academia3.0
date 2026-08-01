-- Convertido automáticamente desde db_scripts/16_07_2026/8.pagoextra_sin_fechas_form.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   Pago extraordinario: fechas inicio/fin salen del concepto (no del formulario)
   Ejecutar después de 7.concepto_fechas_vigencia.sql
   Fecha: 16/07/2026
   ============================================================================ */

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
    
    -- Vigencia del pago = vigencia del concepto
    SELECT FECHAINICIO, p_FechaFin = FECHAFIN INTO p_FechaInicio
    FROM CONCEPTOPAGOEXTRA
    WHERE IDCONCEPTO = p_IdConcepto;

    IF p_Monto IS NULL OR p_Monto <= 0 THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa un monto válido.';
        LEAVE main;
    
    END IF;

    IF p_FechaPago IS NULL OR LEN(p_FechaPago) <> 8 THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa la fecha del pago.';
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
    SELECT p_IdGenerado AS IdGenerado, p_Resultado AS Resultado, p_Mensaje AS Mensaje
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_pagoextra_actualizar;

DROP PROCEDURE IF EXISTS usp_pagoextra_actualizar;

DELIMITER $$

CREATE PROCEDURE usp_pagoextra_actualizar(
    IN p_Id VARCHAR(50),
    IN p_IdConcepto VARCHAR(50),
    IN p_Monto DECIMAL(10,2),
    IN p_FechaPago CHAR(8),
    IN p_FechaInicio CHAR(8),
    IN p_FechaFin CHAR(8),
    IN p_Observaciones LONGTEXT,
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
IF NOT EXISTS (SELECT 1 FROM PAGOEXTRAORDINARIO WHERE IDPAGOEXTRA = p_Id) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'El pago no existe.';
        LEAVE main;
    
    END IF;

    IF p_IdConcepto IS NULL OR TRIM(p_IdConcepto) = '' THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Selecciona un concepto.';
        LEAVE main;
    
    END IF;

    IF NOT EXISTS (SELECT 1 FROM CONCEPTOPAGOEXTRA WHERE IDCONCEPTO = p_IdConcepto) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'El concepto no existe.';
        LEAVE main;
    
    END IF;

    IF p_Monto IS NULL OR p_Monto <= 0 THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa un monto válido.';
        LEAVE main;
    
    END IF;

    IF p_FechaPago IS NULL OR LEN(p_FechaPago) <> 8 THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa la fecha del pago.';
        LEAVE main;
    
    SELECT FECHAINICIO, p_FechaFin = FECHAFIN INTO p_FechaInicio
    FROM CONCEPTOPAGOEXTRA
    WHERE IDCONCEPTO = p_IdConcepto;

    UPDATE PAGOEXTRAORDINARIO SET
        IDCONCEPTO = p_IdConcepto,
        MONTO = p_Monto,
        FECHAPAGO = p_FechaPago,
        FECHAINICIO = p_FechaInicio,
        FECHAFIN = p_FechaFin,
        OBSERVACIONES = p_Observaciones
    WHERE IDPAGOEXTRA = p_Id;

    SET p_Resultado = 1; SET p_Mensaje = 'Pago extraordinario actualizado.';
END;

SELECT 'Pago extraordinario: fechas tomadas del concepto.';
    SELECT p_Resultado AS Resultado, p_Mensaje AS Mensaje
END$$

DELIMITER ;