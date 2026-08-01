-- Convertido automáticamente desde db_scripts/17_07_2026/5.menu_estudiante_examenes.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   Menú: asignar Académico (MOD009) lectura a estudiantes (tipo 1)
   para que vean Académico → Exámenes (SUB015)
   Fecha: 17/07/2026
   ============================================================================ */

IF NOT EXISTS (
    SELECT 1 FROM GRUPO_MODULO
    WHERE IDTIPOUSUARIO = '1' AND IDMODULO = 'MOD009' AND IDTIPOPERMISO = 'TP001'
)
BEGIN
    DECLARE @IdGrm VARCHAR(50);
    SELECT @IdGrm = CONCAT('GRM', RIGHT('000' + CAST(
        IFNULL(MAX(CAST(REPLACE(IDGRUPOMODULO, 'GRM', '') AS INT)), 0) + 1 AS VARCHAR(3)
    ), 3)
    FROM GRUPO_MODULO WHERE IDGRUPOMODULO LIKE 'GRM%';

    INSERT INTO GRUPO_MODULO (IDGRUPOMODULO, IDTIPOUSUARIO, IDMODULO, IDTIPOPERMISO)
    VALUES (@IdGrm, '1', 'MOD009', 'TP001');

    SELECT CONCAT('GRUPO_MODULO: estudiantes (1) → MOD009 lectura (', @IdGrm) + ').';

SELECT 'Menú estudiante exámenes listo.';
