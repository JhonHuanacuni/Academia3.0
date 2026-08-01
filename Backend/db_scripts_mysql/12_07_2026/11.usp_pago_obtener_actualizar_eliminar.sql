-- ============================================================================
-- Pagos: obtener, actualizar y eliminar — MySQL 8
-- ============================================================================

USE `AcademiaDB`;

DROP PROCEDURE IF EXISTS usp_pago_obtener;

DELIMITER $$

CREATE PROCEDURE usp_pago_obtener(IN p_Id VARCHAR(50))
main: BEGIN
    SELECT
        p.IDPAGOMEMBRESIA,
        p.IDMEMBRESIA,
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
    FROM PAGOMEMBRESIA p
    INNER JOIN MEMBRESIA m ON m.IDMEMBRESIA = p.IDMEMBRESIA
    INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
    INNER JOIN `PLAN` pl ON pl.IDPLAN = m.IDPLAN
    LEFT JOIN METODO_PAGO mp ON mp.IDMETODOPAGO = p.IDMETODOPAGO
    LEFT JOIN LATERAL (
        SELECT SUM(x.MONTO) AS PAGADO
        FROM PAGOMEMBRESIA x
        WHERE x.IDMEMBRESIA = m.IDMEMBRESIA
    ) pag ON TRUE
    WHERE p.IDPAGOMEMBRESIA = p_Id;
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
    DECLARE v_IdMembresia VARCHAR(50);
    DECLARE v_MontoTotal DECIMAL(10,2) DEFAULT 0;
    DECLARE v_PagadoOtros DECIMAL(10,2) DEFAULT 0;
    DECLARE v_Maximo DECIMAL(10,2) DEFAULT 0;

    IF NOT EXISTS (SELECT 1 FROM PAGOMEMBRESIA WHERE IDPAGOMEMBRESIA = p_Id) THEN
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

    SELECT IDMEMBRESIA INTO v_IdMembresia
    FROM PAGOMEMBRESIA WHERE IDPAGOMEMBRESIA = p_Id;

    SELECT IFNULL(MONTOTOTAL, 0) INTO v_MontoTotal
    FROM MEMBRESIA WHERE IDMEMBRESIA = v_IdMembresia;

    SELECT IFNULL(SUM(MONTO), 0) INTO v_PagadoOtros
    FROM PAGOMEMBRESIA
    WHERE IDMEMBRESIA = v_IdMembresia AND IDPAGOMEMBRESIA <> p_Id;

    SET v_Maximo = v_MontoTotal - v_PagadoOtros;
    IF v_Maximo < 0 THEN SET v_Maximo = 0; END IF;

    IF p_Monto > v_Maximo THEN
        SET p_Resultado = 0;
        SET p_Mensaje = CONCAT('El monto no puede superar S/ ', CAST(v_Maximo AS CHAR(20)), '.');
        LEAVE main;
    END IF;

    UPDATE PAGOMEMBRESIA SET
        MONTO = p_Monto,
        IDMETODOPAGO = p_IdMetodoPago,
        FECHAPAGO = CASE WHEN p_FechaPago IS NOT NULL AND p_FechaPago <> '' THEN p_FechaPago ELSE FECHAPAGO END,
        OBSERVACIONES = p_Observaciones
    WHERE IDPAGOMEMBRESIA = p_Id;

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
    IF NOT EXISTS (SELECT 1 FROM PAGOMEMBRESIA WHERE IDPAGOMEMBRESIA = p_Id) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'El pago no existe.'; LEAVE main;
    END IF;

    DELETE FROM PAGOMEMBRESIA WHERE IDPAGOMEMBRESIA = p_Id;

    SET p_Resultado = 1;
    SET p_Mensaje = 'Pago eliminado.';
END$$

DELIMITER ;

SELECT 'SPs pago obtener / actualizar / eliminar creados.' AS info;
