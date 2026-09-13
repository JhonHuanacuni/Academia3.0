-- ============================================================================
-- 2. usp_examen_resultados_listar
-- Fecha: 13/09/2026
-- phpMyAdmin: selecciona tu BD, pega TODO y ejecuta
-- ============================================================================

DROP PROCEDURE IF EXISTS usp_examen_resultados_listar;

DELIMITER $$

CREATE PROCEDURE usp_examen_resultados_listar(
    IN p_IdSolicitante VARCHAR(50),
    IN p_Buscar VARCHAR(200),
    IN p_IdExamen VARCHAR(50),
    IN p_IdAula VARCHAR(50),
    IN p_Pagina INT,
    IN p_Tamanio INT
)
main: BEGIN
    DECLARE v_EsEstudiante TINYINT DEFAULT 0;
    DECLARE v_Offset INT DEFAULT 0;
    DECLARE v_Total INT DEFAULT 0;

    IF p_IdSolicitante IS NULL OR TRIM(p_IdSolicitante) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Falta idusuario';
    END IF;

    IF p_Pagina IS NULL OR p_Pagina < 1 THEN SET p_Pagina = 1; END IF;
    IF p_Tamanio IS NULL OR p_Tamanio < 5 THEN SET p_Tamanio = 20; END IF;
    IF p_Tamanio > 100 THEN SET p_Tamanio = 100; END IF;
    SET v_Offset = (p_Pagina - 1) * p_Tamanio;

    SELECT IF(IDTIPOUSUARIO = '1', 1, 0) INTO v_EsEstudiante
    FROM USUARIO WHERE IDUSUARIO = p_IdSolicitante LIMIT 1;

    IF v_EsEstudiante IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Usuario no encontrado';
    END IF;

    SELECT COUNT(*) INTO v_Total
    FROM INTENTO_EXAMEN i
    INNER JOIN EXAMEN e ON e.IDEXAMEN = i.IDEXAMEN
    INNER JOIN USUARIO u ON u.IDUSUARIO = i.IDUSUARIO
    WHERE IFNULL(i.ESTADO, 0) = 1
      AND (v_EsEstudiante = 0 OR i.IDUSUARIO = p_IdSolicitante)
      AND (p_IdExamen IS NULL OR p_IdExamen = '' OR i.IDEXAMEN = p_IdExamen)
      AND (
          p_IdAula IS NULL OR p_IdAula = '' OR
          IFNULL(e.TODASLASULA, 1) = 1 OR
          EXISTS (SELECT 1 FROM EXAMEN_AULA ea WHERE ea.IDEXAMEN = e.IDEXAMEN AND ea.IDAULA = p_IdAula) OR
          EXISTS (
              SELECT 1 FROM MENSUALIDAD m
              WHERE m.IDUSUARIO = i.IDUSUARIO
                AND m.IDAULA = p_IdAula
                AND (m.ESTADO IS NULL OR m.ESTADO = 'Activo')
          )
      )
      AND (
          p_Buscar IS NULL OR p_Buscar = '' OR
          u.DNI LIKE CONCAT('%', p_Buscar, '%') OR
          u.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
          u.APELLIDO LIKE CONCAT('%', p_Buscar, '%') OR
          e.TITULO LIKE CONCAT('%', p_Buscar, '%') OR
          i.IDINTENTOEXAMEN LIKE CONCAT('%', p_Buscar, '%')
      );

    SELECT v_Total AS TOTAL, p_Pagina AS PAGINA, p_Tamanio AS TAMANIOPAGINA, v_EsEstudiante AS SOLOPROPIOS;

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
        IFNULL(e.PUNTAJETOTAL, 0) AS PUNTAJETOTAL,
        e.PUNTAJEAPROBADO,
        (
            SELECT au.NOMBRE
            FROM MENSUALIDAD m
            LEFT JOIN AULA au ON au.IDAULA = m.IDAULA
            WHERE m.IDUSUARIO = i.IDUSUARIO
              AND (m.ESTADO IS NULL OR m.ESTADO = 'Activo')
            ORDER BY m.FECHAREGISTRO DESC
            LIMIT 1
        ) AS AULA
    FROM INTENTO_EXAMEN i
    INNER JOIN EXAMEN e ON e.IDEXAMEN = i.IDEXAMEN
    INNER JOIN USUARIO u ON u.IDUSUARIO = i.IDUSUARIO
    WHERE IFNULL(i.ESTADO, 0) = 1
      AND (v_EsEstudiante = 0 OR i.IDUSUARIO = p_IdSolicitante)
      AND (p_IdExamen IS NULL OR p_IdExamen = '' OR i.IDEXAMEN = p_IdExamen)
      AND (
          p_IdAula IS NULL OR p_IdAula = '' OR
          IFNULL(e.TODASLASULA, 1) = 1 OR
          EXISTS (SELECT 1 FROM EXAMEN_AULA ea WHERE ea.IDEXAMEN = e.IDEXAMEN AND ea.IDAULA = p_IdAula) OR
          EXISTS (
              SELECT 1 FROM MENSUALIDAD m
              WHERE m.IDUSUARIO = i.IDUSUARIO
                AND m.IDAULA = p_IdAula
                AND (m.ESTADO IS NULL OR m.ESTADO = 'Activo')
          )
      )
      AND (
          p_Buscar IS NULL OR p_Buscar = '' OR
          u.DNI LIKE CONCAT('%', p_Buscar, '%') OR
          u.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
          u.APELLIDO LIKE CONCAT('%', p_Buscar, '%') OR
          e.TITULO LIKE CONCAT('%', p_Buscar, '%') OR
          i.IDINTENTOEXAMEN LIKE CONCAT('%', p_Buscar, '%')
      )
    ORDER BY
        STR_TO_DATE(IFNULL(i.FECHAFIN, i.FECHAINICIO), '%d%m%Y') DESC,
        IFNULL(i.HORAFIN, i.HORAINICIO) DESC,
        i.IDINTENTOEXAMEN DESC
    LIMIT p_Tamanio OFFSET v_Offset;
END$$

DELIMITER ;

SELECT '2. usp_examen_resultados_listar listo.' AS info;
