/* ============================================================================
   SPs usuario: soporte columna FOTO (Base64)
   Ejecutar después de 4.usuario_columna_foto.sql
   Fecha: 06/07/2026
   ============================================================================ */

IF OBJECT_ID('dbo.usp_usuario_obtener', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_usuario_obtener;
GO
CREATE PROCEDURE dbo.usp_usuario_obtener
    @Id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        u.IDUSUARIO,
        u.NOMBRE,
        u.APELLIDO,
        u.DNI,
        u.EMAIL,
        u.ESTADO,
        u.IDTIPOUSUARIO,
        t.DESCRIPCION AS TIPOUSUARIO_DESCRIPCION,
        u.FECHANACIMIENTO,
        u.DIRECCION,
        u.DISTRITO,
        u.COLEGIO,
        u.GRADO,
        u.FECHAACTIVO,
        u.TELPERSONAL,
        u.TELAPODERADO,
        u.SITUACIONACADEMICA,
        u.FOTO
    FROM USUARIO u
    INNER JOIN TIPOUSUARIO t ON t.IDTIPOUSUARIO = u.IDTIPOUSUARIO
    WHERE u.IDUSUARIO = @Id;
END;
GO

IF OBJECT_ID('dbo.usp_usuario_insertar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_usuario_insertar;
GO
CREATE PROCEDURE dbo.usp_usuario_insertar
    @Id                 NVARCHAR(50),
    @Contra             NVARCHAR(255),
    @Nombre             NVARCHAR(100),
    @Apellido           NVARCHAR(100),
    @Dni                NVARCHAR(20),
    @Email              NVARCHAR(150),
    @IdTipoUsuario      NVARCHAR(50),
    @Estado             NVARCHAR(50)  = 'Activo',
    @FechaNacimiento    CHAR(8)       = NULL,
    @Direccion          NVARCHAR(255) = NULL,
    @Distrito           NVARCHAR(100) = NULL,
    @Colegio            NVARCHAR(150) = NULL,
    @Grado              NVARCHAR(50)  = NULL,
    @TelPersonal        NVARCHAR(20)  = NULL,
    @TelApoderado       NVARCHAR(20)  = NULL,
    @SituacionAcademica NVARCHAR(100) = NULL,
    @Foto               NVARCHAR(MAX) = NULL,
    @Resultado          INT OUTPUT,
    @Mensaje            NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM USUARIO WHERE IDUSUARIO = @Id)
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'El usuario ya existe.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM USUARIO WHERE DNI = @Dni)
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'El DNI ya está registrado.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM USUARIO WHERE EMAIL = @Email)
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'El email ya está registrado.';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM TIPOUSUARIO WHERE IDTIPOUSUARIO = @IdTipoUsuario)
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'Tipo de usuario no válido.';
        RETURN;
    END

    INSERT INTO USUARIO (
        IDUSUARIO, CONTRA, NOMBRE, APELLIDO, DNI, EMAIL, IDTIPOUSUARIO, ESTADO,
        FECHANACIMIENTO, DIRECCION, DISTRITO, COLEGIO, GRADO,
        TELPERSONAL, TELAPODERADO, SITUACIONACADEMICA, FECHAACTIVO, FOTO
    ) VALUES (
        @Id, @Contra, @Nombre, @Apellido, @Dni, @Email, @IdTipoUsuario, @Estado,
        @FechaNacimiento, @Direccion, @Distrito, @Colegio, @Grado,
        @TelPersonal, @TelApoderado, @SituacionAcademica, dbo.fn_fecha_ddmmyyyy(), @Foto
    );

    SET @Resultado = 1; SET @Mensaje = 'Usuario creado.';
END;
GO

IF OBJECT_ID('dbo.usp_usuario_actualizar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_usuario_actualizar;
GO
CREATE PROCEDURE dbo.usp_usuario_actualizar
    @Id                 NVARCHAR(50),
    @Contra             NVARCHAR(255) = NULL,
    @Nombre             NVARCHAR(100),
    @Apellido           NVARCHAR(100),
    @Dni                NVARCHAR(20),
    @Email              NVARCHAR(150),
    @IdTipoUsuario      NVARCHAR(50),
    @Estado             NVARCHAR(50),
    @FechaNacimiento    CHAR(8)       = NULL,
    @Direccion          NVARCHAR(255) = NULL,
    @Distrito           NVARCHAR(100) = NULL,
    @Colegio            NVARCHAR(150) = NULL,
    @Grado              NVARCHAR(50)  = NULL,
    @TelPersonal        NVARCHAR(20)  = NULL,
    @TelApoderado       NVARCHAR(20)  = NULL,
    @SituacionAcademica NVARCHAR(100) = NULL,
    @Foto               NVARCHAR(MAX) = NULL,
    @ActualizarFoto     BIT           = 0,
    @Resultado          INT OUTPUT,
    @Mensaje            NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM USUARIO WHERE IDUSUARIO = @Id)
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'El usuario no existe.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM USUARIO WHERE DNI = @Dni AND IDUSUARIO <> @Id)
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'El DNI ya está registrado.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM USUARIO WHERE EMAIL = @Email AND IDUSUARIO <> @Id)
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'El email ya está registrado.';
        RETURN;
    END

    UPDATE USUARIO SET
        NOMBRE             = @Nombre,
        APELLIDO           = @Apellido,
        DNI                = @Dni,
        EMAIL              = @Email,
        IDTIPOUSUARIO      = @IdTipoUsuario,
        ESTADO             = @Estado,
        FECHANACIMIENTO    = @FechaNacimiento,
        DIRECCION          = @Direccion,
        DISTRITO           = @Distrito,
        COLEGIO            = @Colegio,
        GRADO              = @Grado,
        TELPERSONAL        = @TelPersonal,
        TELAPODERADO       = @TelApoderado,
        SITUACIONACADEMICA = @SituacionAcademica,
        CONTRA             = CASE WHEN @Contra IS NOT NULL AND @Contra <> '' THEN @Contra ELSE CONTRA END,
        FOTO               = CASE WHEN @ActualizarFoto = 1 THEN @Foto ELSE FOTO END
    WHERE IDUSUARIO = @Id;

    SET @Resultado = 1; SET @Mensaje = 'Usuario actualizado.';
END;
GO

PRINT 'usp_usuario_obtener / insertar / actualizar actualizados con FOTO.';
GO
