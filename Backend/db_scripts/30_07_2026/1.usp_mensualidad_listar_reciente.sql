/* ============================================================================
   Mensualidad listar: una fila por estudiante (mensualidad más reciente)
   + listar todas las mensualidades de un estudiante
   Fecha: 30/07/2026
   ============================================================================ */

IF OBJECT_ID('dbo.usp_mensualidad_listar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_mensualidad_listar;
GO
CREATE PROCEDURE dbo.usp_mensualidad_listar
    @Buscar         NVARCHAR(200) = NULL,
    @Deuda          NVARCHAR(50)  = NULL,
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

    ;WITH Base AS (
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
            ISNULL(pag.PAGADO, 0) AS PAGADO,
            CASE WHEN ISNULL(m.MONTOTOTAL, 0) - ISNULL(pag.PAGADO, 0) < 0 THEN 0
                 ELSE ISNULL(m.MONTOTOTAL, 0) - ISNULL(pag.PAGADO, 0) END AS DEUDA,
            COUNT(*) OVER (PARTITION BY m.IDUSUARIO) AS CANT_MENSUALIDADES,
            SUM(
                CASE WHEN ISNULL(m.MONTOTOTAL, 0) - ISNULL(pag.PAGADO, 0) < 0 THEN 0
                     ELSE ISNULL(m.MONTOTOTAL, 0) - ISNULL(pag.PAGADO, 0) END
            ) OVER (PARTITION BY m.IDUSUARIO) AS DEUDA_TOTAL,
            ISNULL(au.NOMBRE, '') AS AULA_NOMBRE,
            m.IDTUTOR,
            ISNULL(tut.NOMBRE, ISNULL(m.TUTORLEGACY, '')) AS TUTOR_NOMBRE,
            m.REGISTRADOPOR,
            UPPER(LTRIM(RTRIM(
                ISNULL(reg.APELLIDO, '') + ' ' + ISNULL(reg.NOMBRE, '')
            ))) AS ASESOR_NOMBRE,
            m.ESTADO,
            m.FECHAREGISTRO,
            ROW_NUMBER() OVER (
                PARTITION BY m.IDUSUARIO
                ORDER BY m.FECHAREGISTRO DESC, m.IDMENSUALIDAD DESC
            ) AS RN
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
        WHERE m.ESTADO = 'Activo'
    ),
    Filtrada AS (
        SELECT *
        FROM Base
        WHERE RN = 1
          AND (@Buscar IS NULL OR @Buscar = '' OR
               IDMENSUALIDAD LIKE '%' + @Buscar + '%' OR
               ESTUDIANTE_DNI LIKE '%' + @Buscar + '%' OR
               ESTUDIANTE_NOMBRE LIKE '%' + @Buscar + '%' OR
               PLAN_NOMBRE LIKE '%' + @Buscar + '%' OR
               AULA_NOMBRE LIKE '%' + @Buscar + '%' OR
               TUTOR_NOMBRE LIKE '%' + @Buscar + '%')
          AND (
              @Deuda IS NULL OR @Deuda = '' OR
              (@Deuda IN ('con', 'Con deuda') AND DEUDA_TOTAL > 0) OR
              (@Deuda IN ('sin', 'Sin deuda') AND DEUDA_TOTAL <= 0)
          )
    )
    SELECT
        IDMENSUALIDAD,
        IDUSUARIO,
        ESTUDIANTE_NOMBRE,
        ESTUDIANTE_DNI,
        IDPLAN,
        PLAN_NOMBRE,
        TURNO_DESCRIPCION,
        ESTADOMIEMBRO,
        FECHAINICIO,
        FECHAFIN,
        MONTOTOTAL,
        PAGADO,
        DEUDA,
        CANT_MENSUALIDADES,
        DEUDA_TOTAL,
        AULA_NOMBRE,
        IDTUTOR,
        TUTOR_NOMBRE,
        REGISTRADOPOR,
        ASESOR_NOMBRE,
        ESTADO,
        FECHAREGISTRO
    INTO #Filtrada
    FROM Filtrada;

    SELECT @TotalRegistros = COUNT(*) FROM #Filtrada;

    SELECT
        IDMENSUALIDAD,
        IDUSUARIO,
        ESTUDIANTE_NOMBRE,
        ESTUDIANTE_DNI,
        IDPLAN,
        PLAN_NOMBRE,
        TURNO_DESCRIPCION,
        ESTADOMIEMBRO,
        FECHAINICIO,
        FECHAFIN,
        MONTOTOTAL,
        PAGADO,
        DEUDA,
        CANT_MENSUALIDADES,
        DEUDA_TOTAL,
        AULA_NOMBRE,
        IDTUTOR,
        TUTOR_NOMBRE,
        REGISTRADOPOR,
        ASESOR_NOMBRE,
        ESTADO,
        FECHAREGISTRO
    FROM #Filtrada
    ORDER BY
        CASE WHEN @OrdenarPor = 'FECHAREGISTRO' AND @Direccion = 'DESC' THEN FECHAREGISTRO END DESC,
        CASE WHEN @OrdenarPor = 'FECHAREGISTRO' AND @Direccion = 'ASC'  THEN FECHAREGISTRO END ASC,
        CASE WHEN @OrdenarPor IN ('DEUDA', 'DEUDA_TOTAL') AND @Direccion = 'DESC' THEN DEUDA_TOTAL END DESC,
        CASE WHEN @OrdenarPor IN ('DEUDA', 'DEUDA_TOTAL') AND @Direccion = 'ASC' THEN DEUDA_TOTAL END ASC,
        CASE WHEN @OrdenarPor = 'CANT_MENSUALIDADES' AND @Direccion = 'DESC' THEN CANT_MENSUALIDADES END DESC,
        CASE WHEN @OrdenarPor = 'CANT_MENSUALIDADES' AND @Direccion = 'ASC' THEN CANT_MENSUALIDADES END ASC,
        CASE WHEN @OrdenarPor = 'ESTUDIANTE_NOMBRE' AND @Direccion = 'DESC' THEN ESTUDIANTE_NOMBRE END DESC,
        CASE WHEN @OrdenarPor = 'ESTUDIANTE_NOMBRE' AND @Direccion = 'ASC' THEN ESTUDIANTE_NOMBRE END ASC,
        CASE WHEN @OrdenarPor = 'FECHAFIN' AND @Direccion = 'DESC' THEN FECHAFIN END DESC,
        CASE WHEN @OrdenarPor = 'FECHAFIN' AND @Direccion = 'ASC' THEN FECHAFIN END ASC,
        IDMENSUALIDAD DESC
    OFFSET (@Pagina - 1) * @TamanioPagina ROWS
    FETCH NEXT @TamanioPagina ROWS ONLY;

    DROP TABLE #Filtrada;
END;
GO

IF OBJECT_ID('dbo.usp_mensualidad_listar_estudiante', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_mensualidad_listar_estudiante;
GO
CREATE PROCEDURE dbo.usp_mensualidad_listar_estudiante
    @IdUsuario NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        m.IDMENSUALIDAD,
        m.IDUSUARIO,
        m.IDPLAN,
        pl.NOMBRE AS PLAN_NOMBRE,
        m.FECHAINICIO,
        m.FECHAFIN,
        m.MONTOTOTAL,
        ISNULL(pag.PAGADO, 0) AS PAGADO,
        CASE WHEN ISNULL(m.MONTOTOTAL, 0) - ISNULL(pag.PAGADO, 0) < 0 THEN 0
             ELSE ISNULL(m.MONTOTOTAL, 0) - ISNULL(pag.PAGADO, 0) END AS DEUDA,
        m.ESTADOMIEMBRO,
        CASE m.ESTADOMIEMBRO
            WHEN 2 THEN 'Activo'
            WHEN 3 THEN 'Vencido'
            ELSE 'Activo'
        END AS ESTADOMIEMBRO_DESCRIPCION,
        m.ESTADO,
        m.FECHAREGISTRO,
        ISNULL(au.NOMBRE, '') AS AULA_NOMBRE
    FROM MENSUALIDAD m
    INNER JOIN [PLAN] pl ON pl.IDPLAN = m.IDPLAN
    LEFT JOIN AULA au ON au.IDAULA = m.IDAULA
    OUTER APPLY (
        SELECT SUM(p.MONTO) AS PAGADO
        FROM PAGOMENSUALIDAD p
        WHERE p.IDMENSUALIDAD = m.IDMENSUALIDAD
    ) pag
    WHERE m.IDUSUARIO = @IdUsuario
      AND m.ESTADO = 'Activo'
    ORDER BY m.FECHAREGISTRO DESC, m.IDMENSUALIDAD DESC;
END;
GO

PRINT 'usp_mensualidad_listar (solo reciente por estudiante) y usp_mensualidad_listar_estudiante listos.';
GO
