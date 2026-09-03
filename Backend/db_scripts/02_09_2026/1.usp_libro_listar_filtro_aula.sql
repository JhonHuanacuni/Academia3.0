/* ============================================================================
   Biblioteca: listar PDFs filtrados por salón del estudiante (MENSUALIDAD)
   Si @IdUsuario es NULL → admin ve todos. Si viene ID → solo libros
   asignados a aulas de mensualidades activas del estudiante.
   Fecha: 02/09/2026
   ============================================================================ */

IF OBJECT_ID('dbo.usp_libro_listar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_libro_listar;
GO
CREATE PROCEDURE dbo.usp_libro_listar
    @Buscar         NVARCHAR(200) = NULL,
    @Estado         NVARCHAR(50)  = NULL,
    @IdUsuario      NVARCHAR(50)  = NULL,
    @OrdenarPor     NVARCHAR(50)  = 'FECHASUBIDA',
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
    FROM LIBRO l
    WHERE (@Buscar IS NULL OR @Buscar = '' OR
           l.IDLIBRO     LIKE '%' + @Buscar + '%' OR
           l.TITULO      LIKE '%' + @Buscar + '%' OR
           l.DESCRIPCION LIKE '%' + @Buscar + '%')
      AND (@Estado IS NULL OR @Estado = '' OR l.ESTADO = @Estado)
      AND (
          @IdUsuario IS NULL OR @IdUsuario = '' OR
          EXISTS (
              SELECT 1
              FROM LIBRO_AULA la
              WHERE la.IDLIBRO = l.IDLIBRO
                AND la.IDAULA IN (
                    SELECT DISTINCT ms.IDAULA
                    FROM MENSUALIDAD ms
                    WHERE ms.IDUSUARIO = @IdUsuario
                      AND ms.ESTADO = 'Activo'
                      AND ms.IDAULA IS NOT NULL
                      AND LTRIM(RTRIM(ms.IDAULA)) <> ''
                )
          )
      );

    SELECT
        l.IDLIBRO,
        l.TITULO,
        l.DESCRIPCION,
        l.FECHASUBIDA,
        l.ESTADO,
        l.URLCONTENIDO,
        l.IMGPORTADA
    FROM LIBRO l
    WHERE (@Buscar IS NULL OR @Buscar = '' OR
           l.IDLIBRO     LIKE '%' + @Buscar + '%' OR
           l.TITULO      LIKE '%' + @Buscar + '%' OR
           l.DESCRIPCION LIKE '%' + @Buscar + '%')
      AND (@Estado IS NULL OR @Estado = '' OR l.ESTADO = @Estado)
      AND (
          @IdUsuario IS NULL OR @IdUsuario = '' OR
          EXISTS (
              SELECT 1
              FROM LIBRO_AULA la
              WHERE la.IDLIBRO = l.IDLIBRO
                AND la.IDAULA IN (
                    SELECT DISTINCT ms.IDAULA
                    FROM MENSUALIDAD ms
                    WHERE ms.IDUSUARIO = @IdUsuario
                      AND ms.ESTADO = 'Activo'
                      AND ms.IDAULA IS NOT NULL
                      AND LTRIM(RTRIM(ms.IDAULA)) <> ''
                )
          )
      )
    ORDER BY
        CASE WHEN @OrdenarPor = 'IDLIBRO'     AND @Direccion = 'ASC'  THEN l.IDLIBRO END ASC,
        CASE WHEN @OrdenarPor = 'IDLIBRO'     AND @Direccion = 'DESC' THEN l.IDLIBRO END DESC,
        CASE WHEN @OrdenarPor = 'TITULO'      AND @Direccion = 'ASC'  THEN l.TITULO END ASC,
        CASE WHEN @OrdenarPor = 'TITULO'      AND @Direccion = 'DESC' THEN l.TITULO END DESC,
        CASE WHEN @OrdenarPor = 'FECHASUBIDA' AND @Direccion = 'ASC'
            THEN SUBSTRING(l.FECHASUBIDA,5,4) + SUBSTRING(l.FECHASUBIDA,3,2) + SUBSTRING(l.FECHASUBIDA,1,2) END ASC,
        CASE WHEN @OrdenarPor = 'FECHASUBIDA' AND @Direccion = 'DESC'
            THEN SUBSTRING(l.FECHASUBIDA,5,4) + SUBSTRING(l.FECHASUBIDA,3,2) + SUBSTRING(l.FECHASUBIDA,1,2) END DESC,
        CASE WHEN @OrdenarPor = 'ESTADO'      AND @Direccion = 'ASC'  THEN l.ESTADO END ASC,
        CASE WHEN @OrdenarPor = 'ESTADO'      AND @Direccion = 'DESC' THEN l.ESTADO END DESC,
        SUBSTRING(l.FECHASUBIDA,5,4) + SUBSTRING(l.FECHASUBIDA,3,2) + SUBSTRING(l.FECHASUBIDA,1,2) DESC,
        l.IDLIBRO DESC
    OFFSET (@Pagina - 1) * @TamanioPagina ROWS
    FETCH NEXT @TamanioPagina ROWS ONLY;
END;
GO
