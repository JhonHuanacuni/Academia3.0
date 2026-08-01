-- Convertido automáticamente desde db_scripts/29_07_2026/4.fix_sub026_importar_notas.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   Corregir nombre SUB026 → "Importar notas" (si ya se ejecutó script 3 con "Notas")
   Fecha: 29/07/2026
   ============================================================================ */

UPDATE SUBMODULO
SET NOMBRE = 'Importar notas',
    DESCRIPCION = 'Importar calificaciones desde Excel Scantron',
    ICONO = 'faFileImport',
    ACTIVO = 1,
    IDMODULO = 'MOD009'
WHERE IDSUBMODULO = 'SUB026';

SELECT 'SUB026 renombrado a Importar notas.';
