-- Convertido automáticamente desde db_scripts/11_07_2026/3.remove_sub006_ver_membresias.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   Desactiva SUB006 (Ver membresías)
   El listado se abre desde el menú de membresías / + Nuevo (igual que Usuarios).
   Fecha: 12/07/2026
   ============================================================================ */

UPDATE SUBMODULO SET ACTIVO = 0 WHERE IDSUBMODULO = 'SUB006';

IF (SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'USUARIO_SUBMODULO_EXCLUIDO') > 0
BEGIN
    DELETE FROM USUARIO_SUBMODULO_EXCLUIDO WHERE IDSUBMODULO = 'SUB006';

/* El ítem restante del listado */
UPDATE SUBMODULO
SET ORDEN = 1,
    NOMBRE = 'Membresías',
    DESCRIPCION = 'Gestión de membresías'
WHERE IDSUBMODULO = 'SUB005';

SELECT 'SUB006 (Ver membresías) desactivado. Queda MembresíCONCAT(as, Pagos.)';