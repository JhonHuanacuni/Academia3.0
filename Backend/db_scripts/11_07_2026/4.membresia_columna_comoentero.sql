/* ============================================================================
   Columna COMOENTERO en MEMBRESIA (cómo se enteró del servicio)
   Fecha: 12/07/2026
   ============================================================================ */

IF COL_LENGTH('MEMBRESIA', 'COMOENTERO') IS NULL
BEGIN
    ALTER TABLE MEMBRESIA ADD COMOENTERO NVARCHAR(100) NULL;
    PRINT 'Columna MEMBRESIA.COMOENTERO agregada.';
END
ELSE
    PRINT 'Columna MEMBRESIA.COMOENTERO ya existe.';
GO
