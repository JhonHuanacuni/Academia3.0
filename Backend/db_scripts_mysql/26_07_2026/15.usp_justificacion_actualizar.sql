-- ============================================================================
-- usp_justificacion_actualizar — MySQL 8
-- Ejecutar después de 14.justificacion.sql
-- Fecha: 27/07/2026
-- ============================================================================

USE `AcademiaDB`;

DROP PROCEDURE IF EXISTS usp_justificacion_actualizar;

DELIMITER $$

CREATE PROCEDURE usp_justificacion_actualizar(
    IN p_Id VARCHAR(50),
    IN p_IdUsuario VARCHAR(50),
    IN p_Fecha CHAR(8),
    IN p_Observacion VARCHAR(500),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
    DECLARE v_OldUsuario VARCHAR(50);
    DECLARE v_OldFecha CHAR(8);
    DECLARE v_Hora CHAR(8);

    IF NOT EXISTS (SELECT 1 FROM JUSTIFICACION WHERE IDJUSTIFICACION = p_Id) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'La justificación no existe.';
        LEAVE main;
    END IF;

    IF p_IdUsuario IS NULL OR TRIM(p_IdUsuario) = '' THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Selecciona un estudiante.';
        LEAVE main;
    END IF;

    IF p_Fecha IS NULL OR TRIM(p_Fecha) = '' THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Selecciona la fecha a justificar.';
        LEAVE main;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM USUARIO WHERE IDUSUARIO = p_IdUsuario AND ESTADO = 'Activo') THEN
        SET p_Resultado = 0; SET p_Mensaje = 'El estudiante no existe o está inactivo.';
        LEAVE main;
    END IF;

    SELECT IDUSUARIO, FECHA INTO v_OldUsuario, v_OldFecha
    FROM JUSTIFICACION WHERE IDJUSTIFICACION = p_Id;

    IF EXISTS (
        SELECT 1 FROM JUSTIFICACION
        WHERE IDUSUARIO = p_IdUsuario AND FECHA = p_Fecha AND IDJUSTIFICACION <> p_Id
    ) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ya existe una justificación para ese estudiante en esa fecha.';
        LEAVE main;
    END IF;

    UPDATE JUSTIFICACION SET
        IDUSUARIO   = p_IdUsuario,
        FECHA       = p_Fecha,
        OBSERVACION = NULLIF(TRIM(p_Observacion), '')
    WHERE IDJUSTIFICACION = p_Id;

    IF v_OldUsuario <> p_IdUsuario OR v_OldFecha <> p_Fecha THEN
        IF EXISTS (
            SELECT 1 FROM ASISTENCIA
            WHERE IDUSUARIO = v_OldUsuario AND FECHAREGISTRO = v_OldFecha
              AND ESTADO = 'Falta' AND JUSTIFICADO = 1
        ) AND NOT EXISTS (
            SELECT 1 FROM ASISTENCIA
            WHERE IDUSUARIO = v_OldUsuario AND FECHAREGISTRO = v_OldFecha
              AND (ESTADO <> 'Falta' OR JUSTIFICADO = 0)
        ) THEN
            DELETE FROM ASISTENCIA
            WHERE IDUSUARIO = v_OldUsuario AND FECHAREGISTRO = v_OldFecha AND ESTADO = 'Falta';
        ELSEIF EXISTS (
            SELECT 1 FROM ASISTENCIA
            WHERE IDUSUARIO = v_OldUsuario AND FECHAREGISTRO = v_OldFecha
        ) THEN
            UPDATE ASISTENCIA SET JUSTIFICADO = 0
            WHERE IDUSUARIO = v_OldUsuario AND FECHAREGISTRO = v_OldFecha;
        END IF;

        IF EXISTS (
            SELECT 1 FROM ASISTENCIA
            WHERE IDUSUARIO = p_IdUsuario AND FECHAREGISTRO = p_Fecha
        ) THEN
            UPDATE ASISTENCIA SET JUSTIFICADO = 1
            WHERE IDUSUARIO = p_IdUsuario AND FECHAREGISTRO = p_Fecha;
        ELSE
            SET v_Hora = TIME_FORMAT(CONVERT_TZ(NOW(), '+00:00', '-05:00'), '%H:%i:%s');
            INSERT INTO ASISTENCIA (IDASISTENCIA, FECHAREGISTRO, HORAINICIO, ESTADO, JUSTIFICADO, IDUSUARIO)
            VALUES (CONCAT('AS_', REPLACE(UUID(), '-', '')), p_Fecha, v_Hora, 'Falta', 1, p_IdUsuario);
        END IF;
    ELSEIF EXISTS (
        SELECT 1 FROM ASISTENCIA
        WHERE IDUSUARIO = p_IdUsuario AND FECHAREGISTRO = p_Fecha
    ) THEN
        UPDATE ASISTENCIA SET JUSTIFICADO = 1
        WHERE IDUSUARIO = p_IdUsuario AND FECHAREGISTRO = p_Fecha;
    END IF;

    SET p_Resultado = 1; SET p_Mensaje = 'Justificación actualizada.';
END$$

DELIMITER ;

SELECT 'usp_justificacion_actualizar listo.' AS info;
