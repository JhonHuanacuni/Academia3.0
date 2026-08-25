-- ============================================================================
-- Override de submódulo por usuario (inclusión)
-- Fecha: 25/08/2026
--
-- Problema: GRUPO_SUBMODULO_EXCLUIDO quita el submódulo a TODO el rol.
-- No había forma de devolvérselo a un usuario concreto (p.ej. Mensajes
-- solo para un administrador).
--
-- Solución: USUARIO_SUBMODULO_INCLUIDO gana sobre la exclusión del rol.
-- Flujo: Por Rol → quitar Mensajes a Administrador.
--        Por Usuario → asignárselo a quien sí debe verlo.
-- ============================================================================

USE `AcademiaDB`;

CREATE TABLE IF NOT EXISTS USUARIO_SUBMODULO_INCLUIDO (
    IDUSUARIOINCLSUB  VARCHAR(50)  NOT NULL PRIMARY KEY,
    IDUSUARIO         VARCHAR(50)  NOT NULL,
    IDSUBMODULO       VARCHAR(50)  NOT NULL,
    FECHAREGISTRO     CHAR(8)      NULL,
    CONSTRAINT FK_UINCLSUB_USUARIO FOREIGN KEY (IDUSUARIO) REFERENCES USUARIO(IDUSUARIO),
    CONSTRAINT FK_UINCLSUB_SUB     FOREIGN KEY (IDSUBMODULO) REFERENCES SUBMODULO(IDSUBMODULO),
    CONSTRAINT UQ_USUARIO_SUBMODULO_INCL UNIQUE (IDUSUARIO, IDSUBMODULO)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP PROCEDURE IF EXISTS usp_submodulos_modulo_usuario;
DROP PROCEDURE IF EXISTS usp_submodulo_asignar_usuario;
DROP PROCEDURE IF EXISTS usp_submodulo_desasignar_usuario;

DELIMITER $$

CREATE PROCEDURE usp_submodulos_modulo_usuario(
    IN p_idusuario VARCHAR(50),
    IN p_idmodulo VARCHAR(50)
)
main: BEGIN
    DECLARE v_idtipo VARCHAR(50);

    SELECT IDTIPOUSUARIO INTO v_idtipo
    FROM USUARIO
    WHERE IDUSUARIO = p_idusuario AND ESTADO = 'Activo';

    SELECT
        s.IDSUBMODULO,
        s.NOMBRE,
        s.DESCRIPCION,
        s.ICONO,
        s.ORDEN,
        CASE
            WHEN ex_u.IDSUBMODULO IS NOT NULL THEN 0
            WHEN inc_u.IDSUBMODULO IS NOT NULL THEN 1
            WHEN ex_g.IDSUBMODULO IS NOT NULL THEN 0
            ELSE 1
        END AS asignado
    FROM SUBMODULO s
    LEFT JOIN USUARIO_SUBMODULO_EXCLUIDO ex_u
        ON ex_u.IDSUBMODULO = s.IDSUBMODULO AND ex_u.IDUSUARIO = p_idusuario
    LEFT JOIN USUARIO_SUBMODULO_INCLUIDO inc_u
        ON inc_u.IDSUBMODULO = s.IDSUBMODULO AND inc_u.IDUSUARIO = p_idusuario
    LEFT JOIN GRUPO_SUBMODULO_EXCLUIDO ex_g
        ON ex_g.IDSUBMODULO = s.IDSUBMODULO AND ex_g.IDTIPOUSUARIO = v_idtipo
    WHERE s.IDMODULO = p_idmodulo
      AND s.ACTIVO = 1
    ORDER BY s.ORDEN, s.NOMBRE;
END$$

CREATE PROCEDURE usp_submodulo_asignar_usuario(
    IN p_idusuario VARCHAR(50),
    IN p_idsubmodulo VARCHAR(50)
)
main: BEGIN
    DECLARE v_idtipo VARCHAR(50);

    DELETE FROM USUARIO_SUBMODULO_EXCLUIDO
    WHERE IDUSUARIO = p_idusuario AND IDSUBMODULO = p_idsubmodulo;

    SELECT IDTIPOUSUARIO INTO v_idtipo
    FROM USUARIO
    WHERE IDUSUARIO = p_idusuario AND ESTADO = 'Activo';

    IF v_idtipo IS NOT NULL AND EXISTS (
        SELECT 1 FROM GRUPO_SUBMODULO_EXCLUIDO
        WHERE IDTIPOUSUARIO = v_idtipo AND IDSUBMODULO = p_idsubmodulo
    ) THEN
        IF NOT EXISTS (
            SELECT 1 FROM USUARIO_SUBMODULO_INCLUIDO
            WHERE IDUSUARIO = p_idusuario AND IDSUBMODULO = p_idsubmodulo
        ) THEN
            INSERT INTO USUARIO_SUBMODULO_INCLUIDO (IDUSUARIOINCLSUB, IDUSUARIO, IDSUBMODULO, FECHAREGISTRO)
            VALUES (
                CONCAT('INS_', REPLACE(UUID(), '-', '')),
                p_idusuario,
                p_idsubmodulo,
                fn_fecha_ddmmyyyy()
            );
        END IF;
    ELSE
        DELETE FROM USUARIO_SUBMODULO_INCLUIDO
        WHERE IDUSUARIO = p_idusuario AND IDSUBMODULO = p_idsubmodulo;
    END IF;

    SELECT 1 AS success;
END$$

CREATE PROCEDURE usp_submodulo_desasignar_usuario(
    IN p_idusuario VARCHAR(50),
    IN p_idsubmodulo VARCHAR(50)
)
main: BEGIN
    DECLARE v_idtipo VARCHAR(50);

    DELETE FROM USUARIO_SUBMODULO_INCLUIDO
    WHERE IDUSUARIO = p_idusuario AND IDSUBMODULO = p_idsubmodulo;

    SELECT IDTIPOUSUARIO INTO v_idtipo
    FROM USUARIO
    WHERE IDUSUARIO = p_idusuario AND ESTADO = 'Activo';

    IF v_idtipo IS NOT NULL AND EXISTS (
        SELECT 1 FROM GRUPO_SUBMODULO_EXCLUIDO
        WHERE IDTIPOUSUARIO = v_idtipo AND IDSUBMODULO = p_idsubmodulo
    ) THEN
        SELECT 1 AS success;
        LEAVE main;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM USUARIO_SUBMODULO_EXCLUIDO
        WHERE IDUSUARIO = p_idusuario AND IDSUBMODULO = p_idsubmodulo
    ) THEN
        INSERT INTO USUARIO_SUBMODULO_EXCLUIDO (IDUSUARIOEXCLSUB, IDUSUARIO, IDSUBMODULO, FECHAREGISTRO)
        VALUES (
            CONCAT('EXS_', REPLACE(UUID(), '-', '')),
            p_idusuario,
            p_idsubmodulo,
            fn_fecha_ddmmyyyy()
        );
    END IF;

    SELECT 1 AS success;
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_usuario_eliminar;

DELIMITER $$

CREATE PROCEDURE usp_usuario_eliminar(
    IN p_Id VARCHAR(50),
    IN p_EliminacionFisica TINYINT(1),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_Resultado = 0;
        SET p_Mensaje = 'Error al eliminar usuario.';
    END;

    IF NOT EXISTS (SELECT 1 FROM USUARIO WHERE IDUSUARIO = p_Id) THEN
        SET p_Resultado = 0;
        SET p_Mensaje = 'El usuario no existe.';
        LEAVE main;
    END IF;

    IF p_EliminacionFisica = 0 THEN
        UPDATE USUARIO SET ESTADO = 'Retirado' WHERE IDUSUARIO = p_Id;
        SET p_Resultado = 1;
        SET p_Mensaje = 'Usuario retirado.';
        LEAVE main;
    END IF;

    IF EXISTS (SELECT 1 FROM USUARIO WHERE IDUSUARIO = p_Id AND IDTIPOUSUARIO = '3') THEN
        SET p_Resultado = 0;
        SET p_Mensaje = 'No se puede eliminar permanentemente a un administrador.';
        LEAVE main;
    END IF;

    IF EXISTS (SELECT 1 FROM EXAMEN WHERE IDUSUARIO = p_Id) THEN
        SET p_Resultado = 0;
        SET p_Mensaje = 'No se puede eliminar: el usuario tiene exámenes registrados como autor.';
        LEAVE main;
    END IF;

    START TRANSACTION;

    UPDATE MENSUALIDAD SET REGISTRADOPOR = NULL WHERE REGISTRADOPOR = p_Id;
    UPDATE PAGOMENSUALIDAD SET IDUSUARIO = NULL WHERE IDUSUARIO = p_Id;

    DELETE FROM JUSTIFICACION WHERE IDUSUARIO = p_Id;
    UPDATE JUSTIFICACION SET IDREGISTRADOR = NULL WHERE IDREGISTRADOR = p_Id;

    DELETE FROM ASISTENCIA WHERE IDUSUARIO = p_Id;

    DELETE ra FROM RESPUESTA_ALUMNO ra
    INNER JOIN INTENTO_EXAMEN i ON i.IDINTENTOEXAMEN = ra.IDINTENTOEXAMEN
    WHERE i.IDUSUARIO = p_Id;
    DELETE FROM INTENTO_EXAMEN WHERE IDUSUARIO = p_Id;

    DELETE FROM NOTA_IMPORTADA WHERE IDUSUARIO = p_Id;

    DELETE n FROM NOTIFICACIONMENSUALIDAD n
    INNER JOIN MENSUALIDAD m ON m.IDMENSUALIDAD = n.IDMENSUALIDAD
    WHERE m.IDUSUARIO = p_Id;

    DELETE p FROM PAGOMENSUALIDAD p
    INNER JOIN MENSUALIDAD m ON m.IDMENSUALIDAD = p.IDMENSUALIDAD
    WHERE m.IDUSUARIO = p_Id;

    DELETE FROM MENSUALIDAD WHERE IDUSUARIO = p_Id;
    DELETE FROM PAGOEXTRAORDINARIO WHERE IDUSUARIO = p_Id;
    DELETE FROM ASESOR WHERE IDUSUARIO = p_Id;
    DELETE FROM USUARIO_MODULO WHERE IDUSUARIO = p_Id;
    DELETE FROM USUARIO_MODULO_EXCLUIDO WHERE IDUSUARIO = p_Id;
    DELETE FROM USUARIO_SUBMODULO_EXCLUIDO WHERE IDUSUARIO = p_Id;
    DELETE FROM USUARIO_SUBMODULO_INCLUIDO WHERE IDUSUARIO = p_Id;

    DELETE FROM USUARIO WHERE IDUSUARIO = p_Id;

    COMMIT;
    SET p_Resultado = 1;
    SET p_Mensaje = 'Usuario eliminado.';
END$$

DELIMITER ;

SELECT 'submodulo_inclusion_usuario.sql ejecutado correctamente.' AS info;
