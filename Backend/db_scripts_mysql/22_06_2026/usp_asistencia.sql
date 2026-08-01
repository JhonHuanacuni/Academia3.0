-- ============================================================================
-- ASISTENCIA — marcar por DNI/QR, listar, anti-duplicados (MySQL 8)
-- Ejecutar después de esquema_completo.sql
-- ============================================================================

USE `AcademiaDB`;

CREATE UNIQUE INDEX UQ_ASISTENCIA_USUARIO_FECHA ON ASISTENCIA(IDUSUARIO, FECHAREGISTRO);

DROP PROCEDURE IF EXISTS usp_asistencia_marcar;
DROP PROCEDURE IF EXISTS usp_asistencia_listar;

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
    DECLARE v_Nombre VARCHAR(100);
    DECLARE v_Apellido VARCHAR(100);
    DECLARE v_FechaHoy CHAR(8);
    DECLARE v_HoraAhora CHAR(8);
    DECLARE v_Estado VARCHAR(50);
    DECLARE v_HoraLimite TIME DEFAULT '08:00:00';

    SET v_FechaHoy = fn_fecha_ddmmyyyy();
    SET v_HoraAhora = TIME_FORMAT(CONVERT_TZ(NOW(), '+00:00', '-05:00'), '%H:%i:%s');

    SELECT IDUSUARIO, NOMBRE, APELLIDO
    INTO v_IdUsuario, v_Nombre, v_Apellido
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

    IF CAST(v_HoraAhora AS TIME) <= v_HoraLimite THEN
        SET v_Estado = 'Presente';
    ELSE
        SET v_Estado = 'Tarde';
    END IF;

    SET p_IdAsistencia = CONCAT('AS_', REPLACE(UUID(), '-', ''));

    INSERT INTO ASISTENCIA (
        IDASISTENCIA, FECHAREGISTRO, HORAINICIO, ESTADO, JUSTIFICADO, IDUSUARIO
    ) VALUES (
        p_IdAsistencia, v_FechaHoy, v_HoraAhora, v_Estado, 0, v_IdUsuario
    );

    SET p_Resultado = 1;
    SET p_Mensaje = 'Asistencia registrada.';
END$$

CREATE PROCEDURE usp_asistencia_listar(
    IN p_Fecha CHAR(8),
    IN p_Buscar VARCHAR(200),
    IN p_OrdenarPor VARCHAR(50),
    IN p_Direccion VARCHAR(4),
    IN p_Pagina INT,
    IN p_TamanioPagina INT,
    OUT p_TotalRegistros INT
)
main: BEGIN
    IF p_Fecha IS NULL OR p_Fecha = '' THEN
        SET p_Fecha = fn_fecha_ddmmyyyy();
    END IF;
    IF p_Pagina < 1 THEN SET p_Pagina = 1; END IF;
    IF p_TamanioPagina < 1 THEN SET p_TamanioPagina = 50; END IF;

    SELECT COUNT(*)
    INTO p_TotalRegistros
    FROM ASISTENCIA a
    INNER JOIN USUARIO u ON u.IDUSUARIO = a.IDUSUARIO
    WHERE a.FECHAREGISTRO = p_Fecha
      AND (p_Buscar IS NULL OR p_Buscar = '' OR
           u.DNI LIKE CONCAT('%', p_Buscar, '%') OR
           u.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
           u.APELLIDO LIKE CONCAT('%', p_Buscar, '%') OR
           u.IDUSUARIO LIKE CONCAT('%', p_Buscar, '%'));

    SELECT
        a.IDASISTENCIA,
        a.FECHAREGISTRO,
        a.HORAINICIO,
        a.ESTADO,
        a.JUSTIFICADO,
        u.IDUSUARIO,
        u.NOMBRE,
        u.APELLIDO,
        u.DNI
    FROM ASISTENCIA a
    INNER JOIN USUARIO u ON u.IDUSUARIO = a.IDUSUARIO
    WHERE a.FECHAREGISTRO = p_Fecha
      AND (p_Buscar IS NULL OR p_Buscar = '' OR
           u.DNI LIKE CONCAT('%', p_Buscar, '%') OR
           u.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
           u.APELLIDO LIKE CONCAT('%', p_Buscar, '%') OR
           u.IDUSUARIO LIKE CONCAT('%', p_Buscar, '%'))
    ORDER BY
        CASE WHEN p_OrdenarPor = 'HORAINICIO' AND p_Direccion = 'ASC'  THEN a.HORAINICIO END ASC,
        CASE WHEN p_OrdenarPor = 'HORAINICIO' AND p_Direccion = 'DESC' THEN a.HORAINICIO END DESC,
        CASE WHEN p_OrdenarPor = 'NOMBRE'    AND p_Direccion = 'ASC'  THEN u.NOMBRE END ASC,
        CASE WHEN p_OrdenarPor = 'NOMBRE'    AND p_Direccion = 'DESC' THEN u.NOMBRE END DESC,
        a.HORAINICIO DESC
    LIMIT p_TamanioPagina OFFSET ((p_Pagina - 1) * p_TamanioPagina);
END$$

DELIMITER ;

SELECT 'usp_asistencia.sql ejecutado correctamente.' AS info;
