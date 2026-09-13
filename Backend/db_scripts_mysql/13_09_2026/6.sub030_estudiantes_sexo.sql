-- ============================================================================
-- 6. Renombrar SUB030 a Estudiantes + columna SEXO (para indicadores)
-- Fecha: 13/09/2026
-- phpMyAdmin: selecciona tu BD y ejecuta (delimitador ;)
-- ============================================================================

UPDATE SUBMODULO
SET NOMBRE = 'Estudiantes',
    DESCRIPCION = 'Listado de estudiantes por salon, tutor, plan y estado',
    ICONO = 'faUsers'
WHERE IDSUBMODULO = 'SUB030';

SET @col_sexo := (
    SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'USUARIO' AND COLUMN_NAME = 'SEXO'
);
SET @sql_sexo := IF(
    @col_sexo = 0,
    'ALTER TABLE USUARIO ADD SEXO VARCHAR(20) NULL',
    'SELECT 1'
);
PREPARE stmt FROM @sql_sexo;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SELECT '6. SUB030=Estudiantes + USUARIO.SEXO listo.' AS info;
