/* ============================================================================
   Columna FOTO en USUARIO (imagen en Base64, sin prefijo data:image/...)
   Ejecutar después de scripts 22_06_2026 (esquema + usp_usuario_crud)
   Fecha: 06/07/2026
   ============================================================================ */

IF COL_LENGTH('USUARIO', 'FOTO') IS NULL
BEGIN
    ALTER TABLE USUARIO ADD FOTO NVARCHAR(MAX) NULL;
    PRINT 'Columna USUARIO.FOTO agregada.';
END
ELSE
    PRINT 'Columna USUARIO.FOTO ya existe.';
GO
