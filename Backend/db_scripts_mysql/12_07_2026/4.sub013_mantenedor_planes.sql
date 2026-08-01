-- ============================================================================
-- Submódulo Mantenedor de planes bajo Académico (MOD009) — MySQL 8
-- ============================================================================

USE `AcademiaDB`;

INSERT INTO SUBMODULO (IDSUBMODULO, NOMBRE, DESCRIPCION, ICONO, ORDEN, ACTIVO, IDMODULO)
VALUES (
    'SUB013',
    'Mantenedor de planes',
    'Registrar y administrar tipos de plan',
    'faClipboardList',
    3,
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

SELECT 'SUB013 (Mantenedor de planes) listo.' AS info;
