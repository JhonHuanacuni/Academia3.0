/* ============================================================================
   ADMINISTRACIÓN DE MÓDULOS — Datos iniciales + SPs
   Proyecto: Academia VITA 3.0
   Fecha: 22/06/2026
   ----------------------------------------------------------------------------
   Ejecutar DESPUÉS de esquema_completo.sql
   ============================================================================ */

/* ----------------------------------------------------------------------------
   Helper: fecha DDMMYYYY (convención del esquema — 8 dígitos sin separadores)
   ---------------------------------------------------------------------------- */
IF OBJECT_ID('dbo.fn_fecha_ddmmyyyy', 'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_fecha_ddmmyyyy;
GO
CREATE FUNCTION dbo.fn_fecha_ddmmyyyy()
RETURNS CHAR(8)
AS
BEGIN
    RETURN (
        RIGHT('0' + CAST(DAY(GETDATE()) AS VARCHAR(2)), 2) +
        RIGHT('0' + CAST(MONTH(GETDATE()) AS VARCHAR(2)), 2) +
        CAST(YEAR(GETDATE()) AS VARCHAR(4))
    );
END;
GO

/* ----------------------------------------------------------------------------
   1) Tabla de exclusiones (revocar módulo heredado por rol)
   ---------------------------------------------------------------------------- */
IF OBJECT_ID('USUARIO_MODULO_EXCLUIDO', 'U') IS NULL
BEGIN
    CREATE TABLE USUARIO_MODULO_EXCLUIDO (
        IDUSUARIOEXCLUIDO   NVARCHAR(50) NOT NULL PRIMARY KEY,
        IDUSUARIO           NVARCHAR(50) NOT NULL FOREIGN KEY REFERENCES USUARIO(IDUSUARIO),
        IDMODULO            NVARCHAR(50) NOT NULL FOREIGN KEY REFERENCES MODULO(IDMODULO),
        FECHAREGISTRO       CHAR(8)      NULL,
        CONSTRAINT UQ_USUARIO_MODULO_EXCLUIDO UNIQUE (IDUSUARIO, IDMODULO)
    );
    CREATE INDEX IX_USUARIO_MOD_EXCL_USUARIO ON USUARIO_MODULO_EXCLUIDO(IDUSUARIO);
END
GO

/* ----------------------------------------------------------------------------
   2) Catálogo de permisos
   ---------------------------------------------------------------------------- */
IF NOT EXISTS (SELECT 1 FROM TIPO_PERMISO)
BEGIN
    INSERT INTO TIPO_PERMISO (IDTIPOPERMISO, DESCRIPCION) VALUES
    ('TP001', 'VER'),
    ('TP002', 'CREAR'),
    ('TP003', 'EDITAR'),
    ('TP004', 'ELIMINAR');
END
GO

/* ----------------------------------------------------------------------------
   3) Módulos y submódulos del sistema
   ---------------------------------------------------------------------------- */
IF NOT EXISTS (SELECT 1 FROM MODULO)
BEGIN
    INSERT INTO MODULO (IDMODULO, NOMBRE, DESCRIPCION, ICONO, ORDEN, ACTIVO, FECHACREACION) VALUES
    ('MOD001', 'Dashboard',              'Panel de control principal',           'faGauge',         1,  1, dbo.fn_fecha_ddmmyyyy()),
    ('MOD002', 'Usuarios',               'Gestión de usuarios y roles',        'faUsers',         2,  1, dbo.fn_fecha_ddmmyyyy()),
    ('MOD003', 'Asistencias',            'Control de asistencias',             'faCalendarCheck', 3,  1, dbo.fn_fecha_ddmmyyyy()),
    ('MOD004', 'Membresías',             'Gestión de membresías y pagos',      'faIdCard',        4,  1, dbo.fn_fecha_ddmmyyyy()),
    ('MOD005', 'Biblioteca',             'Recursos educativos',                'faBook',          5,  1, dbo.fn_fecha_ddmmyyyy()),
    ('MOD006', 'Exámenes',               'Gestión de exámenes',                 'faFileLines',     6,  1, dbo.fn_fecha_ddmmyyyy()),
    ('MOD007', 'Notas',                  'Calificaciones y progreso',          'faFilePen',       7,  1, dbo.fn_fecha_ddmmyyyy()),
    ('MOD008', 'Administración Módulos', 'Asignar acceso a módulos',           'faCog',          99,  1, dbo.fn_fecha_ddmmyyyy());
END
GO

IF NOT EXISTS (SELECT 1 FROM SUBMODULO)
BEGIN
    INSERT INTO SUBMODULO (IDSUBMODULO, NOMBRE, DESCRIPCION, ICONO, ORDEN, ACTIVO, IDMODULO) VALUES
    ('SUB002', 'Listado de usuarios',  'Ver y gestionar usuarios',   'faClipboardList', 1, 1, 'MOD002'),
    ('SUB003', 'Marcar asistencia',    'Registrar asistencia',       'faCalendarCheck', 1, 1, 'MOD003'),
    ('SUB004', 'Ver asistencias',      'Historial de asistencias',   'faClipboardList', 2, 1, 'MOD003'),
    ('SUB005', 'Registrar membresía',  'Nueva membresía',            'faUserPlus',      1, 1, 'MOD004'),
    ('SUB006', 'Ver membresías',       'Listado de membresías',     'faClipboardList', 2, 1, 'MOD004'),
    ('SUB007', 'Pagos',                'Gestión de pagos',           'faMoneyBill',     3, 1, 'MOD004'),
    ('SUB008', 'Ver notas',            'Consultar calificaciones',   'faClipboardList', 1, 1, 'MOD007'),
    ('SUB009', 'Asignar módulos',      'Dar acceso a módulos',       'faKey',           1, 1, 'MOD008');
END
GO

/* ----------------------------------------------------------------------------
   4) Permisos por rol (GRUPO_MODULO)
   ---------------------------------------------------------------------------- */
IF NOT EXISTS (SELECT 1 FROM GRUPO_MODULO)
BEGIN
    INSERT INTO GRUPO_MODULO (IDGRUPOMODULO, IDTIPOUSUARIO, IDMODULO, IDTIPOPERMISO) VALUES
    -- Administrador (3): todos los módulos, todos los permisos
    ('GRM001', '3', 'MOD001', 'TP001'), ('GRM002', '3', 'MOD001', 'TP002'), ('GRM003', '3', 'MOD001', 'TP003'), ('GRM004', '3', 'MOD001', 'TP004'),
    ('GRM005', '3', 'MOD002', 'TP001'), ('GRM006', '3', 'MOD002', 'TP002'), ('GRM007', '3', 'MOD002', 'TP003'), ('GRM008', '3', 'MOD002', 'TP004'),
    ('GRM009', '3', 'MOD003', 'TP001'), ('GRM010', '3', 'MOD003', 'TP002'), ('GRM011', '3', 'MOD003', 'TP003'), ('GRM012', '3', 'MOD003', 'TP004'),
    ('GRM013', '3', 'MOD004', 'TP001'), ('GRM014', '3', 'MOD004', 'TP002'), ('GRM015', '3', 'MOD004', 'TP003'), ('GRM016', '3', 'MOD004', 'TP004'),
    ('GRM017', '3', 'MOD005', 'TP001'), ('GRM018', '3', 'MOD005', 'TP002'), ('GRM019', '3', 'MOD005', 'TP003'), ('GRM020', '3', 'MOD005', 'TP004'),
    ('GRM021', '3', 'MOD006', 'TP001'), ('GRM022', '3', 'MOD006', 'TP002'), ('GRM023', '3', 'MOD006', 'TP003'), ('GRM024', '3', 'MOD006', 'TP004'),
    ('GRM025', '3', 'MOD007', 'TP001'), ('GRM026', '3', 'MOD007', 'TP002'), ('GRM027', '3', 'MOD007', 'TP003'), ('GRM028', '3', 'MOD007', 'TP004'),
    ('GRM029', '3', 'MOD008', 'TP001'), ('GRM030', '3', 'MOD008', 'TP002'), ('GRM031', '3', 'MOD008', 'TP003'), ('GRM032', '3', 'MOD008', 'TP004'),
    -- Docente (2): operación diaria
    ('GRM033', '2', 'MOD001', 'TP001'), ('GRM034', '2', 'MOD001', 'TP002'),
    ('GRM035', '2', 'MOD002', 'TP001'), ('GRM036', '2', 'MOD002', 'TP002'),
    ('GRM037', '2', 'MOD003', 'TP001'), ('GRM038', '2', 'MOD003', 'TP002'),
    ('GRM039', '2', 'MOD004', 'TP001'), ('GRM040', '2', 'MOD004', 'TP002'),
    ('GRM041', '2', 'MOD005', 'TP001'),
    ('GRM042', '2', 'MOD006', 'TP001'),
    ('GRM043', '2', 'MOD007', 'TP001'),
    -- Estudiante (1): consulta
    ('GRM044', '1', 'MOD001', 'TP001'),
    ('GRM045', '1', 'MOD005', 'TP001'),
    ('GRM046', '1', 'MOD006', 'TP001'),
    ('GRM047', '1', 'MOD007', 'TP001');
END
GO

/* ============================================================================
   5) STORED PROCEDURES — Administración de módulos
   ============================================================================ */

IF OBJECT_ID('dbo.usp_listar_usuarios_activos', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_listar_usuarios_activos;
GO
CREATE PROCEDURE dbo.usp_listar_usuarios_activos
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        u.IDUSUARIO,
        u.NOMBRE,
        u.APELLIDO,
        u.EMAIL,
        u.IDTIPOUSUARIO,
        t.DESCRIPCION AS TIPOUSUARIO
    FROM USUARIO u
    INNER JOIN TIPOUSUARIO t ON t.IDTIPOUSUARIO = u.IDTIPOUSUARIO
    WHERE u.ESTADO = 'Activo'
    ORDER BY u.NOMBRE, u.APELLIDO;
END;
GO

IF OBJECT_ID('dbo.usp_modulos_listar_activos', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_modulos_listar_activos;
GO
CREATE PROCEDURE dbo.usp_modulos_listar_activos
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        m.IDMODULO,
        m.NOMBRE,
        m.DESCRIPCION,
        m.ICONO,
        m.ORDEN
    FROM MODULO m
    WHERE m.ACTIVO = 1
    ORDER BY m.ORDEN, m.NOMBRE;
END;
GO

IF OBJECT_ID('dbo.usp_submodulos_por_modulo', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_submodulos_por_modulo;
GO
CREATE PROCEDURE dbo.usp_submodulos_por_modulo
    @idmodulo NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        s.IDSUBMODULO,
        s.NOMBRE,
        s.DESCRIPCION,
        s.ICONO,
        s.ORDEN
    FROM SUBMODULO s
    WHERE s.IDMODULO = @idmodulo
      AND s.ACTIVO = 1
    ORDER BY s.ORDEN, s.NOMBRE;
END;
GO

IF OBJECT_ID('dbo.usp_modulos_efectivos_usuario', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_modulos_efectivos_usuario;
GO
CREATE PROCEDURE dbo.usp_modulos_efectivos_usuario
    @idusuario NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @idtipo NVARCHAR(50);
    SELECT @idtipo = IDTIPOUSUARIO
    FROM USUARIO
    WHERE IDUSUARIO = @idusuario AND ESTADO = 'Activo';

    IF @idtipo IS NULL
        RETURN;

    ;WITH PermisosRol AS (
        SELECT gm.IDMODULO, tp.DESCRIPCION AS PERMISO
        FROM GRUPO_MODULO gm
        INNER JOIN TIPO_PERMISO tp ON tp.IDTIPOPERMISO = gm.IDTIPOPERMISO
        WHERE gm.IDTIPOUSUARIO = @idtipo
    ),
    PermisosUsuario AS (
        SELECT um.IDMODULO, tp.DESCRIPCION AS PERMISO
        FROM USUARIO_MODULO um
        INNER JOIN TIPO_PERMISO tp ON tp.IDTIPOPERMISO = um.IDTIPOPERMISO
        WHERE um.IDUSUARIO = @idusuario
    ),
    ModulosBase AS (
        SELECT IDMODULO, PERMISO FROM PermisosRol
        UNION
        SELECT IDMODULO, PERMISO FROM PermisosUsuario
    ),
    ModulosFiltrados AS (
        SELECT mb.IDMODULO, mb.PERMISO
        FROM ModulosBase mb
        WHERE NOT EXISTS (
            SELECT 1
            FROM USUARIO_MODULO_EXCLUIDO ex
            WHERE ex.IDUSUARIO = @idusuario
              AND ex.IDMODULO = mb.IDMODULO
        )
    )
    SELECT
        m.IDMODULO,
        m.NOMBRE,
        m.DESCRIPCION,
        m.ICONO,
        m.ORDEN,
        STRING_AGG(mf.PERMISO, ',') WITHIN GROUP (ORDER BY mf.PERMISO) AS PERMISOS
    FROM ModulosFiltrados mf
    INNER JOIN MODULO m ON m.IDMODULO = mf.IDMODULO AND m.ACTIVO = 1
    GROUP BY m.IDMODULO, m.NOMBRE, m.DESCRIPCION, m.ICONO, m.ORDEN
    ORDER BY m.ORDEN, m.NOMBRE;
END;
GO

IF OBJECT_ID('dbo.usp_modulo_asignar_usuario', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_modulo_asignar_usuario;
GO
CREATE PROCEDURE dbo.usp_modulo_asignar_usuario
    @idusuario  NVARCHAR(50),
    @idmodulo   NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM USUARIO WHERE IDUSUARIO = @idusuario AND ESTADO = 'Activo')
    BEGIN
        RAISERROR('Usuario no encontrado o inactivo', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM MODULO WHERE IDMODULO = @idmodulo AND ACTIVO = 1)
    BEGIN
        RAISERROR('Módulo no encontrado o inactivo', 16, 1);
        RETURN;
    END

    -- Quitar exclusión previa
    DELETE FROM USUARIO_MODULO_EXCLUIDO
    WHERE IDUSUARIO = @idusuario AND IDMODULO = @idmodulo;

    -- Asignar permisos VER y CREAR (personalización por usuario)
    DECLARE @perms TABLE (IDTIPOPERMISO NVARCHAR(50));
    INSERT INTO @perms VALUES ('TP001'), ('TP002');

    DECLARE @idpermiso NVARCHAR(50);
    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR SELECT IDTIPOPERMISO FROM @perms;
    OPEN cur;
    FETCH NEXT FROM cur INTO @idpermiso;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF NOT EXISTS (
            SELECT 1 FROM USUARIO_MODULO
            WHERE IDUSUARIO = @idusuario
              AND IDMODULO = @idmodulo
              AND IDTIPOPERMISO = @idpermiso
        )
        BEGIN
            INSERT INTO USUARIO_MODULO (IDUSUARIOMODULO, IDUSUARIO, IDMODULO, IDTIPOPERMISO)
            VALUES (
                'UM_' + REPLACE(CONVERT(NVARCHAR(36), NEWID()), '-', ''),
                @idusuario,
                @idmodulo,
                @idpermiso
            );
        END
        FETCH NEXT FROM cur INTO @idpermiso;
    END
    CLOSE cur;
    DEALLOCATE cur;

    SELECT CAST(1 AS BIT) AS success;
END;
GO

IF OBJECT_ID('dbo.usp_modulo_desasignar_usuario', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_modulo_desasignar_usuario;
GO
CREATE PROCEDURE dbo.usp_modulo_desasignar_usuario
    @idusuario NVARCHAR(50),
    @idmodulo  NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @idtipo NVARCHAR(50);
    SELECT @idtipo = IDTIPOUSUARIO
    FROM USUARIO
    WHERE IDUSUARIO = @idusuario AND ESTADO = 'Activo';

    IF @idtipo IS NULL
    BEGIN
        RAISERROR('Usuario no encontrado o inactivo', 16, 1);
        RETURN;
    END

    -- Quitar asignaciones directas del usuario
    DELETE FROM USUARIO_MODULO
    WHERE IDUSUARIO = @idusuario AND IDMODULO = @idmodulo;

    -- Si el rol aún tiene el módulo, registrar exclusión
    IF EXISTS (
        SELECT 1 FROM GRUPO_MODULO
        WHERE IDTIPOUSUARIO = @idtipo AND IDMODULO = @idmodulo
    )
    AND NOT EXISTS (
        SELECT 1 FROM USUARIO_MODULO_EXCLUIDO
        WHERE IDUSUARIO = @idusuario AND IDMODULO = @idmodulo
    )
    BEGIN
        INSERT INTO USUARIO_MODULO_EXCLUIDO (IDUSUARIOEXCLUIDO, IDUSUARIO, IDMODULO, FECHAREGISTRO)
        VALUES (
            'EX_' + REPLACE(CONVERT(NVARCHAR(36), NEWID()), '-', ''),
            @idusuario,
            @idmodulo,
            dbo.fn_fecha_ddmmyyyy()
        );
    END

    SELECT CAST(1 AS BIT) AS success;
END;
GO

PRINT 'modulos_admin.sql ejecutado correctamente';
GO
