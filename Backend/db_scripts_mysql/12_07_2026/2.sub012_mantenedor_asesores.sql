-- ============================================================================
-- Submódulo Mantenedor de asesores bajo Académico (MOD009) — MySQL 8
-- ============================================================================

USE `AcademiaDB`;

INSERT INTO SUBMODULO (IDSUBMODULO, NOMBRE, DESCRIPCION, ICONO, ORDEN, ACTIVO, IDMODULO)
VALUES (
    'SUB012',
    'Mantenedor de asesores',
    'Registrar y administrar asesores',
    'faIdCard',
    2,
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

SELECT 'SUB012 (Mantenedor de asesores) listo.' AS info;
