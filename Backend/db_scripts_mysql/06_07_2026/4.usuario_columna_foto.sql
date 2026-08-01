-- Convertido automáticamente desde db_scripts/06_07_2026/4.usuario_columna_foto.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   Columna FOTO en USUARIO (imagen en Base64, sin prefijo data:image/...)
   Ejecutar después de scripts 22_06_2026 (CONCAT(esquema, usp_usuario_crud))
   Fecha: 06/07/2026
   ============================================================================ */

SET @col_USUARIO_FOTO := (
    SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'USUARIO' AND COLUMN_NAME = 'FOTO'
);
SET @sql_USUARIO_FOTO := IF(@col_USUARIO_FOTO = 0, 'ALTER TABLE USUARIO ADD FOTO LONGTEXT NULL', 'SELECT 1');
PREPARE stmt FROM @sql_USUARIO_FOTO; EXECUTE stmt; DEALLOCATE PREPARE stmt;