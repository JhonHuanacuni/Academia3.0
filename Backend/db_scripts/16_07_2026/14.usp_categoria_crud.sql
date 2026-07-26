/* ============================================================================
   CRUD CATEGORIA
   Ejecutar después de 13.categoria_materia_tablas.sql
   Fecha: 16/07/2026
   ============================================================================ */

IF OBJECT_ID('dbo.usp_categoria_listar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_categoria_listar;
GO
CREATE PROCEDURE dbo.usp_categoria_listar
    @Buscar         NVARCHAR(200) = NULL,
    @Estado         NVARCHAR(50)  = NULL,
    @OrdenarPor     NVARCHAR(50)  = 'ORDEN',
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
    FROM CATEGORIA c
    WHERE (@Buscar IS NULL OR @Buscar = '' OR
           c.IDCATEGORIA LIKE '%' + @Buscar + '%' OR
           c.NOMBRE LIKE '%' + @Buscar + '%')
      AND (@Estado IS NULL OR @Estado = '' OR
           (@Estado = 'Activo' AND c.ACTIVO = 1) OR
           (@Estado = 'Inactivo' AND c.ACTIVO = 0));

    SELECT
        c.IDCATEGORIA,
        c.NOMBRE,
        c.PORCENTAJE,
        c.ORDEN,
        CASE WHEN c.ACTIVO = 1 THEN 'Activo' ELSE 'Inactivo' END AS ESTADO
    FROM CATEGORIA c
    WHERE (@Buscar IS NULL OR @Buscar = '' OR
           c.IDCATEGORIA LIKE '%' + @Buscar + '%' OR
           c.NOMBRE LIKE '%' + @Buscar + '%')
      AND (@Estado IS NULL OR @Estado = '' OR
           (@Estado = 'Activo' AND c.ACTIVO = 1) OR
           (@Estado = 'Inactivo' AND c.ACTIVO = 0))
    ORDER BY
        CASE WHEN @OrdenarPor = 'IDCATEGORIA' AND @Direccion = 'ASC'  THEN c.IDCATEGORIA END ASC,
        CASE WHEN @OrdenarPor = 'IDCATEGORIA' AND @Direccion = 'DESC' THEN c.IDCATEGORIA END DESC,
        CASE WHEN @OrdenarPor = 'NOMBRE' AND @Direccion = 'ASC'  THEN c.NOMBRE END ASC,
        CASE WHEN @OrdenarPor = 'NOMBRE' AND @Direccion = 'DESC' THEN c.NOMBRE END DESC,
        CASE WHEN @OrdenarPor = 'PORCENTAJE' AND @Direccion = 'ASC'  THEN c.PORCENTAJE END ASC,
        CASE WHEN @OrdenarPor = 'PORCENTAJE' AND @Direccion = 'DESC' THEN c.PORCENTAJE END DESC,
        CASE WHEN @OrdenarPor = 'ORDEN' AND @Direccion = 'ASC'  THEN c.ORDEN END ASC,
        CASE WHEN @OrdenarPor = 'ORDEN' AND @Direccion = 'DESC' THEN c.ORDEN END DESC,
        CASE WHEN @OrdenarPor = 'ESTADO' AND @Direccion = 'ASC'  THEN c.ACTIVO END ASC,
        CASE WHEN @OrdenarPor = 'ESTADO' AND @Direccion = 'DESC' THEN c.ACTIVO END DESC,
        c.ORDEN, c.NOMBRE
    OFFSET (@Pagina - 1) * @TamanioPagina ROWS
    FETCH NEXT @TamanioPagina ROWS ONLY;
END;
GO

IF OBJECT_ID('dbo.usp_categoria_obtener', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_categoria_obtener;
GO
CREATE PROCEDURE dbo.usp_categoria_obtener
    @Id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        c.IDCATEGORIA,
        c.NOMBRE,
        c.PORCENTAJE,
        c.ORDEN,
        CASE WHEN c.ACTIVO = 1 THEN 'Activo' ELSE 'Inactivo' END AS ESTADO
    FROM CATEGORIA c
    WHERE c.IDCATEGORIA = @Id;
END;
GO

IF OBJECT_ID('dbo.usp_categoria_insertar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_categoria_insertar;
GO
CREATE PROCEDURE dbo.usp_categoria_insertar
    @Id          NVARCHAR(50),
    @Nombre      NVARCHAR(100),
    @Porcentaje  DECIMAL(5,2) = NULL,
    @Orden       INT          = 0,
    @Estado      NVARCHAR(50) = 'Activo',
    @Resultado   INT OUTPUT,
    @Mensaje     NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF @Id IS NULL OR LTRIM(RTRIM(@Id)) = ''
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ingresa el código de la categoría.'; RETURN; END

    IF @Nombre IS NULL OR LTRIM(RTRIM(@Nombre)) = ''
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ingresa el nombre de la categoría.'; RETURN; END

    IF @Porcentaje IS NOT NULL AND (@Porcentaje < 0 OR @Porcentaje > 100)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El porcentaje debe estar entre 0 y 100.'; RETURN; END

    IF EXISTS (SELECT 1 FROM CATEGORIA WHERE IDCATEGORIA = @Id)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El código de categoría ya existe.'; RETURN; END

    IF EXISTS (SELECT 1 FROM CATEGORIA WHERE NOMBRE = @Nombre)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ya existe una categoría con ese nombre.'; RETURN; END

    INSERT INTO CATEGORIA (IDCATEGORIA, NOMBRE, PORCENTAJE, ORDEN, ACTIVO)
    VALUES (
        @Id,
        @Nombre,
        @Porcentaje,
        ISNULL(@Orden, 0),
        CASE WHEN @Estado = 'Activo' THEN 1 ELSE 0 END
    );

    SET @Resultado = 1; SET @Mensaje = 'Categoría registrada.';
END;
GO

IF OBJECT_ID('dbo.usp_categoria_actualizar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_categoria_actualizar;
GO
CREATE PROCEDURE dbo.usp_categoria_actualizar
    @Id          NVARCHAR(50),
    @Nombre      NVARCHAR(100),
    @Porcentaje  DECIMAL(5,2) = NULL,
    @Orden       INT          = 0,
    @Estado      NVARCHAR(50) = 'Activo',
    @Resultado   INT OUTPUT,
    @Mensaje     NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM CATEGORIA WHERE IDCATEGORIA = @Id)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'La categoría no existe.'; RETURN; END

    IF @Nombre IS NULL OR LTRIM(RTRIM(@Nombre)) = ''
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ingresa el nombre de la categoría.'; RETURN; END

    IF @Porcentaje IS NOT NULL AND (@Porcentaje < 0 OR @Porcentaje > 100)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El porcentaje debe estar entre 0 y 100.'; RETURN; END

    IF EXISTS (SELECT 1 FROM CATEGORIA WHERE NOMBRE = @Nombre AND IDCATEGORIA <> @Id)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ya existe una categoría con ese nombre.'; RETURN; END

    UPDATE CATEGORIA SET
        NOMBRE     = @Nombre,
        PORCENTAJE = @Porcentaje,
        ORDEN      = ISNULL(@Orden, 0),
        ACTIVO     = CASE WHEN @Estado = 'Activo' THEN 1 ELSE 0 END
    WHERE IDCATEGORIA = @Id;

    SET @Resultado = 1; SET @Mensaje = 'Categoría actualizada.';
END;
GO

IF OBJECT_ID('dbo.usp_categoria_eliminar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_categoria_eliminar;
GO
CREATE PROCEDURE dbo.usp_categoria_eliminar
    @Id        NVARCHAR(50),
    @Resultado INT OUTPUT,
    @Mensaje   NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM CATEGORIA WHERE IDCATEGORIA = @Id)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'La categoría no existe.'; RETURN; END

    IF EXISTS (SELECT 1 FROM MATERIA WHERE IDCATEGORIA = @Id)
    BEGIN
        SET @Resultado = 0;
        SET @Mensaje = 'No se puede eliminar: hay materias asociadas.';
        RETURN;
    END

    DELETE FROM CATEGORIA WHERE IDCATEGORIA = @Id;
    SET @Resultado = 1; SET @Mensaje = 'Categoría eliminada.';
END;
GO

PRINT 'SPs usp_categoria_* creados.';
GO
