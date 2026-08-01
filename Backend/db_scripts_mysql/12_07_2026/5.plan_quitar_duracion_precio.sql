-- Convertido automáticamente desde db_scripts/12_07_2026/5.plan_quitar_duracion_precio.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   PLAN: quitar DURACIONDIAS y PRECIO
   Esos valores se registran en MEMBRESIA (CONCAT(fechas, MONTOTOTAL)).
   Ejecutar después de 3.usp_plan_crud.sql
   Fecha: 12/07/2026
   ============================================================================ */

IF COL_LENGTH('PLAN', 'DURACIONDIAS') IS NOT NULL
BEGIN
    ALTER TABLE `PLAN` DROP COLUMN DURACIONDIAS;
    SELECT 'Columna PLAN.DURACIONDIAS eliminada.';

IF COL_LENGTH('PLAN', 'PRECIO') IS NOT NULL
BEGIN
    ALTER TABLE `PLAN` DROP COLUMN PRECIO;
    SELECT 'Columna PLAN.PRECIO eliminada.';