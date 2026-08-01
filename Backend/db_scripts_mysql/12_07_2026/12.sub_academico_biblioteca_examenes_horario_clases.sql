-- ============================================================================
-- Submódulos Académico: Biblioteca, Exámenes, Horario, Clases — MySQL 8
-- Desactiva MOD005 (Biblioteca) y MOD006 (Exámenes) como módulos sueltos
-- ============================================================================

USE `AcademiaDB`;

INSERT INTO SUBMODULO (IDSUBMODULO, NOMBRE, DESCRIPCION, ICONO, ORDEN, ACTIVO, IDMODULO)
VALUES
    ('SUB014', 'Biblioteca', 'Recursos educativos y archivos de la biblioteca', 'faBook', 4, 1, 'MOD009'),
    ('SUB015', 'Exámenes', 'Gestión de exámenes, resultados y evaluaciones', 'faFileLines', 5, 1, 'MOD009'),
    ('SUB016', 'Horario', 'Agenda y horarios de clases, salones y eventos', 'faCalendarDays', 6, 1, 'MOD009'),
    ('SUB017', 'Clases', 'Registro y administración de clases', 'faChalkboardTeacher', 7, 1, 'MOD009')
ON DUPLICATE KEY UPDATE
    NOMBRE = VALUES(NOMBRE),
    DESCRIPCION = VALUES(DESCRIPCION),
    ICONO = VALUES(ICONO),
    ORDEN = VALUES(ORDEN),
    ACTIVO = VALUES(ACTIVO),
    IDMODULO = VALUES(IDMODULO);

UPDATE MODULO SET ACTIVO = 0 WHERE IDMODULO IN ('MOD005', 'MOD006');
UPDATE SUBMODULO SET ACTIVO = 0 WHERE IDMODULO IN ('MOD005', 'MOD006');

SELECT 'Submódulos Académico: Biblioteca, Exámenes, Horario, Clases listos.' AS info;
