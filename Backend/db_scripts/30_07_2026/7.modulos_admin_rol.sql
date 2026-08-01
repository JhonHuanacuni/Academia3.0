/* ============================================================================
   Administración de módulos y submódulos POR ROL (TIPOUSUARIO)
   Ejecutar después de modulos_admin.sql y submodulos_admin.sql
   Fecha: 30/07/2026
   ============================================================================ */

IF OBJECT_ID('dbo.GRUPO_SUBMODULO_EXCLUIDO', 'U') IS NULL
BEGIN
    CREATE TABLE GRUPO_SUBMODULO_EXCLUIDO (
        IDGRUPOEXCLSUB    NVARCHAR(50)  NOT NULL PRIMARY KEY,
        IDTIPOUSUARIO     NVARCHAR(50)  NOT NULL,
        IDSUBMODULO       NVARCHAR(50)  NOT NULL,
        FECHAREGISTRO     CHAR(8)       NULL,
        CONSTRAINT FK_GEXCLSUB_TIPO FOREIGN KEY (IDTIPOUSUARIO) REFERENCES TIPOUSUARIO(IDTIPOUSUARIO),
        CONSTRAINT FK_GEXCLSUB_SUB  FOREIGN KEY (IDSUBMODULO) REFERENCES SUBMODULO(IDSUBMODULO),
        CONSTRAINT UQ_GRUPO_SUBMODULO_EXCL UNIQUE (IDTIPOUSUARIO, IDSUBMODULO)
    );
END
GO

IF OBJECT_ID('dbo.usp_modulos_efectivos_rol', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_modulos_efectivos_rol;
GO
CREATE PROCEDURE dbo.usp_modulos_efectivos_rol
    @idtipousuario NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM TIPOUSUARIO WHERE IDTIPOUSUARIO = @idtipousuario)
        RETURN;

    ;WITH PermisosRol AS (
        SELECT gm.IDMODULO, tp.DESCRIPCION AS PERMISO
        FROM GRUPO_MODULO gm
        INNER JOIN TIPO_PERMISO tp ON tp.IDTIPOPERMISO = gm.IDTIPOPERMISO
        WHERE gm.IDTIPOUSUARIO = @idtipousuario
    )
    SELECT
        m.IDMODULO,
        m.NOMBRE,
        m.DESCRIPCION,
        m.ICONO,
        m.ORDEN,
        STRING_AGG(pr.PERMISO, ',') WITHIN GROUP (ORDER BY pr.PERMISO) AS PERMISOS
    FROM PermisosRol pr
    INNER JOIN MODULO m ON m.IDMODULO = pr.IDMODULO AND m.ACTIVO = 1
    GROUP BY m.IDMODULO, m.NOMBRE, m.DESCRIPCION, m.ICONO, m.ORDEN
    ORDER BY m.ORDEN, m.NOMBRE;
END;
GO

IF OBJECT_ID('dbo.usp_modulo_asignar_rol', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_modulo_asignar_rol;
GO
CREATE PROCEDURE dbo.usp_modulo_asignar_rol
    @idtipousuario NVARCHAR(50),
    @idmodulo      NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM TIPOUSUARIO WHERE IDTIPOUSUARIO = @idtipousuario)
    BEGIN
        RAISERROR('Tipo de usuario no encontrado', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM MODULO WHERE IDMODULO = @idmodulo AND ACTIVO = 1)
    BEGIN
        RAISERROR('Módulo no encontrado o inactivo', 16, 1);
        RETURN;
    END

    DECLARE @perms TABLE (IDTIPOPERMISO NVARCHAR(50));
    INSERT INTO @perms VALUES ('TP001'), ('TP002'), ('TP003'), ('TP004');

    DECLARE @idpermiso NVARCHAR(50);
    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR SELECT IDTIPOPERMISO FROM @perms;
    OPEN cur;
    FETCH NEXT FROM cur INTO @idpermiso;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF NOT EXISTS (
            SELECT 1 FROM GRUPO_MODULO
            WHERE IDTIPOUSUARIO = @idtipousuario
              AND IDMODULO = @idmodulo
              AND IDTIPOPERMISO = @idpermiso
        )
        BEGIN
            INSERT INTO GRUPO_MODULO (IDGRUPOMODULO, IDTIPOUSUARIO, IDMODULO, IDTIPOPERMISO)
            VALUES (
                'GRM_' + REPLACE(CONVERT(NVARCHAR(36), NEWID()), '-', ''),
                @idtipousuario,
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

IF OBJECT_ID('dbo.usp_modulo_desasignar_rol', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_modulo_desasignar_rol;
GO
CREATE PROCEDURE dbo.usp_modulo_desasignar_rol
    @idtipousuario NVARCHAR(50),
    @idmodulo      NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    IF @idtipousuario = '3' AND @idmodulo IN ('MOD001', 'MOD008')
    BEGIN
        RAISERROR('No se puede quitar este módulo al rol Administrador (Dashboard y Administración de Módulos son obligatorios).', 16, 1);
        RETURN;
    END

    DELETE FROM GRUPO_MODULO
    WHERE IDTIPOUSUARIO = @idtipousuario AND IDMODULO = @idmodulo;

    DELETE gex
    FROM GRUPO_SUBMODULO_EXCLUIDO gex
    INNER JOIN SUBMODULO s ON s.IDSUBMODULO = gex.IDSUBMODULO
    WHERE gex.IDTIPOUSUARIO = @idtipousuario
      AND s.IDMODULO = @idmodulo;

    SELECT CAST(1 AS BIT) AS success;
END;
GO

IF OBJECT_ID('dbo.usp_submodulos_modulo_rol', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_submodulos_modulo_rol;
GO
CREATE PROCEDURE dbo.usp_submodulos_modulo_rol
    @idtipousuario NVARCHAR(50),
    @idmodulo      NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        s.IDSUBMODULO,
        s.NOMBRE,
        s.DESCRIPCION,
        s.ICONO,
        s.ORDEN,
        CAST(CASE WHEN ex.IDSUBMODULO IS NULL THEN 1 ELSE 0 END AS BIT) AS asignado
    FROM SUBMODULO s
    LEFT JOIN GRUPO_SUBMODULO_EXCLUIDO ex
        ON ex.IDSUBMODULO = s.IDSUBMODULO AND ex.IDTIPOUSUARIO = @idtipousuario
    WHERE s.IDMODULO = @idmodulo
      AND s.ACTIVO = 1
    ORDER BY s.ORDEN, s.NOMBRE;
END;
GO

IF OBJECT_ID('dbo.usp_submodulo_asignar_rol', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_submodulo_asignar_rol;
GO
CREATE PROCEDURE dbo.usp_submodulo_asignar_rol
    @idtipousuario NVARCHAR(50),
    @idsubmodulo   NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM GRUPO_SUBMODULO_EXCLUIDO
    WHERE IDTIPOUSUARIO = @idtipousuario AND IDSUBMODULO = @idsubmodulo;

    SELECT CAST(1 AS BIT) AS success;
END;
GO

IF OBJECT_ID('dbo.usp_submodulo_desasignar_rol', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_submodulo_desasignar_rol;
GO
CREATE PROCEDURE dbo.usp_submodulo_desasignar_rol
    @idtipousuario NVARCHAR(50),
    @idsubmodulo   NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1 FROM GRUPO_SUBMODULO_EXCLUIDO
        WHERE IDTIPOUSUARIO = @idtipousuario AND IDSUBMODULO = @idsubmodulo
    )
    BEGIN
        INSERT INTO GRUPO_SUBMODULO_EXCLUIDO (IDGRUPOEXCLSUB, IDTIPOUSUARIO, IDSUBMODULO, FECHAREGISTRO)
        VALUES (
            'GEXS_' + REPLACE(CONVERT(NVARCHAR(36), NEWID()), '-', ''),
            @idtipousuario,
            @idsubmodulo,
            dbo.fn_fecha_ddmmyyyy()
        );
    END

    SELECT CAST(1 AS BIT) AS success;
END;
GO

/* Actualizar SP de submódulos por usuario para considerar exclusiones del rol */
IF OBJECT_ID('dbo.usp_submodulos_modulo_usuario', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_submodulos_modulo_usuario;
GO
CREATE PROCEDURE dbo.usp_submodulos_modulo_usuario
    @idusuario NVARCHAR(50),
    @idmodulo  NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @idtipo NVARCHAR(50);
    SELECT @idtipo = IDTIPOUSUARIO
    FROM USUARIO
    WHERE IDUSUARIO = @idusuario AND ESTADO = 'Activo';

    SELECT
        s.IDSUBMODULO,
        s.NOMBRE,
        s.DESCRIPCION,
        s.ICONO,
        s.ORDEN,
        CAST(CASE
            WHEN ex_u.IDSUBMODULO IS NOT NULL THEN 0
            WHEN ex_g.IDSUBMODULO IS NOT NULL THEN 0
            ELSE 1
        END AS BIT) AS asignado
    FROM SUBMODULO s
    LEFT JOIN USUARIO_SUBMODULO_EXCLUIDO ex_u
        ON ex_u.IDSUBMODULO = s.IDSUBMODULO AND ex_u.IDUSUARIO = @idusuario
    LEFT JOIN GRUPO_SUBMODULO_EXCLUIDO ex_g
        ON ex_g.IDSUBMODULO = s.IDSUBMODULO AND ex_g.IDTIPOUSUARIO = @idtipo
    WHERE s.IDMODULO = @idmodulo
      AND s.ACTIVO = 1
    ORDER BY s.ORDEN, s.NOMBRE;
END;
GO

PRINT 'modulos_admin_rol.sql ejecutado correctamente';
GO
