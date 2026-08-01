-- Convertido automáticamente desde db_scripts/16_07_2026/9.pagoextra_deuda_conceptos_estudiante.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   Pagos extraordinarios: últimos conceptos del estudiante (panel Nuevo pago)
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
IF p_Pagina < 1 THEN SET p_Pagina = 1; END IF;
    IF p_TamanioPagina < 1 THEN SET p_TamanioPagina = 10; END IF;

    SET @v_offset = (p_Pagina - 1) * p_TamanioPagina;
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
        UPPER(TRIM(CONCAT(IFNULL(u.APELLIDO, ''), ' ', IFNULL(u.NOMBRE, '')))) AS ESTUDIANTE_NOMBRE,
        u.DNI AS ESTUDIANTE_DNI,
        p.IDCONCEPTO,
        c.NOMBRE AS CONCEPTO_NOMBRE,
        p.MONTO,
        p.FECHAPAGO,
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
    LIMIT p_TamanioPagina OFFSET @v_offset;
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_pagoextra_conceptos_estudiante;

DROP PROCEDURE IF EXISTS usp_pagoextra_conceptos_estudiante;

DELIMITER $$

CREATE PROCEDURE usp_pagoextra_conceptos_estudiante(
    IN p_IdUsuario VARCHAR(50)
)
main: BEGIN
SELECT
        c.IDCONCEPTO,
        c.NOMBRE AS CONCEPTO_NOMBRE,
        c.COSTO,
        c.FECHAINICIO,
        c.FECHAFIN,
        IFNULL(SUM(p.MONTO), 0) AS PAGADO,
        CASE
            WHEN c.COSTO - IFNULL(SUM(p.MONTO), 0) < 0 THEN 0
            ELSE c.COSTO - IFNULL(SUM(p.MONTO), 0)
        END AS DEUDA,
        MAX(p.FECHAPAGO) AS ULTIMOPAGO
    FROM CONCEPTOPAGOEXTRA c
    INNER JOIN PAGOEXTRAORDINARIO p
        ON p.IDCONCEPTO = c.IDCONCEPTO AND p.IDUSUARIO = p_IdUsuario
    GROUP BY c.IDCONCEPTO, c.NOMBRE, c.COSTO, c.FECHAINICIO, c.FECHAFIN
    ORDER BY MAX(p.FECHAPAGO) DESC;
END$$

DELIMITER ;