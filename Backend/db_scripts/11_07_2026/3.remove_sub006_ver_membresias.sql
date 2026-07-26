/* ============================================================================
   Desactiva SUB006 (Ver membresías)
   El listado se abre desde el menú de membresías / + Nuevo (igual que Usuarios).
   Fecha: 12/07/2026
   ============================================================================ */

UPDATE SUBMODULO SET ACTIVO = 0 WHERE IDSUBMODULO = 'SUB006';
GO

IF OBJECT_ID('dbo.USUARIO_SUBMODULO_EXCLUIDO', 'U') IS NOT NULL
BEGIN
    DELETE FROM USUARIO_SUBMODULO_EXCLUIDO WHERE IDSUBMODULO = 'SUB006';
END
GO

/* El ítem restante del listado */
UPDATE SUBMODULO
SET ORDEN = 1,
    NOMBRE = 'Membresías',
    DESCRIPCION = 'Gestión de membresías'
WHERE IDSUBMODULO = 'SUB005';
GO

PRINT 'SUB006 (Ver membresías) desactivado. Queda Membresías + Pagos.';
GO
