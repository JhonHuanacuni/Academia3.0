-- ============================================================================
-- SUB029 Resultados (Académico) + SUB030 Asistencias por salón (Informes)
-- Fecha: 13/09/2026
-- ============================================================================

USE `AcademiaDB`;

INSERT INTO SUBMODULO (IDSUBMODULO, NOMBRE, DESCRIPCION, ICONO, ORDEN, ACTIVO, IDMODULO)
VALUES (
    'SUB029',
    'Resultados',
    'Resultados de exámenes rendidos: respuestas correctas e incorrectas',
    'faClipboardCheck',
    6,
    1,
    'MOD009'
)
ON DUPLICATE KEY UPDATE
    NOMBRE = 'Resultados',
    DESCRIPCION = 'Resultados de exámenes rendidos: respuestas correctas e incorrectas',
    ICONO = 'faClipboardCheck',
    ORDEN = 6,
    ACTIVO = 1,
    IDMODULO = 'MOD009';

INSERT INTO SUBMODULO (IDSUBMODULO, NOMBRE, DESCRIPCION, ICONO, ORDEN, ACTIVO, IDMODULO)
VALUES (
    'SUB030',
    'Por salón',
    'Informe de asistencias filtrado por salón, tutor, plan y estado',
    'faChalkboardUser',
    2,
    1,
    'MOD010'
)
ON DUPLICATE KEY UPDATE
    NOMBRE = 'Por salón',
    DESCRIPCION = 'Informe de asistencias filtrado por salón, tutor, plan y estado',
    ICONO = 'faChalkboardUser',
    ORDEN = 2,
    ACTIVO = 1,
    IDMODULO = 'MOD010';

-- Estudiantes: Resultados sí; Por salón no (solo staff)
INSERT IGNORE INTO GRUPO_SUBMODULO_EXCLUIDO (IDGRUPOEXCLSUB, IDTIPOUSUARIO, IDSUBMODULO, FECHAREGISTRO)
VALUES ('GEX_INF_SALON_EST', '1', 'SUB030', fn_fecha_ddmmyyyy());

-- Reordenar Mensajes si quedó en orden 7 (Resultados toma 6)
UPDATE SUBMODULO
SET ORDEN = 8
WHERE IDSUBMODULO = 'SUB028' AND IDMODULO = 'MOD009' AND ORDEN <= 7;

SELECT 'SUB029 Resultados + SUB030 Por salón listos.' AS info;
