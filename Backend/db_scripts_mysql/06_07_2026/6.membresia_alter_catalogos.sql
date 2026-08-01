-- Convertido automáticamente desde db_scripts/06_07_2026/6.membresia_alter_catalogos.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   Membresías — columnas CONCAT(adicionales, cat)álogos base (planes, turnos, pagos)
   Ejecutar después de scripts 22_06_2026 y 29_06_2026
   Fecha: 06/07/2026
   ============================================================================ */

SET @col_MEMBRESIA_TIPOMEMBRESIA := (
    SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'MEMBRESIA' AND COLUMN_NAME = 'TIPOMEMBRESIA'
);
SET @sql_MEMBRESIA_TIPOMEMBRESIA := IF(@col_MEMBRESIA_TIPOMEMBRESIA = 0, 'ALTER TABLE MEMBRESIA ADD TIPOMEMBRESIA VARCHAR(50) NULL;
-- TODO MySQL: add column if missing on MEMBRESIA.ASESOR
    ALTER TABLE MEMBRESIA ADD ASESOR VARCHAR(150) NULL;
-- TODO MySQL: add column if missing on MEMBRESIA.FECHACANCELACION
    ALTER TABLE MEMBRESIA ADD FECHACANCELACION CHAR(8) NULL;
-- TODO MySQL: add column if missing on MEMBRESIA.ESTADO
    ALTER TABLE MEMBRESIA ADD ESTADO VARCHAR(50) NOT NULL CONSTRAINT DF_MEMBRESIA_ESTADO DEFAULT ''Activo'';

/* PLAN es palabra reservada en SQL Server → usar `PLAN` */
IF NOT EXISTS (SELECT 1 FROM `PLAN` WHERE IDPLAN = ''PLN001'')
    INSERT INTO `PLAN` (IDPLAN, NOMBRE, DESCRIPCION, DURACIONDIAS, PRECIO, ACTIVO) VALUES
    (''PLN001'', ''Plan Anual 1'', ''Membresía anual — nivel 1'', 365, 1200.00, 1),
    (''PLN002'', ''Plan Anual 2'', ''Membresía anual — nivel 2'', 365, 1500.00, 1),
    (''PLN003'', ''Plan Semestral'', ''Membresía semestral'', 180, 700.00, 1);

INSERT IGNORE INTO TURNO (IDTURNO, DESCRIPCION) VALUES
    (''TUR001'', ''Mañana''),
    (''TUR002'', ''Tarde''),
    (''TUR003'', ''Noche'');

INSERT IGNORE INTO METODO_PAGO (IDMETODOPAGO, TITULO, DESCRIPCION, ACTIVO) VALUES
    (''MPG001'', ''Efectivo'', ''Pago en efectivo'', 1),
    (''MPG002'', ''Transferencia'', ''Transferencia bancaria'', 1),
    (''MPG003'', ''Tarjeta'', ''Pago con tarjeta'', 1),
    (''MPG004'', ''Yape / Plin'', ''Billetera digital'', 1)', 'SELECT 1');
PREPARE stmt FROM @sql_MEMBRESIA_TIPOMEMBRESIA; EXECUTE stmt; DEALLOCATE PREPARE stmt;