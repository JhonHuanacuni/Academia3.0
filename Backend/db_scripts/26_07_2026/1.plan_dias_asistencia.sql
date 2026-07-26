/* ============================================================================
   PLAN: días de asistencia por plan (bitmask lun=1, mar=2, … dom=64)
   Afecta informe de asistencias y referencia en horarios.
   Ejecutar después de 16_07_2026/11.plan_costo_mensual.sql
   Fecha: 26/07/2026
   ============================================================================ */

IF COL_LENGTH('PLAN', 'DIASASISTENCIA') IS NULL
BEGIN
    ALTER TABLE [PLAN] ADD DIASASISTENCIA TINYINT NOT NULL
        CONSTRAINT DF_PLAN_DIASASISTENCIA DEFAULT (63);
    PRINT 'Columna PLAN.DIASASISTENCIA agregada (default lun-sáb = 63).';
END
ELSE
    PRINT 'Columna PLAN.DIASASISTENCIA ya existe.';
GO

UPDATE [PLAN]
SET DIASASISTENCIA = 63
WHERE DIASASISTENCIA IS NULL OR DIASASISTENCIA = 0;
GO

IF OBJECT_ID('dbo.usp_plan_listar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_plan_listar;
GO
CREATE PROCEDURE dbo.usp_plan_listar
    @Buscar         NVARCHAR(200) = NULL,
    @Estado         NVARCHAR(50)  = NULL,
    @OrdenarPor     NVARCHAR(50)  = 'NOMBRE',
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
    FROM [PLAN] p
    WHERE (@Buscar IS NULL OR @Buscar = '' OR
           p.IDPLAN      LIKE '%' + @Buscar + '%' OR
           p.NOMBRE      LIKE '%' + @Buscar + '%' OR
           p.DESCRIPCION LIKE '%' + @Buscar + '%')
      AND (@Estado IS NULL OR @Estado = '' OR
           (@Estado = 'Activo' AND p.ACTIVO = 1) OR
           (@Estado = 'Inactivo' AND p.ACTIVO = 0));

    SELECT
        p.IDPLAN,
        p.NOMBRE,
        p.DESCRIPCION,
        p.COSTOMENSUAL,
        p.DIASASISTENCIA,
        CASE WHEN p.ACTIVO = 1 THEN 'Activo' ELSE 'Inactivo' END AS ESTADO
    FROM [PLAN] p
    WHERE (@Buscar IS NULL OR @Buscar = '' OR
           p.IDPLAN      LIKE '%' + @Buscar + '%' OR
           p.NOMBRE      LIKE '%' + @Buscar + '%' OR
           p.DESCRIPCION LIKE '%' + @Buscar + '%')
      AND (@Estado IS NULL OR @Estado = '' OR
           (@Estado = 'Activo' AND p.ACTIVO = 1) OR
           (@Estado = 'Inactivo' AND p.ACTIVO = 0))
    ORDER BY
        CASE WHEN @OrdenarPor = 'IDPLAN' AND @Direccion = 'ASC'  THEN p.IDPLAN END ASC,
        CASE WHEN @OrdenarPor = 'IDPLAN' AND @Direccion = 'DESC' THEN p.IDPLAN END DESC,
        CASE WHEN @OrdenarPor = 'NOMBRE' AND @Direccion = 'ASC'  THEN p.NOMBRE END ASC,
        CASE WHEN @OrdenarPor = 'NOMBRE' AND @Direccion = 'DESC' THEN p.NOMBRE END DESC,
        CASE WHEN @OrdenarPor = 'COSTOMENSUAL' AND @Direccion = 'ASC'  THEN p.COSTOMENSUAL END ASC,
        CASE WHEN @OrdenarPor = 'COSTOMENSUAL' AND @Direccion = 'DESC' THEN p.COSTOMENSUAL END DESC,
        CASE WHEN @OrdenarPor = 'ESTADO' AND @Direccion = 'ASC'  THEN p.ACTIVO END ASC,
        CASE WHEN @OrdenarPor = 'ESTADO' AND @Direccion = 'DESC' THEN p.ACTIVO END DESC,
        p.NOMBRE
    OFFSET (@Pagina - 1) * @TamanioPagina ROWS
    FETCH NEXT @TamanioPagina ROWS ONLY;
END;
GO

IF OBJECT_ID('dbo.usp_plan_obtener', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_plan_obtener;
GO
CREATE PROCEDURE dbo.usp_plan_obtener
    @Id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        p.IDPLAN,
        p.NOMBRE,
        p.DESCRIPCION,
        p.COSTOMENSUAL,
        p.DIASASISTENCIA,
        CASE WHEN p.ACTIVO = 1 THEN 'Activo' ELSE 'Inactivo' END AS ESTADO
    FROM [PLAN] p
    WHERE p.IDPLAN = @Id;
END;
GO

IF OBJECT_ID('dbo.usp_plan_insertar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_plan_insertar;
GO
CREATE PROCEDURE dbo.usp_plan_insertar
    @Id             NVARCHAR(50),
    @Nombre         NVARCHAR(100),
    @Descripcion    NVARCHAR(255)  = NULL,
    @CostoMensual   DECIMAL(10,2)  = NULL,
    @DiasAsistencia TINYINT        = 63,
    @Estado         NVARCHAR(50)   = 'Activo',
    @Resultado      INT OUTPUT,
    @Mensaje        NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF @Id IS NULL OR LTRIM(RTRIM(@Id)) = ''
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ingresa el código del plan.'; RETURN; END

    IF @Nombre IS NULL OR LTRIM(RTRIM(@Nombre)) = ''
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ingresa el nombre del plan.'; RETURN; END

    IF @CostoMensual IS NOT NULL AND @CostoMensual < 0
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El costo mensual no puede ser negativo.'; RETURN; END

    IF @DiasAsistencia IS NULL OR @DiasAsistencia = 0
        SET @DiasAsistencia = 63;

    IF EXISTS (SELECT 1 FROM [PLAN] WHERE IDPLAN = @Id)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El código de plan ya existe.'; RETURN; END

    IF EXISTS (SELECT 1 FROM [PLAN] WHERE NOMBRE = @Nombre)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ya existe un plan con ese nombre.'; RETURN; END

    INSERT INTO [PLAN] (IDPLAN, NOMBRE, DESCRIPCION, COSTOMENSUAL, DIASASISTENCIA, ACTIVO)
    VALUES (
        @Id,
        @Nombre,
        @Descripcion,
        @CostoMensual,
        @DiasAsistencia,
        CASE WHEN @Estado = 'Activo' THEN 1 ELSE 0 END
    );

    SET @Resultado = 1; SET @Mensaje = 'Plan registrado.';
END;
GO

IF OBJECT_ID('dbo.usp_plan_actualizar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_plan_actualizar;
GO
CREATE PROCEDURE dbo.usp_plan_actualizar
    @Id             NVARCHAR(50),
    @Nombre         NVARCHAR(100),
    @Descripcion    NVARCHAR(255)  = NULL,
    @CostoMensual   DECIMAL(10,2)  = NULL,
    @DiasAsistencia TINYINT        = 63,
    @Estado         NVARCHAR(50)   = 'Activo',
    @Resultado      INT OUTPUT,
    @Mensaje        NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM [PLAN] WHERE IDPLAN = @Id)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El plan no existe.'; RETURN; END

    IF @Nombre IS NULL OR LTRIM(RTRIM(@Nombre)) = ''
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ingresa el nombre del plan.'; RETURN; END

    IF @CostoMensual IS NOT NULL AND @CostoMensual < 0
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El costo mensual no puede ser negativo.'; RETURN; END

    IF @DiasAsistencia IS NULL OR @DiasAsistencia = 0
        SET @DiasAsistencia = 63;

    IF EXISTS (SELECT 1 FROM [PLAN] WHERE NOMBRE = @Nombre AND IDPLAN <> @Id)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ya existe un plan con ese nombre.'; RETURN; END

    UPDATE [PLAN] SET
        NOMBRE          = @Nombre,
        DESCRIPCION     = @Descripcion,
        COSTOMENSUAL    = @CostoMensual,
        DIASASISTENCIA  = @DiasAsistencia,
        ACTIVO          = CASE WHEN @Estado = 'Activo' THEN 1 ELSE 0 END
    WHERE IDPLAN = @Id;

    SET @Resultado = 1; SET @Mensaje = 'Plan actualizado.';
END;
GO

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
        mem.FECHAINICIO AS FECHA_INICIO_MEM,
        mem.FECHAFIN AS FECHA_VENCE,
        mem.IDPLAN,
        ISNULL(pl.DIASASISTENCIA, 63) AS DIASASISTENCIA
    FROM USUARIO u
    OUTER APPLY (
        SELECT TOP 1 m.IDAULA, m.IDPLAN, m.IDTURNO, m.FECHAINICIO, m.FECHAFIN
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

PRINT 'PLAN.DIASASISTENCIA, usp_plan_* y usp_asistencia_informe actualizados.';
GO
