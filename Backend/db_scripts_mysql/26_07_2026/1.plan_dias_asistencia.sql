-- Convertido automáticamente desde db_scripts/26_07_2026/1.plan_dias_asistencia.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   PLAN: días de asistencia por plan (bitmask lun=1, mar=2, … dom=64)
   Afecta informe de asistencias y referencia en horarios.
   Ejecutar después de 16_07_2026/11.plan_costo_mensual.sql
   Fecha: 26/07/2026
   ============================================================================ */

SET @col_PLAN_DIASASISTENCIA := (
    SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'PLAN' AND COLUMN_NAME = 'DIASASISTENCIA'
);
SET @sql_PLAN_DIASASISTENCIA := IF(@col_PLAN_DIASASISTENCIA = 0, 'ALTER TABLE `PLAN` ADD DIASASISTENCIA TINYINT NOT NULL
        CONSTRAINT DF_PLAN_DIASASISTENCIA DEFAULT (63)', 'SELECT 1');
PREPARE stmt FROM @sql_PLAN_DIASASISTENCIA; EXECUTE stmt; DEALLOCATE PREPARE stmt;
UPDATE `PLAN`
SET DIASASISTENCIA = 63
WHERE DIASASISTENCIA IS NULL OR DIASASISTENCIA = 0;

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
    DECLARE v_offset INT DEFAULT 0;
IF p_Pagina < 1 THEN SET p_Pagina = 1; END IF;
    IF p_TamanioPagina < 1 THEN SET p_TamanioPagina = 10; END IF;

    SET v_offset = (p_Pagina - 1) * p_TamanioPagina;
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
        CASE WHEN p.ACTIVO = 1 THEN 'Activo' ELSE 'Inactivo' END AS ESTADO
    FROM `PLAN` p
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
    LIMIT p_TamanioPagina OFFSET v_offset;
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
        CASE WHEN p.ACTIVO = 1 THEN 'Activo' ELSE 'Inactivo' END AS ESTADO
    FROM `PLAN` p
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

    IF EXISTS (SELECT 1 FROM `PLAN` WHERE IDPLAN = p_Id)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'El código de plan ya existe.'; LEAVE main; 
    END IF;

    IF EXISTS (SELECT 1 FROM `PLAN` WHERE NOMBRE = p_Nombre)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'Ya existe un plan con ese nombre.'; LEAVE main; 
    INSERT INTO `PLAN` (IDPLAN, NOMBRE, DESCRIPCION, COSTOMENSUAL, DIASASISTENCIA, ACTIVO)
    VALUES (
        p_Id,
        p_Nombre,
        p_Descripcion,
        p_CostoMensual,
        p_DiasAsistencia,
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

    IF EXISTS (SELECT 1 FROM `PLAN` WHERE NOMBRE = p_Nombre AND IDPLAN <> p_Id)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'Ya existe un plan con ese nombre.'; LEAVE main; 
    UPDATE `PLAN` SET
        NOMBRE          = p_Nombre,
        DESCRIPCION     = p_Descripcion,
        COSTOMENSUAL    = p_CostoMensual,
        DIASASISTENCIA  = p_DiasAsistencia,
        ACTIVO          = CASE WHEN p_Estado = 'Activo' THEN 1 ELSE 0 END
    WHERE IDPLAN = p_Id;

    SET p_Resultado = 1; SET p_Mensaje = 'Plan actualizado.';
    SELECT p_Resultado AS Resultado, p_Mensaje AS Mensaje
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_asistencia_informe;

DROP PROCEDURE IF EXISTS usp_asistencia_informe;

DELIMITER $$

CREATE PROCEDURE usp_asistencia_informe(
    IN p_FechaDesde CHAR(8),
    IN p_FechaHasta CHAR(8),
    IN p_Buscar VARCHAR(200),
    IN p_IDPlan VARCHAR(20),
    IN p_EstadoUsuario VARCHAR(50)
)
main: BEGIN
IF p_FechaDesde IS NULL OR p_FechaDesde = '' OR p_FechaHasta IS NULL OR p_FechaHasta = '' THEN
        RAISERROR('Debe indicar fecha desde y fecha hasta.', 16, 1);
        LEAVE main;
    
    END IF;

    IF p_FechaDesde > p_FechaHasta THEN
        RAISERROR('La fecha desde no puede ser mayor que la fecha hasta.', 16, 1);
        LEAVE main;
    
    SELECT
        u.IDUSUARIO,
        UPPER(TRIM(
            CONCAT(IFNULL(u.APELLIDO, ''), ' ') + IFNULL(u.NOMBRE, '')
        ))) AS NOMBRE_COMPLETO,
        UPPER(IFNULL(u.ESTADO, 'Activo')) AS ESTADO,
        UPPER(IFNULL(tut.NOMBRE, '')) AS TUTORA,
        IFNULL(au.NOMBRE, '') AS AULA,
        CONCAT(UPPER(TRIM(
            IFNULL(pl.NOMBRE, ''), CASE) WHEN tu.DESCRIPCION IS NOT NULL AND tu.DESCRIPCION <> ''
                 THEN CONCAT(' ', tu.DESCRIPCION) ELSE '' 
        ))) AS CICLO,
        mem.FECHAINICIO AS FECHA_INICIO_MEM,
        mem.FECHAFIN AS FECHA_VENCE,
        mem.IDPLAN,
        IFNULL(pl.DIASASISTENCIA, 63) AS DIASASISTENCIA
    FROM USUARIO u
    OUTER APPLY (
        SELECT TOP 1 m.IDAULA, m.IDPLAN, m.IDTURNO, m.FECHAINICIO, m.FECHAFIN
        FROM MEMBRESIA m
        WHERE m.IDUSUARIO = u.IDUSUARIO
          AND (m.ESTADO IS NULL OR m.ESTADO = 'Activo')
        ORDER BY
            CASE
                WHEN (m.FECHAINICIO IS NULL OR m.FECHAINICIO <= p_FechaHasta)
                 AND (m.FECHAFIN IS NULL OR m.FECHAFIN >= p_FechaDesde)
                THEN 0 ELSE 1
            END,
            m.FECHAREGISTRO DESC,
            m.FECHAINICIO DESC
    ) mem
    LEFT JOIN AULA au ON au.IDAULA = mem.IDAULA
    LEFT JOIN USUARIO tut ON tut.IDUSUARIO = au.IDTUTORA
    LEFT JOIN `PLAN` pl ON pl.IDPLAN = mem.IDPLAN
    LEFT JOIN TURNO tu ON tu.IDTURNO = mem.IDTURNO
    WHERE u.IDTIPOUSUARIO = '1'
      AND (
          p_EstadoUsuario IS NULL OR p_EstadoUsuario = '' OR
          UPPER(IFNULL(u.ESTADO, 'Activo')) = UPPER(p_EstadoUsuario)
      )
      AND (
          p_IDPlan IS NULL OR p_IDPlan = '' OR mem.IDPLAN = p_IDPlan
      )
      AND (
          p_Buscar IS NULL OR p_Buscar = '' OR
          u.DNI LIKE CONCAT('%', p_Buscar, '%') OR
          u.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
          u.APELLIDO LIKE CONCAT('%', p_Buscar, '%') OR
          u.IDUSUARIO LIKE CONCAT('%', p_Buscar, '%') OR
          IFNULL(au.NOMBRE, '') LIKE CONCAT('%', p_Buscar, '%')
      )
    ORDER BY u.APELLIDO, u.NOMBRE;

    SELECT
        a.IDUSUARIO,
        a.FECHAREGISTRO,
        a.ESTADO,
        a.JUSTIFICADO
    FROM ASISTENCIA a
    INNER JOIN USUARIO u ON u.IDUSUARIO = a.IDUSUARIO
    WHERE u.IDTIPOUSUARIO = '1'
      AND a.FECHAREGISTRO >= p_FechaDesde
      AND a.FECHAREGISTRO <= p_FechaHasta
      AND (
          p_EstadoUsuario IS NULL OR p_EstadoUsuario = '' OR
          UPPER(IFNULL(u.ESTADO, 'Activo')) = UPPER(p_EstadoUsuario)
      )
      AND (
          p_IDPlan IS NULL OR p_IDPlan = '' OR
          EXISTS (
              SELECT 1
              FROM MEMBRESIA m
              WHERE m.IDUSUARIO = u.IDUSUARIO
                AND m.IDPLAN = p_IDPlan
                AND (m.ESTADO IS NULL OR m.ESTADO = 'Activo')
                AND (m.FECHAINICIO IS NULL OR m.FECHAINICIO <= p_FechaHasta)
                AND (m.FECHAFIN IS NULL OR m.FECHAFIN >= p_FechaDesde)
          )
      )
      AND (
          p_Buscar IS NULL OR p_Buscar = '' OR
          u.DNI LIKE CONCAT('%', p_Buscar, '%') OR
          u.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
          u.APELLIDO LIKE CONCAT('%', p_Buscar, '%') OR
          u.IDUSUARIO LIKE CONCAT('%', p_Buscar, '%')
      );
END;

SELECT 'PLAN.DIASASISTENCIA, usp_plan_* y usp_asistencia_informe actualizados.';
END$$

DELIMITER ;