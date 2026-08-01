-- Convertido automáticamente desde db_scripts/30_07_2026/4.usp_auditoria_crud.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   SPs listar / obtener auditoría
   Fecha: 31/07/2026
   Prerequisito: 2.auditoria_tabla.sql
   ============================================================================ */

DROP PROCEDURE IF EXISTS usp_auditoria_listar;

DROP PROCEDURE IF EXISTS usp_auditoria_listar;

DELIMITER $$

CREATE PROCEDURE usp_auditoria_listar(
    IN p_Buscar VARCHAR(200),
    IN p_Tabla VARCHAR(100),
    IN p_Accion VARCHAR(20),
    IN p_IdUsuario VARCHAR(50),
    IN p_FechaDesde CHAR(8),
    IN p_FechaHasta CHAR(8),
    IN p_OrdenarPor VARCHAR(50),
    IN p_Direccion VARCHAR(4),
    IN p_Pagina INT,
    IN p_TamanioPagina INT,
    OUT p_TotalRegistros INT
)
main: BEGIN
IF p_Pagina < 1 THEN SET p_Pagina = 1; END IF;
    IF p_TamanioPagina < 1 THEN SET p_TamanioPagina = 10; END IF;

    SELECT COUNT(*) INTO p_TotalRegistros
    FROM AUDITORIA a
    LEFT JOIN USUARIO u ON u.IDUSUARIO = a.IDUSUARIO
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           a.IDAUDITORIA LIKE CONCAT('%', p_Buscar, '%') OR
           a.TABLA LIKE CONCAT('%', p_Buscar, '%') OR
           a.IDREGISTRO LIKE CONCAT('%', p_Buscar, '%') OR
           a.ACCION LIKE CONCAT('%', p_Buscar, '%') OR
           CONCAT(IFNULL(u.NOMBRE, ''), ' ') + IFNULL(u.APELLIDO, '') LIKE CONCAT('%', p_Buscar, '%') OR
           IFNULL(a.IDUSUARIO, '') LIKE CONCAT('%', p_Buscar, '%'))
      AND (p_Tabla IS NULL OR p_Tabla = '' OR a.TABLA = p_Tabla)
      AND (p_Accion IS NULL OR p_Accion = '' OR a.ACCION = p_Accion)
      AND (p_IdUsuario IS NULL OR p_IdUsuario = '' OR a.IDUSUARIO = p_IdUsuario)
      AND (p_FechaDesde IS NULL OR p_FechaDesde = '' OR a.FECHA >= p_FechaDesde)
      AND (p_FechaHasta IS NULL OR p_FechaHasta = '' OR a.FECHA <= p_FechaHasta);

    SELECT
        a.IDAUDITORIA,
        a.TABLA,
        a.IDREGISTRO,
        a.ACCION,
        a.IDUSUARIO,
        TRIM(CONCAT(IFNULL(u.NOMBRE, ''), ' ') + IFNULL(u.APELLIDO, ''))) AS USUARIO_NOMBRE,
        a.FECHA,
        a.HORA,
        a.DATOS_ANTES,
        a.DATOS_DESPUES
    FROM AUDITORIA a
    LEFT JOIN USUARIO u ON u.IDUSUARIO = a.IDUSUARIO
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           a.IDAUDITORIA LIKE CONCAT('%', p_Buscar, '%') OR
           a.TABLA LIKE CONCAT('%', p_Buscar, '%') OR
           a.IDREGISTRO LIKE CONCAT('%', p_Buscar, '%') OR
           a.ACCION LIKE CONCAT('%', p_Buscar, '%') OR
           CONCAT(IFNULL(u.NOMBRE, ''), ' ') + IFNULL(u.APELLIDO, '') LIKE CONCAT('%', p_Buscar, '%') OR
           IFNULL(a.IDUSUARIO, '') LIKE CONCAT('%', p_Buscar, '%'))
      AND (p_Tabla IS NULL OR p_Tabla = '' OR a.TABLA = p_Tabla)
      AND (p_Accion IS NULL OR p_Accion = '' OR a.ACCION = p_Accion)
      AND (p_IdUsuario IS NULL OR p_IdUsuario = '' OR a.IDUSUARIO = p_IdUsuario)
      AND (p_FechaDesde IS NULL OR p_FechaDesde = '' OR a.FECHA >= p_FechaDesde)
      AND (p_FechaHasta IS NULL OR p_FechaHasta = '' OR a.FECHA <= p_FechaHasta)
    ORDER BY
        CASE WHEN p_OrdenarPor = 'FECHA' AND p_Direccion = 'DESC' THEN a.FECHA END DESC,
        CASE WHEN p_OrdenarPor = 'FECHA' AND p_Direccion = 'ASC'  THEN a.FECHA END ASC,
        CASE WHEN p_OrdenarPor = 'HORA' AND p_Direccion = 'DESC' THEN a.HORA END DESC,
        CASE WHEN p_OrdenarPor = 'HORA' AND p_Direccion = 'ASC'  THEN a.HORA END ASC,
        CASE WHEN p_OrdenarPor = 'TABLA' AND p_Direccion = 'DESC' THEN a.TABLA END DESC,
        CASE WHEN p_OrdenarPor = 'TABLA' AND p_Direccion = 'ASC'  THEN a.TABLA END ASC,
        CASE WHEN p_OrdenarPor = 'ACCION' AND p_Direccion = 'DESC' THEN a.ACCION END DESC,
        CASE WHEN p_OrdenarPor = 'ACCION' AND p_Direccion = 'ASC'  THEN a.ACCION END ASC,
        CASE WHEN p_OrdenarPor = 'IDREGISTRO' AND p_Direccion = 'DESC' THEN a.IDREGISTRO END DESC,
        CASE WHEN p_OrdenarPor = 'IDREGISTRO' AND p_Direccion = 'ASC'  THEN a.IDREGISTRO END ASC,
        CASE WHEN p_OrdenarPor = 'USUARIO_NOMBRE' AND p_Direccion = 'DESC'
            THEN TRIM(CONCAT(IFNULL(u.NOMBRE, ''), ' ') + IFNULL(u.APELLIDO, ''))) END DESC,
        CASE WHEN p_OrdenarPor = 'USUARIO_NOMBRE' AND p_Direccion = 'ASC'
            THEN TRIM(CONCAT(IFNULL(u.NOMBRE, ''), ' ') + IFNULL(u.APELLIDO, ''))) END ASC,
        a.FECHA DESC, a.HORA DESC, a.IDAUDITORIA DESC
    LIMIT p_TamanioPagina OFFSET ((p_Pagina - 1) * p_TamanioPagina);
    SELECT p_TotalRegistros AS TotalRegistros
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_auditoria_obtener;

DROP PROCEDURE IF EXISTS usp_auditoria_obtener;

DELIMITER $$

CREATE PROCEDURE usp_auditoria_obtener(
    IN p_Id VARCHAR(50)
)
main: BEGIN
SELECT
        a.IDAUDITORIA,
        a.TABLA,
        a.IDREGISTRO,
        a.ACCION,
        a.IDUSUARIO,
        TRIM(CONCAT(IFNULL(u.NOMBRE, ''), ' ') + IFNULL(u.APELLIDO, ''))) AS USUARIO_NOMBRE,
        a.FECHA,
        a.HORA,
        a.DATOS_ANTES,
        a.DATOS_DESPUES
    FROM AUDITORIA a
    LEFT JOIN USUARIO u ON u.IDUSUARIO = a.IDUSUARIO
    WHERE a.IDAUDITORIA = p_Id;
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_auditoria_tablas_catalogo;

DROP PROCEDURE IF EXISTS usp_auditoria_tablas_catalogo;

DELIMITER $$

CREATE PROCEDURE usp_auditoria_tablas_catalogo()
main: BEGIN
SELECT DISTINCT TABLA
    FROM AUDITORIA
    ORDER BY TABLA;
END;

SELECT 'SPs de auditoría listos.';
END$$

DELIMITER ;