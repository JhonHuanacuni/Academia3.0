-- Mensajes / avisos (Académico SUB028) + campana del navbar
-- Fecha: 24/08/2026
-- Destinatarios: Estudiantes | Trabajadores | Todos
-- Fechas CHAR(8) DDMMYYYY. Hora Perú (UTC-5).

USE `AcademiaDB`;

CREATE TABLE IF NOT EXISTS MENSAJE (
    IDMENSAJE           VARCHAR(50)   NOT NULL PRIMARY KEY,
    TITULO              VARCHAR(200)  NOT NULL,
    MENSAJE             TEXT          NOT NULL,
    FECHAINICIO         CHAR(8)       NOT NULL,
    FECHAFIN            CHAR(8)       NOT NULL,
    DESTINATARIO        VARCHAR(30)   NOT NULL DEFAULT 'Estudiantes',
    CARGO               VARCHAR(30)   NOT NULL DEFAULT 'Administrador',
    ESTADO              VARCHAR(50)   NOT NULL DEFAULT 'Activo',
    CREADO_POR          VARCHAR(50)   NULL,
    FECHACREACION       CHAR(8)       NULL,
    HORACREACION        CHAR(8)       NULL,
    MODIFICADO_POR      VARCHAR(50)   NULL,
    FECHAMODIFICACION   CHAR(8)       NULL,
    HORAMODIFICACION    CHAR(8)       NULL,
    INDEX IX_MENSAJE_VIGENCIA (ESTADO, FECHAINICIO, FECHAFIN),
    INDEX IX_MENSAJE_DEST (DESTINATARIO)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO SUBMODULO (IDSUBMODULO, NOMBRE, DESCRIPCION, ICONO, ORDEN, ACTIVO, IDMODULO)
VALUES ('SUB028', 'Mensajes', 'Avisos vigentes para estudiantes y trabajadores', 'faBullhorn', 7, 1, 'MOD009')
ON DUPLICATE KEY UPDATE
    NOMBRE = 'Mensajes',
    DESCRIPCION = 'Avisos vigentes para estudiantes y trabajadores',
    ICONO = 'faBullhorn',
    ORDEN = 7,
    ACTIVO = 1,
    IDMODULO = 'MOD009';

INSERT IGNORE INTO GRUPO_SUBMODULO_EXCLUIDO (IDGRUPOEXCLSUB, IDTIPOUSUARIO, IDSUBMODULO, FECHAREGISTRO)
VALUES ('GEX_MSG_EST', '1', 'SUB028', fn_fecha_ddmmyyyy());

DROP PROCEDURE IF EXISTS usp_mensaje_listar;
DROP PROCEDURE IF EXISTS usp_mensaje_obtener;
DROP PROCEDURE IF EXISTS usp_mensaje_insertar;
DROP PROCEDURE IF EXISTS usp_mensaje_actualizar;
DROP PROCEDURE IF EXISTS usp_mensaje_eliminar;
DROP PROCEDURE IF EXISTS usp_mensaje_vigentes;

DELIMITER $$

CREATE PROCEDURE usp_mensaje_listar(
    IN p_Buscar VARCHAR(200),
    IN p_Estado VARCHAR(50),
    IN p_Destinatario VARCHAR(30),
    IN p_OrdenarPor VARCHAR(50),
    IN p_Direccion VARCHAR(4),
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
    FROM MENSAJE m
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           m.TITULO LIKE CONCAT('%', p_Buscar, '%') OR
           m.MENSAJE LIKE CONCAT('%', p_Buscar, '%') OR
           m.IDMENSAJE LIKE CONCAT('%', p_Buscar, '%'))
      AND (p_Estado IS NULL OR p_Estado = '' OR m.ESTADO = p_Estado)
      AND (p_Destinatario IS NULL OR p_Destinatario = '' OR m.DESTINATARIO = p_Destinatario);

    SELECT
        m.IDMENSAJE,
        m.TITULO,
        m.MENSAJE,
        m.FECHAINICIO,
        m.FECHAFIN,
        m.DESTINATARIO,
        m.CARGO,
        m.ESTADO,
        m.CREADO_POR,
        TRIM(CONCAT(IFNULL(u.NOMBRE, ''), ' ', IFNULL(u.APELLIDO, ''))) AS AUTOR,
        m.FECHACREACION,
        m.HORACREACION,
        m.MODIFICADO_POR,
        m.FECHAMODIFICACION,
        m.HORAMODIFICACION
    FROM MENSAJE m
    LEFT JOIN USUARIO u ON u.IDUSUARIO = m.CREADO_POR
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           m.TITULO LIKE CONCAT('%', p_Buscar, '%') OR
           m.MENSAJE LIKE CONCAT('%', p_Buscar, '%') OR
           m.IDMENSAJE LIKE CONCAT('%', p_Buscar, '%'))
      AND (p_Estado IS NULL OR p_Estado = '' OR m.ESTADO = p_Estado)
      AND (p_Destinatario IS NULL OR p_Destinatario = '' OR m.DESTINATARIO = p_Destinatario)
    ORDER BY
        CASE WHEN p_OrdenarPor = 'TITULO' AND p_Direccion = 'ASC' THEN m.TITULO END ASC,
        CASE WHEN p_OrdenarPor = 'TITULO' AND p_Direccion = 'DESC' THEN m.TITULO END DESC,
        CASE WHEN p_OrdenarPor = 'DESTINATARIO' AND p_Direccion = 'ASC' THEN m.DESTINATARIO END ASC,
        CASE WHEN p_OrdenarPor = 'DESTINATARIO' AND p_Direccion = 'DESC' THEN m.DESTINATARIO END DESC,
        CASE WHEN p_OrdenarPor = 'ESTADO' AND p_Direccion = 'ASC' THEN m.ESTADO END ASC,
        CASE WHEN p_OrdenarPor = 'ESTADO' AND p_Direccion = 'DESC' THEN m.ESTADO END DESC,
        CASE WHEN p_OrdenarPor = 'FECHAINICIO' AND p_Direccion = 'ASC' THEN
            CONCAT(SUBSTRING(m.FECHAINICIO, 5, 4), SUBSTRING(m.FECHAINICIO, 3, 2), SUBSTRING(m.FECHAINICIO, 1, 2)) END ASC,
        CASE WHEN p_OrdenarPor = 'FECHAINICIO' AND p_Direccion = 'DESC' THEN
            CONCAT(SUBSTRING(m.FECHAINICIO, 5, 4), SUBSTRING(m.FECHAINICIO, 3, 2), SUBSTRING(m.FECHAINICIO, 1, 2)) END DESC,
        CASE WHEN p_OrdenarPor = 'FECHAFIN' AND p_Direccion = 'ASC' THEN
            CONCAT(SUBSTRING(m.FECHAFIN, 5, 4), SUBSTRING(m.FECHAFIN, 3, 2), SUBSTRING(m.FECHAFIN, 1, 2)) END ASC,
        CASE WHEN p_OrdenarPor = 'FECHAFIN' AND p_Direccion = 'DESC' THEN
            CONCAT(SUBSTRING(m.FECHAFIN, 5, 4), SUBSTRING(m.FECHAFIN, 3, 2), SUBSTRING(m.FECHAFIN, 1, 2)) END DESC,
        CASE WHEN p_OrdenarPor = 'AUTOR' AND p_Direccion = 'ASC' THEN u.NOMBRE END ASC,
        CASE WHEN p_OrdenarPor = 'AUTOR' AND p_Direccion = 'DESC' THEN u.NOMBRE END DESC,
        CONCAT(SUBSTRING(IFNULL(m.FECHACREACION, '01011900'), 5, 4),
               SUBSTRING(IFNULL(m.FECHACREACION, '01011900'), 3, 2),
               SUBSTRING(IFNULL(m.FECHACREACION, '01011900'), 1, 2)) DESC,
        IFNULL(m.HORACREACION, '') DESC
    LIMIT p_TamanioPagina OFFSET v_offset;
END$$

CREATE PROCEDURE usp_mensaje_obtener(IN p_Id VARCHAR(50))
main: BEGIN
    SELECT
        m.IDMENSAJE,
        m.TITULO,
        m.MENSAJE,
        m.FECHAINICIO,
        m.FECHAFIN,
        m.DESTINATARIO,
        m.CARGO,
        m.ESTADO,
        m.CREADO_POR,
        TRIM(CONCAT(IFNULL(u.NOMBRE, ''), ' ', IFNULL(u.APELLIDO, ''))) AS AUTOR,
        m.FECHACREACION,
        m.HORACREACION,
        m.MODIFICADO_POR,
        m.FECHAMODIFICACION,
        m.HORAMODIFICACION
    FROM MENSAJE m
    LEFT JOIN USUARIO u ON u.IDUSUARIO = m.CREADO_POR
    WHERE m.IDMENSAJE = p_Id;
END$$

CREATE PROCEDURE usp_mensaje_insertar(
    IN p_Titulo VARCHAR(200),
    IN p_Mensaje TEXT,
    IN p_FechaInicio CHAR(8),
    IN p_FechaFin CHAR(8),
    IN p_Destinatario VARCHAR(30),
    IN p_Cargo VARCHAR(30),
    IN p_Estado VARCHAR(50),
    OUT p_IdGenerado VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_MensajeOut VARCHAR(200)
)
main: BEGIN
    DECLARE v_Next INT DEFAULT 0;
    DECLARE v_Fecha CHAR(8);
    DECLARE v_Hora CHAR(8);
    DECLARE v_Dest VARCHAR(30);
    DECLARE v_Cargo VARCHAR(30);
    DECLARE v_Estado VARCHAR(50);

    SET p_IdGenerado = NULL;
    SET v_Fecha = fn_fecha_ddmmyyyy();
    SET v_Hora = TIME_FORMAT(IFNULL(
        CONVERT_TZ(UTC_TIMESTAMP(), '+00:00', '-05:00'),
        DATE_SUB(UTC_TIMESTAMP(), INTERVAL 5 HOUR)
    ), '%H:%i:%s');
    SET v_Dest = NULLIF(TRIM(p_Destinatario), '');
    SET v_Cargo = IFNULL(NULLIF(TRIM(p_Cargo), ''), 'Administrador');
    SET v_Estado = IFNULL(NULLIF(TRIM(p_Estado), ''), 'Activo');

    IF p_Titulo IS NULL OR TRIM(p_Titulo) = '' THEN
        SET p_Resultado = 0; SET p_MensajeOut = 'Ingresa el título.';
        LEAVE main;
    END IF;
    IF p_Mensaje IS NULL OR TRIM(p_Mensaje) = '' THEN
        SET p_Resultado = 0; SET p_MensajeOut = 'Ingresa el mensaje.';
        LEAVE main;
    END IF;
    IF p_FechaInicio IS NULL OR CHAR_LENGTH(p_FechaInicio) <> 8 THEN
        SET p_Resultado = 0; SET p_MensajeOut = 'Ingresa la fecha de inicio.';
        LEAVE main;
    END IF;
    IF p_FechaFin IS NULL OR CHAR_LENGTH(p_FechaFin) <> 8 THEN
        SET p_Resultado = 0; SET p_MensajeOut = 'Ingresa la fecha final.';
        LEAVE main;
    END IF;
    IF STR_TO_DATE(p_FechaFin, '%d%m%Y') < STR_TO_DATE(p_FechaInicio, '%d%m%Y') THEN
        SET p_Resultado = 0; SET p_MensajeOut = 'La fecha final no puede ser anterior al inicio.';
        LEAVE main;
    END IF;
    IF v_Dest IS NULL OR v_Dest NOT IN ('Estudiantes', 'Trabajadores', 'Todos') THEN
        SET p_Resultado = 0; SET p_MensajeOut = 'Selecciona a quién va el mensaje.';
        LEAVE main;
    END IF;
    IF v_Cargo NOT IN ('Trabajador', 'Administrador', 'Desarrollador') THEN
        SET p_Resultado = 0; SET p_MensajeOut = 'Selecciona el cargo del autor.';
        LEAVE main;
    END IF;

    SELECT IFNULL(MAX(CAST(REPLACE(IDMENSAJE, 'MSG', '') AS UNSIGNED)), 0) + 1 INTO v_Next
    FROM MENSAJE WHERE IDMENSAJE LIKE 'MSG%';
    SET p_IdGenerado = CONCAT('MSG', LPAD(CAST(v_Next AS CHAR), 3, '0'));

    INSERT INTO MENSAJE (
        IDMENSAJE, TITULO, MENSAJE, FECHAINICIO, FECHAFIN, DESTINATARIO, CARGO, ESTADO,
        CREADO_POR, FECHACREACION, HORACREACION
    ) VALUES (
        p_IdGenerado, TRIM(p_Titulo), TRIM(p_Mensaje), p_FechaInicio, p_FechaFin,
        v_Dest, v_Cargo, v_Estado, @audit_id_usuario, v_Fecha, v_Hora
    );

    SET p_Resultado = 1; SET p_MensajeOut = 'Mensaje publicado.';
END$$

CREATE PROCEDURE usp_mensaje_actualizar(
    IN p_Id VARCHAR(50),
    IN p_Titulo VARCHAR(200),
    IN p_Mensaje TEXT,
    IN p_FechaInicio CHAR(8),
    IN p_FechaFin CHAR(8),
    IN p_Destinatario VARCHAR(30),
    IN p_Cargo VARCHAR(30),
    IN p_Estado VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_MensajeOut VARCHAR(200)
)
main: BEGIN
    DECLARE v_Fecha CHAR(8);
    DECLARE v_Hora CHAR(8);
    DECLARE v_Dest VARCHAR(30);
    DECLARE v_Cargo VARCHAR(30);
    DECLARE v_Estado VARCHAR(50);

    SET v_Fecha = fn_fecha_ddmmyyyy();
    SET v_Hora = TIME_FORMAT(IFNULL(
        CONVERT_TZ(UTC_TIMESTAMP(), '+00:00', '-05:00'),
        DATE_SUB(UTC_TIMESTAMP(), INTERVAL 5 HOUR)
    ), '%H:%i:%s');
    SET v_Dest = NULLIF(TRIM(p_Destinatario), '');
    SET v_Cargo = IFNULL(NULLIF(TRIM(p_Cargo), ''), 'Administrador');
    SET v_Estado = IFNULL(NULLIF(TRIM(p_Estado), ''), 'Activo');

    IF NOT EXISTS (SELECT 1 FROM MENSAJE WHERE IDMENSAJE = p_Id) THEN
        SET p_Resultado = 0; SET p_MensajeOut = 'El mensaje no existe.';
        LEAVE main;
    END IF;
    IF p_Titulo IS NULL OR TRIM(p_Titulo) = '' THEN
        SET p_Resultado = 0; SET p_MensajeOut = 'Ingresa el título.';
        LEAVE main;
    END IF;
    IF p_Mensaje IS NULL OR TRIM(p_Mensaje) = '' THEN
        SET p_Resultado = 0; SET p_MensajeOut = 'Ingresa el mensaje.';
        LEAVE main;
    END IF;
    IF p_FechaInicio IS NULL OR CHAR_LENGTH(p_FechaInicio) <> 8 THEN
        SET p_Resultado = 0; SET p_MensajeOut = 'Ingresa la fecha de inicio.';
        LEAVE main;
    END IF;
    IF p_FechaFin IS NULL OR CHAR_LENGTH(p_FechaFin) <> 8 THEN
        SET p_Resultado = 0; SET p_MensajeOut = 'Ingresa la fecha final.';
        LEAVE main;
    END IF;
    IF STR_TO_DATE(p_FechaFin, '%d%m%Y') < STR_TO_DATE(p_FechaInicio, '%d%m%Y') THEN
        SET p_Resultado = 0; SET p_MensajeOut = 'La fecha final no puede ser anterior al inicio.';
        LEAVE main;
    END IF;
    IF v_Dest IS NULL OR v_Dest NOT IN ('Estudiantes', 'Trabajadores', 'Todos') THEN
        SET p_Resultado = 0; SET p_MensajeOut = 'Selecciona a quién va el mensaje.';
        LEAVE main;
    END IF;
    IF v_Cargo NOT IN ('Trabajador', 'Administrador', 'Desarrollador') THEN
        SET p_Resultado = 0; SET p_MensajeOut = 'Selecciona el cargo del autor.';
        LEAVE main;
    END IF;

    UPDATE MENSAJE SET
        TITULO = TRIM(p_Titulo),
        MENSAJE = TRIM(p_Mensaje),
        FECHAINICIO = p_FechaInicio,
        FECHAFIN = p_FechaFin,
        DESTINATARIO = v_Dest,
        CARGO = v_Cargo,
        ESTADO = v_Estado,
        MODIFICADO_POR = @audit_id_usuario,
        FECHAMODIFICACION = v_Fecha,
        HORAMODIFICACION = v_Hora
    WHERE IDMENSAJE = p_Id;

    SET p_Resultado = 1; SET p_MensajeOut = 'Mensaje actualizado.';
END$$

CREATE PROCEDURE usp_mensaje_eliminar(
    IN p_Id VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_MensajeOut VARCHAR(200)
)
main: BEGIN
    IF NOT EXISTS (SELECT 1 FROM MENSAJE WHERE IDMENSAJE = p_Id) THEN
        SET p_Resultado = 0; SET p_MensajeOut = 'El mensaje no existe.';
        LEAVE main;
    END IF;
    DELETE FROM MENSAJE WHERE IDMENSAJE = p_Id;
    SET p_Resultado = 1; SET p_MensajeOut = 'Mensaje eliminado.';
END$$

CREATE PROCEDURE usp_mensaje_vigentes(IN p_IdTipoUsuario VARCHAR(50))
main: BEGIN
    DECLARE v_Hoy DATE;
    SET v_Hoy = STR_TO_DATE(fn_fecha_ddmmyyyy(), '%d%m%Y');

    SELECT
        m.IDMENSAJE,
        m.TITULO,
        m.MENSAJE,
        m.DESTINATARIO,
        IFNULL(NULLIF(TRIM(m.CARGO), ''), 'Administrador') AS CARGO,
        m.FECHAINICIO,
        m.FECHAFIN,
        TRIM(CONCAT(IFNULL(u.NOMBRE, ''), ' ', IFNULL(u.APELLIDO, ''))) AS AUTOR,
        m.FECHACREACION,
        m.HORACREACION
    FROM MENSAJE m
    LEFT JOIN USUARIO u ON u.IDUSUARIO = m.CREADO_POR
    WHERE m.ESTADO = 'Activo'
      AND CHAR_LENGTH(m.FECHAINICIO) = 8
      AND CHAR_LENGTH(m.FECHAFIN) = 8
      AND v_Hoy >= STR_TO_DATE(m.FECHAINICIO, '%d%m%Y')
      AND v_Hoy <= STR_TO_DATE(m.FECHAFIN, '%d%m%Y')
      AND (
            p_IdTipoUsuario = '3'
         OR (p_IdTipoUsuario = '1' AND m.DESTINATARIO IN ('Estudiantes', 'Todos'))
         OR (p_IdTipoUsuario = '2' AND m.DESTINATARIO IN ('Trabajadores', 'Todos'))
      )
    ORDER BY
        CONCAT(SUBSTRING(m.FECHAINICIO, 5, 4), SUBSTRING(m.FECHAINICIO, 3, 2), SUBSTRING(m.FECHAINICIO, 1, 2)) DESC,
        IFNULL(m.HORACREACION, '') DESC;
END$$

DELIMITER ;

SELECT 'SUB028 Mensajes y SPs listos.' AS info;
