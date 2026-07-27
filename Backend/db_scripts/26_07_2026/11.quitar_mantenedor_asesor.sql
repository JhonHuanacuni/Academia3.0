/* ============================================================================
   Quitar mantenedor Asesores; ASESOR_NOMBRE = usuario logueado (REGISTRADOPOR)
   Ejecutar después de 10.tutor_codigo_tut.sql
   Fecha: 26/07/2026
   ============================================================================ */

UPDATE SUBMODULO SET ACTIVO = 0 WHERE IDSUBMODULO = 'SUB024';
GO

IF OBJECT_ID('dbo.usp_mensualidad_listar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_mensualidad_listar;
GO
CREATE PROCEDURE dbo.usp_mensualidad_listar
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
    FROM MENSUALIDAD m
    INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
    INNER JOIN [PLAN] pl ON pl.IDPLAN = m.IDPLAN
    LEFT JOIN AULA au ON au.IDAULA = m.IDAULA
    LEFT JOIN TUTOR tut ON tut.IDTUTOR = m.IDTUTOR
    WHERE m.ESTADO = @Estado
      AND (@Buscar IS NULL OR @Buscar = '' OR
           m.IDMENSUALIDAD LIKE '%' + @Buscar + '%' OR
           u.DNI LIKE '%' + @Buscar + '%' OR
           u.NOMBRE LIKE '%' + @Buscar + '%' OR
           u.APELLIDO LIKE '%' + @Buscar + '%' OR
           pl.NOMBRE LIKE '%' + @Buscar + '%' OR
           ISNULL(au.NOMBRE, '') LIKE '%' + @Buscar + '%' OR
           ISNULL(tut.NOMBRE, '') LIKE '%' + @Buscar + '%');

    SELECT
        m.IDMENSUALIDAD,
        m.IDUSUARIO,
        UPPER(LTRIM(RTRIM(ISNULL(u.APELLIDO, '') + ' ' + ISNULL(u.NOMBRE, '')))) AS ESTUDIANTE_NOMBRE,
        u.DNI AS ESTUDIANTE_DNI,
        m.IDPLAN,
        pl.NOMBRE AS PLAN_NOMBRE,
        ISNULL(tu.DESCRIPCION, '') AS TURNO_DESCRIPCION,
        m.ESTADOMIEMBRO,
        CASE m.ESTADOMIEMBRO WHEN 2 THEN 'Activo' WHEN 3 THEN 'Vencido' ELSE 'Activo' END AS ESTADOMIEMBRO_DESCRIPCION,
        m.FECHAINICIO,
        m.FECHAFIN,
        m.MONTOTOTAL,
        ISNULL(pag.PAGADO, 0) AS PAGADO,
        CASE WHEN ISNULL(m.MONTOTOTAL, 0) - ISNULL(pag.PAGADO, 0) < 0 THEN 0
             ELSE ISNULL(m.MONTOTOTAL, 0) - ISNULL(pag.PAGADO, 0) END AS DEUDA,
        ISNULL(au.NOMBRE, '') AS AULA_NOMBRE,
        m.IDTUTOR,
        ISNULL(tut.NOMBRE, ISNULL(m.TUTORLEGACY, '')) AS TUTOR_NOMBRE,
        m.REGISTRADOPOR,
        UPPER(LTRIM(RTRIM(
            ISNULL(reg.APELLIDO, '') + ' ' + ISNULL(reg.NOMBRE, '')
        ))) AS ASESOR_NOMBRE,
        m.ESTADO,
        m.FECHAREGISTRO
    FROM MENSUALIDAD m
    INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
    INNER JOIN [PLAN] pl ON pl.IDPLAN = m.IDPLAN
    LEFT JOIN TURNO tu ON tu.IDTURNO = ISNULL(pl.IDTURNO, m.IDTURNO)
    LEFT JOIN AULA au ON au.IDAULA = m.IDAULA
    LEFT JOIN TUTOR tut ON tut.IDTUTOR = m.IDTUTOR
    LEFT JOIN USUARIO reg ON reg.IDUSUARIO = m.REGISTRADOPOR
    OUTER APPLY (
        SELECT SUM(p.MONTO) AS PAGADO FROM PAGOMENSUALIDAD p WHERE p.IDMENSUALIDAD = m.IDMENSUALIDAD
    ) pag
    WHERE m.ESTADO = @Estado
      AND (@Buscar IS NULL OR @Buscar = '' OR
           m.IDMENSUALIDAD LIKE '%' + @Buscar + '%' OR
           u.DNI LIKE '%' + @Buscar + '%' OR
           u.NOMBRE LIKE '%' + @Buscar + '%' OR
           u.APELLIDO LIKE '%' + @Buscar + '%' OR
           pl.NOMBRE LIKE '%' + @Buscar + '%' OR
           ISNULL(au.NOMBRE, '') LIKE '%' + @Buscar + '%' OR
           ISNULL(tut.NOMBRE, '') LIKE '%' + @Buscar + '%')
    ORDER BY
        CASE WHEN @OrdenarPor = 'FECHAREGISTRO' AND @Direccion = 'DESC' THEN m.FECHAREGISTRO END DESC,
        m.IDMENSUALIDAD DESC
    OFFSET (@Pagina - 1) * @TamanioPagina ROWS
    FETCH NEXT @TamanioPagina ROWS ONLY;
END;
GO

IF OBJECT_ID('dbo.usp_mensualidad_obtener', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_mensualidad_obtener;
GO
CREATE PROCEDURE dbo.usp_mensualidad_obtener @Id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        m.IDMENSUALIDAD,
        m.IDUSUARIO,
        UPPER(LTRIM(RTRIM(ISNULL(u.APELLIDO, '') + ' ' + ISNULL(u.NOMBRE, '')))) AS ESTUDIANTE_NOMBRE,
        u.DNI AS ESTUDIANTE_DNI,
        m.IDPLAN,
        pl.NOMBRE AS PLAN_NOMBRE,
        ISNULL(tu.DESCRIPCION, '') AS TURNO_DESCRIPCION,
        m.ESTADOMIEMBRO,
        m.FECHAINICIO,
        m.FECHAFIN,
        m.MONTOTOTAL,
        m.IDAULA,
        ISNULL(au.NOMBRE, '') AS AULA_NOMBRE,
        m.IDTUTOR,
        ISNULL(tut.NOMBRE, ISNULL(m.TUTORLEGACY, '')) AS TUTOR_NOMBRE,
        m.OBSERVACIONES,
        m.FECHACANCELACION,
        m.ESTADO,
        m.FECHAREGISTRO,
        m.REGISTRADOPOR,
        UPPER(LTRIM(RTRIM(
            ISNULL(reg.APELLIDO, '') + ' ' + ISNULL(reg.NOMBRE, '')
        ))) AS ASESOR_NOMBRE,
        ISNULL(pag.PAGOINICIAL, 0) AS PAGOINICIAL,
        pag.IDMETODOPAGO
    FROM MENSUALIDAD m
    INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
    INNER JOIN [PLAN] pl ON pl.IDPLAN = m.IDPLAN
    LEFT JOIN TURNO tu ON tu.IDTURNO = ISNULL(pl.IDTURNO, m.IDTURNO)
    LEFT JOIN AULA au ON au.IDAULA = m.IDAULA
    LEFT JOIN TUTOR tut ON tut.IDTUTOR = m.IDTUTOR
    LEFT JOIN USUARIO reg ON reg.IDUSUARIO = m.REGISTRADOPOR
    OUTER APPLY (
        SELECT TOP 1 p.MONTO AS PAGOINICIAL, p.IDMETODOPAGO
        FROM PAGOMENSUALIDAD p
        WHERE p.IDMENSUALIDAD = m.IDMENSUALIDAD
        ORDER BY p.FECHAPAGO, p.IDPAGOMENSUALIDAD
    ) pag
    WHERE m.IDMENSUALIDAD = @Id;
END;
GO

PRINT 'SUB024 desactivado; ASESOR_NOMBRE desde usuario logueado (REGISTRADOPOR).';
GO
