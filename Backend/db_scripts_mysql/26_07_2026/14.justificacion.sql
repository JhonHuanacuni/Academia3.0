-- Convertido automáticamente desde db_scripts/26_07_2026/14.justificacion.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   Justificación de asistencias — CONCAT(tabla, SPs) CRUD
   Ejecutar después de 13.mantenedores_codigo_autogenerado.sql
   Fecha: 26/07/2026
   ============================================================================ */

-- create if missing JUSTIFICACION
    CREATE TABLE IF NOT EXISTS JUSTIFICACION (
        IDJUSTIFICACION VARCHAR(50)  NOT NULL PRIMARY KEY,
        IDUSUARIO       VARCHAR(50)  NOT NULL,
        FECHA           CHAR(8)       NOT NULL,
        HORAREGISTRO    CHAR(8)       NOT NULL,
        IDREGISTRADOR   VARCHAR(50)  NULL,
        OBSERVACION     VARCHAR(500) NULL,
        FECHACREACION   CHAR(8)       NOT NULL DEFAULT fn_fecha_ddmmyyyy(),
        CONSTRAINT FK_JUSTIFICACION_USUARIO FOREIGN KEY (IDUSUARIO) REFERENCES USUARIO(IDUSUARIO),
        CONSTRAINT FK_JUSTIFICACION_REGISTRADOR FOREIGN KEY (IDREGISTRADOR) REFERENCES USUARIO(IDUSUARIO)
    );
    CREATE INDEX IX_JUSTIFICACION_USUARIO_FECHA ON JUSTIFICACION(IDUSUARIO, FECHA);

DROP PROCEDURE IF EXISTS usp_justificacion_listar;

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
        TRIM(CONCAT(IFNULL(reg.NOMBRE, ''), ' ') + IFNULL(reg.APELLIDO, ''))) AS REGISTRADOR_NOMBRE
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
    SELECT p_TotalRegistros AS TotalRegistros
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_justificacion_obtener;

DROP PROCEDURE IF EXISTS usp_justificacion_obtener;

DELIMITER $$

CREATE PROCEDURE usp_justificacion_obtener(
    IN p_Id VARCHAR(50)
)
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
        TRIM(CONCAT(IFNULL(reg.NOMBRE, ''), ' ') + IFNULL(reg.APELLIDO, ''))) AS REGISTRADOR_NOMBRE
    FROM JUSTIFICACION j
    INNER JOIN USUARIO est ON est.IDUSUARIO = j.IDUSUARIO
    LEFT JOIN USUARIO reg ON reg.IDUSUARIO = j.IDREGISTRADOR
    WHERE j.IDJUSTIFICACION = p_Id;
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_justificacion_insertar;

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
IF p_IdUsuario IS NULL OR TRIM(p_IdUsuario) = ''
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'Selecciona un estudiante.'; LEAVE main; 
    END IF;

    IF p_Fecha IS NULL OR TRIM(p_Fecha) = ''
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'Selecciona la fecha a justificar.'; LEAVE main; 
    END IF;

    IF NOT EXISTS (SELECT 1 FROM USUARIO WHERE IDUSUARIO = p_IdUsuario AND ESTADO = 'Activo')
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'El estudiante no existe o está inactivo.'; LEAVE main; 
    END IF;

    IF EXISTS (SELECT 1 FROM JUSTIFICACION WHERE IDUSUARIO = p_IdUsuario AND FECHA = p_Fecha)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'Ya existe una justificación para ese estudiante en esa fecha.'; LEAVE main; 
    DECLARE v_Id VARCHAR(50);
    DECLARE v_Next INT = IFNULL((
        SELECT MAX(CAST(REPLACE(IDJUSTIFICACION, 'JUS', '') AS INT))
        FROM JUSTIFICACION WHERE IDJUSTIFICACION LIKE 'JUS%'
    ), 0) + 1;
    SET v_Id = CONCAT('JUS', RIGHT(CONCAT('000CONCAT(', CAST(v_Next AS VARCHAR(10))), 3);

    DECLARE v_Hora CHAR(8) = TIME_FORMAT(CONVERT_TZ(NOW(), ', 00):00', '-05:00'), '%H:%i:%s');

    INSERT INTO JUSTIFICACION (IDJUSTIFICACION, IDUSUARIO, FECHA, HORAREGISTRO, IDREGISTRADOR, OBSERVACION)
    VALUES (v_Id, p_IdUsuario, p_Fecha, v_Hora, NULLIF(TRIM(p_IdRegistrador), ''), NULLIF(TRIM(p_Observacion), ''));

    IF EXISTS (SELECT 1 FROM ASISTENCIA WHERE IDUSUARIO = p_IdUsuario AND FECHAREGISTRO = p_Fecha) THEN
        UPDATE ASISTENCIA SET JUSTIFICADO = 1 WHERE IDUSUARIO = p_IdUsuario AND FECHAREGISTRO = p_Fecha;
    
ELSE
        INSERT INTO ASISTENCIA (IDASISTENCIA, FECHAREGISTRO, HORAINICIO, ESTADO, JUSTIFICADO, IDUSUARIO)
        VALUES (CONCAT('AS_', REPLACE(UUID()), '-', ''), p_Fecha, v_Hora, 'Falta', 1, p_IdUsuario);
    
    SET p_Resultado = 1; SET p_Mensaje = 'Justificación registrada.';
    SELECT p_Resultado AS Resultado, p_Mensaje AS Mensaje
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_justificacion_eliminar;

DROP PROCEDURE IF EXISTS usp_justificacion_eliminar;

DELIMITER $$

CREATE PROCEDURE usp_justificacion_eliminar(
    IN p_Id VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
IF NOT EXISTS (SELECT 1 FROM JUSTIFICACION WHERE IDJUSTIFICACION = p_Id)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'La justificación no existe.'; LEAVE main; 
    DECLARE v_IdUsuario VARCHAR(50);
    DECLARE v_Fecha CHAR(8);
    SELECT IDUSUARIO, v_Fecha = FECHA FROM JUSTIFICACION WHERE IDJUSTIFICACION = p_Id INTO v_IdUsuario;

    DELETE FROM JUSTIFICACION WHERE IDJUSTIFICACION = p_Id;

    IF EXISTS (SELECT 1 FROM ASISTENCIA WHERE IDUSUARIO = v_IdUsuario AND FECHAREGISTRO = v_Fecha AND ESTADO = 'Falta')
        DELETE FROM ASISTENCIA WHERE IDUSUARIO = v_IdUsuario AND FECHAREGISTRO = v_Fecha AND ESTADO = 'Falta';
    ELSE IF EXISTS (SELECT 1 FROM ASISTENCIA WHERE IDUSUARIO = v_IdUsuario AND FECHAREGISTRO = v_Fecha)
        UPDATE ASISTENCIA SET JUSTIFICADO = 0 WHERE IDUSUARIO = v_IdUsuario AND FECHAREGISTRO = v_Fecha;

    SET p_Resultado = 1; SET p_Mensaje = 'Justificación eliminada.';
END;

-- Submódulo menú (visible si el usuario tiene acceso a MOD003 Asistencias)
IF NOT EXISTS (SELECT 1 FROM SUBMODULO WHERE IDSUBMODULO = 'SUB025') THEN
    INSERT INTO SUBMODULO (IDSUBMODULO, NOMBRE, DESCRIPCION, ICONO, ORDEN, ACTIVO, IDMODULO)
    VALUES ('SUB025', 'Justificación', 'Justificar inasistencias o tardanzas', 'faFilePen', 3, 1, 'MOD003');

ELSE
    UPDATE SUBMODULO SET
        NOMBRE = 'Justificación',
        DESCRIPCION = 'Justificar inasistencias o tardanzas',
        ICONO = 'faFilePen',
        ORDEN = 3,
        ACTIVO = 1,
        IDMODULO = 'MOD003'
    WHERE IDSUBMODULO = 'SUB025';

SELECT 'Justificación: tabla, SPs y menú SUB025 listos.';
    SELECT p_Resultado AS Resultado, p_Mensaje AS Mensaje
END$$

DELIMITER ;