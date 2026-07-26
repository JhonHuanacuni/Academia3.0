/* ============================================================================
   Renombrar MEMBRESIA -> MENSUALIDAD, ASESOR -> TUTOR
   Ejecutar despues de 26_07_2026/3.aula_catalogo_academia_vita.sql
   Fecha: 26/07/2026

   Cambios:
   - Tablas: MENSUALIDAD, TUTOR, PAGOMENSUALIDAD, NOTIFICACIONMENSUALIDAD
   - Columnas: IDMENSUALIDAD, IDTUTOR, IDPAGOMENSUALIDAD, etc.
   - SPs: usp_mensualidad_*, usp_tutor_*, usp_pago_mensualidades_*
   - Columna legacy MEMBRESIA.ASESOR -> MENSUALIDAD.TUTORLEGACY
   ============================================================================ */

SET NOCOUNT ON;
GO

/* --- 1) Eliminar FKs que referencian MEMBRESIA / ASESOR --- */
DECLARE @sql NVARCHAR(MAX) = N'';
SELECT @sql = @sql + N'ALTER TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) + N'.' + QUOTENAME(OBJECT_NAME(parent_object_id))
    + N' DROP CONSTRAINT ' + QUOTENAME(name) + N';' + CHAR(13)
FROM sys.foreign_keys
WHERE referenced_object_id IN (OBJECT_ID('MEMBRESIA'), OBJECT_ID('ASESOR'))
   OR parent_object_id IN (OBJECT_ID('MEMBRESIA'), OBJECT_ID('PAGOMEMBRESIA'), OBJECT_ID('NOTIFICACIONMEMBRESIA'), OBJECT_ID('ASESOR'));
EXEC sp_executesql @sql;
GO

/* --- 2) Renombrar tablas --- */
IF OBJECT_ID('dbo.NOTIFICACIONMEMBRESIA', 'U') IS NOT NULL
    EXEC sp_rename 'dbo.NOTIFICACIONMEMBRESIA', 'NOTIFICACIONMENSUALIDAD';
GO
IF OBJECT_ID('dbo.PAGOMEMBRESIA', 'U') IS NOT NULL
    EXEC sp_rename 'dbo.PAGOMEMBRESIA', 'PAGOMENSUALIDAD';
GO
IF COL_LENGTH('MEMBRESIA', 'ASESOR') IS NOT NULL
    EXEC sp_rename 'MEMBRESIA.ASESOR', 'TUTORLEGACY', 'COLUMN';
GO
IF OBJECT_ID('dbo.MEMBRESIA', 'U') IS NOT NULL
    EXEC sp_rename 'dbo.MEMBRESIA', 'MENSUALIDAD';
GO
IF OBJECT_ID('dbo.ASESOR', 'U') IS NOT NULL
    EXEC sp_rename 'dbo.ASESOR', 'TUTOR';
GO

/* --- 3) Renombrar columnas PK/FK --- */
IF COL_LENGTH('NOTIFICACIONMENSUALIDAD', 'IDNOTIFICACIONMEMBRESIA') IS NOT NULL
    EXEC sp_rename 'NOTIFICACIONMENSUALIDAD.IDNOTIFICACIONMEMBRESIA', 'IDNOTIFICACIONMENSUALIDAD', 'COLUMN';
GO
IF COL_LENGTH('NOTIFICACIONMENSUALIDAD', 'IDMEMBRESIA') IS NOT NULL
    EXEC sp_rename 'NOTIFICACIONMENSUALIDAD.IDMEMBRESIA', 'IDMENSUALIDAD', 'COLUMN';
GO
IF COL_LENGTH('PAGOMENSUALIDAD', 'IDPAGOMEMBRESIA') IS NOT NULL
    EXEC sp_rename 'PAGOMENSUALIDAD.IDPAGOMEMBRESIA', 'IDPAGOMENSUALIDAD', 'COLUMN';
GO
IF COL_LENGTH('PAGOMENSUALIDAD', 'IDMEMBRESIA') IS NOT NULL
    EXEC sp_rename 'PAGOMENSUALIDAD.IDMEMBRESIA', 'IDMENSUALIDAD', 'COLUMN';
GO
IF COL_LENGTH('MENSUALIDAD', 'IDMEMBRESIA') IS NOT NULL
    EXEC sp_rename 'MENSUALIDAD.IDMEMBRESIA', 'IDMENSUALIDAD', 'COLUMN';
GO
IF COL_LENGTH('MENSUALIDAD', 'IDASESOR') IS NOT NULL
    EXEC sp_rename 'MENSUALIDAD.IDASESOR', 'IDTUTOR', 'COLUMN';
GO
IF COL_LENGTH('MENSUALIDAD', 'TIPOMEMBRESIA') IS NOT NULL
    EXEC sp_rename 'MENSUALIDAD.TIPOMEMBRESIA', 'TIPOMENSUALIDAD', 'COLUMN';
GO
IF COL_LENGTH('TUTOR', 'IDASESOR') IS NOT NULL
    EXEC sp_rename 'TUTOR.IDASESOR', 'IDTUTOR', 'COLUMN';
GO

/* --- 4) Recrear FKs --- */
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_MENSUALIDAD_PLAN')
    ALTER TABLE MENSUALIDAD ADD CONSTRAINT FK_MENSUALIDAD_PLAN
        FOREIGN KEY (IDPLAN) REFERENCES [PLAN](IDPLAN);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_MENSUALIDAD_AULA')
    ALTER TABLE MENSUALIDAD ADD CONSTRAINT FK_MENSUALIDAD_AULA
        FOREIGN KEY (IDAULA) REFERENCES AULA(IDAULA);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_MENSUALIDAD_TURNO')
    ALTER TABLE MENSUALIDAD ADD CONSTRAINT FK_MENSUALIDAD_TURNO
        FOREIGN KEY (IDTURNO) REFERENCES TURNO(IDTURNO);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_MENSUALIDAD_PROMOCION')
    ALTER TABLE MENSUALIDAD ADD CONSTRAINT FK_MENSUALIDAD_PROMOCION
        FOREIGN KEY (IDPROMOCION) REFERENCES PROMOCIONES(IDPROMOCION);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_MENSUALIDAD_USUARIO')
    ALTER TABLE MENSUALIDAD ADD CONSTRAINT FK_MENSUALIDAD_USUARIO
        FOREIGN KEY (IDUSUARIO) REFERENCES USUARIO(IDUSUARIO);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_MENSUALIDAD_REGISTRADOPOR')
    ALTER TABLE MENSUALIDAD ADD CONSTRAINT FK_MENSUALIDAD_REGISTRADOPOR
        FOREIGN KEY (REGISTRADOPOR) REFERENCES USUARIO(IDUSUARIO);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_MENSUALIDAD_TUTOR')
    ALTER TABLE MENSUALIDAD ADD CONSTRAINT FK_MENSUALIDAD_TUTOR
        FOREIGN KEY (IDTUTOR) REFERENCES TUTOR(IDTUTOR);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_PAGOMENSUALIDAD_MENSUALIDAD')
    ALTER TABLE PAGOMENSUALIDAD ADD CONSTRAINT FK_PAGOMENSUALIDAD_MENSUALIDAD
        FOREIGN KEY (IDMENSUALIDAD) REFERENCES MENSUALIDAD(IDMENSUALIDAD);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_PAGOMENSUALIDAD_METODOPAGO')
    ALTER TABLE PAGOMENSUALIDAD ADD CONSTRAINT FK_PAGOMENSUALIDAD_METODOPAGO
        FOREIGN KEY (IDMETODOPAGO) REFERENCES METODO_PAGO(IDMETODOPAGO);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_PAGOMENSUALIDAD_USUARIO')
    ALTER TABLE PAGOMENSUALIDAD ADD CONSTRAINT FK_PAGOMENSUALIDAD_USUARIO
        FOREIGN KEY (IDUSUARIO) REFERENCES USUARIO(IDUSUARIO);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_NOTIFMENSUALIDAD_MENSUALIDAD')
    ALTER TABLE NOTIFICACIONMENSUALIDAD ADD CONSTRAINT FK_NOTIFMENSUALIDAD_MENSUALIDAD
        FOREIGN KEY (IDMENSUALIDAD) REFERENCES MENSUALIDAD(IDMENSUALIDAD);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_NOTIFMENSUALIDAD_USUARIO')
    ALTER TABLE NOTIFICACIONMENSUALIDAD ADD CONSTRAINT FK_NOTIFMENSUALIDAD_USUARIO
        FOREIGN KEY (IDUSUARIO) REFERENCES USUARIO(IDUSUARIO);
GO

/* --- 5) Eliminar SPs legacy --- */
DECLARE @drop NVARCHAR(MAX) = N'';
SELECT @drop = @drop + N'DROP PROCEDURE dbo.' + QUOTENAME(name, '[') + N';' + CHAR(13)
FROM sys.procedures
WHERE name LIKE 'usp_membresia_%'
   OR name LIKE 'usp_asesor_%'
   OR name = 'usp_pago_membresias_estudiante';
IF LEN(@drop) > 0 EXEC sp_executesql @drop;
GO

/* --- 6) Recrear SPs con nombres nuevos --- */
/* ============================================================================
   CRUD ASESOR — Mantenedor de tutores (módulo Académico)
   Ejecutar después de 6.tutor_tabla.sql (11_07_2026)
   Fecha: 12/07/2026
   ============================================================================ */

IF OBJECT_ID('dbo.usp_tutor_listar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_tutor_listar;
GO

CREATE PROCEDURE dbo.usp_tutor_listar
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
    FROM TUTOR a
    WHERE (@Buscar IS NULL OR @Buscar = '' OR
           a.IDTUTOR LIKE '%' + @Buscar + '%' OR
           a.NOMBRE   LIKE '%' + @Buscar + '%')
      AND (@Estado IS NULL OR @Estado = '' OR
           (@Estado = 'Activo' AND a.ACTIVO = 1) OR
           (@Estado = 'Inactivo' AND a.ACTIVO = 0));

    SELECT
        a.IDTUTOR,
        a.NOMBRE,
        CASE WHEN a.ACTIVO = 1 THEN 'Activo' ELSE 'Inactivo' END AS ESTADO
    FROM TUTOR a
    WHERE (@Buscar IS NULL OR @Buscar = '' OR
           a.IDTUTOR LIKE '%' + @Buscar + '%' OR
           a.NOMBRE   LIKE '%' + @Buscar + '%')
      AND (@Estado IS NULL OR @Estado = '' OR
           (@Estado = 'Activo' AND a.ACTIVO = 1) OR
           (@Estado = 'Inactivo' AND a.ACTIVO = 0))
    ORDER BY
        CASE WHEN @OrdenarPor = 'IDTUTOR' AND @Direccion = 'ASC'  THEN a.IDTUTOR END ASC,
        CASE WHEN @OrdenarPor = 'IDTUTOR' AND @Direccion = 'DESC' THEN a.IDTUTOR END DESC,
        CASE WHEN @OrdenarPor = 'NOMBRE'   AND @Direccion = 'ASC'  THEN a.NOMBRE END ASC,
        CASE WHEN @OrdenarPor = 'NOMBRE'   AND @Direccion = 'DESC' THEN a.NOMBRE END DESC,
        CASE WHEN @OrdenarPor = 'ESTADO'   AND @Direccion = 'ASC'  THEN a.ACTIVO END ASC,
        CASE WHEN @OrdenarPor = 'ESTADO'   AND @Direccion = 'DESC' THEN a.ACTIVO END DESC,
        a.NOMBRE
    OFFSET (@Pagina - 1) * @TamanioPagina ROWS
    FETCH NEXT @TamanioPagina ROWS ONLY;
END;
GO

IF OBJECT_ID('dbo.usp_tutor_obtener', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_tutor_obtener;
GO

CREATE PROCEDURE dbo.usp_tutor_obtener
    @Id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        a.IDTUTOR,
        a.NOMBRE,
        CASE WHEN a.ACTIVO = 1 THEN 'Activo' ELSE 'Inactivo' END AS ESTADO
    FROM TUTOR a
    WHERE a.IDTUTOR = @Id;
END;
GO

IF OBJECT_ID('dbo.usp_tutor_insertar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_tutor_insertar;
GO

CREATE PROCEDURE dbo.usp_tutor_insertar
    @Id        NVARCHAR(50),
    @Nombre    NVARCHAR(150),
    @Estado    NVARCHAR(50) = 'Activo',
    @Resultado INT OUTPUT,
    @Mensaje   NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF @Id IS NULL OR LTRIM(RTRIM(@Id)) = ''
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'Ingresa el código del tutor.';
        RETURN;
    END

    IF @Nombre IS NULL OR LTRIM(RTRIM(@Nombre)) = ''
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'Ingresa el nombre del tutor.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM TUTOR WHERE IDTUTOR = @Id)
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'El código de tutor ya existe.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM TUTOR WHERE NOMBRE = @Nombre)
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'Ya existe un tutor con ese nombre.';
        RETURN;
    END

    INSERT INTO TUTOR (IDTUTOR, NOMBRE, ACTIVO)
    VALUES (
        @Id,
        @Nombre,
        CASE WHEN @Estado = 'Activo' THEN 1 ELSE 0 END
    );

    SET @Resultado = 1; SET @Mensaje = 'Tutor registrado.';
END;
GO

IF OBJECT_ID('dbo.usp_tutor_actualizar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_tutor_actualizar;
GO

CREATE PROCEDURE dbo.usp_tutor_actualizar
    @Id        NVARCHAR(50),
    @Nombre    NVARCHAR(150),
    @Estado    NVARCHAR(50) = 'Activo',
    @Resultado INT OUTPUT,
    @Mensaje   NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM TUTOR WHERE IDTUTOR = @Id)
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'El tutor no existe.';
        RETURN;
    END

    IF @Nombre IS NULL OR LTRIM(RTRIM(@Nombre)) = ''
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'Ingresa el nombre del tutor.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM TUTOR WHERE NOMBRE = @Nombre AND IDTUTOR <> @Id)
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'Ya existe un tutor con ese nombre.';
        RETURN;
    END

    UPDATE TUTOR SET
        NOMBRE = @Nombre,
        ACTIVO = CASE WHEN @Estado = 'Activo' THEN 1 ELSE 0 END
    WHERE IDTUTOR = @Id;

    SET @Resultado = 1; SET @Mensaje = 'Tutor actualizado.';
END;
GO

IF OBJECT_ID('dbo.usp_tutor_eliminar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_tutor_eliminar;
GO

CREATE PROCEDURE dbo.usp_tutor_eliminar
    @Id        NVARCHAR(50),
    @Resultado INT OUTPUT,
    @Mensaje   NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM TUTOR WHERE IDTUTOR = @Id)
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'El tutor no existe.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDTUTOR = @Id)
    BEGIN
        SET @Resultado = 0;
        SET @Mensaje = 'No se puede eliminar: el tutor tiene mensualidads asociadas.';
        RETURN;
    END

    DELETE FROM TUTOR WHERE IDTUTOR = @Id;

    SET @Resultado = 1; SET @Mensaje = 'Tutor eliminado.';
END;
GO

/* ============================================================================
   Mensualidads: columna DEUDA en listado (MONTOTOTAL − suma pagos)
   Ejecutar después de 12_07_2026/10.comoentero_a_usuario.sql
   Fecha: 16/07/2026
   ============================================================================ */

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
    LEFT JOIN TURNO tu ON tu.IDTURNO = m.IDTURNO
    LEFT JOIN TUTOR ase ON ase.IDTUTOR = m.IDTUTOR
    WHERE m.ESTADO = @Estado
      AND (@Buscar IS NULL OR @Buscar = '' OR
           m.IDMENSUALIDAD LIKE '%' + @Buscar + '%' OR
           u.DNI LIKE '%' + @Buscar + '%' OR
           u.NOMBRE LIKE '%' + @Buscar + '%' OR
           u.APELLIDO LIKE '%' + @Buscar + '%' OR
           pl.NOMBRE LIKE '%' + @Buscar + '%' OR
           ISNULL(au.NOMBRE, '') LIKE '%' + @Buscar + '%' OR
           ISNULL(ase.NOMBRE, '') LIKE '%' + @Buscar + '%');

    SELECT
        m.IDMENSUALIDAD,
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
        ISNULL(pag.PAGADO, 0) AS PAGADO,
        CASE
            WHEN ISNULL(m.MONTOTOTAL, 0) - ISNULL(pag.PAGADO, 0) < 0 THEN 0
            ELSE ISNULL(m.MONTOTOTAL, 0) - ISNULL(pag.PAGADO, 0)
        END AS DEUDA,
        ISNULL(au.NOMBRE, '') AS AULA_NOMBRE,
        m.IDTUTOR,
        ISNULL(ase.NOMBRE, ISNULL(m.TUTORLEGACY, '')) AS TUTOR_NOMBRE,
        m.ESTADO,
        m.FECHAREGISTRO
    FROM MENSUALIDAD m
    INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
    INNER JOIN [PLAN] pl ON pl.IDPLAN = m.IDPLAN
    LEFT JOIN AULA au ON au.IDAULA = m.IDAULA
    LEFT JOIN TURNO tu ON tu.IDTURNO = m.IDTURNO
    LEFT JOIN TUTOR ase ON ase.IDTUTOR = m.IDTUTOR
    OUTER APPLY (
        SELECT SUM(p.MONTO) AS PAGADO
        FROM PAGOMENSUALIDAD p
        WHERE p.IDMENSUALIDAD = m.IDMENSUALIDAD
    ) pag
    WHERE m.ESTADO = @Estado
      AND (@Buscar IS NULL OR @Buscar = '' OR
           m.IDMENSUALIDAD LIKE '%' + @Buscar + '%' OR
           u.DNI LIKE '%' + @Buscar + '%' OR
           u.NOMBRE LIKE '%' + @Buscar + '%' OR
           u.APELLIDO LIKE '%' + @Buscar + '%' OR
           pl.NOMBRE LIKE '%' + @Buscar + '%' OR
           ISNULL(au.NOMBRE, '') LIKE '%' + @Buscar + '%' OR
           ISNULL(ase.NOMBRE, '') LIKE '%' + @Buscar + '%')
    ORDER BY
        CASE WHEN @OrdenarPor = 'IDMENSUALIDAD' AND @Direccion = 'ASC'  THEN m.IDMENSUALIDAD END ASC,
        CASE WHEN @OrdenarPor = 'IDMENSUALIDAD' AND @Direccion = 'DESC' THEN m.IDMENSUALIDAD END DESC,
        CASE WHEN @OrdenarPor = 'ESTUDIANTE_NOMBRE' AND @Direccion = 'ASC'  THEN u.APELLIDO END ASC,
        CASE WHEN @OrdenarPor = 'ESTUDIANTE_NOMBRE' AND @Direccion = 'DESC' THEN u.APELLIDO END DESC,
        CASE WHEN @OrdenarPor = 'FECHAINICIO' AND @Direccion = 'ASC'  THEN m.FECHAINICIO END ASC,
        CASE WHEN @OrdenarPor = 'FECHAINICIO' AND @Direccion = 'DESC' THEN m.FECHAINICIO END DESC,
        CASE WHEN @OrdenarPor = 'FECHAFIN' AND @Direccion = 'ASC'  THEN m.FECHAFIN END ASC,
        CASE WHEN @OrdenarPor = 'FECHAFIN' AND @Direccion = 'DESC' THEN m.FECHAFIN END DESC,
        CASE WHEN @OrdenarPor = 'MONTOTOTAL' AND @Direccion = 'ASC'  THEN m.MONTOTOTAL END ASC,
        CASE WHEN @OrdenarPor = 'MONTOTOTAL' AND @Direccion = 'DESC' THEN m.MONTOTOTAL END DESC,
        CASE WHEN @OrdenarPor = 'DEUDA' AND @Direccion = 'ASC' THEN
            ISNULL(m.MONTOTOTAL, 0) - ISNULL(pag.PAGADO, 0) END ASC,
        CASE WHEN @OrdenarPor = 'DEUDA' AND @Direccion = 'DESC' THEN
            ISNULL(m.MONTOTOTAL, 0) - ISNULL(pag.PAGADO, 0) END DESC,
        CASE WHEN @OrdenarPor = 'FECHAREGISTRO' AND @Direccion = 'ASC'  THEN m.FECHAREGISTRO END ASC,
        CASE WHEN @OrdenarPor = 'FECHAREGISTRO' AND @Direccion = 'DESC' THEN m.FECHAREGISTRO END DESC,
        m.IDMENSUALIDAD DESC
    OFFSET (@Pagina - 1) * @TamanioPagina ROWS
    FETCH NEXT @TamanioPagina ROWS ONLY;
END;
GO

IF OBJECT_ID('dbo.usp_mensualidad_obtener', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_mensualidad_obtener;
GO

CREATE PROCEDURE dbo.usp_mensualidad_obtener
    @Id NVARCHAR(50)
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
        m.IDTURNO,
        ISNULL(tu.DESCRIPCION, '') AS TURNO_DESCRIPCION,
        m.ESTADOMIEMBRO,
        m.FECHAINICIO,
        m.FECHAFIN,
        m.MONTOTOTAL,
        m.IDAULA,
        ISNULL(au.NOMBRE, '') AS AULA_NOMBRE,
        m.IDTUTOR,
        ISNULL(ase.NOMBRE, ISNULL(m.TUTORLEGACY, '')) AS TUTOR_NOMBRE,
        m.OBSERVACIONES,
        m.FECHACANCELACION,
        m.ESTADO,
        m.FECHAREGISTRO,
        m.REGISTRADOPOR,
        ISNULL(pag.PAGOINICIAL, 0) AS PAGOINICIAL,
        pag.IDMETODOPAGO
    FROM MENSUALIDAD m
    INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
    INNER JOIN [PLAN] pl ON pl.IDPLAN = m.IDPLAN
    LEFT JOIN AULA au ON au.IDAULA = m.IDAULA
    LEFT JOIN TURNO tu ON tu.IDTURNO = m.IDTURNO
    LEFT JOIN TUTOR ase ON ase.IDTUTOR = m.IDTUTOR
    OUTER APPLY (
        SELECT TOP 1 p.MONTO AS PAGOINICIAL, p.IDMETODOPAGO
        FROM PAGOMENSUALIDAD p
        WHERE p.IDMENSUALIDAD = m.IDMENSUALIDAD
        ORDER BY p.FECHAPAGO, p.IDPAGOMENSUALIDAD
    ) pag
    WHERE m.IDMENSUALIDAD = @Id;
END;
GO

IF OBJECT_ID('dbo.usp_mensualidad_insertar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_mensualidad_insertar;
GO

CREATE PROCEDURE dbo.usp_mensualidad_insertar
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
    @IdTutor           NVARCHAR(50)  = NULL,
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
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Estado de mensualidad no válido.'; RETURN; END

    IF NOT EXISTS (SELECT 1 FROM USUARIO WHERE IDUSUARIO = @IdUsuario AND IDTIPOUSUARIO = '1')
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El estudiante no existe o no es válido.'; RETURN; END
    IF NOT EXISTS (SELECT 1 FROM [PLAN] WHERE IDPLAN = @IdPlan)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El plan seleccionado no es válido.'; RETURN; END

    IF @IdTutor IS NOT NULL AND @IdTutor <> ''
       AND NOT EXISTS (SELECT 1 FROM TUTOR WHERE IDTUTOR = @IdTutor AND ACTIVO = 1)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El tutor seleccionado no es válido.'; RETURN; END

    IF @PagoInicial IS NOT NULL AND @PagoInicial > 0
       AND (@IdMetodoPago IS NULL OR @IdMetodoPago = '')
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Indique el método de pago del pago inicial.'; RETURN; END

    IF @Id IS NULL OR @Id = ''
    BEGIN
        DECLARE @Next INT = ISNULL((
            SELECT MAX(TRY_CAST(SUBSTRING(IDMENSUALIDAD, 4, 10) AS INT))
            FROM MENSUALIDAD WHERE IDMENSUALIDAD LIKE 'MEM%'
        ), 0) + 1;
        SET @Id = 'MEM' + RIGHT('000000' + CAST(@Next AS VARCHAR(10)), 6);
    END

    IF EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = @Id)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'La mensualidad ya existe.'; RETURN; END

    INSERT INTO MENSUALIDAD (
        IDMENSUALIDAD, FECHAINICIO, FECHAFIN, ESTADOMIEMBRO, MONTOTOTAL, OBSERVACIONES,
        FECHAREGISTRO, HORAREGISTRO, IDPLAN, IDAULA, IDTURNO, IDUSUARIO, REGISTRADOPOR,
        IDTUTOR, FECHACANCELACION, ESTADO
    ) VALUES (
        @Id, @FechaInicio, @FechaFin, @EstadoMiembro, @MontoTotal, @Observaciones,
        dbo.fn_fecha_ddmmyyyy(), CONVERT(CHAR(8), GETDATE(), 108),
        @IdPlan, @IdAula, @IdTurno, @IdUsuario, @RegistradoPor,
        @IdTutor, @FechaCancelacion, 'Activo'
    );

    IF @PagoInicial IS NOT NULL AND @PagoInicial > 0
    BEGIN
        DECLARE @IdPago NVARCHAR(50) = 'PAG' + RIGHT('000000' + CAST((
            ISNULL((SELECT MAX(TRY_CAST(SUBSTRING(IDPAGOMENSUALIDAD, 4, 10) AS INT))
                    FROM PAGOMENSUALIDAD WHERE IDPAGOMENSUALIDAD LIKE 'PAG%'), 0) + 1
        ) AS VARCHAR(10)), 6);

        INSERT INTO PAGOMENSUALIDAD (
            IDPAGOMENSUALIDAD, MONTO, FECHAPAGO, HORAPAGO, OBSERVACIONES,
            IDMENSUALIDAD, IDMETODOPAGO, IDUSUARIO
        ) VALUES (
            @IdPago, @PagoInicial, dbo.fn_fecha_ddmmyyyy(), CONVERT(CHAR(8), GETDATE(), 108),
            'Pago inicial', @Id, @IdMetodoPago, @RegistradoPor
        );
    END

    SET @Resultado = 1; SET @Mensaje = 'Mensualidad registrada.';
END;
GO

IF OBJECT_ID('dbo.usp_mensualidad_actualizar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_mensualidad_actualizar;
GO

CREATE PROCEDURE dbo.usp_mensualidad_actualizar
    @Id                 NVARCHAR(50),
    @IdUsuario          NVARCHAR(50),
    @IdPlan             NVARCHAR(50),
    @IdTurno            NVARCHAR(50)  = NULL,
    @EstadoMiembro      INT,
    @FechaInicio        CHAR(8),
    @FechaFin           CHAR(8),
    @MontoTotal         DECIMAL(10,2),
    @IdAula             NVARCHAR(50)  = NULL,
    @IdTutor           NVARCHAR(50)  = NULL,
    @Observaciones      NVARCHAR(MAX) = NULL,
    @FechaCancelacion   CHAR(8)       = NULL,
    @Resultado          INT OUTPUT,
    @Mensaje            NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = @Id)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'La mensualidad no existe.'; RETURN; END
    IF @EstadoMiembro NOT IN (2, 3)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Estado de mensualidad no válido.'; RETURN; END

    IF @IdTutor IS NOT NULL AND @IdTutor <> ''
       AND NOT EXISTS (SELECT 1 FROM TUTOR WHERE IDTUTOR = @IdTutor AND ACTIVO = 1)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El tutor seleccionado no es válido.'; RETURN; END

    UPDATE MENSUALIDAD SET
        IDUSUARIO        = @IdUsuario,
        IDPLAN           = @IdPlan,
        IDTURNO          = @IdTurno,
        ESTADOMIEMBRO    = @EstadoMiembro,
        FECHAINICIO      = @FechaInicio,
        FECHAFIN         = @FechaFin,
        MONTOTOTAL       = @MontoTotal,
        IDAULA           = @IdAula,
        IDTUTOR         = @IdTutor,
        OBSERVACIONES    = @Observaciones,
        FECHACANCELACION = @FechaCancelacion
    WHERE IDMENSUALIDAD = @Id;

    SET @Resultado = 1; SET @Mensaje = 'Mensualidad actualizada.';
END;
GO

IF OBJECT_ID('dbo.usp_pago_mensualidades_estudiante', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_pago_mensualidades_estudiante;
GO

CREATE PROCEDURE dbo.usp_pago_mensualidades_estudiante
    @IdUsuario NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP 3
        m.IDMENSUALIDAD,
        m.IDPLAN,
        pl.NOMBRE AS PLAN_NOMBRE,
        m.IDTURNO,
        m.IDAULA,
        m.IDTUTOR,
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
    FROM MENSUALIDAD m
    INNER JOIN [PLAN] pl ON pl.IDPLAN = m.IDPLAN
    OUTER APPLY (
        SELECT SUM(p.MONTO) AS PAGADO
        FROM PAGOMENSUALIDAD p
        WHERE p.IDMENSUALIDAD = m.IDMENSUALIDAD
    ) pag
    WHERE m.IDUSUARIO = @IdUsuario
      AND m.ESTADO = 'Activo'
    ORDER BY m.FECHAREGISTRO DESC, m.IDMENSUALIDAD DESC;
END;
GO

IF OBJECT_ID('dbo.usp_mensualidad_eliminar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_mensualidad_eliminar;
GO

CREATE PROCEDURE dbo.usp_mensualidad_eliminar
    @Id                 NVARCHAR(50),
    @EliminacionFisica  BIT           = 0,
    @Resultado          INT OUTPUT,
    @Mensaje            NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = @Id)
    BEGIN
        SET @Resultado = 0;
        SET @Mensaje = 'La mensualidad no existe.';
        RETURN;
    END

    IF @EliminacionFisica = 1
    BEGIN
        DELETE FROM NOTIFICACIONMENSUALIDAD WHERE IDMENSUALIDAD = @Id;
        DELETE FROM PAGOMENSUALIDAD WHERE IDMENSUALIDAD = @Id;
        DELETE FROM MENSUALIDAD WHERE IDMENSUALIDAD = @Id;
        SET @Resultado = 1;
        SET @Mensaje = 'Mensualidad eliminada permanentemente.';
        RETURN;
    END

    UPDATE MENSUALIDAD
    SET ESTADO = 'Inactivo'
    WHERE IDMENSUALIDAD = @Id;

    SET @Resultado = 1;
    SET @Mensaje = 'Mensualidad desactivada.';
END;
GO

IF OBJECT_ID('dbo.usp_mensualidad_buscar_estudiantes', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_mensualidad_buscar_estudiantes;
GO

CREATE PROCEDURE dbo.usp_mensualidad_buscar_estudiantes
    @Buscar NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP 20
        u.IDUSUARIO,
        u.DNI,
        u.NOMBRE,
        u.APELLIDO,
        UPPER(LTRIM(RTRIM(ISNULL(u.APELLIDO, '') + ' ' + ISNULL(u.NOMBRE, '')))) AS NOMBRE_COMPLETO
    FROM USUARIO u
    WHERE u.IDTIPOUSUARIO = '1'
      AND u.ESTADO = 'Activo'
      AND (@Buscar IS NULL OR @Buscar = '' OR
           u.DNI LIKE '%' + @Buscar + '%' OR
           u.NOMBRE LIKE '%' + @Buscar + '%' OR
           u.APELLIDO LIKE '%' + @Buscar + '%' OR
           (u.APELLIDO + ' ' + u.NOMBRE) LIKE '%' + @Buscar + '%')
    ORDER BY u.APELLIDO, u.NOMBRE;
END;
GO

/* ============================================================================
   Pagos: listar, abonar mensualidad, últimas 3 mensualidads con deuda
   Ejecutar después de 6.usp_mensualidad_estado_registro.sql
   Fecha: 12/07/2026
   ============================================================================ */

IF OBJECT_ID('dbo.usp_pago_listar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_pago_listar;
GO

CREATE PROCEDURE dbo.usp_pago_listar
    @Buscar         NVARCHAR(200) = NULL,
    @OrdenarPor     NVARCHAR(50)  = 'FECHAPAGO',
    @Direccion      NVARCHAR(4)   = 'DESC',
    @Pagina         INT           = 1,
    @TamanioPagina  INT           = 10,
    @TotalRegistros INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    IF @Pagina < 1 SET @Pagina = 1;
    IF @TamanioPagina < 1 SET @TamanioPagina = 10;

    SELECT @TotalRegistros = COUNT(*)
    FROM PAGOMENSUALIDAD p
    INNER JOIN MENSUALIDAD m ON m.IDMENSUALIDAD = p.IDMENSUALIDAD
    INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
    INNER JOIN [PLAN] pl ON pl.IDPLAN = m.IDPLAN
    LEFT JOIN METODO_PAGO mp ON mp.IDMETODOPAGO = p.IDMETODOPAGO
    WHERE (@Buscar IS NULL OR @Buscar = '' OR
           p.IDPAGOMENSUALIDAD LIKE '%' + @Buscar + '%' OR
           m.IDMENSUALIDAD LIKE '%' + @Buscar + '%' OR
           u.DNI LIKE '%' + @Buscar + '%' OR
           u.NOMBRE LIKE '%' + @Buscar + '%' OR
           u.APELLIDO LIKE '%' + @Buscar + '%' OR
           pl.NOMBRE LIKE '%' + @Buscar + '%' OR
           ISNULL(mp.TITULO, '') LIKE '%' + @Buscar + '%');

    SELECT
        p.IDPAGOMENSUALIDAD,
        p.IDMENSUALIDAD,
        p.MONTO,
        p.FECHAPAGO,
        p.HORAPAGO,
        p.OBSERVACIONES,
        p.IDMETODOPAGO,
        ISNULL(mp.TITULO, '') AS METODOPAGO_TITULO,
        UPPER(LTRIM(RTRIM(ISNULL(u.APELLIDO, '') + ' ' + ISNULL(u.NOMBRE, '')))) AS ESTUDIANTE_NOMBRE,
        u.DNI AS ESTUDIANTE_DNI,
        pl.NOMBRE AS PLAN_NOMBRE
    FROM PAGOMENSUALIDAD p
    INNER JOIN MENSUALIDAD m ON m.IDMENSUALIDAD = p.IDMENSUALIDAD
    INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
    INNER JOIN [PLAN] pl ON pl.IDPLAN = m.IDPLAN
    LEFT JOIN METODO_PAGO mp ON mp.IDMETODOPAGO = p.IDMETODOPAGO
    WHERE (@Buscar IS NULL OR @Buscar = '' OR
           p.IDPAGOMENSUALIDAD LIKE '%' + @Buscar + '%' OR
           m.IDMENSUALIDAD LIKE '%' + @Buscar + '%' OR
           u.DNI LIKE '%' + @Buscar + '%' OR
           u.NOMBRE LIKE '%' + @Buscar + '%' OR
           u.APELLIDO LIKE '%' + @Buscar + '%' OR
           pl.NOMBRE LIKE '%' + @Buscar + '%' OR
           ISNULL(mp.TITULO, '') LIKE '%' + @Buscar + '%')
    ORDER BY
        CASE WHEN @OrdenarPor = 'FECHAPAGO' AND @Direccion = 'ASC'  THEN p.FECHAPAGO END ASC,
        CASE WHEN @OrdenarPor = 'FECHAPAGO' AND @Direccion = 'DESC' THEN p.FECHAPAGO END DESC,
        CASE WHEN @OrdenarPor = 'MONTO' AND @Direccion = 'ASC'  THEN p.MONTO END ASC,
        CASE WHEN @OrdenarPor = 'MONTO' AND @Direccion = 'DESC' THEN p.MONTO END DESC,
        CASE WHEN @OrdenarPor = 'ESTUDIANTE_NOMBRE' AND @Direccion = 'ASC'  THEN u.APELLIDO END ASC,
        CASE WHEN @OrdenarPor = 'ESTUDIANTE_NOMBRE' AND @Direccion = 'DESC' THEN u.APELLIDO END DESC,
        CASE WHEN @OrdenarPor = 'IDPAGOMENSUALIDAD' AND @Direccion = 'ASC'  THEN p.IDPAGOMENSUALIDAD END ASC,
        CASE WHEN @OrdenarPor = 'IDPAGOMENSUALIDAD' AND @Direccion = 'DESC' THEN p.IDPAGOMENSUALIDAD END DESC,
        p.FECHAPAGO DESC, p.HORAPAGO DESC, p.IDPAGOMENSUALIDAD DESC
    OFFSET (@Pagina - 1) * @TamanioPagina ROWS
    FETCH NEXT @TamanioPagina ROWS ONLY;
END;
GO

IF OBJECT_ID('dbo.usp_pago_insertar_abono', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_pago_insertar_abono;
GO

CREATE PROCEDURE dbo.usp_pago_insertar_abono
    @IdMensualidad    NVARCHAR(50),
    @Monto          DECIMAL(10,2),
    @IdMetodoPago   NVARCHAR(50),
    @Observaciones  NVARCHAR(MAX) = NULL,
    @RegistradoPor  NVARCHAR(50)  = NULL,
    @Resultado      INT OUTPUT,
    @Mensaje        NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF @IdMensualidad IS NULL OR @IdMensualidad = ''
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Debe seleccionar una mensualidad.'; RETURN; END
    IF @Monto IS NULL OR @Monto <= 0
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ingrese un monto válido.'; RETURN; END
    IF @IdMetodoPago IS NULL OR @IdMetodoPago = ''
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Indique el método de pago.'; RETURN; END

    IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = @IdMensualidad AND ESTADO = 'Activo')
    BEGIN SET @Resultado = 0; SET @Mensaje = 'La mensualidad no existe o está inactiva.'; RETURN; END

    IF NOT EXISTS (SELECT 1 FROM METODO_PAGO WHERE IDMETODOPAGO = @IdMetodoPago AND ACTIVO = 1)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El método de pago no es válido.'; RETURN; END

    DECLARE @MontoTotal DECIMAL(10,2);
    DECLARE @Pagado DECIMAL(10,2);
    DECLARE @Deuda DECIMAL(10,2);

    SELECT @MontoTotal = ISNULL(MONTOTOTAL, 0) FROM MENSUALIDAD WHERE IDMENSUALIDAD = @IdMensualidad;
    SELECT @Pagado = ISNULL(SUM(MONTO), 0) FROM PAGOMENSUALIDAD WHERE IDMENSUALIDAD = @IdMensualidad;
    SET @Deuda = @MontoTotal - @Pagado;
    IF @Deuda < 0 SET @Deuda = 0;

    IF @Deuda <= 0
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Esta mensualidad no tiene deuda pendiente.'; RETURN; END
    IF @Monto > @Deuda
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El abono no puede superar la deuda (S/ ' + CAST(@Deuda AS NVARCHAR(20)) + ').'; RETURN; END

    DECLARE @IdPago NVARCHAR(50) = 'PAG' + RIGHT('000000' + CAST((
        ISNULL((SELECT MAX(TRY_CAST(SUBSTRING(IDPAGOMENSUALIDAD, 4, 10) AS INT))
                FROM PAGOMENSUALIDAD WHERE IDPAGOMENSUALIDAD LIKE 'PAG%'), 0) + 1
    ) AS VARCHAR(10)), 6);

    INSERT INTO PAGOMENSUALIDAD (
        IDPAGOMENSUALIDAD, MONTO, FECHAPAGO, HORAPAGO, OBSERVACIONES,
        IDMENSUALIDAD, IDMETODOPAGO, IDUSUARIO
    ) VALUES (
        @IdPago, @Monto, dbo.fn_fecha_ddmmyyyy(), CONVERT(CHAR(8), GETDATE(), 108),
        ISNULL(NULLIF(@Observaciones, ''), 'Abono'),
        @IdMensualidad, @IdMetodoPago, @RegistradoPor
    );

    SET @Resultado = 1;
    SET @Mensaje = 'Abono registrado correctamente.';
END;
GO

/* ============================================================================
   Pagos: obtener, actualizar y eliminar
   Ejecutar después de 10.comoentero_a_usuario.sql
   Fecha: 12/07/2026
   ============================================================================ */

IF OBJECT_ID('dbo.usp_pago_obtener', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_pago_obtener;
GO

CREATE PROCEDURE dbo.usp_pago_obtener
    @Id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.IDPAGOMENSUALIDAD,
        p.IDMENSUALIDAD,
        p.MONTO,
        p.FECHAPAGO,
        p.HORAPAGO,
        p.OBSERVACIONES,
        p.IDMETODOPAGO,
        ISNULL(mp.TITULO, '') AS METODOPAGO_TITULO,
        m.IDUSUARIO,
        UPPER(LTRIM(RTRIM(ISNULL(u.APELLIDO, '') + ' ' + ISNULL(u.NOMBRE, '')))) AS ESTUDIANTE_NOMBRE,
        u.DNI AS ESTUDIANTE_DNI,
        pl.NOMBRE AS PLAN_NOMBRE,
        m.MONTOTOTAL,
        ISNULL(pag.PAGADO, 0) AS PAGADO,
        CASE
            WHEN ISNULL(m.MONTOTOTAL, 0) - ISNULL(pag.PAGADO, 0) < 0 THEN 0
            ELSE ISNULL(m.MONTOTOTAL, 0) - ISNULL(pag.PAGADO, 0)
        END AS DEUDA
    FROM PAGOMENSUALIDAD p
    INNER JOIN MENSUALIDAD m ON m.IDMENSUALIDAD = p.IDMENSUALIDAD
    INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
    INNER JOIN [PLAN] pl ON pl.IDPLAN = m.IDPLAN
    LEFT JOIN METODO_PAGO mp ON mp.IDMETODOPAGO = p.IDMETODOPAGO
    OUTER APPLY (
        SELECT SUM(x.MONTO) AS PAGADO
        FROM PAGOMENSUALIDAD x
        WHERE x.IDMENSUALIDAD = m.IDMENSUALIDAD
    ) pag
    WHERE p.IDPAGOMENSUALIDAD = @Id;
END;
GO

IF OBJECT_ID('dbo.usp_pago_actualizar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_pago_actualizar;
GO

CREATE PROCEDURE dbo.usp_pago_actualizar
    @Id             NVARCHAR(50),
    @Monto          DECIMAL(10,2),
    @IdMetodoPago   NVARCHAR(50),
    @FechaPago      CHAR(8) = NULL,
    @Observaciones  NVARCHAR(MAX) = NULL,
    @Resultado      INT OUTPUT,
    @Mensaje        NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM PAGOMENSUALIDAD WHERE IDPAGOMENSUALIDAD = @Id)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El pago no existe.'; RETURN; END
    IF @Monto IS NULL OR @Monto <= 0
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ingrese un monto válido.'; RETURN; END
    IF @IdMetodoPago IS NULL OR @IdMetodoPago = ''
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Indique el método de pago.'; RETURN; END
    IF NOT EXISTS (SELECT 1 FROM METODO_PAGO WHERE IDMETODOPAGO = @IdMetodoPago AND ACTIVO = 1)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El método de pago no es válido.'; RETURN; END

    DECLARE @IdMensualidad NVARCHAR(50);
    DECLARE @MontoAnterior DECIMAL(10,2);
    DECLARE @MontoTotal DECIMAL(10,2);
    DECLARE @PagadoOtros DECIMAL(10,2);
    DECLARE @Maximo DECIMAL(10,2);

    SELECT @IdMensualidad = IDMENSUALIDAD, @MontoAnterior = MONTO
    FROM PAGOMENSUALIDAD WHERE IDPAGOMENSUALIDAD = @Id;

    SELECT @MontoTotal = ISNULL(MONTOTOTAL, 0) FROM MENSUALIDAD WHERE IDMENSUALIDAD = @IdMensualidad;
    SELECT @PagadoOtros = ISNULL(SUM(MONTO), 0)
    FROM PAGOMENSUALIDAD
    WHERE IDMENSUALIDAD = @IdMensualidad AND IDPAGOMENSUALIDAD <> @Id;

    SET @Maximo = @MontoTotal - @PagadoOtros;
    IF @Maximo < 0 SET @Maximo = 0;
    IF @Monto > @Maximo
    BEGIN
        SET @Resultado = 0;
        SET @Mensaje = 'El monto no puede superar S/ ' + CAST(@Maximo AS NVARCHAR(20)) + '.';
        RETURN;
    END

    UPDATE PAGOMENSUALIDAD SET
        MONTO          = @Monto,
        IDMETODOPAGO   = @IdMetodoPago,
        FECHAPAGO      = CASE WHEN @FechaPago IS NOT NULL AND @FechaPago <> '' THEN @FechaPago ELSE FECHAPAGO END,
        OBSERVACIONES  = @Observaciones
    WHERE IDPAGOMENSUALIDAD = @Id;

    SET @Resultado = 1;
    SET @Mensaje = 'Pago actualizado.';
END;
GO

IF OBJECT_ID('dbo.usp_pago_eliminar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_pago_eliminar;
GO

CREATE PROCEDURE dbo.usp_pago_eliminar
    @Id         NVARCHAR(50),
    @Resultado  INT OUTPUT,
    @Mensaje    NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM PAGOMENSUALIDAD WHERE IDPAGOMENSUALIDAD = @Id)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El pago no existe.'; RETURN; END

    DELETE FROM PAGOMENSUALIDAD WHERE IDPAGOMENSUALIDAD = @Id;

    SET @Resultado = 1;
    SET @Mensaje = 'Pago eliminado.';
END;
GO

/* ============================================================================
   Pagos: últimas mensualidads incluyen COSTOMENSUAL del plan
   Ejecutar después de 11.plan_costo_mensual.sql
   Fecha: 16/07/2026
   ============================================================================ */

IF OBJECT_ID('dbo.usp_pago_mensualidades_estudiante', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_pago_mensualidades_estudiante;
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
        FROM MENSUALIDAD m
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
              FROM MENSUALIDAD m
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

IF OBJECT_ID('dbo.usp_plan_eliminar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_plan_eliminar;
GO

CREATE PROCEDURE dbo.usp_plan_eliminar
    @Id        NVARCHAR(50),
    @Resultado INT OUTPUT,
    @Mensaje   NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM [PLAN] WHERE IDPLAN = @Id)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El plan no existe.'; RETURN; END

    IF EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDPLAN = @Id)
    BEGIN
        SET @Resultado = 0;
        SET @Mensaje = 'No se puede eliminar: el plan tiene mensualidads asociadas.';
        RETURN;
    END

    DELETE FROM [PLAN] WHERE IDPLAN = @Id;

    SET @Resultado = 1; SET @Mensaje = 'Plan eliminado.';
END;
GO

IF OBJECT_ID('dbo.usp_aula_eliminar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_aula_eliminar;
GO

CREATE PROCEDURE dbo.usp_aula_eliminar
    @Id        NVARCHAR(50),
    @Resultado INT OUTPUT,
    @Mensaje   NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM AULA WHERE IDAULA = @Id)
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'El aula no existe.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDAULA = @Id)
    BEGIN
        SET @Resultado = 0;
        SET @Mensaje = 'No se puede eliminar: el aula tiene mensualidads asociadas.';
        RETURN;
    END

    DELETE FROM AULA WHERE IDAULA = @Id;

    SET @Resultado = 1; SET @Mensaje = 'Aula eliminada.';
END;
GO

/* ============================================================================
   Exámenes — flujo estudiante (listar / iniciar / pregunta / responder / finalizar)
   Ejecutar después de 2.usp_examen_crud.sql
   Fecha: 17/07/2026
   ============================================================================ */

/* Helper inline: ddmmyyyy + hora → DATETIME */
/* Uso: dbo no tiene fn; se repite patrón TRY_CONVERT */

IF OBJECT_ID('dbo.usp_examen_estudiante_listar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_examen_estudiante_listar;
GO

CREATE PROCEDURE dbo.usp_examen_estudiante_listar
    @IdUsuario NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    IF @IdUsuario IS NULL OR LTRIM(RTRIM(@IdUsuario)) = ''
    BEGIN
        SELECT CAST(NULL AS NVARCHAR(50)) AS IDEXAMEN WHERE 1 = 0;
        RETURN;
    END

    DECLARE @Ahora DATETIME = GETDATE();
    DECLARE @IdAula NVARCHAR(50) = NULL;

    SELECT TOP 1 @IdAula = m.IDAULA
    FROM MENSUALIDAD m
    WHERE m.IDUSUARIO = @IdUsuario
      AND (m.ESTADOMIEMBRO IS NULL OR m.ESTADOMIEMBRO <> 3)
    ORDER BY m.FECHAREGISTRO DESC, m.IDMENSUALIDAD DESC;

    ;WITH Base AS (
        SELECT
            e.IDEXAMEN,
            e.TITULO,
            e.DESCRIPCION,
            e.TIPO,
            e.DURACIONMIN,
            e.FECHAINICIO,
            e.FECHAFIN,
            e.HORAINICIO,
            e.HORAFIN,
            e.INTENTOSMAX,
            e.VISIBLE,
            ISNULL(e.TODASLASULA, 1) AS TODASLASULA,
            ISNULL(e.PUNTAJETOTAL, 0) AS PUNTAJETOTAL,
            (SELECT COUNT(*) FROM PREGUNTA p WHERE p.IDEXAMEN = e.IDEXAMEN) AS CANTPREGUNTAS,
            TRY_CONVERT(DATETIME,
                SUBSTRING(e.FECHAINICIO, 5, 4) + '-' + SUBSTRING(e.FECHAINICIO, 3, 2) + '-' + SUBSTRING(e.FECHAINICIO, 1, 2)
                + ' ' + LEFT(ISNULL(NULLIF(RTRIM(e.HORAINICIO), ''), '00:00:00') + '00', 8),
                120) AS DT_INICIO,
            TRY_CONVERT(DATETIME,
                SUBSTRING(e.FECHAFIN, 5, 4) + '-' + SUBSTRING(e.FECHAFIN, 3, 2) + '-' + SUBSTRING(e.FECHAFIN, 1, 2)
                + ' ' + LEFT(ISNULL(NULLIF(RTRIM(e.HORAFIN), ''), '23:59:59') + '00', 8),
                120) AS DT_FIN
        FROM EXAMEN e
        WHERE e.VISIBLE = 1
          AND (SELECT COUNT(*) FROM PREGUNTA p WHERE p.IDEXAMEN = e.IDEXAMEN) > 0
          AND (
                ISNULL(e.TODASLASULA, 1) = 1
                OR EXISTS (
                    SELECT 1 FROM EXAMEN_AULA ea
                    WHERE ea.IDEXAMEN = e.IDEXAMEN
                      AND ea.IDAULA = @IdAula
                )
              )
    )
    SELECT
        b.IDEXAMEN,
        b.TITULO,
        b.DESCRIPCION,
        b.TIPO,
        b.DURACIONMIN,
        b.FECHAINICIO,
        b.FECHAFIN,
        b.HORAINICIO,
        b.HORAFIN,
        b.INTENTOSMAX,
        b.CANTPREGUNTAS,
        b.PUNTAJETOTAL,
        CASE
            WHEN b.DT_INICIO IS NOT NULL AND @Ahora < b.DT_INICIO THEN 'proximamente'
            WHEN b.DT_FIN IS NOT NULL AND @Ahora > b.DT_FIN THEN 'cerrado'
            ELSE 'disponible'
        END AS ESTADOEXAMEN,
        ISNULL((
            SELECT COUNT(*)
            FROM INTENTO_EXAMEN i
            WHERE i.IDEXAMEN = b.IDEXAMEN
              AND i.IDUSUARIO = @IdUsuario
              AND ISNULL(i.ESTADO, 0) = 1
        ), 0) AS INTENTOSFINALIZADOS,
        (
            SELECT TOP 1 i.IDINTENTOEXAMEN
            FROM INTENTO_EXAMEN i
            WHERE i.IDEXAMEN = b.IDEXAMEN
              AND i.IDUSUARIO = @IdUsuario
              AND ISNULL(i.ESTADO, 0) = 0
            ORDER BY i.NUMEROINTENTO DESC
        ) AS IDINTENTOENCURSO,
        (
            SELECT TOP 1 i.PUNTAJEOBTENIDO
            FROM INTENTO_EXAMEN i
            WHERE i.IDEXAMEN = b.IDEXAMEN
              AND i.IDUSUARIO = @IdUsuario
              AND ISNULL(i.ESTADO, 0) = 1
            ORDER BY i.NUMEROINTENTO DESC
        ) AS ULTIMOPUNTAJE,
        CASE
            WHEN EXISTS (
                SELECT 1 FROM INTENTO_EXAMEN i
                WHERE i.IDEXAMEN = b.IDEXAMEN
                  AND i.IDUSUARIO = @IdUsuario
                  AND ISNULL(i.ESTADO, 0) = 0
            ) THEN 'continuar'
            WHEN (
                SELECT COUNT(*) FROM INTENTO_EXAMEN i
                WHERE i.IDEXAMEN = b.IDEXAMEN
                  AND i.IDUSUARIO = @IdUsuario
                  AND ISNULL(i.ESTADO, 0) = 1
            ) >= ISNULL(NULLIF(b.INTENTOSMAX, 0), 1)
            THEN 'agotado'
            WHEN b.DT_INICIO IS NOT NULL AND @Ahora < b.DT_INICIO THEN 'proximamente'
            WHEN b.DT_FIN IS NOT NULL AND @Ahora > b.DT_FIN THEN 'cerrado'
            ELSE 'desarrollar'
        END AS ACCION
    FROM Base b
    ORDER BY
        CASE
            WHEN b.DT_INICIO IS NOT NULL AND @Ahora < b.DT_INICIO THEN 2
            WHEN b.DT_FIN IS NOT NULL AND @Ahora > b.DT_FIN THEN 3
            ELSE 1
        END,
        b.DT_INICIO DESC,
        b.TITULO;
END;
GO

IF OBJECT_ID('dbo.usp_examen_intento_iniciar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_examen_intento_iniciar;
GO

CREATE PROCEDURE dbo.usp_examen_intento_iniciar
    @IdExamen     NVARCHAR(50),
    @IdUsuario    NVARCHAR(50),
    @IdIntento    NVARCHAR(50) OUTPUT,
    @Resultado    INT OUTPUT,
    @Mensaje      NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @IdIntento = NULL;
    SET @Resultado = 0;
    SET @Mensaje = 'Error desconocido.';

    IF @IdExamen IS NULL OR @IdUsuario IS NULL
    BEGIN SET @Mensaje = 'Datos incompletos.'; RETURN; END

    IF NOT EXISTS (SELECT 1 FROM USUARIO WHERE IDUSUARIO = @IdUsuario)
    BEGIN SET @Mensaje = 'Usuario no válido.'; RETURN; END

    DECLARE @Visible BIT, @Todas BIT, @IntentosMax INT, @Duracion INT;
    DECLARE @Fi CHAR(8), @Ff CHAR(8), @Hi CHAR(8), @Hf CHAR(8);

    SELECT
        @Visible = e.VISIBLE,
        @Todas = ISNULL(e.TODASLASULA, 1),
        @IntentosMax = ISNULL(NULLIF(e.INTENTOSMAX, 0), 1),
        @Duracion = e.DURACIONMIN,
        @Fi = e.FECHAINICIO,
        @Ff = e.FECHAFIN,
        @Hi = e.HORAINICIO,
        @Hf = e.HORAFIN
    FROM EXAMEN e
    WHERE e.IDEXAMEN = @IdExamen;

    IF @Visible IS NULL
    BEGIN SET @Mensaje = 'El examen no existe.'; RETURN; END

    IF @Visible <> 1
    BEGIN SET @Mensaje = 'El examen no está visible.'; RETURN; END

    IF NOT EXISTS (SELECT 1 FROM PREGUNTA WHERE IDEXAMEN = @IdExamen)
    BEGIN SET @Mensaje = 'El examen no tiene preguntas.'; RETURN; END

    DECLARE @IdAula NVARCHAR(50) = NULL;
    SELECT TOP 1 @IdAula = m.IDAULA
    FROM MENSUALIDAD m
    WHERE m.IDUSUARIO = @IdUsuario
      AND (m.ESTADOMIEMBRO IS NULL OR m.ESTADOMIEMBRO <> 3)
    ORDER BY m.FECHAREGISTRO DESC, m.IDMENSUALIDAD DESC;

    IF @Todas = 0 AND NOT EXISTS (
        SELECT 1 FROM EXAMEN_AULA ea
        WHERE ea.IDEXAMEN = @IdExamen AND ea.IDAULA = @IdAula
    )
    BEGIN SET @Mensaje = 'No tienes acceso a este examen (aula).'; RETURN; END

    DECLARE @Ahora DATETIME = GETDATE();
    DECLARE @DT_INICIO DATETIME = TRY_CONVERT(DATETIME,
        SUBSTRING(@Fi, 5, 4) + '-' + SUBSTRING(@Fi, 3, 2) + '-' + SUBSTRING(@Fi, 1, 2)
        + ' ' + LEFT(ISNULL(NULLIF(RTRIM(@Hi), ''), '00:00:00') + '00', 8), 120);
    DECLARE @DT_FIN DATETIME = TRY_CONVERT(DATETIME,
        SUBSTRING(@Ff, 5, 4) + '-' + SUBSTRING(@Ff, 3, 2) + '-' + SUBSTRING(@Ff, 1, 2)
        + ' ' + LEFT(ISNULL(NULLIF(RTRIM(@Hf), ''), '23:59:59') + '00', 8), 120);

    IF @DT_INICIO IS NOT NULL AND @Ahora < @DT_INICIO
    BEGIN SET @Mensaje = 'El examen aún no está disponible.'; RETURN; END
    IF @DT_FIN IS NOT NULL AND @Ahora > @DT_FIN
    BEGIN SET @Mensaje = 'El examen ya cerró.'; RETURN; END

    -- Reanudar intento en curso
    SELECT TOP 1 @IdIntento = i.IDINTENTOEXAMEN
    FROM INTENTO_EXAMEN i
    WHERE i.IDEXAMEN = @IdExamen
      AND i.IDUSUARIO = @IdUsuario
      AND ISNULL(i.ESTADO, 0) = 0
    ORDER BY i.NUMEROINTENTO DESC;

    IF @IdIntento IS NOT NULL
    BEGIN
        SET @Resultado = 1;
        SET @Mensaje = 'Intento en curso reanudado.';
        RETURN;
    END

    DECLARE @Finalizados INT = (
        SELECT COUNT(*) FROM INTENTO_EXAMEN
        WHERE IDEXAMEN = @IdExamen AND IDUSUARIO = @IdUsuario AND ISNULL(ESTADO, 0) = 1
    );
    IF @Finalizados >= @IntentosMax
    BEGIN SET @Mensaje = 'Ya usaste todos los intentos permitidos.'; RETURN; END

    DECLARE @Num INT = @Finalizados + 1;
    DECLARE @NextNum INT;
    SELECT @NextNum = ISNULL(MAX(TRY_CAST(REPLACE(IDINTENTOEXAMEN, 'INT', '') AS INT)), 0) + 1
    FROM INTENTO_EXAMEN WHERE IDINTENTOEXAMEN LIKE 'INT%';
    SET @IdIntento = 'INT' + RIGHT('00000' + CAST(@NextNum AS VARCHAR(5)), 5);

    INSERT INTO INTENTO_EXAMEN (
        IDINTENTOEXAMEN, NUMEROINTENTO,
        FECHAINICIO, HORAINICIO,
        PUNTAJEOBTENIDO, CANTCORRECTAS, CANTINCORRECTAS, CANTSINRESPONDER,
        ESTADO, APROBADO, IDEXAMEN, IDUSUARIO
    )
    VALUES (
        @IdIntento, @Num,
        dbo.fn_fecha_ddmmyyyy(), CONVERT(CHAR(8), GETDATE(), 108),
        NULL, 0, 0, 0,
        0, NULL, @IdExamen, @IdUsuario
    );

    SET @Resultado = 1;
    SET @Mensaje = 'Intento iniciado.';
END;
GO

PRINT 'Renombrado MEMBRESIA/ASESOR -> MENSUALIDAD/TUTOR completado.';
GO
