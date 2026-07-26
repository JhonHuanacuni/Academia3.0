/* ============================================================================
   Mueve COMOENTERO de MEMBRESIA a USUARIO
   Ejecutar después de 9.usp_pago_membresias_prefills.sql
   Fecha: 12/07/2026
   ============================================================================ */

-- 1) Columna en usuario
IF COL_LENGTH('USUARIO', 'COMOENTERO') IS NULL
BEGIN
    ALTER TABLE USUARIO ADD COMOENTERO NVARCHAR(100) NULL;
    PRINT 'Columna USUARIO.COMOENTERO agregada.';
END
ELSE
    PRINT 'Columna USUARIO.COMOENTERO ya existe.';
GO

-- 2) Migrar desde la membresía más reciente de cada usuario
UPDATE u
SET u.COMOENTERO = m.COMOENTERO
FROM USUARIO u
INNER JOIN (
    SELECT m.IDUSUARIO, m.COMOENTERO,
           ROW_NUMBER() OVER (PARTITION BY m.IDUSUARIO ORDER BY m.FECHAREGISTRO DESC, m.IDMEMBRESIA DESC) AS rn
    FROM MEMBRESIA m
    WHERE m.COMOENTERO IS NOT NULL AND LTRIM(RTRIM(m.COMOENTERO)) <> ''
) m ON m.IDUSUARIO = u.IDUSUARIO AND m.rn = 1
WHERE u.COMOENTERO IS NULL OR LTRIM(RTRIM(u.COMOENTERO)) = '';
GO

-- 3) SPs usuario
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
        u.NOMBREAPODERADO,
        u.PARENTESCO,
        u.SITUACIONACADEMICA,
        u.COMOENTERO,
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
    @NombreApoderado    NVARCHAR(200) = NULL,
    @Parentesco         NVARCHAR(50)  = NULL,
    @SituacionAcademica NVARCHAR(100) = NULL,
    @ComoEntero         NVARCHAR(100) = NULL,
    @Foto               NVARCHAR(MAX) = NULL,
    @ActualizarFoto     BIT           = 0,
    @Resultado          INT OUTPUT,
    @Mensaje            NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM USUARIO WHERE IDUSUARIO = @Id)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El usuario no existe.'; RETURN; END
    IF EXISTS (SELECT 1 FROM USUARIO WHERE DNI = @Dni AND IDUSUARIO <> @Id)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El DNI ya está registrado.'; RETURN; END
    IF EXISTS (SELECT 1 FROM USUARIO WHERE EMAIL = @Email AND IDUSUARIO <> @Id)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El email ya está registrado.'; RETURN; END

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
        NOMBREAPODERADO    = @NombreApoderado,
        PARENTESCO         = @Parentesco,
        SITUACIONACADEMICA = @SituacionAcademica,
        COMOENTERO         = @ComoEntero,
        CONTRA             = CASE WHEN @Contra IS NOT NULL AND @Contra <> '' THEN @Contra ELSE CONTRA END,
        FOTO               = CASE WHEN @ActualizarFoto = 1 THEN @Foto ELSE FOTO END
    WHERE IDUSUARIO = @Id;

    SET @Resultado = 1; SET @Mensaje = 'Usuario actualizado.';
END;
GO

-- 4) SPs membresía sin COMOENTERO
IF OBJECT_ID('dbo.usp_membresia_listar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_membresia_listar;
GO
CREATE PROCEDURE dbo.usp_membresia_listar
    @Buscar         NVARCHAR(200) = NULL,
    @Estado         NVARCHAR(50)  = NULL,
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
    IF @Estado IS NULL OR @Estado = '' SET @Estado = 'Activo';

    SELECT @TotalRegistros = COUNT(*)
    FROM MEMBRESIA m
    INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
    INNER JOIN [PLAN] pl ON pl.IDPLAN = m.IDPLAN
    LEFT JOIN AULA au ON au.IDAULA = m.IDAULA
    LEFT JOIN TURNO tu ON tu.IDTURNO = m.IDTURNO
    LEFT JOIN ASESOR ase ON ase.IDASESOR = m.IDASESOR
    WHERE m.ESTADO = @Estado
      AND (@Buscar IS NULL OR @Buscar = '' OR
           m.IDMEMBRESIA LIKE '%' + @Buscar + '%' OR
           u.DNI LIKE '%' + @Buscar + '%' OR
           u.NOMBRE LIKE '%' + @Buscar + '%' OR
           u.APELLIDO LIKE '%' + @Buscar + '%' OR
           pl.NOMBRE LIKE '%' + @Buscar + '%' OR
           ISNULL(au.NOMBRE, '') LIKE '%' + @Buscar + '%' OR
           ISNULL(ase.NOMBRE, '') LIKE '%' + @Buscar + '%');

    SELECT
        m.IDMEMBRESIA,
        m.IDUSUARIO,
        UPPER(LTRIM(RTRIM(ISNULL(u.APELLIDO, '') + ' ' + ISNULL(u.NOMBRE, '')))) AS ESTUDIANTE_NOMBRE,
        u.DNI AS ESTUDIANTE_DNI,
        m.IDPLAN,
        pl.NOMBRE AS PLAN_NOMBRE,
        ISNULL(tu.DESCRIPCION, '') AS TURNO_DESCRIPCION,
        m.ESTADOMIEMBRO,
        CASE m.ESTADOMIEMBRO
            WHEN 2 THEN 'Activo'
            WHEN 3 THEN 'Vencido'
            ELSE 'Activo'
        END AS ESTADOMIEMBRO_DESCRIPCION,
        m.FECHAINICIO,
        m.FECHAFIN,
        m.MONTOTOTAL,
        ISNULL(au.NOMBRE, '') AS AULA_NOMBRE,
        m.IDASESOR,
        ISNULL(ase.NOMBRE, ISNULL(m.ASESOR, '')) AS ASESOR_NOMBRE,
        m.ESTADO,
        m.FECHAREGISTRO
    FROM MEMBRESIA m
    INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
    INNER JOIN [PLAN] pl ON pl.IDPLAN = m.IDPLAN
    LEFT JOIN AULA au ON au.IDAULA = m.IDAULA
    LEFT JOIN TURNO tu ON tu.IDTURNO = m.IDTURNO
    LEFT JOIN ASESOR ase ON ase.IDASESOR = m.IDASESOR
    WHERE m.ESTADO = @Estado
      AND (@Buscar IS NULL OR @Buscar = '' OR
           m.IDMEMBRESIA LIKE '%' + @Buscar + '%' OR
           u.DNI LIKE '%' + @Buscar + '%' OR
           u.NOMBRE LIKE '%' + @Buscar + '%' OR
           u.APELLIDO LIKE '%' + @Buscar + '%' OR
           pl.NOMBRE LIKE '%' + @Buscar + '%' OR
           ISNULL(au.NOMBRE, '') LIKE '%' + @Buscar + '%' OR
           ISNULL(ase.NOMBRE, '') LIKE '%' + @Buscar + '%')
    ORDER BY
        CASE WHEN @OrdenarPor = 'IDMEMBRESIA' AND @Direccion = 'ASC'  THEN m.IDMEMBRESIA END ASC,
        CASE WHEN @OrdenarPor = 'IDMEMBRESIA' AND @Direccion = 'DESC' THEN m.IDMEMBRESIA END DESC,
        CASE WHEN @OrdenarPor = 'ESTUDIANTE_NOMBRE' AND @Direccion = 'ASC'  THEN u.APELLIDO END ASC,
        CASE WHEN @OrdenarPor = 'ESTUDIANTE_NOMBRE' AND @Direccion = 'DESC' THEN u.APELLIDO END DESC,
        CASE WHEN @OrdenarPor = 'FECHAINICIO' AND @Direccion = 'ASC'  THEN m.FECHAINICIO END ASC,
        CASE WHEN @OrdenarPor = 'FECHAINICIO' AND @Direccion = 'DESC' THEN m.FECHAINICIO END DESC,
        CASE WHEN @OrdenarPor = 'FECHAFIN' AND @Direccion = 'ASC'  THEN m.FECHAFIN END ASC,
        CASE WHEN @OrdenarPor = 'FECHAFIN' AND @Direccion = 'DESC' THEN m.FECHAFIN END DESC,
        CASE WHEN @OrdenarPor = 'MONTOTOTAL' AND @Direccion = 'ASC'  THEN m.MONTOTOTAL END ASC,
        CASE WHEN @OrdenarPor = 'MONTOTOTAL' AND @Direccion = 'DESC' THEN m.MONTOTOTAL END DESC,
        CASE WHEN @OrdenarPor = 'FECHAREGISTRO' AND @Direccion = 'ASC'  THEN m.FECHAREGISTRO END ASC,
        CASE WHEN @OrdenarPor = 'FECHAREGISTRO' AND @Direccion = 'DESC' THEN m.FECHAREGISTRO END DESC,
        m.IDMEMBRESIA DESC
    OFFSET (@Pagina - 1) * @TamanioPagina ROWS
    FETCH NEXT @TamanioPagina ROWS ONLY;
END;
GO

IF OBJECT_ID('dbo.usp_membresia_obtener', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_membresia_obtener;
GO
CREATE PROCEDURE dbo.usp_membresia_obtener
    @Id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        m.IDMEMBRESIA,
        m.IDUSUARIO,
        UPPER(LTRIM(RTRIM(ISNULL(u.APELLIDO, '') + ' ' + ISNULL(u.NOMBRE, '')))) AS ESTUDIANTE_NOMBRE,
        u.DNI AS ESTUDIANTE_DNI,
        m.IDPLAN,
        pl.NOMBRE AS PLAN_NOMBRE,
        m.IDTURNO,
        ISNULL(tu.DESCRIPCION, '') AS TURNO_DESCRIPCION,
        m.ESTADOMIEMBRO,
        m.FECHAINICIO,
        m.FECHAFIN,
        m.MONTOTOTAL,
        m.IDAULA,
        ISNULL(au.NOMBRE, '') AS AULA_NOMBRE,
        m.IDASESOR,
        ISNULL(ase.NOMBRE, ISNULL(m.ASESOR, '')) AS ASESOR_NOMBRE,
        m.OBSERVACIONES,
        m.FECHACANCELACION,
        m.ESTADO,
        m.FECHAREGISTRO,
        m.REGISTRADOPOR,
        ISNULL(pag.PAGOINICIAL, 0) AS PAGOINICIAL,
        pag.IDMETODOPAGO
    FROM MEMBRESIA m
    INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
    INNER JOIN [PLAN] pl ON pl.IDPLAN = m.IDPLAN
    LEFT JOIN AULA au ON au.IDAULA = m.IDAULA
    LEFT JOIN TURNO tu ON tu.IDTURNO = m.IDTURNO
    LEFT JOIN ASESOR ase ON ase.IDASESOR = m.IDASESOR
    OUTER APPLY (
        SELECT TOP 1 p.MONTO AS PAGOINICIAL, p.IDMETODOPAGO
        FROM PAGOMEMBRESIA p
        WHERE p.IDMEMBRESIA = m.IDMEMBRESIA
        ORDER BY p.FECHAPAGO, p.IDPAGOMEMBRESIA
    ) pag
    WHERE m.IDMEMBRESIA = @Id;
END;
GO

IF OBJECT_ID('dbo.usp_membresia_insertar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_membresia_insertar;
GO
CREATE PROCEDURE dbo.usp_membresia_insertar
    @Id                 NVARCHAR(50) = NULL,
    @IdUsuario          NVARCHAR(50),
    @IdPlan             NVARCHAR(50),
    @IdTurno            NVARCHAR(50)  = NULL,
    @EstadoMiembro      INT           = 2,
    @FechaInicio        CHAR(8),
    @FechaFin           CHAR(8),
    @MontoTotal         DECIMAL(10,2),
    @PagoInicial        DECIMAL(10,2) = NULL,
    @IdMetodoPago       NVARCHAR(50)  = NULL,
    @IdAula             NVARCHAR(50)  = NULL,
    @IdAsesor           NVARCHAR(50)  = NULL,
    @Observaciones      NVARCHAR(MAX) = NULL,
    @FechaCancelacion   CHAR(8)       = NULL,
    @RegistradoPor      NVARCHAR(50)  = NULL,
    @Resultado          INT OUTPUT,
    @Mensaje            NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF @IdUsuario IS NULL OR @IdUsuario = ''
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Debe seleccionar un estudiante.'; RETURN; END
    IF @FechaInicio IS NULL OR @FechaFin IS NULL
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ingrese fecha de inicio y fin.'; RETURN; END
    IF @MontoTotal IS NULL
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ingrese el monto total.'; RETURN; END
    IF @EstadoMiembro NOT IN (2, 3)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Estado de membresía no válido.'; RETURN; END

    IF NOT EXISTS (SELECT 1 FROM USUARIO WHERE IDUSUARIO = @IdUsuario AND IDTIPOUSUARIO = '1')
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El estudiante no existe o no es válido.'; RETURN; END
    IF NOT EXISTS (SELECT 1 FROM [PLAN] WHERE IDPLAN = @IdPlan)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El plan seleccionado no es válido.'; RETURN; END

    IF @IdAsesor IS NOT NULL AND @IdAsesor <> ''
       AND NOT EXISTS (SELECT 1 FROM ASESOR WHERE IDASESOR = @IdAsesor AND ACTIVO = 1)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El asesor seleccionado no es válido.'; RETURN; END

    IF @PagoInicial IS NOT NULL AND @PagoInicial > 0
       AND (@IdMetodoPago IS NULL OR @IdMetodoPago = '')
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Indique el método de pago del pago inicial.'; RETURN; END

    IF @Id IS NULL OR @Id = ''
    BEGIN
        DECLARE @Next INT = ISNULL((
            SELECT MAX(TRY_CAST(SUBSTRING(IDMEMBRESIA, 4, 10) AS INT))
            FROM MEMBRESIA WHERE IDMEMBRESIA LIKE 'MEM%'
        ), 0) + 1;
        SET @Id = 'MEM' + RIGHT('000000' + CAST(@Next AS VARCHAR(10)), 6);
    END

    IF EXISTS (SELECT 1 FROM MEMBRESIA WHERE IDMEMBRESIA = @Id)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'La membresía ya existe.'; RETURN; END

    INSERT INTO MEMBRESIA (
        IDMEMBRESIA, FECHAINICIO, FECHAFIN, ESTADOMIEMBRO, MONTOTOTAL, OBSERVACIONES,
        FECHAREGISTRO, HORAREGISTRO, IDPLAN, IDAULA, IDTURNO, IDUSUARIO, REGISTRADOPOR,
        IDASESOR, FECHACANCELACION, ESTADO
    ) VALUES (
        @Id, @FechaInicio, @FechaFin, @EstadoMiembro, @MontoTotal, @Observaciones,
        dbo.fn_fecha_ddmmyyyy(), CONVERT(CHAR(8), GETDATE(), 108),
        @IdPlan, @IdAula, @IdTurno, @IdUsuario, @RegistradoPor,
        @IdAsesor, @FechaCancelacion, 'Activo'
    );

    IF @PagoInicial IS NOT NULL AND @PagoInicial > 0
    BEGIN
        DECLARE @IdPago NVARCHAR(50) = 'PAG' + RIGHT('000000' + CAST((
            ISNULL((SELECT MAX(TRY_CAST(SUBSTRING(IDPAGOMEMBRESIA, 4, 10) AS INT))
                    FROM PAGOMEMBRESIA WHERE IDPAGOMEMBRESIA LIKE 'PAG%'), 0) + 1
        ) AS VARCHAR(10)), 6);

        INSERT INTO PAGOMEMBRESIA (
            IDPAGOMEMBRESIA, MONTO, FECHAPAGO, HORAPAGO, OBSERVACIONES,
            IDMEMBRESIA, IDMETODOPAGO, IDUSUARIO
        ) VALUES (
            @IdPago, @PagoInicial, dbo.fn_fecha_ddmmyyyy(), CONVERT(CHAR(8), GETDATE(), 108),
            'Pago inicial', @Id, @IdMetodoPago, @RegistradoPor
        );
    END

    SET @Resultado = 1; SET @Mensaje = 'Membresía registrada.';
END;
GO

IF OBJECT_ID('dbo.usp_membresia_actualizar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_membresia_actualizar;
GO
CREATE PROCEDURE dbo.usp_membresia_actualizar
    @Id                 NVARCHAR(50),
    @IdUsuario          NVARCHAR(50),
    @IdPlan             NVARCHAR(50),
    @IdTurno            NVARCHAR(50)  = NULL,
    @EstadoMiembro      INT,
    @FechaInicio        CHAR(8),
    @FechaFin           CHAR(8),
    @MontoTotal         DECIMAL(10,2),
    @IdAula             NVARCHAR(50)  = NULL,
    @IdAsesor           NVARCHAR(50)  = NULL,
    @Observaciones      NVARCHAR(MAX) = NULL,
    @FechaCancelacion   CHAR(8)       = NULL,
    @Resultado          INT OUTPUT,
    @Mensaje            NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM MEMBRESIA WHERE IDMEMBRESIA = @Id)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'La membresía no existe.'; RETURN; END
    IF @EstadoMiembro NOT IN (2, 3)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Estado de membresía no válido.'; RETURN; END

    IF @IdAsesor IS NOT NULL AND @IdAsesor <> ''
       AND NOT EXISTS (SELECT 1 FROM ASESOR WHERE IDASESOR = @IdAsesor AND ACTIVO = 1)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El asesor seleccionado no es válido.'; RETURN; END

    UPDATE MEMBRESIA SET
        IDUSUARIO        = @IdUsuario,
        IDPLAN           = @IdPlan,
        IDTURNO          = @IdTurno,
        ESTADOMIEMBRO    = @EstadoMiembro,
        FECHAINICIO      = @FechaInicio,
        FECHAFIN         = @FechaFin,
        MONTOTOTAL       = @MontoTotal,
        IDAULA           = @IdAula,
        IDASESOR         = @IdAsesor,
        OBSERVACIONES    = @Observaciones,
        FECHACANCELACION = @FechaCancelacion
    WHERE IDMEMBRESIA = @Id;

    SET @Resultado = 1; SET @Mensaje = 'Membresía actualizada.';
END;
GO

IF OBJECT_ID('dbo.usp_pago_membresias_estudiante', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_pago_membresias_estudiante;
GO
CREATE PROCEDURE dbo.usp_pago_membresias_estudiante
    @IdUsuario NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP 3
        m.IDMEMBRESIA,
        m.IDPLAN,
        pl.NOMBRE AS PLAN_NOMBRE,
        m.IDTURNO,
        m.IDAULA,
        m.IDASESOR,
        m.OBSERVACIONES,
        m.FECHAINICIO,
        m.FECHAFIN,
        m.MONTOTOTAL,
        ISNULL(pag.PAGADO, 0) AS PAGADO,
        CASE
            WHEN ISNULL(m.MONTOTOTAL, 0) - ISNULL(pag.PAGADO, 0) < 0 THEN 0
            ELSE ISNULL(m.MONTOTOTAL, 0) - ISNULL(pag.PAGADO, 0)
        END AS DEUDA,
        m.ESTADOMIEMBRO,
        CASE m.ESTADOMIEMBRO
            WHEN 2 THEN 'Activo'
            WHEN 3 THEN 'Vencido'
            ELSE 'Activo'
        END AS ESTADOMIEMBRO_DESCRIPCION,
        m.ESTADO,
        m.FECHAREGISTRO
    FROM MEMBRESIA m
    INNER JOIN [PLAN] pl ON pl.IDPLAN = m.IDPLAN
    OUTER APPLY (
        SELECT SUM(p.MONTO) AS PAGADO
        FROM PAGOMEMBRESIA p
        WHERE p.IDMEMBRESIA = m.IDMEMBRESIA
    ) pag
    WHERE m.IDUSUARIO = @IdUsuario
      AND m.ESTADO = 'Activo'
    ORDER BY m.FECHAREGISTRO DESC, m.IDMEMBRESIA DESC;
END;
GO

-- 5) Quitar columna de membresía
IF COL_LENGTH('MEMBRESIA', 'COMOENTERO') IS NOT NULL
BEGIN
    ALTER TABLE MEMBRESIA DROP COLUMN COMOENTERO;
    PRINT 'Columna MEMBRESIA.COMOENTERO eliminada.';
END
GO

PRINT 'COMOENTERO movido de MEMBRESIA a USUARIO.';
GO
