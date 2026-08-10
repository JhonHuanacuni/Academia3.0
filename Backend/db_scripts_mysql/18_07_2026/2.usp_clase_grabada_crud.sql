-- ============================================================================
-- CRUD CLASE_GRABADA — MySQL 8
-- Prerequisito: 1.clase_grabada_tabla.sql
-- Fecha: 18/07/2026
-- ============================================================================

USE `AcademiaDB`;

DROP PROCEDURE IF EXISTS usp_clase_grabada_materias;

DELIMITER $$

CREATE PROCEDURE usp_clase_grabada_materias(
    IN p_IdAula VARCHAR(50),
    IN p_IdUsuario VARCHAR(50)
)
main: BEGIN
    SELECT
        m.IDMATERIA,
        m.NOMBRE AS MATERIA_NOMBRE,
        COUNT(cg.IDCLASEGRABADA) AS CANTIDAD
    FROM MATERIA m
    INNER JOIN CLASE_GRABADA cg ON cg.IDMATERIA = m.IDMATERIA AND cg.ESTADO = 'Activo'
    WHERE IFNULL(m.ACTIVO, 1) = 1
      AND (p_IdAula IS NULL OR p_IdAula = '' OR cg.IDAULA = p_IdAula)
      AND (
          p_IdUsuario IS NULL OR p_IdUsuario = '' OR
          cg.IDAULA IN (
              SELECT DISTINCT ms.IDAULA
              FROM MENSUALIDAD ms
              WHERE ms.IDUSUARIO = p_IdUsuario
                AND ms.ESTADO = 'Activo'
                AND ms.IDAULA IS NOT NULL
          )
      )
    GROUP BY m.IDMATERIA, m.NOMBRE
    ORDER BY m.NOMBRE;
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_clase_grabada_listar;

DELIMITER $$

CREATE PROCEDURE usp_clase_grabada_listar(
    IN p_Buscar VARCHAR(200),
    IN p_Estado VARCHAR(50),
    IN p_IdMateria VARCHAR(50),
    IN p_IdAula VARCHAR(50),
    IN p_IdUsuario VARCHAR(50),
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
    FROM CLASE_GRABADA cg
    INNER JOIN AULA au ON au.IDAULA = cg.IDAULA
    INNER JOIN MATERIA m ON m.IDMATERIA = cg.IDMATERIA
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           cg.IDCLASEGRABADA LIKE CONCAT('%', p_Buscar, '%') OR
           cg.DETALLES LIKE CONCAT('%', p_Buscar, '%') OR
           cg.ENLACE LIKE CONCAT('%', p_Buscar, '%') OR
           au.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
           m.NOMBRE LIKE CONCAT('%', p_Buscar, '%'))
      AND (p_Estado IS NULL OR p_Estado = '' OR cg.ESTADO = p_Estado)
      AND (p_IdMateria IS NULL OR p_IdMateria = '' OR cg.IDMATERIA = p_IdMateria)
      AND (p_IdAula IS NULL OR p_IdAula = '' OR cg.IDAULA = p_IdAula)
      AND (
          p_IdUsuario IS NULL OR p_IdUsuario = '' OR
          cg.IDAULA IN (
              SELECT DISTINCT ms.IDAULA
              FROM MENSUALIDAD ms
              WHERE ms.IDUSUARIO = p_IdUsuario
                AND ms.ESTADO = 'Activo'
                AND ms.IDAULA IS NOT NULL
          )
      );

    SELECT
        cg.IDCLASEGRABADA,
        cg.IDAULA,
        au.NOMBRE AS AULA_NOMBRE,
        cg.IDMATERIA,
        m.NOMBRE AS MATERIA_NOMBRE,
        cg.ENLACE,
        cg.DETALLES,
        cg.FECHASUBIDA,
        cg.HORASUBIDA,
        cg.ESTADO,
        cg.CREADO_POR,
        UPPER(TRIM(CONCAT(IFNULL(uc.APELLIDO, ''), ' ', IFNULL(uc.NOMBRE, '')))) AS CREADO_POR_NOMBRE,
        cg.FECHACREACION,
        cg.HORACREACION,
        cg.MODIFICADO_POR,
        UPPER(TRIM(CONCAT(IFNULL(um.APELLIDO, ''), ' ', IFNULL(um.NOMBRE, '')))) AS MODIFICADO_POR_NOMBRE,
        cg.FECHAMODIFICACION,
        cg.HORAMODIFICACION
    FROM CLASE_GRABADA cg
    INNER JOIN AULA au ON au.IDAULA = cg.IDAULA
    INNER JOIN MATERIA m ON m.IDMATERIA = cg.IDMATERIA
    LEFT JOIN USUARIO uc ON uc.IDUSUARIO = cg.CREADO_POR
    LEFT JOIN USUARIO um ON um.IDUSUARIO = cg.MODIFICADO_POR
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           cg.IDCLASEGRABADA LIKE CONCAT('%', p_Buscar, '%') OR
           cg.DETALLES LIKE CONCAT('%', p_Buscar, '%') OR
           cg.ENLACE LIKE CONCAT('%', p_Buscar, '%') OR
           au.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
           m.NOMBRE LIKE CONCAT('%', p_Buscar, '%'))
      AND (p_Estado IS NULL OR p_Estado = '' OR cg.ESTADO = p_Estado)
      AND (p_IdMateria IS NULL OR p_IdMateria = '' OR cg.IDMATERIA = p_IdMateria)
      AND (p_IdAula IS NULL OR p_IdAula = '' OR cg.IDAULA = p_IdAula)
      AND (
          p_IdUsuario IS NULL OR p_IdUsuario = '' OR
          cg.IDAULA IN (
              SELECT DISTINCT ms.IDAULA
              FROM MENSUALIDAD ms
              WHERE ms.IDUSUARIO = p_IdUsuario
                AND ms.ESTADO = 'Activo'
                AND ms.IDAULA IS NOT NULL
          )
      )
    ORDER BY
        CASE WHEN p_OrdenarPor = 'FECHASUBIDA' AND p_Direccion = 'DESC' THEN cg.FECHASUBIDA END DESC,
        CASE WHEN p_OrdenarPor = 'FECHASUBIDA' AND p_Direccion = 'ASC' THEN cg.FECHASUBIDA END ASC,
        CASE WHEN p_OrdenarPor = 'DETALLES' AND p_Direccion = 'DESC' THEN cg.DETALLES END DESC,
        CASE WHEN p_OrdenarPor = 'DETALLES' AND p_Direccion = 'ASC' THEN cg.DETALLES END ASC,
        CASE WHEN p_OrdenarPor = 'AULA_NOMBRE' AND p_Direccion = 'DESC' THEN au.NOMBRE END DESC,
        CASE WHEN p_OrdenarPor = 'AULA_NOMBRE' AND p_Direccion = 'ASC' THEN au.NOMBRE END ASC,
        cg.HORASUBIDA DESC,
        cg.IDCLASEGRABADA DESC
    LIMIT p_TamanioPagina OFFSET v_offset;
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_clase_grabada_obtener;

DELIMITER $$

CREATE PROCEDURE usp_clase_grabada_obtener(IN p_Id VARCHAR(50))
main: BEGIN
    SELECT
        cg.IDCLASEGRABADA,
        cg.IDAULA,
        au.NOMBRE AS AULA_NOMBRE,
        cg.IDMATERIA,
        m.NOMBRE AS MATERIA_NOMBRE,
        cg.ENLACE,
        cg.DETALLES,
        cg.FECHASUBIDA,
        cg.HORASUBIDA,
        cg.ESTADO,
        cg.CREADO_POR,
        cg.FECHACREACION,
        cg.HORACREACION,
        cg.MODIFICADO_POR,
        cg.FECHAMODIFICACION,
        cg.HORAMODIFICACION
    FROM CLASE_GRABADA cg
    INNER JOIN AULA au ON au.IDAULA = cg.IDAULA
    INNER JOIN MATERIA m ON m.IDMATERIA = cg.IDMATERIA
    WHERE cg.IDCLASEGRABADA = p_Id;
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_clase_grabada_insertar;

DELIMITER $$

CREATE PROCEDURE usp_clase_grabada_insertar(
    IN p_IdAula VARCHAR(50),
    IN p_IdMateria VARCHAR(50),
    IN p_Enlace VARCHAR(500),
    IN p_Detalles VARCHAR(500),
    IN p_Estado VARCHAR(50),
    OUT p_IdGenerado VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
    DECLARE v_Next INT DEFAULT 0;
    DECLARE v_err_msg VARCHAR(200);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_IdGenerado = NULL;
        SET p_Resultado = 0;
        GET DIAGNOSTICS CONDITION 1 v_err_msg = MESSAGE_TEXT;
        SET p_Mensaje = LEFT(v_err_msg, 200);
    END;

    SET p_IdGenerado = NULL;

    IF p_IdAula IS NULL OR TRIM(p_IdAula) = '' THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Selecciona un salón.'; LEAVE main;
    END IF;
    IF p_IdMateria IS NULL OR TRIM(p_IdMateria) = '' THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Selecciona una materia.'; LEAVE main;
    END IF;
    IF p_Enlace IS NULL OR TRIM(p_Enlace) = '' THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa el enlace de la grabación.'; LEAVE main;
    END IF;
    IF p_Detalles IS NULL OR TRIM(p_Detalles) = '' THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa los detalles (título o semana).'; LEAVE main;
    END IF;
    IF p_Estado IS NULL OR TRIM(p_Estado) = '' THEN SET p_Estado = 'Activo'; END IF;

    IF NOT EXISTS (SELECT 1 FROM AULA WHERE IDAULA = p_IdAula) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'El salón no existe.'; LEAVE main;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM MATERIA WHERE IDMATERIA = p_IdMateria) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'La materia no existe.'; LEAVE main;
    END IF;

    SELECT IFNULL(MAX(CAST(REPLACE(IDCLASEGRABADA, 'CGR', '') AS UNSIGNED)), 0) + 1 INTO v_Next
    FROM CLASE_GRABADA WHERE IDCLASEGRABADA LIKE 'CGR%';
    SET p_IdGenerado = CONCAT('CGR', LPAD(CAST(v_Next AS CHAR), 3, '0'));

    START TRANSACTION;

    INSERT INTO CLASE_GRABADA (
        IDCLASEGRABADA, IDAULA, IDMATERIA, ENLACE, DETALLES,
        FECHASUBIDA, HORASUBIDA, ESTADO,
        CREADO_POR, FECHACREACION, HORACREACION
    ) VALUES (
        p_IdGenerado, p_IdAula, p_IdMateria, TRIM(p_Enlace), TRIM(p_Detalles),
        fn_fecha_ddmmyyyy(), TIME_FORMAT(NOW(), '%H:%i:%s'), p_Estado,
        @audit_id_usuario, fn_fecha_ddmmyyyy(), TIME_FORMAT(NOW(), '%H:%i:%s')
    );

    COMMIT;
    SET p_Resultado = 1;
    SET p_Mensaje = 'Enlace registrado.';
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_clase_grabada_actualizar;

DELIMITER $$

CREATE PROCEDURE usp_clase_grabada_actualizar(
    IN p_Id VARCHAR(50),
    IN p_IdAula VARCHAR(50),
    IN p_IdMateria VARCHAR(50),
    IN p_Enlace VARCHAR(500),
    IN p_Detalles VARCHAR(500),
    IN p_Estado VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
    DECLARE v_err_msg VARCHAR(200);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_Resultado = 0;
        GET DIAGNOSTICS CONDITION 1 v_err_msg = MESSAGE_TEXT;
        SET p_Mensaje = LEFT(v_err_msg, 200);
    END;

    IF NOT EXISTS (SELECT 1 FROM CLASE_GRABADA WHERE IDCLASEGRABADA = p_Id) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'El registro no existe.'; LEAVE main;
    END IF;
    IF p_IdAula IS NULL OR TRIM(p_IdAula) = '' THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Selecciona un salón.'; LEAVE main;
    END IF;
    IF p_IdMateria IS NULL OR TRIM(p_IdMateria) = '' THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Selecciona una materia.'; LEAVE main;
    END IF;
    IF p_Enlace IS NULL OR TRIM(p_Enlace) = '' THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa el enlace de la grabación.'; LEAVE main;
    END IF;
    IF p_Detalles IS NULL OR TRIM(p_Detalles) = '' THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa los detalles.'; LEAVE main;
    END IF;
    IF p_Estado IS NULL OR TRIM(p_Estado) = '' THEN SET p_Estado = 'Activo'; END IF;

    START TRANSACTION;

    UPDATE CLASE_GRABADA SET
        IDAULA = p_IdAula,
        IDMATERIA = p_IdMateria,
        ENLACE = TRIM(p_Enlace),
        DETALLES = TRIM(p_Detalles),
        ESTADO = p_Estado,
        MODIFICADO_POR = @audit_id_usuario,
        FECHAMODIFICACION = fn_fecha_ddmmyyyy(),
        HORAMODIFICACION = TIME_FORMAT(NOW(), '%H:%i:%s')
    WHERE IDCLASEGRABADA = p_Id;

    COMMIT;
    SET p_Resultado = 1;
    SET p_Mensaje = 'Enlace actualizado.';
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_clase_grabada_eliminar;

DELIMITER $$

CREATE PROCEDURE usp_clase_grabada_eliminar(
    IN p_Id VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
    IF NOT EXISTS (SELECT 1 FROM CLASE_GRABADA WHERE IDCLASEGRABADA = p_Id) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'El registro no existe.'; LEAVE main;
    END IF;

    DELETE FROM CLASE_GRABADA WHERE IDCLASEGRABADA = p_Id;
    SET p_Resultado = 1;
    SET p_Mensaje = 'Enlace eliminado.';
END$$

DELIMITER ;

SELECT 'usp_clase_grabada_* listos.' AS info;
