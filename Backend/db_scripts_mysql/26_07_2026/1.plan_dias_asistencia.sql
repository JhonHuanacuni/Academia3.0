-- ============================================================================
-- PLAN: días de asistencia por plan (bitmask lun=1, mar=2, … dom=64) — MySQL 8
-- Ejecutar después de 16_07_2026/11.plan_costo_mensual.sql
-- Los SPs de plan se actualizan en 26_07_2026/6.plan_turno.sql
-- Fecha: 26/07/2026
-- ============================================================================

USE `AcademiaDB`;

SET @col_PLAN_DIASASISTENCIA := (
    SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'PLAN' AND COLUMN_NAME = 'DIASASISTENCIA'
);
SET @sql_PLAN_DIASASISTENCIA := IF(
    @col_PLAN_DIASASISTENCIA = 0,
    'ALTER TABLE `PLAN` ADD DIASASISTENCIA TINYINT NOT NULL DEFAULT 63',
    'SELECT 1'
);
PREPARE stmt FROM @sql_PLAN_DIASASISTENCIA;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

UPDATE `PLAN`
SET DIASASISTENCIA = 63
WHERE DIASASISTENCIA IS NULL OR DIASASISTENCIA = 0;
