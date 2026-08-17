-- Rol Trabajador y mora separada por pago de cuota — MySQL 8
USE `AcademiaDB`;

UPDATE TIPOUSUARIO
SET DESCRIPCION = 'Trabajador'
WHERE IDTIPOUSUARIO = '2';

SET @mora_exists := (
    SELECT COUNT(*)
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'PAGOMENSUALIDAD'
      AND COLUMN_NAME = 'MORA'
);
SET @mora_sql := IF(
    @mora_exists = 0,
    'ALTER TABLE PAGOMENSUALIDAD ADD COLUMN MORA DECIMAL(10,2) NOT NULL DEFAULT 0 AFTER MONTO',
    'SELECT ''La columna PAGOMENSUALIDAD.MORA ya existe'' AS info'
);
PREPARE mora_stmt FROM @mora_sql;
EXECUTE mora_stmt;
DEALLOCATE PREPARE mora_stmt;

SELECT 'Rol Trabajador y mora de pagos listos.' AS info;
