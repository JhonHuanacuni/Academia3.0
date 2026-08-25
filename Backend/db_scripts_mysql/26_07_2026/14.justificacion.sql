-- ============================================================================
-- Justificación de asistencias — tabla + SPs CRUD — MySQL 8
-- Ejecutar después de 13.mantenedores_codigo_autogenerado.sql
-- Fecha: 26/07/2026
-- ============================================================================

USE `AcademiaDB`;

CREATE TABLE IF NOT EXISTS JUSTIFICACION (
    IDJUSTIFICACION VARCHAR(50)  NOT NULL PRIMARY KEY,
    IDUSUARIO       VARCHAR(50)  NOT NULL,
    FECHA           CHAR(8)       NOT NULL,
    HORAREGISTRO    CHAR(8)       NOT NULL,
    IDREGISTRADOR   VARCHAR(50)  NULL,
    OBSERVACION     VARCHAR(500) NULL,
    FECHACREACION   CHAR(8)       NOT NULL,
    CONSTRAINT FK_JUSTIFICACION_USUARIO FOREIGN KEY (IDUSUARIO) REFERENCES USUARIO(IDUSUARIO),
    CONSTRAINT FK_JUSTIFICACION_REGISTRADOR FOREIGN KEY (IDREGISTRADOR) REFERENCES USUARIO(IDUSUARIO)
);

CREATE INDEX IX_JUSTIFICACION_USUARIO_FECHA ON JUSTIFICACION(IDUSUARIO, FECHA);

DROP PROCEDURE IF EXISTS usp_justificacion_listar;

DELIMITER $$

CREATE PROCEDURE usp_justificacion_listar(
    IN p_Buscar VARCHAR(200),
    IN p_Pagina INT,
    IN p_TamanioPagina INT,
    OUT p_TotalRegistros INT
)
main: BEGIN
    DECLARE v_offset INT DEFAULT 0;

    IF p_Pagina < 1 THEN SET p_Pagina = 1; END IF;
    IF p_TamanioPagina < 1 THEN SET p_TamanioPagina = 10; END IF;
    SET v_offset = (p_Pagina - 1) * p_TamanioPagina;

    SELECT COUNT(*) INTO p_TotalRegistros
    FROM JUSTIFICACION j
    INNER JOIN USUARIO est ON est.IDUSUARIO = j.IDUSUARIO
    LEFT JOIN USUARIO reg ON reg.IDUSUARIO = j.IDREGISTRADOR
    WHERE p_Buscar IS NULL OR p_Buscar = ''
       OR est.DNI LIKE CONCAT('%', p_Buscar, '%')
       OR est.NOMBRE LIKE CONCAT('%', p_Buscar, '%')
       OR est.APELLIDO LIKE CONCAT('%', p_Buscar, '%')
       OR j.OBSERVACION LIKE CONCAT('%', p_Buscar, '%')
       OR reg.NOMBRE LIKE CONCAT('%', p_Buscar, '%')
       OR reg.APELLIDO LIKE CONCAT('%', p_Buscar, '%');

    SELECT
        j.IDJUSTIFICACION,
        j.IDUSUARIO,
        j.FECHA,
        j.HORAREGISTRO,
        j.IDREGISTRADOR,
        j.OBSERVACION,
        est.NOMBRE AS ESTUDIANTE_NOMBRE,
        est.APELLIDO AS ESTUDIANTE_APELLIDO,
        est.DNI,
        TRIM(CONCAT(IFNULL(reg.NOMBRE, ''), ' ', IFNULL(reg.APELLIDO, ''))) AS REGISTRADOR_NOMBRE
    FROM JUSTIFICACION j
    INNER JOIN USUARIO est ON est.IDUSUARIO = j.IDUSUARIO
    LEFT JOIN USUARIO reg ON reg.IDUSUARIO = j.IDREGISTRADOR
    WHERE p_Buscar IS NULL OR p_Buscar = ''
       OR est.DNI LIKE CONCAT('%', p_Buscar, '%')
       OR est.NOMBRE LIKE CONCAT('%', p_Buscar, '%')
       OR est.APELLIDO LIKE CONCAT('%', p_Buscar, '%')
       OR j.OBSERVACION LIKE CONCAT('%', p_Buscar, '%')
       OR reg.NOMBRE LIKE CONCAT('%', p_Buscar, '%')
       OR reg.APELLIDO LIKE CONCAT('%', p_Buscar, '%')
    ORDER BY j.FECHA DESC, j.HORAREGISTRO DESC
    LIMIT p_TamanioPagina OFFSET v_offset;
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_justificacion_obtener;

DELIMITER $$

CREATE PROCEDURE usp_justificacion_obtener(IN p_Id VARCHAR(50))
main: BEGIN
    SELECT
        j.IDJUSTIFICACION,
        j.IDUSUARIO,
        j.FECHA,
        j.HORAREGISTRO,
        j.IDREGISTRADOR,
        j.OBSERVACION,
        est.NOMBRE AS ESTUDIANTE_NOMBRE,
        est.APELLIDO AS ESTUDIANTE_APELLIDO,
        est.DNI,
        TRIM(CONCAT(IFNULL(reg.NOMBRE, ''), ' ', IFNULL(reg.APELLIDO, ''))) AS REGISTRADOR_NOMBRE
    FROM JUSTIFICACION j
    INNER JOIN USUARIO est ON est.IDUSUARIO = j.IDUSUARIO
    LEFT JOIN USUARIO reg ON reg.IDUSUARIO = j.IDREGISTRADOR
    WHERE j.IDJUSTIFICACION = p_Id;
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

    SET v_Hora = TIME_FORMAT(IFNULL(
        CONVERT_TZ(UTC_TIMESTAMP(), '+00:00', '-05:00'),
        DATE_SUB(UTC_TIMESTAMP(), INTERVAL 5 HOUR)
    ), '%H:%i:%s');

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

DROP PROCEDURE IF EXISTS usp_justificacion_eliminar;

DELIMITER $$

CREATE PROCEDURE usp_justificacion_eliminar(
    IN p_Id VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
    DECLARE v_IdUsuario VARCHAR(50);
    DECLARE v_Fecha CHAR(8);

    IF NOT EXISTS (SELECT 1 FROM JUSTIFICACION WHERE IDJUSTIFICACION = p_Id) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'La justificación no existe.';
        LEAVE main;
    END IF;

    SELECT IDUSUARIO, FECHA INTO v_IdUsuario, v_Fecha
    FROM JUSTIFICACION WHERE IDJUSTIFICACION = p_Id;

    DELETE FROM JUSTIFICACION WHERE IDJUSTIFICACION = p_Id;

    IF EXISTS (SELECT 1 FROM ASISTENCIA WHERE IDUSUARIO = v_IdUsuario AND FECHAREGISTRO = v_Fecha AND ESTADO = 'Falta') THEN
        DELETE FROM ASISTENCIA WHERE IDUSUARIO = v_IdUsuario AND FECHAREGISTRO = v_Fecha AND ESTADO = 'Falta';
    ELSEIF EXISTS (SELECT 1 FROM ASISTENCIA WHERE IDUSUARIO = v_IdUsuario AND FECHAREGISTRO = v_Fecha) THEN
        UPDATE ASISTENCIA SET JUSTIFICADO = 0 WHERE IDUSUARIO = v_IdUsuario AND FECHAREGISTRO = v_Fecha;
    END IF;

    SET p_Resultado = 1; SET p_Mensaje = 'Justificación eliminada.';
END$$

DELIMITER ;

-- Submódulo menú (visible si el usuario tiene acceso a MOD003 Asistencias)
INSERT INTO SUBMODULO (IDSUBMODULO, NOMBRE, DESCRIPCION, ICONO, ORDEN, ACTIVO, IDMODULO)
VALUES ('SUB025', 'Justificación', 'Justificar inasistencias o tardanzas', 'faFilePen', 3, 1, 'MOD003')
ON DUPLICATE KEY UPDATE
    NOMBRE = VALUES(NOMBRE),
    DESCRIPCION = VALUES(DESCRIPCION),
    ICONO = VALUES(ICONO),
    ORDEN = VALUES(ORDEN),
    ACTIVO = VALUES(ACTIVO),
    IDMODULO = VALUES(IDMODULO);

SELECT 'Justificación: tabla, SPs y menú SUB025 listos.' AS info;
