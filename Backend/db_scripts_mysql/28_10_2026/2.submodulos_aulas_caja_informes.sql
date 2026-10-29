-- ============================================================================
-- Submódulos: Aulas / Caja / Seguimiento (Informes) + Informes (Académico)
-- Fecha: 28/10/2026
-- phpMyAdmin: selecciona tu BD y ejecuta (delimitador ;)
-- ============================================================================

-- Informes → Aulas (SUB032)
INSERT INTO SUBMODULO (IDSUBMODULO, NOMBRE, DESCRIPCION, ICONO, ORDEN, ACTIVO, IDMODULO)
VALUES (
    'SUB032',
    'Aulas',
    'Ocupación y cobranza por aula / salón',
    'faChalkboard',
    3,
    1,
    'MOD010'
)
ON DUPLICATE KEY UPDATE
    NOMBRE = 'Aulas',
    DESCRIPCION = 'Ocupación y cobranza por aula / salón',
    ICONO = 'faChalkboard',
    ORDEN = 3,
    ACTIVO = 1,
    IDMODULO = 'MOD010';

-- Informes → Caja (SUB033)
INSERT INTO SUBMODULO (IDSUBMODULO, NOMBRE, DESCRIPCION, ICONO, ORDEN, ACTIVO, IDMODULO)
VALUES (
    'SUB033',
    'Caja',
    'Ingresos del mes por medio de pago',
    'faCashRegister',
    4,
    1,
    'MOD010'
)
ON DUPLICATE KEY UPDATE
    NOMBRE = 'Caja',
    DESCRIPCION = 'Ingresos del mes por medio de pago',
    ICONO = 'faCashRegister',
    ORDEN = 4,
    ACTIVO = 1,
    IDMODULO = 'MOD010';

-- Académico → Informes / seguimiento de interesados (SUB034)
INSERT INTO SUBMODULO (IDSUBMODULO, NOMBRE, DESCRIPCION, ICONO, ORDEN, ACTIVO, IDMODULO)
VALUES (
    'SUB034',
    'Informes',
    'Registro de personas que solicitan información',
    'faClipboardList',
    10,
    1,
    'MOD009'
)
ON DUPLICATE KEY UPDATE
    NOMBRE = 'Informes',
    DESCRIPCION = 'Registro de personas que solicitan información',
    ICONO = 'faClipboardList',
    ORDEN = 10,
    ACTIVO = 1,
    IDMODULO = 'MOD009';

-- Informes → Seguimiento (SUB035)
INSERT INTO SUBMODULO (IDSUBMODULO, NOMBRE, DESCRIPCION, ICONO, ORDEN, ACTIVO, IDMODULO)
VALUES (
    'SUB035',
    'Seguimiento',
    'Conversión de interesados a matrículas',
    'faChartPie',
    5,
    1,
    'MOD010'
)
ON DUPLICATE KEY UPDATE
    NOMBRE = 'Seguimiento',
    DESCRIPCION = 'Conversión de interesados a matrículas',
    ICONO = 'faChartPie',
    ORDEN = 5,
    ACTIVO = 1,
    IDMODULO = 'MOD010';

-- Estudiantes no ven estos submódulos
INSERT IGNORE INTO GRUPO_SUBMODULO_EXCLUIDO (IDGRUPOEXCLSUB, IDTIPOUSUARIO, IDSUBMODULO, FECHAREGISTRO)
VALUES
    ('GEX_INF_AULAS', '1', 'SUB032', DATE_FORMAT(NOW(), '%d%m%Y')),
    ('GEX_INF_CAJA', '1', 'SUB033', DATE_FORMAT(NOW(), '%d%m%Y')),
    ('GEX_ACA_INFORMES', '1', 'SUB034', DATE_FORMAT(NOW(), '%d%m%Y')),
    ('GEX_INF_SEGUIM', '1', 'SUB035', DATE_FORMAT(NOW(), '%d%m%Y'));

SELECT '2. SUB032–SUB035 registrados.' AS info;
