/* ============================================================================
   Submódulo Académico: Auditoría del sistema
   Ejecutar después de 3.usp_auditoria_crud.sql
   Fecha: 31/07/2026
   Nota: NCHAR evita corrupción de tildes al ejecutar con sqlcmd en Windows.
   ============================================================================ */

DECLARE @NombreAuditoria NVARCHAR(100) = N'Auditor' + NCHAR(237) + N'a';
DECLARE @DescAuditoria NVARCHAR(255) = N'Historial de altas, modificaciones y eliminaciones en el sistema';

IF NOT EXISTS (SELECT 1 FROM SUBMODULO WHERE IDSUBMODULO = 'SUB027')
BEGIN
    INSERT INTO SUBMODULO (IDSUBMODULO, NOMBRE, DESCRIPCION, ICONO, ORDEN, ACTIVO, IDMODULO)
    VALUES ('SUB027', @NombreAuditoria, @DescAuditoria, 'faClipboardList', 6, 1, 'MOD009');
END
ELSE
BEGIN
    UPDATE SUBMODULO
    SET NOMBRE = @NombreAuditoria,
        DESCRIPCION = @DescAuditoria,
        ICONO = 'faClipboardList',
        ORDEN = 6,
        ACTIVO = 1,
        IDMODULO = 'MOD009'
    WHERE IDSUBMODULO = 'SUB027';
END
GO

PRINT 'SUB027 Auditoria listo (visible para roles con acceso a MOD009 Academico).';
GO
