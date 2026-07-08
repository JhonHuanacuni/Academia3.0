-- Stored procedure para validar credenciales en SQL Server.
-- Retorna is_valid = 1 si el usuario existe y la contraseña coincide.
-- Retorna role = 'usuario' | 'secretario' | 'admin'.

CREATE PROCEDURE dbo.usp_validate_user
    @username NVARCHAR(50),
    @password NVARCHAR(255)
AS
BEGIN

    DECLARE @idTipoUsuario NVARCHAR(50);
    SELECT @idTipoUsuario = idTipoUsuario
    FROM USUARIO
    WHERE idUsuario = @username
      AND contra = @password
      AND estado = 'Activo';

    IF @idTipoUsuario IS NOT NULL
    BEGIN
        SELECT
            CAST(1 AS BIT) AS is_valid,
            CASE @idTipoUsuario
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