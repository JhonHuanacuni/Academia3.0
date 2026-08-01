-- ============================================================================
-- Desactiva SUB006 (Ver membresías) — MySQL 8
-- El listado se abre desde el menú de membresías / + Nuevo (igual que Usuarios).
-- ============================================================================

USE `AcademiaDB`;

UPDATE SUBMODULO SET ACTIVO = 0 WHERE IDSUBMODULO = 'SUB006';

DELETE FROM USUARIO_SUBMODULO_EXCLUIDO WHERE IDSUBMODULO = 'SUB006';

UPDATE SUBMODULO
SET ORDEN = 1,
    NOMBRE = 'Membresías',
    DESCRIPCION = 'Gestión de membresías'
WHERE IDSUBMODULO = 'SUB005';

SELECT 'SUB006 (Ver membresías) desactivado. Queda Membresías + Pagos.' AS info;
