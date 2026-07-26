/* ============================================================================
   CRUD ASESOR — Mantenedor de asesores (módulo Académico)
   Ejecutar después de 6.asesor_tabla.sql (11_07_2026)
   Fecha: 12/07/2026
   ============================================================================ */

IF OBJECT_ID('dbo.usp_asesor_listar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_asesor_listar;
GO
CREATE PROCEDURE dbo.usp_asesor_listar
    @Buscar         NVARCHAR(200) = NULL,
    @Estado         NVARCHAR(50)  = NULL,
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
    FROM ASESOR a
    WHERE (@Buscar IS NULL OR @Buscar = '' OR
           a.IDASESOR LIKE '%' + @Buscar + '%' OR
           a.NOMBRE   LIKE '%' + @Buscar + '%')
      AND (@Estado IS NULL OR @Estado = '' OR
           (@Estado = 'Activo' AND a.ACTIVO = 1) OR
           (@Estado = 'Inactivo' AND a.ACTIVO = 0));

    SELECT
        a.IDASESOR,
        a.NOMBRE,
        CASE WHEN a.ACTIVO = 1 THEN 'Activo' ELSE 'Inactivo' END AS ESTADO
    FROM ASESOR a
    WHERE (@Buscar IS NULL OR @Buscar = '' OR
           a.IDASESOR LIKE '%' + @Buscar + '%' OR
           a.NOMBRE   LIKE '%' + @Buscar + '%')
      AND (@Estado IS NULL OR @Estado = '' OR
           (@Estado = 'Activo' AND a.ACTIVO = 1) OR
           (@Estado = 'Inactivo' AND a.ACTIVO = 0))
    ORDER BY
        CASE WHEN @OrdenarPor = 'IDASESOR' AND @Direccion = 'ASC'  THEN a.IDASESOR END ASC,
        CASE WHEN @OrdenarPor = 'IDASESOR' AND @Direccion = 'DESC' THEN a.IDASESOR END DESC,
        CASE WHEN @OrdenarPor = 'NOMBRE'   AND @Direccion = 'ASC'  THEN a.NOMBRE END ASC,
        CASE WHEN @OrdenarPor = 'NOMBRE'   AND @Direccion = 'DESC' THEN a.NOMBRE END DESC,
        CASE WHEN @OrdenarPor = 'ESTADO'   AND @Direccion = 'ASC'  THEN a.ACTIVO END ASC,
        CASE WHEN @OrdenarPor = 'ESTADO'   AND @Direccion = 'DESC' THEN a.ACTIVO END DESC,
        a.NOMBRE
    OFFSET (@Pagina - 1) * @TamanioPagina ROWS
    FETCH NEXT @TamanioPagina ROWS ONLY;
END;
GO

IF OBJECT_ID('dbo.usp_asesor_obtener', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_asesor_obtener;
GO
CREATE PROCEDURE dbo.usp_asesor_obtener
    @Id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        a.IDASESOR,
        a.NOMBRE,
        CASE WHEN a.ACTIVO = 1 THEN 'Activo' ELSE 'Inactivo' END AS ESTADO
    FROM ASESOR a
    WHERE a.IDASESOR = @Id;
END;
GO

IF OBJECT_ID('dbo.usp_asesor_insertar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_asesor_insertar;
GO
CREATE PROCEDURE dbo.usp_asesor_insertar
    @Id        NVARCHAR(50),
    @Nombre    NVARCHAR(150),
    @Estado    NVARCHAR(50) = 'Activo',
    @Resultado INT OUTPUT,
    @Mensaje   NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF @Id IS NULL OR LTRIM(RTRIM(@Id)) = ''
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'Ingresa el código del asesor.';
        RETURN;
    END

    IF @Nombre IS NULL OR LTRIM(RTRIM(@Nombre)) = ''
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'Ingresa el nombre del asesor.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM ASESOR WHERE IDASESOR = @Id)
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'El código de asesor ya existe.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM ASESOR WHERE NOMBRE = @Nombre)
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'Ya existe un asesor con ese nombre.';
        RETURN;
    END

    INSERT INTO ASESOR (IDASESOR, NOMBRE, ACTIVO)
    VALUES (
        @Id,
        @Nombre,
        CASE WHEN @Estado = 'Activo' THEN 1 ELSE 0 END
    );

    SET @Resultado = 1; SET @Mensaje = 'Asesor registrado.';
END;
GO

IF OBJECT_ID('dbo.usp_asesor_actualizar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_asesor_actualizar;
GO
CREATE PROCEDURE dbo.usp_asesor_actualizar
    @Id        NVARCHAR(50),
    @Nombre    NVARCHAR(150),
    @Estado    NVARCHAR(50) = 'Activo',
    @Resultado INT OUTPUT,
    @Mensaje   NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM ASESOR WHERE IDASESOR = @Id)
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'El asesor no existe.';
        RETURN;
    END

    IF @Nombre IS NULL OR LTRIM(RTRIM(@Nombre)) = ''
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'Ingresa el nombre del asesor.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM ASESOR WHERE NOMBRE = @Nombre AND IDASESOR <> @Id)
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'Ya existe un asesor con ese nombre.';
        RETURN;
    END

    UPDATE ASESOR SET
        NOMBRE = @Nombre,
        ACTIVO = CASE WHEN @Estado = 'Activo' THEN 1 ELSE 0 END
    WHERE IDASESOR = @Id;

    SET @Resultado = 1; SET @Mensaje = 'Asesor actualizado.';
END;
GO

IF OBJECT_ID('dbo.usp_asesor_eliminar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_asesor_eliminar;
GO
CREATE PROCEDURE dbo.usp_asesor_eliminar
    @Id        NVARCHAR(50),
    @Resultado INT OUTPUT,
    @Mensaje   NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM ASESOR WHERE IDASESOR = @Id)
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'El asesor no existe.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM MEMBRESIA WHERE IDASESOR = @Id)
    BEGIN
        SET @Resultado = 0;
        SET @Mensaje = 'No se puede eliminar: el asesor tiene membresías asociadas.';
        RETURN;
    END

    DELETE FROM ASESOR WHERE IDASESOR = @Id;

    SET @Resultado = 1; SET @Mensaje = 'Asesor eliminado.';
END;
GO

PRINT 'SPs usp_asesor_* creados.';
GO
