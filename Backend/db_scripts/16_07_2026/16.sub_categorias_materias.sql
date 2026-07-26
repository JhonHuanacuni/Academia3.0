/* ============================================================================
   Submódulos: Categorías y Materias (MOD011 Mantenedores)
   Usa SUB022 / SUB023 (SUB020/SUB021 pueden estar reservados en ejemplos)
   Fecha: 16/07/2026
   Nota: asigna permisos desde Admin de módulos si no aparecen en el menú.
   ============================================================================ */

-- Si se crearon antes con SUB020/SUB021 bajo Mantenedores, se migran a SUB022/SUB023
IF EXISTS (
    SELECT 1 FROM SUBMODULO
    WHERE IDSUBMODULO = 'SUB020' AND IDMODULO = 'MOD011' AND NOMBRE LIKE N'Categor%'
)
   AND NOT EXISTS (SELECT 1 FROM SUBMODULO WHERE IDSUBMODULO = 'SUB022')
BEGIN
    UPDATE SUBMODULO SET IDSUBMODULO = 'SUB022' WHERE IDSUBMODULO = 'SUB020';
    IF OBJECT_ID('dbo.USUARIO_SUBMODULO_EXCLUIDO', 'U') IS NOT NULL
        UPDATE USUARIO_SUBMODULO_EXCLUIDO SET IDSUBMODULO = 'SUB022' WHERE IDSUBMODULO = 'SUB020';
    PRINT 'SUB020 migrado a SUB022.';
END
GO

IF EXISTS (
    SELECT 1 FROM SUBMODULO
    WHERE IDSUBMODULO = 'SUB021' AND IDMODULO = 'MOD011' AND NOMBRE = N'Materias'
)
   AND NOT EXISTS (SELECT 1 FROM SUBMODULO WHERE IDSUBMODULO = 'SUB023')
BEGIN
    UPDATE SUBMODULO SET IDSUBMODULO = 'SUB023' WHERE IDSUBMODULO = 'SUB021';
    IF OBJECT_ID('dbo.USUARIO_SUBMODULO_EXCLUIDO', 'U') IS NOT NULL
        UPDATE USUARIO_SUBMODULO_EXCLUIDO SET IDSUBMODULO = 'SUB023' WHERE IDSUBMODULO = 'SUB021';
    PRINT 'SUB021 migrado a SUB023.';
END
GO

IF NOT EXISTS (SELECT 1 FROM SUBMODULO WHERE IDSUBMODULO = 'SUB022')
BEGIN
    INSERT INTO SUBMODULO (IDSUBMODULO, NOMBRE, DESCRIPCION, ICONO, ORDEN, ACTIVO, IDMODULO)
    VALUES (
        'SUB022',
        N'Categorías',
        N'Categorías de materias para exámenes (Habilidades, Matemática, etc.)',
        'faLayerGroup',
        5,
        1,
        'MOD011'
    );
    PRINT 'SUB022 (Categorías) creado.';
END
ELSE
BEGIN
    UPDATE SUBMODULO SET
        NOMBRE = N'Categorías',
        DESCRIPCION = N'Categorías de materias para exámenes (Habilidades, Matemática, etc.)',
        ICONO = 'faLayerGroup',
        ORDEN = 5,
        ACTIVO = 1,
        IDMODULO = 'MOD011'
    WHERE IDSUBMODULO = 'SUB022';
    PRINT 'SUB022 (Categorías) actualizado.';
END
GO

IF NOT EXISTS (SELECT 1 FROM SUBMODULO WHERE IDSUBMODULO = 'SUB023')
BEGIN
    INSERT INTO SUBMODULO (IDSUBMODULO, NOMBRE, DESCRIPCION, ICONO, ORDEN, ACTIVO, IDMODULO)
    VALUES (
        'SUB023',
        N'Materias',
        N'Materias / cursos vinculados a categoría',
        'faBookOpen',
        6,
        1,
        'MOD011'
    );
    PRINT 'SUB023 (Materias) creado.';
END
ELSE
BEGIN
    UPDATE SUBMODULO SET
        NOMBRE = N'Materias',
        DESCRIPCION = N'Materias / cursos vinculados a categoría',
        ICONO = 'faBookOpen',
        ORDEN = 6,
        ACTIVO = 1,
        IDMODULO = 'MOD011'
    WHERE IDSUBMODULO = 'SUB023';
    PRINT 'SUB023 (Materias) actualizado.';
END
GO

PRINT 'Submódulos SUB022 y SUB023 listos.';
GO
