-- Convertido automáticamente desde db_scripts/06_07_2026/7.usp_membresia_crud.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   CRUD MEMBRESIA — Mantenedor de membresías
   5 SPs estándar: listar, obtener, insertar, actualizar, eliminar
   Ejecutar después de 6.membresia_alter_catalogos.sql
   Fecha: 06/07/2026
   ============================================================================ */

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
    SELECT COUNT(*) INTO p_TotalRegistros
    FROM MEMBRESIA m
    INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
    INNER JOIN `PLAN` pl ON pl.IDPLAN = m.IDPLAN
    LEFT JOIN AULA au ON au.IDAULA = m.IDAULA
    LEFT JOIN TURNO tu ON tu.IDTURNO = m.IDTURNO
    WHERE (p_Estado IS NULL OR p_Estado = '' OR m.ESTADO = p_Estado)
      AND (p_Buscar IS NULL OR p_Buscar = '' OR
           m.IDMEMBRESIA LIKE CONCAT('%', p_Buscar, '%') OR
           u.DNI LIKE CONCAT('%', p_Buscar, '%') OR
           u.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
           u.APELLIDO LIKE CONCAT('%', p_Buscar, '%') OR
           pl.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
           IFNULL(au.NOMBRE, '') LIKE CONCAT('%', p_Buscar, '%'));

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
            WHEN 1 THEN 'Nuevo'
            WHEN 2 THEN 'Activo'
            WHEN 3 THEN 'Vencido'
            WHEN 4 THEN 'Cancelado'
            ELSE '—'
        END AS ESTADOMIEMBRO_DESCRIPCION,
        m.FECHAINICIO,
        m.FECHAFIN,
        m.MONTOTOTAL,
        m.TIPOMEMBRESIA,
        IFNULL(au.NOMBRE, '') AS AULA_NOMBRE,
        m.ASESOR,
        m.ESTADO,
        m.FECHAREGISTRO
    FROM MEMBRESIA m
    INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
    INNER JOIN `PLAN` pl ON pl.IDPLAN = m.IDPLAN
    LEFT JOIN AULA au ON au.IDAULA = m.IDAULA
    LEFT JOIN TURNO tu ON tu.IDTURNO = m.IDTURNO
    WHERE (p_Estado IS NULL OR p_Estado = '' OR m.ESTADO = p_Estado)
      AND (p_Buscar IS NULL OR p_Buscar = '' OR
           m.IDMEMBRESIA LIKE CONCAT('%', p_Buscar, '%') OR
           u.DNI LIKE CONCAT('%', p_Buscar, '%') OR
           u.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
           u.APELLIDO LIKE CONCAT('%', p_Buscar, '%') OR
           pl.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
           IFNULL(au.NOMBRE, '') LIKE CONCAT('%', p_Buscar, '%'))
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
        m.TIPOMEMBRESIA,
        m.IDAULA,
        IFNULL(au.NOMBRE, '') AS AULA_NOMBRE,
        m.ASESOR,
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
    IN p_TipoMembresia VARCHAR(50),
    IN p_IdMetodoPago VARCHAR(50),
    IN p_IdAula VARCHAR(50),
    IN p_Asesor VARCHAR(150),
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

    IF NOT EXISTS (SELECT 1 FROM USUARIO WHERE IDUSUARIO = p_IdUsuario AND IDTIPOUSUARIO = '1')
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'El estudiante no existe o no es válido.'; LEAVE main; 
    END IF;

    IF NOT EXISTS (SELECT 1 FROM `PLAN` WHERE IDPLAN = p_IdPlan)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'El plan seleccionado no es válido.'; LEAVE main; 
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
        SET p_Id = CONCAT('MEM', RIGHT(CONCAT('000000', CAST(v_Next AS VARCHAR(10))), 6);
    
    IF EXISTS (SELECT 1 FROM MEMBRESIA WHERE IDMEMBRESIA = p_Id)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'La membresía ya existe.'; LEAVE main; 
    INSERT INTO MEMBRESIA (
        IDMEMBRESIA, FECHAINICIO, FECHAFIN, ESTADOMIEMBRO, MONTOTOTAL, OBSERVACIONES,
        FECHAREGISTRO, HORAREGISTRO, IDPLAN, IDAULA, IDTURNO, IDUSUARIO, REGISTRADOPOR,
        TIPOMEMBRESIA, ASESOR, FECHACANCELACION, ESTADO
    ) VALUES (
        p_Id, p_FechaInicio, p_FechaFin, p_EstadoMiembro, p_MontoTotal, p_Observaciones,
        fn_fecha_ddmmyyyy(), TIME_FORMAT(NOW(), '%H:%i:%s'),
        p_IdPlan, p_IdAula, p_IdTurno, p_IdUsuario, p_RegistradoPor,
        p_TipoMembresia, p_Asesor, p_FechaCancelacion, 'Activo'
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
    IN p_TipoMembresia VARCHAR(50),
    IN p_IdAula VARCHAR(50),
    IN p_Asesor VARCHAR(150),
    IN p_Observaciones LONGTEXT,
    IN p_FechaCancelacion CHAR(8),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
IF NOT EXISTS (SELECT 1 FROM MEMBRESIA WHERE IDMEMBRESIA = p_Id)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'La membresía no existe.'; LEAVE main; 
    END IF;

    IF NOT EXISTS (SELECT 1 FROM USUARIO WHERE IDUSUARIO = p_IdUsuario AND IDTIPOUSUARIO = '1')
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'El estudiante no es válido.'; LEAVE main; 
    END IF;

    IF NOT EXISTS (SELECT 1 FROM `PLAN` WHERE IDPLAN = p_IdPlan)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'El plan no es válido.'; LEAVE main; 
    UPDATE MEMBRESIA SET
        IDUSUARIO        = p_IdUsuario,
        IDPLAN           = p_IdPlan,
        IDTURNO          = p_IdTurno,
        ESTADOMIEMBRO    = p_EstadoMiembro,
        FECHAINICIO      = p_FechaInicio,
        FECHAFIN         = p_FechaFin,
        MONTOTOTAL       = p_MontoTotal,
        TIPOMEMBRESIA    = p_TipoMembresia,
        IDAULA           = p_IdAula,
        ASESOR           = p_Asesor,
        OBSERVACIONES    = p_Observaciones,
        FECHACANCELACION = p_FechaCancelacion
    WHERE IDMEMBRESIA = p_Id;

    SET p_Resultado = 1; SET p_Mensaje = 'Membresía actualizada.';
    SELECT p_Resultado AS Resultado, p_Mensaje AS Mensaje
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_membresia_eliminar;

DROP PROCEDURE IF EXISTS usp_membresia_eliminar;

DELIMITER $$

CREATE PROCEDURE usp_membresia_eliminar(
    IN p_Id VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
IF NOT EXISTS (SELECT 1 FROM MEMBRESIA WHERE IDMEMBRESIA = p_Id)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'La membresía no existe.'; LEAVE main; 
    UPDATE MEMBRESIA SET ESTADO = 'Inactivo', ESTADOMIEMBRO = 4 WHERE IDMEMBRESIA = p_Id;
    SET p_Resultado = 1; SET p_Mensaje = 'Membresía eliminada.';
    SELECT p_Resultado AS Resultado, p_Mensaje AS Mensaje
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_membresia_buscar_estudiantes;

DROP PROCEDURE IF EXISTS usp_membresia_buscar_estudiantes;

DELIMITER $$

CREATE PROCEDURE usp_membresia_buscar_estudiantes(
    IN p_Buscar VARCHAR(200)
)
main: BEGIN
SELECT TOP 20
        u.IDUSUARIO,
        u.DNI,
        u.NOMBRE,
        u.APELLIDO,
        UPPER(TRIM(CONCAT(IFNULL(u.APELLIDO, ''), ' ') + IFNULL(u.NOMBRE, '')))) AS NOMBRE_COMPLETO
    FROM USUARIO u
    WHERE u.IDTIPOUSUARIO = '1'
      AND u.ESTADO = 'Activo'
      AND (p_Buscar IS NULL OR p_Buscar = '' OR
           u.DNI LIKE CONCAT('%', p_Buscar, '%') OR
           u.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
           u.APELLIDO LIKE CONCAT('%', p_Buscar, '%') OR
           (CONCAT(u.APELLIDO, ' ') u.NOMBRE) LIKE CONCAT('%', p_Buscar, '%'))
    ORDER BY u.APELLIDO, u.NOMBRE;
END;

SELECT 'usp_membresia_crud ejecutado correctamente.';
END$$

DELIMITER ;