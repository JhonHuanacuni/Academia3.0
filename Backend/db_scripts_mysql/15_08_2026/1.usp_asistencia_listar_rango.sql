-- ============================================================================
-- usp_asistencia_listar: rango fecha inicio / fecha fin — MySQL 8
-- Fecha: 15/08/2026
-- ============================================================================

USE `AcademiaDB`;

DROP PROCEDURE IF EXISTS usp_asistencia_listar;

DELIMITER $$

CREATE PROCEDURE usp_asistencia_listar(
    IN p_FechaDesde CHAR(8),
    IN p_FechaHasta CHAR(8),
    IN p_Buscar VARCHAR(200),
    IN p_OrdenarPor VARCHAR(50),
    IN p_Direccion VARCHAR(4),
    IN p_Pagina INT,
    IN p_TamanioPagina INT,
    OUT p_TotalRegistros INT
)
main: BEGIN
    DECLARE v_offset INT DEFAULT 0;
    DECLARE v_hoy CHAR(8);
    DECLARE v_desde CHAR(8);
    DECLARE v_hasta CHAR(8);
    DECLARE v_tmp CHAR(8);

    SET v_hoy = fn_fecha_ddmmyyyy();
    SET v_desde = IF(p_FechaDesde IS NULL OR TRIM(p_FechaDesde) = '', v_hoy, TRIM(p_FechaDesde));
    SET v_hasta = IF(p_FechaHasta IS NULL OR TRIM(p_FechaHasta) = '', v_desde, TRIM(p_FechaHasta));

    IF CONCAT(SUBSTRING(v_desde, 5, 4), SUBSTRING(v_desde, 3, 2), SUBSTRING(v_desde, 1, 2))
       > CONCAT(SUBSTRING(v_hasta, 5, 4), SUBSTRING(v_hasta, 3, 2), SUBSTRING(v_hasta, 1, 2)) THEN
        SET v_tmp = v_desde;
        SET v_desde = v_hasta;
        SET v_hasta = v_tmp;
    END IF;

    IF p_Pagina < 1 THEN SET p_Pagina = 1; END IF;
    IF p_TamanioPagina < 1 THEN SET p_TamanioPagina = 50; END IF;
    SET v_offset = (p_Pagina - 1) * p_TamanioPagina;

    SELECT COUNT(*)
    INTO p_TotalRegistros
    FROM ASISTENCIA a
    INNER JOIN USUARIO u ON u.IDUSUARIO = a.IDUSUARIO
    WHERE CONCAT(SUBSTRING(a.FECHAREGISTRO, 5, 4), SUBSTRING(a.FECHAREGISTRO, 3, 2), SUBSTRING(a.FECHAREGISTRO, 1, 2))
          BETWEEN CONCAT(SUBSTRING(v_desde, 5, 4), SUBSTRING(v_desde, 3, 2), SUBSTRING(v_desde, 1, 2))
              AND CONCAT(SUBSTRING(v_hasta, 5, 4), SUBSTRING(v_hasta, 3, 2), SUBSTRING(v_hasta, 1, 2))
      AND (p_Buscar IS NULL OR p_Buscar = '' OR
           u.DNI LIKE CONCAT('%', p_Buscar, '%') OR
           u.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
           u.APELLIDO LIKE CONCAT('%', p_Buscar, '%') OR
           u.IDUSUARIO LIKE CONCAT('%', p_Buscar, '%'));

    SELECT
        a.IDASISTENCIA,
        a.FECHAREGISTRO,
        a.HORAINICIO,
        a.ESTADO,
        a.JUSTIFICADO,
        u.IDUSUARIO,
        u.NOMBRE,
        u.APELLIDO,
        u.DNI
    FROM ASISTENCIA a
    INNER JOIN USUARIO u ON u.IDUSUARIO = a.IDUSUARIO
    WHERE CONCAT(SUBSTRING(a.FECHAREGISTRO, 5, 4), SUBSTRING(a.FECHAREGISTRO, 3, 2), SUBSTRING(a.FECHAREGISTRO, 1, 2))
          BETWEEN CONCAT(SUBSTRING(v_desde, 5, 4), SUBSTRING(v_desde, 3, 2), SUBSTRING(v_desde, 1, 2))
              AND CONCAT(SUBSTRING(v_hasta, 5, 4), SUBSTRING(v_hasta, 3, 2), SUBSTRING(v_hasta, 1, 2))
      AND (p_Buscar IS NULL OR p_Buscar = '' OR
           u.DNI LIKE CONCAT('%', p_Buscar, '%') OR
           u.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
           u.APELLIDO LIKE CONCAT('%', p_Buscar, '%') OR
           u.IDUSUARIO LIKE CONCAT('%', p_Buscar, '%'))
    ORDER BY
        CASE WHEN p_OrdenarPor = 'FECHAREGISTRO' AND p_Direccion = 'ASC' THEN
            CONCAT(SUBSTRING(a.FECHAREGISTRO, 5, 4), SUBSTRING(a.FECHAREGISTRO, 3, 2), SUBSTRING(a.FECHAREGISTRO, 1, 2)) END ASC,
        CASE WHEN p_OrdenarPor = 'FECHAREGISTRO' AND p_Direccion = 'DESC' THEN
            CONCAT(SUBSTRING(a.FECHAREGISTRO, 5, 4), SUBSTRING(a.FECHAREGISTRO, 3, 2), SUBSTRING(a.FECHAREGISTRO, 1, 2)) END DESC,
        CASE WHEN p_OrdenarPor = 'HORAINICIO' AND p_Direccion = 'ASC'  THEN a.HORAINICIO END ASC,
        CASE WHEN p_OrdenarPor = 'HORAINICIO' AND p_Direccion = 'DESC' THEN a.HORAINICIO END DESC,
        CASE WHEN p_OrdenarPor = 'NOMBRE'    AND p_Direccion = 'ASC'  THEN u.NOMBRE END ASC,
        CASE WHEN p_OrdenarPor = 'NOMBRE'    AND p_Direccion = 'DESC' THEN u.NOMBRE END DESC,
        CONCAT(SUBSTRING(a.FECHAREGISTRO, 5, 4), SUBSTRING(a.FECHAREGISTRO, 3, 2), SUBSTRING(a.FECHAREGISTRO, 1, 2)) DESC,
        a.HORAINICIO DESC
    LIMIT p_TamanioPagina OFFSET v_offset;
END$$

DELIMITER ;

SELECT 'usp_asistencia_listar: rango fecha inicio/fin listo.' AS info;
