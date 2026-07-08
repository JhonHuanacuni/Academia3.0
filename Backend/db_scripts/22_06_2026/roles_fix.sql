/* ============================================================================
   CORRECCIÓN DE ROLES — Estudiante, Docente, Administrador
   Ejecutar en BD ya creada (después de esquema_completo.sql)
   Fecha: 22/06/2026
   ============================================================================ */

UPDATE TIPOUSUARIO SET DESCRIPCION = 'Estudiante'    WHERE IDTIPOUSUARIO = '1';
UPDATE TIPOUSUARIO SET DESCRIPCION = 'Docente'       WHERE IDTIPOUSUARIO = '2';
UPDATE TIPOUSUARIO SET DESCRIPCION = 'Administrador' WHERE IDTIPOUSUARIO = '3';
GO

IF OBJECT_ID('dbo.usp_validate_user', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_validate_user;
GO

CREATE PROCEDURE dbo.usp_validate_user
    @username NVARCHAR(50),
    @password NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @IDTIPOUSUARIO NVARCHAR(50);

    SELECT @IDTIPOUSUARIO = IDTIPOUSUARIO
    FROM USUARIO
    WHERE IDUSUARIO = @username
      AND CONTRA    = @password
      AND ESTADO    = 'Activo';

    IF @IDTIPOUSUARIO IS NOT NULL
    BEGIN
        SELECT
            CAST(1 AS BIT) AS is_valid,
            CASE @IDTIPOUSUARIO
                WHEN '1' THEN 'estudiante'
                WHEN '2' THEN 'docente'
                WHEN '3' THEN 'administrador'
                ELSE 'estudiante'
            END AS role;
    END
    ELSE
    BEGIN
        SELECT
            CAST(0 AS BIT) AS is_valid,
            'estudiante' AS role;
    END
END;
GO

PRINT 'Roles actualizados: estudiante (1), docente (2), administrador (3)';
GO
