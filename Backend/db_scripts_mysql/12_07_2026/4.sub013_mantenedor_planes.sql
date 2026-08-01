-- Convertido automáticamente desde db_scripts/12_07_2026/4.sub013_mantenedor_planes.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   Submódulo Mantenedor de planes bajo Académico (MOD009)
   Ejecutar después de 3.usp_plan_crud.sql
   Fecha: 12/07/2026
   ============================================================================ */

IF NOT EXISTS (SELECT 1 FROM SUBMODULO WHERE IDSUBMODULO = 'SUB013')
BEGIN
    INSERT INTO SUBMODULO (IDSUBMODULO, NOMBRE, DESCRIPCION, ICONO, ORDEN, ACTIVO, IDMODULO)
    VALUES (
        'SUB013',
        'Mantenedor de planes',
        'Registrar y administrar tipos de plan',
        'faClipboardList',
        3,
        1,
        'MOD009'
    );
    SELECT 'SUB013 (Mantenedor de planes) creado.';

ELSE
BEGIN
    UPDATE SUBMODULO SET
        NOMBRE = 'Mantenedor de planes',
        DESCRIPCION = 'Registrar y administrar tipos de plan',
        ICONO = 'faClipboardList',
        ORDEN = 3,
        ACTIVO = 1,
        IDMODULO = 'MOD009'
    WHERE IDSUBMODULO = 'SUB013';
    SELECT 'SUB013 (Mantenedor de planes) actualizado.';