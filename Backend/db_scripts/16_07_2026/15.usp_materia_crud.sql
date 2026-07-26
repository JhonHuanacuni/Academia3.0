/* ============================================================================
   CRUD MATERIA (con categoría)
   Ejecutar después de 14.usp_categoria_crud.sql
   Fecha: 16/07/2026
   ============================================================================ */

IF OBJECT_ID('dbo.usp_materia_listar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_materia_listar;
GO
CREATE PROCEDURE dbo.usp_materia_listar
    @Buscar         NVARCHAR(200) = NULL,
    @Estado         NVARCHAR(50)  = NULL,
    @IdCategoria    NVARCHAR(50)  = NULL,
    @OrdenarPor     NVARCHAR(50)  = 'NOMBRE',
    @Direccion      NVARCHAR(4)   = 'ASC',
    @Pagina         INT           = 1,
    @TamanioPagina  INT           = 10,
    @TotalRegistros INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    IF @Pagina < 1 SET @Pagina = 1;
    IF @TamanioPagina < 1 SET @TamanioPagina = 10;

    SELECT @TotalRegistros = COUNT(*)
    FROM MATERIA m
    LEFT JOIN CATEGORIA c ON c.IDCATEGORIA = m.IDCATEGORIA
    WHERE (@Buscar IS NULL OR @Buscar = '' OR
           m.IDMATERIA LIKE '%' + @Buscar + '%' OR
           ISNULL(m.CODIGO, '') LIKE '%' + @Buscar + '%' OR
           m.NOMBRE LIKE '%' + @Buscar + '%' OR
           ISNULL(c.NOMBRE, '') LIKE '%' + @Buscar + '%')
      AND (@Estado IS NULL OR @Estado = '' OR
           (@Estado = 'Activo' AND ISNULL(m.ACTIVO, 1) = 1) OR
           (@Estado = 'Inactivo' AND ISNULL(m.ACTIVO, 1) = 0))
      AND (@IdCategoria IS NULL OR @IdCategoria = '' OR m.IDCATEGORIA = @IdCategoria);

    SELECT
        m.IDMATERIA,
        m.CODIGO,
        m.NOMBRE,
        m.IDCATEGORIA,
        ISNULL(c.NOMBRE, '') AS CATEGORIA_NOMBRE,
        CASE WHEN ISNULL(m.ACTIVO, 1) = 1 THEN 'Activo' ELSE 'Inactivo' END AS ESTADO
    FROM MATERIA m
    LEFT JOIN CATEGORIA c ON c.IDCATEGORIA = m.IDCATEGORIA
    WHERE (@Buscar IS NULL OR @Buscar = '' OR
           m.IDMATERIA LIKE '%' + @Buscar + '%' OR
           ISNULL(m.CODIGO, '') LIKE '%' + @Buscar + '%' OR
           m.NOMBRE LIKE '%' + @Buscar + '%' OR
           ISNULL(c.NOMBRE, '') LIKE '%' + @Buscar + '%')
      AND (@Estado IS NULL OR @Estado = '' OR
           (@Estado = 'Activo' AND ISNULL(m.ACTIVO, 1) = 1) OR
           (@Estado = 'Inactivo' AND ISNULL(m.ACTIVO, 1) = 0))
      AND (@IdCategoria IS NULL OR @IdCategoria = '' OR m.IDCATEGORIA = @IdCategoria)
    ORDER BY
        CASE WHEN @OrdenarPor = 'IDMATERIA' AND @Direccion = 'ASC'  THEN m.IDMATERIA END ASC,
        CASE WHEN @OrdenarPor = 'IDMATERIA' AND @Direccion = 'DESC' THEN m.IDMATERIA END DESC,
        CASE WHEN @OrdenarPor = 'CODIGO' AND @Direccion = 'ASC'  THEN m.CODIGO END ASC,
        CASE WHEN @OrdenarPor = 'CODIGO' AND @Direccion = 'DESC' THEN m.CODIGO END DESC,
        CASE WHEN @OrdenarPor = 'NOMBRE' AND @Direccion = 'ASC'  THEN m.NOMBRE END ASC,
        CASE WHEN @OrdenarPor = 'NOMBRE' AND @Direccion = 'DESC' THEN m.NOMBRE END DESC,
        CASE WHEN @OrdenarPor = 'CATEGORIA_NOMBRE' AND @Direccion = 'ASC'  THEN c.NOMBRE END ASC,
        CASE WHEN @OrdenarPor = 'CATEGORIA_NOMBRE' AND @Direccion = 'DESC' THEN c.NOMBRE END DESC,
        CASE WHEN @OrdenarPor = 'ESTADO' AND @Direccion = 'ASC'  THEN m.ACTIVO END ASC,
        CASE WHEN @OrdenarPor = 'ESTADO' AND @Direccion = 'DESC' THEN m.ACTIVO END DESC,
        m.NOMBRE
    OFFSET (@Pagina - 1) * @TamanioPagina ROWS
    FETCH NEXT @TamanioPagina ROWS ONLY;
END;
GO

IF OBJECT_ID('dbo.usp_materia_obtener', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_materia_obtener;
GO
CREATE PROCEDURE dbo.usp_materia_obtener
    @Id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        m.IDMATERIA,
        m.CODIGO,
        m.NOMBRE,
        m.IDCATEGORIA,
        ISNULL(c.NOMBRE, '') AS CATEGORIA_NOMBRE,
        CASE WHEN ISNULL(m.ACTIVO, 1) = 1 THEN 'Activo' ELSE 'Inactivo' END AS ESTADO
    FROM MATERIA m
    LEFT JOIN CATEGORIA c ON c.IDCATEGORIA = m.IDCATEGORIA
    WHERE m.IDMATERIA = @Id;
END;
GO

IF OBJECT_ID('dbo.usp_materia_insertar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_materia_insertar;
GO
CREATE PROCEDURE dbo.usp_materia_insertar
    @Id          NVARCHAR(50),
    @Codigo      NVARCHAR(50)  = NULL,
    @Nombre      NVARCHAR(150),
    @IdCategoria NVARCHAR(50)  = NULL,
    @Estado      NVARCHAR(50)  = 'Activo',
    @Resultado   INT OUTPUT,
    @Mensaje     NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF @Id IS NULL OR LTRIM(RTRIM(@Id)) = ''
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ingresa el código de la materia.'; RETURN; END

    IF @Nombre IS NULL OR LTRIM(RTRIM(@Nombre)) = ''
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ingresa el nombre de la materia.'; RETURN; END

    IF EXISTS (SELECT 1 FROM MATERIA WHERE IDMATERIA = @Id)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El código de materia ya existe.'; RETURN; END

    IF EXISTS (SELECT 1 FROM MATERIA WHERE NOMBRE = @Nombre)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ya existe una materia con ese nombre.'; RETURN; END

    IF @IdCategoria IS NOT NULL AND LTRIM(RTRIM(@IdCategoria)) <> ''
       AND NOT EXISTS (SELECT 1 FROM CATEGORIA WHERE IDCATEGORIA = @IdCategoria)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'La categoría no existe.'; RETURN; END

    IF @Codigo IS NOT NULL AND LTRIM(RTRIM(@Codigo)) <> ''
       AND EXISTS (SELECT 1 FROM MATERIA WHERE CODIGO = @Codigo)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ya existe una materia con ese código corto.'; RETURN; END

    INSERT INTO MATERIA (IDMATERIA, CODIGO, NOMBRE, IDCATEGORIA, ACTIVO)
    VALUES (
        @Id,
        NULLIF(LTRIM(RTRIM(@Codigo)), ''),
        @Nombre,
        NULLIF(LTRIM(RTRIM(@IdCategoria)), ''),
        CASE WHEN @Estado = 'Activo' THEN 1 ELSE 0 END
    );

    SET @Resultado = 1; SET @Mensaje = 'Materia registrada.';
END;
GO

IF OBJECT_ID('dbo.usp_materia_actualizar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_materia_actualizar;
GO
CREATE PROCEDURE dbo.usp_materia_actualizar
    @Id          NVARCHAR(50),
    @Codigo      NVARCHAR(50)  = NULL,
    @Nombre      NVARCHAR(150),
    @IdCategoria NVARCHAR(50)  = NULL,
    @Estado      NVARCHAR(50)  = 'Activo',
    @Resultado   INT OUTPUT,
    @Mensaje     NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM MATERIA WHERE IDMATERIA = @Id)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'La materia no existe.'; RETURN; END

    IF @Nombre IS NULL OR LTRIM(RTRIM(@Nombre)) = ''
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ingresa el nombre de la materia.'; RETURN; END

    IF EXISTS (SELECT 1 FROM MATERIA WHERE NOMBRE = @Nombre AND IDMATERIA <> @Id)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ya existe una materia con ese nombre.'; RETURN; END

    IF @IdCategoria IS NOT NULL AND LTRIM(RTRIM(@IdCategoria)) <> ''
       AND NOT EXISTS (SELECT 1 FROM CATEGORIA WHERE IDCATEGORIA = @IdCategoria)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'La categoría no existe.'; RETURN; END

    IF @Codigo IS NOT NULL AND LTRIM(RTRIM(@Codigo)) <> ''
       AND EXISTS (SELECT 1 FROM MATERIA WHERE CODIGO = @Codigo AND IDMATERIA <> @Id)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ya existe una materia con ese código corto.'; RETURN; END

    UPDATE MATERIA SET
        CODIGO      = NULLIF(LTRIM(RTRIM(@Codigo)), ''),
        NOMBRE      = @Nombre,
        IDCATEGORIA = NULLIF(LTRIM(RTRIM(@IdCategoria)), ''),
        ACTIVO      = CASE WHEN @Estado = 'Activo' THEN 1 ELSE 0 END
    WHERE IDMATERIA = @Id;

    SET @Resultado = 1; SET @Mensaje = 'Materia actualizada.';
END;
GO

IF OBJECT_ID('dbo.usp_materia_eliminar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_materia_eliminar;
GO
CREATE PROCEDURE dbo.usp_materia_eliminar
    @Id        NVARCHAR(50),
    @Resultado INT OUTPUT,
    @Mensaje   NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM MATERIA WHERE IDMATERIA = @Id)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'La materia no existe.'; RETURN; END

    IF OBJECT_ID('dbo.PREGUNTA', 'U') IS NOT NULL
       AND EXISTS (SELECT 1 FROM PREGUNTA WHERE IDMATERIA = @Id)
    BEGIN
        SET @Resultado = 0;
        SET @Mensaje = 'No se puede eliminar: la materia tiene preguntas asociadas.';
        RETURN;
    END

    IF OBJECT_ID('dbo.LIBRO_MATERIA', 'U') IS NOT NULL
       AND EXISTS (SELECT 1 FROM LIBRO_MATERIA WHERE IDMATERIA = @Id)
    BEGIN
        SET @Resultado = 0;
        SET @Mensaje = 'No se puede eliminar: la materia está ligada a libros.';
        RETURN;
    END

    DELETE FROM MATERIA WHERE IDMATERIA = @Id;
    SET @Resultado = 1; SET @Mensaje = 'Materia eliminada.';
END;
GO

PRINT 'SPs usp_materia_* creados.';
GO
