-- ============================================================================
-- Eliminar membresía: admin = físico, demás = desactivar — MySQL 8
-- ============================================================================

USE `AcademiaDB`;

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
    END IF;

    UPDATE MEMBRESIA
    SET ESTADO = 'Inactivo', ESTADOMIEMBRO = 4
    WHERE IDMEMBRESIA = p_Id;

    SET p_Resultado = 1;
    SET p_Mensaje = 'Membresía desactivada.';
END$$

DELIMITER ;

SELECT 'usp_membresia_eliminar actualizado.' AS info;
