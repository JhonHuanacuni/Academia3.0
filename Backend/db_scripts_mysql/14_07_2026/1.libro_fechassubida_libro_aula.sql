-- Convertido automáticamente desde db_scripts/14_07_2026/1.libro_fechassubida_libro_aula.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   BIBLIOTECA — columnas y relación libro ↔ salón
   Fecha: 14/07/2026
   ============================================================================ */

-- Fecha de subida (DDMMYYYY)
-- TODO MySQL: add column if missing on LIBRO.FECHASUBIDA
BEGIN
    ALTER TABLE LIBRO ADD FECHASUBIDA CHAR(8) NULL;

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
    CREATE INDEX IX_LIBRO_AULA_AULA  ON LIBRO_AULA(IDAULA);

SELECT 'LIBRO.FECHASUBIDA y LIBRO_AULA listos.';
