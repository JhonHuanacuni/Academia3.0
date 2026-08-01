-- ============================================================================
-- PERMISOS POR SUBMÓDULO — control granular por usuario (MySQL 8)
-- Ejecutar después de modulos_admin.sql
-- ============================================================================

USE `AcademiaDB`;

CREATE TABLE IF NOT EXISTS USUARIO_SUBMODULO_EXCLUIDO (
    IDUSUARIOEXCLSUB  VARCHAR(50)  NOT NULL PRIMARY KEY,
    IDUSUARIO         VARCHAR(50)  NOT NULL,
    IDSUBMODULO       VARCHAR(50)  NOT NULL,
    FECHAREGISTRO     CHAR(8)      NULL,
    CONSTRAINT FK_UEXCLSUB_USUARIO FOREIGN KEY (IDUSUARIO) REFERENCES USUARIO(IDUSUARIO),
    CONSTRAINT FK_UEXCLSUB_SUB     FOREIGN KEY (IDSUBMODULO) REFERENCES SUBMODULO(IDSUBMODULO),
    CONSTRAINT UQ_USUARIO_SUBMODULO_EXCL UNIQUE (IDUSUARIO, IDSUBMODULO)
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
    SELECT
        s.IDSUBMODULO,
        s.NOMBRE,
        s.DESCRIPCION,
        s.ICONO,
        s.ORDEN,
        CASE WHEN ex.IDSUBMODULO IS NULL THEN 1 ELSE 0 END AS asignado
    FROM SUBMODULO s
    LEFT JOIN USUARIO_SUBMODULO_EXCLUIDO ex
        ON ex.IDSUBMODULO = s.IDSUBMODULO AND ex.IDUSUARIO = p_idusuario
    WHERE s.IDMODULO = p_idmodulo
      AND s.ACTIVO = 1
    ORDER BY s.ORDEN, s.NOMBRE;
END$$

CREATE PROCEDURE usp_submodulo_asignar_usuario(
    IN p_idusuario VARCHAR(50),
    IN p_idsubmodulo VARCHAR(50)
)
main: BEGIN
    DELETE FROM USUARIO_SUBMODULO_EXCLUIDO
    WHERE IDUSUARIO = p_idusuario AND IDSUBMODULO = p_idsubmodulo;

    SELECT 1 AS success;
END$$

CREATE PROCEDURE usp_submodulo_desasignar_usuario(
    IN p_idusuario VARCHAR(50),
    IN p_idsubmodulo VARCHAR(50)
)
main: BEGIN
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

SELECT 'submodulos_admin.sql ejecutado correctamente.' AS info;
