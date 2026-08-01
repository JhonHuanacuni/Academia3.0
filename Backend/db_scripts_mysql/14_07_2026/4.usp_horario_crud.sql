-- Convertido automáticamente desde db_scripts/14_07_2026/4.usp_horario_crud.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   CRUD HORARIO — Académico
   Prerequisito: 3.horario_tabla.sql
   Fecha: 14/07/2026
   ============================================================================ */

DROP PROCEDURE IF EXISTS usp_horario_listar;

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
    DECLARE v_offset INT DEFAULT 0;
IF p_Pagina < 1 THEN SET p_Pagina = 1; END IF;
    IF p_TamanioPagina < 1 THEN SET p_TamanioPagina = 10; END IF;

    SET v_offset = (p_Pagina - 1) * p_TamanioPagina;
    SELECT COUNT(*) INTO p_TotalRegistros
    FROM HORARIO h
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           h.IDHORARIO   LIKE CONCAT('%', p_Buscar, '%') OR
           h.TITULO      LIKE CONCAT('%', p_Buscar, '%') OR
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
           h.IDHORARIO   LIKE CONCAT('%', p_Buscar, '%') OR
           h.TITULO      LIKE CONCAT('%', p_Buscar, '%') OR
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
    LIMIT p_TamanioPagina OFFSET v_offset;
    SELECT p_TotalRegistros AS TotalRegistros
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_horario_obtener;

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
SET p_IdGenerado = NULL;

    IF p_Titulo IS NULL OR TRIM(p_Titulo) = '' THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa el título del horario.';
        LEAVE main;
    
    END IF;

    IF p_Estado IS NULL OR TRIM(p_Estado) = '' THEN SET p_Estado = 'Activo'; END IF;

    IF p_FechaSubida IS NULL OR TRIM(p_FechaSubida) = '' OR LEN(p_FechaSubida) <> 8 THEN SET p_FechaSubida =
            RIGHT(CONCAT('0', CAST(DAY(NOW())) AS VARCHAR(2)), 2) +
            RIGHT(CONCAT('0', CAST(MONTH(NOW())) AS VARCHAR(2)), 2) +
            CAST(YEAR(NOW()) AS VARCHAR(4)); END IF;

    DECLARE v_NextNum INT;
    SELECT IFNULL(MAX(CAST(IDHORARIO AS INT)), 0) + 1 FROM HORARIO INTO v_NextNum;
    SET p_IdGenerado = CAST(v_NextNum AS VARCHAR(50));

    BEGIN TRY
        BEGIN TRAN;

        INSERT INTO HORARIO (IDHORARIO, TITULO, DESCRIPCION, URLIMAGEN, FECHASUBIDA, ESTADO)
        VALUES (p_IdGenerado, p_Titulo, p_Descripcion, p_UrlImagen, p_FechaSubida, p_Estado);

        IF p_AulasCsv IS NOT NULL AND TRIM(p_AulasCsv) <> '' THEN
            DECLARE v_pos INT = 1, @next INT, @token VARCHAR(50), @seq INT = 1;
            DECLARE v_csv LONGTEXT = CONCAT(p_AulasCsv, ',');

            WHILE v_pos <= LEN(v_csv)
            BEGIN
                SET @next = CHARINDEX(',', v_csv, v_pos);
                IF @next = 0 BREAK;
                SET @token = TRIM(SUBSTRING(v_csv, v_pos, @next - v_pos)));
                IF @token <> '' AND EXISTS (SELECT 1 FROM AULA WHERE IDAULA = @token) THEN
                    INSERT INTO HORARIO_AULA (IDHORARIOAULA, IDHORARIO, IDAULA)
                    VALUES (CONCAT(p_IdGenerado, '-A') RIGHT('000', CAST(@seq AS VARCHAR(3)), 3), p_IdGenerado, @token);
                    SET @seq = @CONCAT(seq, 1);
                
                SET v_pos = @CONCAT(next, 1);
            
        
        COMMIT TRAN;
        SET p_Resultado = 1; SET p_Mensaje = 'Horario registrado.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        SET p_IdGenerado = NULL;
        SET p_Resultado = 0;
        SET p_Mensaje = LEFT(ERROR_MESSAGE(), 200);
    END CATCH
    SELECT p_IdGenerado AS IdGenerado, p_Resultado AS Resultado, p_Mensaje AS Mensaje
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_horario_actualizar;

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
IF NOT EXISTS (SELECT 1 FROM HORARIO WHERE IDHORARIO = p_Id) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'El horario no existe.';
        LEAVE main;
    
    END IF;

    IF p_Titulo IS NULL OR TRIM(p_Titulo) = '' THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa el título del horario.';
        LEAVE main;
    
    END IF;

    IF p_Estado IS NULL OR TRIM(p_Estado) = '' THEN SET p_Estado = 'Activo'; END IF;

    BEGIN TRY
        BEGIN TRAN;

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
            DECLARE v_pos INT = 1, @next INT, @token VARCHAR(50), @seq INT = 1;
            DECLARE v_csv LONGTEXT = CONCAT(p_AulasCsv, ',');

            WHILE v_pos <= LEN(v_csv)
            BEGIN
                SET @next = CHARINDEX(',', v_csv, v_pos);
                IF @next = 0 BREAK;
                SET @token = TRIM(SUBSTRING(v_csv, v_pos, @next - v_pos)));
                IF @token <> '' AND EXISTS (SELECT 1 FROM AULA WHERE IDAULA = @token) THEN
                    INSERT INTO HORARIO_AULA (IDHORARIOAULA, IDHORARIO, IDAULA)
                    VALUES (CONCAT(p_Id, '-A') RIGHT('000', CAST(@seq AS VARCHAR(3)), 3), p_Id, @token);
                    SET @seq = @CONCAT(seq, 1);
                
                SET v_pos = @CONCAT(next, 1);
            
        
        COMMIT TRAN;
        SET p_Resultado = 1; SET p_Mensaje = 'Horario actualizado.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        SET p_Resultado = 0;
        SET p_Mensaje = LEFT(ERROR_MESSAGE(), 200);
    END CATCH
    SELECT p_Resultado AS Resultado, p_Mensaje AS Mensaje
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_horario_eliminar;

DROP PROCEDURE IF EXISTS usp_horario_eliminar;

DELIMITER $$

CREATE PROCEDURE usp_horario_eliminar(
    IN p_Id VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
IF NOT EXISTS (SELECT 1 FROM HORARIO WHERE IDHORARIO = p_Id) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'El horario no existe.';
        LEAVE main;
    
    BEGIN TRY
        BEGIN TRAN;
        DELETE FROM HORARIO_AULA WHERE IDHORARIO = p_Id;
        DELETE FROM HORARIO WHERE IDHORARIO = p_Id;
        COMMIT TRAN;
        SET p_Resultado = 1; SET p_Mensaje = 'Horario eliminado.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        SET p_Resultado = 0;
        SET p_Mensaje = LEFT(ERROR_MESSAGE(), 200);
    END CATCH
END;

SELECT 'SPs usp_horario_* creados.';
    SELECT p_Resultado AS Resultado, p_Mensaje AS Mensaje
END$$

DELIMITER ;