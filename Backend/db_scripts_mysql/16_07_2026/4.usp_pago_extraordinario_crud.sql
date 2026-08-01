-- Convertido automáticamente desde db_scripts/16_07_2026/4.usp_pago_extraordinario_crud.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   CRUD PAGOEXTRAORDINARIO
   Prerequisito: 3.pago_extraordinario_tabla.sql
   Fecha: 16/07/2026
   ============================================================================ */

DROP PROCEDURE IF EXISTS usp_pagoextra_listar;

DROP PROCEDURE IF EXISTS usp_pagoextra_listar;

DELIMITER $$

CREATE PROCEDURE usp_pagoextra_listar(
    IN p_Buscar VARCHAR(200),
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
    FROM PAGOEXTRAORDINARIO p
    INNER JOIN USUARIO u ON u.IDUSUARIO = p.IDUSUARIO
    INNER JOIN CONCEPTOPAGOEXTRA c ON c.IDCONCEPTO = p.IDCONCEPTO
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           p.IDPAGOEXTRA LIKE CONCAT('%', p_Buscar, '%') OR
           u.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
           u.APELLIDO LIKE CONCAT('%', p_Buscar, '%') OR
           u.DNI LIKE CONCAT('%', p_Buscar, '%') OR
           c.NOMBRE LIKE CONCAT('%', p_Buscar, '%'));

    SELECT
        p.IDPAGOEXTRA,
        p.IDUSUARIO,
        UPPER(TRIM(CONCAT(IFNULL(u.APELLIDO, ''), ' ') + IFNULL(u.NOMBRE, '')))) AS ESTUDIANTE_NOMBRE,
        u.DNI AS ESTUDIANTE_DNI,
        p.IDCONCEPTO,
        c.NOMBRE AS CONCEPTO_NOMBRE,
        p.MONTO,
        p.FECHAPAGO,
        p.FECHAINICIO,
        p.FECHAFIN,
        p.OBSERVACIONES
    FROM PAGOEXTRAORDINARIO p
    INNER JOIN USUARIO u ON u.IDUSUARIO = p.IDUSUARIO
    INNER JOIN CONCEPTOPAGOEXTRA c ON c.IDCONCEPTO = p.IDCONCEPTO
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           p.IDPAGOEXTRA LIKE CONCAT('%', p_Buscar, '%') OR
           u.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
           u.APELLIDO LIKE CONCAT('%', p_Buscar, '%') OR
           u.DNI LIKE CONCAT('%', p_Buscar, '%') OR
           c.NOMBRE LIKE CONCAT('%', p_Buscar, '%'))
    ORDER BY
        CASE WHEN p_OrdenarPor = 'FECHAPAGO' AND p_Direccion = 'ASC'  THEN p.FECHAPAGO END ASC,
        CASE WHEN p_OrdenarPor = 'FECHAPAGO' AND p_Direccion = 'DESC' THEN p.FECHAPAGO END DESC,
        CASE WHEN p_OrdenarPor = 'MONTO' AND p_Direccion = 'ASC' THEN p.MONTO END ASC,
        CASE WHEN p_OrdenarPor = 'MONTO' AND p_Direccion = 'DESC' THEN p.MONTO END DESC,
        CASE WHEN p_OrdenarPor = 'ESTUDIANTE_NOMBRE' AND p_Direccion = 'ASC' THEN u.APELLIDO END ASC,
        CASE WHEN p_OrdenarPor = 'ESTUDIANTE_NOMBRE' AND p_Direccion = 'DESC' THEN u.APELLIDO END DESC,
        CASE WHEN p_OrdenarPor = 'CONCEPTO_NOMBRE' AND p_Direccion = 'ASC' THEN c.NOMBRE END ASC,
        CASE WHEN p_OrdenarPor = 'CONCEPTO_NOMBRE' AND p_Direccion = 'DESC' THEN c.NOMBRE END DESC,
        p.FECHAPAGO DESC, p.IDPAGOEXTRA DESC
    LIMIT p_TamanioPagina OFFSET v_offset;
    SELECT p_TotalRegistros AS TotalRegistros
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_pagoextra_obtener;

DROP PROCEDURE IF EXISTS usp_pagoextra_obtener;

DELIMITER $$

CREATE PROCEDURE usp_pagoextra_obtener(
    IN p_Id VARCHAR(50)
)
main: BEGIN
SELECT
        p.IDPAGOEXTRA,
        p.IDUSUARIO,
        UPPER(TRIM(CONCAT(IFNULL(u.APELLIDO, ''), ' ') + IFNULL(u.NOMBRE, '')))) AS ESTUDIANTE_NOMBRE,
        u.DNI AS ESTUDIANTE_DNI,
        p.IDCONCEPTO,
        c.NOMBRE AS CONCEPTO_NOMBRE,
        c.COSTO AS CONCEPTO_COSTO,
        p.MONTO,
        p.FECHAPAGO,
        p.FECHAINICIO,
        p.FECHAFIN,
        p.OBSERVACIONES
    FROM PAGOEXTRAORDINARIO p
    INNER JOIN USUARIO u ON u.IDUSUARIO = p.IDUSUARIO
    INNER JOIN CONCEPTOPAGOEXTRA c ON c.IDCONCEPTO = p.IDCONCEPTO
    WHERE p.IDPAGOEXTRA = p_Id;
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
    
    END IF;

    IF p_FechaInicio IS NULL OR LEN(p_FechaInicio) <> 8
       OR p_FechaFin IS NULL OR LEN(p_FechaFin) <> 8
    BEGIN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa las fechas de inicio y fin.';
        LEAVE main;
    
    UPDATE PAGOEXTRAORDINARIO SET
        IDCONCEPTO = p_IdConcepto,
        MONTO = p_Monto,
        FECHAPAGO = p_FechaPago,
        FECHAINICIO = p_FechaInicio,
        FECHAFIN = p_FechaFin,
        OBSERVACIONES = p_Observaciones
    WHERE IDPAGOEXTRA = p_Id;

    SET p_Resultado = 1; SET p_Mensaje = 'Pago extraordinario actualizado.';
    SELECT p_Resultado AS Resultado, p_Mensaje AS Mensaje
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_pagoextra_eliminar;

DROP PROCEDURE IF EXISTS usp_pagoextra_eliminar;

DELIMITER $$

CREATE PROCEDURE usp_pagoextra_eliminar(
    IN p_Id VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
IF NOT EXISTS (SELECT 1 FROM PAGOEXTRAORDINARIO WHERE IDPAGOEXTRA = p_Id) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'El pago no existe.';
        LEAVE main;
    
    DELETE FROM PAGOEXTRAORDINARIO WHERE IDPAGOEXTRA = p_Id;

    SET p_Resultado = 1; SET p_Mensaje = 'Pago extraordinario eliminado.';
END;

SELECT 'SPs usp_pagoextra_* creados.';
    SELECT p_Resultado AS Resultado, p_Mensaje AS Mensaje
END$$

DELIMITER ;