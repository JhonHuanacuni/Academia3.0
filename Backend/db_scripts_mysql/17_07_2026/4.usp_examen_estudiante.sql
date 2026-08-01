-- Convertido automáticamente desde db_scripts/17_07_2026/4.usp_examen_estudiante.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   Exámenes — flujo estudiante (listar / iniciar / pregunta / responder / finalizar)
   Ejecutar después de 2.usp_examen_crud.sql
   Fecha: 17/07/2026
   ============================================================================ */

/* Helper inline: CONCAT(ddmmyyyy, hora) → DATETIME */
/* Uso: dbo no tiene fn; se repite patrón TRY_CONVERT */

DROP PROCEDURE IF EXISTS usp_examen_estudiante_listar;

DROP PROCEDURE IF EXISTS usp_examen_estudiante_listar;

DELIMITER $$

CREATE PROCEDURE usp_examen_estudiante_listar(
    IN p_IdUsuario VARCHAR(50)
)
main: BEGIN
IF p_IdUsuario IS NULL OR TRIM(p_IdUsuario) = '' THEN
        SELECT CAST(NULL AS CHAR(50)) AS IDEXAMEN WHERE 1 = 0;
        LEAVE main;
    
    DECLARE v_Ahora DATETIME = NOW();
    DECLARE v_IdAula VARCHAR(50) = NULL;

    SELECT TOP 1 v_IdAula = m.IDAULA
    FROM MEMBRESIA m
    WHERE m.IDUSUARIO = p_IdUsuario
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
            IFNULL(e.TODASLASULA, 1) AS TODASLASULA,
            IFNULL(e.PUNTAJETOTAL, 0) AS PUNTAJETOTAL,
            (SELECT COUNT(*) FROM PREGUNTA p WHERE p.IDEXAMEN = e.IDEXAMEN) AS CANTPREGUNTAS,
            CONCAT(TRY_CONVERT(DATETIME,
                SUBSTRING(e.FECHAINICIO, 5, 4), '-') + CONCAT(SUBSTRING(e.FECHAINICIO, 3, 2), '-') + CONCAT(SUBSTRING(e.FECHAINICIO, 1, 2), ' ') + LEFT(IFNULL(NULLIF(RTRIM(e.HORAINICIO), ''), '00:00:00') + '00', 8),
                120) AS DT_INICIO,
            CONCAT(TRY_CONVERT(DATETIME,
                SUBSTRING(e.FECHAFIN, 5, 4), '-') + CONCAT(SUBSTRING(e.FECHAFIN, 3, 2), '-') + CONCAT(SUBSTRING(e.FECHAFIN, 1, 2), ' ') + LEFT(IFNULL(NULLIF(RTRIM(e.HORAFIN), ''), '23:59:59') + '00', 8),
                120) AS DT_FIN
        FROM EXAMEN e
        WHERE e.VISIBLE = 1
          AND (SELECT COUNT(*) FROM PREGUNTA p WHERE p.IDEXAMEN = e.IDEXAMEN) > 0
          AND (
                IFNULL(e.TODASLASULA, 1) = 1
                OR EXISTS (
                    SELECT 1 FROM EXAMEN_AULA ea
                    WHERE ea.IDEXAMEN = e.IDEXAMEN
                      AND ea.IDAULA = v_IdAula
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
            WHEN b.DT_INICIO IS NOT NULL AND v_Ahora < b.DT_INICIO THEN 'proximamente'
            WHEN b.DT_FIN IS NOT NULL AND v_Ahora > b.DT_FIN THEN 'cerrado'
            ELSE 'disponible'
        END AS ESTADOEXAMEN,
        IFNULL((
            SELECT COUNT(*)
            FROM INTENTO_EXAMEN i
            WHERE i.IDEXAMEN = b.IDEXAMEN
              AND i.IDUSUARIO = p_IdUsuario
              AND IFNULL(i.ESTADO, 0) = 1
        ), 0) AS INTENTOSFINALIZADOS,
        (
            SELECT TOP 1 i.IDINTENTOEXAMEN
            FROM INTENTO_EXAMEN i
            WHERE i.IDEXAMEN = b.IDEXAMEN
              AND i.IDUSUARIO = p_IdUsuario
              AND IFNULL(i.ESTADO, 0) = 0
            ORDER BY i.NUMEROINTENTO DESC
        ) AS IDINTENTOENCURSO,
        (
            SELECT TOP 1 i.PUNTAJEOBTENIDO
            FROM INTENTO_EXAMEN i
            WHERE i.IDEXAMEN = b.IDEXAMEN
              AND i.IDUSUARIO = p_IdUsuario
              AND IFNULL(i.ESTADO, 0) = 1
            ORDER BY i.NUMEROINTENTO DESC
        ) AS ULTIMOPUNTAJE,
        CASE
            WHEN EXISTS (
                SELECT 1 FROM INTENTO_EXAMEN i
                WHERE i.IDEXAMEN = b.IDEXAMEN
                  AND i.IDUSUARIO = p_IdUsuario
                  AND IFNULL(i.ESTADO, 0) = 0
            ) THEN 'continuar'
            WHEN (
                SELECT COUNT(*) FROM INTENTO_EXAMEN i
                WHERE i.IDEXAMEN = b.IDEXAMEN
                  AND i.IDUSUARIO = p_IdUsuario
                  AND IFNULL(i.ESTADO, 0) = 1
            ) >= IFNULL(NULLIF(b.INTENTOSMAX, 0), 1)
            THEN 'agotado'
            WHEN b.DT_INICIO IS NOT NULL AND v_Ahora < b.DT_INICIO THEN 'proximamente'
            WHEN b.DT_FIN IS NOT NULL AND v_Ahora > b.DT_FIN THEN 'cerrado'
            ELSE 'desarrollar'
        END AS ACCION
    FROM Base b
    ORDER BY
        CASE
            WHEN b.DT_INICIO IS NOT NULL AND v_Ahora < b.DT_INICIO THEN 2
            WHEN b.DT_FIN IS NOT NULL AND v_Ahora > b.DT_FIN THEN 3
            ELSE 1
        END,
        b.DT_INICIO DESC,
        b.TITULO;
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_examen_intento_iniciar;

DROP PROCEDURE IF EXISTS usp_examen_intento_iniciar;

DELIMITER $$

CREATE PROCEDURE usp_examen_intento_iniciar(
    IN p_IdExamen VARCHAR(50),
    IN p_IdUsuario VARCHAR(50),
    OUT p_IdIntento VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
SET p_IdIntento = NULL;
    SET p_Resultado = 0;
    SET p_Mensaje = 'Error desconocido.';

    IF p_IdExamen IS NULL OR p_IdUsuario IS NULL
    BEGIN SET p_Mensaje = 'Datos incompletos.'; LEAVE main; 
    END IF;

    IF NOT EXISTS (SELECT 1 FROM USUARIO WHERE IDUSUARIO = p_IdUsuario)
    BEGIN SET p_Mensaje = 'Usuario no válido.'; LEAVE main; 
    DECLARE v_Visible TINYINT(1), @Todas TINYINT(1), @IntentosMax INT, @Duracion INT;
    DECLARE v_Fi CHAR(8), @Ff CHAR(8), @Hi CHAR(8), @Hf CHAR(8);

    SELECT e.VISIBLE, INTO v_Visible
        @Todas = IFNULL(e.TODASLASULA, 1),
        @IntentosMax = IFNULL(NULLIF(e.INTENTOSMAX, 0), 1),
        @Duracion = e.DURACIONMIN,
        v_Fi = e.FECHAINICIO,
        @Ff = e.FECHAFIN,
        @Hi = e.HORAINICIO,
        @Hf = e.HORAFIN
    FROM EXAMEN e
    WHERE e.IDEXAMEN = p_IdExamen;

    IF v_Visible IS NULL
    BEGIN SET p_Mensaje = 'El examen no existe.'; LEAVE main; 
    END IF;

    IF v_Visible <> 1
    BEGIN SET p_Mensaje = 'El examen no está visible.'; LEAVE main; 
    END IF;

    IF NOT EXISTS (SELECT 1 FROM PREGUNTA WHERE IDEXAMEN = p_IdExamen)
    BEGIN SET p_Mensaje = 'El examen no tiene preguntas.'; LEAVE main; 
    DECLARE v_IdAula VARCHAR(50) = NULL;
    SELECT TOP 1 v_IdAula = m.IDAULA
    FROM MEMBRESIA m
    WHERE m.IDUSUARIO = p_IdUsuario
      AND (m.ESTADOMIEMBRO IS NULL OR m.ESTADOMIEMBRO <> 3)
    ORDER BY m.FECHAREGISTRO DESC, m.IDMEMBRESIA DESC;

    IF @Todas = 0 AND NOT EXISTS (
        SELECT 1 FROM EXAMEN_AULA ea
        WHERE ea.IDEXAMEN = p_IdExamen AND ea.IDAULA = v_IdAula
    )
    BEGIN SET p_Mensaje = 'No tienes acceso a este examen (aula).'; LEAVE main; 
    DECLARE v_Ahora DATETIME = NOW();
    DECLARE v_DT_INICIO DATETIME = CONCAT(TRY_CONVERT(DATETIME,
        SUBSTRING(v_Fi, 5, 4), '-') + CONCAT(SUBSTRING(v_Fi, 3, 2), '-') + CONCAT(SUBSTRING(v_Fi, 1, 2), ' ') + LEFT(IFNULL(NULLIF(RTRIM(@Hi), ''), '00:00:00') + '00', 8), 120);
    DECLARE v_DT_FIN DATETIME = CONCAT(TRY_CONVERT(DATETIME,
        SUBSTRING(@Ff, 5, 4), '-') + CONCAT(SUBSTRING(@Ff, 3, 2), '-') + CONCAT(SUBSTRING(@Ff, 1, 2), ' ') + LEFT(IFNULL(NULLIF(RTRIM(@Hf), ''), '23:59:59') + '00', 8), 120);

    IF v_DT_INICIO IS NOT NULL AND v_Ahora < v_DT_INICIO
    BEGIN SET p_Mensaje = 'El examen aún no está disponible.'; LEAVE main; 
    END IF;

    IF v_DT_FIN IS NOT NULL AND v_Ahora > v_DT_FIN
    BEGIN SET p_Mensaje = 'El examen ya cerró.'; LEAVE main; 
    -- Reanudar intento en curso
    SELECT TOP 1 p_IdIntento = i.IDINTENTOEXAMEN
    FROM INTENTO_EXAMEN i
    WHERE i.IDEXAMEN = p_IdExamen
      AND i.IDUSUARIO = p_IdUsuario
      AND IFNULL(i.ESTADO, 0) = 0
    ORDER BY i.NUMEROINTENTO DESC;

    IF p_IdIntento IS NOT NULL THEN
        SET p_Resultado = 1;
        SET p_Mensaje = 'Intento en curso reanudado.';
        LEAVE main;
    
    DECLARE v_Finalizados INT = (
        SELECT COUNT(*) FROM INTENTO_EXAMEN
        WHERE IDEXAMEN = p_IdExamen AND IDUSUARIO = p_IdUsuario AND IFNULL(ESTADO, 0) = 1
    );
    IF v_Finalizados >= @IntentosMax
    BEGIN SET p_Mensaje = 'Ya usaste todos los intentos permitidos.'; LEAVE main; 
    DECLARE v_Num INT = CONCAT(v_Finalizados, 1);
    DECLARE v_NextNum INT;
    SELECT IFNULL(MAX(CAST(REPLACE(IDINTENTOEXAMEN, 'INT', '') AS INT)), 0) + 1 INTO v_NextNum
    FROM INTENTO_EXAMEN WHERE IDINTENTOEXAMEN LIKE 'INT%';
    SET p_IdIntento = CONCAT('INT', RIGHT(CONCAT('00000', CAST(v_NextNum AS CHAR(5))), 5);

    INSERT INTO INTENTO_EXAMEN (
        IDINTENTOEXAMEN, NUMEROINTENTO,
        FECHAINICIO, HORAINICIO,
        PUNTAJEOBTENIDO, CANTCORRECTAS, CANTINCORRECTAS, CANTSINRESPONDER,
        ESTADO, APROBADO, IDEXAMEN, IDUSUARIO
    )
    VALUES (
        p_IdIntento, v_Num,
        fn_fecha_ddmmyyyy(), TIME_FORMAT(NOW(), '%H:%i:%s'),
        NULL, 0, 0, 0,
        0, NULL, p_IdExamen, p_IdUsuario
    );

    SET p_Resultado = 1;
    SET p_Mensaje = 'Intento iniciado.';
    SELECT p_IdIntento AS IdIntento, p_Resultado AS Resultado, p_Mensaje AS Mensaje
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_examen_intento_estado;

DROP PROCEDURE IF EXISTS usp_examen_intento_estado;

DELIMITER $$

CREATE PROCEDURE usp_examen_intento_estado(
    IN p_IdIntento VARCHAR(50),
    IN p_IdUsuario VARCHAR(50)
)
main: BEGIN
DECLARE v_IdExamen VARCHAR(50), @Estado INT, @Duracion INT;
    DECLARE v_Fi CHAR(8), @Hi CHAR(8);

    SELECT i.IDEXAMEN, INTO v_IdExamen
        @Estado = IFNULL(i.ESTADO, 0),
        v_Fi = i.FECHAINICIO,
        @Hi = i.HORAINICIO,
        @Duracion = e.DURACIONMIN
    FROM INTENTO_EXAMEN i
    INNER JOIN EXAMEN e ON e.IDEXAMEN = i.IDEXAMEN
    WHERE i.IDINTENTOEXAMEN = p_IdIntento
      AND i.IDUSUARIO = p_IdUsuario;

    IF v_IdExamen IS NULL THEN
        SELECT CAST(0 AS INT) AS Resultado, 'Intento no encontrado.' AS Mensaje;
        LEAVE main;
    
    DECLARE v_Total INT = (SELECT COUNT(*) FROM PREGUNTA WHERE IDEXAMEN = v_IdExamen);
    DECLARE v_Respondidas INT = (
        SELECT COUNT(*) FROM RESPUESTA_ALUMNO WHERE IDINTENTOEXAMEN = p_IdIntento
    );
    DECLARE v_OrdenActual INT = CONCAT(v_Respondidas, 1);
    IF v_OrdenActual > v_Total THEN SET v_OrdenActual = v_Total; END IF;

    DECLARE v_DT_INI DATETIME = CONCAT(TRY_CONVERT(DATETIME,
        SUBSTRING(v_Fi, 5, 4), '-') + CONCAT(SUBSTRING(v_Fi, 3, 2), '-') + CONCAT(SUBSTRING(v_Fi, 1, 2), ' ') + LEFT(IFNULL(NULLIF(RTRIM(@Hi), ''), '00:00:00') + '00', 8), 120);
    DECLARE v_SegundosRestantes INT = NULL;
    IF @Duracion IS NOT NULL AND v_DT_INI IS NOT NULL THEN SET v_SegundosRestantes = DATEDIFF(SECOND, NOW(), DATEADD(MINUTE, @Duracion, v_DT_INI)); END IF;

    -- Resultado 1
    SELECT
        1 AS Resultado,
        'OK' AS Mensaje,
        i.IDINTENTOEXAMEN,
        i.IDEXAMEN,
        i.NUMEROINTENTO,
        IFNULL(i.ESTADO, 0) AS ESTADO,
        i.FECHAINICIO,
        i.HORAINICIO,
        e.TITULO,
        e.TIPO,
        e.DURACIONMIN,
        v_Total AS CANTPREGUNTAS,
        v_Respondidas AS CANTRESPONDIDAS,
        v_OrdenActual AS ORDENACTUAL,
        v_SegundosRestantes AS SEGUNDOSRESTANTES,
        i.PUNTAJEOBTENIDO,
        i.CANTCORRECTAS,
        i.CANTINCORRECTAS,
        i.CANTSINRESPONDER,
        i.APROBADO
    FROM INTENTO_EXAMEN i
    INNER JOIN EXAMEN e ON e.IDEXAMEN = i.IDEXAMEN
    WHERE i.IDINTENTOEXAMEN = p_IdIntento;

    -- Resultado 2: mapa de órdenes respondidos (para cuadrados)
    SELECT p.ORDEN, p.IDPREGUNTA
    FROM RESPUESTA_ALUMNO ra
    INNER JOIN PREGUNTA p ON p.IDPREGUNTA = ra.IDPREGUNTA
    WHERE ra.IDINTENTOEXAMEN = p_IdIntento
    ORDER BY p.ORDEN;

    -- Resultado 3: pregunta actual (sin ESCORRECTA) si en curso
    IF @Estado = 0 AND v_OrdenActual >= 1 AND v_OrdenActual <= v_Total AND v_Respondidas < v_Total THEN
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
        WHERE p.IDEXAMEN = v_IdExamen AND p.ORDEN = v_OrdenActual;

        SELECT
            a.IDALTERNATIVA,
            a.DESCRIPCION,
            a.ORDEN,
            a.IMAGEURL
        FROM ALTERNATIVA a
        INNER JOIN PREGUNTA p ON p.IDPREGUNTA = a.IDPREGUNTA
        WHERE p.IDEXAMEN = v_IdExamen AND p.ORDEN = v_OrdenActual
        ORDER BY a.ORDEN, a.IDALTERNATIVA;
    
    ELSE IF @Estado = 0 AND v_Respondidas >= v_Total
    BEGIN
        -- Todas respondidas: listo para finalizar (sin pregunta)
        SELECT CAST(NULL AS CHAR(50)) AS IDPREGUNTA WHERE 1 = 0;
        SELECT CAST(NULL AS CHAR(50)) AS IDALTERNATIVA WHERE 1 = 0;
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_examen_intento_responder;

DROP PROCEDURE IF EXISTS usp_examen_intento_responder;

DELIMITER $$

CREATE PROCEDURE usp_examen_intento_responder(
    IN p_IdIntento VARCHAR(50),
    IN p_IdUsuario VARCHAR(50),
    IN p_IdPregunta VARCHAR(50),
    IN p_IdAlternativa VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200),
    OUT p_OrdenSiguiente INT,
    OUT p_EsUltima TINYINT(1),
    OUT p_TiempoAgotado TINYINT(1)
)
main: BEGIN
SET p_Resultado = 0;
    SET p_Mensaje = 'Error desconocido.';
    SET p_OrdenSiguiente = NULL;
    SET p_EsUltima = 0;
    SET p_TiempoAgotado = 0;

    DECLARE v_IdExamen VARCHAR(50), @Estado INT, @Duracion INT;
    DECLARE v_Fi CHAR(8), @Hi CHAR(8);

    SELECT i.IDEXAMEN, INTO v_IdExamen
        @Estado = IFNULL(i.ESTADO, 0),
        v_Fi = i.FECHAINICIO,
        @Hi = i.HORAINICIO,
        @Duracion = e.DURACIONMIN
    FROM INTENTO_EXAMEN i
    INNER JOIN EXAMEN e ON e.IDEXAMEN = i.IDEXAMEN
    WHERE i.IDINTENTOEXAMEN = p_IdIntento
      AND i.IDUSUARIO = p_IdUsuario;

    IF v_IdExamen IS NULL
    BEGIN SET p_Mensaje = 'Intento no encontrado.'; LEAVE main; 
    END IF;

    IF @Estado <> 0
    BEGIN SET p_Mensaje = 'El intento ya está finalizado.'; LEAVE main; 
    -- Timer
    DECLARE v_DT_INI DATETIME = CONCAT(TRY_CONVERT(DATETIME,
        SUBSTRING(v_Fi, 5, 4), '-') + CONCAT(SUBSTRING(v_Fi, 3, 2), '-') + CONCAT(SUBSTRING(v_Fi, 1, 2), ' ') + LEFT(IFNULL(NULLIF(RTRIM(@Hi), ''), '00:00:00') + '00', 8), 120);
    IF @Duracion IS NOT NULL AND v_DT_INI IS NOT NULL
       AND NOW() > DATEADD(MINUTE, @Duracion, v_DT_INI)
    BEGIN
        SET p_TiempoAgotado = 1;
        SET p_Mensaje = 'Tiempo agotado.';
        SET p_Resultado = 0;
        LEAVE main;
    
    DECLARE v_Total INT = (SELECT COUNT(*) FROM PREGUNTA WHERE IDEXAMEN = v_IdExamen);
    DECLARE v_Respondidas INT = (
        SELECT COUNT(*) FROM RESPUESTA_ALUMNO WHERE IDINTENTOEXAMEN = p_IdIntento
    );
    DECLARE v_OrdenActual INT = CONCAT(v_Respondidas, 1);

    DECLARE v_OrdenPreg INT, @IdPregOk VARCHAR(50);
    SELECT p.ORDEN, @IdPregOk = p.IDPREGUNTA INTO v_OrdenPreg
    FROM PREGUNTA p
    WHERE p.IDPREGUNTA = p_IdPregunta AND p.IDEXAMEN = v_IdExamen;

    IF @IdPregOk IS NULL
    BEGIN SET p_Mensaje = 'Pregunta no válida.'; LEAVE main; 
    END IF;

    IF v_OrdenPreg <> v_OrdenActual
    BEGIN SET p_Mensaje = 'No puedes responder esta pregunta (orden incorrecto).'; LEAVE main; 
    END IF;

    IF EXISTS (
        SELECT 1 FROM RESPUESTA_ALUMNO
        WHERE IDINTENTOEXAMEN = p_IdIntento AND IDPREGUNTA = p_IdPregunta
    )
    BEGIN SET p_Mensaje = 'Esta pregunta ya fue respondida.'; LEAVE main; 
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM ALTERNATIVA
        WHERE IDALTERNATIVA = p_IdAlternativa AND IDPREGUNTA = p_IdPregunta
    )
    BEGIN SET p_Mensaje = 'Alternativa no válida.'; LEAVE main; 
    DECLARE v_IdResp VARCHAR(50);
    DECLARE v_NextNum INT;
    SELECT IFNULL(MAX(CAST(REPLACE(IDRESPUESTAALUMNO, 'RAL', '') AS INT)), 0) + 1 INTO v_NextNum
    FROM RESPUESTA_ALUMNO WHERE IDRESPUESTAALUMNO LIKE 'RAL%';
    SET v_IdResp = CONCAT('RAL', RIGHT(CONCAT('00000', CAST(v_NextNum AS CHAR(5))), 5);

    INSERT INTO RESPUESTA_ALUMNO (
        IDRESPUESTAALUMNO, PUNTAJEOBTENIDO, RESPABIERTA,
        IDINTENTOEXAMEN, IDPREGUNTA, IDALTERNATIVA
    )
    VALUES (v_IdResp, NULL, NULL, p_IdIntento, p_IdPregunta, p_IdAlternativa);

    SET v_Respondidas = CONCAT(v_Respondidas, 1);
    IF v_Respondidas >= v_Total THEN
        SET p_EsUltima = 1;
        SET p_OrdenSiguiente = v_Total;
    
ELSE
        SET p_OrdenSiguiente = CONCAT(v_Respondidas, 1);
        SET p_EsUltima = 0;
    
    SET p_Resultado = 1;
    SET p_Mensaje = 'Respuesta guardada.';
    SELECT p_Resultado AS Resultado, p_Mensaje AS Mensaje, p_OrdenSiguiente AS OrdenSiguiente, p_EsUltima AS EsUltima, p_TiempoAgotado AS TiempoAgotado
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_examen_intento_finalizar;

DROP PROCEDURE IF EXISTS usp_examen_intento_finalizar;

DELIMITER $$

CREATE PROCEDURE usp_examen_intento_finalizar(
    IN p_IdIntento VARCHAR(50),
    IN p_IdUsuario VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
SET p_Resultado = 0;
    SET p_Mensaje = 'Error desconocido.';

    DECLARE v_IdExamen VARCHAR(50), @Estado INT;
    DECLARE v_PuntajeAprobado DECIMAL(6,2);

    SELECT i.IDEXAMEN, INTO v_IdExamen
        @Estado = IFNULL(i.ESTADO, 0),
        v_PuntajeAprobado = e.PUNTAJEAPROBADO
    FROM INTENTO_EXAMEN i
    INNER JOIN EXAMEN e ON e.IDEXAMEN = i.IDEXAMEN
    WHERE i.IDINTENTOEXAMEN = p_IdIntento
      AND i.IDUSUARIO = p_IdUsuario;

    IF v_IdExamen IS NULL
    BEGIN SET p_Mensaje = 'Intento no encontrado.'; LEAVE main; 
    END IF;

    IF @Estado = 1 THEN
        SET p_Resultado = 1;
        SET p_Mensaje = 'El intento ya estaba finalizado.';
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
            (SELECT COUNT(*) FROM PREGUNTA WHERE IDEXAMEN = v_IdExamen) AS CANTPREGUNTAS,
            IFNULL(e.PUNTAJETOTAL, 0) AS PUNTAJETOTAL
        FROM INTENTO_EXAMEN i
        INNER JOIN EXAMEN e ON e.IDEXAMEN = i.IDEXAMEN
        WHERE i.IDINTENTOEXAMEN = p_IdIntento;
        LEAVE main;
    
    DECLARE v_Total INT = (SELECT COUNT(*) FROM PREGUNTA WHERE IDEXAMEN = v_IdExamen);

    -- Puntuar respuestas
    UPDATE ra
    SET ra.PUNTAJEOBTENIDO = CASE
            WHEN IFNULL(a.ESCORRECTA, 0) = 1 THEN IFNULL(p.PUNTAJE, 1)
            ELSE 0
        
    FROM RESPUESTA_ALUMNO ra
    INNER JOIN PREGUNTA p ON p.IDPREGUNTA = ra.IDPREGUNTA
    LEFT JOIN ALTERNATIVA a ON a.IDALTERNATIVA = ra.IDALTERNATIVA
    WHERE ra.IDINTENTOEXAMEN = p_IdIntento;

    DECLARE v_Correctas INT = (
        SELECT COUNT(*)
        FROM RESPUESTA_ALUMNO ra
        INNER JOIN ALTERNATIVA a ON a.IDALTERNATIVA = ra.IDALTERNATIVA
        WHERE ra.IDINTENTOEXAMEN = p_IdIntento AND IFNULL(a.ESCORRECTA, 0) = 1
    );
    DECLARE v_Respondidas INT = (
        SELECT COUNT(*) FROM RESPUESTA_ALUMNO WHERE IDINTENTOEXAMEN = p_IdIntento
    );
    DECLARE v_Incorrectas INT = v_Respondidas - v_Correctas;
    DECLARE v_SinResp INT = v_Total - v_Respondidas;
    IF v_SinResp < 0 THEN SET v_SinResp = 0; END IF;

    DECLARE v_Puntaje DECIMAL(6,2) = (
        SELECT IFNULL(SUM(ra.PUNTAJEOBTENIDO), 0)
        FROM RESPUESTA_ALUMNO ra
        WHERE ra.IDINTENTOEXAMEN = p_IdIntento
    );

    -- Si no hay puntaje por pregunta, usar 1 punto por correcta
    IF NOT EXISTS (SELECT 1 FROM PREGUNTA WHERE IDEXAMEN = v_IdExamen AND IFNULL(PUNTAJE, 0) > 0) THEN SET v_Puntaje = CAST(v_Correctas AS DECIMAL(6,2)); END IF;

    DECLARE v_Aprobado TINYINT(1) = 0;
    IF v_PuntajeAprobado IS NOT NULL AND v_Puntaje >= v_PuntajeAprobado THEN SET v_Aprobado = 1; END IF;
    ELSE IF v_PuntajeAprobado IS NULL AND v_Total > 0 AND v_Correctas >= CEILING(v_Total * 0.5) THEN SET v_Aprobado = 1; END IF;

    UPDATE INTENTO_EXAMEN SET
        FECHAFIN = fn_fecha_ddmmyyyy(),
        HORAFIN = TIME_FORMAT(NOW(), '%H:%i:%s'),
        PUNTAJEOBTENIDO = v_Puntaje,
        CANTCORRECTAS = v_Correctas,
        CANTINCORRECTAS = v_Incorrectas,
        CANTSINRESPONDER = v_SinResp,
        ESTADO = 1,
        APROBADO = v_Aprobado
    WHERE IDINTENTOEXAMEN = p_IdIntento;

    SET p_Resultado = 1;
    SET p_Mensaje = 'Examen enviado.';

    SELECT
        i.IDINTENTOEXAMEN,
        i.IDEXAMEN,
        e.TITULO,
        i.PUNTAJEOBTENIDO,
        i.CANTCORRECTAS,
        i.CANTINCORRECTAS,
        i.CANTSINRESPONDER,
        i.APROBADO,
        v_Total AS CANTPREGUNTAS,
        IFNULL(e.PUNTAJETOTAL, v_Total) AS PUNTAJETOTAL
    FROM INTENTO_EXAMEN i
    INNER JOIN EXAMEN e ON e.IDEXAMEN = i.IDEXAMEN
    WHERE i.IDINTENTOEXAMEN = p_IdIntento;
END;

SELECT 'usp_examen_estudiante (listar/iniciar/estado/responder/finalizar) listo.';
    SELECT p_Resultado AS Resultado, p_Mensaje AS Mensaje
END$$

DELIMITER ;