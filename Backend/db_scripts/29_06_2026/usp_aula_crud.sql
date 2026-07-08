/* ============================================================================
   CRUD AULA — Mantenedor de aulas (módulo Académico)
   5 SPs estándar: listar, obtener, insertar, actualizar, eliminar
   Fecha: 29/06/2026
   ============================================================================ */

IF OBJECT_ID('dbo.usp_aula_listar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_aula_listar;
GO
CREATE PROCEDURE dbo.usp_aula_listar
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
    FROM AULA a
    WHERE (@Buscar IS NULL OR @Buscar = '' OR
           a.IDAULA      LIKE '%' + @Buscar + '%' OR
           a.NOMBRE      LIKE '%' + @Buscar + '%' OR
           a.DESCRIPCION LIKE '%' + @Buscar + '%')
      AND (@Estado IS NULL OR @Estado = '' OR
           (@Estado = 'Activo' AND a.ACTIVO = 1) OR
           (@Estado = 'Inactivo' AND a.ACTIVO = 0));

    SELECT
        a.IDAULA,
        a.NOMBRE,
        a.DESCRIPCION,
        a.CAPACIDAD,
        a.ENLACEVIRTUAL,
        a.ENLACECUESTIONARIO,
        CASE WHEN a.ACTIVO = 1 THEN 'Activo' ELSE 'Inactivo' END AS ESTADO
    FROM AULA a
    WHERE (@Buscar IS NULL OR @Buscar = '' OR
           a.IDAULA      LIKE '%' + @Buscar + '%' OR
           a.NOMBRE      LIKE '%' + @Buscar + '%' OR
           a.DESCRIPCION LIKE '%' + @Buscar + '%')
      AND (@Estado IS NULL OR @Estado = '' OR
           (@Estado = 'Activo' AND a.ACTIVO = 1) OR
           (@Estado = 'Inactivo' AND a.ACTIVO = 0))
    ORDER BY
        CASE WHEN @OrdenarPor = 'IDAULA'   AND @Direccion = 'ASC'  THEN a.IDAULA END ASC,
        CASE WHEN @OrdenarPor = 'IDAULA'   AND @Direccion = 'DESC' THEN a.IDAULA END DESC,
        CASE WHEN @OrdenarPor = 'NOMBRE'   AND @Direccion = 'ASC'  THEN a.NOMBRE END ASC,
        CASE WHEN @OrdenarPor = 'NOMBRE'   AND @Direccion = 'DESC' THEN a.NOMBRE END DESC,
        CASE WHEN @OrdenarPor = 'CAPACIDAD' AND @Direccion = 'ASC' THEN CAST(a.CAPACIDAD AS NVARCHAR(20)) END ASC,
        CASE WHEN @OrdenarPor = 'CAPACIDAD' AND @Direccion = 'DESC' THEN CAST(a.CAPACIDAD AS NVARCHAR(20)) END DESC,
        CASE WHEN @OrdenarPor = 'ESTADO'   AND @Direccion = 'ASC'  THEN a.ACTIVO END ASC,
        CASE WHEN @OrdenarPor = 'ESTADO'   AND @Direccion = 'DESC' THEN a.ACTIVO END DESC,
        a.NOMBRE
    OFFSET (@Pagina - 1) * @TamanioPagina ROWS
    FETCH NEXT @TamanioPagina ROWS ONLY;
END;
GO

IF OBJECT_ID('dbo.usp_aula_obtener', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_aula_obtener;
GO
CREATE PROCEDURE dbo.usp_aula_obtener
    @Id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        a.IDAULA,
        a.NOMBRE,
        a.DESCRIPCION,
        a.CAPACIDAD,
        a.ENLACEVIRTUAL,
        a.ENLACECUESTIONARIO,
        CASE WHEN a.ACTIVO = 1 THEN 'Activo' ELSE 'Inactivo' END AS ESTADO
    FROM AULA a
    WHERE a.IDAULA = @Id;
END;
GO

IF OBJECT_ID('dbo.usp_aula_insertar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_aula_insertar;
GO
CREATE PROCEDURE dbo.usp_aula_insertar
    @Id                 NVARCHAR(50),
    @Nombre             NVARCHAR(100),
    @Descripcion        NVARCHAR(MAX) = NULL,
    @Capacidad          INT           = NULL,
    @EnlaceVirtual      NVARCHAR(255) = NULL,
    @EnlaceCuestionario NVARCHAR(255) = NULL,
    @Estado             NVARCHAR(50)  = 'Activo',
    @Resultado          INT OUTPUT,
    @Mensaje            NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF @Id IS NULL OR LTRIM(RTRIM(@Id)) = ''
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'Ingresa el código del aula.';
        RETURN;
    END

    IF @Nombre IS NULL OR LTRIM(RTRIM(@Nombre)) = ''
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'Ingresa el nombre del aula.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM AULA WHERE IDAULA = @Id)
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'El código de aula ya existe.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM AULA WHERE NOMBRE = @Nombre)
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'Ya existe un aula con ese nombre.';
        RETURN;
    END

    INSERT INTO AULA (
        IDAULA, NOMBRE, DESCRIPCION, CAPACIDAD, ACTIVO, ENLACEVIRTUAL, ENLACECUESTIONARIO
    ) VALUES (
        @Id,
        @Nombre,
        @Descripcion,
        @Capacidad,
        CASE WHEN @Estado = 'Activo' THEN 1 ELSE 0 END,
        @EnlaceVirtual,
        @EnlaceCuestionario
    );

    SET @Resultado = 1; SET @Mensaje = 'Aula registrada.';
END;
GO

IF OBJECT_ID('dbo.usp_aula_actualizar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_aula_actualizar;
GO
CREATE PROCEDURE dbo.usp_aula_actualizar
    @Id                 NVARCHAR(50),
    @Nombre             NVARCHAR(100),
    @Descripcion        NVARCHAR(MAX) = NULL,
    @Capacidad          INT           = NULL,
    @EnlaceVirtual      NVARCHAR(255) = NULL,
    @EnlaceCuestionario NVARCHAR(255) = NULL,
    @Estado             NVARCHAR(50)  = 'Activo',
    @Resultado          INT OUTPUT,
    @Mensaje            NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM AULA WHERE IDAULA = @Id)
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'El aula no existe.';
        RETURN;
    END

    IF @Nombre IS NULL OR LTRIM(RTRIM(@Nombre)) = ''
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'Ingresa el nombre del aula.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM AULA WHERE NOMBRE = @Nombre AND IDAULA <> @Id)
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'Ya existe un aula con ese nombre.';
        RETURN;
    END

    UPDATE AULA SET
        NOMBRE             = @Nombre,
        DESCRIPCION        = @Descripcion,
        CAPACIDAD          = @Capacidad,
        ENLACEVIRTUAL      = @EnlaceVirtual,
        ENLACECUESTIONARIO = @EnlaceCuestionario,
        ACTIVO             = CASE WHEN @Estado = 'Activo' THEN 1 ELSE 0 END
    WHERE IDAULA = @Id;

    SET @Resultado = 1; SET @Mensaje = 'Aula actualizada.';
END;
GO

IF OBJECT_ID('dbo.usp_aula_eliminar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_aula_eliminar;
GO
CREATE PROCEDURE dbo.usp_aula_eliminar
    @Id        NVARCHAR(50),
    @Resultado INT OUTPUT,
    @Mensaje   NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM AULA WHERE IDAULA = @Id)
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'El aula no existe.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM MEMBRESIA WHERE IDAULA = @Id)
    BEGIN
        SET @Resultado = 0;
        SET @Mensaje = 'No se puede eliminar: el aula tiene membresías asociadas.';
        RETURN;
    END

    DELETE FROM AULA WHERE IDAULA = @Id;

    SET @Resultado = 1; SET @Mensaje = 'Aula eliminada.';
END;
GO

PRINT 'SPs usp_aula_* creados.';
GO
