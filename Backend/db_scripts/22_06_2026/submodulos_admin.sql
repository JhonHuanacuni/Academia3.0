/* ============================================================================
   PERMISOS POR SUBMÓDULO — control granular por usuario
   Ejecutar después de modulos_admin.sql
   Fecha: 22/06/2026
   ============================================================================ */

IF OBJECT_ID('dbo.USUARIO_SUBMODULO_EXCLUIDO', 'U') IS NULL
BEGIN
    CREATE TABLE USUARIO_SUBMODULO_EXCLUIDO (
        IDUSUARIOEXCLSUB  NVARCHAR(50)  NOT NULL PRIMARY KEY,
        IDUSUARIO         NVARCHAR(50)  NOT NULL,
        IDSUBMODULO       NVARCHAR(50)  NOT NULL,
        FECHAREGISTRO     CHAR(8)       NULL,
        CONSTRAINT FK_UEXCLSUB_USUARIO FOREIGN KEY (IDUSUARIO) REFERENCES USUARIO(IDUSUARIO),
        CONSTRAINT FK_UEXCLSUB_SUB     FOREIGN KEY (IDSUBMODULO) REFERENCES SUBMODULO(IDSUBMODULO),
        CONSTRAINT UQ_USUARIO_SUBMODULO_EXCL UNIQUE (IDUSUARIO, IDSUBMODULO)
    );
END
GO

IF OBJECT_ID('dbo.usp_submodulos_modulo_usuario', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_submodulos_modulo_usuario;
GO
CREATE PROCEDURE dbo.usp_submodulos_modulo_usuario
    @idusuario NVARCHAR(50),
    @idmodulo  NVARCHAR(50)
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
    LEFT JOIN USUARIO_SUBMODULO_EXCLUIDO ex
        ON ex.IDSUBMODULO = s.IDSUBMODULO AND ex.IDUSUARIO = @idusuario
    WHERE s.IDMODULO = @idmodulo
      AND s.ACTIVO = 1
    ORDER BY s.ORDEN, s.NOMBRE;
END;
GO

IF OBJECT_ID('dbo.usp_submodulo_asignar_usuario', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_submodulo_asignar_usuario;
GO
CREATE PROCEDURE dbo.usp_submodulo_asignar_usuario
    @idusuario   NVARCHAR(50),
    @idsubmodulo NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM USUARIO_SUBMODULO_EXCLUIDO
    WHERE IDUSUARIO = @idusuario AND IDSUBMODULO = @idsubmodulo;

    SELECT CAST(1 AS BIT) AS success;
END;
GO

IF OBJECT_ID('dbo.usp_submodulo_desasignar_usuario', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_submodulo_desasignar_usuario;
GO
CREATE PROCEDURE dbo.usp_submodulo_desasignar_usuario
    @idusuario   NVARCHAR(50),
    @idsubmodulo NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1 FROM USUARIO_SUBMODULO_EXCLUIDO
        WHERE IDUSUARIO = @idusuario AND IDSUBMODULO = @idsubmodulo
    )
    BEGIN
        INSERT INTO USUARIO_SUBMODULO_EXCLUIDO (IDUSUARIOEXCLSUB, IDUSUARIO, IDSUBMODULO, FECHAREGISTRO)
        VALUES (
            'EXS_' + REPLACE(CONVERT(NVARCHAR(36), NEWID()), '-', ''),
            @idusuario,
            @idsubmodulo,
            dbo.fn_fecha_ddmmyyyy()
        );
    END

    SELECT CAST(1 AS BIT) AS success;
END;
GO

PRINT 'submodulos_admin.sql ejecutado correctamente';
GO
