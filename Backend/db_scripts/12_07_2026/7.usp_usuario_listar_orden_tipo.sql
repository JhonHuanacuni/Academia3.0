/* ============================================================================
   usp_usuario_listar: ordenar por TIPOUSUARIO_DESCRIPCION (columna Tipo)
   Ejecutar después de 11_07_2026/2.usp_usuario_apoderado.sql
   Fecha: 12/07/2026
   ============================================================================ */

IF OBJECT_ID('dbo.usp_usuario_listar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_usuario_listar;
GO
CREATE PROCEDURE dbo.usp_usuario_listar
    @Buscar         NVARCHAR(200) = NULL,
    @Estado         NVARCHAR(50)  = NULL,
    @OrdenarPor     NVARCHAR(50)  = 'IDUSUARIO',
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
    FROM USUARIO u
    INNER JOIN TIPOUSUARIO t ON t.IDTIPOUSUARIO = u.IDTIPOUSUARIO
    WHERE (@Buscar IS NULL OR @Buscar = '' OR
           u.IDUSUARIO  LIKE '%' + @Buscar + '%' OR
           u.NOMBRE     LIKE '%' + @Buscar + '%' OR
           u.APELLIDO   LIKE '%' + @Buscar + '%' OR
           u.DNI        LIKE '%' + @Buscar + '%' OR
           u.EMAIL      LIKE '%' + @Buscar + '%' OR
           ISNULL(u.NOMBREAPODERADO, '') LIKE '%' + @Buscar + '%')
      AND (@Estado IS NULL OR @Estado = '' OR u.ESTADO = @Estado);

    SELECT
        u.IDUSUARIO,
        u.NOMBRE,
        u.APELLIDO,
        u.DNI,
        u.EMAIL,
        u.ESTADO,
        u.IDTIPOUSUARIO,
        t.DESCRIPCION AS TIPOUSUARIO_DESCRIPCION,
        u.FECHANACIMIENTO,
        u.DIRECCION,
        u.DISTRITO,
        u.COLEGIO,
        u.GRADO,
        u.TELPERSONAL,
        u.TELAPODERADO,
        u.NOMBREAPODERADO,
        u.PARENTESCO,
        u.SITUACIONACADEMICA
    FROM USUARIO u
    INNER JOIN TIPOUSUARIO t ON t.IDTIPOUSUARIO = u.IDTIPOUSUARIO
    WHERE (@Buscar IS NULL OR @Buscar = '' OR
           u.IDUSUARIO  LIKE '%' + @Buscar + '%' OR
           u.NOMBRE     LIKE '%' + @Buscar + '%' OR
           u.APELLIDO   LIKE '%' + @Buscar + '%' OR
           u.DNI        LIKE '%' + @Buscar + '%' OR
           u.EMAIL      LIKE '%' + @Buscar + '%' OR
           ISNULL(u.NOMBREAPODERADO, '') LIKE '%' + @Buscar + '%')
      AND (@Estado IS NULL OR @Estado = '' OR u.ESTADO = @Estado)
    ORDER BY
        CASE WHEN @OrdenarPor = 'IDUSUARIO' AND @Direccion = 'ASC'  THEN u.IDUSUARIO END ASC,
        CASE WHEN @OrdenarPor = 'IDUSUARIO' AND @Direccion = 'DESC' THEN u.IDUSUARIO END DESC,
        CASE WHEN @OrdenarPor = 'NOMBRE'    AND @Direccion = 'ASC'  THEN u.NOMBRE END ASC,
        CASE WHEN @OrdenarPor = 'NOMBRE'    AND @Direccion = 'DESC' THEN u.NOMBRE END DESC,
        CASE WHEN @OrdenarPor = 'APELLIDO'  AND @Direccion = 'ASC'  THEN u.APELLIDO END ASC,
        CASE WHEN @OrdenarPor = 'APELLIDO'  AND @Direccion = 'DESC' THEN u.APELLIDO END DESC,
        CASE WHEN @OrdenarPor = 'DNI'       AND @Direccion = 'ASC'  THEN u.DNI END ASC,
        CASE WHEN @OrdenarPor = 'DNI'       AND @Direccion = 'DESC' THEN u.DNI END DESC,
        CASE WHEN @OrdenarPor = 'EMAIL'     AND @Direccion = 'ASC'  THEN u.EMAIL END ASC,
        CASE WHEN @OrdenarPor = 'EMAIL'     AND @Direccion = 'DESC' THEN u.EMAIL END DESC,
        CASE WHEN @OrdenarPor = 'ESTADO'    AND @Direccion = 'ASC'  THEN u.ESTADO END ASC,
        CASE WHEN @OrdenarPor = 'ESTADO'    AND @Direccion = 'DESC' THEN u.ESTADO END DESC,
        CASE WHEN @OrdenarPor = 'TIPOUSUARIO_DESCRIPCION' AND @Direccion = 'ASC'  THEN t.DESCRIPCION END ASC,
        CASE WHEN @OrdenarPor = 'TIPOUSUARIO_DESCRIPCION' AND @Direccion = 'DESC' THEN t.DESCRIPCION END DESC,
        CASE WHEN @OrdenarPor = 'NOMBREAPODERADO' AND @Direccion = 'ASC'  THEN u.NOMBREAPODERADO END ASC,
        CASE WHEN @OrdenarPor = 'NOMBREAPODERADO' AND @Direccion = 'DESC' THEN u.NOMBREAPODERADO END DESC,
        CASE WHEN @OrdenarPor = 'TELAPODERADO'    AND @Direccion = 'ASC'  THEN u.TELAPODERADO END ASC,
        CASE WHEN @OrdenarPor = 'TELAPODERADO'    AND @Direccion = 'DESC' THEN u.TELAPODERADO END DESC,
        CASE WHEN @OrdenarPor = 'PARENTESCO'      AND @Direccion = 'ASC'  THEN u.PARENTESCO END ASC,
        CASE WHEN @OrdenarPor = 'PARENTESCO'      AND @Direccion = 'DESC' THEN u.PARENTESCO END DESC,
        u.IDUSUARIO
    OFFSET (@Pagina - 1) * @TamanioPagina ROWS
    FETCH NEXT @TamanioPagina ROWS ONLY;
END;
GO

PRINT 'usp_usuario_listar: orden por TIPOUSUARIO_DESCRIPCION habilitado.';
GO
