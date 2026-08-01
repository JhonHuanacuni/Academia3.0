-- ============================================================================
-- Módulo Académico (MOD009) + submódulo Mantenedor de Aulas (SUB010) — MySQL 8
-- ============================================================================

USE `AcademiaDB`;

INSERT INTO MODULO (IDMODULO, NOMBRE, DESCRIPCION, ICONO, ORDEN, ACTIVO, FECHACREACION)
VALUES ('MOD009', 'Académico', 'Gestión académica: aulas, horarios y turnos', 'faGraduationCap', 8, 1, fn_fecha_ddmmyyyy())
ON DUPLICATE KEY UPDATE
    NOMBRE = 'Académico',
    DESCRIPCION = 'Gestión académica: aulas, horarios y turnos',
    ICONO = 'faGraduationCap',
    ORDEN = 8,
    ACTIVO = 1;

INSERT INTO SUBMODULO (IDSUBMODULO, NOMBRE, DESCRIPCION, ICONO, ORDEN, ACTIVO, IDMODULO)
VALUES ('SUB010', 'Mantenedor de aulas', 'Registrar y administrar aulas / salones', 'faChalkboard', 1, 1, 'MOD009')
ON DUPLICATE KEY UPDATE
    NOMBRE = 'Mantenedor de aulas',
    DESCRIPCION = 'Registrar y administrar aulas / salones',
    ICONO = 'faChalkboard',
    ORDEN = 1,
    ACTIVO = 1,
    IDMODULO = 'MOD009';

INSERT IGNORE INTO GRUPO_MODULO (IDGRUPOMODULO, IDTIPOUSUARIO, IDMODULO, IDTIPOPERMISO) VALUES
('GRM048', '3', 'MOD009', 'TP001'),
('GRM049', '3', 'MOD009', 'TP002'),
('GRM050', '3', 'MOD009', 'TP003'),
('GRM051', '3', 'MOD009', 'TP004');

INSERT IGNORE INTO GRUPO_MODULO (IDGRUPOMODULO, IDTIPOUSUARIO, IDMODULO, IDTIPOPERMISO) VALUES
('GRM052', '2', 'MOD009', 'TP001'),
('GRM053', '2', 'MOD009', 'TP002'),
('GRM054', '2', 'MOD009', 'TP003');

INSERT IGNORE INTO AULA (IDAULA, NOMBRE, DESCRIPCION, CAPACIDAD, ACTIVO, ENLACEVIRTUAL, ENLACECUESTIONARIO) VALUES
('AUL001', 'Salón A', 'Aula principal — nivel inicial', 25, 1, NULL, NULL),
('AUL002', 'Salón B', 'Aula intermedio', 20, 1, NULL, NULL),
('AUL003', 'Salón C', 'Aula avanzado', 18, 1, NULL, NULL);

SELECT 'Módulo Académico (MOD009) y submódulo Aulas (SUB010) listos.' AS info;
