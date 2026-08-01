-- Convertido automáticamente desde db_scripts/16_07_2026/16.sub_categorias_materias.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   Submódulos: Categorías y Materias (MOD011 Mantenedores)
   Usa SUB022 / SUB023 (SUB020/SUB021 pueden estar reservados en ejemplos)
   Fecha: 16/07/2026
   Nota: asigna permisos desde Admin de módulos si no aparecen en el menú.
   ============================================================================ */

-- Si se crearon antes con SUB020/SUB021 bajo Mantenedores, se migran a SUB022/SUB023
IF EXISTS (
    SELECT 1 FROM SUBMODULO
    WHERE IDSUBMODULO = 'SUB020' AND IDMODULO = 'MOD011' AND NOMBRE LIKE 'Categor%'
)
   AND NOT EXISTS (SELECT 1 FROM SUBMODULO WHERE IDSUBMODULO = 'SUB022')
BEGIN
    UPDATE SUBMODULO SET IDSUBMODULO = 'SUB022' WHERE IDSUBMODULO = 'SUB020';
    IF (SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'USUARIO_SUBMODULO_EXCLUIDO') > 0
        UPDATE USUARIO_SUBMODULO_EXCLUIDO SET IDSUBMODULO = 'SUB022' WHERE IDSUBMODULO = 'SUB020';
    SELECT 'SUB020 migrado a SUB022.';

IF EXISTS (
    SELECT 1 FROM SUBMODULO
    WHERE IDSUBMODULO = 'SUB021' AND IDMODULO = 'MOD011' AND NOMBRE = 'Materias'
)
   AND NOT EXISTS (SELECT 1 FROM SUBMODULO WHERE IDSUBMODULO = 'SUB023')
BEGIN
    UPDATE SUBMODULO SET IDSUBMODULO = 'SUB023' WHERE IDSUBMODULO = 'SUB021';
    IF (SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'USUARIO_SUBMODULO_EXCLUIDO') > 0
        UPDATE USUARIO_SUBMODULO_EXCLUIDO SET IDSUBMODULO = 'SUB023' WHERE IDSUBMODULO = 'SUB021';
    SELECT 'SUB021 migrado a SUB023.';

IF NOT EXISTS (SELECT 1 FROM SUBMODULO WHERE IDSUBMODULO = 'SUB022')
BEGIN
    INSERT INTO SUBMODULO (IDSUBMODULO, NOMBRE, DESCRIPCION, ICONO, ORDEN, ACTIVO, IDMODULO)
    VALUES (
        'SUB022',
        'Categorías',
        'Categorías de materias para exámenes (Habilidades, Matemática, etc.)',
        'faLayerGroup',
        5,
        1,
        'MOD011'
    );
    SELECT 'SUB022 (Categorías) creado.';

ELSE
BEGIN
    UPDATE SUBMODULO SET
        NOMBRE = 'Categorías',
        DESCRIPCION = 'Categorías de materias para exámenes (Habilidades, Matemática, etc.)',
        ICONO = 'faLayerGroup',
        ORDEN = 5,
        ACTIVO = 1,
        IDMODULO = 'MOD011'
    WHERE IDSUBMODULO = 'SUB022';
    SELECT 'SUB022 (Categorías) actualizado.';

IF NOT EXISTS (SELECT 1 FROM SUBMODULO WHERE IDSUBMODULO = 'SUB023')
BEGIN
    INSERT INTO SUBMODULO (IDSUBMODULO, NOMBRE, DESCRIPCION, ICONO, ORDEN, ACTIVO, IDMODULO)
    VALUES (
        'SUB023',
        'Materias',
        'Materias / cursos vinculados a categoría',
        'faBookOpen',
        6,
        1,
        'MOD011'
    );
    SELECT 'SUB023 (Materias) creado.';

ELSE
BEGIN
    UPDATE SUBMODULO SET
        NOMBRE = 'Materias',
        DESCRIPCION = 'Materias / cursos vinculados a categoría',
        ICONO = 'faBookOpen',
        ORDEN = 6,
        ACTIVO = 1,
        IDMODULO = 'MOD011'
    WHERE IDSUBMODULO = 'SUB023';
    SELECT 'SUB023 (Materias) actualizado.';

SELECT 'Submódulos SUB022 y SUB023 listos.';