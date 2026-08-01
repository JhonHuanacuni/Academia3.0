-- Convertido automáticamente desde db_scripts/29_07_2026/2.sub_academico_importar_notas.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   Submódulo Académico: Importar notas
   Ejecutar después de 1.notas_importacion_tablas.sql
   Fecha: 29/07/2026
   ============================================================================ */

IF NOT EXISTS (SELECT 1 FROM SUBMODULO WHERE IDSUBMODULO = 'SUB026')
BEGIN
    INSERT INTO SUBMODULO (IDSUBMODULO, NOMBRE, DESCRIPCION, ICONO, ORDEN, ACTIVO, IDMODULO)
    VALUES ('SUB026', 'Importar notas', 'Importar calificaciones desde Excel Scantron', 'faFileImport', 5, 1, 'MOD009');

ELSE
BEGIN
    UPDATE SUBMODULO
    SET NOMBRE = 'Importar notas',
        DESCRIPCION = 'Importar calificaciones desde Excel Scantron',
        ICONO = 'faFileImport',
        ORDEN = 5,
        ACTIVO = 1,
        IDMODULO = 'MOD009'
    WHERE IDSUBMODULO = 'SUB026';

SELECT 'SUB026 Importar notas listo (visible para roles con acceso a MOD009 Académico).';
