-- ============================================================================
-- Módulo Mantenedores (MOD011) — MySQL 8
-- ============================================================================

USE `AcademiaDB`;

INSERT INTO MODULO (IDMODULO, NOMBRE, DESCRIPCION, ICONO, ORDEN, ACTIVO, FECHACREACION)
VALUES ('MOD011', 'Mantenedores', 'Catálogos y mantenedores del sistema', 'faDatabase', 8, 1, fn_fecha_ddmmyyyy())
ON DUPLICATE KEY UPDATE
    NOMBRE = 'Mantenedores',
    DESCRIPCION = 'Catálogos y mantenedores del sistema',
    ICONO = 'faDatabase',
    ORDEN = 8,
    ACTIVO = 1;

UPDATE MODULO SET ORDEN = 7 WHERE IDMODULO = 'MOD009';
UPDATE MODULO SET ORDEN = 9 WHERE IDMODULO = 'MOD010';

INSERT INTO SUBMODULO (IDSUBMODULO, NOMBRE, DESCRIPCION, ICONO, ORDEN, ACTIVO, IDMODULO)
VALUES ('SUB010', 'Aulas', 'Registrar y administrar aulas / salones', 'faChalkboard', 1, 1, 'MOD011')
ON DUPLICATE KEY UPDATE
    NOMBRE = 'Aulas',
    DESCRIPCION = 'Registrar y administrar aulas / salones',
    ICONO = 'faChalkboard',
    ORDEN = 1,
    ACTIVO = 1,
    IDMODULO = 'MOD011';

INSERT INTO SUBMODULO (IDSUBMODULO, NOMBRE, DESCRIPCION, ICONO, ORDEN, ACTIVO, IDMODULO)
VALUES ('SUB012', 'Asesores', 'Registrar y administrar asesores', 'faIdCard', 2, 1, 'MOD011')
ON DUPLICATE KEY UPDATE
    NOMBRE = 'Asesores',
    DESCRIPCION = 'Registrar y administrar asesores',
    ICONO = 'faIdCard',
    ORDEN = 2,
    ACTIVO = 1,
    IDMODULO = 'MOD011';

INSERT INTO SUBMODULO (IDSUBMODULO, NOMBRE, DESCRIPCION, ICONO, ORDEN, ACTIVO, IDMODULO)
VALUES ('SUB013', 'Planes', 'Registrar y administrar tipos de plan', 'faLayerGroup', 3, 1, 'MOD011')
ON DUPLICATE KEY UPDATE
    NOMBRE = 'Planes',
    DESCRIPCION = 'Registrar y administrar tipos de plan',
    ICONO = 'faLayerGroup',
    ORDEN = 3,
    ACTIVO = 1,
    IDMODULO = 'MOD011';

UPDATE SUBMODULO SET ORDEN = 1 WHERE IDSUBMODULO = 'SUB014';
UPDATE SUBMODULO SET ORDEN = 2 WHERE IDSUBMODULO = 'SUB015';
UPDATE SUBMODULO SET ORDEN = 3 WHERE IDSUBMODULO = 'SUB016';
UPDATE SUBMODULO SET ORDEN = 4 WHERE IDSUBMODULO = 'SUB017';

INSERT IGNORE INTO GRUPO_MODULO (IDGRUPOMODULO, IDTIPOUSUARIO, IDMODULO, IDTIPOPERMISO) VALUES
('GRM060', '3', 'MOD011', 'TP001'),
('GRM061', '3', 'MOD011', 'TP002'),
('GRM062', '3', 'MOD011', 'TP003'),
('GRM063', '3', 'MOD011', 'TP004');

INSERT IGNORE INTO GRUPO_MODULO (IDGRUPOMODULO, IDTIPOUSUARIO, IDMODULO, IDTIPOPERMISO) VALUES
('GRM064', '2', 'MOD011', 'TP001'),
('GRM065', '2', 'MOD011', 'TP002');

SELECT 'Módulo Mantenedores (MOD011) con Aulas, Asesores y Planes listo.' AS info;
