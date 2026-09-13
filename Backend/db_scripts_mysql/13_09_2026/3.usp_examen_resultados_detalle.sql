-- ============================================================================
-- 3. usp_examen_resultados_detalle
-- Fecha: 13/09/2026
-- phpMyAdmin: selecciona tu BD, pega TODO y ejecuta
-- ============================================================================

DROP PROCEDURE IF EXISTS usp_examen_resultados_detalle;

DELIMITER $$

CREATE PROCEDURE usp_examen_resultados_detalle(
    IN p_IdIntento VARCHAR(50),
    IN p_IdSolicitante VARCHAR(50)
)
main: BEGIN
    DECLARE v_EsEstudiante TINYINT DEFAULT 0;
    DECLARE v_IdUsuarioIntento VARCHAR(50);
    DECLARE v_IdExamen VARCHAR(50);
    DECLARE v_Estado INT DEFAULT 0;

    IF p_IdIntento IS NULL OR TRIM(p_IdIntento) = '' OR p_IdSolicitante IS NULL OR TRIM(p_IdSolicitante) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Faltan idintento o idusuario';
    END IF;

    SELECT IF(IDTIPOUSUARIO = '1', 1, 0) INTO v_EsEstudiante
    FROM USUARIO WHERE IDUSUARIO = p_IdSolicitante LIMIT 1;

    SELECT i.IDUSUARIO, i.IDEXAMEN, IFNULL(i.ESTADO, 0)
    INTO v_IdUsuarioIntento, v_IdExamen, v_Estado
    FROM INTENTO_EXAMEN i
    WHERE i.IDINTENTOEXAMEN = p_IdIntento
    LIMIT 1;

    IF v_IdExamen IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Resultado no encontrado';
    END IF;

    IF v_EsEstudiante = 1 AND v_IdUsuarioIntento <> p_IdSolicitante THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No tienes permiso para ver este resultado';
    END IF;

    IF v_Estado <> 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El intento aun no esta finalizado';
    END IF;

    SELECT
        i.IDINTENTOEXAMEN,
        i.IDEXAMEN,
        e.TITULO AS EXAMEN,
        i.IDUSUARIO,
        UPPER(TRIM(CONCAT(IFNULL(u.APELLIDO, ''), ' ', IFNULL(u.NOMBRE, '')))) AS ESTUDIANTE,
        u.DNI,
        i.NUMEROINTENTO,
        i.FECHAINICIO,
        i.HORAINICIO,
        i.FECHAFIN,
        i.HORAFIN,
        i.PUNTAJEOBTENIDO,
        i.CANTCORRECTAS,
        i.CANTINCORRECTAS,
        i.CANTSINRESPONDER,
        i.APROBADO,
        IFNULL(i.ESTADO, 0) AS ESTADO,
        IFNULL(e.PUNTAJETOTAL, 0) AS PUNTAJETOTAL,
        e.PUNTAJEAPROBADO,
        v_EsEstudiante AS SOLOPROPIOS
    FROM INTENTO_EXAMEN i
    INNER JOIN EXAMEN e ON e.IDEXAMEN = i.IDEXAMEN
    INNER JOIN USUARIO u ON u.IDUSUARIO = i.IDUSUARIO
    WHERE i.IDINTENTOEXAMEN = p_IdIntento;

    SELECT
        p.IDPREGUNTA,
        p.ORDEN,
        p.TITULO,
        p.DESCRIPCION,
        p.IMAGEURL,
        IFNULL(p.PUNTAJE, 1) AS PUNTAJE,
        m.NOMBRE AS MATERIA,
        ra.IDALTERNATIVA AS IDALTERNATIVA_ELEGIDA,
        ra.PUNTAJEOBTENIDO AS PUNTAJE_OBTENIDO,
        ae.DESCRIPCION AS RESPUESTA_ELEGIDA,
        ae.IMAGEURL AS RESPUESTA_ELEGIDA_IMG,
        IFNULL(ae.ESCORRECTA, 0) AS ELEGIDA_CORRECTA,
        ac.IDALTERNATIVA AS IDALTERNATIVA_CORRECTA,
        ac.DESCRIPCION AS RESPUESTA_CORRECTA,
        ac.IMAGEURL AS RESPUESTA_CORRECTA_IMG
    FROM PREGUNTA p
    LEFT JOIN MATERIA m ON m.IDMATERIA = p.IDMATERIA
    LEFT JOIN RESPUESTA_ALUMNO ra
        ON ra.IDPREGUNTA = p.IDPREGUNTA AND ra.IDINTENTOEXAMEN = p_IdIntento
    LEFT JOIN ALTERNATIVA ae ON ae.IDALTERNATIVA = ra.IDALTERNATIVA
    LEFT JOIN ALTERNATIVA ac
        ON ac.IDPREGUNTA = p.IDPREGUNTA AND IFNULL(ac.ESCORRECTA, 0) = 1
    WHERE p.IDEXAMEN = v_IdExamen
    ORDER BY IFNULL(p.ORDEN, 9999), p.IDPREGUNTA;
END$$

DELIMITER ;

SELECT '3. usp_examen_resultados_detalle listo.' AS info;
