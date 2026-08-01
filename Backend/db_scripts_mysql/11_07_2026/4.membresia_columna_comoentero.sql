-- Convertido automáticamente desde db_scripts/11_07_2026/4.membresia_columna_comoentero.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   Columna COMOENTERO en MEMBRESIA (cómo se enteró del servicio)
   Fecha: 12/07/2026
   ============================================================================ */

SET @col_MEMBRESIA_COMOENTERO := (
    SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'MEMBRESIA' AND COLUMN_NAME = 'COMOENTERO'
);
SET @sql_MEMBRESIA_COMOENTERO := IF(@col_MEMBRESIA_COMOENTERO = 0, 'ALTER TABLE MEMBRESIA ADD COMOENTERO VARCHAR(100) NULL', 'SELECT 1');
PREPARE stmt FROM @sql_MEMBRESIA_COMOENTERO; EXECUTE stmt; DEALLOCATE PREPARE stmt;