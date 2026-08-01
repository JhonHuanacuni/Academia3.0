-- Convertido automáticamente desde db_scripts/12_07_2026/7.usp_usuario_listar_orden_tipo.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   usp_usuario_listar: ordenar por TIPOUSUARIO_DESCRIPCION (columna Tipo)
   Ejecutar después de 11_07_2026/2.usp_usuario_apoderado.sql
   Fecha: 12/07/2026
   ============================================================================ */

DROP PROCEDURE IF EXISTS usp_usuario_listar;

DROP PROCEDURE IF EXISTS usp_usuario_listar;

DELIMITER $$

CREATE PROCEDURE usp_usuario_listar(
    IN p_Buscar VARCHAR(200),
    IN p_Estado VARCHAR(50),
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
    FROM USUARIO u
    INNER JOIN TIPOUSUARIO t ON t.IDTIPOUSUARIO = u.IDTIPOUSUARIO
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           u.IDUSUARIO  LIKE CONCAT('%', p_Buscar, '%') OR
           u.NOMBRE     LIKE CONCAT('%', p_Buscar, '%') OR
           u.APELLIDO   LIKE CONCAT('%', p_Buscar, '%') OR
           u.DNI        LIKE CONCAT('%', p_Buscar, '%') OR
           u.EMAIL      LIKE CONCAT('%', p_Buscar, '%') OR
           IFNULL(u.NOMBREAPODERADO, '') LIKE CONCAT('%', p_Buscar, '%'))
      AND (p_Estado IS NULL OR p_Estado = '' OR u.ESTADO = p_Estado);

    SELECT
        u.IDUSUARIO,
        u.NOMBRE,
        u.APELLIDO,
        u.DNI,
        u.EMAIL,
        u.ESTADO,
        u.IDTIPOUSUARIO,
        t.DESCRIPCION AS TIPOUSUARIO_DESCRIPCION,
        u.FECHANACIMIENTO,
        u.DIRECCION,
        u.DISTRITO,
        u.COLEGIO,
        u.GRADO,
        u.TELPERSONAL,
        u.TELAPODERADO,
        u.NOMBREAPODERADO,
        u.PARENTESCO,
        u.SITUACIONACADEMICA
    FROM USUARIO u
    INNER JOIN TIPOUSUARIO t ON t.IDTIPOUSUARIO = u.IDTIPOUSUARIO
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           u.IDUSUARIO  LIKE CONCAT('%', p_Buscar, '%') OR
           u.NOMBRE     LIKE CONCAT('%', p_Buscar, '%') OR
           u.APELLIDO   LIKE CONCAT('%', p_Buscar, '%') OR
           u.DNI        LIKE CONCAT('%', p_Buscar, '%') OR
           u.EMAIL      LIKE CONCAT('%', p_Buscar, '%') OR
           IFNULL(u.NOMBREAPODERADO, '') LIKE CONCAT('%', p_Buscar, '%'))
      AND (p_Estado IS NULL OR p_Estado = '' OR u.ESTADO = p_Estado)
    ORDER BY
        CASE WHEN p_OrdenarPor = 'IDUSUARIO' AND p_Direccion = 'ASC'  THEN u.IDUSUARIO END ASC,
        CASE WHEN p_OrdenarPor = 'IDUSUARIO' AND p_Direccion = 'DESC' THEN u.IDUSUARIO END DESC,
        CASE WHEN p_OrdenarPor = 'NOMBRE'    AND p_Direccion = 'ASC'  THEN u.NOMBRE END ASC,
        CASE WHEN p_OrdenarPor = 'NOMBRE'    AND p_Direccion = 'DESC' THEN u.NOMBRE END DESC,
        CASE WHEN p_OrdenarPor = 'APELLIDO'  AND p_Direccion = 'ASC'  THEN u.APELLIDO END ASC,
        CASE WHEN p_OrdenarPor = 'APELLIDO'  AND p_Direccion = 'DESC' THEN u.APELLIDO END DESC,
        CASE WHEN p_OrdenarPor = 'DNI'       AND p_Direccion = 'ASC'  THEN u.DNI END ASC,
        CASE WHEN p_OrdenarPor = 'DNI'       AND p_Direccion = 'DESC' THEN u.DNI END DESC,
        CASE WHEN p_OrdenarPor = 'EMAIL'     AND p_Direccion = 'ASC'  THEN u.EMAIL END ASC,
        CASE WHEN p_OrdenarPor = 'EMAIL'     AND p_Direccion = 'DESC' THEN u.EMAIL END DESC,
        CASE WHEN p_OrdenarPor = 'ESTADO'    AND p_Direccion = 'ASC'  THEN u.ESTADO END ASC,
        CASE WHEN p_OrdenarPor = 'ESTADO'    AND p_Direccion = 'DESC' THEN u.ESTADO END DESC,
        CASE WHEN p_OrdenarPor = 'TIPOUSUARIO_DESCRIPCION' AND p_Direccion = 'ASC'  THEN t.DESCRIPCION END ASC,
        CASE WHEN p_OrdenarPor = 'TIPOUSUARIO_DESCRIPCION' AND p_Direccion = 'DESC' THEN t.DESCRIPCION END DESC,
        CASE WHEN p_OrdenarPor = 'NOMBREAPODERADO' AND p_Direccion = 'ASC'  THEN u.NOMBREAPODERADO END ASC,
        CASE WHEN p_OrdenarPor = 'NOMBREAPODERADO' AND p_Direccion = 'DESC' THEN u.NOMBREAPODERADO END DESC,
        CASE WHEN p_OrdenarPor = 'TELAPODERADO'    AND p_Direccion = 'ASC'  THEN u.TELAPODERADO END ASC,
        CASE WHEN p_OrdenarPor = 'TELAPODERADO'    AND p_Direccion = 'DESC' THEN u.TELAPODERADO END DESC,
        CASE WHEN p_OrdenarPor = 'PARENTESCO'      AND p_Direccion = 'ASC'  THEN u.PARENTESCO END ASC,
        CASE WHEN p_OrdenarPor = 'PARENTESCO'      AND p_Direccion = 'DESC' THEN u.PARENTESCO END DESC,
        u.IDUSUARIO
    LIMIT p_TamanioPagina OFFSET @v_offset;
END$$

DELIMITER ;