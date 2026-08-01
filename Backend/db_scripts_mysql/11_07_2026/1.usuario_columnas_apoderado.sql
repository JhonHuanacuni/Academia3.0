-- Convertido automáticamente desde db_scripts/11_07_2026/1.usuario_columnas_apoderado.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   Columnas de apoderado en USUARIO
   NOMBREAPODERADO, PARENTESCO (TELAPODERADO ya existe)
   Fecha: 11/07/2026
   ============================================================================ */

-- TODO MySQL: add column if missing on USUARIO.NOMBREAPODERADO
BEGIN
    ALTER TABLE USUARIO ADD NOMBREAPODERADO VARCHAR(200) NULL;
    SELECT 'Columna USUARIO.NOMBREAPODERADO agregada.';

-- TODO MySQL: add column if missing on USUARIO.PARENTESCO
BEGIN
    ALTER TABLE USUARIO ADD PARENTESCO VARCHAR(50) NULL;
    SELECT 'Columna USUARIO.PARENTESCO agregada.';
