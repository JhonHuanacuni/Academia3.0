-- ============================================================================
-- Estudiantes: asegurar Clases grabadas visible (SUB017 bajo MOD009) — MySQL 8
-- Prerequisito: 17_07_2026/5.menu_estudiante_examenes.sql (MOD009 para tipo 1)
-- Fecha: 18/07/2026
-- ============================================================================

USE `AcademiaDB`;

DELETE FROM GRUPO_SUBMODULO_EXCLUIDO
WHERE IDTIPOUSUARIO = '1' AND IDSUBMODULO = 'SUB017';

SELECT 'Estudiantes: SUB017 Clases grabadas no excluido.' AS info;
