-- ============================================================================
-- Membresías — columnas adicionales + catálogos base — MySQL 8
-- ============================================================================

USE `AcademiaDB`;

SET @col := (
    SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'MEMBRESIA' AND COLUMN_NAME = 'TIPOMEMBRESIA'
);
SET @sql := IF(@col = 0, 'ALTER TABLE MEMBRESIA ADD COLUMN TIPOMEMBRESIA VARCHAR(50) NULL', 'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @col := (
    SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'MEMBRESIA' AND COLUMN_NAME = 'ASESOR'
);
SET @sql := IF(@col = 0, 'ALTER TABLE MEMBRESIA ADD COLUMN ASESOR VARCHAR(150) NULL', 'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @col := (
    SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'MEMBRESIA' AND COLUMN_NAME = 'FECHACANCELACION'
);
SET @sql := IF(@col = 0, 'ALTER TABLE MEMBRESIA ADD COLUMN FECHACANCELACION CHAR(8) NULL', 'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @col := (
    SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'MEMBRESIA' AND COLUMN_NAME = 'ESTADO'
);
SET @sql := IF(@col = 0, 'ALTER TABLE MEMBRESIA ADD COLUMN ESTADO VARCHAR(50) NOT NULL DEFAULT ''Activo''', 'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

INSERT IGNORE INTO `PLAN` (IDPLAN, NOMBRE, DESCRIPCION, DURACIONDIAS, PRECIO, ACTIVO) VALUES
    ('PLN001', 'Plan Anual 1', 'Membresía anual — nivel 1', 365, 1200.00, 1),
    ('PLN002', 'Plan Anual 2', 'Membresía anual — nivel 2', 365, 1500.00, 1),
    ('PLN003', 'Plan Semestral', 'Membresía semestral', 180, 700.00, 1);

INSERT IGNORE INTO TURNO (IDTURNO, DESCRIPCION) VALUES
    ('TUR001', 'Mañana'),
    ('TUR002', 'Tarde'),
    ('TUR003', 'Noche');

INSERT IGNORE INTO METODO_PAGO (IDMETODOPAGO, TITULO, DESCRIPCION, ACTIVO) VALUES
    ('MPG001', 'Efectivo', 'Pago en efectivo', 1),
    ('MPG002', 'Transferencia', 'Transferencia bancaria', 1),
    ('MPG003', 'Tarjeta', 'Pago con tarjeta', 1),
    ('MPG004', 'Yape / Plin', 'Billetera digital', 1);

SELECT 'Membresía: columnas y catálogos listos.' AS info;
