-- Convertido automáticamente desde db_scripts/26_07_2026/6.plan_turno.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   PLAN: turno por plan (FK TURNO). Mensualidad hereda turno del plan.
   Ejecutar después de 5.menu_mensualidad_tutor.sql
   Fecha: 26/07/2026
   ============================================================================ */

SET @col_PLAN_IDTURNO := (
    SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'PLAN' AND COLUMN_NAME = 'IDTURNO'
);
SET @sql_PLAN_IDTURNO := IF(@col_PLAN_IDTURNO = 0, 'ALTER TABLE `PLAN` ADD IDTURNO VARCHAR(50) NULL', 'SELECT 1');
PREPARE stmt FROM @sql_PLAN_IDTURNO; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @fk_FK_PLAN_TURNO := (
    SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_SCHEMA = DATABASE() AND CONSTRAINT_NAME = 'FK_PLAN_TURNO'
);
SET @sql_FK_PLAN_TURNO := IF(@fk_FK_PLAN_TURNO = 0, 'ALTER TABLE `PLAN`
        ADD CONSTRAINT FK_PLAN_TURNO FOREIGN KEY (IDTURNO) REFERENCES TURNO(IDTURNO)', 'SELECT 1');
PREPARE stmt FROM @sql_FK_PLAN_TURNO; EXECUTE stmt; DEALLOCATE PREPARE stmt;
/* Catálogo Academia Vita: tarde en PLN002 y PLN006; resto mañana */
UPDATE `PLAN` SET IDTURNO = 'TUR002' WHERE IDPLAN IN ('PLN002', 'PLN006');
UPDATE `PLAN` SET IDTURNO = 'TUR001' WHERE IDTURNO IS NULL;

/* Sincronizar mensualidades existentes con el turno del plan */
UPDATE m
SET m.IDTURNO = p.IDTURNO
FROM MENSUALIDAD m
INNER JOIN `PLAN` p ON p.IDPLAN = m.IDPLAN
WHERE p.IDTURNO IS NOT NULL;

/* ---- usp_plan_* ---- */

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

    SET @v_offset = (p_Pagina - 1) * p_TamanioPagina;
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
    LIMIT p_TamanioPagina OFFSET @v_offset;
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
    IN p_Estado VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
IF p_Id IS NULL OR TRIM(p_Id) = '' THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa el código del plan.'; LEAVE main;     END IF;

    IF p_Nombre IS NULL OR TRIM(p_Nombre) = '' THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa el nombre del plan.'; LEAVE main;     END IF;

    IF p_CostoMensual IS NOT NULL AND p_CostoMensual < 0 THEN
        SET p_Resultado = 0; SET p_Mensaje = 'El costo mensual no puede ser negativo.'; LEAVE main;     END IF;

    IF p_DiasAsistencia IS NULL OR p_DiasAsistencia = 0 THEN SET p_DiasAsistencia = 63; END IF;

    IF p_IdTurno IS NOT NULL AND p_IdTurno <> ''
       AND NOT EXISTS (SELECT 1 FROM TURNO WHERE IDTURNO = p_IdTurno)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'El turno seleccionado no es válido.'; LEAVE main; 
    END IF;

    IF EXISTS (SELECT 1 FROM `PLAN` WHERE IDPLAN = p_Id) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'El código de plan ya existe.'; LEAVE main;     END IF;

    IF EXISTS (SELECT 1 FROM `PLAN` WHERE NOMBRE = p_Nombre) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ya existe un plan con ese nombre.'; LEAVE main;     END IF;
    INSERT INTO `PLAN` (IDPLAN, NOMBRE, DESCRIPCION, COSTOMENSUAL, DIASASISTENCIA, IDTURNO, ACTIVO)
    VALUES (
        p_Id,
        p_Nombre,
        p_Descripcion,
        p_CostoMensual,
        p_DiasAsistencia,
        NULLIF(p_IdTurno, ''),
        CASE WHEN p_Estado = 'Activo' THEN 1 ELSE 0 END);

    SET p_Resultado = 1; SET p_Mensaje = 'Plan registrado.';
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
    IN p_Estado VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
IF NOT EXISTS (SELECT 1 FROM `PLAN` WHERE IDPLAN = p_Id) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'El plan no existe.'; LEAVE main;     END IF;

    IF p_Nombre IS NULL OR TRIM(p_Nombre) = '' THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa el nombre del plan.'; LEAVE main;     END IF;

    IF p_CostoMensual IS NOT NULL AND p_CostoMensual < 0 THEN
        SET p_Resultado = 0; SET p_Mensaje = 'El costo mensual no puede ser negativo.'; LEAVE main;     END IF;

    IF p_DiasAsistencia IS NULL OR p_DiasAsistencia = 0 THEN SET p_DiasAsistencia = 63; END IF;

    IF p_IdTurno IS NOT NULL AND p_IdTurno <> ''
       AND NOT EXISTS (SELECT 1 FROM TURNO WHERE IDTURNO = p_IdTurno)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'El turno seleccionado no es válido.'; LEAVE main; 
    END IF;

    IF EXISTS (SELECT 1 FROM `PLAN` WHERE NOMBRE = p_Nombre AND IDPLAN <> p_Id) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ya existe un plan con ese nombre.'; LEAVE main;     END IF;
    UPDATE `PLAN` SET
        NOMBRE          = p_Nombre,
        DESCRIPCION     = p_Descripcion,
        COSTOMENSUAL    = p_CostoMensual,
        DIASASISTENCIA  = p_DiasAsistencia,
        IDTURNO         = NULLIF(p_IdTurno, ''),
        ACTIVO          = CASE WHEN p_Estado = 'Activo' THEN 1 ELSE 0 END
    WHERE IDPLAN = p_Id;

    UPDATE m
    SET m.IDTURNO = NULLIF(p_IdTurno, '')
    FROM MENSUALIDAD m
    WHERE m.IDPLAN = p_Id;

    SET p_Resultado = 1; SET p_Mensaje = 'Plan actualizado.';
END;

/* ---- usp_mensualidad: turno heredado del plan ---- */
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_mensualidad_insertar;

DROP PROCEDURE IF EXISTS usp_mensualidad_insertar;

DELIMITER $$

CREATE PROCEDURE usp_mensualidad_insertar(
    IN p_Id VARCHAR(50),
    IN p_IdUsuario VARCHAR(50),
    IN p_IdPlan VARCHAR(50),
    IN p_EstadoMiembro INT,
    IN p_FechaInicio CHAR(8),
    IN p_FechaFin CHAR(8),
    IN p_MontoTotal DECIMAL(10,2),
    IN p_PagoInicial DECIMAL(10,2),
    IN p_IdMetodoPago VARCHAR(50),
    IN p_IdAula VARCHAR(50),
    IN p_IdTutor VARCHAR(50),
    IN p_Observaciones LONGTEXT,
    IN p_FechaCancelacion CHAR(8),
    IN p_RegistradoPor VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
IF p_IdUsuario IS NULL OR p_IdUsuario = '' THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Debe seleccionar un estudiante.'; LEAVE main;     END IF;

    IF p_FechaInicio IS NULL OR p_FechaFin IS NULL THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingrese fecha de inicio y fin.'; LEAVE main;     END IF;

    IF p_MontoTotal IS NULL THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingrese el monto total.'; LEAVE main;     END IF;

    IF p_EstadoMiembro NOT IN (2, 3) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Estado de mensualidad no válido.'; LEAVE main;     END IF;

    IF NOT EXISTS (SELECT 1 FROM USUARIO WHERE IDUSUARIO = p_IdUsuario AND IDTIPOUSUARIO = '1') THEN
        SET p_Resultado = 0; SET p_Mensaje = 'El estudiante no existe o no es válido.'; LEAVE main;     END IF;

    IF NOT EXISTS (SELECT 1 FROM `PLAN` WHERE IDPLAN = p_IdPlan) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'El plan seleccionado no es válido.'; LEAVE main;     END IF;
    SELECT IDTURNO FROM `PLAN` WHERE IDPLAN = p_IdPlan INTO v_IdTurno;

    IF p_IdTutor IS NOT NULL AND p_IdTutor <> ''
       AND NOT EXISTS (SELECT 1 FROM TUTOR WHERE IDTUTOR = p_IdTutor AND ACTIVO = 1)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'El tutor seleccionado no es válido.'; LEAVE main; 
    END IF;

    IF p_PagoInicial IS NOT NULL AND p_PagoInicial > 0
       AND (p_IdMetodoPago IS NULL OR p_IdMetodoPago = '')
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'Indique el método de pago del pago inicial.'; LEAVE main; 
    END IF;

    IF p_Id IS NULL OR p_Id = '' THEN
SET p_Id = CONCAT('MEM', RIGHT(CONCAT('000000', CAST(v_Next AS CHAR(10))), 6);
    
    IF EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = p_Id) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'La mensualidad ya existe.'; LEAVE main;     END IF;
    INSERT INTO MENSUALIDAD (
        IDMENSUALIDAD, FECHAINICIO, FECHAFIN, ESTADOMIEMBRO, MONTOTOTAL, OBSERVACIONES,
        FECHAREGISTRO, HORAREGISTRO, IDPLAN, IDAULA, IDTURNO, IDUSUARIO, REGISTRADOPOR,
        IDTUTOR, FECHACANCELACION, ESTADO
    ) VALUES (
        p_Id, p_FechaInicio, p_FechaFin, p_EstadoMiembro, p_MontoTotal, p_Observaciones,
        fn_fecha_ddmmyyyy(), TIME_FORMAT(NOW(), '%H:%i:%s'),
        p_IdPlan, p_IdAula, v_IdTurno, p_IdUsuario, p_RegistradoPor,
        p_IdTutor, p_FechaCancelacion, 'Activo'
    );

    IF p_PagoInicial IS NOT NULL AND p_PagoInicial > 0 THEN
INSERT INTO PAGOMENSUALIDAD (
            IDPAGOMENSUALIDAD, MONTO, FECHAPAGO, HORAPAGO, OBSERVACIONES,
            IDMENSUALIDAD, IDMETODOPAGO, IDUSUARIO
        ) VALUES (
            v_IdPago, p_PagoInicial, fn_fecha_ddmmyyyy(), TIME_FORMAT(NOW(), '%H:%i:%s'),
            'Pago inicial', p_Id, p_IdMetodoPago, p_RegistradoPor
        );
    
    SET p_Resultado = 1; SET p_Mensaje = 'Mensualidad registrada.';
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_mensualidad_actualizar;

DROP PROCEDURE IF EXISTS usp_mensualidad_actualizar;

DELIMITER $$

CREATE PROCEDURE usp_mensualidad_actualizar(
    IN p_Id VARCHAR(50),
    IN p_IdUsuario VARCHAR(50),
    IN p_IdPlan VARCHAR(50),
    IN p_EstadoMiembro INT,
    IN p_FechaInicio CHAR(8),
    IN p_FechaFin CHAR(8),
    IN p_MontoTotal DECIMAL(10,2),
    IN p_IdAula VARCHAR(50),
    IN p_IdTutor VARCHAR(50),
    IN p_Observaciones LONGTEXT,
    IN p_FechaCancelacion CHAR(8),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = p_Id) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'La mensualidad no existe.'; LEAVE main;     END IF;

    IF p_EstadoMiembro NOT IN (2, 3) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Estado de mensualidad no válido.'; LEAVE main;     END IF;
    SELECT IDTURNO FROM `PLAN` WHERE IDPLAN = p_IdPlan INTO v_IdTurno;

    IF p_IdTutor IS NOT NULL AND p_IdTutor <> ''
       AND NOT EXISTS (SELECT 1 FROM TUTOR WHERE IDTUTOR = p_IdTutor AND ACTIVO = 1)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'El tutor seleccionado no es válido.'; LEAVE main; 
    UPDATE MENSUALIDAD SET
        IDUSUARIO        = p_IdUsuario,
        IDPLAN           = p_IdPlan,
        IDTURNO          = v_IdTurno,
        ESTADOMIEMBRO    = p_EstadoMiembro,
        FECHAINICIO      = p_FechaInicio,
        FECHAFIN         = p_FechaFin,
        MONTOTOTAL       = p_MontoTotal,
        IDAULA           = p_IdAula,
        IDTUTOR          = p_IdTutor,
        OBSERVACIONES    = p_Observaciones,
        FECHACANCELACION = p_FechaCancelacion
    WHERE IDMENSUALIDAD = p_Id;

    SET p_Resultado = 1; SET p_Mensaje = 'Mensualidad actualizada.';
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_mensualidad_listar;

DROP PROCEDURE IF EXISTS usp_mensualidad_listar;

DELIMITER $$

CREATE PROCEDURE usp_mensualidad_listar(
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
    SET @v_offset = (p_Pagina - 1) * p_TamanioPagina;
    IF p_Estado IS NULL OR p_Estado = '' THEN SET p_Estado = 'Activo'; END IF;

    SELECT COUNT(*) INTO p_TotalRegistros
    FROM MENSUALIDAD m
    INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
    INNER JOIN `PLAN` pl ON pl.IDPLAN = m.IDPLAN
    LEFT JOIN AULA au ON au.IDAULA = m.IDAULA
    LEFT JOIN TUTOR ase ON ase.IDTUTOR = m.IDTUTOR
    WHERE m.ESTADO = p_Estado
      AND (p_Buscar IS NULL OR p_Buscar = '' OR
           m.IDMENSUALIDAD LIKE CONCAT('%', p_Buscar, '%') OR
           u.DNI LIKE CONCAT('%', p_Buscar, '%') OR
           u.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
           u.APELLIDO LIKE CONCAT('%', p_Buscar, '%') OR
           pl.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
           IFNULL(au.NOMBRE, '') LIKE CONCAT('%', p_Buscar, '%') OR
           IFNULL(ase.NOMBRE, '') LIKE CONCAT('%', p_Buscar, '%'));

    SELECT
        m.IDMENSUALIDAD,
        m.IDUSUARIO,
        UPPER(TRIM(CONCAT(IFNULL(u.APELLIDO, ''), ' ', IFNULL(u.NOMBRE, '')))) AS ESTUDIANTE_NOMBRE,
        u.DNI AS ESTUDIANTE_DNI,
        m.IDPLAN,
        pl.NOMBRE AS PLAN_NOMBRE,
        IFNULL(tu.DESCRIPCION, '') AS TURNO_DESCRIPCION,
        m.ESTADOMIEMBRO,
        CASE m.ESTADOMIEMBRO
            WHEN 2 THEN 'Activo'
            WHEN 3 THEN 'Vencido'
            ELSE 'Activo'
        END AS ESTADOMIEMBRO_DESCRIPCION,
        m.FECHAINICIO,
        m.FECHAFIN,
        m.MONTOTOTAL,
        IFNULL(pag.PAGADO, 0) AS PAGADO,
        CASE
            WHEN IFNULL(m.MONTOTOTAL, 0) - IFNULL(pag.PAGADO, 0) < 0 THEN 0
            ELSE IFNULL(m.MONTOTOTAL, 0) - IFNULL(pag.PAGADO, 0)
        END AS DEUDA,
        IFNULL(au.NOMBRE, '') AS AULA_NOMBRE,
        m.IDTUTOR,
        IFNULL(ase.NOMBRE, IFNULL(m.TUTORLEGACY, '')) AS TUTOR_NOMBRE,
        m.ESTADO,
        m.FECHAREGISTRO
    FROM MENSUALIDAD m
    INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
    INNER JOIN `PLAN` pl ON pl.IDPLAN = m.IDPLAN
    LEFT JOIN TURNO tu ON tu.IDTURNO = IFNULL(pl.IDTURNO, m.IDTURNO)
    LEFT JOIN AULA au ON au.IDAULA = m.IDAULA
    LEFT JOIN TUTOR ase ON ase.IDTUTOR = m.IDTUTOR
    LEFT JOIN LATERAL (
        SELECT SUM(p.MONTO) AS PAGADO
        FROM PAGOMENSUALIDAD p
        WHERE p.IDMENSUALIDAD = m.IDMENSUALIDAD
        LIMIT 1
    ) pag ON TRUE
    WHERE m.ESTADO = p_Estado
      AND (p_Buscar IS NULL OR p_Buscar = '' OR
           m.IDMENSUALIDAD LIKE CONCAT('%', p_Buscar, '%') OR
           u.DNI LIKE CONCAT('%', p_Buscar, '%') OR
           u.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
           u.APELLIDO LIKE CONCAT('%', p_Buscar, '%') OR
           pl.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
           IFNULL(au.NOMBRE, '') LIKE CONCAT('%', p_Buscar, '%') OR
           IFNULL(ase.NOMBRE, '') LIKE CONCAT('%', p_Buscar, '%'))
    ORDER BY
        CASE WHEN p_OrdenarPor = 'IDMENSUALIDAD' AND p_Direccion = 'ASC'  THEN m.IDMENSUALIDAD END ASC,
        CASE WHEN p_OrdenarPor = 'IDMENSUALIDAD' AND p_Direccion = 'DESC' THEN m.IDMENSUALIDAD END DESC,
        CASE WHEN p_OrdenarPor = 'ESTUDIANTE_NOMBRE' AND p_Direccion = 'ASC'  THEN u.APELLIDO END ASC,
        CASE WHEN p_OrdenarPor = 'ESTUDIANTE_NOMBRE' AND p_Direccion = 'DESC' THEN u.APELLIDO END DESC,
        CASE WHEN p_OrdenarPor = 'FECHAINICIO' AND p_Direccion = 'ASC'  THEN m.FECHAINICIO END ASC,
        CASE WHEN p_OrdenarPor = 'FECHAINICIO' AND p_Direccion = 'DESC' THEN m.FECHAINICIO END DESC,
        CASE WHEN p_OrdenarPor = 'FECHAFIN' AND p_Direccion = 'ASC'  THEN m.FECHAFIN END ASC,
        CASE WHEN p_OrdenarPor = 'FECHAFIN' AND p_Direccion = 'DESC' THEN m.FECHAFIN END DESC,
        CASE WHEN p_OrdenarPor = 'MONTOTOTAL' AND p_Direccion = 'ASC'  THEN m.MONTOTOTAL END ASC,
        CASE WHEN p_OrdenarPor = 'MONTOTOTAL' AND p_Direccion = 'DESC' THEN m.MONTOTOTAL END DESC,
        CASE WHEN p_OrdenarPor = 'DEUDA' AND p_Direccion = 'ASC' THEN
            IFNULL(m.MONTOTOTAL, 0) - IFNULL(pag.PAGADO, 0) END ASC,
        CASE WHEN p_OrdenarPor = 'DEUDA' AND p_Direccion = 'DESC' THEN
            IFNULL(m.MONTOTOTAL, 0) - IFNULL(pag.PAGADO, 0) END DESC,
        CASE WHEN p_OrdenarPor = 'FECHAREGISTRO' AND p_Direccion = 'ASC'  THEN m.FECHAREGISTRO END ASC,
        CASE WHEN p_OrdenarPor = 'FECHAREGISTRO' AND p_Direccion = 'DESC' THEN m.FECHAREGISTRO END DESC,
        m.IDMENSUALIDAD DESC
    LIMIT p_TamanioPagina OFFSET @v_offset;
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_mensualidad_obtener;

DROP PROCEDURE IF EXISTS usp_mensualidad_obtener;

DELIMITER $$

CREATE PROCEDURE usp_mensualidad_obtener(
    IN p_Id VARCHAR(50)
)
main: BEGIN
SELECT
        m.IDMENSUALIDAD,
        m.IDUSUARIO,
        UPPER(TRIM(CONCAT(IFNULL(u.APELLIDO, ''), ' ', IFNULL(u.NOMBRE, '')))) AS ESTUDIANTE_NOMBRE,
        u.DNI AS ESTUDIANTE_DNI,
        m.IDPLAN,
        pl.NOMBRE AS PLAN_NOMBRE,
        IFNULL(tu.DESCRIPCION, '') AS TURNO_DESCRIPCION,
        m.ESTADOMIEMBRO,
        m.FECHAINICIO,
        m.FECHAFIN,
        m.MONTOTOTAL,
        m.IDAULA,
        IFNULL(au.NOMBRE, '') AS AULA_NOMBRE,
        m.IDTUTOR,
        IFNULL(ase.NOMBRE, IFNULL(m.TUTORLEGACY, '')) AS TUTOR_NOMBRE,
        m.OBSERVACIONES,
        m.FECHACANCELACION,
        m.ESTADO,
        m.FECHAREGISTRO,
        m.REGISTRADOPOR,
        IFNULL(pag.PAGOINICIAL, 0) AS PAGOINICIAL,
        pag.IDMETODOPAGO
    FROM MENSUALIDAD m
    INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
    INNER JOIN `PLAN` pl ON pl.IDPLAN = m.IDPLAN
    LEFT JOIN TURNO tu ON tu.IDTURNO = IFNULL(pl.IDTURNO, m.IDTURNO)
    LEFT JOIN AULA au ON au.IDAULA = m.IDAULA
    LEFT JOIN TUTOR ase ON ase.IDTUTOR = m.IDTUTOR
    LEFT JOIN LATERAL (
        SELECT p.MONTO AS PAGOINICIAL, p.IDMETODOPAGO
        FROM PAGOMENSUALIDAD p
        WHERE p.IDMENSUALIDAD = m.IDMENSUALIDAD
        ORDER BY p.FECHAPAGO, p.IDPAGOMENSUALIDAD
        LIMIT 1
    ) pag ON TRUE
    WHERE m.IDMENSUALIDAD = p_Id;
END$$

DELIMITER ;