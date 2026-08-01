-- Convertido automáticamente desde db_scripts/07_05_2026/SPs.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

ALTER PROCEDURE usp_validate_user
    @username VARCHAR(50),
    @password VARCHAR(255)
AS
BEGIN

    DECLARE @IDTIPOUSUARIO VARCHAR(50);

    SELECT @IDTIPOUSUARIO = IDTIPOUSUARIO
    FROM USUARIO
    WHERE IDUSUARIO = @username
      AND CONTRA = @password
      AND ESTADO = 'Activo';

    IF @IDTIPOUSUARIO IS NOT NULL
    BEGIN
        SELECT
            1 AS is_valid,
            CASE @IDTIPOUSUARIO
                WHEN '1' THEN 'estudiante'
                WHEN '2' THEN 'docente'
                WHEN '3' THEN 'administrador'
                ELSE 'estudiante'
            END AS role;
    
    ELSE
    BEGIN
        SELECT
            0 AS is_valid,
            'estudiante' AS role;
    
END;
