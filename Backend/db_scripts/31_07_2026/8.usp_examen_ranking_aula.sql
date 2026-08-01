/* ============================================================================
   Ranking del último examen realizado en el aula del estudiante
   Ejecutar después de scripts de exámenes (17_07_2026)
   Fecha: 31/07/2026
   ============================================================================ */

SET QUOTED_IDENTIFIER ON;
GO
SET ANSI_NULLS ON;
GO

IF OBJECT_ID('dbo.usp_examen_ranking_aula', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_examen_ranking_aula;
GO

SET QUOTED_IDENTIFIER ON;
GO
SET ANSI_NULLS ON;
GO

CREATE PROCEDURE dbo.usp_examen_ranking_aula
    @IdUsuario NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @IdAula NVARCHAR(50);
    DECLARE @IdExamen NVARCHAR(50);
    DECLARE @TotalPreg INT;

    SELECT TOP 1 @IdAula = m.IDAULA
    FROM MENSUALIDAD m
    WHERE m.IDUSUARIO = @IdUsuario
      AND ISNULL(m.ESTADO, 'Activo') = 'Activo'
      AND (m.ESTADOMIEMBRO IS NULL OR m.ESTADOMIEMBRO <> 3)
    ORDER BY m.FECHAREGISTRO DESC, m.IDMENSUALIDAD DESC;

    IF @IdAula IS NULL
    BEGIN
        SELECT CAST(NULL AS NVARCHAR(50)) AS IDEXAMEN WHERE 1 = 0;
        SELECT CAST(NULL AS INT) AS POSICION WHERE 1 = 0;
        RETURN;
    END

    SELECT TOP 1 @IdExamen = i.IDEXAMEN
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
            WHERE ISNULL(m.ESTADO, 'Activo') = 'Activo'
              AND (m.ESTADOMIEMBRO IS NULL OR m.ESTADOMIEMBRO <> 3)
        ) um
        WHERE um.RN = 1 AND um.IDAULA = @IdAula
    ) aa ON aa.IDUSUARIO = i.IDUSUARIO
    WHERE ISNULL(i.ESTADO, 0) = 1
      AND i.FECHAFIN IS NOT NULL AND LEN(i.FECHAFIN) = 8
    ORDER BY
        TRY_CONVERT(DATETIME,
            SUBSTRING(i.FECHAFIN, 5, 4) + '-' + SUBSTRING(i.FECHAFIN, 3, 2) + '-' + SUBSTRING(i.FECHAFIN, 1, 2)
            + ' ' + LEFT(ISNULL(NULLIF(RTRIM(i.HORAFIN), ''), '00:00:00') + '00', 8),
            120) DESC,
        i.IDINTENTOEXAMEN DESC;

    IF @IdExamen IS NULL
    BEGIN
        SELECT
            CAST(NULL AS NVARCHAR(50)) AS IDEXAMEN,
            CAST(NULL AS NVARCHAR(200)) AS TITULO,
            CAST(NULL AS DECIMAL(6,2)) AS PUNTAJETOTAL,
            au.NOMBRE AS AULA_NOMBRE,
            @IdAula AS IDAULA
        FROM AULA au
        WHERE au.IDAULA = @IdAula;

        SELECT CAST(NULL AS INT) AS POSICION WHERE 1 = 0;
        RETURN;
    END

    SELECT @TotalPreg = COUNT(*) FROM PREGUNTA WHERE IDEXAMEN = @IdExamen;
    IF @TotalPreg < 1 SET @TotalPreg = 1;

    SELECT
        e.IDEXAMEN,
        e.TITULO,
        ISNULL(e.PUNTAJETOTAL, 0) AS PUNTAJETOTAL,
        au.NOMBRE AS AULA_NOMBRE,
        @IdAula AS IDAULA,
        @TotalPreg AS TOTALPREGUNTAS
    FROM EXAMEN e
    CROSS JOIN AULA au
    WHERE e.IDEXAMEN = @IdExamen AND au.IDAULA = @IdAula;

    ;WITH AlumnosAula AS (
        SELECT um.IDUSUARIO
        FROM (
            SELECT m.IDUSUARIO, m.IDAULA,
                ROW_NUMBER() OVER (
                    PARTITION BY m.IDUSUARIO
                    ORDER BY m.FECHAREGISTRO DESC, m.IDMENSUALIDAD DESC
                ) AS RN
            FROM MENSUALIDAD m
            WHERE ISNULL(m.ESTADO, 'Activo') = 'Activo'
              AND (m.ESTADOMIEMBRO IS NULL OR m.ESTADOMIEMBRO <> 3)
        ) um
        WHERE um.RN = 1 AND um.IDAULA = @IdAula
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
        WHERE i.IDEXAMEN = @IdExamen AND ISNULL(i.ESTADO, 0) = 1
    ),
    RankingBase AS (
        SELECT
            u.IDUSUARIO,
            u.DNI,
            UPPER(LTRIM(RTRIM(ISNULL(u.APELLIDO, '') + ' ' + ISNULL(u.NOMBRE, '')))) AS NOMBRE_COMPLETO,
            mi.PUNTAJEOBTENIDO,
            mi.CANTCORRECTAS,
            mi.CANTINCORRECTAS,
            mi.CANTSINRESPONDER,
            mi.APROBADO,
            CASE WHEN u.IDUSUARIO = @IdUsuario THEN 1 ELSE 0 END AS ES_YO,
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
        CAST(ROUND(CAST(ISNULL(CANTCORRECTAS, 0) AS FLOAT) / @TotalPreg * 100, 1) AS DECIMAL(5,1)) AS PCT_CORRECTAS,
        CAST(ROUND(CAST(ISNULL(CANTINCORRECTAS, 0) AS FLOAT) / @TotalPreg * 100, 1) AS DECIMAL(5,1)) AS PCT_ERRORES,
        CAST(ROUND(CAST(ISNULL(CANTSINRESPONDER, 0) AS FLOAT) / @TotalPreg * 100, 1) AS DECIMAL(5,1)) AS PCT_BLANCO
    FROM RankingBase
    ORDER BY POSICION;
END;
GO

PRINT 'usp_examen_ranking_aula creado.';
GO
