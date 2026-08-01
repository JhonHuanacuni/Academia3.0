/* ============================================================================
   SPs listar / obtener auditoría
   Fecha: 31/07/2026
   Prerequisito: 2.auditoria_tabla.sql
   ============================================================================ */

IF OBJECT_ID('dbo.usp_auditoria_listar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_auditoria_listar;
GO
CREATE PROCEDURE dbo.usp_auditoria_listar
    @Buscar         NVARCHAR(200) = NULL,
    @Tabla          NVARCHAR(100) = NULL,
    @Accion         NVARCHAR(20)  = NULL,
    @IdUsuario      NVARCHAR(50)  = NULL,
    @FechaDesde     CHAR(8)       = NULL,
    @FechaHasta     CHAR(8)       = NULL,
    @OrdenarPor     NVARCHAR(50)  = 'FECHA',
    @Direccion      NVARCHAR(4)   = 'DESC',
    @Pagina         INT           = 1,
    @TamanioPagina  INT           = 10,
    @TotalRegistros INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF @Pagina < 1 SET @Pagina = 1;
    IF @TamanioPagina < 1 SET @TamanioPagina = 10;

    SELECT @TotalRegistros = COUNT(*)
    FROM dbo.AUDITORIA a
    LEFT JOIN dbo.USUARIO u ON u.IDUSUARIO = a.IDUSUARIO
    WHERE (@Buscar IS NULL OR @Buscar = '' OR
           a.IDAUDITORIA LIKE '%' + @Buscar + '%' OR
           a.TABLA LIKE '%' + @Buscar + '%' OR
           a.IDREGISTRO LIKE '%' + @Buscar + '%' OR
           a.ACCION LIKE '%' + @Buscar + '%' OR
           ISNULL(u.NOMBRE, '') + ' ' + ISNULL(u.APELLIDO, '') LIKE '%' + @Buscar + '%' OR
           ISNULL(a.IDUSUARIO, '') LIKE '%' + @Buscar + '%')
      AND (@Tabla IS NULL OR @Tabla = '' OR a.TABLA = @Tabla)
      AND (@Accion IS NULL OR @Accion = '' OR a.ACCION = @Accion)
      AND (@IdUsuario IS NULL OR @IdUsuario = '' OR a.IDUSUARIO = @IdUsuario)
      AND (@FechaDesde IS NULL OR @FechaDesde = '' OR a.FECHA >= @FechaDesde)
      AND (@FechaHasta IS NULL OR @FechaHasta = '' OR a.FECHA <= @FechaHasta);

    SELECT
        a.IDAUDITORIA,
        a.TABLA,
        a.IDREGISTRO,
        a.ACCION,
        a.IDUSUARIO,
        LTRIM(RTRIM(ISNULL(u.NOMBRE, '') + ' ' + ISNULL(u.APELLIDO, ''))) AS USUARIO_NOMBRE,
        a.FECHA,
        a.HORA,
        a.DATOS_ANTES,
        a.DATOS_DESPUES
    FROM dbo.AUDITORIA a
    LEFT JOIN dbo.USUARIO u ON u.IDUSUARIO = a.IDUSUARIO
    WHERE (@Buscar IS NULL OR @Buscar = '' OR
           a.IDAUDITORIA LIKE '%' + @Buscar + '%' OR
           a.TABLA LIKE '%' + @Buscar + '%' OR
           a.IDREGISTRO LIKE '%' + @Buscar + '%' OR
           a.ACCION LIKE '%' + @Buscar + '%' OR
           ISNULL(u.NOMBRE, '') + ' ' + ISNULL(u.APELLIDO, '') LIKE '%' + @Buscar + '%' OR
           ISNULL(a.IDUSUARIO, '') LIKE '%' + @Buscar + '%')
      AND (@Tabla IS NULL OR @Tabla = '' OR a.TABLA = @Tabla)
      AND (@Accion IS NULL OR @Accion = '' OR a.ACCION = @Accion)
      AND (@IdUsuario IS NULL OR @IdUsuario = '' OR a.IDUSUARIO = @IdUsuario)
      AND (@FechaDesde IS NULL OR @FechaDesde = '' OR a.FECHA >= @FechaDesde)
      AND (@FechaHasta IS NULL OR @FechaHasta = '' OR a.FECHA <= @FechaHasta)
    ORDER BY
        CASE WHEN @OrdenarPor = 'FECHA' AND @Direccion = 'DESC' THEN a.FECHA END DESC,
        CASE WHEN @OrdenarPor = 'FECHA' AND @Direccion = 'ASC'  THEN a.FECHA END ASC,
        CASE WHEN @OrdenarPor = 'HORA' AND @Direccion = 'DESC' THEN a.HORA END DESC,
        CASE WHEN @OrdenarPor = 'HORA' AND @Direccion = 'ASC'  THEN a.HORA END ASC,
        CASE WHEN @OrdenarPor = 'TABLA' AND @Direccion = 'DESC' THEN a.TABLA END DESC,
        CASE WHEN @OrdenarPor = 'TABLA' AND @Direccion = 'ASC'  THEN a.TABLA END ASC,
        CASE WHEN @OrdenarPor = 'ACCION' AND @Direccion = 'DESC' THEN a.ACCION END DESC,
        CASE WHEN @OrdenarPor = 'ACCION' AND @Direccion = 'ASC'  THEN a.ACCION END ASC,
        CASE WHEN @OrdenarPor = 'IDREGISTRO' AND @Direccion = 'DESC' THEN a.IDREGISTRO END DESC,
        CASE WHEN @OrdenarPor = 'IDREGISTRO' AND @Direccion = 'ASC'  THEN a.IDREGISTRO END ASC,
        CASE WHEN @OrdenarPor = 'USUARIO_NOMBRE' AND @Direccion = 'DESC'
            THEN LTRIM(RTRIM(ISNULL(u.NOMBRE, '') + ' ' + ISNULL(u.APELLIDO, ''))) END DESC,
        CASE WHEN @OrdenarPor = 'USUARIO_NOMBRE' AND @Direccion = 'ASC'
            THEN LTRIM(RTRIM(ISNULL(u.NOMBRE, '') + ' ' + ISNULL(u.APELLIDO, ''))) END ASC,
        a.FECHA DESC, a.HORA DESC, a.IDAUDITORIA DESC
    OFFSET (@Pagina - 1) * @TamanioPagina ROWS
    FETCH NEXT @TamanioPagina ROWS ONLY;
END;
GO

IF OBJECT_ID('dbo.usp_auditoria_obtener', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_auditoria_obtener;
GO
CREATE PROCEDURE dbo.usp_auditoria_obtener
    @Id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        a.IDAUDITORIA,
        a.TABLA,
        a.IDREGISTRO,
        a.ACCION,
        a.IDUSUARIO,
        LTRIM(RTRIM(ISNULL(u.NOMBRE, '') + ' ' + ISNULL(u.APELLIDO, ''))) AS USUARIO_NOMBRE,
        a.FECHA,
        a.HORA,
        a.DATOS_ANTES,
        a.DATOS_DESPUES
    FROM dbo.AUDITORIA a
    LEFT JOIN dbo.USUARIO u ON u.IDUSUARIO = a.IDUSUARIO
    WHERE a.IDAUDITORIA = @Id;
END;
GO

IF OBJECT_ID('dbo.usp_auditoria_tablas_catalogo', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_auditoria_tablas_catalogo;
GO
CREATE PROCEDURE dbo.usp_auditoria_tablas_catalogo
AS
BEGIN
    SET NOCOUNT ON;
    SELECT DISTINCT TABLA
    FROM dbo.AUDITORIA
    ORDER BY TABLA;
END;
GO

PRINT 'SPs de auditoría listos.';
GO
