/* ============================================================================
   PLAN: hora de entrada + tiempo extra (tolerancia) para tardanza al marcar asistencia
   Ejecutar después de 11.quitar_mantenedor_asesor.sql
   Fecha: 26/07/2026
   ============================================================================ */

IF COL_LENGTH('PLAN', 'HORAENTRADA') IS NULL
BEGIN
    ALTER TABLE [PLAN] ADD HORAENTRADA TIME NOT NULL
        CONSTRAINT DF_PLAN_HORAENTRADA DEFAULT ('08:00:00');
    PRINT 'Columna PLAN.HORAENTRADA agregada.';
END
ELSE
    PRINT 'Columna PLAN.HORAENTRADA ya existe.';
GO

IF COL_LENGTH('PLAN', 'TIEMPOEXTRA') IS NULL
BEGIN
    ALTER TABLE [PLAN] ADD TIEMPOEXTRA INT NOT NULL
        CONSTRAINT DF_PLAN_TIEMPOEXTRA DEFAULT (0);
    PRINT 'Columna PLAN.TIEMPOEXTRA agregada.';
END
ELSE
    PRINT 'Columna PLAN.TIEMPOEXTRA ya existe.';
GO

UPDATE [PLAN]
SET HORAENTRADA = ISNULL(HORAENTRADA, CAST('08:00:00' AS TIME)),
    TIEMPOEXTRA  = ISNULL(TIEMPOEXTRA, 0);
GO

/* Turno mañana: 8:00 + 15 min | Turno tarde: 14:00 + 15 min */
UPDATE [PLAN] SET HORAENTRADA = CAST('08:00:00' AS TIME), TIEMPOEXTRA = 15
WHERE IDTURNO = 'TUR001' OR IDTURNO IS NULL;

UPDATE [PLAN] SET HORAENTRADA = CAST('14:00:00' AS TIME), TIEMPOEXTRA = 15
WHERE IDTURNO = 'TUR002';
GO

/* ---- usp_plan_* con HORAENTRADA y TIEMPOEXTRA ---- */
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
        p.IDTURNO,
        CONVERT(VARCHAR(5), p.HORAENTRADA, 108) AS HORAENTRADA,
        p.TIEMPOEXTRA,
        ISNULL(tu.DESCRIPCION, '') AS TURNO_DESCRIPCION,
        CASE WHEN p.ACTIVO = 1 THEN 'Activo' ELSE 'Inactivo' END AS ESTADO
    FROM [PLAN] p
    LEFT JOIN TURNO tu ON tu.IDTURNO = p.IDTURNO
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
        p.IDTURNO,
        CONVERT(VARCHAR(5), p.HORAENTRADA, 108) AS HORAENTRADA,
        p.TIEMPOEXTRA,
        ISNULL(tu.DESCRIPCION, '') AS TURNO_DESCRIPCION,
        CASE WHEN p.ACTIVO = 1 THEN 'Activo' ELSE 'Inactivo' END AS ESTADO
    FROM [PLAN] p
    LEFT JOIN TURNO tu ON tu.IDTURNO = p.IDTURNO
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
    @IdTurno        NVARCHAR(50)   = NULL,
    @HoraEntrada    TIME           = NULL,
    @TiempoExtra    INT            = 0,
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

    IF @HoraEntrada IS NULL
        SET @HoraEntrada = CAST('08:00:00' AS TIME);

    IF @TiempoExtra IS NULL OR @TiempoExtra < 0
        SET @TiempoExtra = 0;

    IF @IdTurno IS NOT NULL AND @IdTurno <> ''
       AND NOT EXISTS (SELECT 1 FROM TURNO WHERE IDTURNO = @IdTurno)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El turno seleccionado no es válido.'; RETURN; END

    IF EXISTS (SELECT 1 FROM [PLAN] WHERE IDPLAN = @Id)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El código de plan ya existe.'; RETURN; END

    IF EXISTS (SELECT 1 FROM [PLAN] WHERE NOMBRE = @Nombre)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ya existe un plan con ese nombre.'; RETURN; END

    INSERT INTO [PLAN] (IDPLAN, NOMBRE, DESCRIPCION, COSTOMENSUAL, DIASASISTENCIA, IDTURNO, HORAENTRADA, TIEMPOEXTRA, ACTIVO)
    VALUES (
        @Id,
        @Nombre,
        @Descripcion,
        @CostoMensual,
        @DiasAsistencia,
        NULLIF(@IdTurno, ''),
        @HoraEntrada,
        @TiempoExtra,
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
    @IdTurno        NVARCHAR(50)   = NULL,
    @HoraEntrada    TIME           = NULL,
    @TiempoExtra    INT            = 0,
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

    IF @HoraEntrada IS NULL
        SET @HoraEntrada = CAST('08:00:00' AS TIME);

    IF @TiempoExtra IS NULL OR @TiempoExtra < 0
        SET @TiempoExtra = 0;

    IF @IdTurno IS NOT NULL AND @IdTurno <> ''
       AND NOT EXISTS (SELECT 1 FROM TURNO WHERE IDTURNO = @IdTurno)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El turno seleccionado no es válido.'; RETURN; END

    IF EXISTS (SELECT 1 FROM [PLAN] WHERE NOMBRE = @Nombre AND IDPLAN <> @Id)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ya existe un plan con ese nombre.'; RETURN; END

    UPDATE [PLAN] SET
        NOMBRE          = @Nombre,
        DESCRIPCION     = @Descripcion,
        COSTOMENSUAL    = @CostoMensual,
        DIASASISTENCIA  = @DiasAsistencia,
        IDTURNO         = NULLIF(@IdTurno, ''),
        HORAENTRADA     = @HoraEntrada,
        TIEMPOEXTRA     = @TiempoExtra,
        ACTIVO          = CASE WHEN @Estado = 'Activo' THEN 1 ELSE 0 END
    WHERE IDPLAN = @Id;

    UPDATE m
    SET m.IDTURNO = NULLIF(@IdTurno, '')
    FROM MENSUALIDAD m
    WHERE m.IDPLAN = @Id;

    SET @Resultado = 1; SET @Mensaje = 'Plan actualizado.';
END;
GO

/* ---- Marcar asistencia según plan del estudiante ---- */
IF OBJECT_ID('dbo.usp_asistencia_marcar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_asistencia_marcar;
GO
CREATE PROCEDURE dbo.usp_asistencia_marcar
    @Dni            NVARCHAR(20),
    @IdRegistrador  NVARCHAR(50) = NULL,
    @Resultado      INT OUTPUT,
    @Mensaje        NVARCHAR(200) OUTPUT,
    @IdAsistencia   NVARCHAR(50) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @IdUsuario NVARCHAR(50);
    DECLARE @FechaHoy CHAR(8) = dbo.fn_fecha_ddmmyyyy();
    DECLARE @HoraAhora TIME;
    DECLARE @Estado NVARCHAR(50);
    DECLARE @HoraEntrada TIME = CAST('08:00:00' AS TIME);
    DECLARE @TiempoExtra INT = 0;
    DECLARE @HoraLimite TIME;

    SET @HoraAhora = CAST(CAST(SYSDATETIMEOFFSET() AT TIME ZONE 'SA Pacific Standard Time' AS DATETIME2) AS TIME);

    SELECT @IdUsuario = IDUSUARIO
    FROM USUARIO
    WHERE DNI = @Dni AND ESTADO = 'Activo';

    IF @IdUsuario IS NULL
    BEGIN
        SET @Resultado = 0;
        SET @Mensaje = 'Usuario no encontrado con ese DNI.';
        SET @IdAsistencia = NULL;
        RETURN;
    END

    IF EXISTS (
        SELECT 1 FROM ASISTENCIA
        WHERE IDUSUARIO = @IdUsuario AND FECHAREGISTRO = @FechaHoy
    )
    BEGIN
        SET @Resultado = 0;
        SET @Mensaje = 'Este estudiante ya tiene su asistencia registrada para hoy.';
        SET @IdAsistencia = NULL;
        RETURN;
    END

    SELECT TOP 1
        @HoraEntrada = ISNULL(p.HORAENTRADA, CAST('08:00:00' AS TIME)),
        @TiempoExtra = ISNULL(p.TIEMPOEXTRA, 0)
    FROM MENSUALIDAD m
    INNER JOIN [PLAN] p ON p.IDPLAN = m.IDPLAN
    WHERE m.IDUSUARIO = @IdUsuario
      AND (m.ESTADO IS NULL OR m.ESTADO = 'Activo')
      AND (
          m.FECHAINICIO IS NULL OR m.FECHAINICIO = '' OR
          CONVERT(DATE,
              SUBSTRING(m.FECHAINICIO, 5, 4) + '-' +
              SUBSTRING(m.FECHAINICIO, 3, 2) + '-' +
              SUBSTRING(m.FECHAINICIO, 1, 2)
          ) <= CONVERT(DATE,
              SUBSTRING(@FechaHoy, 5, 4) + '-' +
              SUBSTRING(@FechaHoy, 3, 2) + '-' +
              SUBSTRING(@FechaHoy, 1, 2)
          )
      )
      AND (
          m.FECHAFIN IS NULL OR m.FECHAFIN = '' OR
          CONVERT(DATE,
              SUBSTRING(m.FECHAFIN, 5, 4) + '-' +
              SUBSTRING(m.FECHAFIN, 3, 2) + '-' +
              SUBSTRING(m.FECHAFIN, 1, 2)
          ) >= CONVERT(DATE,
              SUBSTRING(@FechaHoy, 5, 4) + '-' +
              SUBSTRING(@FechaHoy, 3, 2) + '-' +
              SUBSTRING(@FechaHoy, 1, 2)
          )
      )
    ORDER BY m.FECHAREGISTRO DESC, m.FECHAINICIO DESC;

    SET @HoraLimite = CAST(DATEADD(MINUTE, @TiempoExtra, CAST(@HoraEntrada AS DATETIME)) AS TIME);

    IF @HoraAhora <= @HoraLimite
        SET @Estado = 'Presente';
    ELSE
        SET @Estado = 'Tarde';

    SET @IdAsistencia = 'AS_' + REPLACE(CONVERT(NVARCHAR(36), NEWID()), '-', '');

    INSERT INTO ASISTENCIA (
        IDASISTENCIA, FECHAREGISTRO, HORAINICIO, ESTADO, JUSTIFICADO, IDUSUARIO
    ) VALUES (
        @IdAsistencia, @FechaHoy,
        CONVERT(CHAR(8), @HoraAhora, 108),
        @Estado, 0, @IdUsuario
    );

    SET @Resultado = 1;
    SET @Mensaje = 'Asistencia registrada.';
END;
GO

PRINT 'PLAN.HORAENTRADA, PLAN.TIEMPOEXTRA, usp_plan_* y usp_asistencia_marcar actualizados.';
GO
