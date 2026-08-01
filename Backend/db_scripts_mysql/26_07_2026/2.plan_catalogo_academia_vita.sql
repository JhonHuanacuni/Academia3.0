-- Convertido automáticamente desde db_scripts/26_07_2026/2.plan_catalogo_academia_vita.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   Catálogo de planes Academia Vita (reemplazo completo)
   Ejecutar después de 26_07_2026/1.plan_dias_asistencia.sql
   Fecha: 26/07/2026

   DIASASISTENCIA bitmask: lun=1 mar=2 mié=4 jue=8 vie=16 sáb=32 dom=64
   - Mañana/Tarde/Virtual/Semi/Semestral/Beca mañana: lun–sáb (63)
   - Interdiario: lun/mié/vie (21)
   - Sabatino: sáb (32)

   Nota: PLN001 se conserva por mensualidades existentes; se renombra in-place.
   ============================================================================ */

UPDATE MEMBRESIA SET IDPLAN = 'PLN001' WHERE IDPLAN IS NOT NULL;

DELETE FROM [PLAN] WHERE IDPLAN <> 'PLN001';

UPDATE [PLAN] SET
    NOMBRE         = 'Plan Anual 1 (Mañana)',
    DESCRIPCION    = 'Plan anual — turno mañana',
    COSTOMENSUAL   = NULL,
    DIASASISTENCIA = 63,
    ACTIVO         = 1
WHERE IDPLAN = 'PLN001';

INSERT INTO [PLAN] (IDPLAN, NOMBRE, DESCRIPCION, COSTOMENSUAL, DIASASISTENCIA, ACTIVO) VALUES
('PLN002', 'Plan Anual 2 (Tarde)',                 'Plan anual — turno tarde',               NULL, 63, 1),
('PLN003', 'Plan Anual 3 (Mañana)',                'Plan anual — turno mañana',              NULL, 63, 1),
('PLN004', 'Plan Anual Virtual (Mañana)',          'Plan anual virtual — turno mañana',      NULL, 63, 1),
('PLN005', 'Plan Escolar 1 (Interdiario Mañana)',  'Plan escolar interdiario — mañana',      NULL, 21, 1),
('PLN006', 'Plan Escolar 2 (Interdiario Tarde)',   'Plan escolar interdiario — tarde',       NULL, 21, 1),
('PLN007', 'Plan Sabatino 1 (Mañana)',             'Plan sabatino — mañana',                  NULL, 32, 1),
('PLN008', 'Plan Beca 18 (Mañana)',                'Plan Beca 18 — turno mañana',             NULL, 63, 1),
('PLN009', 'Plan Semi-Anual (Mañana)',             'Plan semi-anual — turno mañana',          NULL, 63, 1),
('PLN010', 'Plan Semestral (Mañana)',              'Plan semestral — turno mañana',           NULL, 63, 1),
('PLN011', 'Plan Beca 18 - Sabatino (Mañana)',     'Plan Beca 18 sabatino — mañana',          NULL, 32, 1);

SELECT 'Catálogo de planes Academia Vita actualizado (11 planes).';
