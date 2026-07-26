/* ============================================================================
   Exámenes — flujo estudiante (listar / iniciar / pregunta / responder / finalizar)
   Ejecutar después de 2.usp_examen_crud.sql
   Fecha: 17/07/2026
   ============================================================================ */

/* Helper inline: ddmmyyyy + hora → DATETIME */
/* Uso: dbo no tiene fn; se repite patrón TRY_CONVERT */

IF OBJECT_ID('dbo.usp_examen_estudiante_listar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_examen_estudiante_listar;
GO
CREATE PROCEDURE dbo.usp_examen_estudiante_listar
    @IdUsuario NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    IF @IdUsuario IS NULL OR LTRIM(RTRIM(@IdUsuario)) = ''
    BEGIN
        SELECT CAST(NULL AS NVARCHAR(50)) AS IDEXAMEN WHERE 1 = 0;
        RETURN;
    END

    DECLARE @Ahora DATETIME = GETDATE();
    DECLARE @IdAula NVARCHAR(50) = NULL;

    SELECT TOP 1 @IdAula = m.IDAULA
    FROM MEMBRESIA m
    WHERE m.IDUSUARIO = @IdUsuario
      AND (m.ESTADOMIEMBRO IS NULL OR m.ESTADOMIEMBRO <> 3)
    ORDER BY m.FECHAREGISTRO DESC, m.IDMEMBRESIA DESC;

    ;WITH Base AS (
        SELECT
            e.IDEXAMEN,
            e.TITULO,
            e.DESCRIPCION,
            e.TIPO,
            e.DURACIONMIN,
            e.FECHAINICIO,
            e.FECHAFIN,
            e.HORAINICIO,
            e.HORAFIN,
            e.INTENTOSMAX,
            e.VISIBLE,
            ISNULL(e.TODASLASULA, 1) AS TODASLASULA,
            ISNULL(e.PUNTAJETOTAL, 0) AS PUNTAJETOTAL,
            (SELECT COUNT(*) FROM PREGUNTA p WHERE p.IDEXAMEN = e.IDEXAMEN) AS CANTPREGUNTAS,
            TRY_CONVERT(DATETIME,
                SUBSTRING(e.FECHAINICIO, 5, 4) + '-' + SUBSTRING(e.FECHAINICIO, 3, 2) + '-' + SUBSTRING(e.FECHAINICIO, 1, 2)
                + ' ' + LEFT(ISNULL(NULLIF(RTRIM(e.HORAINICIO), ''), '00:00:00') + '00', 8),
                120) AS DT_INICIO,
            TRY_CONVERT(DATETIME,
                SUBSTRING(e.FECHAFIN, 5, 4) + '-' + SUBSTRING(e.FECHAFIN, 3, 2) + '-' + SUBSTRING(e.FECHAFIN, 1, 2)
                + ' ' + LEFT(ISNULL(NULLIF(RTRIM(e.HORAFIN), ''), '23:59:59') + '00', 8),
                120) AS DT_FIN
        FROM EXAMEN e
        WHERE e.VISIBLE = 1
          AND (SELECT COUNT(*) FROM PREGUNTA p WHERE p.IDEXAMEN = e.IDEXAMEN) > 0
          AND (
                ISNULL(e.TODASLASULA, 1) = 1
                OR EXISTS (
                    SELECT 1 FROM EXAMEN_AULA ea
                    WHERE ea.IDEXAMEN = e.IDEXAMEN
                      AND ea.IDAULA = @IdAula
                )
              )
    )
    SELECT
        b.IDEXAMEN,
        b.TITULO,
        b.DESCRIPCION,
        b.TIPO,
        b.DURACIONMIN,
        b.FECHAINICIO,
        b.FECHAFIN,
        b.HORAINICIO,
        b.HORAFIN,
        b.INTENTOSMAX,
        b.CANTPREGUNTAS,
        b.PUNTAJETOTAL,
        CASE
            WHEN b.DT_INICIO IS NOT NULL AND @Ahora < b.DT_INICIO THEN 'proximamente'
            WHEN b.DT_FIN IS NOT NULL AND @Ahora > b.DT_FIN THEN 'cerrado'
            ELSE 'disponible'
        END AS ESTADOEXAMEN,
        ISNULL((
            SELECT COUNT(*)
            FROM INTENTO_EXAMEN i
            WHERE i.IDEXAMEN = b.IDEXAMEN
              AND i.IDUSUARIO = @IdUsuario
              AND ISNULL(i.ESTADO, 0) = 1
        ), 0) AS INTENTOSFINALIZADOS,
        (
            SELECT TOP 1 i.IDINTENTOEXAMEN
            FROM INTENTO_EXAMEN i
            WHERE i.IDEXAMEN = b.IDEXAMEN
              AND i.IDUSUARIO = @IdUsuario
              AND ISNULL(i.ESTADO, 0) = 0
            ORDER BY i.NUMEROINTENTO DESC
        ) AS IDINTENTOENCURSO,
        (
            SELECT TOP 1 i.PUNTAJEOBTENIDO
            FROM INTENTO_EXAMEN i
            WHERE i.IDEXAMEN = b.IDEXAMEN
              AND i.IDUSUARIO = @IdUsuario
              AND ISNULL(i.ESTADO, 0) = 1
            ORDER BY i.NUMEROINTENTO DESC
        ) AS ULTIMOPUNTAJE,
        CASE
            WHEN EXISTS (
                SELECT 1 FROM INTENTO_EXAMEN i
                WHERE i.IDEXAMEN = b.IDEXAMEN
                  AND i.IDUSUARIO = @IdUsuario
                  AND ISNULL(i.ESTADO, 0) = 0
            ) THEN 'continuar'
            WHEN (
                SELECT COUNT(*) FROM INTENTO_EXAMEN i
                WHERE i.IDEXAMEN = b.IDEXAMEN
                  AND i.IDUSUARIO = @IdUsuario
                  AND ISNULL(i.ESTADO, 0) = 1
            ) >= ISNULL(NULLIF(b.INTENTOSMAX, 0), 1)
            THEN 'agotado'
            WHEN b.DT_INICIO IS NOT NULL AND @Ahora < b.DT_INICIO THEN 'proximamente'
            WHEN b.DT_FIN IS NOT NULL AND @Ahora > b.DT_FIN THEN 'cerrado'
            ELSE 'desarrollar'
        END AS ACCION
    FROM Base b
    ORDER BY
        CASE
            WHEN b.DT_INICIO IS NOT NULL AND @Ahora < b.DT_INICIO THEN 2
            WHEN b.DT_FIN IS NOT NULL AND @Ahora > b.DT_FIN THEN 3
            ELSE 1
        END,
        b.DT_INICIO DESC,
        b.TITULO;
END;
GO

IF OBJECT_ID('dbo.usp_examen_intento_iniciar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_examen_intento_iniciar;
GO
CREATE PROCEDURE dbo.usp_examen_intento_iniciar
    @IdExamen     NVARCHAR(50),
    @IdUsuario    NVARCHAR(50),
    @IdIntento    NVARCHAR(50) OUTPUT,
    @Resultado    INT OUTPUT,
    @Mensaje      NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @IdIntento = NULL;
    SET @Resultado = 0;
    SET @Mensaje = 'Error desconocido.';

    IF @IdExamen IS NULL OR @IdUsuario IS NULL
    BEGIN SET @Mensaje = 'Datos incompletos.'; RETURN; END

    IF NOT EXISTS (SELECT 1 FROM USUARIO WHERE IDUSUARIO = @IdUsuario)
    BEGIN SET @Mensaje = 'Usuario no válido.'; RETURN; END

    DECLARE @Visible BIT, @Todas BIT, @IntentosMax INT, @Duracion INT;
    DECLARE @Fi CHAR(8), @Ff CHAR(8), @Hi CHAR(8), @Hf CHAR(8);

    SELECT
        @Visible = e.VISIBLE,
        @Todas = ISNULL(e.TODASLASULA, 1),
        @IntentosMax = ISNULL(NULLIF(e.INTENTOSMAX, 0), 1),
        @Duracion = e.DURACIONMIN,
        @Fi = e.FECHAINICIO,
        @Ff = e.FECHAFIN,
        @Hi = e.HORAINICIO,
        @Hf = e.HORAFIN
    FROM EXAMEN e
    WHERE e.IDEXAMEN = @IdExamen;

    IF @Visible IS NULL
    BEGIN SET @Mensaje = 'El examen no existe.'; RETURN; END

    IF @Visible <> 1
    BEGIN SET @Mensaje = 'El examen no está visible.'; RETURN; END

    IF NOT EXISTS (SELECT 1 FROM PREGUNTA WHERE IDEXAMEN = @IdExamen)
    BEGIN SET @Mensaje = 'El examen no tiene preguntas.'; RETURN; END

    DECLARE @IdAula NVARCHAR(50) = NULL;
    SELECT TOP 1 @IdAula = m.IDAULA
    FROM MEMBRESIA m
    WHERE m.IDUSUARIO = @IdUsuario
      AND (m.ESTADOMIEMBRO IS NULL OR m.ESTADOMIEMBRO <> 3)
    ORDER BY m.FECHAREGISTRO DESC, m.IDMEMBRESIA DESC;

    IF @Todas = 0 AND NOT EXISTS (
        SELECT 1 FROM EXAMEN_AULA ea
        WHERE ea.IDEXAMEN = @IdExamen AND ea.IDAULA = @IdAula
    )
    BEGIN SET @Mensaje = 'No tienes acceso a este examen (aula).'; RETURN; END

    DECLARE @Ahora DATETIME = GETDATE();
    DECLARE @DT_INICIO DATETIME = TRY_CONVERT(DATETIME,
        SUBSTRING(@Fi, 5, 4) + '-' + SUBSTRING(@Fi, 3, 2) + '-' + SUBSTRING(@Fi, 1, 2)
        + ' ' + LEFT(ISNULL(NULLIF(RTRIM(@Hi), ''), '00:00:00') + '00', 8), 120);
    DECLARE @DT_FIN DATETIME = TRY_CONVERT(DATETIME,
        SUBSTRING(@Ff, 5, 4) + '-' + SUBSTRING(@Ff, 3, 2) + '-' + SUBSTRING(@Ff, 1, 2)
        + ' ' + LEFT(ISNULL(NULLIF(RTRIM(@Hf), ''), '23:59:59') + '00', 8), 120);

    IF @DT_INICIO IS NOT NULL AND @Ahora < @DT_INICIO
    BEGIN SET @Mensaje = 'El examen aún no está disponible.'; RETURN; END
    IF @DT_FIN IS NOT NULL AND @Ahora > @DT_FIN
    BEGIN SET @Mensaje = 'El examen ya cerró.'; RETURN; END

    -- Reanudar intento en curso
    SELECT TOP 1 @IdIntento = i.IDINTENTOEXAMEN
    FROM INTENTO_EXAMEN i
    WHERE i.IDEXAMEN = @IdExamen
      AND i.IDUSUARIO = @IdUsuario
      AND ISNULL(i.ESTADO, 0) = 0
    ORDER BY i.NUMEROINTENTO DESC;

    IF @IdIntento IS NOT NULL
    BEGIN
        SET @Resultado = 1;
        SET @Mensaje = 'Intento en curso reanudado.';
        RETURN;
    END

    DECLARE @Finalizados INT = (
        SELECT COUNT(*) FROM INTENTO_EXAMEN
        WHERE IDEXAMEN = @IdExamen AND IDUSUARIO = @IdUsuario AND ISNULL(ESTADO, 0) = 1
    );
    IF @Finalizados >= @IntentosMax
    BEGIN SET @Mensaje = 'Ya usaste todos los intentos permitidos.'; RETURN; END

    DECLARE @Num INT = @Finalizados + 1;
    DECLARE @NextNum INT;
    SELECT @NextNum = ISNULL(MAX(TRY_CAST(REPLACE(IDINTENTOEXAMEN, 'INT', '') AS INT)), 0) + 1
    FROM INTENTO_EXAMEN WHERE IDINTENTOEXAMEN LIKE 'INT%';
    SET @IdIntento = 'INT' + RIGHT('00000' + CAST(@NextNum AS VARCHAR(5)), 5);

    INSERT INTO INTENTO_EXAMEN (
        IDINTENTOEXAMEN, NUMEROINTENTO,
        FECHAINICIO, HORAINICIO,
        PUNTAJEOBTENIDO, CANTCORRECTAS, CANTINCORRECTAS, CANTSINRESPONDER,
        ESTADO, APROBADO, IDEXAMEN, IDUSUARIO
    )
    VALUES (
        @IdIntento, @Num,
        dbo.fn_fecha_ddmmyyyy(), CONVERT(CHAR(8), GETDATE(), 108),
        NULL, 0, 0, 0,
        0, NULL, @IdExamen, @IdUsuario
    );

    SET @Resultado = 1;
    SET @Mensaje = 'Intento iniciado.';
END;
GO

IF OBJECT_ID('dbo.usp_examen_intento_estado', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_examen_intento_estado;
GO
CREATE PROCEDURE dbo.usp_examen_intento_estado
    @IdIntento NVARCHAR(50),
    @IdUsuario NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @IdExamen NVARCHAR(50), @Estado INT, @Duracion INT;
    DECLARE @Fi CHAR(8), @Hi CHAR(8);

    SELECT
        @IdExamen = i.IDEXAMEN,
        @Estado = ISNULL(i.ESTADO, 0),
        @Fi = i.FECHAINICIO,
        @Hi = i.HORAINICIO,
        @Duracion = e.DURACIONMIN
    FROM INTENTO_EXAMEN i
    INNER JOIN EXAMEN e ON e.IDEXAMEN = i.IDEXAMEN
    WHERE i.IDINTENTOEXAMEN = @IdIntento
      AND i.IDUSUARIO = @IdUsuario;

    IF @IdExamen IS NULL
    BEGIN
        SELECT CAST(0 AS INT) AS Resultado, 'Intento no encontrado.' AS Mensaje;
        RETURN;
    END

    DECLARE @Total INT = (SELECT COUNT(*) FROM PREGUNTA WHERE IDEXAMEN = @IdExamen);
    DECLARE @Respondidas INT = (
        SELECT COUNT(*) FROM RESPUESTA_ALUMNO WHERE IDINTENTOEXAMEN = @IdIntento
    );
    DECLARE @OrdenActual INT = @Respondidas + 1;
    IF @OrdenActual > @Total SET @OrdenActual = @Total;

    DECLARE @DT_INI DATETIME = TRY_CONVERT(DATETIME,
        SUBSTRING(@Fi, 5, 4) + '-' + SUBSTRING(@Fi, 3, 2) + '-' + SUBSTRING(@Fi, 1, 2)
        + ' ' + LEFT(ISNULL(NULLIF(RTRIM(@Hi), ''), '00:00:00') + '00', 8), 120);
    DECLARE @SegundosRestantes INT = NULL;
    IF @Duracion IS NOT NULL AND @DT_INI IS NOT NULL
        SET @SegundosRestantes = DATEDIFF(SECOND, GETDATE(), DATEADD(MINUTE, @Duracion, @DT_INI));

    -- Resultado 1
    SELECT
        1 AS Resultado,
        'OK' AS Mensaje,
        i.IDINTENTOEXAMEN,
        i.IDEXAMEN,
        i.NUMEROINTENTO,
        ISNULL(i.ESTADO, 0) AS ESTADO,
        i.FECHAINICIO,
        i.HORAINICIO,
        e.TITULO,
        e.TIPO,
        e.DURACIONMIN,
        @Total AS CANTPREGUNTAS,
        @Respondidas AS CANTRESPONDIDAS,
        @OrdenActual AS ORDENACTUAL,
        @SegundosRestantes AS SEGUNDOSRESTANTES,
        i.PUNTAJEOBTENIDO,
        i.CANTCORRECTAS,
        i.CANTINCORRECTAS,
        i.CANTSINRESPONDER,
        i.APROBADO
    FROM INTENTO_EXAMEN i
    INNER JOIN EXAMEN e ON e.IDEXAMEN = i.IDEXAMEN
    WHERE i.IDINTENTOEXAMEN = @IdIntento;

    -- Resultado 2: mapa de órdenes respondidos (para cuadrados)
    SELECT p.ORDEN, p.IDPREGUNTA
    FROM RESPUESTA_ALUMNO ra
    INNER JOIN PREGUNTA p ON p.IDPREGUNTA = ra.IDPREGUNTA
    WHERE ra.IDINTENTOEXAMEN = @IdIntento
    ORDER BY p.ORDEN;

    -- Resultado 3: pregunta actual (sin ESCORRECTA) si en curso
    IF @Estado = 0 AND @OrdenActual >= 1 AND @OrdenActual <= @Total AND @Respondidas < @Total
    BEGIN
        SELECT
            p.IDPREGUNTA,
            p.TITULO,
            p.DESCRIPCION,
            p.PUNTAJE,
            p.ORDEN,
            p.IMAGEURL,
            p.IDMATERIA,
            m.CODIGO AS MATERIA_CODIGO,
            m.NOMBRE AS MATERIA_NOMBRE
        FROM PREGUNTA p
        LEFT JOIN MATERIA m ON m.IDMATERIA = p.IDMATERIA
        WHERE p.IDEXAMEN = @IdExamen AND p.ORDEN = @OrdenActual;

        SELECT
            a.IDALTERNATIVA,
            a.DESCRIPCION,
            a.ORDEN,
            a.IMAGEURL
        FROM ALTERNATIVA a
        INNER JOIN PREGUNTA p ON p.IDPREGUNTA = a.IDPREGUNTA
        WHERE p.IDEXAMEN = @IdExamen AND p.ORDEN = @OrdenActual
        ORDER BY a.ORDEN, a.IDALTERNATIVA;
    END
    ELSE IF @Estado = 0 AND @Respondidas >= @Total
    BEGIN
        -- Todas respondidas: listo para finalizar (sin pregunta)
        SELECT CAST(NULL AS NVARCHAR(50)) AS IDPREGUNTA WHERE 1 = 0;
        SELECT CAST(NULL AS NVARCHAR(50)) AS IDALTERNATIVA WHERE 1 = 0;
    END
END;
GO

IF OBJECT_ID('dbo.usp_examen_intento_responder', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_examen_intento_responder;
GO
CREATE PROCEDURE dbo.usp_examen_intento_responder
    @IdIntento      NVARCHAR(50),
    @IdUsuario      NVARCHAR(50),
    @IdPregunta     NVARCHAR(50),
    @IdAlternativa  NVARCHAR(50),
    @Resultado      INT OUTPUT,
    @Mensaje        NVARCHAR(200) OUTPUT,
    @OrdenSiguiente INT OUTPUT,
    @EsUltima       BIT OUTPUT,
    @TiempoAgotado  BIT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje = 'Error desconocido.';
    SET @OrdenSiguiente = NULL;
    SET @EsUltima = 0;
    SET @TiempoAgotado = 0;

    DECLARE @IdExamen NVARCHAR(50), @Estado INT, @Duracion INT;
    DECLARE @Fi CHAR(8), @Hi CHAR(8);

    SELECT
        @IdExamen = i.IDEXAMEN,
        @Estado = ISNULL(i.ESTADO, 0),
        @Fi = i.FECHAINICIO,
        @Hi = i.HORAINICIO,
        @Duracion = e.DURACIONMIN
    FROM INTENTO_EXAMEN i
    INNER JOIN EXAMEN e ON e.IDEXAMEN = i.IDEXAMEN
    WHERE i.IDINTENTOEXAMEN = @IdIntento
      AND i.IDUSUARIO = @IdUsuario;

    IF @IdExamen IS NULL
    BEGIN SET @Mensaje = 'Intento no encontrado.'; RETURN; END

    IF @Estado <> 0
    BEGIN SET @Mensaje = 'El intento ya está finalizado.'; RETURN; END

    -- Timer
    DECLARE @DT_INI DATETIME = TRY_CONVERT(DATETIME,
        SUBSTRING(@Fi, 5, 4) + '-' + SUBSTRING(@Fi, 3, 2) + '-' + SUBSTRING(@Fi, 1, 2)
        + ' ' + LEFT(ISNULL(NULLIF(RTRIM(@Hi), ''), '00:00:00') + '00', 8), 120);
    IF @Duracion IS NOT NULL AND @DT_INI IS NOT NULL
       AND GETDATE() > DATEADD(MINUTE, @Duracion, @DT_INI)
    BEGIN
        SET @TiempoAgotado = 1;
        SET @Mensaje = 'Tiempo agotado.';
        SET @Resultado = 0;
        RETURN;
    END

    DECLARE @Total INT = (SELECT COUNT(*) FROM PREGUNTA WHERE IDEXAMEN = @IdExamen);
    DECLARE @Respondidas INT = (
        SELECT COUNT(*) FROM RESPUESTA_ALUMNO WHERE IDINTENTOEXAMEN = @IdIntento
    );
    DECLARE @OrdenActual INT = @Respondidas + 1;

    DECLARE @OrdenPreg INT, @IdPregOk NVARCHAR(50);
    SELECT @OrdenPreg = p.ORDEN, @IdPregOk = p.IDPREGUNTA
    FROM PREGUNTA p
    WHERE p.IDPREGUNTA = @IdPregunta AND p.IDEXAMEN = @IdExamen;

    IF @IdPregOk IS NULL
    BEGIN SET @Mensaje = 'Pregunta no válida.'; RETURN; END

    IF @OrdenPreg <> @OrdenActual
    BEGIN SET @Mensaje = 'No puedes responder esta pregunta (orden incorrecto).'; RETURN; END

    IF EXISTS (
        SELECT 1 FROM RESPUESTA_ALUMNO
        WHERE IDINTENTOEXAMEN = @IdIntento AND IDPREGUNTA = @IdPregunta
    )
    BEGIN SET @Mensaje = 'Esta pregunta ya fue respondida.'; RETURN; END

    IF NOT EXISTS (
        SELECT 1 FROM ALTERNATIVA
        WHERE IDALTERNATIVA = @IdAlternativa AND IDPREGUNTA = @IdPregunta
    )
    BEGIN SET @Mensaje = 'Alternativa no válida.'; RETURN; END

    DECLARE @IdResp NVARCHAR(50);
    DECLARE @NextNum INT;
    SELECT @NextNum = ISNULL(MAX(TRY_CAST(REPLACE(IDRESPUESTAALUMNO, 'RAL', '') AS INT)), 0) + 1
    FROM RESPUESTA_ALUMNO WHERE IDRESPUESTAALUMNO LIKE 'RAL%';
    SET @IdResp = 'RAL' + RIGHT('00000' + CAST(@NextNum AS VARCHAR(5)), 5);

    INSERT INTO RESPUESTA_ALUMNO (
        IDRESPUESTAALUMNO, PUNTAJEOBTENIDO, RESPABIERTA,
        IDINTENTOEXAMEN, IDPREGUNTA, IDALTERNATIVA
    )
    VALUES (@IdResp, NULL, NULL, @IdIntento, @IdPregunta, @IdAlternativa);

    SET @Respondidas = @Respondidas + 1;
    IF @Respondidas >= @Total
    BEGIN
        SET @EsUltima = 1;
        SET @OrdenSiguiente = @Total;
    END
    ELSE
    BEGIN
        SET @OrdenSiguiente = @Respondidas + 1;
        SET @EsUltima = 0;
    END

    SET @Resultado = 1;
    SET @Mensaje = 'Respuesta guardada.';
END;
GO

IF OBJECT_ID('dbo.usp_examen_intento_finalizar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_examen_intento_finalizar;
GO
CREATE PROCEDURE dbo.usp_examen_intento_finalizar
    @IdIntento  NVARCHAR(50),
    @IdUsuario  NVARCHAR(50),
    @Resultado  INT OUTPUT,
    @Mensaje    NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje = 'Error desconocido.';

    DECLARE @IdExamen NVARCHAR(50), @Estado INT;
    DECLARE @PuntajeAprobado DECIMAL(6,2);

    SELECT
        @IdExamen = i.IDEXAMEN,
        @Estado = ISNULL(i.ESTADO, 0),
        @PuntajeAprobado = e.PUNTAJEAPROBADO
    FROM INTENTO_EXAMEN i
    INNER JOIN EXAMEN e ON e.IDEXAMEN = i.IDEXAMEN
    WHERE i.IDINTENTOEXAMEN = @IdIntento
      AND i.IDUSUARIO = @IdUsuario;

    IF @IdExamen IS NULL
    BEGIN SET @Mensaje = 'Intento no encontrado.'; RETURN; END

    IF @Estado = 1
    BEGIN
        SET @Resultado = 1;
        SET @Mensaje = 'El intento ya estaba finalizado.';
        -- Devolver resumen existente
        SELECT
            i.IDINTENTOEXAMEN,
            i.IDEXAMEN,
            e.TITULO,
            i.PUNTAJEOBTENIDO,
            i.CANTCORRECTAS,
            i.CANTINCORRECTAS,
            i.CANTSINRESPONDER,
            i.APROBADO,
            (SELECT COUNT(*) FROM PREGUNTA WHERE IDEXAMEN = @IdExamen) AS CANTPREGUNTAS,
            ISNULL(e.PUNTAJETOTAL, 0) AS PUNTAJETOTAL
        FROM INTENTO_EXAMEN i
        INNER JOIN EXAMEN e ON e.IDEXAMEN = i.IDEXAMEN
        WHERE i.IDINTENTOEXAMEN = @IdIntento;
        RETURN;
    END

    DECLARE @Total INT = (SELECT COUNT(*) FROM PREGUNTA WHERE IDEXAMEN = @IdExamen);

    -- Puntuar respuestas
    UPDATE ra
    SET ra.PUNTAJEOBTENIDO = CASE
            WHEN ISNULL(a.ESCORRECTA, 0) = 1 THEN ISNULL(p.PUNTAJE, 1)
            ELSE 0
        END
    FROM RESPUESTA_ALUMNO ra
    INNER JOIN PREGUNTA p ON p.IDPREGUNTA = ra.IDPREGUNTA
    LEFT JOIN ALTERNATIVA a ON a.IDALTERNATIVA = ra.IDALTERNATIVA
    WHERE ra.IDINTENTOEXAMEN = @IdIntento;

    DECLARE @Correctas INT = (
        SELECT COUNT(*)
        FROM RESPUESTA_ALUMNO ra
        INNER JOIN ALTERNATIVA a ON a.IDALTERNATIVA = ra.IDALTERNATIVA
        WHERE ra.IDINTENTOEXAMEN = @IdIntento AND ISNULL(a.ESCORRECTA, 0) = 1
    );
    DECLARE @Respondidas INT = (
        SELECT COUNT(*) FROM RESPUESTA_ALUMNO WHERE IDINTENTOEXAMEN = @IdIntento
    );
    DECLARE @Incorrectas INT = @Respondidas - @Correctas;
    DECLARE @SinResp INT = @Total - @Respondidas;
    IF @SinResp < 0 SET @SinResp = 0;

    DECLARE @Puntaje DECIMAL(6,2) = (
        SELECT ISNULL(SUM(ra.PUNTAJEOBTENIDO), 0)
        FROM RESPUESTA_ALUMNO ra
        WHERE ra.IDINTENTOEXAMEN = @IdIntento
    );

    -- Si no hay puntaje por pregunta, usar 1 punto por correcta
    IF NOT EXISTS (SELECT 1 FROM PREGUNTA WHERE IDEXAMEN = @IdExamen AND ISNULL(PUNTAJE, 0) > 0)
        SET @Puntaje = CAST(@Correctas AS DECIMAL(6,2));

    DECLARE @Aprobado BIT = 0;
    IF @PuntajeAprobado IS NOT NULL AND @Puntaje >= @PuntajeAprobado
        SET @Aprobado = 1;
    ELSE IF @PuntajeAprobado IS NULL AND @Total > 0 AND @Correctas >= CEILING(@Total * 0.5)
        SET @Aprobado = 1;

    UPDATE INTENTO_EXAMEN SET
        FECHAFIN = dbo.fn_fecha_ddmmyyyy(),
        HORAFIN = CONVERT(CHAR(8), GETDATE(), 108),
        PUNTAJEOBTENIDO = @Puntaje,
        CANTCORRECTAS = @Correctas,
        CANTINCORRECTAS = @Incorrectas,
        CANTSINRESPONDER = @SinResp,
        ESTADO = 1,
        APROBADO = @Aprobado
    WHERE IDINTENTOEXAMEN = @IdIntento;

    SET @Resultado = 1;
    SET @Mensaje = 'Examen enviado.';

    SELECT
        i.IDINTENTOEXAMEN,
        i.IDEXAMEN,
        e.TITULO,
        i.PUNTAJEOBTENIDO,
        i.CANTCORRECTAS,
        i.CANTINCORRECTAS,
        i.CANTSINRESPONDER,
        i.APROBADO,
        @Total AS CANTPREGUNTAS,
        ISNULL(e.PUNTAJETOTAL, @Total) AS PUNTAJETOTAL
    FROM INTENTO_EXAMEN i
    INNER JOIN EXAMEN e ON e.IDEXAMEN = i.IDEXAMEN
    WHERE i.IDINTENTOEXAMEN = @IdIntento;
END;
GO

PRINT 'usp_examen_estudiante (listar/iniciar/estado/responder/finalizar) listo.';
GO
