/* ============================================================================
   Códigos autogenerados en mantenedores (PLN, AUL, CAT, MAT, usuario=DNI)
   Ejecutar después de 12.plan_hora_entrada_tardanza.sql
   Fecha: 26/07/2026
   ============================================================================ */

IF OBJECT_ID('dbo.usp_plan_insertar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_plan_insertar;
GO
CREATE PROCEDURE dbo.usp_plan_insertar
    @Id             NVARCHAR(50)   = NULL,
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

    IF @Id IS NULL OR LTRIM(RTRIM(@Id)) = ''
    BEGIN
        DECLARE @NextPln INT = ISNULL((
            SELECT MAX(TRY_CAST(REPLACE(IDPLAN, 'PLN', '') AS INT))
            FROM [PLAN] WHERE IDPLAN LIKE 'PLN%'
        ), 0) + 1;
        SET @Id = 'PLN' + RIGHT('000' + CAST(@NextPln AS VARCHAR(10)), 3);
    END
    ELSE
        SET @Id = UPPER(LTRIM(RTRIM(@Id)));

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

IF OBJECT_ID('dbo.usp_aula_insertar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_aula_insertar;
GO
CREATE PROCEDURE dbo.usp_aula_insertar
    @Id                 NVARCHAR(50)  = NULL,
    @Nombre             NVARCHAR(100),
    @Descripcion        NVARCHAR(MAX) = NULL,
    @Capacidad          INT           = NULL,
    @EnlaceVirtual      NVARCHAR(255) = NULL,
    @EnlaceCuestionario NVARCHAR(255) = NULL,
    @Estado             NVARCHAR(50)  = 'Activo',
    @Resultado          INT OUTPUT,
    @Mensaje            NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF @Nombre IS NULL OR LTRIM(RTRIM(@Nombre)) = ''
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ingresa el nombre del aula.'; RETURN; END

    IF @Id IS NULL OR LTRIM(RTRIM(@Id)) = ''
    BEGIN
        DECLARE @NextAul INT = ISNULL((
            SELECT MAX(TRY_CAST(REPLACE(IDAULA, 'AUL', '') AS INT))
            FROM AULA WHERE IDAULA LIKE 'AUL%'
        ), 0) + 1;
        SET @Id = 'AUL' + RIGHT('000' + CAST(@NextAul AS VARCHAR(10)), 3);
    END
    ELSE
        SET @Id = UPPER(LTRIM(RTRIM(@Id)));

    IF EXISTS (SELECT 1 FROM AULA WHERE IDAULA = @Id)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El código de aula ya existe.'; RETURN; END

    IF EXISTS (SELECT 1 FROM AULA WHERE NOMBRE = @Nombre)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ya existe un aula con ese nombre.'; RETURN; END

    INSERT INTO AULA (IDAULA, NOMBRE, DESCRIPCION, CAPACIDAD, ACTIVO, ENLACEVIRTUAL, ENLACECUESTIONARIO)
    VALUES (
        @Id,
        @Nombre,
        @Descripcion,
        @Capacidad,
        CASE WHEN @Estado = 'Activo' THEN 1 ELSE 0 END,
        @EnlaceVirtual,
        @EnlaceCuestionario
    );

    SET @Resultado = 1; SET @Mensaje = 'Aula registrada.';
END;
GO

IF OBJECT_ID('dbo.usp_categoria_insertar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_categoria_insertar;
GO
CREATE PROCEDURE dbo.usp_categoria_insertar
    @Nombre      NVARCHAR(100),
    @Porcentaje  DECIMAL(5,2) = NULL,
    @Orden       INT          = 0,
    @Estado      NVARCHAR(50) = 'Activo',
    @IdGenerado  NVARCHAR(50) OUTPUT,
    @Resultado   INT OUTPUT,
    @Mensaje     NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @IdGenerado = NULL;

    IF @Nombre IS NULL OR LTRIM(RTRIM(@Nombre)) = ''
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ingresa el nombre de la categoría.'; RETURN; END

    IF @Porcentaje IS NOT NULL AND (@Porcentaje < 0 OR @Porcentaje > 100)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El porcentaje debe estar entre 0 y 100.'; RETURN; END

    IF EXISTS (SELECT 1 FROM CATEGORIA WHERE NOMBRE = @Nombre)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ya existe una categoría con ese nombre.'; RETURN; END

    DECLARE @NextCat INT;
    SELECT @NextCat = ISNULL(MAX(TRY_CAST(REPLACE(IDCATEGORIA, 'CAT', '') AS INT)), 0) + 1
    FROM CATEGORIA WHERE IDCATEGORIA LIKE 'CAT%';
    SET @IdGenerado = 'CAT' + RIGHT('000' + CAST(@NextCat AS VARCHAR(3)), 3);

    INSERT INTO CATEGORIA (IDCATEGORIA, NOMBRE, PORCENTAJE, ORDEN, ACTIVO)
    VALUES (
        @IdGenerado,
        @Nombre,
        @Porcentaje,
        ISNULL(@Orden, 0),
        CASE WHEN @Estado = 'Activo' THEN 1 ELSE 0 END
    );

    SET @Resultado = 1; SET @Mensaje = 'Categoría registrada.';
END;
GO

IF OBJECT_ID('dbo.usp_materia_insertar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_materia_insertar;
GO
CREATE PROCEDURE dbo.usp_materia_insertar
    @Codigo      NVARCHAR(50)  = NULL,
    @Nombre      NVARCHAR(150),
    @IdCategoria NVARCHAR(50)  = NULL,
    @Estado      NVARCHAR(50)  = 'Activo',
    @IdGenerado  NVARCHAR(50) OUTPUT,
    @Resultado   INT OUTPUT,
    @Mensaje     NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @IdGenerado = NULL;

    IF @Nombre IS NULL OR LTRIM(RTRIM(@Nombre)) = ''
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ingresa el nombre de la materia.'; RETURN; END

    IF EXISTS (SELECT 1 FROM MATERIA WHERE NOMBRE = @Nombre)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ya existe una materia con ese nombre.'; RETURN; END

    IF @IdCategoria IS NOT NULL AND LTRIM(RTRIM(@IdCategoria)) <> ''
       AND NOT EXISTS (SELECT 1 FROM CATEGORIA WHERE IDCATEGORIA = @IdCategoria)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'La categoría no existe.'; RETURN; END

    IF @Codigo IS NOT NULL AND LTRIM(RTRIM(@Codigo)) <> ''
       AND EXISTS (SELECT 1 FROM MATERIA WHERE CODIGO = @Codigo)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ya existe una materia con ese código corto.'; RETURN; END

    DECLARE @NextMat INT;
    SELECT @NextMat = ISNULL(MAX(TRY_CAST(REPLACE(IDMATERIA, 'MAT', '') AS INT)), 0) + 1
    FROM MATERIA WHERE IDMATERIA LIKE 'MAT%';
    SET @IdGenerado = 'MAT' + RIGHT('000' + CAST(@NextMat AS VARCHAR(3)), 3);

    INSERT INTO MATERIA (IDMATERIA, CODIGO, NOMBRE, IDCATEGORIA, ACTIVO)
    VALUES (
        @IdGenerado,
        NULLIF(LTRIM(RTRIM(@Codigo)), ''),
        @Nombre,
        NULLIF(LTRIM(RTRIM(@IdCategoria)), ''),
        CASE WHEN @Estado = 'Activo' THEN 1 ELSE 0 END
    );

    SET @Resultado = 1; SET @Mensaje = 'Materia registrada.';
END;
GO

IF OBJECT_ID('dbo.usp_usuario_insertar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_usuario_insertar;
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

    IF @Dni IS NULL OR LTRIM(RTRIM(@Dni)) = ''
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ingresa el DNI.'; RETURN; END

    IF @Id IS NULL OR LTRIM(RTRIM(@Id)) = ''
        SET @Id = LTRIM(RTRIM(@Dni));

    IF @Contra IS NULL OR LTRIM(RTRIM(@Contra)) = ''
        SET @Contra = @Id;

    IF EXISTS (SELECT 1 FROM USUARIO WHERE IDUSUARIO = @Id)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El usuario ya existe.'; RETURN; END
    IF EXISTS (SELECT 1 FROM USUARIO WHERE DNI = @Dni)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El DNI ya está registrado.'; RETURN; END
    IF EXISTS (SELECT 1 FROM USUARIO WHERE EMAIL = @Email)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El email ya está registrado.'; RETURN; END
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

    SET @Resultado = 1; SET @Mensaje = 'Usuario creado.';
END;
GO
