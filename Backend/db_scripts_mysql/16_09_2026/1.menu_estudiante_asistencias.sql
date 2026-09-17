-- ============================================================================
-- Estudiantes: submódulo Asistencias (SUB031) bajo Académico
-- Fecha: 16/09/2026
-- phpMyAdmin: selecciona AcademiaDB y ejecuta (delimitador ;)
-- ============================================================================

INSERT INTO SUBMODULO (IDSUBMODULO, NOMBRE, DESCRIPCION, ICONO, ORDEN, ACTIVO, IDMODULO)
VALUES (
    'SUB031',
    'Asistencias',
    'Consulta el historial de asistencias del estudiante',
    'faCalendarCheck',
    5,
    1,
    'MOD009'
)
ON DUPLICATE KEY UPDATE
    NOMBRE = 'Asistencias',
    DESCRIPCION = 'Consulta el historial de asistencias del estudiante',
    ICONO = 'faCalendarCheck',
    ORDEN = 5,
    ACTIVO = 1,
    IDMODULO = 'MOD009';

-- Visible para estudiantes (tipo 1). No duplicar en menú de trabajador/admin.
DELETE FROM GRUPO_SUBMODULO_EXCLUIDO
WHERE IDSUBMODULO = 'SUB031' AND IDTIPOUSUARIO = '1';

INSERT IGNORE INTO GRUPO_SUBMODULO_EXCLUIDO (IDGRUPOEXCLSUB, IDTIPOUSUARIO, IDSUBMODULO, FECHAREGISTRO)
VALUES
    ('GEX_ASIS_EST_TRAB', '2', 'SUB031', DATE_FORMAT(NOW(), '%d%m%Y')),
    ('GEX_ASIS_EST_ADM', '3', 'SUB031', DATE_FORMAT(NOW(), '%d%m%Y'));

SELECT 'SUB031 Asistencias listo para estudiantes.' AS info;
