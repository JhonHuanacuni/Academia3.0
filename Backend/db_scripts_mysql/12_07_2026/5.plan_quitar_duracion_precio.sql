-- Convertido automáticamente desde db_scripts/12_07_2026/5.plan_quitar_duracion_precio.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   PLAN: quitar DURACIONDIAS y PRECIO
   Esos valores se registran en MEMBRESIA (CONCAT(fechas, MONTOTOTAL)).
   Ejecutar después de 3.usp_plan_crud.sql
   Fecha: 12/07/2026
   ============================================================================ */

IF (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'PLAN' AND COLUMN_NAME = 'DURACIONDIAS') > 0
BEGIN
    ALTER TABLE `PLAN` DROP COLUMN DURACIONDIAS;
    SELECT 'Columna PLAN.DURACIONDIAS eliminada.';

IF (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'PLAN' AND COLUMN_NAME = 'PRECIO') > 0
BEGIN
    ALTER TABLE `PLAN` DROP COLUMN PRECIO;
    SELECT 'Columna PLAN.PRECIO eliminada.';