/* ============================================================================
   Alter: filtro opcional por estado de estudiante (@EstadoUsuario)
   Ejecutar después de 1.usp_asistencia_informe_filtro_plan.sql
   Fecha: 08/07/2026
   ============================================================================ */

IF OBJECT_ID('dbo.usp_asistencia_informe', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_asistencia_informe;
GO
CREATE PROCEDURE dbo.usp_asistencia_informe
    @FechaDesde     CHAR(8),
    @FechaHasta     CHAR(8),
    @Buscar         NVARCHAR(200) = NULL,
    @IDPlan         VARCHAR(20) = NULL,
    @EstadoUsuario  NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @FechaDesde IS NULL OR @FechaDesde = '' OR @FechaHasta IS NULL OR @FechaHasta = ''
    BEGIN
        RAISERROR('Debe indicar fecha desde y fecha hasta.', 16, 1);
        RETURN;
    END

    IF @FechaDesde > @FechaHasta
    BEGIN
        RAISERROR('La fecha desde no puede ser mayor que la fecha hasta.', 16, 1);
        RETURN;
    END

    SELECT
        u.IDUSUARIO,
        UPPER(LTRIM(RTRIM(
            ISNULL(u.APELLIDO, '') + ' ' + ISNULL(u.NOMBRE, '')
        ))) AS NOMBRE_COMPLETO,
        UPPER(ISNULL(u.ESTADO, 'Activo')) AS ESTADO,
        UPPER(ISNULL(tut.NOMBRE, '')) AS TUTORA,
        ISNULL(au.NOMBRE, '') AS AULA,
        UPPER(LTRIM(RTRIM(
            ISNULL(pl.NOMBRE, '') +
            CASE WHEN tu.DESCRIPCION IS NOT NULL AND tu.DESCRIPCION <> ''
                 THEN ' ' + tu.DESCRIPCION ELSE '' END
        ))) AS CICLO,
        mem.FECHAFIN AS FECHA_VENCE
    FROM USUARIO u
    OUTER APPLY (
        SELECT TOP 1 m.IDAULA, m.IDPLAN, m.IDTURNO, m.FECHAFIN
        FROM MEMBRESIA m
        WHERE m.IDUSUARIO = u.IDUSUARIO
          AND (m.ESTADO IS NULL OR m.ESTADO = 'Activo')
        ORDER BY
            CASE
                WHEN (m.FECHAINICIO IS NULL OR m.FECHAINICIO <= @FechaHasta)
                 AND (m.FECHAFIN IS NULL OR m.FECHAFIN >= @FechaDesde)
                THEN 0 ELSE 1
            END,
            m.FECHAREGISTRO DESC,
            m.FECHAINICIO DESC
    ) mem
    LEFT JOIN AULA au ON au.IDAULA = mem.IDAULA
    LEFT JOIN USUARIO tut ON tut.IDUSUARIO = au.IDTUTORA
    LEFT JOIN [PLAN] pl ON pl.IDPLAN = mem.IDPLAN
    LEFT JOIN TURNO tu ON tu.IDTURNO = mem.IDTURNO
    WHERE u.IDTIPOUSUARIO = '1'
      AND (
          @EstadoUsuario IS NULL OR @EstadoUsuario = '' OR
          UPPER(ISNULL(u.ESTADO, 'Activo')) = UPPER(@EstadoUsuario)
      )
      AND (
          @IDPlan IS NULL OR @IDPlan = '' OR mem.IDPLAN = @IDPlan
      )
      AND (
          @Buscar IS NULL OR @Buscar = '' OR
          u.DNI LIKE '%' + @Buscar + '%' OR
          u.NOMBRE LIKE '%' + @Buscar + '%' OR
          u.APELLIDO LIKE '%' + @Buscar + '%' OR
          u.IDUSUARIO LIKE '%' + @Buscar + '%' OR
          ISNULL(au.NOMBRE, '') LIKE '%' + @Buscar + '%'
      )
    ORDER BY u.APELLIDO, u.NOMBRE;

    SELECT
        a.IDUSUARIO,
        a.FECHAREGISTRO,
        a.ESTADO,
        a.JUSTIFICADO
    FROM ASISTENCIA a
    INNER JOIN USUARIO u ON u.IDUSUARIO = a.IDUSUARIO
    WHERE u.IDTIPOUSUARIO = '1'
      AND a.FECHAREGISTRO >= @FechaDesde
      AND a.FECHAREGISTRO <= @FechaHasta
      AND (
          @EstadoUsuario IS NULL OR @EstadoUsuario = '' OR
          UPPER(ISNULL(u.ESTADO, 'Activo')) = UPPER(@EstadoUsuario)
      )
      AND (
          @IDPlan IS NULL OR @IDPlan = '' OR
          EXISTS (
              SELECT 1
              FROM MEMBRESIA m
              WHERE m.IDUSUARIO = u.IDUSUARIO
                AND m.IDPLAN = @IDPlan
                AND (m.ESTADO IS NULL OR m.ESTADO = 'Activo')
                AND (m.FECHAINICIO IS NULL OR m.FECHAINICIO <= @FechaHasta)
                AND (m.FECHAFIN IS NULL OR m.FECHAFIN >= @FechaDesde)
          )
      )
      AND (
          @Buscar IS NULL OR @Buscar = '' OR
          u.DNI LIKE '%' + @Buscar + '%' OR
          u.NOMBRE LIKE '%' + @Buscar + '%' OR
          u.APELLIDO LIKE '%' + @Buscar + '%' OR
          u.IDUSUARIO LIKE '%' + @Buscar + '%'
      );
END;
GO

PRINT 'usp_asistencia_informe: filtro opcional @EstadoUsuario agregado.';
GO
