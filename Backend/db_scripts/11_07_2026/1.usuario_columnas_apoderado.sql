/* ============================================================================
   Columnas de apoderado en USUARIO
   NOMBREAPODERADO, PARENTESCO (TELAPODERADO ya existe)
   Fecha: 11/07/2026
   ============================================================================ */

IF COL_LENGTH('USUARIO', 'NOMBREAPODERADO') IS NULL
BEGIN
    ALTER TABLE USUARIO ADD NOMBREAPODERADO NVARCHAR(200) NULL;
    PRINT 'Columna USUARIO.NOMBREAPODERADO agregada.';
END
ELSE
    PRINT 'Columna USUARIO.NOMBREAPODERADO ya existe.';
GO

IF COL_LENGTH('USUARIO', 'PARENTESCO') IS NULL
BEGIN
    ALTER TABLE USUARIO ADD PARENTESCO NVARCHAR(50) NULL;
    PRINT 'Columna USUARIO.PARENTESCO agregada.';
END
ELSE
    PRINT 'Columna USUARIO.PARENTESCO ya existe.';
GO
