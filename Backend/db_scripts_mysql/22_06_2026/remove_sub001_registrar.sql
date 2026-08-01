-- Convertido automáticamente desde db_scripts/22_06_2026/remove_sub001_registrar.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* Desactiva SUB001 (Registrar usuario) — el alta se hace desde Listado (+ Nuevo) */
UPDATE SUBMODULO SET ACTIVO = 0 WHERE IDSUBMODULO = 'SUB001';

IF OBJECT_ID('USUARIO_SUBMODULO_EXCLUIDO', 'U') IS NOT NULL
BEGIN
    DELETE FROM USUARIO_SUBMODULO_EXCLUIDO WHERE IDSUBMODULO = 'SUB001';

UPDATE SUBMODULO SET ORDEN = 1, NOMBRE = 'Listado de usuarios'
WHERE IDSUBMODULO = 'SUB002';

SELECT 'SUB001 desactivado. Usuarios queda solo con Listado.';
