-- ============================================================================
-- Submódulo Académico: Auditoría del sistema — MySQL 8
-- ============================================================================

USE `AcademiaDB`;

INSERT INTO SUBMODULO (IDSUBMODULO, NOMBRE, DESCRIPCION, ICONO, ORDEN, ACTIVO, IDMODULO)
VALUES ('SUB027', 'Auditoría', 'Historial de altas, modificaciones y eliminaciones en el sistema', 'faClipboardList', 6, 1, 'MOD009')
ON DUPLICATE KEY UPDATE
    NOMBRE = 'Auditoría',
    DESCRIPCION = 'Historial de altas, modificaciones y eliminaciones en el sistema',
    ICONO = 'faClipboardList',
    ORDEN = 6,
    ACTIVO = 1,
    IDMODULO = 'MOD009';

SELECT 'SUB027 Auditoría listo (visible para roles con acceso a MOD009 Académico).' AS info;