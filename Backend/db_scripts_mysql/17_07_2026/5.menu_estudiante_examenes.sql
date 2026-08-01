-- ============================================================================
-- Menú: estudiantes (tipo 1) → MOD009 lectura — MySQL 8
-- ============================================================================

USE `AcademiaDB`;

INSERT IGNORE INTO GRUPO_MODULO (IDGRUPOMODULO, IDTIPOUSUARIO, IDMODULO, IDTIPOPERMISO)
VALUES ('GRM900', '1', 'MOD009', 'TP001');

SELECT 'Menú estudiante exámenes listo.' AS info;
