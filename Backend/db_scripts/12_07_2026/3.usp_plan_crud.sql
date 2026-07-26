/* ============================================================================
   CRUD PLAN — Mantenedor de planes (módulo Académico)
   Solo catálogo: código, nombre, descripción, activo.
   Duración y monto viven en MEMBRESIA (FECHAINICIO/FECHAFIN/MONTOTOTAL).
   Fecha: 12/07/2026
   ============================================================================ */

IF OBJECT_ID('dbo.usp_plan_listar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_plan_listar;
GO
CREATE PROCEDURE dbo.usp_plan_listar
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
    FROM [PLAN] p
    WHERE (@Buscar IS NULL OR @Buscar = '' OR
           p.IDPLAN      LIKE '%' + @Buscar + '%' OR
           p.NOMBRE      LIKE '%' + @Buscar + '%' OR
           p.DESCRIPCION LIKE '%' + @Buscar + '%')
      AND (@Estado IS NULL OR @Estado = '' OR
           (@Estado = 'Activo' AND p.ACTIVO = 1) OR
           (@Estado = 'Inactivo' AND p.ACTIVO = 0));

    SELECT
        p.IDPLAN,
        p.NOMBRE,
        p.DESCRIPCION,
        CASE WHEN p.ACTIVO = 1 THEN 'Activo' ELSE 'Inactivo' END AS ESTADO
    FROM [PLAN] p
    WHERE (@Buscar IS NULL OR @Buscar = '' OR
           p.IDPLAN      LIKE '%' + @Buscar + '%' OR
           p.NOMBRE      LIKE '%' + @Buscar + '%' OR
           p.DESCRIPCION LIKE '%' + @Buscar + '%')
      AND (@Estado IS NULL OR @Estado = '' OR
           (@Estado = 'Activo' AND p.ACTIVO = 1) OR
           (@Estado = 'Inactivo' AND p.ACTIVO = 0))
    ORDER BY
        CASE WHEN @OrdenarPor = 'IDPLAN' AND @Direccion = 'ASC'  THEN p.IDPLAN END ASC,
        CASE WHEN @OrdenarPor = 'IDPLAN' AND @Direccion = 'DESC' THEN p.IDPLAN END DESC,
        CASE WHEN @OrdenarPor = 'NOMBRE' AND @Direccion = 'ASC'  THEN p.NOMBRE END ASC,
        CASE WHEN @OrdenarPor = 'NOMBRE' AND @Direccion = 'DESC' THEN p.NOMBRE END DESC,
        CASE WHEN @OrdenarPor = 'ESTADO' AND @Direccion = 'ASC'  THEN p.ACTIVO END ASC,
        CASE WHEN @OrdenarPor = 'ESTADO' AND @Direccion = 'DESC' THEN p.ACTIVO END DESC,
        p.NOMBRE
    OFFSET (@Pagina - 1) * @TamanioPagina ROWS
    FETCH NEXT @TamanioPagina ROWS ONLY;
END;
GO

IF OBJECT_ID('dbo.usp_plan_obtener', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_plan_obtener;
GO
CREATE PROCEDURE dbo.usp_plan_obtener
    @Id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        p.IDPLAN,
        p.NOMBRE,
        p.DESCRIPCION,
        CASE WHEN p.ACTIVO = 1 THEN 'Activo' ELSE 'Inactivo' END AS ESTADO
    FROM [PLAN] p
    WHERE p.IDPLAN = @Id;
END;
GO

IF OBJECT_ID('dbo.usp_plan_insertar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_plan_insertar;
GO
CREATE PROCEDURE dbo.usp_plan_insertar
    @Id          NVARCHAR(50),
    @Nombre      NVARCHAR(100),
    @Descripcion NVARCHAR(255) = NULL,
    @Estado      NVARCHAR(50)  = 'Activo',
    @Resultado   INT OUTPUT,
    @Mensaje     NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF @Id IS NULL OR LTRIM(RTRIM(@Id)) = ''
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ingresa el código del plan.'; RETURN; END

    IF @Nombre IS NULL OR LTRIM(RTRIM(@Nombre)) = ''
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ingresa el nombre del plan.'; RETURN; END

    IF EXISTS (SELECT 1 FROM [PLAN] WHERE IDPLAN = @Id)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El código de plan ya existe.'; RETURN; END

    IF EXISTS (SELECT 1 FROM [PLAN] WHERE NOMBRE = @Nombre)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ya existe un plan con ese nombre.'; RETURN; END

    INSERT INTO [PLAN] (IDPLAN, NOMBRE, DESCRIPCION, ACTIVO)
    VALUES (
        @Id,
        @Nombre,
        @Descripcion,
        CASE WHEN @Estado = 'Activo' THEN 1 ELSE 0 END
    );

    SET @Resultado = 1; SET @Mensaje = 'Plan registrado.';
END;
GO

IF OBJECT_ID('dbo.usp_plan_actualizar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_plan_actualizar;
GO
CREATE PROCEDURE dbo.usp_plan_actualizar
    @Id          NVARCHAR(50),
    @Nombre      NVARCHAR(100),
    @Descripcion NVARCHAR(255) = NULL,
    @Estado      NVARCHAR(50)  = 'Activo',
    @Resultado   INT OUTPUT,
    @Mensaje     NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM [PLAN] WHERE IDPLAN = @Id)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El plan no existe.'; RETURN; END

    IF @Nombre IS NULL OR LTRIM(RTRIM(@Nombre)) = ''
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ingresa el nombre del plan.'; RETURN; END

    IF EXISTS (SELECT 1 FROM [PLAN] WHERE NOMBRE = @Nombre AND IDPLAN <> @Id)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ya existe un plan con ese nombre.'; RETURN; END

    UPDATE [PLAN] SET
        NOMBRE      = @Nombre,
        DESCRIPCION = @Descripcion,
        ACTIVO      = CASE WHEN @Estado = 'Activo' THEN 1 ELSE 0 END
    WHERE IDPLAN = @Id;

    SET @Resultado = 1; SET @Mensaje = 'Plan actualizado.';
END;
GO

IF OBJECT_ID('dbo.usp_plan_eliminar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_plan_eliminar;
GO
CREATE PROCEDURE dbo.usp_plan_eliminar
    @Id        NVARCHAR(50),
    @Resultado INT OUTPUT,
    @Mensaje   NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM [PLAN] WHERE IDPLAN = @Id)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El plan no existe.'; RETURN; END

    IF EXISTS (SELECT 1 FROM MEMBRESIA WHERE IDPLAN = @Id)
    BEGIN
        SET @Resultado = 0;
        SET @Mensaje = 'No se puede eliminar: el plan tiene membresías asociadas.';
        RETURN;
    END

    DELETE FROM [PLAN] WHERE IDPLAN = @Id;

    SET @Resultado = 1; SET @Mensaje = 'Plan eliminado.';
END;
GO

PRINT 'SPs usp_plan_* creados (sin duración ni precio).';
GO
