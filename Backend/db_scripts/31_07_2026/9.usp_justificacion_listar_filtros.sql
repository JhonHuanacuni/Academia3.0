/* ============================================================================
   Justificación listar: filtros tutor, ciclo (plan), fechas y turno
   Ejecutar después de 26_07_2026/14.justificacion.sql
   Fecha: 31/07/2026
   ============================================================================ */

IF OBJECT_ID('dbo.usp_justificacion_listar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_justificacion_listar;
GO
CREATE PROCEDURE dbo.usp_justificacion_listar
    @Buscar         NVARCHAR(200) = NULL,
    @IdTutor        NVARCHAR(50)  = NULL,
    @IdPlan         NVARCHAR(20)  = NULL,
    @FechaDesde     CHAR(8)       = NULL,
    @FechaHasta     CHAR(8)       = NULL,
    @IdTurno        NVARCHAR(50)  = NULL,
    @Pagina         INT           = 1,
    @TamanioPagina  INT           = 10,
    @TotalRegistros INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    IF @Pagina < 1 SET @Pagina = 1;
    IF @TamanioPagina < 1 SET @TamanioPagina = 10;

    SELECT @TotalRegistros = COUNT(*)
    FROM JUSTIFICACION j
    INNER JOIN USUARIO est ON est.IDUSUARIO = j.IDUSUARIO
    LEFT JOIN USUARIO reg ON reg.IDUSUARIO = j.IDREGISTRADOR
    OUTER APPLY (
        SELECT TOP 1 m.IDPLAN, m.IDTURNO, m.IDTUTOR
        FROM MENSUALIDAD m
        WHERE m.IDUSUARIO = j.IDUSUARIO
          AND (m.ESTADO IS NULL OR m.ESTADO = 'Activo')
          AND (m.FECHAINICIO IS NULL OR m.FECHAINICIO <= j.FECHA)
          AND (m.FECHAFIN IS NULL OR m.FECHAFIN >= j.FECHA)
        ORDER BY m.FECHAREGISTRO DESC, m.IDMENSUALIDAD DESC
    ) mem
    LEFT JOIN [PLAN] pl ON pl.IDPLAN = mem.IDPLAN
    WHERE (@Buscar IS NULL OR @Buscar = ''
       OR est.DNI LIKE '%' + @Buscar + '%'
       OR est.NOMBRE LIKE '%' + @Buscar + '%'
       OR est.APELLIDO LIKE '%' + @Buscar + '%'
       OR j.OBSERVACION LIKE '%' + @Buscar + '%'
       OR reg.NOMBRE LIKE '%' + @Buscar + '%'
       OR reg.APELLIDO LIKE '%' + @Buscar + '%')
      AND (@FechaDesde IS NULL OR @FechaDesde = '' OR j.FECHA >= @FechaDesde)
      AND (@FechaHasta IS NULL OR @FechaHasta = '' OR j.FECHA <= @FechaHasta)
      AND (@IdTutor IS NULL OR @IdTutor = '' OR mem.IDTUTOR = @IdTutor)
      AND (@IdPlan IS NULL OR @IdPlan = '' OR mem.IDPLAN = @IdPlan)
      AND (@IdTurno IS NULL OR @IdTurno = '' OR ISNULL(pl.IDTURNO, mem.IDTURNO) = @IdTurno);

    SELECT
        j.IDJUSTIFICACION,
        j.IDUSUARIO,
        j.FECHA,
        j.HORAREGISTRO,
        j.IDREGISTRADOR,
        j.OBSERVACION,
        est.NOMBRE AS ESTUDIANTE_NOMBRE,
        est.APELLIDO AS ESTUDIANTE_APELLIDO,
        est.DNI,
        LTRIM(RTRIM(ISNULL(reg.NOMBRE, '') + ' ' + ISNULL(reg.APELLIDO, ''))) AS REGISTRADOR_NOMBRE
    FROM JUSTIFICACION j
    INNER JOIN USUARIO est ON est.IDUSUARIO = j.IDUSUARIO
    LEFT JOIN USUARIO reg ON reg.IDUSUARIO = j.IDREGISTRADOR
    OUTER APPLY (
        SELECT TOP 1 m.IDPLAN, m.IDTURNO, m.IDTUTOR
        FROM MENSUALIDAD m
        WHERE m.IDUSUARIO = j.IDUSUARIO
          AND (m.ESTADO IS NULL OR m.ESTADO = 'Activo')
          AND (m.FECHAINICIO IS NULL OR m.FECHAINICIO <= j.FECHA)
          AND (m.FECHAFIN IS NULL OR m.FECHAFIN >= j.FECHA)
        ORDER BY m.FECHAREGISTRO DESC, m.IDMENSUALIDAD DESC
    ) mem
    LEFT JOIN [PLAN] pl ON pl.IDPLAN = mem.IDPLAN
    WHERE (@Buscar IS NULL OR @Buscar = ''
       OR est.DNI LIKE '%' + @Buscar + '%'
       OR est.NOMBRE LIKE '%' + @Buscar + '%'
       OR est.APELLIDO LIKE '%' + @Buscar + '%'
       OR j.OBSERVACION LIKE '%' + @Buscar + '%'
       OR reg.NOMBRE LIKE '%' + @Buscar + '%'
       OR reg.APELLIDO LIKE '%' + @Buscar + '%')
      AND (@FechaDesde IS NULL OR @FechaDesde = '' OR j.FECHA >= @FechaDesde)
      AND (@FechaHasta IS NULL OR @FechaHasta = '' OR j.FECHA <= @FechaHasta)
      AND (@IdTutor IS NULL OR @IdTutor = '' OR mem.IDTUTOR = @IdTutor)
      AND (@IdPlan IS NULL OR @IdPlan = '' OR mem.IDPLAN = @IdPlan)
      AND (@IdTurno IS NULL OR @IdTurno = '' OR ISNULL(pl.IDTURNO, mem.IDTURNO) = @IdTurno)
    ORDER BY j.FECHA DESC, j.HORAREGISTRO DESC
    OFFSET (@Pagina - 1) * @TamanioPagina ROWS
    FETCH NEXT @TamanioPagina ROWS ONLY;
END;
GO

PRINT 'usp_justificacion_listar: filtros tutor, ciclo, fechas y turno listos.';
GO
