-- Convertido automáticamente desde db_scripts/26_07_2026/16.usuario_estado_retirado.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   USUARIO: estado Inactivo -> Retirado
   Ejecutar después de 15.usp_justificacion_actualizar.sql
   Fecha: 27/07/2026
   ============================================================================ */

UPDATE USUARIO SET ESTADO = 'Retirado' WHERE ESTADO = 'Inactivo';

DROP PROCEDURE IF EXISTS usp_usuario_eliminar;

DROP PROCEDURE IF EXISTS usp_usuario_eliminar;

DELIMITER $$

CREATE PROCEDURE usp_usuario_eliminar(
    IN p_Id VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
IF NOT EXISTS (SELECT 1 FROM USUARIO WHERE IDUSUARIO = p_Id) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'El usuario no existe.';
        LEAVE main;
    
    UPDATE USUARIO SET ESTADO = 'Retirado' WHERE IDUSUARIO = p_Id;

    SET p_Resultado = 1; SET p_Mensaje = 'Usuario retirado.';
END;

SELECT 'USUARIO: estado Retirado aplicado (CONCAT(datos, usp_usuario_eliminar)).';
    SELECT p_Resultado AS Resultado, p_Mensaje AS Mensaje
END$$

DELIMITER ;