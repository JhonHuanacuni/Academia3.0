-- Convertido automáticamente desde db_scripts/26_07_2026/9.menu_tutores_asesores.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   Menú: SUB012 = Tutores, SUB024 = Asesores (nombres distintos)
   Ejecutar después de 8.asesor_registro_mensualidad.sql
   Fecha: 26/07/2026
   ============================================================================ */

UPDATE SUBMODULO SET
    NOMBRE      = 'Tutores',
    DESCRIPCION = 'Registro y administración de tutores',
    ORDEN       = 2,
    ACTIVO      = 1,
    IDMODULO    = 'MOD011'
WHERE IDSUBMODULO = 'SUB012';

UPDATE SUBMODULO SET
    NOMBRE      = 'Asesores',
    DESCRIPCION = 'Personal que registra mensualidades',
    ORDEN       = 3,
    ACTIVO      = 1,
    IDMODULO    = 'MOD011'
WHERE IDSUBMODULO = 'SUB024';

SELECT 'Menú: SUB012 Tutores, SUB024 Asesores.';