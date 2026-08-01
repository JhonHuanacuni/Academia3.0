-- ============================================================================
-- USUARIO eliminar: retiro (soft) vs eliminación física — MySQL 8
-- Fecha: 31/07/2026
-- ============================================================================

USE `AcademiaDB`;

DROP PROCEDURE IF EXISTS usp_usuario_eliminar;

DELIMITER $$

CREATE PROCEDURE usp_usuario_eliminar(
    IN p_Id VARCHAR(50),
    IN p_EliminacionFisica TINYINT(1),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_Resultado = 0;
        SET p_Mensaje = 'Error al eliminar usuario.';
    END;

    IF NOT EXISTS (SELECT 1 FROM USUARIO WHERE IDUSUARIO = p_Id) THEN
        SET p_Resultado = 0;
        SET p_Mensaje = 'El usuario no existe.';
        LEAVE main;
    END IF;

    IF p_EliminacionFisica = 0 THEN
        UPDATE USUARIO SET ESTADO = 'Retirado' WHERE IDUSUARIO = p_Id;
        SET p_Resultado = 1;
        SET p_Mensaje = 'Usuario retirado.';
        LEAVE main;
    END IF;

    IF EXISTS (SELECT 1 FROM USUARIO WHERE IDUSUARIO = p_Id AND IDTIPOUSUARIO = '3') THEN
        SET p_Resultado = 0;
        SET p_Mensaje = 'No se puede eliminar permanentemente a un administrador.';
        LEAVE main;
    END IF;

    IF EXISTS (SELECT 1 FROM EXAMEN WHERE IDUSUARIO = p_Id) THEN
        SET p_Resultado = 0;
        SET p_Mensaje = 'No se puede eliminar: el usuario tiene exámenes registrados como autor.';
        LEAVE main;
    END IF;

    START TRANSACTION;

    UPDATE MENSUALIDAD SET REGISTRADOPOR = NULL WHERE REGISTRADOPOR = p_Id;
    UPDATE PAGOMENSUALIDAD SET IDUSUARIO = NULL WHERE IDUSUARIO = p_Id;

    DELETE FROM JUSTIFICACION WHERE IDUSUARIO = p_Id;
    UPDATE JUSTIFICACION SET IDREGISTRADOR = NULL WHERE IDREGISTRADOR = p_Id;

    DELETE FROM ASISTENCIA WHERE IDUSUARIO = p_Id;

    DELETE ra FROM RESPUESTA_ALUMNO ra
    INNER JOIN INTENTO_EXAMEN i ON i.IDINTENTOEXAMEN = ra.IDINTENTOEXAMEN
    WHERE i.IDUSUARIO = p_Id;
    DELETE FROM INTENTO_EXAMEN WHERE IDUSUARIO = p_Id;

    DELETE FROM NOTA_IMPORTADA WHERE IDUSUARIO = p_Id;

    DELETE n FROM NOTIFICACIONMENSUALIDAD n
    INNER JOIN MENSUALIDAD m ON m.IDMENSUALIDAD = n.IDMENSUALIDAD
    WHERE m.IDUSUARIO = p_Id;

    DELETE p FROM PAGOMENSUALIDAD p
    INNER JOIN MENSUALIDAD m ON m.IDMENSUALIDAD = p.IDMENSUALIDAD
    WHERE m.IDUSUARIO = p_Id;

    DELETE FROM MENSUALIDAD WHERE IDUSUARIO = p_Id;
    DELETE FROM PAGOEXTRAORDINARIO WHERE IDUSUARIO = p_Id;
    DELETE FROM ASESOR WHERE IDUSUARIO = p_Id;
    DELETE FROM USUARIO_MODULO WHERE IDUSUARIO = p_Id;
    DELETE FROM USUARIO_MODULO_EXCLUIDO WHERE IDUSUARIO = p_Id;
    DELETE FROM USUARIO_SUBMODULO_EXCLUIDO WHERE IDUSUARIO = p_Id;

    DELETE FROM USUARIO WHERE IDUSUARIO = p_Id;

    COMMIT;
    SET p_Resultado = 1;
    SET p_Mensaje = 'Usuario eliminado.';
END$$

DELIMITER ;

SELECT 'usp_usuario_eliminar actualizado.' AS info;
