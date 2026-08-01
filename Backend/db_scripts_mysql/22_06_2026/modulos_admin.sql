-- ============================================================================
-- ADMINISTRACIÓN DE MÓDULOS — Datos iniciales + SPs (MySQL 8)
-- Ejecutar DESPUÉS de esquema_completo.sql
-- ============================================================================

USE `AcademiaDB`;

DROP FUNCTION IF EXISTS fn_fecha_ddmmyyyy;

DELIMITER $$

CREATE FUNCTION fn_fecha_ddmmyyyy()
RETURNS CHAR(8)
DETERMINISTIC
NO SQL
BEGIN
    RETURN CONCAT(
        LPAD(DAY(NOW()), 2, '0'),
        LPAD(MONTH(NOW()), 2, '0'),
        YEAR(NOW())
    );
END$$

DELIMITER ;

CREATE TABLE IF NOT EXISTS USUARIO_MODULO_EXCLUIDO (
    IDUSUARIOEXCLUIDO   VARCHAR(50) NOT NULL PRIMARY KEY,
    IDUSUARIO           VARCHAR(50) NOT NULL,
    IDMODULO            VARCHAR(50) NOT NULL,
    FECHAREGISTRO       CHAR(8)     NULL,
    CONSTRAINT UQ_USUARIO_MODULO_EXCLUIDO UNIQUE (IDUSUARIO, IDMODULO),
    CONSTRAINT FK_UMEXCL_USUARIO FOREIGN KEY (IDUSUARIO) REFERENCES USUARIO (IDUSUARIO),
    CONSTRAINT FK_UMEXCL_MODULO FOREIGN KEY (IDMODULO) REFERENCES MODULO (IDMODULO)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX IX_USUARIO_MOD_EXCL_USUARIO ON USUARIO_MODULO_EXCLUIDO (IDUSUARIO);

INSERT IGNORE INTO TIPO_PERMISO (IDTIPOPERMISO, DESCRIPCION) VALUES
('TP001', 'VER'),
('TP002', 'CREAR'),
('TP003', 'EDITAR'),
('TP004', 'ELIMINAR');

INSERT IGNORE INTO MODULO (IDMODULO, NOMBRE, DESCRIPCION, ICONO, ORDEN, ACTIVO, FECHACREACION) VALUES
('MOD001', 'Dashboard', 'Panel de control principal', 'faGauge', 1, 1, fn_fecha_ddmmyyyy()),
('MOD002', 'Usuarios', 'Gestión de usuarios y roles', 'faUsers', 2, 1, fn_fecha_ddmmyyyy()),
('MOD003', 'Asistencias', 'Control de asistencias', 'faCalendarCheck', 3, 1, fn_fecha_ddmmyyyy()),
('MOD004', 'Membresías', 'Gestión de membresías y pagos', 'faIdCard', 4, 1, fn_fecha_ddmmyyyy()),
('MOD005', 'Biblioteca', 'Recursos educativos', 'faBook', 5, 1, fn_fecha_ddmmyyyy()),
('MOD006', 'Exámenes', 'Gestión de exámenes', 'faFileLines', 6, 1, fn_fecha_ddmmyyyy()),
('MOD007', 'Notas', 'Calificaciones y progreso', 'faFilePen', 7, 1, fn_fecha_ddmmyyyy()),
('MOD008', 'Administración Módulos', 'Asignar acceso a módulos', 'faCog', 99, 1, fn_fecha_ddmmyyyy());

INSERT IGNORE INTO SUBMODULO (IDSUBMODULO, NOMBRE, DESCRIPCION, ICONO, ORDEN, ACTIVO, IDMODULO) VALUES
('SUB002', 'Listado de usuarios', 'Ver y gestionar usuarios', 'faClipboardList', 1, 1, 'MOD002'),
('SUB003', 'Marcar asistencia', 'Registrar asistencia', 'faCalendarCheck', 1, 1, 'MOD003'),
('SUB004', 'Ver asistencias', 'Historial de asistencias', 'faClipboardList', 2, 1, 'MOD003'),
('SUB005', 'Registrar membresía', 'Nueva membresía', 'faUserPlus', 1, 1, 'MOD004'),
('SUB006', 'Ver membresías', 'Listado de membresías', 'faClipboardList', 2, 1, 'MOD004'),
('SUB007', 'Pagos', 'Gestión de pagos', 'faMoneyBill', 3, 1, 'MOD004'),
('SUB008', 'Ver notas', 'Consultar calificaciones', 'faClipboardList', 1, 1, 'MOD007'),
('SUB009', 'Asignar módulos', 'Dar acceso a módulos', 'faKey', 1, 1, 'MOD008');

INSERT IGNORE INTO GRUPO_MODULO (IDGRUPOMODULO, IDTIPOUSUARIO, IDMODULO, IDTIPOPERMISO) VALUES
('GRM001', '3', 'MOD001', 'TP001'), ('GRM002', '3', 'MOD001', 'TP002'),
('GRM003', '3', 'MOD001', 'TP003'), ('GRM004', '3', 'MOD001', 'TP004'),
('GRM005', '3', 'MOD002', 'TP001'), ('GRM006', '3', 'MOD002', 'TP002'),
('GRM007', '3', 'MOD002', 'TP003'), ('GRM008', '3', 'MOD002', 'TP004'),
('GRM009', '3', 'MOD003', 'TP001'), ('GRM010', '3', 'MOD003', 'TP002'),
('GRM011', '3', 'MOD003', 'TP003'), ('GRM012', '3', 'MOD003', 'TP004'),
('GRM013', '3', 'MOD004', 'TP001'), ('GRM014', '3', 'MOD004', 'TP002'),
('GRM015', '3', 'MOD004', 'TP003'), ('GRM016', '3', 'MOD004', 'TP004'),
('GRM017', '3', 'MOD005', 'TP001'), ('GRM018', '3', 'MOD005', 'TP002'),
('GRM019', '3', 'MOD005', 'TP003'), ('GRM020', '3', 'MOD005', 'TP004'),
('GRM021', '3', 'MOD006', 'TP001'), ('GRM022', '3', 'MOD006', 'TP002'),
('GRM023', '3', 'MOD006', 'TP003'), ('GRM024', '3', 'MOD006', 'TP004'),
('GRM025', '3', 'MOD007', 'TP001'), ('GRM026', '3', 'MOD007', 'TP002'),
('GRM027', '3', 'MOD007', 'TP003'), ('GRM028', '3', 'MOD007', 'TP004'),
('GRM029', '3', 'MOD008', 'TP001'), ('GRM030', '3', 'MOD008', 'TP002'),
('GRM031', '3', 'MOD008', 'TP003'), ('GRM032', '3', 'MOD008', 'TP004'),
('GRM033', '2', 'MOD001', 'TP001'), ('GRM034', '2', 'MOD001', 'TP002'),
('GRM035', '2', 'MOD002', 'TP001'), ('GRM036', '2', 'MOD002', 'TP002'),
('GRM037', '2', 'MOD003', 'TP001'), ('GRM038', '2', 'MOD003', 'TP002'),
('GRM039', '2', 'MOD004', 'TP001'), ('GRM040', '2', 'MOD004', 'TP002'),
('GRM041', '2', 'MOD005', 'TP001'),
('GRM042', '2', 'MOD006', 'TP001'),
('GRM043', '2', 'MOD007', 'TP001'),
('GRM044', '1', 'MOD001', 'TP001'),
('GRM045', '1', 'MOD005', 'TP001'),
('GRM046', '1', 'MOD006', 'TP001'),
('GRM047', '1', 'MOD007', 'TP001');

DROP PROCEDURE IF EXISTS usp_listar_usuarios_activos;
DROP PROCEDURE IF EXISTS usp_modulos_listar_activos;
DROP PROCEDURE IF EXISTS usp_submodulos_por_modulo;
DROP PROCEDURE IF EXISTS usp_modulos_efectivos_usuario;
DROP PROCEDURE IF EXISTS usp_modulo_asignar_usuario;
DROP PROCEDURE IF EXISTS usp_modulo_desasignar_usuario;

DELIMITER $$

CREATE PROCEDURE usp_listar_usuarios_activos()
main: BEGIN
    SELECT
        u.IDUSUARIO, u.NOMBRE, u.APELLIDO, u.EMAIL, u.IDTIPOUSUARIO,
        t.DESCRIPCION AS TIPOUSUARIO
    FROM USUARIO u
    INNER JOIN TIPOUSUARIO t ON t.IDTIPOUSUARIO = u.IDTIPOUSUARIO
    WHERE u.ESTADO = 'Activo'
    ORDER BY u.NOMBRE, u.APELLIDO;
END$$

CREATE PROCEDURE usp_modulos_listar_activos()
main: BEGIN
    SELECT m.IDMODULO, m.NOMBRE, m.DESCRIPCION, m.ICONO, m.ORDEN
    FROM MODULO m
    WHERE m.ACTIVO = 1
    ORDER BY m.ORDEN, m.NOMBRE;
END$$

CREATE PROCEDURE usp_submodulos_por_modulo(IN p_idmodulo VARCHAR(50))
main: BEGIN
    SELECT s.IDSUBMODULO, s.NOMBRE, s.DESCRIPCION, s.ICONO, s.ORDEN
    FROM SUBMODULO s
    WHERE s.IDMODULO = p_idmodulo AND s.ACTIVO = 1
    ORDER BY s.ORDEN, s.NOMBRE;
END$$

CREATE PROCEDURE usp_modulos_efectivos_usuario(IN p_idusuario VARCHAR(50))
main: BEGIN
    DECLARE v_idtipo VARCHAR(50);

    SELECT IDTIPOUSUARIO INTO v_idtipo
    FROM USUARIO
    WHERE IDUSUARIO = p_idusuario AND ESTADO = 'Activo';

    IF v_idtipo IS NULL THEN
        LEAVE main;
    END IF;

    SELECT
        m.IDMODULO, m.NOMBRE, m.DESCRIPCION, m.ICONO, m.ORDEN,
        GROUP_CONCAT(DISTINCT mf.PERMISO ORDER BY mf.PERMISO SEPARATOR ',') AS PERMISOS
    FROM (
        SELECT gm.IDMODULO, tp.DESCRIPCION AS PERMISO
        FROM GRUPO_MODULO gm
        INNER JOIN TIPO_PERMISO tp ON tp.IDTIPOPERMISO = gm.IDTIPOPERMISO
        WHERE gm.IDTIPOUSUARIO = v_idtipo
        UNION
        SELECT um.IDMODULO, tp.DESCRIPCION AS PERMISO
        FROM USUARIO_MODULO um
        INNER JOIN TIPO_PERMISO tp ON tp.IDTIPOPERMISO = um.IDTIPOPERMISO
        WHERE um.IDUSUARIO = p_idusuario
    ) mf
    INNER JOIN MODULO m ON m.IDMODULO = mf.IDMODULO AND m.ACTIVO = 1
    WHERE NOT EXISTS (
        SELECT 1 FROM USUARIO_MODULO_EXCLUIDO ex
        WHERE ex.IDUSUARIO = p_idusuario AND ex.IDMODULO = mf.IDMODULO
    )
    GROUP BY m.IDMODULO, m.NOMBRE, m.DESCRIPCION, m.ICONO, m.ORDEN
    ORDER BY m.ORDEN, m.NOMBRE;
END$$

CREATE PROCEDURE usp_modulo_asignar_usuario(
    IN p_idusuario VARCHAR(50),
    IN p_idmodulo VARCHAR(50)
)
main: BEGIN
    IF NOT EXISTS (SELECT 1 FROM USUARIO WHERE IDUSUARIO = p_idusuario AND ESTADO = 'Activo') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Usuario no encontrado o inactivo';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM MODULO WHERE IDMODULO = p_idmodulo AND ACTIVO = 1) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Módulo no encontrado o inactivo';
    END IF;

    DELETE FROM USUARIO_MODULO_EXCLUIDO
    WHERE IDUSUARIO = p_idusuario AND IDMODULO = p_idmodulo;

    INSERT INTO USUARIO_MODULO (IDUSUARIOMODULO, IDUSUARIO, IDMODULO, IDTIPOPERMISO)
    SELECT
        CONCAT('UM_', REPLACE(UUID(), '-', '')),
        p_idusuario,
        p_idmodulo,
        perm.IDTIPOPERMISO
    FROM (SELECT 'TP001' AS IDTIPOPERMISO UNION ALL SELECT 'TP002') perm
    WHERE NOT EXISTS (
        SELECT 1 FROM USUARIO_MODULO um
        WHERE um.IDUSUARIO = p_idusuario
          AND um.IDMODULO = p_idmodulo
          AND um.IDTIPOPERMISO = perm.IDTIPOPERMISO
    );

    SELECT 1 AS success;
END$$

CREATE PROCEDURE usp_modulo_desasignar_usuario(
    IN p_idusuario VARCHAR(50),
    IN p_idmodulo VARCHAR(50)
)
main: BEGIN
    DECLARE v_idtipo VARCHAR(50);

    SELECT IDTIPOUSUARIO INTO v_idtipo
    FROM USUARIO
    WHERE IDUSUARIO = p_idusuario AND ESTADO = 'Activo';

    IF v_idtipo IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Usuario no encontrado o inactivo';
    END IF;

    DELETE FROM USUARIO_MODULO
    WHERE IDUSUARIO = p_idusuario AND IDMODULO = p_idmodulo;

    IF EXISTS (
        SELECT 1 FROM GRUPO_MODULO
        WHERE IDTIPOUSUARIO = v_idtipo AND IDMODULO = p_idmodulo
    ) AND NOT EXISTS (
        SELECT 1 FROM USUARIO_MODULO_EXCLUIDO
        WHERE IDUSUARIO = p_idusuario AND IDMODULO = p_idmodulo
    ) THEN
        INSERT INTO USUARIO_MODULO_EXCLUIDO (IDUSUARIOEXCLUIDO, IDUSUARIO, IDMODULO, FECHAREGISTRO)
        VALUES (
            CONCAT('EX_', REPLACE(UUID(), '-', '')),
            p_idusuario,
            p_idmodulo,
            fn_fecha_ddmmyyyy()
        );
    END IF;

    SELECT 1 AS success;
END$$

DELIMITER ;

SELECT 'modulos_admin.sql ejecutado correctamente.' AS info;
