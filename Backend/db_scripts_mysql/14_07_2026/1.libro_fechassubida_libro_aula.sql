-- Convertido automáticamente desde db_scripts/14_07_2026/1.libro_fechassubida_libro_aula.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   BIBLIOTECA — columnas y relación libro ↔ salón
   Fecha: 14/07/2026
   ============================================================================ */

-- Fecha de subida (DDMMYYYY)
SET @col_LIBRO_FECHASUBIDA := (
    SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'LIBRO' AND COLUMN_NAME = 'FECHASUBIDA'
);
SET @sql_LIBRO_FECHASUBIDA := IF(@col_LIBRO_FECHASUBIDA = 0, 'ALTER TABLE LIBRO ADD FECHASUBIDA CHAR(8) NULL;

-- Relación N:M libro ↔ aula (salones con acceso)
-- create if missing LIBRO_AULA
    CREATE TABLE IF NOT EXISTS LIBRO_AULA (
        IDLIBROAULA VARCHAR(50) NOT NULL PRIMARY KEY,
        IDLIBRO VARCHAR(50) NOT NULL,
    FOREIGN KEY (IDLIBRO) REFERENCES LIBRO(IDLIBRO),
        IDAULA VARCHAR(50) NOT NULL,
    FOREIGN KEY (IDAULA) REFERENCES AULA(IDAULA),
        CONSTRAINT UQ_LIBRO_AULA UNIQUE (IDLIBRO, IDAULA)
    );
    CREATE INDEX IX_LIBRO_AULA_LIBRO ON LIBRO_AULA(IDLIBRO);
    CREATE INDEX IX_LIBRO_AULA_AULA  ON LIBRO_AULA(IDAULA)', 'SELECT 1');
PREPARE stmt FROM @sql_LIBRO_FECHASUBIDA; EXECUTE stmt; DEALLOCATE PREPARE stmt;