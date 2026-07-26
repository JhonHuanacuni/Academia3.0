/* ============================================================================
   Membresías: columna DEUDA en listado (MONTOTOTAL − suma pagos)
   Ejecutar después de 12_07_2026/10.comoentero_a_usuario.sql
   Fecha: 16/07/2026
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
    IF @Estado IS NULL OR @Estado = '' SET @Estado = 'Activo';

    SELECT @TotalRegistros = COUNT(*)
    FROM MEMBRESIA m
    INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
    INNER JOIN [PLAN] pl ON pl.IDPLAN = m.IDPLAN
    LEFT JOIN AULA au ON au.IDAULA = m.IDAULA
    LEFT JOIN TURNO tu ON tu.IDTURNO = m.IDTURNO
    LEFT JOIN ASESOR ase ON ase.IDASESOR = m.IDASESOR
    WHERE m.ESTADO = @Estado
      AND (@Buscar IS NULL OR @Buscar = '' OR
           m.IDMEMBRESIA LIKE '%' + @Buscar + '%' OR
           u.DNI LIKE '%' + @Buscar + '%' OR
           u.NOMBRE LIKE '%' + @Buscar + '%' OR
           u.APELLIDO LIKE '%' + @Buscar + '%' OR
           pl.NOMBRE LIKE '%' + @Buscar + '%' OR
           ISNULL(au.NOMBRE, '') LIKE '%' + @Buscar + '%' OR
           ISNULL(ase.NOMBRE, '') LIKE '%' + @Buscar + '%');

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
            WHEN 2 THEN 'Activo'
            WHEN 3 THEN 'Vencido'
            ELSE 'Activo'
        END AS ESTADOMIEMBRO_DESCRIPCION,
        m.FECHAINICIO,
        m.FECHAFIN,
        m.MONTOTOTAL,
        ISNULL(pag.PAGADO, 0) AS PAGADO,
        CASE
            WHEN ISNULL(m.MONTOTOTAL, 0) - ISNULL(pag.PAGADO, 0) < 0 THEN 0
            ELSE ISNULL(m.MONTOTOTAL, 0) - ISNULL(pag.PAGADO, 0)
        END AS DEUDA,
        ISNULL(au.NOMBRE, '') AS AULA_NOMBRE,
        m.IDASESOR,
        ISNULL(ase.NOMBRE, ISNULL(m.ASESOR, '')) AS ASESOR_NOMBRE,
        m.ESTADO,
        m.FECHAREGISTRO
    FROM MEMBRESIA m
    INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
    INNER JOIN [PLAN] pl ON pl.IDPLAN = m.IDPLAN
    LEFT JOIN AULA au ON au.IDAULA = m.IDAULA
    LEFT JOIN TURNO tu ON tu.IDTURNO = m.IDTURNO
    LEFT JOIN ASESOR ase ON ase.IDASESOR = m.IDASESOR
    OUTER APPLY (
        SELECT SUM(p.MONTO) AS PAGADO
        FROM PAGOMEMBRESIA p
        WHERE p.IDMEMBRESIA = m.IDMEMBRESIA
    ) pag
    WHERE m.ESTADO = @Estado
      AND (@Buscar IS NULL OR @Buscar = '' OR
           m.IDMEMBRESIA LIKE '%' + @Buscar + '%' OR
           u.DNI LIKE '%' + @Buscar + '%' OR
           u.NOMBRE LIKE '%' + @Buscar + '%' OR
           u.APELLIDO LIKE '%' + @Buscar + '%' OR
           pl.NOMBRE LIKE '%' + @Buscar + '%' OR
           ISNULL(au.NOMBRE, '') LIKE '%' + @Buscar + '%' OR
           ISNULL(ase.NOMBRE, '') LIKE '%' + @Buscar + '%')
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
        CASE WHEN @OrdenarPor = 'DEUDA' AND @Direccion = 'ASC' THEN
            ISNULL(m.MONTOTOTAL, 0) - ISNULL(pag.PAGADO, 0) END ASC,
        CASE WHEN @OrdenarPor = 'DEUDA' AND @Direccion = 'DESC' THEN
            ISNULL(m.MONTOTOTAL, 0) - ISNULL(pag.PAGADO, 0) END DESC,
        CASE WHEN @OrdenarPor = 'FECHAREGISTRO' AND @Direccion = 'ASC'  THEN m.FECHAREGISTRO END ASC,
        CASE WHEN @OrdenarPor = 'FECHAREGISTRO' AND @Direccion = 'DESC' THEN m.FECHAREGISTRO END DESC,
        m.IDMEMBRESIA DESC
    OFFSET (@Pagina - 1) * @TamanioPagina ROWS
    FETCH NEXT @TamanioPagina ROWS ONLY;
END;
GO

PRINT 'usp_membresia_listar actualizado con DEUDA.';
GO
