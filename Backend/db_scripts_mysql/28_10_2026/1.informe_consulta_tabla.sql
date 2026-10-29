-- ============================================================================
-- INFORME_CONSULTA — seguimiento de personas que piden información
-- Fecha: 28/10/2026
-- phpMyAdmin: selecciona tu BD y ejecuta (delimitador ;)
-- ============================================================================

CREATE TABLE IF NOT EXISTS INFORME_CONSULTA (
    IDINFORMECONSULTA   VARCHAR(50)  NOT NULL PRIMARY KEY,
    FECHA               CHAR(8)      NOT NULL,
    NOMBRE              VARCHAR(200) NOT NULL,
    TELEFONO            VARCHAR(30)  NULL,
    CICLO_INTERES       VARCHAR(120) NULL,
    CANAL               VARCHAR(30)  NOT NULL DEFAULT 'presencial',
    RESULTADO           VARCHAR(30)  NOT NULL DEFAULT 'interesado',
    SE_ENTERO           VARCHAR(200) NULL,
    OBSERVACION         VARCHAR(500) NULL,
    MARCA_NO_APLICA     TINYINT      NOT NULL DEFAULT 0,
    MARCA_INTERESADO    TINYINT      NOT NULL DEFAULT 1,
    ESTADO              VARCHAR(50)  NOT NULL DEFAULT 'Activo',
    CREADO_POR          VARCHAR(50)  NULL,
    FECHACREACION       CHAR(8)      NULL,
    HORACREACION        CHAR(8)      NULL,
    MODIFICADO_POR      VARCHAR(50)  NULL,
    FECHAMODIFICACION   CHAR(8)      NULL,
    HORAMODIFICACION    CHAR(8)      NULL
);

-- Índices (ignorar error si ya existen al re-ejecutar)
SET @sql := (
  SELECT IF(
    EXISTS(SELECT 1 FROM information_schema.statistics
           WHERE table_schema = DATABASE() AND table_name = 'INFORME_CONSULTA' AND index_name = 'IX_INFORME_CONSULTA_FECHA'),
    'SELECT 1',
    'CREATE INDEX IX_INFORME_CONSULTA_FECHA ON INFORME_CONSULTA(FECHA)'
  )
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := (
  SELECT IF(
    EXISTS(SELECT 1 FROM information_schema.statistics
           WHERE table_schema = DATABASE() AND table_name = 'INFORME_CONSULTA' AND index_name = 'IX_INFORME_CONSULTA_RESULTADO'),
    'SELECT 1',
    'CREATE INDEX IX_INFORME_CONSULTA_RESULTADO ON INFORME_CONSULTA(RESULTADO)'
  )
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := (
  SELECT IF(
    EXISTS(SELECT 1 FROM information_schema.statistics
           WHERE table_schema = DATABASE() AND table_name = 'INFORME_CONSULTA' AND index_name = 'IX_INFORME_CONSULTA_ESTADO'),
    'SELECT 1',
    'CREATE INDEX IX_INFORME_CONSULTA_ESTADO ON INFORME_CONSULTA(ESTADO)'
  )
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := (
  SELECT IF(
    EXISTS(SELECT 1 FROM information_schema.statistics
           WHERE table_schema = DATABASE() AND table_name = 'INFORME_CONSULTA' AND index_name = 'IX_INFORME_CONSULTA_TELEFONO'),
    'SELECT 1',
    'CREATE INDEX IX_INFORME_CONSULTA_TELEFONO ON INFORME_CONSULTA(TELEFONO)'
  )
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SELECT '1. Tabla INFORME_CONSULTA lista.' AS info;
