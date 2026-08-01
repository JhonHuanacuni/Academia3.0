-- Convertido automáticamente desde db_scripts/31_07_2026/8.usp_examen_ranking_aula.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   Ranking del último examen realizado en el aula del estudiante
   Ejecutar después de scripts de exámenes (17_07_2026)
   Fecha: 31/07/2026
   ============================================================================ */

DROP PROCEDURE IF EXISTS usp_examen_ranking_aula;

DROP PROCEDURE IF EXISTS usp_examen_ranking_aula;

DELIMITER $$

CREATE PROCEDURE usp_examen_ranking_aula(
    IN p_IdUsuario VARCHAR(50)
)
main: BEGIN
DECLARE v_IdAula VARCHAR(50);
    DECLARE v_IdExamen VARCHAR(50);
    DECLARE v_TotalPreg INT;

    SELECT TOP 1 v_IdAula = m.IDAULA
    FROM MENSUALIDAD m
    WHERE m.IDUSUARIO = p_IdUsuario
      AND IFNULL(m.ESTADO, 'Activo') = 'Activo'
      AND (m.ESTADOMIEMBRO IS NULL OR m.ESTADOMIEMBRO <> 3)
    ORDER BY m.FECHAREGISTRO DESC, m.IDMENSUALIDAD DESC;

    IF v_IdAula IS NULL THEN
        SELECT CAST(NULL AS CHAR(50)) AS IDEXAMEN WHERE 1 = 0;
        SELECT CAST(NULL AS INT) AS POSICION WHERE 1 = 0;
        LEAVE main;
    
    SELECT TOP 1 v_IdExamen = i.IDEXAMEN
    FROM INTENTO_EXAMEN i
    INNER JOIN (
        SELECT um.IDUSUARIO
        FROM (
            SELECT m.IDUSUARIO, m.IDAULA,
                ROW_NUMBER() OVER (
                    PARTITION BY m.IDUSUARIO
                    ORDER BY m.FECHAREGISTRO DESC, m.IDMENSUALIDAD DESC
                ) AS RN
            FROM MENSUALIDAD m
            WHERE IFNULL(m.ESTADO, 'Activo') = 'Activo'
              AND (m.ESTADOMIEMBRO IS NULL OR m.ESTADOMIEMBRO <> 3)
        ) um
        WHERE um.RN = 1 AND um.IDAULA = v_IdAula
    ) aa ON aa.IDUSUARIO = i.IDUSUARIO
    WHERE IFNULL(i.ESTADO, 0) = 1
      AND i.FECHAFIN IS NOT NULL AND LEN(i.FECHAFIN) = 8
    ORDER BY
        CONCAT(TRY_CONVERT(DATETIME,
            SUBSTRING(i.FECHAFIN, 5, 4), '-') + CONCAT(SUBSTRING(i.FECHAFIN, 3, 2), '-') + CONCAT(SUBSTRING(i.FECHAFIN, 1, 2), ' ') + LEFT(IFNULL(NULLIF(RTRIM(i.HORAFIN), ''), '00:00:00') + '00', 8),
            120) DESC,
        i.IDINTENTOEXAMEN DESC;

    IF v_IdExamen IS NULL THEN
        SELECT
            CAST(NULL AS CHAR(50)) AS IDEXAMEN,
            CAST(NULL AS CHAR(200)) AS TITULO,
            CAST(NULL AS DECIMAL(6,2)) AS PUNTAJETOTAL,
            au.NOMBRE AS AULA_NOMBRE,
            v_IdAula AS IDAULA
        FROM AULA au
        WHERE au.IDAULA = v_IdAula;

        SELECT CAST(NULL AS INT) AS POSICION WHERE 1 = 0;
        LEAVE main;
    
    SELECT COUNT(*) FROM PREGUNTA WHERE IDEXAMEN = v_IdExamen INTO v_TotalPreg;
    IF v_TotalPreg < 1 THEN SET v_TotalPreg = 1; END IF;

    SELECT
        e.IDEXAMEN,
        e.TITULO,
        IFNULL(e.PUNTAJETOTAL, 0) AS PUNTAJETOTAL,
        au.NOMBRE AS AULA_NOMBRE,
        v_IdAula AS IDAULA,
        v_TotalPreg AS TOTALPREGUNTAS
    FROM EXAMEN e
    CROSS JOIN AULA au
    WHERE e.IDEXAMEN = v_IdExamen AND au.IDAULA = v_IdAula;

    ;WITH AlumnosAula AS (
        SELECT um.IDUSUARIO
        FROM (
            SELECT m.IDUSUARIO, m.IDAULA,
                ROW_NUMBER() OVER (
                    PARTITION BY m.IDUSUARIO
                    ORDER BY m.FECHAREGISTRO DESC, m.IDMENSUALIDAD DESC
                ) AS RN
            FROM MENSUALIDAD m
            WHERE IFNULL(m.ESTADO, 'Activo') = 'Activo'
              AND (m.ESTADOMIEMBRO IS NULL OR m.ESTADOMIEMBRO <> 3)
        ) um
        WHERE um.RN = 1 AND um.IDAULA = v_IdAula
    ),
    MejorIntento AS (
        SELECT
            i.IDUSUARIO,
            i.PUNTAJEOBTENIDO,
            i.CANTCORRECTAS,
            i.CANTINCORRECTAS,
            i.CANTSINRESPONDER,
            i.APROBADO,
            ROW_NUMBER() OVER (
                PARTITION BY i.IDUSUARIO
                ORDER BY i.PUNTAJEOBTENIDO DESC, i.NUMEROINTENTO DESC, i.IDINTENTOEXAMEN DESC
            ) AS RN
        FROM INTENTO_EXAMEN i
        WHERE i.IDEXAMEN = v_IdExamen AND IFNULL(i.ESTADO, 0) = 1
    ),
    RankingBase AS (
        SELECT
            u.IDUSUARIO,
            u.DNI,
            UPPER(TRIM(CONCAT(IFNULL(u.APELLIDO, ''), ' ') + IFNULL(u.NOMBRE, '')))) AS NOMBRE_COMPLETO,
            mi.PUNTAJEOBTENIDO,
            mi.CANTCORRECTAS,
            mi.CANTINCORRECTAS,
            mi.CANTSINRESPONDER,
            mi.APROBADO,
            CASE WHEN u.IDUSUARIO = p_IdUsuario THEN 1 ELSE 0 END AS ES_YO,
            CASE WHEN mi.PUNTAJEOBTENIDO IS NULL THEN 1 ELSE 0 END AS SIN_EXAMEN
        FROM AlumnosAula aa
        INNER JOIN USUARIO u ON u.IDUSUARIO = aa.IDUSUARIO
        LEFT JOIN MejorIntento mi ON mi.IDUSUARIO = aa.IDUSUARIO AND mi.RN = 1
    )
    SELECT
        ROW_NUMBER() OVER (
            ORDER BY SIN_EXAMEN ASC, PUNTAJEOBTENIDO DESC, CANTCORRECTAS DESC, NOMBRE_COMPLETO
        ) AS POSICION,
        IDUSUARIO,
        DNI,
        NOMBRE_COMPLETO,
        PUNTAJEOBTENIDO,
        CANTCORRECTAS,
        CANTINCORRECTAS,
        CANTSINRESPONDER,
        APROBADO,
        ES_YO,
        CAST(ROUND(CAST(IFNULL(CANTCORRECTAS, 0) AS FLOAT) / v_TotalPreg * 100, 1) AS DECIMAL(5,1)) AS PCT_CORRECTAS,
        CAST(ROUND(CAST(IFNULL(CANTINCORRECTAS, 0) AS FLOAT) / v_TotalPreg * 100, 1) AS DECIMAL(5,1)) AS PCT_ERRORES,
        CAST(ROUND(CAST(IFNULL(CANTSINRESPONDER, 0) AS FLOAT) / v_TotalPreg * 100, 1) AS DECIMAL(5,1)) AS PCT_BLANCO
    FROM RankingBase
    ORDER BY POSICION;
END;

SELECT 'usp_examen_ranking_aula creado.';
END$$

DELIMITER ;