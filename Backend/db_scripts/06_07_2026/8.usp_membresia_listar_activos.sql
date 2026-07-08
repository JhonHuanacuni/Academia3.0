/* ============================================================================
   Fix listar: por defecto solo membresías Activas (las eliminadas no aparecen)
   Ejecutar después de 7.usp_membresia_crud.sql
   Fecha: 06/07/2026
   ============================================================================ */

IF OBJECT_ID('dbo.usp_membresia_listar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_membresia_listar;
GO
CREATE PROCEDURE dbo.usp_membresia_listar
    @Buscar         NVARCHAR(200) = NULL,
    @Estado         NVARCHAR(50)  = NULL,
    @OrdenarPor     NVARCHAR(50)  = 'FECHAREGISTRO',
    @Direccion      NVARCHAR(4)   = 'DESC',
    @Pagina         INT           = 1,
    @TamanioPagina  INT           = 10,
    @TotalRegistros INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    IF @Pagina < 1 SET @Pagina = 1;
    IF @TamanioPagina < 1 SET @TamanioPagina = 10;

    /* Sin filtro explícito → solo Activas (las dadas de baja quedan ocultas) */
    IF @Estado IS NULL OR @Estado = '' SET @Estado = 'Activo';

    SELECT @TotalRegistros = COUNT(*)
    FROM MEMBRESIA m
    INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
    INNER JOIN [PLAN] pl ON pl.IDPLAN = m.IDPLAN
    LEFT JOIN AULA au ON au.IDAULA = m.IDAULA
    LEFT JOIN TURNO tu ON tu.IDTURNO = m.IDTURNO
    WHERE m.ESTADO = @Estado
      AND (@Buscar IS NULL OR @Buscar = '' OR
           m.IDMEMBRESIA LIKE '%' + @Buscar + '%' OR
           u.DNI LIKE '%' + @Buscar + '%' OR
           u.NOMBRE LIKE '%' + @Buscar + '%' OR
           u.APELLIDO LIKE '%' + @Buscar + '%' OR
           pl.NOMBRE LIKE '%' + @Buscar + '%' OR
           ISNULL(au.NOMBRE, '') LIKE '%' + @Buscar + '%');

    SELECT
        m.IDMEMBRESIA,
        m.IDUSUARIO,
        UPPER(LTRIM(RTRIM(ISNULL(u.APELLIDO, '') + ' ' + ISNULL(u.NOMBRE, '')))) AS ESTUDIANTE_NOMBRE,
        u.DNI AS ESTUDIANTE_DNI,
        m.IDPLAN,
        pl.NOMBRE AS PLAN_NOMBRE,
        ISNULL(tu.DESCRIPCION, '') AS TURNO_DESCRIPCION,
        m.ESTADOMIEMBRO,
        CASE m.ESTADOMIEMBRO
            WHEN 1 THEN 'Nuevo'
            WHEN 2 THEN 'Activo'
            WHEN 3 THEN 'Vencido'
            WHEN 4 THEN 'Cancelado'
            ELSE '—'
        END AS ESTADOMIEMBRO_DESCRIPCION,
        m.FECHAINICIO,
        m.FECHAFIN,
        m.MONTOTOTAL,
        m.TIPOMEMBRESIA,
        ISNULL(au.NOMBRE, '') AS AULA_NOMBRE,
        m.ASESOR,
        m.ESTADO,
        m.FECHAREGISTRO
    FROM MEMBRESIA m
    INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
    INNER JOIN [PLAN] pl ON pl.IDPLAN = m.IDPLAN
    LEFT JOIN AULA au ON au.IDAULA = m.IDAULA
    LEFT JOIN TURNO tu ON tu.IDTURNO = m.IDTURNO
    WHERE m.ESTADO = @Estado
      AND (@Buscar IS NULL OR @Buscar = '' OR
           m.IDMEMBRESIA LIKE '%' + @Buscar + '%' OR
           u.DNI LIKE '%' + @Buscar + '%' OR
           u.NOMBRE LIKE '%' + @Buscar + '%' OR
           u.APELLIDO LIKE '%' + @Buscar + '%' OR
           pl.NOMBRE LIKE '%' + @Buscar + '%' OR
           ISNULL(au.NOMBRE, '') LIKE '%' + @Buscar + '%')
    ORDER BY
        CASE WHEN @OrdenarPor = 'IDMEMBRESIA' AND @Direccion = 'ASC'  THEN m.IDMEMBRESIA END ASC,
        CASE WHEN @OrdenarPor = 'IDMEMBRESIA' AND @Direccion = 'DESC' THEN m.IDMEMBRESIA END DESC,
        CASE WHEN @OrdenarPor = 'ESTUDIANTE_NOMBRE' AND @Direccion = 'ASC'  THEN u.APELLIDO END ASC,
        CASE WHEN @OrdenarPor = 'ESTUDIANTE_NOMBRE' AND @Direccion = 'DESC' THEN u.APELLIDO END DESC,
        CASE WHEN @OrdenarPor = 'FECHAINICIO' AND @Direccion = 'ASC'  THEN m.FECHAINICIO END ASC,
        CASE WHEN @OrdenarPor = 'FECHAINICIO' AND @Direccion = 'DESC' THEN m.FECHAINICIO END DESC,
        CASE WHEN @OrdenarPor = 'FECHAFIN' AND @Direccion = 'ASC'  THEN m.FECHAFIN END ASC,
        CASE WHEN @OrdenarPor = 'FECHAFIN' AND @Direccion = 'DESC' THEN m.FECHAFIN END DESC,
        CASE WHEN @OrdenarPor = 'MONTOTOTAL' AND @Direccion = 'ASC'  THEN m.MONTOTOTAL END ASC,
        CASE WHEN @OrdenarPor = 'MONTOTOTAL' AND @Direccion = 'DESC' THEN m.MONTOTOTAL END DESC,
        CASE WHEN @OrdenarPor = 'FECHAREGISTRO' AND @Direccion = 'ASC'  THEN m.FECHAREGISTRO END ASC,
        CASE WHEN @OrdenarPor = 'FECHAREGISTRO' AND @Direccion = 'DESC' THEN m.FECHAREGISTRO END DESC,
        m.IDMEMBRESIA DESC
    OFFSET (@Pagina - 1) * @TamanioPagina ROWS
    FETCH NEXT @TamanioPagina ROWS ONLY;
END;
GO

PRINT 'usp_membresia_listar actualizado: por defecto solo Activas.';
GO
