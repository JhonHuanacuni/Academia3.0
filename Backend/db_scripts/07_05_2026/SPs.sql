
GO
ALTER PROCEDURE dbo.usp_validate_user
    @username NVARCHAR(50),
    @password NVARCHAR(255)
AS
BEGIN

    DECLARE @IDTIPOUSUARIO NVARCHAR(50);

    SELECT @IDTIPOUSUARIO = IDTIPOUSUARIO
    FROM USUARIO
    WHERE IDUSUARIO = @username
      AND CONTRA = @password
      AND ESTADO = 'Activo';

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