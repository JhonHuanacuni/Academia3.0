-- Convertido automáticamente desde db_scripts/12_07_2026/8.usp_pago_crud.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   Pagos: listar, abonar membresía, últimas 3 membresías con deuda
   Ejecutar después de 6.usp_membresia_estado_registro.sql
   Fecha: 12/07/2026
   ============================================================================ */

DROP PROCEDURE IF EXISTS usp_pago_listar;

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
    FROM PAGOMEMBRESIA p
    INNER JOIN MEMBRESIA m ON m.IDMEMBRESIA = p.IDMEMBRESIA
    INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
    INNER JOIN `PLAN` pl ON pl.IDPLAN = m.IDPLAN
    LEFT JOIN METODO_PAGO mp ON mp.IDMETODOPAGO = p.IDMETODOPAGO
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           p.IDPAGOMEMBRESIA LIKE CONCAT('%', p_Buscar, '%') OR
           m.IDMEMBRESIA LIKE CONCAT('%', p_Buscar, '%') OR
           u.DNI LIKE CONCAT('%', p_Buscar, '%') OR
           u.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
           u.APELLIDO LIKE CONCAT('%', p_Buscar, '%') OR
           pl.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
           IFNULL(mp.TITULO, '') LIKE CONCAT('%', p_Buscar, '%'));

    SELECT
        p.IDPAGOMEMBRESIA,
        p.IDMEMBRESIA,
        p.MONTO,
        p.FECHAPAGO,
        p.HORAPAGO,
        p.OBSERVACIONES,
        p.IDMETODOPAGO,
        IFNULL(mp.TITULO, '') AS METODOPAGO_TITULO,
        UPPER(TRIM(CONCAT(IFNULL(u.APELLIDO, ''), ' ') + IFNULL(u.NOMBRE, '')))) AS ESTUDIANTE_NOMBRE,
        u.DNI AS ESTUDIANTE_DNI,
        pl.NOMBRE AS PLAN_NOMBRE
    FROM PAGOMEMBRESIA p
    INNER JOIN MEMBRESIA m ON m.IDMEMBRESIA = p.IDMEMBRESIA
    INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
    INNER JOIN `PLAN` pl ON pl.IDPLAN = m.IDPLAN
    LEFT JOIN METODO_PAGO mp ON mp.IDMETODOPAGO = p.IDMETODOPAGO
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           p.IDPAGOMEMBRESIA LIKE CONCAT('%', p_Buscar, '%') OR
           m.IDMEMBRESIA LIKE CONCAT('%', p_Buscar, '%') OR
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
        CASE WHEN p_OrdenarPor = 'IDPAGOMEMBRESIA' AND p_Direccion = 'ASC'  THEN p.IDPAGOMEMBRESIA END ASC,
        CASE WHEN p_OrdenarPor = 'IDPAGOMEMBRESIA' AND p_Direccion = 'DESC' THEN p.IDPAGOMEMBRESIA END DESC,
        p.FECHAPAGO DESC, p.HORAPAGO DESC, p.IDPAGOMEMBRESIA DESC
    LIMIT p_TamanioPagina OFFSET v_offset;
    SELECT p_TotalRegistros AS TotalRegistros
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_pago_membresias_estudiante;

DROP PROCEDURE IF EXISTS usp_pago_membresias_estudiante;

DELIMITER $$

CREATE PROCEDURE usp_pago_membresias_estudiante(
    IN p_IdUsuario VARCHAR(50)
)
main: BEGIN
SELECT TOP 3
        m.IDMEMBRESIA,
        m.IDPLAN,
        pl.NOMBRE AS PLAN_NOMBRE,
        m.FECHAINICIO,
        m.FECHAFIN,
        m.MONTOTOTAL,
        IFNULL(pag.PAGADO, 0) AS PAGADO,
        CASE
            WHEN IFNULL(m.MONTOTOTAL, 0) - IFNULL(pag.PAGADO, 0) < 0 THEN 0
            ELSE IFNULL(m.MONTOTOTAL, 0) - IFNULL(pag.PAGADO, 0)
        END AS DEUDA,
        m.ESTADOMIEMBRO,
        CASE m.ESTADOMIEMBRO
            WHEN 2 THEN 'Activo'
            WHEN 3 THEN 'Vencido'
            ELSE 'Activo'
        END AS ESTADOMIEMBRO_DESCRIPCION,
        m.ESTADO,
        m.FECHAREGISTRO
    FROM MEMBRESIA m
    INNER JOIN `PLAN` pl ON pl.IDPLAN = m.IDPLAN
    OUTER APPLY (
        SELECT SUM(p.MONTO) AS PAGADO
        FROM PAGOMEMBRESIA p
        WHERE p.IDMEMBRESIA = m.IDMEMBRESIA
    ) pag
    WHERE m.IDUSUARIO = p_IdUsuario
      AND m.ESTADO = 'Activo'
    ORDER BY m.FECHAREGISTRO DESC, m.IDMEMBRESIA DESC;
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_pago_insertar_abono;

DROP PROCEDURE IF EXISTS usp_pago_insertar_abono;

DELIMITER $$

CREATE PROCEDURE usp_pago_insertar_abono(
    IN p_IdMembresia VARCHAR(50),
    IN p_Monto DECIMAL(10,2),
    IN p_IdMetodoPago VARCHAR(50),
    IN p_Observaciones LONGTEXT,
    IN p_RegistradoPor VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
IF p_IdMembresia IS NULL OR p_IdMembresia = ''
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'Debe seleccionar una membresía.'; LEAVE main; 
    END IF;

    IF p_Monto IS NULL OR p_Monto <= 0
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'Ingrese un monto válido.'; LEAVE main; 
    END IF;

    IF p_IdMetodoPago IS NULL OR p_IdMetodoPago = ''
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'Indique el método de pago.'; LEAVE main; 
    END IF;

    IF NOT EXISTS (SELECT 1 FROM MEMBRESIA WHERE IDMEMBRESIA = p_IdMembresia AND ESTADO = 'Activo')
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'La membresía no existe o está inactiva.'; LEAVE main; 
    END IF;

    IF NOT EXISTS (SELECT 1 FROM METODO_PAGO WHERE IDMETODOPAGO = p_IdMetodoPago AND ACTIVO = 1)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'El método de pago no es válido.'; LEAVE main; 
    DECLARE v_MontoTotal DECIMAL(10,2);
    DECLARE v_Pagado DECIMAL(10,2);
    DECLARE v_Deuda DECIMAL(10,2);

    SELECT IFNULL(MONTOTOTAL, 0) FROM MEMBRESIA WHERE IDMEMBRESIA = p_IdMembresia INTO v_MontoTotal;
    SELECT IFNULL(SUM(MONTO), 0) FROM PAGOMEMBRESIA WHERE IDMEMBRESIA = p_IdMembresia INTO v_Pagado;
    SET v_Deuda = v_MontoTotal - v_Pagado;
    IF v_Deuda < 0 THEN SET v_Deuda = 0; END IF;

    IF v_Deuda <= 0
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'Esta membresía no tiene deuda pendiente.'; LEAVE main; 
    END IF;

    IF p_Monto > v_Deuda
    BEGIN SET p_Resultado = 0; SET p_Mensaje = CONCAT('El abono no puede superar la deuda (S/ ', CAST(v_Deuda AS VARCHAR(20))) + ').'; LEAVE main; 
    DECLARE v_IdPago VARCHAR(50) = CONCAT('PAG', RIGHT(CONCAT('000000', CAST((
        IFNULL((SELECT MAX(CAST(SUBSTRING(IDPAGOMEMBRESIA, 4, 10)) AS INT))
                FROM PAGOMEMBRESIA WHERE IDPAGOMEMBRESIA LIKE 'PAG%'), 0) + 1
    ) AS VARCHAR(10)), 6);

    INSERT INTO PAGOMEMBRESIA (
        IDPAGOMEMBRESIA, MONTO, FECHAPAGO, HORAPAGO, OBSERVACIONES,
        IDMEMBRESIA, IDMETODOPAGO, IDUSUARIO
    ) VALUES (
        v_IdPago, p_Monto, fn_fecha_ddmmyyyy(), TIME_FORMAT(NOW(), '%H:%i:%s'),
        IFNULL(NULLIF(p_Observaciones, ''), 'Abono'),
        p_IdMembresia, p_IdMetodoPago, p_RegistradoPor
    );

    SET p_Resultado = 1;
    SET p_Mensaje = 'Abono registrado correctamente.';
END;

SELECT 'SPs de pagos creados: listar, abono, membresías del estudiante.';
    SELECT p_Resultado AS Resultado, p_Mensaje AS Mensaje
END$$

DELIMITER ;