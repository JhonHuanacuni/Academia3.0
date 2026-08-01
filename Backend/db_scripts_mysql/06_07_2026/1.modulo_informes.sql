-- ============================================================================
-- Módulo Informes (MOD010) + submódulo Asistencias (SUB011) — MySQL 8
-- ============================================================================

USE `AcademiaDB`;

SET @col_exists := (
    SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'AULA' AND COLUMN_NAME = 'IDTUTORA'
);
SET @sql := IF(@col_exists = 0,
    'ALTER TABLE AULA ADD COLUMN IDTUTORA VARCHAR(50) NULL, ADD CONSTRAINT FK_AULA_TUTORA FOREIGN KEY (IDTUTORA) REFERENCES USUARIO(IDUSUARIO)',
    'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

INSERT INTO MODULO (IDMODULO, NOMBRE, DESCRIPCION, ICONO, ORDEN, ACTIVO, FECHACREACION)
VALUES ('MOD010', 'Informes', 'Reportes y estadísticas del instituto', 'faChartColumn', 9, 1, fn_fecha_ddmmyyyy())
ON DUPLICATE KEY UPDATE
    NOMBRE = 'Informes',
    DESCRIPCION = 'Reportes y estadísticas del instituto',
    ICONO = 'faChartColumn',
    ORDEN = 9,
    ACTIVO = 1;

INSERT INTO SUBMODULO (IDSUBMODULO, NOMBRE, DESCRIPCION, ICONO, ORDEN, ACTIVO, IDMODULO)
VALUES ('SUB011', 'Asistencias', 'Informe de asistencias por rango de fechas', 'faCalendarDays', 1, 1, 'MOD010')
ON DUPLICATE KEY UPDATE
    NOMBRE = 'Asistencias',
    DESCRIPCION = 'Informe de asistencias por rango de fechas',
    ICONO = 'faCalendarDays',
    ORDEN = 1,
    ACTIVO = 1,
    IDMODULO = 'MOD010';

INSERT IGNORE INTO GRUPO_MODULO (IDGRUPOMODULO, IDTIPOUSUARIO, IDMODULO, IDTIPOPERMISO) VALUES
('GRM055', '3', 'MOD010', 'TP001'),
('GRM056', '3', 'MOD010', 'TP002'),
('GRM057', '3', 'MOD010', 'TP003'),
('GRM058', '3', 'MOD010', 'TP004');

INSERT IGNORE INTO GRUPO_MODULO (IDGRUPOMODULO, IDTIPOUSUARIO, IDMODULO, IDTIPOPERMISO) VALUES
('GRM059', '2', 'MOD010', 'TP001');

SELECT 'Módulo Informes (MOD010) y submódulo Asistencias (SUB011) listos.' AS info;
