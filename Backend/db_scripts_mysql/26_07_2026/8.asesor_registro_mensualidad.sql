-- Convertido automáticamente desde db_scripts/26_07_2026/8.asesor_registro_mensualidad.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   ASESOR (registro de mensualidades) + nombre registrador en mensualidad
   Ejecutar después de 6.plan_turno.sql (o 7.plan_nombres_sin_turno.sql)
   Fecha: 26/07/2026

   Nota: TUTOR es distinto (asignación académica). ASESOR cataloga personal
   que registra mensualidades; MENSUALIDAD.REGISTRADOPOR = usuario logueado.
   ============================================================================ */

/* PLAN.IDTURNO — requerido por usp_mensualidad_* (script 6) */
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
SET @sql_FK_PLAN_TURNO := IF(@fk_FK_PLAN_TURNO = 0, 'ALTER TABLE `PLAN` ADD CONSTRAINT FK_PLAN_TURNO
        FOREIGN KEY (IDTURNO) REFERENCES TURNO(IDTURNO)', 'SELECT 1');
PREPARE stmt FROM @sql_FK_PLAN_TURNO; EXECUTE stmt; DEALLOCATE PREPARE stmt;
UPDATE `PLAN` SET IDTURNO = 'TUR002' WHERE IDPLAN IN ('PLN002', 'PLN006') AND IDTURNO IS NULL;
UPDATE `PLAN` SET IDTURNO = 'TUR001' WHERE IDTURNO IS NULL;

-- create if missing ASESOR
    CREATE TABLE IF NOT EXISTS ASESOR (
        IDASESOR    VARCHAR(50)   NOT NULL PRIMARY KEY,
        NOMBRE      VARCHAR(150)  NOT NULL,
        IDUSUARIO   VARCHAR(50)   NULL,
        ACTIVO      TINYINT(1)            NOT NULL DEFAULT 1
    );
    SELECT 'Tabla ASESOR creada.';

SET @col_ASESOR_IDUSUARIO := (
    SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'ASESOR' AND COLUMN_NAME = 'IDUSUARIO'
);
SET @sql_ASESOR_IDUSUARIO := IF(@col_ASESOR_IDUSUARIO = 0, 'ALTER TABLE ASESOR ADD IDUSUARIO VARCHAR(50) NULL', 'SELECT 1');
PREPARE stmt FROM @sql_ASESOR_IDUSUARIO; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @fk_FK_ASESOR_USUARIO := (
    SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_SCHEMA = DATABASE() AND CONSTRAINT_NAME = 'FK_ASESOR_USUARIO'
);
SET @sql_FK_ASESOR_USUARIO := IF(@fk_FK_ASESOR_USUARIO = 0, 'ALTER TABLE ASESOR ADD CONSTRAINT FK_ASESOR_USUARIO
        FOREIGN KEY (IDUSUARIO) REFERENCES USUARIO(IDUSUARIO)', 'SELECT 1');
PREPARE stmt FROM @sql_FK_ASESOR_USUARIO; EXECUTE stmt; DEALLOCATE PREPARE stmt;
INSERT IGNORE INTO ASESOR (IDASESOR, NOMBRE, ACTIVO) VALUES
    ('ASE001', 'Asesor 1', 1),
    ('ASE002', 'Asesor 2', 1);
/* ---- usp_asesor_* ---- */

DROP PROCEDURE IF EXISTS usp_asesor_listar;

DROP PROCEDURE IF EXISTS usp_asesor_listar;

DELIMITER $$

CREATE PROCEDURE usp_asesor_listar(
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
    FROM ASESOR a
    LEFT JOIN USUARIO u ON u.IDUSUARIO = a.IDUSUARIO
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           a.IDASESOR LIKE CONCAT('%', p_Buscar, '%') OR
           a.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
           IFNULL(a.IDUSUARIO, '') LIKE CONCAT('%', p_Buscar, '%'))
      AND (p_Estado IS NULL OR p_Estado = '' OR
           (p_Estado = 'Activo' AND a.ACTIVO = 1) OR
           (p_Estado = 'Inactivo' AND a.ACTIVO = 0));

    SELECT
        a.IDASESOR,
        a.NOMBRE,
        a.IDUSUARIO,
        CONCAT(IFNULL(u.NOMBRE, ''), CASE WHEN u.APELLIDO IS NOT NULL THEN CONCAT(' ', u.APELLIDO) ELSE '' END) AS USUARIO_NOMBRE,
        CASE WHEN a.ACTIVO = 1 THEN 'Activo' ELSE 'Inactivo' END AS ESTADO
    FROM ASESOR a
    LEFT JOIN USUARIO u ON u.IDUSUARIO = a.IDUSUARIO
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           a.IDASESOR LIKE CONCAT('%', p_Buscar, '%') OR
           a.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
           IFNULL(a.IDUSUARIO, '') LIKE CONCAT('%', p_Buscar, '%'))
      AND (p_Estado IS NULL OR p_Estado = '' OR
           (p_Estado = 'Activo' AND a.ACTIVO = 1) OR
           (p_Estado = 'Inactivo' AND a.ACTIVO = 0))
    ORDER BY
        CASE WHEN p_OrdenarPor = 'IDASESOR' AND p_Direccion = 'ASC'  THEN a.IDASESOR END ASC,
        CASE WHEN p_OrdenarPor = 'IDASESOR' AND p_Direccion = 'DESC' THEN a.IDASESOR END DESC,
        CASE WHEN p_OrdenarPor = 'NOMBRE' AND p_Direccion = 'ASC'  THEN a.NOMBRE END ASC,
        CASE WHEN p_OrdenarPor = 'NOMBRE' AND p_Direccion = 'DESC' THEN a.NOMBRE END DESC,
        a.NOMBRE
    LIMIT p_TamanioPagina OFFSET v_offset;
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_asesor_obtener;

DROP PROCEDURE IF EXISTS usp_asesor_obtener;

DELIMITER $$

CREATE PROCEDURE usp_asesor_obtener(
    IN p_Id VARCHAR(50)
)
main: BEGIN
SELECT
        a.IDASESOR,
        a.NOMBRE,
        a.IDUSUARIO,
        CASE WHEN a.ACTIVO = 1 THEN 'Activo' ELSE 'Inactivo' END AS ESTADO
    FROM ASESOR a
    WHERE a.IDASESOR = p_Id;
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_asesor_insertar;

DROP PROCEDURE IF EXISTS usp_asesor_insertar;

DELIMITER $$

CREATE PROCEDURE usp_asesor_insertar(
    IN p_Id VARCHAR(50),
    IN p_Nombre VARCHAR(150),
    IN p_IdUsuario VARCHAR(50),
    IN p_Estado VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
IF p_Id IS NULL OR TRIM(p_Id) = '' THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa el código del asesor.'; LEAVE main;     END IF;

    IF p_Nombre IS NULL OR TRIM(p_Nombre) = '' THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa el nombre del asesor.'; LEAVE main;     END IF;

    IF p_IdUsuario IS NOT NULL AND p_IdUsuario <> ''
       AND NOT EXISTS (SELECT 1 FROM USUARIO WHERE IDUSUARIO = p_IdUsuario)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'El usuario vinculado no existe.'; LEAVE main; 
    END IF;

    IF EXISTS (SELECT 1 FROM ASESOR WHERE IDASESOR = p_Id) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'El código de asesor ya existe.'; LEAVE main;     END IF;

    IF EXISTS (SELECT 1 FROM ASESOR WHERE NOMBRE = p_Nombre) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ya existe un asesor con ese nombre.'; LEAVE main;     END IF;

    IF p_IdUsuario IS NOT NULL AND p_IdUsuario <> ''
       AND EXISTS (SELECT 1 FROM ASESOR WHERE IDUSUARIO = p_IdUsuario AND ACTIVO = 1)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'Ese usuario ya está vinculado a otro asesor activo.'; LEAVE main; 
    INSERT INTO ASESOR (IDASESOR, NOMBRE, IDUSUARIO, ACTIVO)
    VALUES (p_Id, p_Nombre, NULLIF(p_IdUsuario, ''), CASE WHEN p_Estado = 'Activo' THEN 1 ELSE 0 END);

    SET p_Resultado = 1; SET p_Mensaje = 'Asesor registrado.';
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_asesor_actualizar;

DROP PROCEDURE IF EXISTS usp_asesor_actualizar;

DELIMITER $$

CREATE PROCEDURE usp_asesor_actualizar(
    IN p_Id VARCHAR(50),
    IN p_Nombre VARCHAR(150),
    IN p_IdUsuario VARCHAR(50),
    IN p_Estado VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
IF NOT EXISTS (SELECT 1 FROM ASESOR WHERE IDASESOR = p_Id) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'El asesor no existe.'; LEAVE main;     END IF;

    IF p_Nombre IS NULL OR TRIM(p_Nombre) = '' THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa el nombre del asesor.'; LEAVE main;     END IF;

    IF p_IdUsuario IS NOT NULL AND p_IdUsuario <> ''
       AND NOT EXISTS (SELECT 1 FROM USUARIO WHERE IDUSUARIO = p_IdUsuario)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'El usuario vinculado no existe.'; LEAVE main; 
    END IF;

    IF EXISTS (SELECT 1 FROM ASESOR WHERE NOMBRE = p_Nombre AND IDASESOR <> p_Id) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ya existe un asesor con ese nombre.'; LEAVE main;     END IF;

    IF p_IdUsuario IS NOT NULL AND p_IdUsuario <> ''
       AND EXISTS (SELECT 1 FROM ASESOR WHERE IDUSUARIO = p_IdUsuario AND IDASESOR <> p_Id AND ACTIVO = 1)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'Ese usuario ya está vinculado a otro asesor activo.'; LEAVE main; 
    UPDATE ASESOR SET
        NOMBRE    = p_Nombre,
        IDUSUARIO = NULLIF(p_IdUsuario, ''),
        ACTIVO    = CASE WHEN p_Estado = 'Activo' THEN 1 ELSE 0 END
    WHERE IDASESOR = p_Id;

    SET p_Resultado = 1; SET p_Mensaje = 'Asesor actualizado.';
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_asesor_eliminar;

DROP PROCEDURE IF EXISTS usp_asesor_eliminar;

DELIMITER $$

CREATE PROCEDURE usp_asesor_eliminar(
    IN p_Id VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
IF NOT EXISTS (SELECT 1 FROM ASESOR WHERE IDASESOR = p_Id) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'El asesor no existe.'; LEAVE main;     END IF;
    DELETE FROM ASESOR WHERE IDASESOR = p_Id;
    SET p_Resultado = 1; SET p_Mensaje = 'Asesor eliminado.';
END;

/* ---- Mensualidad: nombre del asesor (usuario registrador) ---- */
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
    DECLARE v_offset INT DEFAULT 0;
IF p_Pagina < 1 THEN SET p_Pagina = 1; END IF;
    IF p_TamanioPagina < 1 THEN SET p_TamanioPagina = 10; END IF;
    SET v_offset = (p_Pagina - 1) * p_TamanioPagina;
    IF p_Estado IS NULL OR p_Estado = '' THEN SET p_Estado = 'Activo'; END IF;

    SELECT COUNT(*) INTO p_TotalRegistros
    FROM MENSUALIDAD m
    INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
    INNER JOIN `PLAN` pl ON pl.IDPLAN = m.IDPLAN
    LEFT JOIN AULA au ON au.IDAULA = m.IDAULA
    LEFT JOIN TUTOR tut ON tut.IDTUTOR = m.IDTUTOR
    WHERE m.ESTADO = p_Estado
      AND (p_Buscar IS NULL OR p_Buscar = '' OR
           m.IDMENSUALIDAD LIKE CONCAT('%', p_Buscar, '%') OR
           u.DNI LIKE CONCAT('%', p_Buscar, '%') OR
           u.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
           u.APELLIDO LIKE CONCAT('%', p_Buscar, '%') OR
           pl.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
           IFNULL(au.NOMBRE, '') LIKE CONCAT('%', p_Buscar, '%') OR
           IFNULL(tut.NOMBRE, '') LIKE CONCAT('%', p_Buscar, '%'));

    SELECT
        m.IDMENSUALIDAD,
        m.IDUSUARIO,
        UPPER(TRIM(CONCAT(IFNULL(u.APELLIDO, ''), ' ', IFNULL(u.NOMBRE, '')))) AS ESTUDIANTE_NOMBRE,
        u.DNI AS ESTUDIANTE_DNI,
        m.IDPLAN,
        pl.NOMBRE AS PLAN_NOMBRE,
        IFNULL(tu.DESCRIPCION, '') AS TURNO_DESCRIPCION,
        m.ESTADOMIEMBRO,
        CASE m.ESTADOMIEMBRO WHEN 2 THEN 'Activo' WHEN 3 THEN 'Vencido' ELSE 'Activo' END AS ESTADOMIEMBRO_DESCRIPCION,
        m.FECHAINICIO,
        m.FECHAFIN,
        m.MONTOTOTAL,
        IFNULL(pag.PAGADO, 0) AS PAGADO,
        CASE WHEN IFNULL(m.MONTOTOTAL, 0) - IFNULL(pag.PAGADO, 0) < 0 THEN 0
             ELSE IFNULL(m.MONTOTOTAL, 0) - IFNULL(pag.PAGADO, 0) END AS DEUDA,
        IFNULL(au.NOMBRE, '') AS AULA_NOMBRE,
        m.IDTUTOR,
        IFNULL(tut.NOMBRE, IFNULL(m.TUTORLEGACY, '')) AS TUTOR_NOMBRE,
        m.REGISTRADOPOR,
        UPPER(TRIM(
            COALESCE(
                (SELECT a.NOMBRE FROM ASESOR a WHERE a.IDUSUARIO = m.REGISTRADOPOR AND a.ACTIVO = 1),
                CONCAT(IFNULL(reg.APELLIDO, ''), ' ', IFNULL(reg.NOMBRE, ''))
            )
        ))) AS ASESOR_NOMBRE,
        m.ESTADO,
        m.FECHAREGISTRO
    FROM MENSUALIDAD m
    INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
    INNER JOIN `PLAN` pl ON pl.IDPLAN = m.IDPLAN
    LEFT JOIN TURNO tu ON tu.IDTURNO = IFNULL(pl.IDTURNO, m.IDTURNO)
    LEFT JOIN AULA au ON au.IDAULA = m.IDAULA
    LEFT JOIN TUTOR tut ON tut.IDTUTOR = m.IDTUTOR
    LEFT JOIN USUARIO reg ON reg.IDUSUARIO = m.REGISTRADOPOR
    LEFT JOIN LATERAL (
        SELECT SUM(p.MONTO) AS PAGADO FROM PAGOMENSUALIDAD p WHERE p.IDMENSUALIDAD = m.IDMENSUALIDAD
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
           IFNULL(tut.NOMBRE, '') LIKE CONCAT('%', p_Buscar, '%'))
    ORDER BY
        CASE WHEN p_OrdenarPor = 'FECHAREGISTRO' AND p_Direccion = 'DESC' THEN m.FECHAREGISTRO END DESC,
        m.IDMENSUALIDAD DESC
    LIMIT p_TamanioPagina OFFSET v_offset;
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
        IFNULL(tut.NOMBRE, IFNULL(m.TUTORLEGACY, '')) AS TUTOR_NOMBRE,
        m.OBSERVACIONES,
        m.FECHACANCELACION,
        m.ESTADO,
        m.FECHAREGISTRO,
        m.REGISTRADOPOR,
        UPPER(TRIM(
            COALESCE(
                (SELECT a.NOMBRE FROM ASESOR a WHERE a.IDUSUARIO = m.REGISTRADOPOR AND a.ACTIVO = 1),
                CONCAT(IFNULL(reg.APELLIDO, ''), ' ', IFNULL(reg.NOMBRE, ''))
            )
        ))) AS ASESOR_NOMBRE,
        IFNULL(pag.PAGOINICIAL, 0) AS PAGOINICIAL,
        pag.IDMETODOPAGO
    FROM MENSUALIDAD m
    INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
    INNER JOIN `PLAN` pl ON pl.IDPLAN = m.IDPLAN
    LEFT JOIN TURNO tu ON tu.IDTURNO = IFNULL(pl.IDTURNO, m.IDTURNO)
    LEFT JOIN AULA au ON au.IDAULA = m.IDAULA
    LEFT JOIN TUTOR tut ON tut.IDTUTOR = m.IDTUTOR
    LEFT JOIN USUARIO reg ON reg.IDUSUARIO = m.REGISTRADOPOR
    LEFT JOIN LATERAL (
        SELECT p.MONTO AS PAGOINICIAL, p.IDMETODOPAGO
        FROM PAGOMENSUALIDAD p
        WHERE p.IDMENSUALIDAD = m.IDMENSUALIDAD
        ORDER BY p.FECHAPAGO, p.IDPAGOMENSUALIDAD
        LIMIT 1
    ) pag ON TRUE
    WHERE m.IDMENSUALIDAD = p_Id;
END;

/* Menú mantenedor asesores */
IF NOT EXISTS (SELECT 1 FROM SUBMODULO WHERE IDSUBMODULO = 'SUB024') THEN
    INSERT INTO SUBMODULO (IDSUBMODULO, NOMBRE, DESCRIPCION, ICONO, ORDEN, ACTIVO, IDMODULO)
    VALUES ('SUB024', 'Asesores', 'Personal que registra mensualidades', 'faIdBadge', 4, 1, 'MOD011');
    SELECT 'SUB024 (Asesores) creado.';

ELSE
    UPDATE SUBMODULO SET NOMBRE = 'Asesores', DESCRIPCION = 'Personal que registra mensualidades', ACTIVO = 1
    WHERE IDSUBMODULO = 'SUB024';

SELECT 'ASESOR, usp_asesor_* y ASESOR_NOMBRE en mensualidad listos.';
END$$

DELIMITER ;