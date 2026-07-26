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
    DECLARE @IdGrm NVARCHAR(50);
    SELECT @IdGrm = 'GRM' + RIGHT('000' + CAST(
        ISNULL(MAX(TRY_CAST(REPLACE(IDGRUPOMODULO, 'GRM', '') AS INT)), 0) + 1 AS VARCHAR(3)
    ), 3)
    FROM GRUPO_MODULO WHERE IDGRUPOMODULO LIKE 'GRM%';

    INSERT INTO GRUPO_MODULO (IDGRUPOMODULO, IDTIPOUSUARIO, IDMODULO, IDTIPOPERMISO)
    VALUES (@IdGrm, '1', 'MOD009', 'TP001');

    PRINT 'GRUPO_MODULO: estudiantes (1) → MOD009 lectura (' + @IdGrm + ').';
END
ELSE
    PRINT 'Estudiantes ya tienen acceso de lectura a MOD009.';
GO

PRINT 'Menú estudiante exámenes listo.';
GO
