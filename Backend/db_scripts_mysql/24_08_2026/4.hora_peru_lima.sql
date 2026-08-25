-- Hora y fecha siempre en Perú (UTC-5, America/Lima).
-- El SP de asistencia convertía NOW() como si fuera UTC; si MySQL ya está en Lima, restaba 5 horas de más.
-- Fecha: 24/08/2026

USE `AcademiaDB`;

DROP FUNCTION IF EXISTS fn_hora_lima;
DROP FUNCTION IF EXISTS fn_fecha_ddmmyyyy;
DROP FUNCTION IF EXISTS fn_ahora_lima;

DELIMITER $$

CREATE FUNCTION fn_ahora_lima()
RETURNS DATETIME
DETERMINISTIC
NO SQL
BEGIN
    RETURN IFNULL(
        CONVERT_TZ(UTC_TIMESTAMP(), '+00:00', '-05:00'),
        DATE_SUB(UTC_TIMESTAMP(), INTERVAL 5 HOUR)
    );
END$$

CREATE FUNCTION fn_hora_lima()
RETURNS CHAR(8)
DETERMINISTIC
NO SQL
BEGIN
    RETURN TIME_FORMAT(fn_ahora_lima(), '%H:%i:%s');
END$$

CREATE FUNCTION fn_fecha_ddmmyyyy()
RETURNS CHAR(8)
DETERMINISTIC
NO SQL
BEGIN
    RETURN DATE_FORMAT(fn_ahora_lima(), '%d%m%Y');
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_asistencia_marcar;

DELIMITER $$

CREATE PROCEDURE usp_asistencia_marcar(
    IN p_Dni VARCHAR(20),
    IN p_IdRegistrador VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200),
    OUT p_IdAsistencia VARCHAR(50)
)
main: BEGIN
    DECLARE v_IdUsuario VARCHAR(50);
    DECLARE v_FechaHoy CHAR(8);
    DECLARE v_HoraAhora TIME;
    DECLARE v_Estado VARCHAR(50);
    DECLARE v_HoraEntrada TIME DEFAULT '08:00:00';
    DECLARE v_TiempoExtra INT DEFAULT 0;
    DECLARE v_HoraLimite TIME;

    SET v_FechaHoy = fn_fecha_ddmmyyyy();
    SET v_HoraAhora = CAST(fn_ahora_lima() AS TIME);

    SELECT IDUSUARIO INTO v_IdUsuario
    FROM USUARIO
    WHERE DNI = p_Dni AND ESTADO = 'Activo';

    IF v_IdUsuario IS NULL THEN
        SET p_Resultado = 0;
        SET p_Mensaje = 'Usuario no encontrado con ese DNI.';
        SET p_IdAsistencia = NULL;
        LEAVE main;
    END IF;

    IF EXISTS (
        SELECT 1 FROM ASISTENCIA
        WHERE IDUSUARIO = v_IdUsuario AND FECHAREGISTRO = v_FechaHoy
    ) THEN
        SET p_Resultado = 0;
        SET p_Mensaje = 'Este estudiante ya tiene su asistencia registrada para hoy.';
        SET p_IdAsistencia = NULL;
        LEAVE main;
    END IF;

    SELECT
        IFNULL(p.HORAENTRADA, CAST('08:00:00' AS TIME)),
        IFNULL(p.TIEMPOEXTRA, 0)
    INTO v_HoraEntrada, v_TiempoExtra
    FROM MENSUALIDAD m
    INNER JOIN `PLAN` p ON p.IDPLAN = m.IDPLAN
    WHERE m.IDUSUARIO = v_IdUsuario
      AND (m.ESTADO IS NULL OR m.ESTADO = 'Activo')
      AND (
          m.FECHAINICIO IS NULL OR m.FECHAINICIO = '' OR
          STR_TO_DATE(m.FECHAINICIO, '%d%m%Y') <= STR_TO_DATE(v_FechaHoy, '%d%m%Y')
      )
      AND (
          m.FECHAFIN IS NULL OR m.FECHAFIN = '' OR
          STR_TO_DATE(m.FECHAFIN, '%d%m%Y') >= STR_TO_DATE(v_FechaHoy, '%d%m%Y')
      )
    ORDER BY m.FECHAREGISTRO DESC, m.FECHAINICIO DESC
    LIMIT 1;

    SET v_HoraLimite = CAST(
        DATE_ADD(CAST(v_HoraEntrada AS DATETIME), INTERVAL v_TiempoExtra MINUTE) AS TIME
    );

    IF v_HoraAhora <= v_HoraLimite THEN
        SET v_Estado = 'Presente';
    ELSE
        SET v_Estado = 'Tarde';
    END IF;

    SET p_IdAsistencia = CONCAT('AS_', REPLACE(UUID(), '-', ''));

    INSERT INTO ASISTENCIA (
        IDASISTENCIA, FECHAREGISTRO, HORAINICIO, ESTADO, JUSTIFICADO, IDUSUARIO
    ) VALUES (
        p_IdAsistencia, v_FechaHoy,
        TIME_FORMAT(v_HoraAhora, '%H:%i:%s'),
        v_Estado, 0, v_IdUsuario
    );

    SET p_Resultado = 1;
    SET p_Mensaje = 'Asistencia registrada.';
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_justificacion_insertar;

DELIMITER $$

CREATE PROCEDURE usp_justificacion_insertar(
    IN p_IdUsuario VARCHAR(50),
    IN p_Fecha CHAR(8),
    IN p_IdRegistrador VARCHAR(50),
    IN p_Observacion VARCHAR(500),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
    DECLARE v_Next INT DEFAULT 0;
    DECLARE v_Id VARCHAR(50);
    DECLARE v_Hora CHAR(8);

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

    IF EXISTS (SELECT 1 FROM JUSTIFICACION WHERE IDUSUARIO = p_IdUsuario AND FECHA = p_Fecha) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ya existe una justificación para ese estudiante en esa fecha.';
        LEAVE main;
    END IF;

    SELECT IFNULL(MAX(CAST(REPLACE(IDJUSTIFICACION, 'JUS', '') AS UNSIGNED)), 0) + 1 INTO v_Next
    FROM JUSTIFICACION WHERE IDJUSTIFICACION LIKE 'JUS%';
    SET v_Id = CONCAT('JUS', LPAD(CAST(v_Next AS CHAR), 3, '0'));

    SET v_Hora = fn_hora_lima();

    INSERT INTO JUSTIFICACION (IDJUSTIFICACION, IDUSUARIO, FECHA, HORAREGISTRO, IDREGISTRADOR, OBSERVACION, FECHACREACION)
    VALUES (v_Id, p_IdUsuario, p_Fecha, v_Hora, NULLIF(TRIM(p_IdRegistrador), ''), NULLIF(TRIM(p_Observacion), ''), fn_fecha_ddmmyyyy());

    IF EXISTS (SELECT 1 FROM ASISTENCIA WHERE IDUSUARIO = p_IdUsuario AND FECHAREGISTRO = p_Fecha) THEN
        UPDATE ASISTENCIA SET JUSTIFICADO = 1 WHERE IDUSUARIO = p_IdUsuario AND FECHAREGISTRO = p_Fecha;
    ELSE
        INSERT INTO ASISTENCIA (IDASISTENCIA, FECHAREGISTRO, HORAINICIO, ESTADO, JUSTIFICADO, IDUSUARIO)
        VALUES (CONCAT('AS_', REPLACE(UUID(), '-', '')), p_Fecha, v_Hora, 'Falta', 1, p_IdUsuario);
    END IF;

    SET p_Resultado = 1; SET p_Mensaje = 'Justificación registrada.';
END$$

DELIMITER ;

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
            SET v_Hora = fn_hora_lima();
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

SELECT 'Hora Perú (America/Lima, UTC-5) aplicada a fecha, asistencia y justificación.' AS info;
