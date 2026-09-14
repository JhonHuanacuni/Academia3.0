-- ============================================================================
-- 1. usp_asistencia_listar
-- Orden por fecha (mas reciente primero) y columnas clicables.
-- phpMyAdmin: selecciona tu BD, pega TODO y ejecuta
-- ============================================================================

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
    DECLARE v_orden VARCHAR(50);
    DECLARE v_dir VARCHAR(4);

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

    SET v_orden = UPPER(IFNULL(NULLIF(TRIM(p_OrdenarPor), ''), 'FECHAREGISTRO'));
    SET v_dir = UPPER(IFNULL(NULLIF(TRIM(p_Direccion), ''), 'DESC'));
    IF v_dir NOT IN ('ASC', 'DESC') THEN SET v_dir = 'DESC'; END IF;
    IF v_orden IN ('FECHA') THEN SET v_orden = 'FECHAREGISTRO'; END IF;
    IF v_orden IN ('HORA') THEN SET v_orden = 'HORAINICIO'; END IF;
    IF v_orden IN ('ESTUDIANTE_NOMBRE', 'APELLIDO') THEN SET v_orden = 'NOMBRE'; END IF;

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
        CASE WHEN v_orden = 'FECHAREGISTRO' AND v_dir = 'ASC' THEN
            CONCAT(SUBSTRING(a.FECHAREGISTRO, 5, 4), SUBSTRING(a.FECHAREGISTRO, 3, 2), SUBSTRING(a.FECHAREGISTRO, 1, 2)) END ASC,
        CASE WHEN v_orden = 'FECHAREGISTRO' AND v_dir = 'DESC' THEN
            CONCAT(SUBSTRING(a.FECHAREGISTRO, 5, 4), SUBSTRING(a.FECHAREGISTRO, 3, 2), SUBSTRING(a.FECHAREGISTRO, 1, 2)) END DESC,
        CASE WHEN v_orden = 'HORAINICIO' AND v_dir = 'ASC'  THEN a.HORAINICIO END ASC,
        CASE WHEN v_orden = 'HORAINICIO' AND v_dir = 'DESC' THEN a.HORAINICIO END DESC,
        CASE WHEN v_orden = 'DNI' AND v_dir = 'ASC'  THEN u.DNI END ASC,
        CASE WHEN v_orden = 'DNI' AND v_dir = 'DESC' THEN u.DNI END DESC,
        CASE WHEN v_orden = 'NOMBRE' AND v_dir = 'ASC'  THEN CONCAT(IFNULL(u.APELLIDO, ''), ' ', IFNULL(u.NOMBRE, '')) END ASC,
        CASE WHEN v_orden = 'NOMBRE' AND v_dir = 'DESC' THEN CONCAT(IFNULL(u.APELLIDO, ''), ' ', IFNULL(u.NOMBRE, '')) END DESC,
        CASE WHEN v_orden = 'ESTADO' AND v_dir = 'ASC'  THEN
            IF(IFNULL(a.JUSTIFICADO, 0) = 1, 'Justificado', a.ESTADO) END ASC,
        CASE WHEN v_orden = 'ESTADO' AND v_dir = 'DESC' THEN
            IF(IFNULL(a.JUSTIFICADO, 0) = 1, 'Justificado', a.ESTADO) END DESC,
        CONCAT(SUBSTRING(a.FECHAREGISTRO, 5, 4), SUBSTRING(a.FECHAREGISTRO, 3, 2), SUBSTRING(a.FECHAREGISTRO, 1, 2)) DESC,
        a.HORAINICIO DESC
    LIMIT p_TamanioPagina OFFSET v_offset;
END$$

DELIMITER ;

SELECT '1. usp_asistencia_listar: orden por fecha y columnas listo.' AS info;
