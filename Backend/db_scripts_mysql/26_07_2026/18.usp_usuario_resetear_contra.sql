-- Convertido automáticamente desde db_scripts/26_07_2026/18.usp_usuario_resetear_contra.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   usp_usuario_resetear_contra — contraseña = DNI
   Ejecutar después de 17.mensualidad_filtro_deuda.sql
   Fecha: 27/07/2026
   ============================================================================ */

DROP PROCEDURE IF EXISTS usp_usuario_resetear_contra;

DROP PROCEDURE IF EXISTS usp_usuario_resetear_contra;

DELIMITER $$

CREATE PROCEDURE usp_usuario_resetear_contra(
    IN p_Id VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
IF NOT EXISTS (SELECT 1 FROM USUARIO WHERE IDUSUARIO = p_Id)
    BEGIN
        SET p_Resultado = 0; SET p_Mensaje = 'El usuario no existe.';
        LEAVE main;
    
    UPDATE USUARIO SET CONTRA = DNI WHERE IDUSUARIO = p_Id;

    SET p_Resultado = 1; SET p_Mensaje = 'Contraseña restablecida al DNI.';
END;

SELECT 'usp_usuario_resetear_contra listo.';
    SELECT p_Resultado AS Resultado, p_Mensaje AS Mensaje
END$$

DELIMITER ;
