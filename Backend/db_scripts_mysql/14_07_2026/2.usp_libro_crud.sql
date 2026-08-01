-- Convertido automáticamente desde db_scripts/14_07_2026/2.usp_libro_crud.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   CRUD LIBRO — Biblioteca (Académico)
   Prerequisito: 1.libro_fechassubida_libro_aula.sql
   Fecha: 14/07/2026
   ============================================================================ */

DROP PROCEDURE IF EXISTS usp_libro_listar;

DROP PROCEDURE IF EXISTS usp_libro_listar;

DELIMITER $$

CREATE PROCEDURE usp_libro_listar(
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

    SELECT COUNT(*) INTO p_TotalRegistros
    FROM LIBRO l
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           l.IDLIBRO    LIKE CONCAT('%', p_Buscar, '%') OR
           l.TITULO     LIKE CONCAT('%', p_Buscar, '%') OR
           l.DESCRIPCION LIKE CONCAT('%', p_Buscar, '%'))
      AND (p_Estado IS NULL OR p_Estado = '' OR l.ESTADO = p_Estado);

    SELECT
        l.IDLIBRO,
        l.TITULO,
        l.DESCRIPCION,
        l.FECHASUBIDA,
        l.ESTADO,
        l.URLCONTENIDO,
        l.IMGPORTADA
    FROM LIBRO l
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           l.IDLIBRO    LIKE CONCAT('%', p_Buscar, '%') OR
           l.TITULO     LIKE CONCAT('%', p_Buscar, '%') OR
           l.DESCRIPCION LIKE CONCAT('%', p_Buscar, '%'))
      AND (p_Estado IS NULL OR p_Estado = '' OR l.ESTADO = p_Estado)
    ORDER BY
        CASE WHEN p_OrdenarPor = 'IDLIBRO'     AND p_Direccion = 'ASC'  THEN l.IDLIBRO END ASC,
        CASE WHEN p_OrdenarPor = 'IDLIBRO'     AND p_Direccion = 'DESC' THEN l.IDLIBRO END DESC,
        CASE WHEN p_OrdenarPor = 'TITULO'      AND p_Direccion = 'ASC'  THEN l.TITULO END ASC,
        CASE WHEN p_OrdenarPor = 'TITULO'      AND p_Direccion = 'DESC' THEN l.TITULO END DESC,
        CASE WHEN p_OrdenarPor = 'FECHASUBIDA' AND p_Direccion = 'ASC'  THEN l.FECHASUBIDA END ASC,
        CASE WHEN p_OrdenarPor = 'FECHASUBIDA' AND p_Direccion = 'DESC' THEN l.FECHASUBIDA END DESC,
        CASE WHEN p_OrdenarPor = 'ESTADO'      AND p_Direccion = 'ASC'  THEN l.ESTADO END ASC,
        CASE WHEN p_OrdenarPor = 'ESTADO'      AND p_Direccion = 'DESC' THEN l.ESTADO END DESC,
        l.FECHASUBIDA DESC, l.IDLIBRO DESC
    LIMIT p_TamanioPagina OFFSET ((p_Pagina - 1) * p_TamanioPagina);
    SELECT p_TotalRegistros AS TotalRegistros
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_libro_obtener;

DROP PROCEDURE IF EXISTS usp_libro_obtener;

DELIMITER $$

CREATE PROCEDURE usp_libro_obtener(
    IN p_Id VARCHAR(50)
)
main: BEGIN
SELECT
        l.IDLIBRO,
        l.TITULO,
        l.DESCRIPCION,
        l.AUTOR,
        l.ANIOPUBLICACION,
        l.URLCONTENIDO,
        l.IMGPORTADA,
        l.FECHASUBIDA,
        l.ESTADO
    FROM LIBRO l
    WHERE l.IDLIBRO = p_Id;

    SELECT la.IDAULA
    FROM LIBRO_AULA la
    WHERE la.IDLIBRO = p_Id
    ORDER BY la.IDAULA;
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_libro_insertar;

DROP PROCEDURE IF EXISTS usp_libro_insertar;

DELIMITER $$

CREATE PROCEDURE usp_libro_insertar(
    IN p_Titulo VARCHAR(200),
    IN p_Descripcion LONGTEXT,
    IN p_UrlContenido VARCHAR(255),
    IN p_ImgPortada VARCHAR(255),
    IN p_FechaSubida CHAR(8),
    IN p_Estado VARCHAR(50),
    IN p_AulasCsv L,
    OUT p_IdGenerado VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
SET p_IdGenerado = NULL;

    IF p_Titulo IS NULL OR TRIM(p_Titulo)) = ''
    BEGIN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa el título del documento.';
        LEAVE main;
    
    IF p_Estado IS NULL OR TRIM(p_Estado)) = '' THEN SET p_Estado = 'Activo'; END IF;

    IF p_FechaSubida IS NULL OR TRIM(p_FechaSubida)) = '' OR LEN(p_FechaSubida) <> 8 THEN SET p_FechaSubida =
            RIGHT('0' + CAST(DAY(NOW()) AS VARCHAR(2)), 2) +
            RIGHT('0' + CAST(MONTH(NOW()) AS VARCHAR(2)), 2) +
            CAST(YEAR(NOW()) AS VARCHAR(4)); END IF;

    DECLARE v_NextNum INT;
    SELECT IFNULL(MAX(CAST(IDLIBRO AS INT)), 0) + 1 FROM LIBRO INTO v_NextNum;
    SET p_IdGenerado = CAST(v_NextNum AS VARCHAR(50));

    BEGIN TRY
        BEGIN TRAN;

        INSERT INTO LIBRO (
            IDLIBRO, TITULO, DESCRIPCION, URLCONTENIDO, IMGPORTADA, FECHASUBIDA, ESTADO
        )
        VALUES (
            p_IdGenerado, p_Titulo, p_Descripcion, p_UrlContenido, p_ImgPortada, p_FechaSubida, p_Estado
        );

        IF p_AulasCsv IS NOT NULL AND TRIM(p_AulasCsv)) <> ''
        BEGIN
            DECLARE v_pos INT = 1, @next INT, @token VARCHAR(50), @seq INT = 1;
            DECLARE v_csv LONGTEXT = CONCAT(p_AulasCsv, ',');

            WHILE v_pos <= LEN(v_csv)
            BEGIN
                SET @next = CHARINDEX(',', v_csv, v_pos);
                IF @next = 0 BREAK;
                SET @token = TRIM(SUBSTRING(v_csv, v_pos, @next - v_pos)));
                IF @token <> '' AND EXISTS (SELECT 1 FROM AULA WHERE IDAULA = @token)
                BEGIN
                    INSERT INTO LIBRO_AULA (IDLIBROAULA, IDLIBRO, IDAULA)
                    VALUES (CONCAT(p_IdGenerado, '-A') + RIGHT('000' + CAST(@seq AS VARCHAR(3)), 3), p_IdGenerado, @token);
                    SET @seq = @seq + 1;
                
                SET v_pos = @next + 1;
            
        
        COMMIT TRAN;
        SET p_Resultado = 1; SET p_Mensaje = 'Documento registrado.';
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

DROP PROCEDURE IF EXISTS usp_libro_actualizar;

DROP PROCEDURE IF EXISTS usp_libro_actualizar;

DELIMITER $$

CREATE PROCEDURE usp_libro_actualizar(
    IN p_Id VARCHAR(50),
    IN p_Titulo VARCHAR(200),
    IN p_Descripcion LONGTEXT,
    IN p_UrlContenido VARCHAR(255),
    IN p_ImgPortada VARCHAR(255),
    IN p_Estado VARCHAR(50),
    IN p_AulasCsv LONGTEXT,
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
IF NOT EXISTS (SELECT 1 FROM LIBRO WHERE IDLIBRO = p_Id)
    BEGIN
        SET p_Resultado = 0; SET p_Mensaje = 'El documento no existe.';
        LEAVE main;
    
    IF p_Titulo IS NULL OR TRIM(p_Titulo)) = ''
    BEGIN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa el título del documento.';
        LEAVE main;
    
    IF p_Estado IS NULL OR TRIM(p_Estado)) = '' THEN SET p_Estado = 'Activo'; END IF;

    BEGIN TRY
        BEGIN TRAN;

        UPDATE LIBRO SET
            TITULO = p_Titulo,
            DESCRIPCION = p_Descripcion,
            URLCONTENIDO = CASE
                WHEN p_UrlContenido IS NOT NULL AND TRIM(p_UrlContenido)) <> ''
                THEN p_UrlContenido ELSE URLCONTENIDO END,
            IMGPORTADA = CASE
                WHEN p_ImgPortada IS NOT NULL AND TRIM(p_ImgPortada)) <> ''
                THEN p_ImgPortada ELSE IMGPORTADA END,
            ESTADO = p_Estado
        WHERE IDLIBRO = p_Id;

        DELETE FROM LIBRO_AULA WHERE IDLIBRO = p_Id;

        IF p_AulasCsv IS NOT NULL AND TRIM(p_AulasCsv)) <> ''
        BEGIN
            DECLARE v_pos INT = 1, @next INT, @token VARCHAR(50), @seq INT = 1;
            DECLARE v_csv LONGTEXT = CONCAT(p_AulasCsv, ',');

            WHILE v_pos <= LEN(v_csv)
            BEGIN
                SET @next = CHARINDEX(',', v_csv, v_pos);
                IF @next = 0 BREAK;
                SET @token = TRIM(SUBSTRING(v_csv, v_pos, @next - v_pos)));
                IF @token <> '' AND EXISTS (SELECT 1 FROM AULA WHERE IDAULA = @token)
                BEGIN
                    INSERT INTO LIBRO_AULA (IDLIBROAULA, IDLIBRO, IDAULA)
                    VALUES (CONCAT(p_Id, '-A') + RIGHT('000' + CAST(@seq AS VARCHAR(3)), 3), p_Id, @token);
                    SET @seq = @seq + 1;
                
                SET v_pos = @next + 1;
            
        
        COMMIT TRAN;
        SET p_Resultado = 1; SET p_Mensaje = 'Documento actualizado.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        SET p_Resultado = 0;
        SET p_Mensaje = LEFT(ERROR_MESSAGE(), 200);
    END CATCH
    SELECT p_Resultado AS Resultado, p_Mensaje AS Mensaje
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_libro_eliminar;

DROP PROCEDURE IF EXISTS usp_libro_eliminar;

DELIMITER $$

CREATE PROCEDURE usp_libro_eliminar(
    IN p_Id VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
IF NOT EXISTS (SELECT 1 FROM LIBRO WHERE IDLIBRO = p_Id)
    BEGIN
        SET p_Resultado = 0; SET p_Mensaje = 'El documento no existe.';
        LEAVE main;
    
    BEGIN TRY
        BEGIN TRAN;

        DELETE FROM LIBRO_ACCESO WHERE IDLIBRO = p_Id;
        DELETE FROM LIBRO_MATERIA WHERE IDLIBRO = p_Id;
        DELETE FROM LIBRO_AULA WHERE IDLIBRO = p_Id;
        DELETE FROM LIBRO WHERE IDLIBRO = p_Id;

        COMMIT TRAN;
        SET p_Resultado = 1; SET p_Mensaje = 'Documento eliminado.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        SET p_Resultado = 0;
        SET p_Mensaje = LEFT(ERROR_MESSAGE(), 200);
    END CATCH
END;

SELECT 'SPs usp_libro_* creados.';
    SELECT p_Resultado AS Resultado, p_Mensaje AS Mensaje
END$$

DELIMITER ;
