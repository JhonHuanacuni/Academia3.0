/* ============================================================================
   Catálogo de aulas/salones Academia Vita (reemplazo completo)
   Fecha: 26/07/2026

   Nota: AUL001 se conserva por mensualidades, horarios y biblioteca existentes.
   ============================================================================ */

UPDATE MEMBRESIA SET IDAULA = 'AUL001' WHERE IDAULA IS NOT NULL;
GO

DELETE FROM AULA WHERE IDAULA <> 'AUL001';
GO

UPDATE AULA SET
    NOMBRE      = 'CICLO SEMIANUAL 1 - 2026',
    DESCRIPCION = 'Salón ciclo semi-anual 1 — 2026',
    CAPACIDAD   = 40,
    ACTIVO      = 1
WHERE IDAULA = 'AUL001';
GO

INSERT INTO AULA (IDAULA, NOMBRE, DESCRIPCION, CAPACIDAD, ACTIVO) VALUES
('AUL002', 'CICLO SABATINO - 2026',           'Salón ciclo sabatino — 2026',           40, 1),
('AUL003', 'CICLO SABATINO JR - 2026',        'Salón ciclo sabatino junior — 2026',    40, 1),
('AUL004', 'CICLO ESCOLAR DIARIO',            'Salón ciclo escolar diario',            40, 1),
('AUL005', 'CICLO BECA 18',                   'Salón ciclo Beca 18',                   20, 1),
('AUL006', 'DOCENTES',                        'Salón docentes',                        21, 1),
('AUL007', 'PERSONAL VITA-ESTACIÓN',          'Salón personal Vita-Estación',          30, 1),
('AUL008', 'CICLO ANUAL 1 - 2026',            'Salón ciclo anual 1 — 2026',            60, 1),
('AUL009', 'CICLO ANUAL 2 - 2026',            'Salón ciclo anual 2 — 2026',            50, 1),
('AUL010', 'CICLO ANUAL 3 - 2026',            'Salón ciclo anual 3 — 2026',            50, 1),
('AUL011', 'CICLO ANUAL 4 - 2026',            'Salón ciclo anual 4 — 2026',            50, 1),
('AUL012', 'CICLO ESCOLAR INTERDIARIO',       'Salón ciclo escolar interdiario',       40, 1);
GO

PRINT 'Catálogo de aulas Academia Vita actualizado (12 salones).';
GO
