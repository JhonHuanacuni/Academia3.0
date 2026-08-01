-- Convertido automáticamente desde db_scripts/14_07_2026/3.horario_tabla.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   HORARIO — tabla CONCAT(principal, relaci)ón con salones
   Fecha: 14/07/2026
   ============================================================================ */

-- create if missing HORARIO
    CREATE TABLE IF NOT EXISTS HORARIO (
        IDHORARIO    VARCHAR(50)  NOT NULL PRIMARY KEY,
        TITULO       VARCHAR(200) NOT NULL,
        DESCRIPCION  LONGTEXT NULL,
        URLIMAGEN    VARCHAR(255) NULL,
        FECHASUBIDA  CHAR(8)       NULL,
        ESTADO       VARCHAR(50)  NULL DEFAULT 'Activo'
    );

-- create if missing HORARIO_AULA
    CREATE TABLE IF NOT EXISTS HORARIO_AULA (
        IDHORARIOAULA VARCHAR(50) NOT NULL PRIMARY KEY,
        IDHORARIO VARCHAR(50) NOT NULL,
    FOREIGN KEY (IDHORARIO) REFERENCES HORARIO(IDHORARIO),
        IDAULA VARCHAR(50) NOT NULL,
    FOREIGN KEY (IDAULA) REFERENCES AULA(IDAULA),
        CONSTRAINT UQ_HORARIO_AULA UNIQUE (IDHORARIO, IDAULA)
    );
    CREATE INDEX IX_HORARIO_AULA_HORARIO ON HORARIO_AULA(IDHORARIO);
    CREATE INDEX IX_HORARIO_AULA_AULA    ON HORARIO_AULA(IDAULA);

SELECT 'HORARIO y HORARIO_AULA listos.';