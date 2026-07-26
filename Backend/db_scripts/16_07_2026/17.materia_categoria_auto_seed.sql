/* ============================================================================
   Código automático CAT### / MAT### + seed materias Academia 2.0
   Ejecutar después de 15.usp_materia_crud.sql
   Fecha: 16/07/2026
   ============================================================================ */

IF OBJECT_ID('dbo.usp_categoria_insertar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_categoria_insertar;
GO
CREATE PROCEDURE dbo.usp_categoria_insertar
    @Nombre      NVARCHAR(100),
    @Porcentaje  DECIMAL(5,2) = NULL,
    @Orden       INT          = 0,
    @Estado      NVARCHAR(50) = 'Activo',
    @IdGenerado  NVARCHAR(50) OUTPUT,
    @Resultado   INT OUTPUT,
    @Mensaje     NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @IdGenerado = NULL;

    IF @Nombre IS NULL OR LTRIM(RTRIM(@Nombre)) = ''
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ingresa el nombre de la categoría.'; RETURN; END

    IF @Porcentaje IS NOT NULL AND (@Porcentaje < 0 OR @Porcentaje > 100)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El porcentaje debe estar entre 0 y 100.'; RETURN; END

    IF EXISTS (SELECT 1 FROM CATEGORIA WHERE NOMBRE = @Nombre)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ya existe una categoría con ese nombre.'; RETURN; END

    DECLARE @NextNum INT;
    SELECT @NextNum = ISNULL(MAX(TRY_CAST(REPLACE(IDCATEGORIA, 'CAT', '') AS INT)), 0) + 1
    FROM CATEGORIA
    WHERE IDCATEGORIA LIKE 'CAT%';
    SET @IdGenerado = 'CAT' + RIGHT('000' + CAST(@NextNum AS VARCHAR(3)), 3);

    INSERT INTO CATEGORIA (IDCATEGORIA, NOMBRE, PORCENTAJE, ORDEN, ACTIVO)
    VALUES (
        @IdGenerado,
        @Nombre,
        @Porcentaje,
        ISNULL(@Orden, 0),
        CASE WHEN @Estado = 'Activo' THEN 1 ELSE 0 END
    );

    SET @Resultado = 1; SET @Mensaje = 'Categoría registrada.';
END;
GO

IF OBJECT_ID('dbo.usp_materia_insertar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_materia_insertar;
GO
CREATE PROCEDURE dbo.usp_materia_insertar
    @Codigo      NVARCHAR(50)  = NULL,
    @Nombre      NVARCHAR(150),
    @IdCategoria NVARCHAR(50)  = NULL,
    @Estado      NVARCHAR(50)  = 'Activo',
    @IdGenerado  NVARCHAR(50) OUTPUT,
    @Resultado   INT OUTPUT,
    @Mensaje     NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @IdGenerado = NULL;

    IF @Nombre IS NULL OR LTRIM(RTRIM(@Nombre)) = ''
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ingresa el nombre de la materia.'; RETURN; END

    IF EXISTS (SELECT 1 FROM MATERIA WHERE NOMBRE = @Nombre)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ya existe una materia con ese nombre.'; RETURN; END

    IF @IdCategoria IS NOT NULL AND LTRIM(RTRIM(@IdCategoria)) <> ''
       AND NOT EXISTS (SELECT 1 FROM CATEGORIA WHERE IDCATEGORIA = @IdCategoria)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'La categoría no existe.'; RETURN; END

    IF @Codigo IS NOT NULL AND LTRIM(RTRIM(@Codigo)) <> ''
       AND EXISTS (SELECT 1 FROM MATERIA WHERE CODIGO = @Codigo)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ya existe una materia con ese código corto.'; RETURN; END

    DECLARE @NextNum INT;
    SELECT @NextNum = ISNULL(MAX(TRY_CAST(REPLACE(IDMATERIA, 'MAT', '') AS INT)), 0) + 1
    FROM MATERIA
    WHERE IDMATERIA LIKE 'MAT%';
    SET @IdGenerado = 'MAT' + RIGHT('000' + CAST(@NextNum AS VARCHAR(3)), 3);

    INSERT INTO MATERIA (IDMATERIA, CODIGO, NOMBRE, IDCATEGORIA, ACTIVO)
    VALUES (
        @IdGenerado,
        NULLIF(LTRIM(RTRIM(@Codigo)), ''),
        @Nombre,
        NULLIF(LTRIM(RTRIM(@IdCategoria)), ''),
        CASE WHEN @Estado = 'Activo' THEN 1 ELSE 0 END
    );

    SET @Resultado = 1; SET @Mensaje = 'Materia registrada.';
END;
GO

-- Seed materias (por CODIGO; no duplica si ya existen)
DECLARE @Base INT;
SELECT @Base = ISNULL(MAX(TRY_CAST(REPLACE(IDMATERIA, 'MAT', '') AS INT)), 0)
FROM MATERIA
WHERE IDMATERIA LIKE 'MAT%';

;WITH Seed AS (
    SELECT
        v.CODIGO,
        v.NOMBRE,
        v.CATEGORIA_NOMBRE,
        ROW_NUMBER() OVER (ORDER BY
            CASE v.CATEGORIA_NOMBRE
                WHEN N'Habilidades' THEN 1
                WHEN N'Matematica' THEN 2
                WHEN N'Humanidades' THEN 3
                WHEN N'Ciencias' THEN 4
                ELSE 9
            END,
            v.CODIGO
        ) AS RN
    FROM (VALUES
        (N'HM',     N'Habilidad Matemática', N'Habilidades'),
        (N'HV',     N'Habilidad Verbal',     N'Habilidades'),
        (N'ARIT',   N'Aritmética',           N'Matematica'),
        (N'GEO',    N'Geometría',            N'Matematica'),
        (N'ALGE',   N'Álgebra',              N'Matematica'),
        (N'TRIGO',  N'Trigonometría',        N'Matematica'),
        (N'LENGUA', N'Lenguaje',             N'Humanidades'),
        (N'PSI',    N'Psicología',           N'Humanidades'),
        (N'CIV',    N'Cívica',               N'Humanidades'),
        (N'HP',     N'Historia del Perú',    N'Humanidades'),
        (N'HU',     N'Historia Universal',   N'Humanidades'),
        (N'GEO_L',  N'Geografía',            N'Humanidades'),
        (N'ECO',    N'Economía',             N'Humanidades'),
        (N'FILO',   N'Filosofía',            N'Humanidades'),
        (N'FIS',    N'Física',               N'Ciencias'),
        (N'QUI',    N'Química',              N'Ciencias'),
        (N'BIO',    N'Biología',             N'Ciencias')
    ) v(CODIGO, NOMBRE, CATEGORIA_NOMBRE)
)
INSERT INTO MATERIA (IDMATERIA, CODIGO, NOMBRE, IDCATEGORIA, ACTIVO)
SELECT
    'MAT' + RIGHT('000' + CAST(@Base + s.RN AS VARCHAR(3)), 3),
    s.CODIGO,
    s.NOMBRE,
    c.IDCATEGORIA,
    1
FROM Seed s
INNER JOIN CATEGORIA c ON c.NOMBRE = s.CATEGORIA_NOMBRE
WHERE NOT EXISTS (
    SELECT 1 FROM MATERIA m
    WHERE m.CODIGO = s.CODIGO OR m.NOMBRE = s.NOMBRE
);
GO

PRINT 'Códigos auto CAT/MAT y seed de materias listos.';
GO
