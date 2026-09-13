-- ============================================================================
-- 1. Submodulos: Resultados (SUB029) + Por salon (SUB030)
-- Fecha: 13/09/2026
-- phpMyAdmin: selecciona tu BD y ejecuta (delimitador ;)
-- ============================================================================

INSERT INTO SUBMODULO (IDSUBMODULO, NOMBRE, DESCRIPCION, ICONO, ORDEN, ACTIVO, IDMODULO)
VALUES ('SUB029', 'Resultados', 'Resultados de examenes rendidos', 'faClipboardCheck', 6, 1, 'MOD009')
ON DUPLICATE KEY UPDATE
    NOMBRE = 'Resultados',
    DESCRIPCION = 'Resultados de examenes rendidos',
    ICONO = 'faClipboardCheck',
    ORDEN = 6,
    ACTIVO = 1,
    IDMODULO = 'MOD009';

INSERT INTO SUBMODULO (IDSUBMODULO, NOMBRE, DESCRIPCION, ICONO, ORDEN, ACTIVO, IDMODULO)
VALUES ('SUB030', 'Por salon', 'Asistencias filtradas por salon, tutor, plan y estado', 'faChalkboard', 2, 1, 'MOD010')
ON DUPLICATE KEY UPDATE
    NOMBRE = 'Por salon',
    DESCRIPCION = 'Asistencias filtradas por salon, tutor, plan y estado',
    ICONO = 'faChalkboard',
    ORDEN = 2,
    ACTIVO = 1,
    IDMODULO = 'MOD010';

UPDATE SUBMODULO
SET ORDEN = 8
WHERE IDSUBMODULO = 'SUB028' AND IDMODULO = 'MOD009';

INSERT IGNORE INTO GRUPO_SUBMODULO_EXCLUIDO (IDGRUPOEXCLSUB, IDTIPOUSUARIO, IDSUBMODULO, FECHAREGISTRO)
VALUES ('GEX_INF_SALON_EST', '1', 'SUB030', DATE_FORMAT(NOW(), '%d%m%Y'));

SELECT '1. SUB029 + SUB030 listos.' AS info;
