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
GO

PRINT 'SUB026 renombrado a Importar notas.';
GO
