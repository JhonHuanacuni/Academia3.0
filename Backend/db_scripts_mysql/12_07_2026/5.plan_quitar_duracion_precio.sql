-- ============================================================================
-- PLAN: quitar DURACIONDIAS y PRECIO — MySQL 8
-- Esos valores se registran en MEMBRESIA (fechas + MONTOTOTAL).
-- ============================================================================

USE `AcademiaDB`;

SET @exists = (
    SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'PLAN' AND COLUMN_NAME = 'DURACIONDIAS'
);
SET @ddl = IF(@exists > 0, 'ALTER TABLE `PLAN` DROP COLUMN DURACIONDIAS', 'SELECT ''PLAN.DURACIONDIAS ya no existe'' AS info');
PREPARE _stmt FROM @ddl;
EXECUTE _stmt;
DEALLOCATE PREPARE _stmt;

SET @exists = (
    SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'PLAN' AND COLUMN_NAME = 'PRECIO'
);
SET @ddl = IF(@exists > 0, 'ALTER TABLE `PLAN` DROP COLUMN PRECIO', 'SELECT ''PLAN.PRECIO ya no existe'' AS info');
PREPARE _stmt FROM @ddl;
EXECUTE _stmt;
DEALLOCATE PREPARE _stmt;
