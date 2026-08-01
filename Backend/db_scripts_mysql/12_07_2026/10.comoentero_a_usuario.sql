-- Convertido automáticamente desde db_scripts/12_07_2026/10.comoentero_a_usuario.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   Mueve COMOENTERO de MEMBRESIA a USUARIO
   Ejecutar después de 9.usp_pago_membresias_prefills.sql
   Fecha: 12/07/2026
   ============================================================================ */

-- 1) Columna en usuario
SET @col_USUARIO_COMOENTERO := (
    SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'USUARIO' AND COLUMN_NAME = 'COMOENTERO'
);
SET @sql_USUARIO_COMOENTERO := IF(@col_USUARIO_COMOENTERO = 0, 'ALTER TABLE USUARIO ADD COMOENTERO VARCHAR(100) NULL', 'SELECT 1');
PREPARE stmt FROM @sql_USUARIO_COMOENTERO; EXECUTE stmt; DEALLOCATE PREPARE stmt;
-- 2) Migrar desde la membresía más reciente de cada usuario
UPDATE u
SET u.COMOENTERO = m.COMOENTERO
FROM USUARIO u
INNER JOIN (
    SELECT m.IDUSUARIO, m.COMOENTERO,
           ROW_NUMBER() OVER (PARTITION BY m.IDUSUARIO ORDER BY m.FECHAREGISTRO DESC, m.IDMEMBRESIA DESC) AS rn
    FROM MEMBRESIA m
    WHERE m.COMOENTERO IS NOT NULL AND TRIM(m.COMOENTERO)) <> ''
) m ON m.IDUSUARIO = u.IDUSUARIO AND m.rn = 1
WHERE u.COMOENTERO IS NULL OR TRIM(u.COMOENTERO)) = '';

-- 3) SPs usuario

DROP PROCEDURE IF EXISTS usp_usuario_obtener;

DROP PROCEDURE IF EXISTS usp_usuario_obtener;

DELIMITER $$

CREATE PROCEDURE usp_usuario_obtener(
    IN p_Id VARCHAR(50)
)
main: BEGIN
SELECT
        u.IDUSUARIO,
        u.NOMBRE,
        u.APELLIDO,
        u.DNI,
        u.EMAIL,
        u.ESTADO,
        u.IDTIPOUSUARIO,
        t.DESCRIPCION AS TIPOUSUARIO_DESCRIPCION,
        u.FECHANACIMIENTO,
        u.DIRECCION,
        u.DISTRITO,
        u.COLEGIO,
        u.GRADO,
        u.FECHAACTIVO,
        u.TELPERSONAL,
        u.TELAPODERADO,
        u.NOMBREAPODERADO,
        u.PARENTESCO,
        u.SITUACIONACADEMICA,
        u.COMOENTERO,
        u.FOTO
    FROM USUARIO u
    INNER JOIN TIPOUSUARIO t ON t.IDTIPOUSUARIO = u.IDTIPOUSUARIO
    WHERE u.IDUSUARIO = p_Id;
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_usuario_insertar;

DROP PROCEDURE IF EXISTS usp_usuario_insertar;

DELIMITER $$

CREATE PROCEDURE usp_usuario_insertar(
    IN p_Id VARCHAR(50),
    IN p_Contra VARCHAR(255),
    IN p_Nombre VARCHAR(100),
    IN p_Apellido VARCHAR(100),
    IN p_Dni VARCHAR(20),
    IN p_Email VARCHAR(150),
    IN p_IdTipoUsuario VARCHAR(50),
    IN p_Estado VARCHAR(50),
    IN p_FechaNacimiento CHAR(8),
    IN p_Direccion VARCHAR(255),
    IN p_Distrito VARCHAR(100),
    IN p_Colegio VARCHAR(150),
    IN p_Grado VARCHAR(50),
    IN p_TelPersonal VARCHAR(20),
    IN p_TelApoderado VARCHAR(20),
    IN p_NombreApoderado VARCHAR(200),
    IN p_Parentesco VARCHAR(50),
    IN p_SituacionAcademica VARCHAR(100),
    IN p_ComoEntero VARCHAR(100),
    IN p_Foto LONGTEXT,
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
IF EXISTS (SELECT 1 FROM USUARIO WHERE IDUSUARIO = p_Id)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'El usuario ya existe.'; LEAVE main; 
    END IF;

    IF EXISTS (SELECT 1 FROM USUARIO WHERE DNI = p_Dni)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'El DNI ya está registrado.'; LEAVE main; 
    END IF;

    IF EXISTS (SELECT 1 FROM USUARIO WHERE EMAIL = p_Email)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'El email ya está registrado.'; LEAVE main; 
    END IF;

    IF NOT EXISTS (SELECT 1 FROM TIPOUSUARIO WHERE IDTIPOUSUARIO = p_IdTipoUsuario)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'Tipo de usuario no válido.'; LEAVE main; 
    INSERT INTO USUARIO (
        IDUSUARIO, CONTRA, NOMBRE, APELLIDO, DNI, EMAIL, IDTIPOUSUARIO, ESTADO,
        FECHANACIMIENTO, DIRECCION, DISTRITO, COLEGIO, GRADO,
        TELPERSONAL, TELAPODERADO, NOMBREAPODERADO, PARENTESCO,
        SITUACIONACADEMICA, COMOENTERO, FECHAACTIVO, FOTO
    ) VALUES (
        p_Id, p_Contra, p_Nombre, p_Apellido, p_Dni, p_Email, p_IdTipoUsuario, p_Estado,
        p_FechaNacimiento, p_Direccion, p_Distrito, p_Colegio, p_Grado,
        p_TelPersonal, p_TelApoderado, p_NombreApoderado, p_Parentesco,
        p_SituacionAcademica, p_ComoEntero, fn_fecha_ddmmyyyy(), p_Foto
    );

    SET p_Resultado = 1; SET p_Mensaje = 'Usuario creado.';
    SELECT p_Resultado AS Resultado, p_Mensaje AS Mensaje
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_usuario_actualizar;

DROP PROCEDURE IF EXISTS usp_usuario_actualizar;

DELIMITER $$

CREATE PROCEDURE usp_usuario_actualizar(
    IN p_Id VARCHAR(50),
    IN p_Contra VARCHAR(255),
    IN p_Nombre VARCHAR(100),
    IN p_Apellido VARCHAR(100),
    IN p_Dni VARCHAR(20),
    IN p_Email VARCHAR(150),
    IN p_IdTipoUsuario VARCHAR(50),
    IN p_Estado VARCHAR(50),
    IN p_FechaNacimiento CHAR(8),
    IN p_Direccion VARCHAR(255),
    IN p_Distrito VARCHAR(100),
    IN p_Colegio VARCHAR(150),
    IN p_Grado VARCHAR(50),
    IN p_TelPersonal VARCHAR(20),
    IN p_TelApoderado VARCHAR(20),
    IN p_NombreApoderado VARCHAR(200),
    IN p_Parentesco VARCHAR(50),
    IN p_SituacionAcademica VARCHAR(100),
    IN p_ComoEntero VARCHAR(100),
    IN p_Foto LONGTEXT,
    IN p_ActualizarFoto TINYINT(1),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
IF NOT EXISTS (SELECT 1 FROM USUARIO WHERE IDUSUARIO = p_Id)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'El usuario no existe.'; LEAVE main; 
    END IF;

    IF EXISTS (SELECT 1 FROM USUARIO WHERE DNI = p_Dni AND IDUSUARIO <> p_Id)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'El DNI ya está registrado.'; LEAVE main; 
    END IF;

    IF EXISTS (SELECT 1 FROM USUARIO WHERE EMAIL = p_Email AND IDUSUARIO <> p_Id)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'El email ya está registrado.'; LEAVE main; 
    UPDATE USUARIO SET
        NOMBRE             = p_Nombre,
        APELLIDO           = p_Apellido,
        DNI                = p_Dni,
        EMAIL              = p_Email,
        IDTIPOUSUARIO      = p_IdTipoUsuario,
        ESTADO             = p_Estado,
        FECHANACIMIENTO    = p_FechaNacimiento,
        DIRECCION          = p_Direccion,
        DISTRITO           = p_Distrito,
        COLEGIO            = p_Colegio,
        GRADO              = p_Grado,
        TELPERSONAL        = p_TelPersonal,
        TELAPODERADO       = p_TelApoderado,
        NOMBREAPODERADO    = p_NombreApoderado,
        PARENTESCO         = p_Parentesco,
        SITUACIONACADEMICA = p_SituacionAcademica,
        COMOENTERO         = p_ComoEntero,
        CONTRA             = CASE WHEN p_Contra IS NOT NULL AND p_Contra <> '' THEN p_Contra ELSE CONTRA END,
        FOTO               = CASE WHEN p_ActualizarFoto = 1 THEN p_Foto ELSE FOTO 
    WHERE IDUSUARIO = p_Id;

    SET p_Resultado = 1; SET p_Mensaje = 'Usuario actualizado.';
END;

-- 4) SPs membresía sin COMOENTERO
    SELECT p_Resultado AS Resultado, p_Mensaje AS Mensaje
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_membresia_listar;

DROP PROCEDURE IF EXISTS usp_membresia_listar;

DELIMITER $$

CREATE PROCEDURE usp_membresia_listar(
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
    FROM MEMBRESIA m
    INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
    INNER JOIN `PLAN` pl ON pl.IDPLAN = m.IDPLAN
    LEFT JOIN AULA au ON au.IDAULA = m.IDAULA
    LEFT JOIN TURNO tu ON tu.IDTURNO = m.IDTURNO
    LEFT JOIN ASESOR ase ON ase.IDASESOR = m.IDASESOR
    WHERE m.ESTADO = p_Estado
      AND (p_Buscar IS NULL OR p_Buscar = '' OR
           m.IDMEMBRESIA LIKE CONCAT('%', p_Buscar, '%') OR
           u.DNI LIKE CONCAT('%', p_Buscar, '%') OR
           u.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
           u.APELLIDO LIKE CONCAT('%', p_Buscar, '%') OR
           pl.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
           IFNULL(au.NOMBRE, '') LIKE CONCAT('%', p_Buscar, '%') OR
           IFNULL(ase.NOMBRE, '') LIKE CONCAT('%', p_Buscar, '%'));

    SELECT
        m.IDMEMBRESIA,
        m.IDUSUARIO,
        UPPER(TRIM(CONCAT(IFNULL(u.APELLIDO, ''), ' ') + IFNULL(u.NOMBRE, '')))) AS ESTUDIANTE_NOMBRE,
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
        IFNULL(au.NOMBRE, '') AS AULA_NOMBRE,
        m.IDASESOR,
        IFNULL(ase.NOMBRE, IFNULL(m.ASESOR, '')) AS ASESOR_NOMBRE,
        m.ESTADO,
        m.FECHAREGISTRO
    FROM MEMBRESIA m
    INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
    INNER JOIN `PLAN` pl ON pl.IDPLAN = m.IDPLAN
    LEFT JOIN AULA au ON au.IDAULA = m.IDAULA
    LEFT JOIN TURNO tu ON tu.IDTURNO = m.IDTURNO
    LEFT JOIN ASESOR ase ON ase.IDASESOR = m.IDASESOR
    WHERE m.ESTADO = p_Estado
      AND (p_Buscar IS NULL OR p_Buscar = '' OR
           m.IDMEMBRESIA LIKE CONCAT('%', p_Buscar, '%') OR
           u.DNI LIKE CONCAT('%', p_Buscar, '%') OR
           u.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
           u.APELLIDO LIKE CONCAT('%', p_Buscar, '%') OR
           pl.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
           IFNULL(au.NOMBRE, '') LIKE CONCAT('%', p_Buscar, '%') OR
           IFNULL(ase.NOMBRE, '') LIKE CONCAT('%', p_Buscar, '%'))
    ORDER BY
        CASE WHEN p_OrdenarPor = 'IDMEMBRESIA' AND p_Direccion = 'ASC'  THEN m.IDMEMBRESIA END ASC,
        CASE WHEN p_OrdenarPor = 'IDMEMBRESIA' AND p_Direccion = 'DESC' THEN m.IDMEMBRESIA END DESC,
        CASE WHEN p_OrdenarPor = 'ESTUDIANTE_NOMBRE' AND p_Direccion = 'ASC'  THEN u.APELLIDO END ASC,
        CASE WHEN p_OrdenarPor = 'ESTUDIANTE_NOMBRE' AND p_Direccion = 'DESC' THEN u.APELLIDO END DESC,
        CASE WHEN p_OrdenarPor = 'FECHAINICIO' AND p_Direccion = 'ASC'  THEN m.FECHAINICIO END ASC,
        CASE WHEN p_OrdenarPor = 'FECHAINICIO' AND p_Direccion = 'DESC' THEN m.FECHAINICIO END DESC,
        CASE WHEN p_OrdenarPor = 'FECHAFIN' AND p_Direccion = 'ASC'  THEN m.FECHAFIN END ASC,
        CASE WHEN p_OrdenarPor = 'FECHAFIN' AND p_Direccion = 'DESC' THEN m.FECHAFIN END DESC,
        CASE WHEN p_OrdenarPor = 'MONTOTOTAL' AND p_Direccion = 'ASC'  THEN m.MONTOTOTAL END ASC,
        CASE WHEN p_OrdenarPor = 'MONTOTOTAL' AND p_Direccion = 'DESC' THEN m.MONTOTOTAL END DESC,
        CASE WHEN p_OrdenarPor = 'FECHAREGISTRO' AND p_Direccion = 'ASC'  THEN m.FECHAREGISTRO END ASC,
        CASE WHEN p_OrdenarPor = 'FECHAREGISTRO' AND p_Direccion = 'DESC' THEN m.FECHAREGISTRO END DESC,
        m.IDMEMBRESIA DESC
    LIMIT p_TamanioPagina OFFSET v_offset;
    SELECT p_TotalRegistros AS TotalRegistros
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_membresia_obtener;

DROP PROCEDURE IF EXISTS usp_membresia_obtener;

DELIMITER $$

CREATE PROCEDURE usp_membresia_obtener(
    IN p_Id VARCHAR(50)
)
main: BEGIN
SELECT
        m.IDMEMBRESIA,
        m.IDUSUARIO,
        UPPER(TRIM(CONCAT(IFNULL(u.APELLIDO, ''), ' ') + IFNULL(u.NOMBRE, '')))) AS ESTUDIANTE_NOMBRE,
        u.DNI AS ESTUDIANTE_DNI,
        m.IDPLAN,
        pl.NOMBRE AS PLAN_NOMBRE,
        m.IDTURNO,
        IFNULL(tu.DESCRIPCION, '') AS TURNO_DESCRIPCION,
        m.ESTADOMIEMBRO,
        m.FECHAINICIO,
        m.FECHAFIN,
        m.MONTOTOTAL,
        m.IDAULA,
        IFNULL(au.NOMBRE, '') AS AULA_NOMBRE,
        m.IDASESOR,
        IFNULL(ase.NOMBRE, IFNULL(m.ASESOR, '')) AS ASESOR_NOMBRE,
        m.OBSERVACIONES,
        m.FECHACANCELACION,
        m.ESTADO,
        m.FECHAREGISTRO,
        m.REGISTRADOPOR,
        IFNULL(pag.PAGOINICIAL, 0) AS PAGOINICIAL,
        pag.IDMETODOPAGO
    FROM MEMBRESIA m
    INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
    INNER JOIN `PLAN` pl ON pl.IDPLAN = m.IDPLAN
    LEFT JOIN AULA au ON au.IDAULA = m.IDAULA
    LEFT JOIN TURNO tu ON tu.IDTURNO = m.IDTURNO
    LEFT JOIN ASESOR ase ON ase.IDASESOR = m.IDASESOR
    OUTER APPLY (
        SELECT TOP 1 p.MONTO AS PAGOINICIAL, p.IDMETODOPAGO
        FROM PAGOMEMBRESIA p
        WHERE p.IDMEMBRESIA = m.IDMEMBRESIA
        ORDER BY p.FECHAPAGO, p.IDPAGOMEMBRESIA
    ) pag
    WHERE m.IDMEMBRESIA = p_Id;
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_membresia_insertar;

DROP PROCEDURE IF EXISTS usp_membresia_insertar;

DELIMITER $$

CREATE PROCEDURE usp_membresia_insertar(
    IN p_Id VARCHAR(50),
    IN p_IdUsuario VARCHAR(50),
    IN p_IdPlan VARCHAR(50),
    IN p_IdTurno VARCHAR(50),
    IN p_EstadoMiembro INT,
    IN p_FechaInicio CHAR(8),
    IN p_FechaFin CHAR(8),
    IN p_MontoTotal DECIMAL(10,2),
    IN p_PagoInicial DECIMAL(10,2),
    IN p_IdMetodoPago VARCHAR(50),
    IN p_IdAula VARCHAR(50),
    IN p_IdAsesor VARCHAR(50),
    IN p_Observaciones LONGTEXT,
    IN p_FechaCancelacion CHAR(8),
    IN p_RegistradoPor VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
IF p_IdUsuario IS NULL OR p_IdUsuario = ''
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'Debe seleccionar un estudiante.'; LEAVE main; 
    END IF;

    IF p_FechaInicio IS NULL OR p_FechaFin IS NULL
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'Ingrese fecha de inicio y fin.'; LEAVE main; 
    END IF;

    IF p_MontoTotal IS NULL
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'Ingrese el monto total.'; LEAVE main; 
    END IF;

    IF p_EstadoMiembro NOT IN (2, 3)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'Estado de membresía no válido.'; LEAVE main; 
    END IF;

    IF NOT EXISTS (SELECT 1 FROM USUARIO WHERE IDUSUARIO = p_IdUsuario AND IDTIPOUSUARIO = '1')
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'El estudiante no existe o no es válido.'; LEAVE main; 
    END IF;

    IF NOT EXISTS (SELECT 1 FROM `PLAN` WHERE IDPLAN = p_IdPlan)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'El plan seleccionado no es válido.'; LEAVE main; 
    END IF;

    IF p_IdAsesor IS NOT NULL AND p_IdAsesor <> ''
       AND NOT EXISTS (SELECT 1 FROM ASESOR WHERE IDASESOR = p_IdAsesor AND ACTIVO = 1)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'El asesor seleccionado no es válido.'; LEAVE main; 
    END IF;

    IF p_PagoInicial IS NOT NULL AND p_PagoInicial > 0
       AND (p_IdMetodoPago IS NULL OR p_IdMetodoPago = '')
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'Indique el método de pago del pago inicial.'; LEAVE main; 
    END IF;

    IF p_Id IS NULL OR p_Id = '' THEN
        DECLARE v_Next INT = IFNULL((
            SELECT MAX(CAST(SUBSTRING(IDMEMBRESIA, 4, 10) AS INT))
            FROM MEMBRESIA WHERE IDMEMBRESIA LIKE 'MEM%'
        ), 0) + 1;
        SET p_Id = CONCAT('MEM', RIGHT(CONCAT('000000', CAST(v_Next AS CHAR(10))), 6);
    
    IF EXISTS (SELECT 1 FROM MEMBRESIA WHERE IDMEMBRESIA = p_Id)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'La membresía ya existe.'; LEAVE main; 
    INSERT INTO MEMBRESIA (
        IDMEMBRESIA, FECHAINICIO, FECHAFIN, ESTADOMIEMBRO, MONTOTOTAL, OBSERVACIONES,
        FECHAREGISTRO, HORAREGISTRO, IDPLAN, IDAULA, IDTURNO, IDUSUARIO, REGISTRADOPOR,
        IDASESOR, FECHACANCELACION, ESTADO
    ) VALUES (
        p_Id, p_FechaInicio, p_FechaFin, p_EstadoMiembro, p_MontoTotal, p_Observaciones,
        fn_fecha_ddmmyyyy(), TIME_FORMAT(NOW(), '%H:%i:%s'),
        p_IdPlan, p_IdAula, p_IdTurno, p_IdUsuario, p_RegistradoPor,
        p_IdAsesor, p_FechaCancelacion, 'Activo'
    );

    IF p_PagoInicial IS NOT NULL AND p_PagoInicial > 0 THEN
        DECLARE v_IdPago VARCHAR(50) = CONCAT('PAG', RIGHT(CONCAT('000000', CAST((
            IFNULL((SELECT MAX(CAST(SUBSTRING(IDPAGOMEMBRESIA, 4, 10)) AS INT))
                    FROM PAGOMEMBRESIA WHERE IDPAGOMEMBRESIA LIKE 'PAG%'), 0) + 1
        ) AS VARCHAR(10)), 6);

        INSERT INTO PAGOMEMBRESIA (
            IDPAGOMEMBRESIA, MONTO, FECHAPAGO, HORAPAGO, OBSERVACIONES,
            IDMEMBRESIA, IDMETODOPAGO, IDUSUARIO
        ) VALUES (
            v_IdPago, p_PagoInicial, fn_fecha_ddmmyyyy(), TIME_FORMAT(NOW(), '%H:%i:%s'),
            'Pago inicial', p_Id, p_IdMetodoPago, p_RegistradoPor
        );
    
    SET p_Resultado = 1; SET p_Mensaje = 'Membresía registrada.';
    SELECT p_Resultado AS Resultado, p_Mensaje AS Mensaje
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_membresia_actualizar;

DROP PROCEDURE IF EXISTS usp_membresia_actualizar;

DELIMITER $$

CREATE PROCEDURE usp_membresia_actualizar(
    IN p_Id VARCHAR(50),
    IN p_IdUsuario VARCHAR(50),
    IN p_IdPlan VARCHAR(50),
    IN p_IdTurno VARCHAR(50),
    IN p_EstadoMiembro INT,
    IN p_FechaInicio CHAR(8),
    IN p_FechaFin CHAR(8),
    IN p_MontoTotal DECIMAL(10,2),
    IN p_IdAula VARCHAR(50),
    IN p_IdAsesor VARCHAR(50),
    IN p_Observaciones LONGTEXT,
    IN p_FechaCancelacion CHAR(8),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
IF NOT EXISTS (SELECT 1 FROM MEMBRESIA WHERE IDMEMBRESIA = p_Id)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'La membresía no existe.'; LEAVE main; 
    END IF;

    IF p_EstadoMiembro NOT IN (2, 3)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'Estado de membresía no válido.'; LEAVE main; 
    END IF;

    IF p_IdAsesor IS NOT NULL AND p_IdAsesor <> ''
       AND NOT EXISTS (SELECT 1 FROM ASESOR WHERE IDASESOR = p_IdAsesor AND ACTIVO = 1)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'El asesor seleccionado no es válido.'; LEAVE main; 
    UPDATE MEMBRESIA SET
        IDUSUARIO        = p_IdUsuario,
        IDPLAN           = p_IdPlan,
        IDTURNO          = p_IdTurno,
        ESTADOMIEMBRO    = p_EstadoMiembro,
        FECHAINICIO      = p_FechaInicio,
        FECHAFIN         = p_FechaFin,
        MONTOTOTAL       = p_MontoTotal,
        IDAULA           = p_IdAula,
        IDASESOR         = p_IdAsesor,
        OBSERVACIONES    = p_Observaciones,
        FECHACANCELACION = p_FechaCancelacion
    WHERE IDMEMBRESIA = p_Id;

    SET p_Resultado = 1; SET p_Mensaje = 'Membresía actualizada.';
    SELECT p_Resultado AS Resultado, p_Mensaje AS Mensaje
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_pago_membresias_estudiante;

DROP PROCEDURE IF EXISTS usp_pago_membresias_estudiante;

DELIMITER $$

CREATE PROCEDURE usp_pago_membresias_estudiante(
    IN p_IdUsuario VARCHAR(50)
)
main: BEGIN
SELECT TOP 3
        m.IDMEMBRESIA,
        m.IDPLAN,
        pl.NOMBRE AS PLAN_NOMBRE,
        m.IDTURNO,
        m.IDAULA,
        m.IDASESOR,
        m.OBSERVACIONES,
        m.FECHAINICIO,
        m.FECHAFIN,
        m.MONTOTOTAL,
        IFNULL(pag.PAGADO, 0) AS PAGADO,
        CASE
            WHEN IFNULL(m.MONTOTOTAL, 0) - IFNULL(pag.PAGADO, 0) < 0 THEN 0
            ELSE IFNULL(m.MONTOTOTAL, 0) - IFNULL(pag.PAGADO, 0)
        END AS DEUDA,
        m.ESTADOMIEMBRO,
        CASE m.ESTADOMIEMBRO
            WHEN 2 THEN 'Activo'
            WHEN 3 THEN 'Vencido'
            ELSE 'Activo'
        END AS ESTADOMIEMBRO_DESCRIPCION,
        m.ESTADO,
        m.FECHAREGISTRO
    FROM MEMBRESIA m
    INNER JOIN `PLAN` pl ON pl.IDPLAN = m.IDPLAN
    OUTER APPLY (
        SELECT SUM(p.MONTO) AS PAGADO
        FROM PAGOMEMBRESIA p
        WHERE p.IDMEMBRESIA = m.IDMEMBRESIA
    ) pag
    WHERE m.IDUSUARIO = p_IdUsuario
      AND m.ESTADO = 'Activo'
    ORDER BY m.FECHAREGISTRO DESC, m.IDMEMBRESIA DESC;
END;

-- 5) Quitar columna de membresía
IF COL_LENGTH('MEMBRESIA', 'COMOENTERO') IS NOT NULL THEN
    ALTER TABLE MEMBRESIA DROP COLUMN COMOENTERO;
    SELECT 'Columna MEMBRESIA.COMOENTERO eliminada.';

SELECT 'COMOENTERO movido de MEMBRESIA a USUARIO.';
END$$

DELIMITER ;