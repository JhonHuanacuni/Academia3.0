-- Convertido automáticamente desde db_scripts/06_07_2026/4.usuario_columna_foto.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   Columna FOTO en USUARIO (imagen en Base64, sin prefijo data:image/...)
   Ejecutar después de scripts 22_06_2026 (esquema + usp_usuario_crud)
   Fecha: 06/07/2026
   ============================================================================ */

-- TODO MySQL: add column if missing on USUARIO.FOTO
BEGIN
    ALTER TABLE USUARIO ADD FOTO LONGTEXT NULL;
    SELECT 'Columna USUARIO.FOTO agregada.';
