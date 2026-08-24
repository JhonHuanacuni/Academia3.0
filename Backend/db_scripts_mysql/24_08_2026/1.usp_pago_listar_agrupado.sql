-- ============================================================================
-- Pagos: listado agrupado por mensualidad (estudiante + plan)
-- + detalle de pagos de una mensualidad para el modal
-- Fecha: 24/08/2026
-- ============================================================================

USE `AcademiaDB`;

DROP PROCEDURE IF EXISTS usp_pago_listar_agrupado;

DELIMITER $$

CREATE PROCEDURE usp_pago_listar_agrupado(
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

    DROP TEMPORARY TABLE IF EXISTS tmp_pago_agrupado;
    CREATE TEMPORARY TABLE tmp_pago_agrupado AS
    SELECT
        ult.IDPAGOMENSUALIDAD,
        m.IDMENSUALIDAD,
        m.IDUSUARIO,
        UPPER(TRIM(CONCAT(IFNULL(u.APELLIDO, ''), ' ', IFNULL(u.NOMBRE, '')))) AS ESTUDIANTE_NOMBRE,
        u.DNI AS ESTUDIANTE_DNI,
        pl.NOMBRE AS PLAN_NOMBRE,
        ca.NUMERO AS CUOTA_NUMERO,
        IFNULL(ca.MONTO, m.MONTOTOTAL) AS TOTAL,
        CASE
            WHEN ca.IDCUOTA IS NOT NULL THEN IFNULL(pagc.PAGADO, 0)
            ELSE IFNULL(pag.PAGADO, 0)
        END AS PAGADO,
        CASE
            WHEN EXISTS (
                SELECT 1 FROM MENSUALIDAD_CUOTA cx WHERE cx.IDMENSUALIDAD = m.IDMENSUALIDAD
            ) THEN (
                SELECT IFNULL(SUM(
                    CASE WHEN IFNULL(c.MONTO, 0) - IFNULL(pg.PAGADO, 0) < 0 THEN 0
                         ELSE IFNULL(c.MONTO, 0) - IFNULL(pg.PAGADO, 0) END
                ), 0)
                FROM MENSUALIDAD_CUOTA c
                LEFT JOIN (
                    SELECT IDCUOTA, SUM(MONTO) AS PAGADO
                    FROM PAGOMENSUALIDAD WHERE IDCUOTA IS NOT NULL
                    GROUP BY IDCUOTA
                ) pg ON pg.IDCUOTA = c.IDCUOTA
                WHERE c.IDMENSUALIDAD = m.IDMENSUALIDAD
                  AND STR_TO_DATE(c.FECHAINICIO, '%d%m%Y') <= CURDATE()
            )
            ELSE (
                CASE WHEN IFNULL(m.MONTOTOTAL, 0) - IFNULL(pag.PAGADO, 0) < 0 THEN 0
                     ELSE IFNULL(m.MONTOTOTAL, 0) - IFNULL(pag.PAGADO, 0) END
            )
        END AS DEUDA,
        IFNULL(ca.FECHAINICIO, m.FECHAINICIO) AS FECHAINICIO_CUOTA,
        IFNULL(ca.FECHAFIN, m.FECHAFIN) AS FECHAFIN_CUOTA
    FROM MENSUALIDAD m
    INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
    INNER JOIN `PLAN` pl ON pl.IDPLAN = m.IDPLAN
    INNER JOIN (
        SELECT p1.IDMENSUALIDAD, p1.IDPAGOMENSUALIDAD
        FROM PAGOMENSUALIDAD p1
        INNER JOIN (
            SELECT p.IDMENSUALIDAD, MAX(p.IDPAGOMENSUALIDAD) AS ID_ULT
            FROM PAGOMENSUALIDAD p
            INNER JOIN (
                SELECT IDMENSUALIDAD, MAX(STR_TO_DATE(FECHAPAGO, '%d%m%Y')) AS MAX_F
                FROM PAGOMENSUALIDAD
                GROUP BY IDMENSUALIDAD
            ) mx ON mx.IDMENSUALIDAD = p.IDMENSUALIDAD
               AND STR_TO_DATE(p.FECHAPAGO, '%d%m%Y') = mx.MAX_F
            GROUP BY p.IDMENSUALIDAD
        ) pick ON pick.ID_ULT = p1.IDPAGOMENSUALIDAD
    ) ult ON ult.IDMENSUALIDAD = m.IDMENSUALIDAD
    LEFT JOIN (
        SELECT IDMENSUALIDAD, SUM(MONTO) AS PAGADO
        FROM PAGOMENSUALIDAD
        GROUP BY IDMENSUALIDAD
    ) pag ON pag.IDMENSUALIDAD = m.IDMENSUALIDAD
    LEFT JOIN MENSUALIDAD_CUOTA ca ON ca.IDCUOTA = (
        SELECT c.IDCUOTA
        FROM MENSUALIDAD_CUOTA c
        WHERE c.IDMENSUALIDAD = m.IDMENSUALIDAD
        ORDER BY
            CASE
                WHEN STR_TO_DATE(c.FECHAINICIO, '%d%m%Y') <= CURDATE()
                 AND STR_TO_DATE(c.FECHAFIN, '%d%m%Y') >= CURDATE() THEN 0
                WHEN STR_TO_DATE(c.FECHAINICIO, '%d%m%Y') <= CURDATE() THEN 1
                ELSE 2
            END,
            CASE
                WHEN STR_TO_DATE(c.FECHAINICIO, '%d%m%Y') <= CURDATE()
                 AND STR_TO_DATE(c.FECHAFIN, '%d%m%Y') >= CURDATE() THEN c.NUMERO
                WHEN STR_TO_DATE(c.FECHAINICIO, '%d%m%Y') <= CURDATE() THEN -c.NUMERO
                ELSE c.NUMERO
            END
        LIMIT 1
    )
    LEFT JOIN (
        SELECT IDCUOTA, SUM(MONTO) AS PAGADO
        FROM PAGOMENSUALIDAD
        WHERE IDCUOTA IS NOT NULL
        GROUP BY IDCUOTA
    ) pagc ON pagc.IDCUOTA = ca.IDCUOTA
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           u.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
           u.APELLIDO LIKE CONCAT('%', p_Buscar, '%') OR
           CONCAT(IFNULL(u.APELLIDO, ''), ' ', IFNULL(u.NOMBRE, '')) LIKE CONCAT('%', p_Buscar, '%') OR
           u.DNI LIKE CONCAT('%', p_Buscar, '%') OR
           pl.NOMBRE LIKE CONCAT('%', p_Buscar, '%'));

    SELECT COUNT(*) INTO p_TotalRegistros FROM tmp_pago_agrupado;

    SELECT *
    FROM tmp_pago_agrupado base
    ORDER BY
        CASE WHEN p_OrdenarPor = 'ESTUDIANTE_NOMBRE' AND p_Direccion = 'ASC' THEN base.ESTUDIANTE_NOMBRE END ASC,
        CASE WHEN p_OrdenarPor = 'ESTUDIANTE_NOMBRE' AND p_Direccion = 'DESC' THEN base.ESTUDIANTE_NOMBRE END DESC,
        CASE WHEN p_OrdenarPor = 'PLAN_NOMBRE' AND p_Direccion = 'ASC' THEN base.PLAN_NOMBRE END ASC,
        CASE WHEN p_OrdenarPor = 'PLAN_NOMBRE' AND p_Direccion = 'DESC' THEN base.PLAN_NOMBRE END DESC,
        CASE WHEN p_OrdenarPor = 'CUOTA_NUMERO' AND p_Direccion = 'ASC' THEN base.CUOTA_NUMERO END ASC,
        CASE WHEN p_OrdenarPor = 'CUOTA_NUMERO' AND p_Direccion = 'DESC' THEN base.CUOTA_NUMERO END DESC,
        CASE WHEN p_OrdenarPor = 'TOTAL' AND p_Direccion = 'ASC' THEN base.TOTAL END ASC,
        CASE WHEN p_OrdenarPor = 'TOTAL' AND p_Direccion = 'DESC' THEN base.TOTAL END DESC,
        CASE WHEN p_OrdenarPor = 'DEUDA' AND p_Direccion = 'ASC' THEN base.DEUDA END ASC,
        CASE WHEN p_OrdenarPor = 'DEUDA' AND p_Direccion = 'DESC' THEN base.DEUDA END DESC,
        CASE WHEN p_OrdenarPor = 'PAGADO' AND p_Direccion = 'ASC' THEN base.PAGADO END ASC,
        CASE WHEN p_OrdenarPor = 'PAGADO' AND p_Direccion = 'DESC' THEN base.PAGADO END DESC,
        CASE WHEN p_OrdenarPor IN ('FECHA', 'FECHAINICIO_CUOTA') AND p_Direccion = 'ASC'
            THEN STR_TO_DATE(base.FECHAINICIO_CUOTA, '%d%m%Y') END ASC,
        CASE WHEN p_OrdenarPor IN ('FECHA', 'FECHAINICIO_CUOTA') AND p_Direccion = 'DESC'
            THEN STR_TO_DATE(base.FECHAINICIO_CUOTA, '%d%m%Y') END DESC,
        base.ESTUDIANTE_NOMBRE ASC
    LIMIT p_TamanioPagina OFFSET v_offset;

    DROP TEMPORARY TABLE IF EXISTS tmp_pago_agrupado;
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_pago_listar_detalle;

DELIMITER $$

CREATE PROCEDURE usp_pago_listar_detalle(
    IN p_IdMensualidad VARCHAR(50)
)
main: BEGIN
    SELECT
        p.IDPAGOMENSUALIDAD,
        p.IDMENSUALIDAD,
        p.IDCUOTA,
        c.NUMERO AS CUOTA_NUMERO,
        p.MONTO,
        IFNULL(p.MORA, 0) AS MORA,
        p.MONTO + IFNULL(p.MORA, 0) AS TOTAL_COBRADO,
        p.FECHAPAGO,
        p.HORAPAGO,
        p.IDMETODOPAGO,
        IFNULL(mp.TITULO, '') AS METODOPAGO_TITULO,
        p.OBSERVACIONES,
        UPPER(TRIM(CONCAT(IFNULL(u.APELLIDO, ''), ' ', IFNULL(u.NOMBRE, '')))) AS ESTUDIANTE_NOMBRE,
        pl.NOMBRE AS PLAN_NOMBRE
    FROM PAGOMENSUALIDAD p
    INNER JOIN MENSUALIDAD m ON m.IDMENSUALIDAD = p.IDMENSUALIDAD
    INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
    INNER JOIN `PLAN` pl ON pl.IDPLAN = m.IDPLAN
    LEFT JOIN MENSUALIDAD_CUOTA c ON c.IDCUOTA = p.IDCUOTA
    LEFT JOIN METODO_PAGO mp ON mp.IDMETODOPAGO = p.IDMETODOPAGO
    WHERE p.IDMENSUALIDAD = p_IdMensualidad
    ORDER BY
        STR_TO_DATE(p.FECHAPAGO, '%d%m%Y') DESC,
        p.HORAPAGO DESC,
        p.IDPAGOMENSUALIDAD DESC;
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_mensualidad_listar_pagos;

DELIMITER $$

CREATE PROCEDURE usp_mensualidad_listar_pagos(
    IN p_IdMensualidad VARCHAR(50)
)
main: BEGIN
    SELECT
        p.IDPAGOMENSUALIDAD,
        p.IDCUOTA,
        c.NUMERO AS CUOTA_NUMERO,
        p.MONTO,
        IFNULL(p.MORA, 0) AS MORA,
        p.MONTO + IFNULL(p.MORA, 0) AS TOTAL_COBRADO,
        p.FECHAPAGO,
        p.HORAPAGO,
        p.IDMETODOPAGO,
        IFNULL(mp.TITULO, '') AS METODOPAGO_TITULO
    FROM PAGOMENSUALIDAD p
    LEFT JOIN MENSUALIDAD_CUOTA c ON c.IDCUOTA = p.IDCUOTA
    LEFT JOIN METODO_PAGO mp ON mp.IDMETODOPAGO = p.IDMETODOPAGO
    WHERE p.IDMENSUALIDAD = p_IdMensualidad
    ORDER BY
        STR_TO_DATE(p.FECHAPAGO, '%d%m%Y') DESC,
        p.HORAPAGO DESC,
        p.IDPAGOMENSUALIDAD DESC;
END$$

DELIMITER ;
