/* ============================================================================
   ASISTENCIA — marcar por DNI/QR, listar, anti-duplicados
   Ejecutar después de esquema_completo.sql
   Fecha: 22/06/2026
   ============================================================================ */

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'UQ_ASISTENCIA_USUARIO_FECHA' AND object_id = OBJECT_ID('ASISTENCIA')
)
BEGIN
    CREATE UNIQUE INDEX UQ_ASISTENCIA_USUARIO_FECHA
    ON ASISTENCIA(IDUSUARIO, FECHAREGISTRO)
    WHERE FECHAREGISTRO IS NOT NULL;
END
GO

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
    DECLARE @Nombre NVARCHAR(100);
    DECLARE @Apellido NVARCHAR(100);
    DECLARE @FechaHoy CHAR(8) = dbo.fn_fecha_ddmmyyyy();
    DECLARE @HoraAhora CHAR(8);
    DECLARE @Estado NVARCHAR(50);
    DECLARE @HoraLimite TIME = '08:00:00';

    SET @HoraAhora = CONVERT(CHAR(8), CAST(SYSDATETIMEOFFSET() AT TIME ZONE 'SA Pacific Standard Time' AS TIME), 108);

    SELECT @IdUsuario = IDUSUARIO, @Nombre = NOMBRE, @Apellido = APELLIDO
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

    IF CAST(@HoraAhora AS TIME) <= @HoraLimite
        SET @Estado = 'Presente';
    ELSE
        SET @Estado = 'Tarde';

    SET @IdAsistencia = 'AS_' + REPLACE(CONVERT(NVARCHAR(36), NEWID()), '-', '');

    INSERT INTO ASISTENCIA (
        IDASISTENCIA, FECHAREGISTRO, HORAINICIO, ESTADO, JUSTIFICADO, IDUSUARIO
    ) VALUES (
        @IdAsistencia, @FechaHoy, @HoraAhora, @Estado, 0, @IdUsuario
    );

    SET @Resultado = 1;
    SET @Mensaje = 'Asistencia registrada.';
END;
GO

IF OBJECT_ID('dbo.usp_asistencia_listar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_asistencia_listar;
GO
CREATE PROCEDURE dbo.usp_asistencia_listar
    @Fecha          CHAR(8)       = NULL,
    @Buscar         NVARCHAR(200) = NULL,
    @OrdenarPor     NVARCHAR(50)  = 'HORAINICIO',
    @Direccion      NVARCHAR(4)   = 'DESC',
    @Pagina         INT           = 1,
    @TamanioPagina  INT           = 50,
    @TotalRegistros INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF @Fecha IS NULL OR @Fecha = ''
        SET @Fecha = dbo.fn_fecha_ddmmyyyy();

    IF @Pagina < 1 SET @Pagina = 1;
    IF @TamanioPagina < 1 SET @TamanioPagina = 50;

    SELECT @TotalRegistros = COUNT(*)
    FROM ASISTENCIA a
    INNER JOIN USUARIO u ON u.IDUSUARIO = a.IDUSUARIO
    WHERE a.FECHAREGISTRO = @Fecha
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
    WHERE a.FECHAREGISTRO = @Fecha
      AND (@Buscar IS NULL OR @Buscar = '' OR
           u.DNI LIKE '%' + @Buscar + '%' OR
           u.NOMBRE LIKE '%' + @Buscar + '%' OR
           u.APELLIDO LIKE '%' + @Buscar + '%' OR
           u.IDUSUARIO LIKE '%' + @Buscar + '%')
    ORDER BY
        CASE WHEN @OrdenarPor = 'HORAINICIO' AND @Direccion = 'ASC'  THEN a.HORAINICIO END ASC,
        CASE WHEN @OrdenarPor = 'HORAINICIO' AND @Direccion = 'DESC' THEN a.HORAINICIO END DESC,
        CASE WHEN @OrdenarPor = 'NOMBRE'    AND @Direccion = 'ASC'  THEN u.NOMBRE END ASC,
        CASE WHEN @OrdenarPor = 'NOMBRE'    AND @Direccion = 'DESC' THEN u.NOMBRE END DESC,
        a.HORAINICIO DESC
    OFFSET (@Pagina - 1) * @TamanioPagina ROWS
    FETCH NEXT @TamanioPagina ROWS ONLY;
END;
GO

PRINT 'usp_asistencia.sql ejecutado correctamente';
GO
