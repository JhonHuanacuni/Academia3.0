-- ============================================================================
-- Biblioteca: listar PDFs filtrados por salón del estudiante (MENSUALIDAD)
-- Si p_IdUsuario viene vacío → admin ve todos. Si viene ID → solo libros
-- asignados a aulas de mensualidades activas del estudiante.
-- Fecha: 02/09/2026
-- ============================================================================

USE `AcademiaDB`;

DROP PROCEDURE IF EXISTS usp_libro_listar;

DELIMITER $$

CREATE PROCEDURE usp_libro_listar(
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
    FROM LIBRO l
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           l.IDLIBRO LIKE CONCAT('%', p_Buscar, '%') OR
           l.TITULO LIKE CONCAT('%', p_Buscar, '%') OR
           l.DESCRIPCION LIKE CONCAT('%', p_Buscar, '%'))
      AND (p_Estado IS NULL OR p_Estado = '' OR l.ESTADO = p_Estado)
      AND (
          p_IdUsuario IS NULL OR p_IdUsuario = '' OR
          EXISTS (
              SELECT 1
              FROM LIBRO_AULA la
              WHERE la.IDLIBRO = l.IDLIBRO
                AND la.IDAULA IN (
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
        l.IDLIBRO,
        l.TITULO,
        l.DESCRIPCION,
        l.FECHASUBIDA,
        l.ESTADO,
        l.URLCONTENIDO,
        l.IMGPORTADA
    FROM LIBRO l
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           l.IDLIBRO LIKE CONCAT('%', p_Buscar, '%') OR
           l.TITULO LIKE CONCAT('%', p_Buscar, '%') OR
           l.DESCRIPCION LIKE CONCAT('%', p_Buscar, '%'))
      AND (p_Estado IS NULL OR p_Estado = '' OR l.ESTADO = p_Estado)
      AND (
          p_IdUsuario IS NULL OR p_IdUsuario = '' OR
          EXISTS (
              SELECT 1
              FROM LIBRO_AULA la
              WHERE la.IDLIBRO = l.IDLIBRO
                AND la.IDAULA IN (
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
        CASE WHEN p_OrdenarPor = 'IDLIBRO'     AND p_Direccion = 'ASC'  THEN l.IDLIBRO END ASC,
        CASE WHEN p_OrdenarPor = 'IDLIBRO'     AND p_Direccion = 'DESC' THEN l.IDLIBRO END DESC,
        CASE WHEN p_OrdenarPor = 'TITULO'      AND p_Direccion = 'ASC'  THEN l.TITULO END ASC,
        CASE WHEN p_OrdenarPor = 'TITULO'      AND p_Direccion = 'DESC' THEN l.TITULO END DESC,
        CASE WHEN p_OrdenarPor = 'FECHASUBIDA' AND p_Direccion = 'ASC'
            THEN CONCAT(SUBSTRING(l.FECHASUBIDA,5,4), SUBSTRING(l.FECHASUBIDA,3,2), SUBSTRING(l.FECHASUBIDA,1,2)) END ASC,
        CASE WHEN p_OrdenarPor = 'FECHASUBIDA' AND p_Direccion = 'DESC'
            THEN CONCAT(SUBSTRING(l.FECHASUBIDA,5,4), SUBSTRING(l.FECHASUBIDA,3,2), SUBSTRING(l.FECHASUBIDA,1,2)) END DESC,
        CASE WHEN p_OrdenarPor = 'ESTADO'      AND p_Direccion = 'ASC'  THEN l.ESTADO END ASC,
        CASE WHEN p_OrdenarPor = 'ESTADO'      AND p_Direccion = 'DESC' THEN l.ESTADO END DESC,
        CONCAT(SUBSTRING(l.FECHASUBIDA,5,4), SUBSTRING(l.FECHASUBIDA,3,2), SUBSTRING(l.FECHASUBIDA,1,2)) DESC,
        l.IDLIBRO DESC
    LIMIT p_TamanioPagina OFFSET v_offset;
END$$

DELIMITER ;
