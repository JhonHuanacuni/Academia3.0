-- Convertido automáticamente desde db_scripts/26_07_2026/5.menu_mensualidad_tutor.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   Etiquetas del menú: Mensualidades / Tutores (UI)
   Ejecutar después de 4.rename_membresia_asesor_a_mensualidad_tutor.sql
   Fecha: 26/07/2026
   ============================================================================ */

UPDATE SUBMODULO SET NOMBRE = 'Mensualidades', DESCRIPCION = 'Gestión de mensualidades y cobros'
WHERE IDSUBMODULO = 'SUB005';

UPDATE SUBMODULO SET NOMBRE = 'Tutores', DESCRIPCION = 'Registro y administración de tutores'
WHERE IDSUBMODULO = 'SUB012';

UPDATE MODULO SET NOMBRE = 'Mensualidades', DESCRIPCION = 'Gestión de mensualidades, pagos y cobros'
WHERE IDMODULO = 'MOD004';

SELECT 'Menú actualizado: Mensualidades / Tutores.';
