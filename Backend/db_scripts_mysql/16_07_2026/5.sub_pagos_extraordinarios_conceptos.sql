-- ============================================================================
-- Submódulos: Pagos extraordinarios (MOD004) + Conceptos (MOD011) — MySQL 8
-- ============================================================================

USE `AcademiaDB`;

INSERT INTO SUBMODULO (IDSUBMODULO, NOMBRE, DESCRIPCION, ICONO, ORDEN, ACTIVO, IDMODULO)
VALUES
    ('SUB018', 'Pagos extraordinarios', 'Pagos no ligados a membresía (conceptos especiales)', 'faMoneyBillWave', 3, 1, 'MOD004'),
    ('SUB019', 'Conceptos', 'Conceptos de pago extraordinario (nombre y costo)', 'faTags', 4, 1, 'MOD011')
ON DUPLICATE KEY UPDATE
    NOMBRE = VALUES(NOMBRE),
    DESCRIPCION = VALUES(DESCRIPCION),
    ICONO = VALUES(ICONO),
    ORDEN = VALUES(ORDEN),
    ACTIVO = VALUES(ACTIVO),
    IDMODULO = VALUES(IDMODULO);

SELECT 'Submódulos SUB018 y SUB019 listos.' AS info;
