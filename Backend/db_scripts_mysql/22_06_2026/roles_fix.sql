-- Convertido automáticamente desde db_scripts/22_06_2026/roles_fix.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   CORRECCIÓN DE ROLES — Estudiante, Docente, Administrador
   Ejecutar en BD ya creada (después de esquema_completo.sql)
   Fecha: 22/06/2026
   ============================================================================ */

UPDATE TIPOUSUARIO SET DESCRIPCION = 'Estudiante'    WHERE IDTIPOUSUARIO = '1';
UPDATE TIPOUSUARIO SET DESCRIPCION = 'Docente'       WHERE IDTIPOUSUARIO = '2';
UPDATE TIPOUSUARIO SET DESCRIPCION = 'Administrador' WHERE IDTIPOUSUARIO = '3';

DROP PROCEDURE IF EXISTS usp_validate_user;

DROP PROCEDURE IF EXISTS usp_validate_user;

DELIMITER $$

CREATE PROCEDURE usp_validate_user(
    IN p_username VARCHAR(50),
    IN p_password VARCHAR(255)
)
main: BEGIN
DECLARE v_IDTIPOUSUARIO VARCHAR(50);

    SELECT IDTIPOUSUARIO INTO v_IDTIPOUSUARIO
    FROM USUARIO
    WHERE IDUSUARIO = p_username
      AND CONTRA    = p_password
      AND ESTADO    = 'Activo';

    IF v_IDTIPOUSUARIO IS NOT NULL
    BEGIN
        SELECT
            1 AS is_valid,
            CASE v_IDTIPOUSUARIO
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

SELECT 'Roles actualizados: estudiante (1), docente (2), administrador (3)';
END$$

DELIMITER ;
