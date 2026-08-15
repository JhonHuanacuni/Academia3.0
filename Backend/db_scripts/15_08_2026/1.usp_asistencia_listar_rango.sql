/* ============================================================================
   usp_asistencia_listar: rango fecha inicio / fecha fin
   Fecha: 15/08/2026
   ============================================================================ */

IF OBJECT_ID('dbo.usp_asistencia_listar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_asistencia_listar;
GO
CREATE PROCEDURE dbo.usp_asistencia_listar
    @FechaDesde     CHAR(8)       = NULL,
    @FechaHasta     CHAR(8)       = NULL,
    @Buscar         NVARCHAR(200) = NULL,
    @OrdenarPor     NVARCHAR(50)  = 'HORAINICIO',
    @Direccion      NVARCHAR(4)   = 'DESC',
    @Pagina         INT           = 1,
    @TamanioPagina  INT           = 50,
    @TotalRegistros INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Hoy CHAR(8) = dbo.fn_fecha_ddmmyyyy();
    DECLARE @Desde CHAR(8) = CASE WHEN @FechaDesde IS NULL OR LTRIM(RTRIM(@FechaDesde)) = '' THEN @Hoy ELSE LTRIM(RTRIM(@FechaDesde)) END;
    DECLARE @Hasta CHAR(8) = CASE WHEN @FechaHasta IS NULL OR LTRIM(RTRIM(@FechaHasta)) = '' THEN @Desde ELSE LTRIM(RTRIM(@FechaHasta)) END;
    DECLARE @Tmp CHAR(8);

    IF SUBSTRING(@Desde, 5, 4) + SUBSTRING(@Desde, 3, 2) + SUBSTRING(@Desde, 1, 2)
       > SUBSTRING(@Hasta, 5, 4) + SUBSTRING(@Hasta, 3, 2) + SUBSTRING(@Hasta, 1, 2)
    BEGIN
        SET @Tmp = @Desde;
        SET @Desde = @Hasta;
        SET @Hasta = @Tmp;
    END

    IF @Pagina < 1 SET @Pagina = 1;
    IF @TamanioPagina < 1 SET @TamanioPagina = 50;

    SELECT @TotalRegistros = COUNT(*)
    FROM ASISTENCIA a
    INNER JOIN USUARIO u ON u.IDUSUARIO = a.IDUSUARIO
    WHERE SUBSTRING(a.FECHAREGISTRO, 5, 4) + SUBSTRING(a.FECHAREGISTRO, 3, 2) + SUBSTRING(a.FECHAREGISTRO, 1, 2)
          BETWEEN SUBSTRING(@Desde, 5, 4) + SUBSTRING(@Desde, 3, 2) + SUBSTRING(@Desde, 1, 2)
              AND SUBSTRING(@Hasta, 5, 4) + SUBSTRING(@Hasta, 3, 2) + SUBSTRING(@Hasta, 1, 2)
      AND (@Buscar IS NULL OR @Buscar = '' OR
           u.DNI LIKE '%' + @Buscar + '%' OR
           u.NOMBRE LIKE '%' + @Buscar + '%' OR
           u.APELLIDO LIKE '%' + @Buscar + '%' OR
           u.IDUSUARIO LIKE '%' + @Buscar + '%');

    SELECT
        a.IDASISTENCIA,
        a.FECHAREGISTRO,
        a.HORAINICIO,
        a.ESTADO,
        a.JUSTIFICADO,
        u.IDUSUARIO,
        u.NOMBRE,
        u.APELLIDO,
        u.DNI
    FROM ASISTENCIA a
    INNER JOIN USUARIO u ON u.IDUSUARIO = a.IDUSUARIO
    WHERE SUBSTRING(a.FECHAREGISTRO, 5, 4) + SUBSTRING(a.FECHAREGISTRO, 3, 2) + SUBSTRING(a.FECHAREGISTRO, 1, 2)
          BETWEEN SUBSTRING(@Desde, 5, 4) + SUBSTRING(@Desde, 3, 2) + SUBSTRING(@Desde, 1, 2)
              AND SUBSTRING(@Hasta, 5, 4) + SUBSTRING(@Hasta, 3, 2) + SUBSTRING(@Hasta, 1, 2)
      AND (@Buscar IS NULL OR @Buscar = '' OR
           u.DNI LIKE '%' + @Buscar + '%' OR
           u.NOMBRE LIKE '%' + @Buscar + '%' OR
           u.APELLIDO LIKE '%' + @Buscar + '%' OR
           u.IDUSUARIO LIKE '%' + @Buscar + '%')
    ORDER BY
        CASE WHEN @OrdenarPor = 'FECHAREGISTRO' AND @Direccion = 'ASC' THEN
            SUBSTRING(a.FECHAREGISTRO, 5, 4) + SUBSTRING(a.FECHAREGISTRO, 3, 2) + SUBSTRING(a.FECHAREGISTRO, 1, 2) END ASC,
        CASE WHEN @OrdenarPor = 'FECHAREGISTRO' AND @Direccion = 'DESC' THEN
            SUBSTRING(a.FECHAREGISTRO, 5, 4) + SUBSTRING(a.FECHAREGISTRO, 3, 2) + SUBSTRING(a.FECHAREGISTRO, 1, 2) END DESC,
        CASE WHEN @OrdenarPor = 'HORAINICIO' AND @Direccion = 'ASC'  THEN a.HORAINICIO END ASC,
        CASE WHEN @OrdenarPor = 'HORAINICIO' AND @Direccion = 'DESC' THEN a.HORAINICIO END DESC,
        CASE WHEN @OrdenarPor = 'NOMBRE'    AND @Direccion = 'ASC'  THEN u.NOMBRE END ASC,
        CASE WHEN @OrdenarPor = 'NOMBRE'    AND @Direccion = 'DESC' THEN u.NOMBRE END DESC,
        SUBSTRING(a.FECHAREGISTRO, 5, 4) + SUBSTRING(a.FECHAREGISTRO, 3, 2) + SUBSTRING(a.FECHAREGISTRO, 1, 2) DESC,
        a.HORAINICIO DESC
    OFFSET (@Pagina - 1) * @TamanioPagina ROWS
    FETCH NEXT @TamanioPagina ROWS ONLY;
END;
GO

PRINT 'usp_asistencia_listar: rango fecha inicio/fin listo.';
GO
