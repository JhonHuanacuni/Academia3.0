-- Convertido automáticamente desde db_scripts/05_05_2026/Sps.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

-- Stored procedure para validar credenciales en SQL Server.
-- Retorna is_valid = 1 si el usuario existe y la contraseña coincide.
-- Retorna role = 'usuario' | 'secretario' | 'admin'.

DROP PROCEDURE IF EXISTS usp_validate_user;

DELIMITER $$

CREATE PROCEDURE usp_validate_user(
    IN p_username VARCHAR(50),
    IN p_password VARCHAR(255)
)
main: BEGIN
DECLARE v_idTipoUsuario VARCHAR(50);
    SELECT idTipoUsuario INTO v_idTipoUsuario
    FROM USUARIO
    WHERE idUsuario = p_username
      AND contra = p_password
      AND estado = 'Activo';

    IF v_idTipoUsuario IS NOT NULL
    BEGIN
        SELECT
            1 AS is_valid,
            CASE v_idTipoUsuario
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
END$$

DELIMITER ;
