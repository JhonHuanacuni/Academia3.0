-- ============================================================================
-- Submódulo Académico: Importar notas — MySQL 8
-- ============================================================================

USE `AcademiaDB`;

INSERT INTO SUBMODULO (IDSUBMODULO, NOMBRE, DESCRIPCION, ICONO, ORDEN, ACTIVO, IDMODULO)
VALUES (
    'SUB026',
    'Importar notas',
    'Importar calificaciones desde Excel Scantron',
    'faFileImport',
    5,
    1,
    'MOD009'
)
ON DUPLICATE KEY UPDATE
    NOMBRE = VALUES(NOMBRE),
    DESCRIPCION = VALUES(DESCRIPCION),
    ICONO = VALUES(ICONO),
    ORDEN = VALUES(ORDEN),
    ACTIVO = VALUES(ACTIVO),
    IDMODULO = VALUES(IDMODULO);

SELECT 'SUB026 Importar notas listo.' AS info;
