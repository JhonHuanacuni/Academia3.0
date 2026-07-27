/* ============================================================================
   ASESOR (registro de mensualidades) + nombre registrador en mensualidad
   Ejecutar después de 6.plan_turno.sql (o 7.plan_nombres_sin_turno.sql)
   Fecha: 26/07/2026

   Nota: TUTOR es distinto (asignación académica). ASESOR cataloga personal
   que registra mensualidades; MENSUALIDAD.REGISTRADOPOR = usuario logueado.
   ============================================================================ */

/* PLAN.IDTURNO — requerido por usp_mensualidad_* (script 6) */
IF COL_LENGTH('PLAN', 'IDTURNO') IS NULL
BEGIN
    ALTER TABLE [PLAN] ADD IDTURNO NVARCHAR(50) NULL;
    PRINT 'Columna PLAN.IDTURNO agregada.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_PLAN_TURNO')
BEGIN
    ALTER TABLE [PLAN] ADD CONSTRAINT FK_PLAN_TURNO
        FOREIGN KEY (IDTURNO) REFERENCES TURNO(IDTURNO);
    PRINT 'FK PLAN.IDTURNO creada.';
END
GO

UPDATE [PLAN] SET IDTURNO = 'TUR002' WHERE IDPLAN IN ('PLN002', 'PLN006') AND IDTURNO IS NULL;
UPDATE [PLAN] SET IDTURNO = 'TUR001' WHERE IDTURNO IS NULL;
GO

IF OBJECT_ID('dbo.ASESOR', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.ASESOR (
        IDASESOR    NVARCHAR(50)   NOT NULL PRIMARY KEY,
        NOMBRE      NVARCHAR(150)  NOT NULL,
        IDUSUARIO   NVARCHAR(50)   NULL,
        ACTIVO      BIT            NOT NULL CONSTRAINT DF_ASESOR_REG_ACTIVO DEFAULT (1)
    );
    PRINT 'Tabla ASESOR creada.';
END
ELSE
    PRINT 'Tabla ASESOR ya existe.';
GO

IF COL_LENGTH('ASESOR', 'IDUSUARIO') IS NULL
BEGIN
    ALTER TABLE ASESOR ADD IDUSUARIO NVARCHAR(50) NULL;
    PRINT 'Columna ASESOR.IDUSUARIO agregada.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_ASESOR_USUARIO')
BEGIN
    ALTER TABLE ASESOR ADD CONSTRAINT FK_ASESOR_USUARIO
        FOREIGN KEY (IDUSUARIO) REFERENCES USUARIO(IDUSUARIO);
    PRINT 'FK ASESOR.IDUSUARIO → USUARIO creada.';
END
GO

IF NOT EXISTS (SELECT 1 FROM ASESOR)
BEGIN
    INSERT INTO ASESOR (IDASESOR, NOMBRE, ACTIVO) VALUES
    ('ASE001', 'Asesor 1', 1),
    ('ASE002', 'Asesor 2', 1);
    PRINT 'Asesores iniciales insertados.';
END
GO

/* ---- usp_asesor_* ---- */
IF OBJECT_ID('dbo.usp_asesor_listar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_asesor_listar;
GO
CREATE PROCEDURE dbo.usp_asesor_listar
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
    FROM ASESOR a
    LEFT JOIN USUARIO u ON u.IDUSUARIO = a.IDUSUARIO
    WHERE (@Buscar IS NULL OR @Buscar = '' OR
           a.IDASESOR LIKE '%' + @Buscar + '%' OR
           a.NOMBRE LIKE '%' + @Buscar + '%' OR
           ISNULL(a.IDUSUARIO, '') LIKE '%' + @Buscar + '%')
      AND (@Estado IS NULL OR @Estado = '' OR
           (@Estado = 'Activo' AND a.ACTIVO = 1) OR
           (@Estado = 'Inactivo' AND a.ACTIVO = 0));

    SELECT
        a.IDASESOR,
        a.NOMBRE,
        a.IDUSUARIO,
        ISNULL(u.NOMBRE, '') + CASE WHEN u.APELLIDO IS NOT NULL THEN ' ' + u.APELLIDO ELSE '' END AS USUARIO_NOMBRE,
        CASE WHEN a.ACTIVO = 1 THEN 'Activo' ELSE 'Inactivo' END AS ESTADO
    FROM ASESOR a
    LEFT JOIN USUARIO u ON u.IDUSUARIO = a.IDUSUARIO
    WHERE (@Buscar IS NULL OR @Buscar = '' OR
           a.IDASESOR LIKE '%' + @Buscar + '%' OR
           a.NOMBRE LIKE '%' + @Buscar + '%' OR
           ISNULL(a.IDUSUARIO, '') LIKE '%' + @Buscar + '%')
      AND (@Estado IS NULL OR @Estado = '' OR
           (@Estado = 'Activo' AND a.ACTIVO = 1) OR
           (@Estado = 'Inactivo' AND a.ACTIVO = 0))
    ORDER BY
        CASE WHEN @OrdenarPor = 'IDASESOR' AND @Direccion = 'ASC'  THEN a.IDASESOR END ASC,
        CASE WHEN @OrdenarPor = 'IDASESOR' AND @Direccion = 'DESC' THEN a.IDASESOR END DESC,
        CASE WHEN @OrdenarPor = 'NOMBRE' AND @Direccion = 'ASC'  THEN a.NOMBRE END ASC,
        CASE WHEN @OrdenarPor = 'NOMBRE' AND @Direccion = 'DESC' THEN a.NOMBRE END DESC,
        a.NOMBRE
    OFFSET (@Pagina - 1) * @TamanioPagina ROWS
    FETCH NEXT @TamanioPagina ROWS ONLY;
END;
GO

IF OBJECT_ID('dbo.usp_asesor_obtener', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_asesor_obtener;
GO
CREATE PROCEDURE dbo.usp_asesor_obtener @Id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        a.IDASESOR,
        a.NOMBRE,
        a.IDUSUARIO,
        CASE WHEN a.ACTIVO = 1 THEN 'Activo' ELSE 'Inactivo' END AS ESTADO
    FROM ASESOR a
    WHERE a.IDASESOR = @Id;
END;
GO

IF OBJECT_ID('dbo.usp_asesor_insertar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_asesor_insertar;
GO
CREATE PROCEDURE dbo.usp_asesor_insertar
    @Id         NVARCHAR(50),
    @Nombre     NVARCHAR(150),
    @IdUsuario  NVARCHAR(50)  = NULL,
    @Estado     NVARCHAR(50)  = 'Activo',
    @Resultado  INT OUTPUT,
    @Mensaje    NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    IF @Id IS NULL OR LTRIM(RTRIM(@Id)) = ''
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ingresa el código del asesor.'; RETURN; END
    IF @Nombre IS NULL OR LTRIM(RTRIM(@Nombre)) = ''
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ingresa el nombre del asesor.'; RETURN; END
    IF @IdUsuario IS NOT NULL AND @IdUsuario <> ''
       AND NOT EXISTS (SELECT 1 FROM USUARIO WHERE IDUSUARIO = @IdUsuario)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El usuario vinculado no existe.'; RETURN; END
    IF EXISTS (SELECT 1 FROM ASESOR WHERE IDASESOR = @Id)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El código de asesor ya existe.'; RETURN; END
    IF EXISTS (SELECT 1 FROM ASESOR WHERE NOMBRE = @Nombre)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ya existe un asesor con ese nombre.'; RETURN; END
    IF @IdUsuario IS NOT NULL AND @IdUsuario <> ''
       AND EXISTS (SELECT 1 FROM ASESOR WHERE IDUSUARIO = @IdUsuario AND ACTIVO = 1)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ese usuario ya está vinculado a otro asesor activo.'; RETURN; END

    INSERT INTO ASESOR (IDASESOR, NOMBRE, IDUSUARIO, ACTIVO)
    VALUES (@Id, @Nombre, NULLIF(@IdUsuario, ''), CASE WHEN @Estado = 'Activo' THEN 1 ELSE 0 END);

    SET @Resultado = 1; SET @Mensaje = 'Asesor registrado.';
END;
GO

IF OBJECT_ID('dbo.usp_asesor_actualizar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_asesor_actualizar;
GO
CREATE PROCEDURE dbo.usp_asesor_actualizar
    @Id         NVARCHAR(50),
    @Nombre     NVARCHAR(150),
    @IdUsuario  NVARCHAR(50)  = NULL,
    @Estado     NVARCHAR(50)  = 'Activo',
    @Resultado  INT OUTPUT,
    @Mensaje    NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM ASESOR WHERE IDASESOR = @Id)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El asesor no existe.'; RETURN; END
    IF @Nombre IS NULL OR LTRIM(RTRIM(@Nombre)) = ''
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ingresa el nombre del asesor.'; RETURN; END
    IF @IdUsuario IS NOT NULL AND @IdUsuario <> ''
       AND NOT EXISTS (SELECT 1 FROM USUARIO WHERE IDUSUARIO = @IdUsuario)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El usuario vinculado no existe.'; RETURN; END
    IF EXISTS (SELECT 1 FROM ASESOR WHERE NOMBRE = @Nombre AND IDASESOR <> @Id)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ya existe un asesor con ese nombre.'; RETURN; END
    IF @IdUsuario IS NOT NULL AND @IdUsuario <> ''
       AND EXISTS (SELECT 1 FROM ASESOR WHERE IDUSUARIO = @IdUsuario AND IDASESOR <> @Id AND ACTIVO = 1)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ese usuario ya está vinculado a otro asesor activo.'; RETURN; END

    UPDATE ASESOR SET
        NOMBRE    = @Nombre,
        IDUSUARIO = NULLIF(@IdUsuario, ''),
        ACTIVO    = CASE WHEN @Estado = 'Activo' THEN 1 ELSE 0 END
    WHERE IDASESOR = @Id;

    SET @Resultado = 1; SET @Mensaje = 'Asesor actualizado.';
END;
GO

IF OBJECT_ID('dbo.usp_asesor_eliminar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_asesor_eliminar;
GO
CREATE PROCEDURE dbo.usp_asesor_eliminar
    @Id        NVARCHAR(50),
    @Resultado INT OUTPUT,
    @Mensaje   NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM ASESOR WHERE IDASESOR = @Id)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El asesor no existe.'; RETURN; END

    DELETE FROM ASESOR WHERE IDASESOR = @Id;
    SET @Resultado = 1; SET @Mensaje = 'Asesor eliminado.';
END;
GO

/* ---- Mensualidad: nombre del asesor (usuario registrador) ---- */
IF OBJECT_ID('dbo.usp_mensualidad_listar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_mensualidad_listar;
GO
CREATE PROCEDURE dbo.usp_mensualidad_listar
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
    FROM MENSUALIDAD m
    INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
    INNER JOIN [PLAN] pl ON pl.IDPLAN = m.IDPLAN
    LEFT JOIN AULA au ON au.IDAULA = m.IDAULA
    LEFT JOIN TUTOR tut ON tut.IDTUTOR = m.IDTUTOR
    WHERE m.ESTADO = @Estado
      AND (@Buscar IS NULL OR @Buscar = '' OR
           m.IDMENSUALIDAD LIKE '%' + @Buscar + '%' OR
           u.DNI LIKE '%' + @Buscar + '%' OR
           u.NOMBRE LIKE '%' + @Buscar + '%' OR
           u.APELLIDO LIKE '%' + @Buscar + '%' OR
           pl.NOMBRE LIKE '%' + @Buscar + '%' OR
           ISNULL(au.NOMBRE, '') LIKE '%' + @Buscar + '%' OR
           ISNULL(tut.NOMBRE, '') LIKE '%' + @Buscar + '%');

    SELECT
        m.IDMENSUALIDAD,
        m.IDUSUARIO,
        UPPER(LTRIM(RTRIM(ISNULL(u.APELLIDO, '') + ' ' + ISNULL(u.NOMBRE, '')))) AS ESTUDIANTE_NOMBRE,
        u.DNI AS ESTUDIANTE_DNI,
        m.IDPLAN,
        pl.NOMBRE AS PLAN_NOMBRE,
        ISNULL(tu.DESCRIPCION, '') AS TURNO_DESCRIPCION,
        m.ESTADOMIEMBRO,
        CASE m.ESTADOMIEMBRO WHEN 2 THEN 'Activo' WHEN 3 THEN 'Vencido' ELSE 'Activo' END AS ESTADOMIEMBRO_DESCRIPCION,
        m.FECHAINICIO,
        m.FECHAFIN,
        m.MONTOTOTAL,
        ISNULL(pag.PAGADO, 0) AS PAGADO,
        CASE WHEN ISNULL(m.MONTOTOTAL, 0) - ISNULL(pag.PAGADO, 0) < 0 THEN 0
             ELSE ISNULL(m.MONTOTOTAL, 0) - ISNULL(pag.PAGADO, 0) END AS DEUDA,
        ISNULL(au.NOMBRE, '') AS AULA_NOMBRE,
        m.IDTUTOR,
        ISNULL(tut.NOMBRE, ISNULL(m.TUTORLEGACY, '')) AS TUTOR_NOMBRE,
        m.REGISTRADOPOR,
        UPPER(LTRIM(RTRIM(
            COALESCE(
                (SELECT TOP 1 a.NOMBRE FROM ASESOR a WHERE a.IDUSUARIO = m.REGISTRADOPOR AND a.ACTIVO = 1),
                ISNULL(reg.APELLIDO, '') + ' ' + ISNULL(reg.NOMBRE, '')
            )
        ))) AS ASESOR_NOMBRE,
        m.ESTADO,
        m.FECHAREGISTRO
    FROM MENSUALIDAD m
    INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
    INNER JOIN [PLAN] pl ON pl.IDPLAN = m.IDPLAN
    LEFT JOIN TURNO tu ON tu.IDTURNO = ISNULL(pl.IDTURNO, m.IDTURNO)
    LEFT JOIN AULA au ON au.IDAULA = m.IDAULA
    LEFT JOIN TUTOR tut ON tut.IDTUTOR = m.IDTUTOR
    LEFT JOIN USUARIO reg ON reg.IDUSUARIO = m.REGISTRADOPOR
    OUTER APPLY (
        SELECT SUM(p.MONTO) AS PAGADO FROM PAGOMENSUALIDAD p WHERE p.IDMENSUALIDAD = m.IDMENSUALIDAD
    ) pag
    WHERE m.ESTADO = @Estado
      AND (@Buscar IS NULL OR @Buscar = '' OR
           m.IDMENSUALIDAD LIKE '%' + @Buscar + '%' OR
           u.DNI LIKE '%' + @Buscar + '%' OR
           u.NOMBRE LIKE '%' + @Buscar + '%' OR
           u.APELLIDO LIKE '%' + @Buscar + '%' OR
           pl.NOMBRE LIKE '%' + @Buscar + '%' OR
           ISNULL(au.NOMBRE, '') LIKE '%' + @Buscar + '%' OR
           ISNULL(tut.NOMBRE, '') LIKE '%' + @Buscar + '%')
    ORDER BY
        CASE WHEN @OrdenarPor = 'FECHAREGISTRO' AND @Direccion = 'DESC' THEN m.FECHAREGISTRO END DESC,
        m.IDMENSUALIDAD DESC
    OFFSET (@Pagina - 1) * @TamanioPagina ROWS
    FETCH NEXT @TamanioPagina ROWS ONLY;
END;
GO

IF OBJECT_ID('dbo.usp_mensualidad_obtener', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_mensualidad_obtener;
GO
CREATE PROCEDURE dbo.usp_mensualidad_obtener @Id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        m.IDMENSUALIDAD,
        m.IDUSUARIO,
        UPPER(LTRIM(RTRIM(ISNULL(u.APELLIDO, '') + ' ' + ISNULL(u.NOMBRE, '')))) AS ESTUDIANTE_NOMBRE,
        u.DNI AS ESTUDIANTE_DNI,
        m.IDPLAN,
        pl.NOMBRE AS PLAN_NOMBRE,
        ISNULL(tu.DESCRIPCION, '') AS TURNO_DESCRIPCION,
        m.ESTADOMIEMBRO,
        m.FECHAINICIO,
        m.FECHAFIN,
        m.MONTOTOTAL,
        m.IDAULA,
        ISNULL(au.NOMBRE, '') AS AULA_NOMBRE,
        m.IDTUTOR,
        ISNULL(tut.NOMBRE, ISNULL(m.TUTORLEGACY, '')) AS TUTOR_NOMBRE,
        m.OBSERVACIONES,
        m.FECHACANCELACION,
        m.ESTADO,
        m.FECHAREGISTRO,
        m.REGISTRADOPOR,
        UPPER(LTRIM(RTRIM(
            COALESCE(
                (SELECT TOP 1 a.NOMBRE FROM ASESOR a WHERE a.IDUSUARIO = m.REGISTRADOPOR AND a.ACTIVO = 1),
                ISNULL(reg.APELLIDO, '') + ' ' + ISNULL(reg.NOMBRE, '')
            )
        ))) AS ASESOR_NOMBRE,
        ISNULL(pag.PAGOINICIAL, 0) AS PAGOINICIAL,
        pag.IDMETODOPAGO
    FROM MENSUALIDAD m
    INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
    INNER JOIN [PLAN] pl ON pl.IDPLAN = m.IDPLAN
    LEFT JOIN TURNO tu ON tu.IDTURNO = ISNULL(pl.IDTURNO, m.IDTURNO)
    LEFT JOIN AULA au ON au.IDAULA = m.IDAULA
    LEFT JOIN TUTOR tut ON tut.IDTUTOR = m.IDTUTOR
    LEFT JOIN USUARIO reg ON reg.IDUSUARIO = m.REGISTRADOPOR
    OUTER APPLY (
        SELECT TOP 1 p.MONTO AS PAGOINICIAL, p.IDMETODOPAGO
        FROM PAGOMENSUALIDAD p
        WHERE p.IDMENSUALIDAD = m.IDMENSUALIDAD
        ORDER BY p.FECHAPAGO, p.IDPAGOMENSUALIDAD
    ) pag
    WHERE m.IDMENSUALIDAD = @Id;
END;
GO

/* Menú mantenedor asesores */
IF NOT EXISTS (SELECT 1 FROM SUBMODULO WHERE IDSUBMODULO = 'SUB024')
BEGIN
    INSERT INTO SUBMODULO (IDSUBMODULO, NOMBRE, DESCRIPCION, ICONO, ORDEN, ACTIVO, IDMODULO)
    VALUES ('SUB024', 'Asesores', 'Personal que registra mensualidades', 'faIdBadge', 4, 1, 'MOD011');
    PRINT 'SUB024 (Asesores) creado.';
END
ELSE
    UPDATE SUBMODULO SET NOMBRE = 'Asesores', DESCRIPCION = 'Personal que registra mensualidades', ACTIVO = 1
    WHERE IDSUBMODULO = 'SUB024';
GO

PRINT 'ASESOR, usp_asesor_* y ASESOR_NOMBRE en mensualidad listos.';
GO
