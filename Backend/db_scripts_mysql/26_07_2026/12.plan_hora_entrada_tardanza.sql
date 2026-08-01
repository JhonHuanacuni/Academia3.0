-- Convertido automáticamente desde db_scripts/26_07_2026/12.plan_hora_entrada_tardanza.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   PLAN: hora de CONCAT(entrada, tiempo) extra (tolerancia) para tardanza al marcar asistencia
   Ejecutar después de 11.quitar_mantenedor_asesor.sql
   Fecha: 26/07/2026
   ============================================================================ */

SET @col_PLAN_HORAENTRADA := (
    SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'PLAN' AND COLUMN_NAME = 'HORAENTRADA'
);
SET @sql_PLAN_HORAENTRADA := IF(@col_PLAN_HORAENTRADA = 0, 'ALTER TABLE `PLAN` ADD HORAENTRADA TIME NOT NULL
        CONSTRAINT DF_PLAN_HORAENTRADA DEFAULT (''08:00:00'')', 'SELECT 1');
PREPARE stmt FROM @sql_PLAN_HORAENTRADA; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @col_PLAN_TIEMPOEXTRA := (
    SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'PLAN' AND COLUMN_NAME = 'TIEMPOEXTRA'
);
SET @sql_PLAN_TIEMPOEXTRA := IF(@col_PLAN_TIEMPOEXTRA = 0, 'ALTER TABLE `PLAN` ADD TIEMPOEXTRA INT NOT NULL
        CONSTRAINT DF_PLAN_TIEMPOEXTRA DEFAULT (0)', 'SELECT 1');
PREPARE stmt FROM @sql_PLAN_TIEMPOEXTRA; EXECUTE stmt; DEALLOCATE PREPARE stmt;
UPDATE `PLAN`
SET HORAENTRADA = IFNULL(HORAENTRADA, CAST('08:00:00' AS TIME)),
    TIEMPOEXTRA  = IFNULL(TIEMPOEXTRA, 0);

/* Turno mañana: 8:CONCAT(00, 15) min | Turno tarde: 14:CONCAT(00, 15) min */
UPDATE `PLAN` SET HORAENTRADA = CAST('08:00:00' AS TIME), TIEMPOEXTRA = 15
WHERE IDTURNO = 'TUR001' OR IDTURNO IS NULL;

UPDATE `PLAN` SET HORAENTRADA = CAST('14:00:00' AS TIME), TIEMPOEXTRA = 15
WHERE IDTURNO = 'TUR002';

/* ---- usp_plan_* con HORAENTRADA y TIEMPOEXTRA ---- */

DROP PROCEDURE IF EXISTS usp_plan_listar;

DROP PROCEDURE IF EXISTS usp_plan_listar;

DELIMITER $$

CREATE PROCEDURE usp_plan_listar(
    IN p_Buscar VARCHAR(200),
    IN p_Estado VARCHAR(50),
    IN p_OrdenarPor VARCHAR(50),
    IN p_Direccion VARCHAR(4),
    IN p_Pagina INT,
    IN p_TamanioPagina INT,
    OUT p_TotalRegistros INT
)
main: BEGIN
IF p_Pagina < 1 THEN SET p_Pagina = 1; END IF;
    IF p_TamanioPagina < 1 THEN SET p_TamanioPagina = 10; END IF;

    SELECT COUNT(*) INTO p_TotalRegistros
    FROM `PLAN` p
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           p.IDPLAN      LIKE CONCAT('%', p_Buscar, '%') OR
           p.NOMBRE      LIKE CONCAT('%', p_Buscar, '%') OR
           p.DESCRIPCION LIKE CONCAT('%', p_Buscar, '%'))
      AND (p_Estado IS NULL OR p_Estado = '' OR
           (p_Estado = 'Activo' AND p.ACTIVO = 1) OR
           (p_Estado = 'Inactivo' AND p.ACTIVO = 0));

    SELECT
        p.IDPLAN,
        p.NOMBRE,
        p.DESCRIPCION,
        p.COSTOMENSUAL,
        p.DIASASISTENCIA,
        p.IDTURNO,
        TIME_FORMAT(p.HORAENTRADA, '%H:%i') AS HORAENTRADA,
        p.TIEMPOEXTRA,
        IFNULL(tu.DESCRIPCION, '') AS TURNO_DESCRIPCION,
        CASE WHEN p.ACTIVO = 1 THEN 'Activo' ELSE 'Inactivo' END AS ESTADO
    FROM `PLAN` p
    LEFT JOIN TURNO tu ON tu.IDTURNO = p.IDTURNO
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           p.IDPLAN      LIKE CONCAT('%', p_Buscar, '%') OR
           p.NOMBRE      LIKE CONCAT('%', p_Buscar, '%') OR
           p.DESCRIPCION LIKE CONCAT('%', p_Buscar, '%'))
      AND (p_Estado IS NULL OR p_Estado = '' OR
           (p_Estado = 'Activo' AND p.ACTIVO = 1) OR
           (p_Estado = 'Inactivo' AND p.ACTIVO = 0))
    ORDER BY
        CASE WHEN p_OrdenarPor = 'IDPLAN' AND p_Direccion = 'ASC'  THEN p.IDPLAN END ASC,
        CASE WHEN p_OrdenarPor = 'IDPLAN' AND p_Direccion = 'DESC' THEN p.IDPLAN END DESC,
        CASE WHEN p_OrdenarPor = 'NOMBRE' AND p_Direccion = 'ASC'  THEN p.NOMBRE END ASC,
        CASE WHEN p_OrdenarPor = 'NOMBRE' AND p_Direccion = 'DESC' THEN p.NOMBRE END DESC,
        CASE WHEN p_OrdenarPor = 'COSTOMENSUAL' AND p_Direccion = 'ASC'  THEN p.COSTOMENSUAL END ASC,
        CASE WHEN p_OrdenarPor = 'COSTOMENSUAL' AND p_Direccion = 'DESC' THEN p.COSTOMENSUAL END DESC,
        CASE WHEN p_OrdenarPor = 'ESTADO' AND p_Direccion = 'ASC'  THEN p.ACTIVO END ASC,
        CASE WHEN p_OrdenarPor = 'ESTADO' AND p_Direccion = 'DESC' THEN p.ACTIVO END DESC,
        p.NOMBRE
    LIMIT p_TamanioPagina OFFSET ((p_Pagina - 1) * p_TamanioPagina);
    SELECT p_TotalRegistros AS TotalRegistros
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_plan_obtener;

DROP PROCEDURE IF EXISTS usp_plan_obtener;

DELIMITER $$

CREATE PROCEDURE usp_plan_obtener(
    IN p_Id VARCHAR(50)
)
main: BEGIN
SELECT
        p.IDPLAN,
        p.NOMBRE,
        p.DESCRIPCION,
        p.COSTOMENSUAL,
        p.DIASASISTENCIA,
        p.IDTURNO,
        TIME_FORMAT(p.HORAENTRADA, '%H:%i') AS HORAENTRADA,
        p.TIEMPOEXTRA,
        IFNULL(tu.DESCRIPCION, '') AS TURNO_DESCRIPCION,
        CASE WHEN p.ACTIVO = 1 THEN 'Activo' ELSE 'Inactivo' END AS ESTADO
    FROM `PLAN` p
    LEFT JOIN TURNO tu ON tu.IDTURNO = p.IDTURNO
    WHERE p.IDPLAN = p_Id;
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_plan_insertar;

DROP PROCEDURE IF EXISTS usp_plan_insertar;

DELIMITER $$

CREATE PROCEDURE usp_plan_insertar(
    IN p_Id VARCHAR(50),
    IN p_Nombre VARCHAR(100),
    IN p_Descripcion VARCHAR(255),
    IN p_CostoMensual DECIMAL(10,2),
    IN p_DiasAsistencia TINYINT,
    IN p_IdTurno VARCHAR(50),
    IN p_HoraEntrada TIME,
    IN p_TiempoExtra INT,
    IN p_Estado VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
IF p_Id IS NULL OR TRIM(p_Id) = ''
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'Ingresa el código del plan.'; LEAVE main; 
    END IF;

    IF p_Nombre IS NULL OR TRIM(p_Nombre) = ''
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'Ingresa el nombre del plan.'; LEAVE main; 
    END IF;

    IF p_CostoMensual IS NOT NULL AND p_CostoMensual < 0
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'El costo mensual no puede ser negativo.'; LEAVE main; 
    END IF;

    IF p_DiasAsistencia IS NULL OR p_DiasAsistencia = 0 THEN SET p_DiasAsistencia = 63; END IF;

    IF p_HoraEntrada IS NULL THEN SET p_HoraEntrada = CAST('08:00:00' AS TIME); END IF;

    IF p_TiempoExtra IS NULL OR p_TiempoExtra < 0 THEN SET p_TiempoExtra = 0; END IF;

    IF p_IdTurno IS NOT NULL AND p_IdTurno <> ''
       AND NOT EXISTS (SELECT 1 FROM TURNO WHERE IDTURNO = p_IdTurno)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'El turno seleccionado no es válido.'; LEAVE main; 
    END IF;

    IF EXISTS (SELECT 1 FROM `PLAN` WHERE IDPLAN = p_Id)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'El código de plan ya existe.'; LEAVE main; 
    END IF;

    IF EXISTS (SELECT 1 FROM `PLAN` WHERE NOMBRE = p_Nombre)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'Ya existe un plan con ese nombre.'; LEAVE main; 
    INSERT INTO `PLAN` (IDPLAN, NOMBRE, DESCRIPCION, COSTOMENSUAL, DIASASISTENCIA, IDTURNO, HORAENTRADA, TIEMPOEXTRA, ACTIVO)
    VALUES (
        p_Id,
        p_Nombre,
        p_Descripcion,
        p_CostoMensual,
        p_DiasAsistencia,
        NULLIF(p_IdTurno, ''),
        p_HoraEntrada,
        p_TiempoExtra,
        CASE WHEN p_Estado = 'Activo' THEN 1 ELSE 0 END);

    SET p_Resultado = 1; SET p_Mensaje = 'Plan registrado.';
    SELECT p_Resultado AS Resultado, p_Mensaje AS Mensaje
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_plan_actualizar;

DROP PROCEDURE IF EXISTS usp_plan_actualizar;

DELIMITER $$

CREATE PROCEDURE usp_plan_actualizar(
    IN p_Id VARCHAR(50),
    IN p_Nombre VARCHAR(100),
    IN p_Descripcion VARCHAR(255),
    IN p_CostoMensual DECIMAL(10,2),
    IN p_DiasAsistencia TINYINT,
    IN p_IdTurno VARCHAR(50),
    IN p_HoraEntrada TIME,
    IN p_TiempoExtra INT,
    IN p_Estado VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
IF NOT EXISTS (SELECT 1 FROM `PLAN` WHERE IDPLAN = p_Id)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'El plan no existe.'; LEAVE main; 
    END IF;

    IF p_Nombre IS NULL OR TRIM(p_Nombre) = ''
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'Ingresa el nombre del plan.'; LEAVE main; 
    END IF;

    IF p_CostoMensual IS NOT NULL AND p_CostoMensual < 0
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'El costo mensual no puede ser negativo.'; LEAVE main; 
    END IF;

    IF p_DiasAsistencia IS NULL OR p_DiasAsistencia = 0 THEN SET p_DiasAsistencia = 63; END IF;

    IF p_HoraEntrada IS NULL THEN SET p_HoraEntrada = CAST('08:00:00' AS TIME); END IF;

    IF p_TiempoExtra IS NULL OR p_TiempoExtra < 0 THEN SET p_TiempoExtra = 0; END IF;

    IF p_IdTurno IS NOT NULL AND p_IdTurno <> ''
       AND NOT EXISTS (SELECT 1 FROM TURNO WHERE IDTURNO = p_IdTurno)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'El turno seleccionado no es válido.'; LEAVE main; 
    END IF;

    IF EXISTS (SELECT 1 FROM `PLAN` WHERE NOMBRE = p_Nombre AND IDPLAN <> p_Id)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'Ya existe un plan con ese nombre.'; LEAVE main; 
    UPDATE `PLAN` SET
        NOMBRE          = p_Nombre,
        DESCRIPCION     = p_Descripcion,
        COSTOMENSUAL    = p_CostoMensual,
        DIASASISTENCIA  = p_DiasAsistencia,
        IDTURNO         = NULLIF(p_IdTurno, ''),
        HORAENTRADA     = p_HoraEntrada,
        TIEMPOEXTRA     = p_TiempoExtra,
        ACTIVO          = CASE WHEN p_Estado = 'Activo' THEN 1 ELSE 0 END
    WHERE IDPLAN = p_Id;

    UPDATE m
    SET m.IDTURNO = NULLIF(p_IdTurno, '')
    FROM MENSUALIDAD m
    WHERE m.IDPLAN = p_Id;

    SET p_Resultado = 1; SET p_Mensaje = 'Plan actualizado.';
END;

/* ---- Marcar asistencia según plan del estudiante ---- */
    SELECT p_Resultado AS Resultado, p_Mensaje AS Mensaje
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_asistencia_marcar;

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
    DECLARE v_FechaHoy CHAR(8) = fn_fecha_ddmmyyyy();
    DECLARE v_HoraAhora TIME;
    DECLARE v_Estado VARCHAR(50);
    DECLARE v_HoraEntrada TIME = CAST('08:00:00' AS TIME);
    DECLARE v_TiempoExtra INT = 0;
    DECLARE v_HoraLimite TIME;

    SET v_HoraAhora = CAST(CAST(SYSDATETIMEOFFSET() AT TIME ZONE 'SA Pacific Standard Time' AS DATETIME) AS TIME);

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
    )
    BEGIN
        SET p_Resultado = 0;
        SET p_Mensaje = 'Este estudiante ya tiene su asistencia registrada para hoy.';
        SET p_IdAsistencia = NULL;
        LEAVE main;
    
    SELECT TOP 1
        v_HoraEntrada = IFNULL(p.HORAENTRADA, CAST('08:00:00' AS TIME)),
        v_TiempoExtra = IFNULL(p.TIEMPOEXTRA, 0)
    FROM MENSUALIDAD m
    INNER JOIN `PLAN` p ON p.IDPLAN = m.IDPLAN
    WHERE m.IDUSUARIO = v_IdUsuario
      AND (m.ESTADO IS NULL OR m.ESTADO = 'Activo')
      AND (
          m.FECHAINICIO IS NULL OR m.FECHAINICIO = '' OR
          CONCAT(CONVERT(DATE,
              SUBSTRING(m.FECHAINICIO, 5, 4), '-') +
              CONCAT(SUBSTRING(m.FECHAINICIO, 3, 2), '-') +
              SUBSTRING(m.FECHAINICIO, 1, 2)
          ) <= CONCAT(CONVERT(DATE,
              SUBSTRING(v_FechaHoy, 5, 4), '-') +
              CONCAT(SUBSTRING(v_FechaHoy, 3, 2), '-') +
              SUBSTRING(v_FechaHoy, 1, 2)
          )
      )
      AND (
          m.FECHAFIN IS NULL OR m.FECHAFIN = '' OR
          CONCAT(CONVERT(DATE,
              SUBSTRING(m.FECHAFIN, 5, 4), '-') +
              CONCAT(SUBSTRING(m.FECHAFIN, 3, 2), '-') +
              SUBSTRING(m.FECHAFIN, 1, 2)
          ) >= CONCAT(CONVERT(DATE,
              SUBSTRING(v_FechaHoy, 5, 4), '-') +
              CONCAT(SUBSTRING(v_FechaHoy, 3, 2), '-') +
              SUBSTRING(v_FechaHoy, 1, 2)
          )
      )
    ORDER BY m.FECHAREGISTRO DESC, m.FECHAINICIO DESC;

    SET v_HoraLimite = CAST(DATEADD(MINUTE, v_TiempoExtra, CAST(v_HoraEntrada AS DATETIME)) AS TIME);

    IF v_HoraAhora <= v_HoraLimite THEN SET v_Estado = 'Presente'; END IF;
ELSE
        SET v_Estado = 'Tarde';

    SET p_IdAsistencia = CONCAT('AS_', REPLACE(UUID()), '-', '');

    INSERT INTO ASISTENCIA (
        IDASISTENCIA, FECHAREGISTRO, HORAINICIO, ESTADO, JUSTIFICADO, IDUSUARIO
    ) VALUES (
        p_IdAsistencia, v_FechaHoy,
        CONVERT(CHAR(8), v_HoraAhora, 108),
        v_Estado, 0, v_IdUsuario
    );

    SET p_Resultado = 1;
    SET p_Mensaje = 'Asistencia registrada.';
END;

SELECT 'PLAN.HORAENTRADA, PLAN.TIEMPOEXTRA, usp_plan_* y usp_asistencia_marcar actualizados.';
    SELECT p_Resultado AS Resultado, p_Mensaje AS Mensaje, p_IdAsistencia AS IdAsistencia
END$$

DELIMITER ;