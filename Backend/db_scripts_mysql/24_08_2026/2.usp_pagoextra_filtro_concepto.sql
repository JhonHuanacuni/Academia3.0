-- ============================================================================
-- Pagos extraordinarios: filtro por concepto en el listado agrupado
-- Fecha: 24/08/2026
-- ============================================================================

USE `AcademiaDB`;

DROP PROCEDURE IF EXISTS usp_pagoextra_listar;

DELIMITER $$

CREATE PROCEDURE usp_pagoextra_listar(
    IN p_Buscar VARCHAR(200),
    IN p_OrdenarPor VARCHAR(50),
    IN p_Direccion VARCHAR(4),
    IN p_Pagina INT,
    IN p_TamanioPagina INT,
    IN p_IdConcepto VARCHAR(50),
    OUT p_TotalRegistros INT
)
main: BEGIN
    DECLARE v_offset INT DEFAULT 0;

    IF p_Pagina < 1 THEN SET p_Pagina = 1; END IF;
    IF p_TamanioPagina < 1 THEN SET p_TamanioPagina = 10; END IF;
    SET v_offset = (p_Pagina - 1) * p_TamanioPagina;

    SELECT COUNT(*) INTO p_TotalRegistros
    FROM (
        SELECT p.IDUSUARIO, p.IDCONCEPTO
        FROM PAGOEXTRAORDINARIO p
        INNER JOIN USUARIO u ON u.IDUSUARIO = p.IDUSUARIO
        INNER JOIN CONCEPTOPAGOEXTRA c ON c.IDCONCEPTO = p.IDCONCEPTO
        WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
               u.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
               u.APELLIDO LIKE CONCAT('%', p_Buscar, '%') OR
               u.DNI LIKE CONCAT('%', p_Buscar, '%') OR
               c.NOMBRE LIKE CONCAT('%', p_Buscar, '%'))
          AND (p_IdConcepto IS NULL OR p_IdConcepto = '' OR p.IDCONCEPTO = p_IdConcepto)
        GROUP BY p.IDUSUARIO, p.IDCONCEPTO
    ) g;

    SELECT *
    FROM (
        SELECT
            CONCAT(p.IDUSUARIO, '|', p.IDCONCEPTO) AS GRUPO_KEY,
            p.IDUSUARIO,
            UPPER(TRIM(CONCAT(IFNULL(u.APELLIDO, ''), ' ', IFNULL(u.NOMBRE, '')))) AS ESTUDIANTE_NOMBRE,
            u.DNI AS ESTUDIANTE_DNI,
            p.IDCONCEPTO,
            c.NOMBRE AS CONCEPTO_NOMBRE,
            c.COSTO AS MONTO_TOTAL,
            IFNULL(SUM(p.MONTO), 0) AS PAGADO,
            CASE
                WHEN c.COSTO - IFNULL(SUM(p.MONTO), 0) < 0 THEN 0
                ELSE c.COSTO - IFNULL(SUM(p.MONTO), 0)
            END AS DEUDA,
            COUNT(p.IDPAGOEXTRA) AS CANTIDAD_PAGOS,
            DATE_FORMAT(
                MAX(STR_TO_DATE(p.FECHAPAGO, '%d%m%Y')),
                '%d%m%Y'
            ) AS ULTIMO_PAGO
        FROM PAGOEXTRAORDINARIO p
        INNER JOIN USUARIO u ON u.IDUSUARIO = p.IDUSUARIO
        INNER JOIN CONCEPTOPAGOEXTRA c ON c.IDCONCEPTO = p.IDCONCEPTO
        WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
               u.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
               u.APELLIDO LIKE CONCAT('%', p_Buscar, '%') OR
               u.DNI LIKE CONCAT('%', p_Buscar, '%') OR
               c.NOMBRE LIKE CONCAT('%', p_Buscar, '%'))
          AND (p_IdConcepto IS NULL OR p_IdConcepto = '' OR p.IDCONCEPTO = p_IdConcepto)
        GROUP BY p.IDUSUARIO, u.APELLIDO, u.NOMBRE, u.DNI, p.IDCONCEPTO, c.NOMBRE, c.COSTO
    ) base
    ORDER BY
        CASE WHEN p_OrdenarPor = 'DEUDA' AND p_Direccion = 'ASC' THEN base.DEUDA END ASC,
        CASE WHEN p_OrdenarPor = 'DEUDA' AND p_Direccion = 'DESC' THEN base.DEUDA END DESC,
        CASE WHEN p_OrdenarPor = 'PAGADO' AND p_Direccion = 'ASC' THEN base.PAGADO END ASC,
        CASE WHEN p_OrdenarPor = 'PAGADO' AND p_Direccion = 'DESC' THEN base.PAGADO END DESC,
        CASE WHEN p_OrdenarPor = 'MONTO_TOTAL' AND p_Direccion = 'ASC' THEN base.MONTO_TOTAL END ASC,
        CASE WHEN p_OrdenarPor = 'MONTO_TOTAL' AND p_Direccion = 'DESC' THEN base.MONTO_TOTAL END DESC,
        CASE WHEN p_OrdenarPor IN ('FECHAPAGO', 'ULTIMO_PAGO') AND p_Direccion = 'ASC'
            THEN STR_TO_DATE(base.ULTIMO_PAGO, '%d%m%Y') END ASC,
        CASE WHEN p_OrdenarPor IN ('FECHAPAGO', 'ULTIMO_PAGO') AND p_Direccion = 'DESC'
            THEN STR_TO_DATE(base.ULTIMO_PAGO, '%d%m%Y') END DESC,
        CASE WHEN p_OrdenarPor = 'ESTUDIANTE_NOMBRE' AND p_Direccion = 'ASC' THEN base.ESTUDIANTE_NOMBRE END ASC,
        CASE WHEN p_OrdenarPor = 'ESTUDIANTE_NOMBRE' AND p_Direccion = 'DESC' THEN base.ESTUDIANTE_NOMBRE END DESC,
        CASE WHEN p_OrdenarPor = 'CONCEPTO_NOMBRE' AND p_Direccion = 'ASC' THEN base.CONCEPTO_NOMBRE END ASC,
        CASE WHEN p_OrdenarPor = 'CONCEPTO_NOMBRE' AND p_Direccion = 'DESC' THEN base.CONCEPTO_NOMBRE END DESC,
        STR_TO_DATE(base.ULTIMO_PAGO, '%d%m%Y') DESC
    LIMIT p_TamanioPagina OFFSET v_offset;
END$$

DELIMITER ;
