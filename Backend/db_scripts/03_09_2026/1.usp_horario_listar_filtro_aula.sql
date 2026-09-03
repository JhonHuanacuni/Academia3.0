/* ============================================================================
   Horario: listar filtrados por salón del estudiante (MENSUALIDAD)
   Si @IdUsuario es NULL → admin ve todos. Si viene ID → solo horarios
   asignados a aulas de mensualidades activas del estudiante.
   Fecha: 03/09/2026
   ============================================================================ */

IF OBJECT_ID('dbo.usp_horario_listar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_horario_listar;
GO
CREATE PROCEDURE dbo.usp_horario_listar
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
    FROM HORARIO h
    WHERE (@Buscar IS NULL OR @Buscar = '' OR
           h.IDHORARIO   LIKE '%' + @Buscar + '%' OR
           h.TITULO      LIKE '%' + @Buscar + '%' OR
           h.DESCRIPCION LIKE '%' + @Buscar + '%')
      AND (@Estado IS NULL OR @Estado = '' OR h.ESTADO = @Estado)
      AND (
          @IdUsuario IS NULL OR @IdUsuario = '' OR
          EXISTS (
              SELECT 1
              FROM HORARIO_AULA ha
              WHERE ha.IDHORARIO = h.IDHORARIO
                AND ha.IDAULA IN (
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
        h.IDHORARIO,
        h.TITULO,
        h.DESCRIPCION,
        h.FECHASUBIDA,
        h.ESTADO,
        h.URLIMAGEN
    FROM HORARIO h
    WHERE (@Buscar IS NULL OR @Buscar = '' OR
           h.IDHORARIO   LIKE '%' + @Buscar + '%' OR
           h.TITULO      LIKE '%' + @Buscar + '%' OR
           h.DESCRIPCION LIKE '%' + @Buscar + '%')
      AND (@Estado IS NULL OR @Estado = '' OR h.ESTADO = @Estado)
      AND (
          @IdUsuario IS NULL OR @IdUsuario = '' OR
          EXISTS (
              SELECT 1
              FROM HORARIO_AULA ha
              WHERE ha.IDHORARIO = h.IDHORARIO
                AND ha.IDAULA IN (
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
        CASE WHEN @OrdenarPor = 'IDHORARIO'   AND @Direccion = 'ASC'  THEN h.IDHORARIO END ASC,
        CASE WHEN @OrdenarPor = 'IDHORARIO'   AND @Direccion = 'DESC' THEN h.IDHORARIO END DESC,
        CASE WHEN @OrdenarPor = 'TITULO'      AND @Direccion = 'ASC'  THEN h.TITULO END ASC,
        CASE WHEN @OrdenarPor = 'TITULO'      AND @Direccion = 'DESC' THEN h.TITULO END DESC,
        CASE WHEN @OrdenarPor = 'FECHASUBIDA' AND @Direccion = 'ASC'
            THEN SUBSTRING(h.FECHASUBIDA,5,4) + SUBSTRING(h.FECHASUBIDA,3,2) + SUBSTRING(h.FECHASUBIDA,1,2) END ASC,
        CASE WHEN @OrdenarPor = 'FECHASUBIDA' AND @Direccion = 'DESC'
            THEN SUBSTRING(h.FECHASUBIDA,5,4) + SUBSTRING(h.FECHASUBIDA,3,2) + SUBSTRING(h.FECHASUBIDA,1,2) END DESC,
        CASE WHEN @OrdenarPor = 'ESTADO'      AND @Direccion = 'ASC'  THEN h.ESTADO END ASC,
        CASE WHEN @OrdenarPor = 'ESTADO'      AND @Direccion = 'DESC' THEN h.ESTADO END DESC,
        SUBSTRING(h.FECHASUBIDA,5,4) + SUBSTRING(h.FECHASUBIDA,3,2) + SUBSTRING(h.FECHASUBIDA,1,2) DESC,
        h.IDHORARIO DESC
    OFFSET (@Pagina - 1) * @TamanioPagina ROWS
    FETCH NEXT @TamanioPagina ROWS ONLY;
END;
GO
