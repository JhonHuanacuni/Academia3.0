-- ============================================================================
-- Administración de módulos y submódulos POR ROL (TIPOUSUARIO) — MySQL 8
-- Ejecutar después de modulos_admin.sql y submodulos_admin.sql
-- Fecha: 30/07/2026
-- ============================================================================

USE `AcademiaDB`;

CREATE TABLE IF NOT EXISTS GRUPO_SUBMODULO_EXCLUIDO (
    IDGRUPOEXCLSUB    VARCHAR(50)  NOT NULL PRIMARY KEY,
    IDTIPOUSUARIO     VARCHAR(50)  NOT NULL,
    IDSUBMODULO       VARCHAR(50)  NOT NULL,
    FECHAREGISTRO     CHAR(8)      NULL,
    CONSTRAINT FK_GEXCLSUB_TIPO FOREIGN KEY (IDTIPOUSUARIO) REFERENCES TIPOUSUARIO(IDTIPOUSUARIO),
    CONSTRAINT FK_GEXCLSUB_SUB  FOREIGN KEY (IDSUBMODULO) REFERENCES SUBMODULO(IDSUBMODULO),
    CONSTRAINT UQ_GRUPO_SUBMODULO_EXCL UNIQUE (IDTIPOUSUARIO, IDSUBMODULO)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP PROCEDURE IF EXISTS usp_modulos_efectivos_rol;

DELIMITER $$

CREATE PROCEDURE usp_modulos_efectivos_rol(
    IN p_idtipousuario VARCHAR(50)
)
main: BEGIN
    IF NOT EXISTS (SELECT 1 FROM TIPOUSUARIO WHERE IDTIPOUSUARIO = p_idtipousuario) THEN
        LEAVE main;
    END IF;

    SELECT
        m.IDMODULO,
        m.NOMBRE,
        m.DESCRIPCION,
        m.ICONO,
        m.ORDEN,
        GROUP_CONCAT(pr.PERMISO ORDER BY pr.PERMISO SEPARATOR ',') AS PERMISOS
    FROM (
        SELECT gm.IDMODULO, tp.DESCRIPCION AS PERMISO
        FROM GRUPO_MODULO gm
        INNER JOIN TIPO_PERMISO tp ON tp.IDTIPOPERMISO = gm.IDTIPOPERMISO
        WHERE gm.IDTIPOUSUARIO = p_idtipousuario
    ) pr
    INNER JOIN MODULO m ON m.IDMODULO = pr.IDMODULO AND m.ACTIVO = 1
    GROUP BY m.IDMODULO, m.NOMBRE, m.DESCRIPCION, m.ICONO, m.ORDEN
    ORDER BY m.ORDEN, m.NOMBRE;
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_modulo_asignar_rol;

DELIMITER $$

CREATE PROCEDURE usp_modulo_asignar_rol(
    IN p_idtipousuario VARCHAR(50),
    IN p_idmodulo VARCHAR(50)
)
main: BEGIN
    IF NOT EXISTS (SELECT 1 FROM TIPOUSUARIO WHERE IDTIPOUSUARIO = p_idtipousuario) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tipo de usuario no encontrado';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM MODULO WHERE IDMODULO = p_idmodulo AND ACTIVO = 1) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Módulo no encontrado o inactivo';
    END IF;

    INSERT INTO GRUPO_MODULO (IDGRUPOMODULO, IDTIPOUSUARIO, IDMODULO, IDTIPOPERMISO)
    SELECT
        CONCAT('GRM_', REPLACE(UUID(), '-', '')),
        p_idtipousuario,
        p_idmodulo,
        perm.IDTIPOPERMISO
    FROM (
        SELECT 'TP001' AS IDTIPOPERMISO
        UNION ALL SELECT 'TP002'
        UNION ALL SELECT 'TP003'
        UNION ALL SELECT 'TP004'
    ) perm
    WHERE NOT EXISTS (
        SELECT 1 FROM GRUPO_MODULO gm
        WHERE gm.IDTIPOUSUARIO = p_idtipousuario
          AND gm.IDMODULO = p_idmodulo
          AND gm.IDTIPOPERMISO = perm.IDTIPOPERMISO
    );

    SELECT 1 AS success;
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_modulo_desasignar_rol;

DELIMITER $$

CREATE PROCEDURE usp_modulo_desasignar_rol(
    IN p_idtipousuario VARCHAR(50),
    IN p_idmodulo VARCHAR(50)
)
main: BEGIN
    IF p_idtipousuario = '3' AND p_idmodulo IN ('MOD001', 'MOD008') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede quitar este módulo al rol Administrador (Dashboard y Administración de Módulos son obligatorios).';
    END IF;

    DELETE FROM GRUPO_MODULO
    WHERE IDTIPOUSUARIO = p_idtipousuario AND IDMODULO = p_idmodulo;

    DELETE gex FROM GRUPO_SUBMODULO_EXCLUIDO gex
    INNER JOIN SUBMODULO s ON s.IDSUBMODULO = gex.IDSUBMODULO
    WHERE gex.IDTIPOUSUARIO = p_idtipousuario
      AND s.IDMODULO = p_idmodulo;

    SELECT 1 AS success;
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_submodulos_modulo_rol;

DELIMITER $$

CREATE PROCEDURE usp_submodulos_modulo_rol(
    IN p_idtipousuario VARCHAR(50),
    IN p_idmodulo VARCHAR(50)
)
main: BEGIN
    SELECT
        s.IDSUBMODULO,
        s.NOMBRE,
        s.DESCRIPCION,
        s.ICONO,
        s.ORDEN,
        CASE WHEN ex.IDSUBMODULO IS NULL THEN 1 ELSE 0 END AS asignado
    FROM SUBMODULO s
    LEFT JOIN GRUPO_SUBMODULO_EXCLUIDO ex
        ON ex.IDSUBMODULO = s.IDSUBMODULO AND ex.IDTIPOUSUARIO = p_idtipousuario
    WHERE s.IDMODULO = p_idmodulo
      AND s.ACTIVO = 1
    ORDER BY s.ORDEN, s.NOMBRE;
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_submodulo_asignar_rol;

DELIMITER $$

CREATE PROCEDURE usp_submodulo_asignar_rol(
    IN p_idtipousuario VARCHAR(50),
    IN p_idsubmodulo VARCHAR(50)
)
main: BEGIN
    DELETE FROM GRUPO_SUBMODULO_EXCLUIDO
    WHERE IDTIPOUSUARIO = p_idtipousuario AND IDSUBMODULO = p_idsubmodulo;

    SELECT 1 AS success;
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_submodulo_desasignar_rol;

DELIMITER $$

CREATE PROCEDURE usp_submodulo_desasignar_rol(
    IN p_idtipousuario VARCHAR(50),
    IN p_idsubmodulo VARCHAR(50)
)
main: BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM GRUPO_SUBMODULO_EXCLUIDO
        WHERE IDTIPOUSUARIO = p_idtipousuario AND IDSUBMODULO = p_idsubmodulo
    ) THEN
        INSERT INTO GRUPO_SUBMODULO_EXCLUIDO (IDGRUPOEXCLSUB, IDTIPOUSUARIO, IDSUBMODULO, FECHAREGISTRO)
        VALUES (
            CONCAT('GEXS_', REPLACE(UUID(), '-', '')),
            p_idtipousuario,
            p_idsubmodulo,
            fn_fecha_ddmmyyyy()
        );
    END IF;

    SELECT 1 AS success;
END$$

DELIMITER ;

/* Actualizar SP de submódulos por usuario para considerar exclusiones del rol */
DROP PROCEDURE IF EXISTS usp_submodulos_modulo_usuario;

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
            WHEN ex_g.IDSUBMODULO IS NOT NULL THEN 0
            ELSE 1
        END AS asignado
    FROM SUBMODULO s
    LEFT JOIN USUARIO_SUBMODULO_EXCLUIDO ex_u
        ON ex_u.IDSUBMODULO = s.IDSUBMODULO AND ex_u.IDUSUARIO = p_idusuario
    LEFT JOIN GRUPO_SUBMODULO_EXCLUIDO ex_g
        ON ex_g.IDSUBMODULO = s.IDSUBMODULO AND ex_g.IDTIPOUSUARIO = v_idtipo
    WHERE s.IDMODULO = p_idmodulo
      AND s.ACTIVO = 1
    ORDER BY s.ORDEN, s.NOMBRE;
END$$

DELIMITER ;

SELECT 'modulos_admin_rol.sql ejecutado correctamente' AS info;
