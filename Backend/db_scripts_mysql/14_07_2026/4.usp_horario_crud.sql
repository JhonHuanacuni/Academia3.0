-- ============================================================================
-- CRUD HORARIO — Académico — MySQL 8
-- Prerequisito: 3.horario_tabla.sql
-- Fecha: 14/07/2026
-- ============================================================================

USE `AcademiaDB`;

DROP PROCEDURE IF EXISTS usp_horario_listar;

DELIMITER $$

CREATE PROCEDURE usp_horario_listar(
    IN p_Buscar VARCHAR(200),
    IN p_Estado VARCHAR(50),
    IN p_OrdenarPor VARCHAR(50),
    IN p_Direccion VARCHAR(4),
    IN p_Pagina INT,
    IN p_TamanioPagina INT,
    OUT p_TotalRegistros INT
)
main: BEGIN
    IF p_Pagina < 1 THEN SET p_Pagina = 1; END IF;
    IF p_TamanioPagina < 1 THEN SET p_TamanioPagina = 10; END IF;

    SET @v_offset = (p_Pagina - 1) * p_TamanioPagina;

    SELECT COUNT(*) INTO p_TotalRegistros
    FROM HORARIO h
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           h.IDHORARIO LIKE CONCAT('%', p_Buscar, '%') OR
           h.TITULO LIKE CONCAT('%', p_Buscar, '%') OR
           h.DESCRIPCION LIKE CONCAT('%', p_Buscar, '%'))
      AND (p_Estado IS NULL OR p_Estado = '' OR h.ESTADO = p_Estado);

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
    ORDER BY
        CASE WHEN p_OrdenarPor = 'IDHORARIO'   AND p_Direccion = 'ASC'  THEN h.IDHORARIO END ASC,
        CASE WHEN p_OrdenarPor = 'IDHORARIO'   AND p_Direccion = 'DESC' THEN h.IDHORARIO END DESC,
        CASE WHEN p_OrdenarPor = 'TITULO'      AND p_Direccion = 'ASC'  THEN h.TITULO END ASC,
        CASE WHEN p_OrdenarPor = 'TITULO'      AND p_Direccion = 'DESC' THEN h.TITULO END DESC,
        CASE WHEN p_OrdenarPor = 'FECHASUBIDA' AND p_Direccion = 'ASC'  THEN h.FECHASUBIDA END ASC,
        CASE WHEN p_OrdenarPor = 'FECHASUBIDA' AND p_Direccion = 'DESC' THEN h.FECHASUBIDA END DESC,
        CASE WHEN p_OrdenarPor = 'ESTADO'      AND p_Direccion = 'ASC'  THEN h.ESTADO END ASC,
        CASE WHEN p_OrdenarPor = 'ESTADO'      AND p_Direccion = 'DESC' THEN h.ESTADO END DESC,
        h.FECHASUBIDA DESC, h.IDHORARIO DESC
    LIMIT p_TamanioPagina OFFSET @v_offset;
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_horario_obtener;

DELIMITER $$

CREATE PROCEDURE usp_horario_obtener(
    IN p_Id VARCHAR(50)
)
main: BEGIN
    SELECT
        h.IDHORARIO,
        h.TITULO,
        h.DESCRIPCION,
        h.URLIMAGEN,
        h.FECHASUBIDA,
        h.ESTADO
    FROM HORARIO h
    WHERE h.IDHORARIO = p_Id;

    SELECT ha.IDAULA
    FROM HORARIO_AULA ha
    WHERE ha.IDHORARIO = p_Id
    ORDER BY ha.IDAULA;
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_horario_insertar;

DELIMITER $$

CREATE PROCEDURE usp_horario_insertar(
    IN p_Titulo VARCHAR(200),
    IN p_Descripcion LONGTEXT,
    IN p_UrlImagen VARCHAR(255),
    IN p_FechaSubida CHAR(8),
    IN p_Estado VARCHAR(50),
    IN p_AulasCsv LONGTEXT,
    OUT p_IdGenerado VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
    DECLARE v_NextNum INT DEFAULT 0;
    DECLARE v_pos INT DEFAULT 1;
    DECLARE v_next INT DEFAULT 0;
    DECLARE v_token VARCHAR(50);
    DECLARE v_seq INT DEFAULT 1;
    DECLARE v_csv LONGTEXT;
    DECLARE v_err_msg VARCHAR(200);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_IdGenerado = NULL;
        SET p_Resultado = 0;
        GET DIAGNOSTICS CONDITION 1 v_err_msg = MESSAGE_TEXT;
        SET p_Mensaje = LEFT(v_err_msg, 200);
    END;

    SET p_IdGenerado = NULL;

    IF p_Titulo IS NULL OR TRIM(p_Titulo) = '' THEN
        SET p_Resultado = 0;
        SET p_Mensaje = 'Ingresa el título del horario.';
        LEAVE main;
    END IF;

    IF p_Estado IS NULL OR TRIM(p_Estado) = '' THEN
        SET p_Estado = 'Activo';
    END IF;

    IF p_FechaSubida IS NULL OR TRIM(p_FechaSubida) = '' OR CHAR_LENGTH(p_FechaSubida) <> 8 THEN
        SET p_FechaSubida = fn_fecha_ddmmyyyy();
    END IF;

    SELECT IFNULL(MAX(CAST(IDHORARIO AS UNSIGNED)), 0) + 1 INTO v_NextNum FROM HORARIO;
    SET p_IdGenerado = CAST(v_NextNum AS CHAR);

    START TRANSACTION;

    INSERT INTO HORARIO (IDHORARIO, TITULO, DESCRIPCION, URLIMAGEN, FECHASUBIDA, ESTADO)
    VALUES (p_IdGenerado, p_Titulo, p_Descripcion, p_UrlImagen, p_FechaSubida, p_Estado);

    IF p_AulasCsv IS NOT NULL AND TRIM(p_AulasCsv) <> '' THEN
        SET v_csv = CONCAT(p_AulasCsv, ',');
        SET v_pos = 1;
        SET v_seq = 1;

        csv_loop: WHILE v_pos <= CHAR_LENGTH(v_csv) DO
            SET v_next = LOCATE(',', v_csv, v_pos);
            IF v_next = 0 THEN
                LEAVE csv_loop;
            END IF;

            SET v_token = TRIM(SUBSTRING(v_csv, v_pos, v_next - v_pos));

            IF v_token <> '' AND EXISTS (SELECT 1 FROM AULA WHERE IDAULA = v_token) THEN
                INSERT INTO HORARIO_AULA (IDHORARIOAULA, IDHORARIO, IDAULA)
                VALUES (
                    CONCAT(p_IdGenerado, '-A', LPAD(CAST(v_seq AS CHAR), 3, '0')),
                    p_IdGenerado,
                    v_token
                );
                SET v_seq = v_seq + 1;
            END IF;

            SET v_pos = v_next + 1;
        END WHILE csv_loop;
    END IF;

    COMMIT;
    SET p_Resultado = 1;
    SET p_Mensaje = 'Horario registrado.';
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_horario_actualizar;

DELIMITER $$

CREATE PROCEDURE usp_horario_actualizar(
    IN p_Id VARCHAR(50),
    IN p_Titulo VARCHAR(200),
    IN p_Descripcion LONGTEXT,
    IN p_UrlImagen VARCHAR(255),
    IN p_Estado VARCHAR(50),
    IN p_AulasCsv LONGTEXT,
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
    DECLARE v_pos INT DEFAULT 1;
    DECLARE v_next INT DEFAULT 0;
    DECLARE v_token VARCHAR(50);
    DECLARE v_seq INT DEFAULT 1;
    DECLARE v_csv LONGTEXT;
    DECLARE v_err_msg VARCHAR(200);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_Resultado = 0;
        GET DIAGNOSTICS CONDITION 1 v_err_msg = MESSAGE_TEXT;
        SET p_Mensaje = LEFT(v_err_msg, 200);
    END;

    IF NOT EXISTS (SELECT 1 FROM HORARIO WHERE IDHORARIO = p_Id) THEN
        SET p_Resultado = 0;
        SET p_Mensaje = 'El horario no existe.';
        LEAVE main;
    END IF;

    IF p_Titulo IS NULL OR TRIM(p_Titulo) = '' THEN
        SET p_Resultado = 0;
        SET p_Mensaje = 'Ingresa el título del horario.';
        LEAVE main;
    END IF;

    IF p_Estado IS NULL OR TRIM(p_Estado) = '' THEN
        SET p_Estado = 'Activo';
    END IF;

    START TRANSACTION;

    UPDATE HORARIO SET
        TITULO = p_Titulo,
        DESCRIPCION = p_Descripcion,
        URLIMAGEN = CASE
            WHEN p_UrlImagen IS NOT NULL AND TRIM(p_UrlImagen) <> ''
            THEN p_UrlImagen ELSE URLIMAGEN END,
        ESTADO = p_Estado
    WHERE IDHORARIO = p_Id;

    DELETE FROM HORARIO_AULA WHERE IDHORARIO = p_Id;

    IF p_AulasCsv IS NOT NULL AND TRIM(p_AulasCsv) <> '' THEN
        SET v_csv = CONCAT(p_AulasCsv, ',');
        SET v_pos = 1;
        SET v_seq = 1;

        csv_loop: WHILE v_pos <= CHAR_LENGTH(v_csv) DO
            SET v_next = LOCATE(',', v_csv, v_pos);
            IF v_next = 0 THEN
                LEAVE csv_loop;
            END IF;

            SET v_token = TRIM(SUBSTRING(v_csv, v_pos, v_next - v_pos));

            IF v_token <> '' AND EXISTS (SELECT 1 FROM AULA WHERE IDAULA = v_token) THEN
                INSERT INTO HORARIO_AULA (IDHORARIOAULA, IDHORARIO, IDAULA)
                VALUES (
                    CONCAT(p_Id, '-A', LPAD(CAST(v_seq AS CHAR), 3, '0')),
                    p_Id,
                    v_token
                );
                SET v_seq = v_seq + 1;
            END IF;

            SET v_pos = v_next + 1;
        END WHILE csv_loop;
    END IF;

    COMMIT;
    SET p_Resultado = 1;
    SET p_Mensaje = 'Horario actualizado.';
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_horario_eliminar;

DELIMITER $$

CREATE PROCEDURE usp_horario_eliminar(
    IN p_Id VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
    DECLARE v_err_msg VARCHAR(200);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_Resultado = 0;
        GET DIAGNOSTICS CONDITION 1 v_err_msg = MESSAGE_TEXT;
        SET p_Mensaje = LEFT(v_err_msg, 200);
    END;

    IF NOT EXISTS (SELECT 1 FROM HORARIO WHERE IDHORARIO = p_Id) THEN
        SET p_Resultado = 0;
        SET p_Mensaje = 'El horario no existe.';
        LEAVE main;
    END IF;

    START TRANSACTION;

    DELETE FROM HORARIO_AULA WHERE IDHORARIO = p_Id;
    DELETE FROM HORARIO WHERE IDHORARIO = p_Id;

    COMMIT;
    SET p_Resultado = 1;
    SET p_Mensaje = 'Horario eliminado.';
END$$

DELIMITER ;

SELECT 'SPs usp_horario_* creados.' AS info;
