-- Convertido automáticamente desde db_scripts/06_07_2026/9.usp_membresia_eliminar_roles.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   Eliminar membresía: admin = borrado físico, demás roles = desactivar
   Ejecutar después de 8.usp_membresia_listar_activos.sql
   Fecha: 06/07/2026
   ============================================================================ */

DROP PROCEDURE IF EXISTS usp_membresia_eliminar;

DROP PROCEDURE IF EXISTS usp_membresia_eliminar;

DELIMITER $$

CREATE PROCEDURE usp_membresia_eliminar(
    IN p_Id VARCHAR(50),
    IN p_EliminacionFisica TINYINT(1),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
IF NOT EXISTS (SELECT 1 FROM MEMBRESIA WHERE IDMEMBRESIA = p_Id) THEN
        SET p_Resultado = 0;
        SET p_Mensaje = 'La membresía no existe.';
        LEAVE main;
    
    END IF;

    IF p_EliminacionFisica = 1 THEN
        DELETE FROM NOTIFICACIONMEMBRESIA WHERE IDMEMBRESIA = p_Id;
        DELETE FROM PAGOMEMBRESIA WHERE IDMEMBRESIA = p_Id;
        DELETE FROM MEMBRESIA WHERE IDMEMBRESIA = p_Id;
        SET p_Resultado = 1;
        SET p_Mensaje = 'Membresía eliminada permanentemente.';
        LEAVE main;
    
    UPDATE MEMBRESIA
    SET ESTADO = 'Inactivo', ESTADOMIEMBRO = 4
    WHERE IDMEMBRESIA = p_Id;

    SET p_Resultado = 1;
    SET p_Mensaje = 'Membresía desactivada.';
END;

SELECT 'usp_membresia_eliminar actualizado: físico (admin) o desactivar (otros roles).';
    SELECT p_Resultado AS Resultado, p_Mensaje AS Mensaje
END$$

DELIMITER ;