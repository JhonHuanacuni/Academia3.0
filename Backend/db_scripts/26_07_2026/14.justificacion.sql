/* ============================================================================
   Justificación de asistencias — tabla + SPs CRUD
   Ejecutar después de 13.mantenedores_codigo_autogenerado.sql
   Fecha: 26/07/2026
   ============================================================================ */

IF OBJECT_ID('dbo.JUSTIFICACION', 'U') IS NULL
BEGIN
    CREATE TABLE JUSTIFICACION (
        IDJUSTIFICACION NVARCHAR(50)  NOT NULL PRIMARY KEY,
        IDUSUARIO       NVARCHAR(50)  NOT NULL,
        FECHA           CHAR(8)       NOT NULL,
        HORAREGISTRO    CHAR(8)       NOT NULL,
        IDREGISTRADOR   NVARCHAR(50)  NULL,
        OBSERVACION     NVARCHAR(500) NULL,
        FECHACREACION   CHAR(8)       NOT NULL DEFAULT dbo.fn_fecha_ddmmyyyy(),
        CONSTRAINT FK_JUSTIFICACION_USUARIO FOREIGN KEY (IDUSUARIO) REFERENCES USUARIO(IDUSUARIO),
        CONSTRAINT FK_JUSTIFICACION_REGISTRADOR FOREIGN KEY (IDREGISTRADOR) REFERENCES USUARIO(IDUSUARIO)
    );
    CREATE INDEX IX_JUSTIFICACION_USUARIO_FECHA ON JUSTIFICACION(IDUSUARIO, FECHA);
END
GO

IF OBJECT_ID('dbo.usp_justificacion_listar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_justificacion_listar;
GO
CREATE PROCEDURE dbo.usp_justificacion_listar
    @Buscar         NVARCHAR(200) = NULL,
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
    WHERE @Buscar IS NULL OR @Buscar = ''
       OR est.DNI LIKE '%' + @Buscar + '%'
       OR est.NOMBRE LIKE '%' + @Buscar + '%'
       OR est.APELLIDO LIKE '%' + @Buscar + '%'
       OR j.OBSERVACION LIKE '%' + @Buscar + '%'
       OR reg.NOMBRE LIKE '%' + @Buscar + '%'
       OR reg.APELLIDO LIKE '%' + @Buscar + '%';

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
    WHERE @Buscar IS NULL OR @Buscar = ''
       OR est.DNI LIKE '%' + @Buscar + '%'
       OR est.NOMBRE LIKE '%' + @Buscar + '%'
       OR est.APELLIDO LIKE '%' + @Buscar + '%'
       OR j.OBSERVACION LIKE '%' + @Buscar + '%'
       OR reg.NOMBRE LIKE '%' + @Buscar + '%'
       OR reg.APELLIDO LIKE '%' + @Buscar + '%'
    ORDER BY j.FECHA DESC, j.HORAREGISTRO DESC
    OFFSET (@Pagina - 1) * @TamanioPagina ROWS
    FETCH NEXT @TamanioPagina ROWS ONLY;
END;
GO

IF OBJECT_ID('dbo.usp_justificacion_obtener', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_justificacion_obtener;
GO
CREATE PROCEDURE dbo.usp_justificacion_obtener
    @Id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
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
    WHERE j.IDJUSTIFICACION = @Id;
END;
GO

IF OBJECT_ID('dbo.usp_justificacion_insertar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_justificacion_insertar;
GO
CREATE PROCEDURE dbo.usp_justificacion_insertar
    @IdUsuario      NVARCHAR(50),
    @Fecha          CHAR(8),
    @IdRegistrador  NVARCHAR(50)  = NULL,
    @Observacion    NVARCHAR(500) = NULL,
    @Resultado      INT OUTPUT,
    @Mensaje        NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF @IdUsuario IS NULL OR LTRIM(RTRIM(@IdUsuario)) = ''
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Selecciona un estudiante.'; RETURN; END

    IF @Fecha IS NULL OR LTRIM(RTRIM(@Fecha)) = ''
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Selecciona la fecha a justificar.'; RETURN; END

    IF NOT EXISTS (SELECT 1 FROM USUARIO WHERE IDUSUARIO = @IdUsuario AND ESTADO = 'Activo')
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El estudiante no existe o está inactivo.'; RETURN; END

    IF EXISTS (SELECT 1 FROM JUSTIFICACION WHERE IDUSUARIO = @IdUsuario AND FECHA = @Fecha)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ya existe una justificación para ese estudiante en esa fecha.'; RETURN; END

    DECLARE @Id NVARCHAR(50);
    DECLARE @Next INT = ISNULL((
        SELECT MAX(TRY_CAST(REPLACE(IDJUSTIFICACION, 'JUS', '') AS INT))
        FROM JUSTIFICACION WHERE IDJUSTIFICACION LIKE 'JUS%'
    ), 0) + 1;
    SET @Id = 'JUS' + RIGHT('000' + CAST(@Next AS VARCHAR(10)), 3);

    DECLARE @Hora CHAR(8) = CONVERT(CHAR(8), CAST(SYSDATETIMEOFFSET() AT TIME ZONE 'SA Pacific Standard Time' AS TIME), 108);

    INSERT INTO JUSTIFICACION (IDJUSTIFICACION, IDUSUARIO, FECHA, HORAREGISTRO, IDREGISTRADOR, OBSERVACION)
    VALUES (@Id, @IdUsuario, @Fecha, @Hora, NULLIF(LTRIM(RTRIM(@IdRegistrador)), ''), NULLIF(LTRIM(RTRIM(@Observacion)), ''));

    IF EXISTS (SELECT 1 FROM ASISTENCIA WHERE IDUSUARIO = @IdUsuario AND FECHAREGISTRO = @Fecha)
    BEGIN
        UPDATE ASISTENCIA SET JUSTIFICADO = 1 WHERE IDUSUARIO = @IdUsuario AND FECHAREGISTRO = @Fecha;
    END
    ELSE
    BEGIN
        INSERT INTO ASISTENCIA (IDASISTENCIA, FECHAREGISTRO, HORAINICIO, ESTADO, JUSTIFICADO, IDUSUARIO)
        VALUES ('AS_' + REPLACE(CONVERT(NVARCHAR(36), NEWID()), '-', ''), @Fecha, @Hora, 'Falta', 1, @IdUsuario);
    END

    SET @Resultado = 1; SET @Mensaje = 'Justificación registrada.';
END;
GO

IF OBJECT_ID('dbo.usp_justificacion_eliminar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_justificacion_eliminar;
GO
CREATE PROCEDURE dbo.usp_justificacion_eliminar
    @Id        NVARCHAR(50),
    @Resultado INT OUTPUT,
    @Mensaje   NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM JUSTIFICACION WHERE IDJUSTIFICACION = @Id)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'La justificación no existe.'; RETURN; END

    DECLARE @IdUsuario NVARCHAR(50);
    DECLARE @Fecha CHAR(8);
    SELECT @IdUsuario = IDUSUARIO, @Fecha = FECHA FROM JUSTIFICACION WHERE IDJUSTIFICACION = @Id;

    DELETE FROM JUSTIFICACION WHERE IDJUSTIFICACION = @Id;

    IF EXISTS (SELECT 1 FROM ASISTENCIA WHERE IDUSUARIO = @IdUsuario AND FECHAREGISTRO = @Fecha AND ESTADO = 'Falta')
        DELETE FROM ASISTENCIA WHERE IDUSUARIO = @IdUsuario AND FECHAREGISTRO = @Fecha AND ESTADO = 'Falta';
    ELSE IF EXISTS (SELECT 1 FROM ASISTENCIA WHERE IDUSUARIO = @IdUsuario AND FECHAREGISTRO = @Fecha)
        UPDATE ASISTENCIA SET JUSTIFICADO = 0 WHERE IDUSUARIO = @IdUsuario AND FECHAREGISTRO = @Fecha;

    SET @Resultado = 1; SET @Mensaje = 'Justificación eliminada.';
END;
GO

-- Submódulo menú (visible si el usuario tiene acceso a MOD003 Asistencias)
IF NOT EXISTS (SELECT 1 FROM SUBMODULO WHERE IDSUBMODULO = 'SUB025')
BEGIN
    INSERT INTO SUBMODULO (IDSUBMODULO, NOMBRE, DESCRIPCION, ICONO, ORDEN, ACTIVO, IDMODULO)
    VALUES ('SUB025', 'Justificación', 'Justificar inasistencias o tardanzas', 'faFilePen', 3, 1, 'MOD003');
END
ELSE
BEGIN
    UPDATE SUBMODULO SET
        NOMBRE = 'Justificación',
        DESCRIPCION = 'Justificar inasistencias o tardanzas',
        ICONO = 'faFilePen',
        ORDEN = 3,
        ACTIVO = 1,
        IDMODULO = 'MOD003'
    WHERE IDSUBMODULO = 'SUB025';
END
GO

PRINT 'Justificación: tabla, SPs y menú SUB025 listos.';
GO
