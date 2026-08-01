/* ============================================================================
   usp_usuario_insertar: mensajes claros si el usuario/DNI existe (p. ej. Retirado)
   Ejecutar después de 3.usp_usuario_eliminar_fisica.sql
   Fecha: 31/07/2026
   ============================================================================ */

SET QUOTED_IDENTIFIER ON;
GO
SET ANSI_NULLS ON;
GO

IF OBJECT_ID('dbo.usp_usuario_insertar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_usuario_insertar;
GO

SET QUOTED_IDENTIFIER ON;
GO
SET ANSI_NULLS ON;
GO

CREATE PROCEDURE dbo.usp_usuario_insertar
    @Id                 NVARCHAR(50)  = NULL,
    @Contra             NVARCHAR(255) = NULL,
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
    @NombreApoderado    NVARCHAR(200) = NULL,
    @Parentesco         NVARCHAR(50)  = NULL,
    @SituacionAcademica NVARCHAR(100) = NULL,
    @ComoEntero         NVARCHAR(100) = NULL,
    @Foto               NVARCHAR(MAX) = NULL,
    @Resultado          INT OUTPUT,
    @Mensaje            NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @EstEx NVARCHAR(50);

    IF @Dni IS NULL OR LTRIM(RTRIM(@Dni)) = ''
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ingresa el DNI.'; RETURN; END

    IF @Id IS NULL OR LTRIM(RTRIM(@Id)) = ''
        SET @Id = LTRIM(RTRIM(@Dni));

    IF @Contra IS NULL OR LTRIM(RTRIM(@Contra)) = ''
        SET @Contra = @Id;

    IF EXISTS (SELECT 1 FROM USUARIO WHERE IDUSUARIO = @Id)
    BEGIN
        SELECT @EstEx = ESTADO FROM USUARIO WHERE IDUSUARIO = @Id;
        SET @Resultado = 0;
        SET @Mensaje = CASE
            WHEN @EstEx = 'Retirado'
                THEN 'Ese usuario ya existe como Retirado. En el listado usa el filtro Retirado o Todos para verlo, reactívalo o elimínalo.'
            ELSE 'El usuario ya existe.'
        END;
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM USUARIO WHERE DNI = @Dni)
    BEGIN
        SELECT @EstEx = ESTADO FROM USUARIO WHERE DNI = @Dni;
        SET @Resultado = 0;
        SET @Mensaje = CASE
            WHEN @EstEx = 'Retirado'
                THEN 'Ese DNI ya está registrado (Retirado). En el listado usa el filtro Retirado o Todos para verlo, reactívalo o elimínalo.'
            ELSE 'El DNI ya está registrado.'
        END;
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM USUARIO WHERE EMAIL = @Email)
    BEGIN
        SELECT @EstEx = ESTADO FROM USUARIO WHERE EMAIL = @Email;
        SET @Resultado = 0;
        SET @Mensaje = CASE
            WHEN @EstEx = 'Retirado'
                THEN 'Ese email ya está registrado (Retirado). En el listado usa el filtro Retirado o Todos.'
            ELSE 'El email ya está registrado.'
        END;
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM TIPOUSUARIO WHERE IDTIPOUSUARIO = @IdTipoUsuario)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Tipo de usuario no válido.'; RETURN; END

    INSERT INTO USUARIO (
        IDUSUARIO, CONTRA, NOMBRE, APELLIDO, DNI, EMAIL, IDTIPOUSUARIO, ESTADO,
        FECHANACIMIENTO, DIRECCION, DISTRITO, COLEGIO, GRADO,
        TELPERSONAL, TELAPODERADO, NOMBREAPODERADO, PARENTESCO,
        SITUACIONACADEMICA, COMOENTERO, FECHAACTIVO, FOTO
    ) VALUES (
        @Id, @Contra, @Nombre, @Apellido, @Dni, @Email, @IdTipoUsuario, @Estado,
        @FechaNacimiento, @Direccion, @Distrito, @Colegio, @Grado,
        @TelPersonal, @TelApoderado, @NombreApoderado, @Parentesco,
        @SituacionAcademica, @ComoEntero, dbo.fn_fecha_ddmmyyyy(), @Foto
    );

    SET @Resultado = 1;
    SET @Mensaje = 'Usuario creado.';
END;
GO

PRINT 'usp_usuario_insertar: mensajes de duplicado mejorados.';
GO
