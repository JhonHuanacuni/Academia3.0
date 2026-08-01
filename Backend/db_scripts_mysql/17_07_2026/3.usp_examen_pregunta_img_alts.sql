-- Convertido automáticamente desde db_scripts/17_07_2026/3.usp_examen_pregunta_img_alts.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   Pregunta guardar: imágenes por alternativa A–E
   Fecha: 17/07/2026
   ============================================================================ */

DROP PROCEDURE IF EXISTS usp_examen_pregunta_guardar;

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
    IN p_ImgAlt1 VARCHAR(255),
    IN p_ImgAlt2 VARCHAR(255),
    IN p_ImgAlt3 VARCHAR(255),
    IN p_ImgAlt4 VARCHAR(255),
    IN p_ImgAlt5 VARCHAR(255),
    IN p_QuitarImgAlt1 TINYINT(1),
    IN p_QuitarImgAlt2 TINYINT(1),
    IN p_QuitarImgAlt3 TINYINT(1),
    IN p_QuitarImgAlt4 TINYINT(1),
    IN p_QuitarImgAlt5 TINYINT(1),
    IN p_CorrectaOrden INT,
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
IF NOT EXISTS (SELECT 1 FROM PREGUNTA WHERE IDPREGUNTA = p_IdPregunta AND IDEXAMEN = p_IdExamen)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'La pregunta no existe en este examen.'; LEAVE main; 
    END IF;

    IF p_CorrectaOrden IS NULL OR p_CorrectaOrden < 1 OR p_CorrectaOrden > 5 THEN SET p_CorrectaOrden = 1; END IF;

    UPDATE PREGUNTA SET
        DESCRIPCION = p_Descripcion,
        IMAGEURL = CASE
            WHEN p_QuitarImagen = 1 THEN NULL
            WHEN p_ImageUrl IS NOT NULL AND TRIM(p_ImageUrl) <> '' THEN p_ImageUrl
            ELSE IMAGEURL
        
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
        IMAGEURL = CASE ORDEN
            WHEN 1 THEN CASE
                WHEN p_QuitarImgAlt1 = 1 THEN NULL
                WHEN p_ImgAlt1 IS NOT NULL AND TRIM(p_ImgAlt1) <> '' THEN p_ImgAlt1
                ELSE IMAGEURL 
            WHEN 2 THEN CASE
                WHEN p_QuitarImgAlt2 = 1 THEN NULL
                WHEN p_ImgAlt2 IS NOT NULL AND TRIM(p_ImgAlt2) <> '' THEN p_ImgAlt2
                ELSE IMAGEURL 
            WHEN 3 THEN CASE
                WHEN p_QuitarImgAlt3 = 1 THEN NULL
                WHEN p_ImgAlt3 IS NOT NULL AND TRIM(p_ImgAlt3) <> '' THEN p_ImgAlt3
                ELSE IMAGEURL 
            WHEN 4 THEN CASE
                WHEN p_QuitarImgAlt4 = 1 THEN NULL
                WHEN p_ImgAlt4 IS NOT NULL AND TRIM(p_ImgAlt4) <> '' THEN p_ImgAlt4
                ELSE IMAGEURL 
            WHEN 5 THEN CASE
                WHEN p_QuitarImgAlt5 = 1 THEN NULL
                WHEN p_ImgAlt5 IS NOT NULL AND TRIM(p_ImgAlt5) <> '' THEN p_ImgAlt5
                ELSE IMAGEURL 
            ELSE IMAGEURL
        END,
        ESCORRECTA = CASE WHEN ORDEN = p_CorrectaOrden THEN 1 ELSE 0 END
    WHERE IDPREGUNTA = p_IdPregunta;

    SET p_Resultado = 1; SET p_Mensaje = 'Pregunta guardada.';
END;

SELECT 'usp_examen_pregunta_guardar: imágenes por alternativa.';
    SELECT p_Resultado AS Resultado, p_Mensaje AS Mensaje
END$$

DELIMITER ;