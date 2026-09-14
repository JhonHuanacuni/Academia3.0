-- ============================================================================
-- 6. Renombrar SUB030 a Estudiantes
-- Fecha: 13/09/2026
-- phpMyAdmin: selecciona tu BD y ejecuta (delimitador ;)
-- ============================================================================

UPDATE SUBMODULO
SET NOMBRE = 'Estudiantes',
    DESCRIPCION = 'Listado de estudiantes por salon, tutor, plan y estado',
    ICONO = 'faUsers'
WHERE IDSUBMODULO = 'SUB030';

SELECT '6. SUB030 renombrado a Estudiantes.' AS info;
