-- Convertido automáticamente desde db_scripts/29_07_2026/3.notas_modulo_academico.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   Importar notas: desactivar MOD007, SUB026 bajo Académico
   Ejecutar después de 2.sub_academico_importar_notas.sql
   Fecha: 29/07/2026
   ============================================================================ */

-- Desactivar módulo Notas independiente y sus submódulos
UPDATE MODULO SET ACTIVO = 0 WHERE IDMODULO = 'MOD007';
UPDATE SUBMODULO SET ACTIVO = 0 WHERE IDMODULO = 'MOD007';

-- SUB026: Importar notas bajo Académico (listado + importación Excel)
UPDATE SUBMODULO
SET NOMBRE = 'Importar notas',
    DESCRIPCION = 'Importar calificaciones desde Excel Scantron',
    ICONO = 'faFileImport',
    ORDEN = 5,
    ACTIVO = 1,
    IDMODULO = 'MOD009'
WHERE IDSUBMODULO = 'SUB026';

IF NOT EXISTS (SELECT 1 FROM SUBMODULO WHERE IDSUBMODULO = 'SUB026')
BEGIN
    INSERT INTO SUBMODULO (IDSUBMODULO, NOMBRE, DESCRIPCION, ICONO, ORDEN, ACTIVO, IDMODULO)
    VALUES ('SUB026', 'Importar notas', 'Importar calificaciones desde Excel Scantron', 'faFileImport', 5, 1, 'MOD009');

SELECT 'MOD007 desactivado; SUB026 Importar notas activo bajo MOD009 Académico.';
