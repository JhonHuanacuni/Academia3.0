-- Convertido automáticamente desde db_scripts/11_07_2026/4.membresia_columna_comoentero.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   Columna COMOENTERO en MEMBRESIA (cómo se enteró del servicio)
   Fecha: 12/07/2026
   ============================================================================ */

-- TODO MySQL: add column if missing on MEMBRESIA.COMOENTERO
BEGIN
    ALTER TABLE MEMBRESIA ADD COMOENTERO VARCHAR(100) NULL;
    SELECT 'Columna MEMBRESIA.COMOENTERO agregada.';
