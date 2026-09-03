-- ============================================================================
-- Horario: listar filtrados por salón del estudiante (MENSUALIDAD)
-- Si p_IdUsuario viene vacío → admin ve todos. Si viene ID → solo horarios
-- asignados a aulas de mensualidades activas del estudiante.
-- Fecha: 03/09/2026
-- ============================================================================

USE `AcademiaDB`;

DROP PROCEDURE IF EXISTS usp_horario_listar;

DELIMITER $$

CREATE PROCEDURE usp_horario_listar(
    IN p_Buscar VARCHAR(200),
    IN p_Estado VARCHAR(50),
    IN p_IdUsuario VARCHAR(50),
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
    FROM HORARIO h
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           h.IDHORARIO LIKE CONCAT('%', p_Buscar, '%') OR
           h.TITULO LIKE CONCAT('%', p_Buscar, '%') OR
           h.DESCRIPCION LIKE CONCAT('%', p_Buscar, '%'))
      AND (p_Estado IS NULL OR p_Estado = '' OR h.ESTADO = p_Estado)
      AND (
          p_IdUsuario IS NULL OR p_IdUsuario = '' OR
          EXISTS (
              SELECT 1
              FROM HORARIO_AULA ha
              WHERE ha.IDHORARIO = h.IDHORARIO
                AND ha.IDAULA IN (
                    SELECT DISTINCT ms.IDAULA
                    FROM MENSUALIDAD ms
                    WHERE ms.IDUSUARIO = p_IdUsuario
                      AND ms.ESTADO = 'Activo'
                      AND ms.IDAULA IS NOT NULL
                      AND TRIM(ms.IDAULA) <> ''
                )
          )
      );

    SELECT
        h.IDHORARIO,
        h.TITULO,
        h.DESCRIPCION,
        h.FECHASUBIDA,
        h.ESTADO,
        h.URLIMAGEN
    FROM HORARIO h
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           h.IDHORARIO LIKE CONCAT('%', p_Buscar, '%') OR
           h.TITULO LIKE CONCAT('%', p_Buscar, '%') OR
           h.DESCRIPCION LIKE CONCAT('%', p_Buscar, '%'))
      AND (p_Estado IS NULL OR p_Estado = '' OR h.ESTADO = p_Estado)
      AND (
          p_IdUsuario IS NULL OR p_IdUsuario = '' OR
          EXISTS (
              SELECT 1
              FROM HORARIO_AULA ha
              WHERE ha.IDHORARIO = h.IDHORARIO
                AND ha.IDAULA IN (
                    SELECT DISTINCT ms.IDAULA
                    FROM MENSUALIDAD ms
                    WHERE ms.IDUSUARIO = p_IdUsuario
                      AND ms.ESTADO = 'Activo'
                      AND ms.IDAULA IS NOT NULL
                      AND TRIM(ms.IDAULA) <> ''
                )
          )
      )
    ORDER BY
        CASE WHEN p_OrdenarPor = 'IDHORARIO'   AND p_Direccion = 'ASC'  THEN h.IDHORARIO END ASC,
        CASE WHEN p_OrdenarPor = 'IDHORARIO'   AND p_Direccion = 'DESC' THEN h.IDHORARIO END DESC,
        CASE WHEN p_OrdenarPor = 'TITULO'      AND p_Direccion = 'ASC'  THEN h.TITULO END ASC,
        CASE WHEN p_OrdenarPor = 'TITULO'      AND p_Direccion = 'DESC' THEN h.TITULO END DESC,
        CASE WHEN p_OrdenarPor = 'FECHASUBIDA' AND p_Direccion = 'ASC'
            THEN CONCAT(SUBSTRING(h.FECHASUBIDA,5,4), SUBSTRING(h.FECHASUBIDA,3,2), SUBSTRING(h.FECHASUBIDA,1,2)) END ASC,
        CASE WHEN p_OrdenarPor = 'FECHASUBIDA' AND p_Direccion = 'DESC'
            THEN CONCAT(SUBSTRING(h.FECHASUBIDA,5,4), SUBSTRING(h.FECHASUBIDA,3,2), SUBSTRING(h.FECHASUBIDA,1,2)) END DESC,
        CASE WHEN p_OrdenarPor = 'ESTADO'      AND p_Direccion = 'ASC'  THEN h.ESTADO END ASC,
        CASE WHEN p_OrdenarPor = 'ESTADO'      AND p_Direccion = 'DESC' THEN h.ESTADO END DESC,
        CONCAT(SUBSTRING(h.FECHASUBIDA,5,4), SUBSTRING(h.FECHASUBIDA,3,2), SUBSTRING(h.FECHASUBIDA,1,2)) DESC,
        h.IDHORARIO DESC
    LIMIT p_TamanioPagina OFFSET v_offset;
END$$

DELIMITER ;
