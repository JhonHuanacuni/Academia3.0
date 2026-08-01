-- Convertido automáticamente desde db_scripts/11_07_2026/1.usuario_columnas_apoderado.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   Columnas de apoderado en USUARIO
   NOMBREAPODERADO, PARENTESCO (TELAPODERADO ya existe)
   Fecha: 11/07/2026
   ============================================================================ */

SET @col_USUARIO_NOMBREAPODERADO := (
    SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'USUARIO' AND COLUMN_NAME = 'NOMBREAPODERADO'
);
SET @sql_USUARIO_NOMBREAPODERADO := IF(@col_USUARIO_NOMBREAPODERADO = 0, 'ALTER TABLE USUARIO ADD NOMBREAPODERADO VARCHAR(200) NULL', 'SELECT 1');
PREPARE stmt FROM @sql_USUARIO_NOMBREAPODERADO; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @col_USUARIO_PARENTESCO := (
    SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'USUARIO' AND COLUMN_NAME = 'PARENTESCO'
);
SET @sql_USUARIO_PARENTESCO := IF(@col_USUARIO_PARENTESCO = 0, 'ALTER TABLE USUARIO ADD PARENTESCO VARCHAR(50) NULL', 'SELECT 1');
PREPARE stmt FROM @sql_USUARIO_PARENTESCO; EXECUTE stmt; DEALLOCATE PREPARE stmt;