-- Convertido automáticamente desde db_scripts/30_07_2026/7.modulos_admin_rol.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   Administración de módulos y submódulos POR ROL (TIPOUSUARIO)
   Ejecutar después de modulos_admin.sql y submodulos_admin.sql
   Fecha: 30/07/2026
   ============================================================================ */

-- create if missing GRUPO_SUBMODULO_EXCLUIDO
    CREATE TABLE IF NOT EXISTS GRUPO_SUBMODULO_EXCLUIDO (
        IDGRUPOEXCLSUB    VARCHAR(50)  NOT NULL PRIMARY KEY,
        IDTIPOUSUARIO     VARCHAR(50)  NOT NULL,
        IDSUBMODULO       VARCHAR(50)  NOT NULL,
        FECHAREGISTRO     CHAR(8)       NULL,
        CONSTRAINT FK_GEXCLSUB_TIPO FOREIGN KEY (IDTIPOUSUARIO) REFERENCES TIPOUSUARIO(IDTIPOUSUARIO),
        CONSTRAINT FK_GEXCLSUB_SUB  FOREIGN KEY (IDSUBMODULO) REFERENCES SUBMODULO(IDSUBMODULO),
        CONSTRAINT UQ_GRUPO_SUBMODULO_EXCL UNIQUE (IDTIPOUSUARIO, IDSUBMODULO)
    );

DROP PROCEDURE IF EXISTS usp_modulos_efectivos_rol;

DROP PROCEDURE IF EXISTS usp_modulos_efectivos_rol;

DELIMITER $$

CREATE PROCEDURE usp_modulos_efectivos_rol(
    IN p_idtipousuario VARCHAR(50)
)
main: BEGIN
IF NOT EXISTS (SELECT 1 FROM TIPOUSUARIO WHERE IDTIPOUSUARIO = p_idtipousuario)
        LEAVE main;

    ;WITH PermisosRol AS (
        SELECT gm.IDMODULO, tp.DESCRIPCION AS PERMISO
        FROM GRUPO_MODULO gm
        INNER JOIN TIPO_PERMISO tp ON tp.IDTIPOPERMISO = gm.IDTIPOPERMISO
        WHERE gm.IDTIPOUSUARIO = p_idtipousuario
    )
    SELECT
        m.IDMODULO,
        m.NOMBRE,
        m.DESCRIPCION,
        m.ICONO,
        m.ORDEN,
        STRING_AGG(pr.PERMISO, ',') WITHIN GROUP (ORDER BY pr.PERMISO) AS PERMISOS
    FROM PermisosRol pr
    INNER JOIN MODULO m ON m.IDMODULO = pr.IDMODULO AND m.ACTIVO = 1
    GROUP BY m.IDMODULO, m.NOMBRE, m.DESCRIPCION, m.ICONO, m.ORDEN
    ORDER BY m.ORDEN, m.NOMBRE;
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_modulo_asignar_rol;

DROP PROCEDURE IF EXISTS usp_modulo_asignar_rol;

DELIMITER $$

CREATE PROCEDURE usp_modulo_asignar_rol(
    IN p_idtipousuario VARCHAR(50),
    IN p_idmodulo VARCHAR(50)
)
main: BEGIN
IF NOT EXISTS (SELECT 1 FROM TIPOUSUARIO WHERE IDTIPOUSUARIO = p_idtipousuario)
    BEGIN
        RAISERROR('Tipo de usuario no encontrado', 16, 1);
        LEAVE main;
    
    IF NOT EXISTS (SELECT 1 FROM MODULO WHERE IDMODULO = p_idmodulo AND ACTIVO = 1)
    BEGIN
        RAISERROR('Módulo no encontrado o inactivo', 16, 1);
        LEAVE main;
    
    DECLARE v_perms TABLE (IDTIPOPERMISO VARCHAR(50));
    INSERT INTO v_perms VALUES ('TP001'), ('TP002'), ('TP003'), ('TP004');

    DECLARE v_idpermiso VARCHAR(50);
    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR SELECT IDTIPOPERMISO FROM v_perms;
    OPEN cur;
    FETCH NEXT FROM cur INTO v_idpermiso;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF NOT EXISTS (
            SELECT 1 FROM GRUPO_MODULO
            WHERE IDTIPOUSUARIO = p_idtipousuario
              AND IDMODULO = p_idmodulo
              AND IDTIPOPERMISO = v_idpermiso
        )
        BEGIN
            INSERT INTO GRUPO_MODULO (IDGRUPOMODULO, IDTIPOUSUARIO, IDMODULO, IDTIPOPERMISO)
            VALUES (
                'GRM_' + REPLACE(CONVERT(VARCHAR(36), NEWID()), '-', ''),
                p_idtipousuario,
                p_idmodulo,
                v_idpermiso
            );
        
        FETCH NEXT FROM cur INTO v_idpermiso;
    
    CLOSE cur;
    DEALLOCATE cur;

    SELECT 1 AS success;
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_modulo_desasignar_rol;

DROP PROCEDURE IF EXISTS usp_modulo_desasignar_rol;

DELIMITER $$

CREATE PROCEDURE usp_modulo_desasignar_rol(
    IN p_idtipousuario VARCHAR(50),
    IN p_idmodulo VARCHAR(50)
)
main: BEGIN
IF p_idtipousuario = '3' AND p_idmodulo IN ('MOD001', 'MOD008')
    BEGIN
        RAISERROR('No se puede quitar este módulo al rol Administrador (Dashboard y Administración de Módulos son obligatorios).', 16, 1);
        LEAVE main;
    
    DELETE FROM GRUPO_MODULO
    WHERE IDTIPOUSUARIO = p_idtipousuario AND IDMODULO = p_idmodulo;

    DELETE gex
    FROM GRUPO_SUBMODULO_EXCLUIDO gex
    INNER JOIN SUBMODULO s ON s.IDSUBMODULO = gex.IDSUBMODULO
    WHERE gex.IDTIPOUSUARIO = p_idtipousuario
      AND s.IDMODULO = p_idmodulo;

    SELECT 1 AS success;
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_submodulos_modulo_rol;

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
        CAST(CASE WHEN ex.IDSUBMODULO IS NULL THEN 1 ELSE 0 END AS TINYINT(1)) AS asignado
    FROM SUBMODULO s
    LEFT JOIN GRUPO_SUBMODULO_EXCLUIDO ex
        ON ex.IDSUBMODULO = s.IDSUBMODULO AND ex.IDTIPOUSUARIO = p_idtipousuario
    WHERE s.IDMODULO = p_idmodulo
      AND s.ACTIVO = 1
    ORDER BY s.ORDEN, s.NOMBRE;
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_submodulo_asignar_rol;

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
    )
    BEGIN
        INSERT INTO GRUPO_SUBMODULO_EXCLUIDO (IDGRUPOEXCLSUB, IDTIPOUSUARIO, IDSUBMODULO, FECHAREGISTRO)
        VALUES (
            'GEXS_' + REPLACE(CONVERT(VARCHAR(36), NEWID()), '-', ''),
            p_idtipousuario,
            p_idsubmodulo,
            fn_fecha_ddmmyyyy()
        );
    
    SELECT 1 AS success;
END;

/* Actualizar SP de submódulos por usuario para considerar exclusiones del rol */
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_submodulos_modulo_usuario;

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
        CAST(CASE
            WHEN ex_u.IDSUBMODULO IS NOT NULL THEN 0
            WHEN ex_g.IDSUBMODULO IS NOT NULL THEN 0
            ELSE 1
        END AS TINYINT(1)) AS asignado
    FROM SUBMODULO s
    LEFT JOIN USUARIO_SUBMODULO_EXCLUIDO ex_u
        ON ex_u.IDSUBMODULO = s.IDSUBMODULO AND ex_u.IDUSUARIO = p_idusuario
    LEFT JOIN GRUPO_SUBMODULO_EXCLUIDO ex_g
        ON ex_g.IDSUBMODULO = s.IDSUBMODULO AND ex_g.IDTIPOUSUARIO = v_idtipo
    WHERE s.IDMODULO = p_idmodulo
      AND s.ACTIVO = 1
    ORDER BY s.ORDEN, s.NOMBRE;
END;

SELECT 'modulos_admin_rol.sql ejecutado correctamente';
END$$

DELIMITER ;
