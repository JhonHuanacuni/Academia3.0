-- ============================================================================
-- Importar notas: desactivar MOD007, SUB026 bajo Académico — MySQL 8
-- ============================================================================

USE `AcademiaDB`;

UPDATE MODULO SET ACTIVO = 0 WHERE IDMODULO = 'MOD007';
UPDATE SUBMODULO SET ACTIVO = 0 WHERE IDMODULO = 'MOD007';

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

SELECT 'MOD007 desactivado; SUB026 Importar notas activo bajo MOD009 Académico.' AS info;
