-- Convertido automáticamente desde db_scripts/12_07_2026/2.sub012_mantenedor_asesores.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   Submódulo Mantenedor de asesores bajo Académico (MOD009)
   Ejecutar después de 1.usp_asesor_crud.sql
   Fecha: 12/07/2026
   ============================================================================ */

IF NOT EXISTS (SELECT 1 FROM SUBMODULO WHERE IDSUBMODULO = 'SUB012')
BEGIN
    INSERT INTO SUBMODULO (IDSUBMODULO, NOMBRE, DESCRIPCION, ICONO, ORDEN, ACTIVO, IDMODULO)
    VALUES (
        'SUB012',
        'Mantenedor de asesores',
        'Registrar y administrar asesores',
        'faIdCard',
        2,
        1,
        'MOD009'
    );
    SELECT 'SUB012 (Mantenedor de asesores) creado.';

ELSE
BEGIN
    UPDATE SUBMODULO SET
        NOMBRE = 'Mantenedor de asesores',
        DESCRIPCION = 'Registrar y administrar asesores',
        ICONO = 'faIdCard',
        ORDEN = 2,
        ACTIVO = 1,
        IDMODULO = 'MOD009'
    WHERE IDSUBMODULO = 'SUB012';
    SELECT 'SUB012 (Mantenedor de asesores) actualizado.';
