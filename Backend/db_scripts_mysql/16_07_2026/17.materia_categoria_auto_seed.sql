-- ============================================================================
-- Código automático CAT### / MAT### + seed materias Academia 2.0 — MySQL 8
-- Ejecutar después de 15.usp_materia_crud.sql
-- Fecha: 16/07/2026
-- ============================================================================

USE `AcademiaDB`;

DROP PROCEDURE IF EXISTS usp_categoria_insertar;

DELIMITER $$

CREATE PROCEDURE usp_categoria_insertar(
    IN p_Nombre VARCHAR(100),
    IN p_Porcentaje DECIMAL(5,2),
    IN p_Orden INT,
    IN p_Estado VARCHAR(50),
    OUT p_IdGenerado VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
    DECLARE v_NextNum INT DEFAULT 0;

    SET p_IdGenerado = NULL;

    IF p_Nombre IS NULL OR TRIM(p_Nombre) = '' THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa el nombre de la categoría.';
        LEAVE main;
    END IF;

    IF p_Porcentaje IS NOT NULL AND (p_Porcentaje < 0 OR p_Porcentaje > 100) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'El porcentaje debe estar entre 0 y 100.';
        LEAVE main;
    END IF;

    IF EXISTS (SELECT 1 FROM CATEGORIA WHERE NOMBRE = p_Nombre) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ya existe una categoría con ese nombre.';
        LEAVE main;
    END IF;

    SELECT IFNULL(MAX(CAST(REPLACE(IDCATEGORIA, 'CAT', '') AS UNSIGNED)), 0) + 1 INTO v_NextNum
    FROM CATEGORIA WHERE IDCATEGORIA LIKE 'CAT%';
    SET p_IdGenerado = CONCAT('CAT', LPAD(CAST(v_NextNum AS CHAR), 3, '0'));

    INSERT INTO CATEGORIA (IDCATEGORIA, NOMBRE, PORCENTAJE, ORDEN, ACTIVO)
    VALUES (
        p_IdGenerado,
        p_Nombre,
        p_Porcentaje,
        IFNULL(p_Orden, 0),
        CASE WHEN p_Estado = 'Activo' THEN 1 ELSE 0 END
    );

    SET p_Resultado = 1; SET p_Mensaje = 'Categoría registrada.';
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_materia_insertar;

DELIMITER $$

CREATE PROCEDURE usp_materia_insertar(
    IN p_Codigo VARCHAR(50),
    IN p_Nombre VARCHAR(150),
    IN p_IdCategoria VARCHAR(50),
    IN p_Estado VARCHAR(50),
    OUT p_IdGenerado VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
    DECLARE v_NextNum INT DEFAULT 0;

    SET p_IdGenerado = NULL;

    IF p_Nombre IS NULL OR TRIM(p_Nombre) = '' THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa el nombre de la materia.';
        LEAVE main;
    END IF;

    IF EXISTS (SELECT 1 FROM MATERIA WHERE NOMBRE = p_Nombre) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ya existe una materia con ese nombre.';
        LEAVE main;
    END IF;

    IF p_IdCategoria IS NOT NULL AND TRIM(p_IdCategoria) <> ''
       AND NOT EXISTS (SELECT 1 FROM CATEGORIA WHERE IDCATEGORIA = p_IdCategoria) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'La categoría no existe.';
        LEAVE main;
    END IF;

    IF p_Codigo IS NOT NULL AND TRIM(p_Codigo) <> ''
       AND EXISTS (SELECT 1 FROM MATERIA WHERE CODIGO = p_Codigo) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ya existe una materia con ese código corto.';
        LEAVE main;
    END IF;

    SELECT IFNULL(MAX(CAST(REPLACE(IDMATERIA, 'MAT', '') AS UNSIGNED)), 0) + 1 INTO v_NextNum
    FROM MATERIA WHERE IDMATERIA LIKE 'MAT%';
    SET p_IdGenerado = CONCAT('MAT', LPAD(CAST(v_NextNum AS CHAR), 3, '0'));

    INSERT INTO MATERIA (IDMATERIA, CODIGO, NOMBRE, IDCATEGORIA, ACTIVO)
    VALUES (
        p_IdGenerado,
        NULLIF(TRIM(p_Codigo), ''),
        p_Nombre,
        NULLIF(TRIM(p_IdCategoria), ''),
        CASE WHEN p_Estado = 'Activo' THEN 1 ELSE 0 END
    );

    SET p_Resultado = 1; SET p_Mensaje = 'Materia registrada.';
END$$

DELIMITER ;

-- Seed materias por CODIGO (no duplica si ya existen)
INSERT INTO MATERIA (IDMATERIA, CODIGO, NOMBRE, IDCATEGORIA, ACTIVO)
SELECT
    CONCAT('MAT', LPAD(CAST(seed_base.max_num + s.rn AS CHAR), 3, '0')),
    s.CODIGO,
    s.NOMBRE,
    c.IDCATEGORIA,
    1
FROM (
    SELECT v.CODIGO, v.NOMBRE, v.CATEGORIA_NOMBRE,
           ROW_NUMBER() OVER (ORDER BY
               CASE v.CATEGORIA_NOMBRE
                   WHEN 'Habilidades' THEN 1
                   WHEN 'Matematica' THEN 2
                   WHEN 'Humanidades' THEN 3
                   WHEN 'Ciencias' THEN 4
                   ELSE 9
               END,
               v.CODIGO
           ) AS rn
    FROM (
        SELECT 'HM' AS CODIGO, 'Habilidad Matemática' AS NOMBRE, 'Habilidades' AS CATEGORIA_NOMBRE UNION ALL
        SELECT 'HV', 'Habilidad Verbal', 'Habilidades' UNION ALL
        SELECT 'ARIT', 'Aritmética', 'Matematica' UNION ALL
        SELECT 'GEO', 'Geometría', 'Matematica' UNION ALL
        SELECT 'ALGE', 'Álgebra', 'Matematica' UNION ALL
        SELECT 'TRIGO', 'Trigonometría', 'Matematica' UNION ALL
        SELECT 'LENGUA', 'Lenguaje', 'Humanidades' UNION ALL
        SELECT 'PSI', 'Psicología', 'Humanidades' UNION ALL
        SELECT 'CIV', 'Cívica', 'Humanidades' UNION ALL
        SELECT 'HP', 'Historia del Perú', 'Humanidades' UNION ALL
        SELECT 'HU', 'Historia Universal', 'Humanidades' UNION ALL
        SELECT 'GEO_L', 'Geografía', 'Humanidades' UNION ALL
        SELECT 'ECO', 'Economía', 'Humanidades' UNION ALL
        SELECT 'FILO', 'Filosofía', 'Humanidades' UNION ALL
        SELECT 'FIS', 'Física', 'Ciencias' UNION ALL
        SELECT 'QUI', 'Química', 'Ciencias' UNION ALL
        SELECT 'BIO', 'Biología', 'Ciencias'
    ) v
) s
INNER JOIN CATEGORIA c ON c.NOMBRE = s.CATEGORIA_NOMBRE
CROSS JOIN (
    SELECT IFNULL(MAX(CAST(REPLACE(IDMATERIA, 'MAT', '') AS UNSIGNED)), 0) AS max_num
    FROM MATERIA
    WHERE IDMATERIA LIKE 'MAT%'
) seed_base
WHERE NOT EXISTS (
    SELECT 1 FROM MATERIA m
    WHERE m.CODIGO = s.CODIGO OR m.NOMBRE = s.NOMBRE
);
