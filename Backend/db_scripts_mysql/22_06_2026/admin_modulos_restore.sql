-- Convertido automáticamente desde db_scripts/22_06_2026/admin_modulos_restore.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   RESTAURAR MÓDULOS BASE DEL ADMINISTRADOR
   Ejecutar si un admin quedó sin sidebar (sin Dashboard ni Administración Módulos)
   Fecha: 22/06/2026
   ============================================================================ */

-- 1) Asegurar permisos de rol para administrador (tipo 3)
IF NOT EXISTS (SELECT 1 FROM GRUPO_MODULO WHERE IDTIPOUSUARIO = '3' AND IDMODULO = 'MOD001')
BEGIN
    INSERT INTO GRUPO_MODULO (IDGRUPOMODULO, IDTIPOUSUARIO, IDMODULO, IDTIPOPERMISO) VALUES
    ('GRM901', '3', 'MOD001', 'TP001'), ('GRM902', '3', 'MOD001', 'TP002'),
    ('GRM903', '3', 'MOD001', 'TP003'), ('GRM904', '3', 'MOD001', 'TP004');

IF NOT EXISTS (SELECT 1 FROM GRUPO_MODULO WHERE IDTIPOUSUARIO = '3' AND IDMODULO = 'MOD008')
BEGIN
    INSERT INTO GRUPO_MODULO (IDGRUPOMODULO, IDTIPOUSUARIO, IDMODULO, IDTIPOPERMISO) VALUES
    ('GRM905', '3', 'MOD008', 'TP001'), ('GRM906', '3', 'MOD008', 'TP002'),
    ('GRM907', '3', 'MOD008', 'TP003'), ('GRM908', '3', 'MOD008', 'TP004');

-- 2) Quitar exclusiones de módulos protegidos para todos los administradores
DELETE ex
FROM USUARIO_MODULO_EXCLUIDO ex
INNER JOIN USUARIO u ON u.IDUSUARIO = ex.IDUSUARIO
WHERE u.IDTIPOUSUARIO = '3'
  AND ex.IDMODULO IN ('MOD001', 'MOD008');

SELECT 'Administradores restaurados: MOD001 (Dashboard) y MOD008 (Administración Módulos)';
