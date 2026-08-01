-- ============================================================================
-- CRUD EXAMEN + preguntas + distribución — MySQL 8
-- Ejecutar después de 1.examen_tablas_plantilla.sql
-- Fecha: 17/07/2026
-- ============================================================================

USE `AcademiaDB`;

DROP PROCEDURE IF EXISTS usp_examen_listar;

DELIMITER $$

CREATE PROCEDURE usp_examen_listar(
    IN p_Buscar VARCHAR(200),
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
    FROM EXAMEN e
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           e.IDEXAMEN LIKE CONCAT('%', p_Buscar, '%') OR
           e.TITULO LIKE CONCAT('%', p_Buscar, '%') OR
           IFNULL(e.DESCRIPCION, '') LIKE CONCAT('%', p_Buscar, '%'));

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
        e.VISIBLE,
        IFNULL(e.TODASLASULA, 1) AS TODASLASULA,
        e.IDUSUARIO,
        (SELECT COUNT(*) FROM PREGUNTA p WHERE p.IDEXAMEN = e.IDEXAMEN) AS CANTPREGUNTAS
    FROM EXAMEN e
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           e.IDEXAMEN LIKE CONCAT('%', p_Buscar, '%') OR
           e.TITULO LIKE CONCAT('%', p_Buscar, '%') OR
           IFNULL(e.DESCRIPCION, '') LIKE CONCAT('%', p_Buscar, '%'))
    ORDER BY
        CASE WHEN p_OrdenarPor = 'TITULO' AND p_Direccion = 'ASC'  THEN e.TITULO END ASC,
        CASE WHEN p_OrdenarPor = 'TITULO' AND p_Direccion = 'DESC' THEN e.TITULO END DESC,
        CASE WHEN p_OrdenarPor = 'TIPO' AND p_Direccion = 'ASC'  THEN e.TIPO END ASC,
        CASE WHEN p_OrdenarPor = 'TIPO' AND p_Direccion = 'DESC' THEN e.TIPO END DESC,
        CASE WHEN p_OrdenarPor = 'FECHAINICIO' AND p_Direccion = 'ASC'  THEN e.FECHAINICIO END ASC,
        CASE WHEN p_OrdenarPor = 'FECHAINICIO' AND p_Direccion = 'DESC' THEN e.FECHAINICIO END DESC,
        e.IDEXAMEN DESC
    LIMIT p_TamanioPagina OFFSET v_offset;
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_examen_obtener;

DELIMITER $$

CREATE PROCEDURE usp_examen_obtener(
    IN p_Id VARCHAR(50)
)
main: BEGIN
    SELECT
        e.IDEXAMEN,
        e.TITULO,
        e.DESCRIPCION,
        e.TIPO,
        e.DURACIONMIN,
        e.PUNTAJETOTAL,
        e.PUNTAJEAPROBADO,
        e.FECHAINICIO,
        e.FECHAFIN,
        e.HORAINICIO,
        e.HORAFIN,
        e.TIEMPOLIMITE,
        e.INTENTOSMAX,
        e.VISIBLE,
        IFNULL(e.TODASLASULA, 1) AS TODASLASULA,
        e.IDUSUARIO
    FROM EXAMEN e
    WHERE e.IDEXAMEN = p_Id;

    SELECT ea.IDAULA
    FROM EXAMEN_AULA ea
    WHERE ea.IDEXAMEN = p_Id
    ORDER BY ea.IDAULA;

    SELECT
        p.IDPREGUNTA,
        p.TITULO,
        p.DESCRIPCION,
        p.PUNTAJE,
        p.ORDEN,
        p.IMAGEURL,
        p.IDMATERIA,
        m.CODIGO AS MATERIA_CODIGO,
        m.NOMBRE AS MATERIA_NOMBRE,
        c.IDCATEGORIA,
        c.NOMBRE AS CATEGORIA_NOMBRE
    FROM PREGUNTA p
    LEFT JOIN MATERIA m ON m.IDMATERIA = p.IDMATERIA
    LEFT JOIN CATEGORIA c ON c.IDCATEGORIA = m.IDCATEGORIA
    WHERE p.IDEXAMEN = p_Id
    ORDER BY p.ORDEN, p.IDPREGUNTA;
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_examen_pregunta_detalle;

DELIMITER $$

CREATE PROCEDURE usp_examen_pregunta_detalle(
    IN p_IdExamen VARCHAR(50),
    IN p_IdPregunta VARCHAR(50)
)
main: BEGIN
    SELECT
        p.IDPREGUNTA,
        p.TITULO,
        p.DESCRIPCION,
        p.PUNTAJE,
        p.ORDEN,
        p.IMAGEURL,
        p.IDEXAMEN,
        p.IDMATERIA,
        m.CODIGO AS MATERIA_CODIGO,
        m.NOMBRE AS MATERIA_NOMBRE
    FROM PREGUNTA p
    LEFT JOIN MATERIA m ON m.IDMATERIA = p.IDMATERIA
    WHERE p.IDEXAMEN = p_IdExamen AND p.IDPREGUNTA = p_IdPregunta;

    SELECT
        a.IDALTERNATIVA,
        a.DESCRIPCION,
        a.ESCORRECTA,
        a.ORDEN,
        a.IMAGEURL
    FROM ALTERNATIVA a
    WHERE a.IDPREGUNTA = p_IdPregunta
    ORDER BY a.ORDEN, a.IDALTERNATIVA;
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_examen_distribucion;

DELIMITER $$

CREATE PROCEDURE usp_examen_distribucion(
    IN p_Tipo INT,
    IN p_IdExamen VARCHAR(50)
)
main: BEGIN
    IF p_IdExamen IS NOT NULL AND TRIM(p_IdExamen) <> '' THEN
        SELECT
            c.IDCATEGORIA,
            c.NOMBRE AS CATEGORIA_NOMBRE,
            c.PORCENTAJE,
            c.ORDEN AS CATEGORIA_ORDEN,
            COUNT(DISTINCT m.IDMATERIA) AS AREAS,
            COUNT(p.IDPREGUNTA) AS TOTALPREGUNTAS
        FROM PREGUNTA p
        INNER JOIN MATERIA m ON m.IDMATERIA = p.IDMATERIA
        INNER JOIN CATEGORIA c ON c.IDCATEGORIA = m.IDCATEGORIA
        WHERE p.IDEXAMEN = p_IdExamen
        GROUP BY c.IDCATEGORIA, c.NOMBRE, c.PORCENTAJE, c.ORDEN
        ORDER BY c.ORDEN, c.NOMBRE;

        SELECT
            c.IDCATEGORIA,
            m.IDMATERIA,
            m.CODIGO,
            m.NOMBRE AS MATERIA_NOMBRE,
            COUNT(p.IDPREGUNTA) AS CANTIDAD
        FROM PREGUNTA p
        INNER JOIN MATERIA m ON m.IDMATERIA = p.IDMATERIA
        INNER JOIN CATEGORIA c ON c.IDCATEGORIA = m.IDCATEGORIA
        WHERE p.IDEXAMEN = p_IdExamen
        GROUP BY c.IDCATEGORIA, m.IDMATERIA, m.CODIGO, m.NOMBRE, c.ORDEN, m.CODIGO
        ORDER BY c.ORDEN, m.CODIGO;
        LEAVE main;
    END IF;

    IF p_Tipo IS NULL THEN SET p_Tipo = 40; END IF;

    SELECT
        c.IDCATEGORIA,
        c.NOMBRE AS CATEGORIA_NOMBRE,
        c.PORCENTAJE,
        c.ORDEN AS CATEGORIA_ORDEN,
        COUNT(DISTINCT m.IDMATERIA) AS AREAS,
        SUM(pl.CANTIDAD) AS TOTALPREGUNTAS
    FROM EXAMEN_PLANTILLA pl
    INNER JOIN MATERIA m ON m.CODIGO = pl.CODIGOMATERIA
    INNER JOIN CATEGORIA c ON c.IDCATEGORIA = m.IDCATEGORIA
    WHERE pl.TIPO = p_Tipo
    GROUP BY c.IDCATEGORIA, c.NOMBRE, c.PORCENTAJE, c.ORDEN
    ORDER BY c.ORDEN, c.NOMBRE;

    SELECT
        c.IDCATEGORIA,
        m.IDMATERIA,
        m.CODIGO,
        m.NOMBRE AS MATERIA_NOMBRE,
        pl.CANTIDAD
    FROM EXAMEN_PLANTILLA pl
    INNER JOIN MATERIA m ON m.CODIGO = pl.CODIGOMATERIA
    INNER JOIN CATEGORIA c ON c.IDCATEGORIA = m.IDCATEGORIA
    WHERE pl.TIPO = p_Tipo
    ORDER BY c.ORDEN, m.CODIGO;
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_examen_insertar;

DELIMITER $$

CREATE PROCEDURE usp_examen_insertar(
    IN p_Titulo VARCHAR(200),
    IN p_Descripcion LONGTEXT,
    IN p_Tipo INT,
    IN p_DuracionMin INT,
    IN p_FechaInicio CHAR(8),
    IN p_FechaFin CHAR(8),
    IN p_HoraInicio CHAR(8),
    IN p_HoraFin CHAR(8),
    IN p_Visible TINYINT(1),
    IN p_TodasLasAula TINYINT(1),
    IN p_IdUsuario VARCHAR(50),
    IN p_AulasCsv LONGTEXT,
    OUT p_IdGenerado VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
    DECLARE v_NextNum INT;
    DECLARE v_Orden INT DEFAULT 0;
    DECLARE v_Codigo VARCHAR(50);
    DECLARE v_Cant INT;
    DECLARE v_IdMateria VARCHAR(50);
    DECLARE v_i INT;
    DECLARE v_IdPreg VARCHAR(50);
    DECLARE v_AltOrd INT;
    DECLARE v_done INT DEFAULT 0;
    DECLARE v_pos INT DEFAULT 1;
    DECLARE v_next INT DEFAULT 0;
    DECLARE v_token VARCHAR(50);
    DECLARE v_csv LONGTEXT;

    DECLARE cur CURSOR FOR
        SELECT pl.CODIGOMATERIA, pl.CANTIDAD, m.IDMATERIA
        FROM EXAMEN_PLANTILLA pl
        INNER JOIN MATERIA m ON m.CODIGO = pl.CODIGOMATERIA
        INNER JOIN CATEGORIA c ON c.IDCATEGORIA = m.IDCATEGORIA
        WHERE pl.TIPO = p_Tipo
        ORDER BY c.ORDEN, m.CODIGO;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;

    SET p_IdGenerado = NULL;
    SET p_Resultado = 0;
    SET p_Mensaje = 'Error desconocido.';

    IF p_Titulo IS NULL OR TRIM(p_Titulo) = '' THEN
        SET p_Mensaje = 'Ingresa el título del examen.';
        LEAVE main;
    END IF;

    IF p_IdUsuario IS NULL OR TRIM(p_IdUsuario) = '' THEN
        SET p_Mensaje = 'Usuario creador no válido.';
        LEAVE main;
    END IF;

    IF p_Tipo NOT IN (40, 100) THEN SET p_Tipo = 40; END IF;

    IF NOT EXISTS (SELECT 1 FROM EXAMEN_PLANTILLA WHERE TIPO = p_Tipo) THEN
        SET p_Mensaje = 'No hay plantilla de distribución para ese tipo.';
        LEAVE main;
    END IF;

    IF EXISTS (
        SELECT 1 FROM EXAMEN_PLANTILLA pl
        WHERE pl.TIPO = p_Tipo
          AND NOT EXISTS (SELECT 1 FROM MATERIA m WHERE m.CODIGO = pl.CODIGOMATERIA)
    ) THEN
        SET p_Mensaje = 'Faltan materias de la plantilla. Revisa el mantenedor de materias.';
        LEAVE main;
    END IF;

    SELECT IFNULL(MAX(CAST(REPLACE(IDEXAMEN, 'EXA', '') AS UNSIGNED)), 0) + 1 INTO v_NextNum
    FROM EXAMEN WHERE IDEXAMEN LIKE 'EXA%';
    SET p_IdGenerado = CONCAT('EXA', LPAD(CAST(v_NextNum AS CHAR), 3, '0'));

    INSERT INTO EXAMEN (
        IDEXAMEN, TITULO, DESCRIPCION, TIPO, DURACIONMIN,
        FECHAINICIO, FECHAFIN, HORAINICIO, HORAFIN,
        INTENTOSMAX, VISIBLE, TODASLASULA, IDUSUARIO
    )
    VALUES (
        p_IdGenerado, p_Titulo, p_Descripcion, p_Tipo, p_DuracionMin,
        p_FechaInicio, p_FechaFin, p_HoraInicio, p_HoraFin,
        1, p_Visible, p_TodasLasAula, p_IdUsuario
    );

    IF p_TodasLasAula = 0 AND p_AulasCsv IS NOT NULL AND TRIM(p_AulasCsv) <> '' THEN
        SET v_csv = CONCAT(p_AulasCsv, ',');
        SET v_pos = 1;

        csv_loop: WHILE v_pos <= CHAR_LENGTH(v_csv) DO
            SET v_next = LOCATE(',', v_csv, v_pos);
            IF v_next = 0 THEN
                LEAVE csv_loop;
            END IF;

            SET v_token = TRIM(SUBSTRING(v_csv, v_pos, v_next - v_pos));

            IF v_token <> '' THEN
                INSERT INTO EXAMEN_AULA (IDEXAMENAULA, IDEXAMEN, IDAULA)
                VALUES (
                    CONCAT('EXAUL', REPLACE(UUID(), '-', '')),
                    p_IdGenerado,
                    v_token
                );
            END IF;

            SET v_pos = v_next + 1;
        END WHILE csv_loop;
    END IF;

    SET v_done = 0;
    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_Codigo, v_Cant, v_IdMateria;
        IF v_done = 1 THEN
            LEAVE read_loop;
        END IF;

        SET v_i = 1;
        WHILE v_i <= v_Cant DO
            SET v_Orden = v_Orden + 1;
            SET v_IdPreg = CONCAT(p_IdGenerado, '_P', LPAD(CAST(v_Orden AS CHAR), 3, '0'));

            INSERT INTO PREGUNTA (IDPREGUNTA, TITULO, DESCRIPCION, PUNTAJE, ORDEN, IMAGEURL, IDEXAMEN, IDMATERIA)
            VALUES (
                v_IdPreg,
                CONCAT('Pregunta ', CAST(v_Orden AS CHAR)),
                NULL,
                1,
                v_Orden,
                NULL,
                p_IdGenerado,
                v_IdMateria
            );

            SET v_AltOrd = 1;
            WHILE v_AltOrd <= 5 DO
                INSERT INTO ALTERNATIVA (IDALTERNATIVA, DESCRIPCION, ESCORRECTA, ORDEN, IMAGEURL, IDPREGUNTA)
                VALUES (
                    CONCAT(v_IdPreg, '_A', CAST(v_AltOrd AS CHAR)),
                    '',
                    CASE WHEN v_AltOrd = 1 THEN 1 ELSE 0 END,
                    v_AltOrd,
                    NULL,
                    v_IdPreg
                );
                SET v_AltOrd = v_AltOrd + 1;
            END WHILE;

            SET v_i = v_i + 1;
        END WHILE;
    END LOOP;
    CLOSE cur;

    SET p_Resultado = 1;
    SET p_Mensaje = CONCAT('Examen creado con ', CAST(v_Orden AS CHAR), ' preguntas.');
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_examen_actualizar;

DELIMITER $$

CREATE PROCEDURE usp_examen_actualizar(
    IN p_Id VARCHAR(50),
    IN p_Titulo VARCHAR(200),
    IN p_Descripcion LONGTEXT,
    IN p_DuracionMin INT,
    IN p_FechaInicio CHAR(8),
    IN p_FechaFin CHAR(8),
    IN p_HoraInicio CHAR(8),
    IN p_HoraFin CHAR(8),
    IN p_Visible TINYINT(1),
    IN p_TodasLasAula TINYINT(1),
    IN p_AulasCsv LONGTEXT,
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
    DECLARE v_pos INT DEFAULT 1;
    DECLARE v_next INT DEFAULT 0;
    DECLARE v_token VARCHAR(50);
    DECLARE v_csv LONGTEXT;

    SET p_Resultado = 0;
    SET p_Mensaje = 'Error desconocido.';

    IF NOT EXISTS (SELECT 1 FROM EXAMEN WHERE IDEXAMEN = p_Id) THEN
        SET p_Mensaje = 'El examen no existe.';
        LEAVE main;
    END IF;

    IF p_Titulo IS NULL OR TRIM(p_Titulo) = '' THEN
        SET p_Mensaje = 'Ingresa el título del examen.';
        LEAVE main;
    END IF;

    UPDATE EXAMEN SET
        TITULO = p_Titulo,
        DESCRIPCION = p_Descripcion,
        DURACIONMIN = p_DuracionMin,
        FECHAINICIO = p_FechaInicio,
        FECHAFIN = p_FechaFin,
        HORAINICIO = p_HoraInicio,
        HORAFIN = p_HoraFin,
        VISIBLE = p_Visible,
        TODASLASULA = p_TodasLasAula
    WHERE IDEXAMEN = p_Id;

    DELETE FROM EXAMEN_AULA WHERE IDEXAMEN = p_Id;

    IF p_TodasLasAula = 0 AND p_AulasCsv IS NOT NULL AND TRIM(p_AulasCsv) <> '' THEN
        SET v_csv = CONCAT(p_AulasCsv, ',');
        SET v_pos = 1;

        csv_loop: WHILE v_pos <= CHAR_LENGTH(v_csv) DO
            SET v_next = LOCATE(',', v_csv, v_pos);
            IF v_next = 0 THEN
                LEAVE csv_loop;
            END IF;

            SET v_token = TRIM(SUBSTRING(v_csv, v_pos, v_next - v_pos));

            IF v_token <> '' THEN
                INSERT INTO EXAMEN_AULA (IDEXAMENAULA, IDEXAMEN, IDAULA)
                VALUES (
                    CONCAT('EXAUL', REPLACE(UUID(), '-', '')),
                    p_Id,
                    v_token
                );
            END IF;

            SET v_pos = v_next + 1;
        END WHILE csv_loop;
    END IF;

    SET p_Resultado = 1;
    SET p_Mensaje = 'Examen actualizado.';
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_examen_eliminar;

DELIMITER $$

CREATE PROCEDURE usp_examen_eliminar(
    IN p_Id VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
    SET p_Resultado = 0;
    SET p_Mensaje = 'Error desconocido.';

    IF NOT EXISTS (SELECT 1 FROM EXAMEN WHERE IDEXAMEN = p_Id) THEN
        SET p_Mensaje = 'El examen no existe.';
        LEAVE main;
    END IF;

    IF EXISTS (SELECT 1 FROM INTENTO_EXAMEN WHERE IDEXAMEN = p_Id) THEN
        SET p_Mensaje = 'No se puede eliminar: hay intentos de estudiantes.';
        LEAVE main;
    END IF;

    DELETE FROM ALTERNATIVA
    WHERE IDPREGUNTA IN (SELECT IDPREGUNTA FROM PREGUNTA WHERE IDEXAMEN = p_Id);

    DELETE FROM PREGUNTA WHERE IDEXAMEN = p_Id;
    DELETE FROM EXAMEN_AULA WHERE IDEXAMEN = p_Id;
    DELETE FROM EXAMEN WHERE IDEXAMEN = p_Id;

    SET p_Resultado = 1;
    SET p_Mensaje = 'Examen eliminado.';
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_examen_pregunta_guardar;

DELIMITER $$

CREATE PROCEDURE usp_examen_pregunta_guardar(
    IN p_IdExamen VARCHAR(50),
    IN p_IdPregunta VARCHAR(50),
    IN p_Descripcion LONGTEXT,
    IN p_ImageUrl VARCHAR(255),
    IN p_QuitarImagen TINYINT(1),
    IN p_Alt1 LONGTEXT,
    IN p_Alt2 LONGTEXT,
    IN p_Alt3 LONGTEXT,
    IN p_Alt4 LONGTEXT,
    IN p_Alt5 LONGTEXT,
    IN p_CorrectaOrden INT,
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
    SET p_Resultado = 0;
    SET p_Mensaje = 'Error desconocido.';

    IF NOT EXISTS (SELECT 1 FROM PREGUNTA WHERE IDPREGUNTA = p_IdPregunta AND IDEXAMEN = p_IdExamen) THEN
        SET p_Mensaje = 'La pregunta no existe en este examen.';
        LEAVE main;
    END IF;

    IF p_CorrectaOrden IS NULL OR p_CorrectaOrden < 1 OR p_CorrectaOrden > 5 THEN
        SET p_CorrectaOrden = 1;
    END IF;

    UPDATE PREGUNTA SET
        DESCRIPCION = p_Descripcion,
        IMAGEURL = CASE
            WHEN p_QuitarImagen = 1 THEN NULL
            WHEN p_ImageUrl IS NOT NULL AND TRIM(p_ImageUrl) <> '' THEN p_ImageUrl
            ELSE IMAGEURL
        END
    WHERE IDPREGUNTA = p_IdPregunta;

    UPDATE ALTERNATIVA SET
        DESCRIPCION = CASE ORDEN
            WHEN 1 THEN IFNULL(p_Alt1, '')
            WHEN 2 THEN IFNULL(p_Alt2, '')
            WHEN 3 THEN IFNULL(p_Alt3, '')
            WHEN 4 THEN IFNULL(p_Alt4, '')
            WHEN 5 THEN IFNULL(p_Alt5, '')
            ELSE DESCRIPCION
        END,
        ESCORRECTA = CASE WHEN ORDEN = p_CorrectaOrden THEN 1 ELSE 0 END
    WHERE IDPREGUNTA = p_IdPregunta;

    SET p_Resultado = 1;
    SET p_Mensaje = 'Pregunta guardada.';
END$$

DELIMITER ;

SELECT 'SPs usp_examen_* creados.' AS info;
