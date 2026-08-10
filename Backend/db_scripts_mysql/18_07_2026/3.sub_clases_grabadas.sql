-- ============================================================================
-- Renombrar submódulo Clases → Clases grabadas — MySQL 8
-- Fecha: 18/07/2026
-- ============================================================================

USE `AcademiaDB`;

UPDATE SUBMODULO
SET NOMBRE = 'Clases grabadas',
    DESCRIPCION = 'Enlaces a clases grabadas por materia y salón',
    ICONO = 'faVideo'
WHERE IDSUBMODULO = 'SUB017';

SELECT 'Submódulo SUB017 actualizado a Clases grabadas.' AS info;
