-- ============================================================================
-- Corregir SPs de pagos: MEMBRESIA/PAGOMEMBRESIA → MENSUALIDAD/PAGOMENSUALIDAD
-- Ejecutar después del rename 26_07_2026/4.rename_membresia_asesor_a_mensualidad_tutor.sql
-- Fecha: 04/08/2026
-- ============================================================================

USE `AcademiaDB`;

DROP PROCEDURE IF EXISTS usp_pago_listar;

DELIMITER $$

CREATE PROCEDURE usp_pago_listar(
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
    FROM PAGOMENSUALIDAD p
    INNER JOIN MENSUALIDAD m ON m.IDMENSUALIDAD = p.IDMENSUALIDAD
    INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
    INNER JOIN `PLAN` pl ON pl.IDPLAN = m.IDPLAN
    LEFT JOIN METODO_PAGO mp ON mp.IDMETODOPAGO = p.IDMETODOPAGO
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           p.IDPAGOMENSUALIDAD LIKE CONCAT('%', p_Buscar, '%') OR
           m.IDMENSUALIDAD LIKE CONCAT('%', p_Buscar, '%') OR
           u.DNI LIKE CONCAT('%', p_Buscar, '%') OR
           u.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
           u.APELLIDO LIKE CONCAT('%', p_Buscar, '%') OR
           pl.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
           IFNULL(mp.TITULO, '') LIKE CONCAT('%', p_Buscar, '%'));

    SELECT
        p.IDPAGOMENSUALIDAD,
        p.IDMENSUALIDAD,
        p.MONTO,
        p.FECHAPAGO,
        p.HORAPAGO,
        p.OBSERVACIONES,
        p.IDMETODOPAGO,
        IFNULL(mp.TITULO, '') AS METODOPAGO_TITULO,
        UPPER(TRIM(CONCAT(IFNULL(u.APELLIDO, ''), ' ', IFNULL(u.NOMBRE, '')))) AS ESTUDIANTE_NOMBRE,
        u.DNI AS ESTUDIANTE_DNI,
        pl.NOMBRE AS PLAN_NOMBRE
    FROM PAGOMENSUALIDAD p
    INNER JOIN MENSUALIDAD m ON m.IDMENSUALIDAD = p.IDMENSUALIDAD
    INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
    INNER JOIN `PLAN` pl ON pl.IDPLAN = m.IDPLAN
    LEFT JOIN METODO_PAGO mp ON mp.IDMETODOPAGO = p.IDMETODOPAGO
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           p.IDPAGOMENSUALIDAD LIKE CONCAT('%', p_Buscar, '%') OR
           m.IDMENSUALIDAD LIKE CONCAT('%', p_Buscar, '%') OR
           u.DNI LIKE CONCAT('%', p_Buscar, '%') OR
           u.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
           u.APELLIDO LIKE CONCAT('%', p_Buscar, '%') OR
           pl.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
           IFNULL(mp.TITULO, '') LIKE CONCAT('%', p_Buscar, '%'))
    ORDER BY
        CASE WHEN p_OrdenarPor = 'FECHAPAGO' AND p_Direccion = 'ASC'  THEN p.FECHAPAGO END ASC,
        CASE WHEN p_OrdenarPor = 'FECHAPAGO' AND p_Direccion = 'DESC' THEN p.FECHAPAGO END DESC,
        CASE WHEN p_OrdenarPor = 'MONTO' AND p_Direccion = 'ASC'  THEN p.MONTO END ASC,
        CASE WHEN p_OrdenarPor = 'MONTO' AND p_Direccion = 'DESC' THEN p.MONTO END DESC,
        CASE WHEN p_OrdenarPor = 'ESTUDIANTE_NOMBRE' AND p_Direccion = 'ASC'  THEN u.APELLIDO END ASC,
        CASE WHEN p_OrdenarPor = 'ESTUDIANTE_NOMBRE' AND p_Direccion = 'DESC' THEN u.APELLIDO END DESC,
        CASE WHEN p_OrdenarPor = 'IDPAGOMENSUALIDAD' AND p_Direccion = 'ASC'  THEN p.IDPAGOMENSUALIDAD END ASC,
        CASE WHEN p_OrdenarPor = 'IDPAGOMENSUALIDAD' AND p_Direccion = 'DESC' THEN p.IDPAGOMENSUALIDAD END DESC,
        p.FECHAPAGO DESC, p.HORAPAGO DESC, p.IDPAGOMENSUALIDAD DESC
    LIMIT p_TamanioPagina OFFSET v_offset;
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_pago_insertar_abono;

DELIMITER $$

CREATE PROCEDURE usp_pago_insertar_abono(
    IN p_IdMensualidad VARCHAR(50),
    IN p_Monto DECIMAL(10,2),
    IN p_IdMetodoPago VARCHAR(50),
    IN p_Observaciones LONGTEXT,
    IN p_RegistradoPor VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
    DECLARE v_MontoTotal DECIMAL(10,2) DEFAULT 0;
    DECLARE v_Pagado DECIMAL(10,2) DEFAULT 0;
    DECLARE v_Deuda DECIMAL(10,2) DEFAULT 0;
    DECLARE v_IdPago VARCHAR(50);
    DECLARE v_Next INT DEFAULT 0;

    IF p_IdMensualidad IS NULL OR p_IdMensualidad = '' THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Debe seleccionar una mensualidad.'; LEAVE main;
    END IF;
    IF p_Monto IS NULL OR p_Monto <= 0 THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingrese un monto válido.'; LEAVE main;
    END IF;
    IF p_IdMetodoPago IS NULL OR p_IdMetodoPago = '' THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Indique el método de pago.'; LEAVE main;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = p_IdMensualidad AND ESTADO = 'Activo') THEN
        SET p_Resultado = 0; SET p_Mensaje = 'La mensualidad no existe o está inactiva.'; LEAVE main;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM METODO_PAGO WHERE IDMETODOPAGO = p_IdMetodoPago AND ACTIVO = 1) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'El método de pago no es válido.'; LEAVE main;
    END IF;

    SELECT IFNULL(MONTOTOTAL, 0) INTO v_MontoTotal
    FROM MENSUALIDAD WHERE IDMENSUALIDAD = p_IdMensualidad;

    SELECT IFNULL(SUM(MONTO), 0) INTO v_Pagado
    FROM PAGOMENSUALIDAD WHERE IDMENSUALIDAD = p_IdMensualidad;

    SET v_Deuda = v_MontoTotal - v_Pagado;
    IF v_Deuda < 0 THEN SET v_Deuda = 0; END IF;

    IF v_Deuda <= 0 THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Esta mensualidad no tiene deuda pendiente.'; LEAVE main;
    END IF;
    IF p_Monto > v_Deuda THEN
        SET p_Resultado = 0;
        SET p_Mensaje = CONCAT('El abono no puede superar la deuda (S/ ', CAST(v_Deuda AS CHAR(20)), ').');
        LEAVE main;
    END IF;

    SELECT IFNULL(MAX(CAST(SUBSTRING(IDPAGOMENSUALIDAD, 4, 10) AS UNSIGNED)), 0) + 1 INTO v_Next
    FROM PAGOMENSUALIDAD WHERE IDPAGOMENSUALIDAD LIKE 'PAG%';
    SET v_IdPago = CONCAT('PAG', LPAD(CAST(v_Next AS CHAR), 6, '0'));

    INSERT INTO PAGOMENSUALIDAD (
        IDPAGOMENSUALIDAD, MONTO, FECHAPAGO, HORAPAGO, OBSERVACIONES,
        IDMENSUALIDAD, IDMETODOPAGO, IDUSUARIO
    ) VALUES (
        v_IdPago, p_Monto, fn_fecha_ddmmyyyy(), TIME_FORMAT(NOW(), '%H:%i:%s'),
        IFNULL(NULLIF(p_Observaciones, ''), 'Abono'),
        p_IdMensualidad, p_IdMetodoPago, p_RegistradoPor
    );

    SET p_Resultado = 1;
    SET p_Mensaje = 'Abono registrado correctamente.';
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_pago_obtener;

DELIMITER $$

CREATE PROCEDURE usp_pago_obtener(IN p_Id VARCHAR(50))
main: BEGIN
    SELECT
        p.IDPAGOMENSUALIDAD,
        p.IDMENSUALIDAD,
        p.MONTO,
        p.FECHAPAGO,
        p.HORAPAGO,
        p.OBSERVACIONES,
        p.IDMETODOPAGO,
        IFNULL(mp.TITULO, '') AS METODOPAGO_TITULO,
        m.IDUSUARIO,
        UPPER(TRIM(CONCAT(IFNULL(u.APELLIDO, ''), ' ', IFNULL(u.NOMBRE, '')))) AS ESTUDIANTE_NOMBRE,
        u.DNI AS ESTUDIANTE_DNI,
        pl.NOMBRE AS PLAN_NOMBRE,
        m.MONTOTOTAL,
        IFNULL(pag.PAGADO, 0) AS PAGADO,
        CASE
            WHEN IFNULL(m.MONTOTOTAL, 0) - IFNULL(pag.PAGADO, 0) < 0 THEN 0
            ELSE IFNULL(m.MONTOTOTAL, 0) - IFNULL(pag.PAGADO, 0)
        END AS DEUDA
    FROM PAGOMENSUALIDAD p
    INNER JOIN MENSUALIDAD m ON m.IDMENSUALIDAD = p.IDMENSUALIDAD
    INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
    INNER JOIN `PLAN` pl ON pl.IDPLAN = m.IDPLAN
    LEFT JOIN METODO_PAGO mp ON mp.IDMETODOPAGO = p.IDMETODOPAGO
    LEFT JOIN LATERAL (
        SELECT SUM(x.MONTO) AS PAGADO
        FROM PAGOMENSUALIDAD x
        WHERE x.IDMENSUALIDAD = m.IDMENSUALIDAD
    ) pag ON TRUE
    WHERE p.IDPAGOMENSUALIDAD = p_Id;
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_pago_actualizar;

DELIMITER $$

CREATE PROCEDURE usp_pago_actualizar(
    IN p_Id VARCHAR(50),
    IN p_Monto DECIMAL(10,2),
    IN p_IdMetodoPago VARCHAR(50),
    IN p_FechaPago CHAR(8),
    IN p_Observaciones LONGTEXT,
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
    DECLARE v_IdMensualidad VARCHAR(50);
    DECLARE v_MontoTotal DECIMAL(10,2) DEFAULT 0;
    DECLARE v_PagadoOtros DECIMAL(10,2) DEFAULT 0;
    DECLARE v_Maximo DECIMAL(10,2) DEFAULT 0;

    IF NOT EXISTS (SELECT 1 FROM PAGOMENSUALIDAD WHERE IDPAGOMENSUALIDAD = p_Id) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'El pago no existe.'; LEAVE main;
    END IF;
    IF p_Monto IS NULL OR p_Monto <= 0 THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingrese un monto válido.'; LEAVE main;
    END IF;
    IF p_IdMetodoPago IS NULL OR p_IdMetodoPago = '' THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Indique el método de pago.'; LEAVE main;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM METODO_PAGO WHERE IDMETODOPAGO = p_IdMetodoPago AND ACTIVO = 1) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'El método de pago no es válido.'; LEAVE main;
    END IF;

    SELECT IDMENSUALIDAD INTO v_IdMensualidad
    FROM PAGOMENSUALIDAD WHERE IDPAGOMENSUALIDAD = p_Id;

    SELECT IFNULL(MONTOTOTAL, 0) INTO v_MontoTotal
    FROM MENSUALIDAD WHERE IDMENSUALIDAD = v_IdMensualidad;

    SELECT IFNULL(SUM(MONTO), 0) INTO v_PagadoOtros
    FROM PAGOMENSUALIDAD
    WHERE IDMENSUALIDAD = v_IdMensualidad AND IDPAGOMENSUALIDAD <> p_Id;

    SET v_Maximo = v_MontoTotal - v_PagadoOtros;
    IF v_Maximo < 0 THEN SET v_Maximo = 0; END IF;

    IF p_Monto > v_Maximo THEN
        SET p_Resultado = 0;
        SET p_Mensaje = CONCAT('El monto no puede superar S/ ', CAST(v_Maximo AS CHAR(20)), '.');
        LEAVE main;
    END IF;

    UPDATE PAGOMENSUALIDAD SET
        MONTO = p_Monto,
        IDMETODOPAGO = p_IdMetodoPago,
        FECHAPAGO = CASE WHEN p_FechaPago IS NOT NULL AND p_FechaPago <> '' THEN p_FechaPago ELSE FECHAPAGO END,
        OBSERVACIONES = p_Observaciones
    WHERE IDPAGOMENSUALIDAD = p_Id;

    SET p_Resultado = 1;
    SET p_Mensaje = 'Pago actualizado.';
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_pago_eliminar;

DELIMITER $$

CREATE PROCEDURE usp_pago_eliminar(
    IN p_Id VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
    IF NOT EXISTS (SELECT 1 FROM PAGOMENSUALIDAD WHERE IDPAGOMENSUALIDAD = p_Id) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'El pago no existe.'; LEAVE main;
    END IF;

    DELETE FROM PAGOMENSUALIDAD WHERE IDPAGOMENSUALIDAD = p_Id;

    SET p_Resultado = 1;
    SET p_Mensaje = 'Pago eliminado.';
END$$

DELIMITER ;

SELECT 'SPs de pagos corregidos (MENSUALIDAD/PAGOMENSUALIDAD).' AS info;
