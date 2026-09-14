-- ============================================================================
-- 7. usp_examen_resultados_catalogos (todos los examenes para docente/admin)
-- Fecha: 13/09/2026
-- phpMyAdmin: selecciona tu BD, pega TODO y ejecuta
-- ============================================================================

DROP PROCEDURE IF EXISTS usp_examen_resultados_catalogos;

DELIMITER $$

CREATE PROCEDURE usp_examen_resultados_catalogos(
    IN p_IdSolicitante VARCHAR(50)
)
main: BEGIN
    DECLARE v_EsEstudiante TINYINT DEFAULT 0;

    IF p_IdSolicitante IS NULL OR TRIM(p_IdSolicitante) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Falta idusuario';
    END IF;

    SELECT IF(IDTIPOUSUARIO = '1', 1, 0) INTO v_EsEstudiante
    FROM USUARIO WHERE IDUSUARIO = p_IdSolicitante LIMIT 1;

    SELECT v_EsEstudiante AS SOLOPROPIOS;

    IF v_EsEstudiante = 1 THEN
        SELECT DISTINCT e.IDEXAMEN, e.TITULO
        FROM INTENTO_EXAMEN i
        INNER JOIN EXAMEN e ON e.IDEXAMEN = i.IDEXAMEN
        WHERE i.IDUSUARIO = p_IdSolicitante AND IFNULL(i.ESTADO, 0) = 1
        ORDER BY e.TITULO;
    ELSE
        SELECT e.IDEXAMEN, e.TITULO
        FROM EXAMEN e
        ORDER BY e.TITULO;
    END IF;

    IF v_EsEstudiante = 1 THEN
        SELECT IDAULA, NOMBRE FROM AULA WHERE 1 = 0;
    ELSE
        SELECT IDAULA, NOMBRE
        FROM AULA
        WHERE IFNULL(ACTIVO, 1) = 1
        ORDER BY NOMBRE;
    END IF;
END$$

DELIMITER ;

SELECT '7. Catalogo de resultados: lista todos los examenes.' AS info;
