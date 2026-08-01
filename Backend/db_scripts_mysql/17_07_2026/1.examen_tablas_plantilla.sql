-- Convertido automáticamente desde db_scripts/17_07_2026/1.examen_tablas_plantilla.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   EXAMEN: TODASLASULA + EXAMEN_AULA + plantilla distribución
   Fecha: 17/07/2026
   ============================================================================ */

-- TODO MySQL: add column if missing on EXAMEN.TODASLASULA
BEGIN
    ALTER TABLE EXAMEN ADD TODASLASULA TINYINT(1) NOT NULL
        CONSTRAINT DF_EXAMEN_TODASLASULA DEFAULT (1);
    SELECT 'Columna EXAMEN.TODASLASULA agregada.';

-- create if missing EXAMEN_AULA
    CREATE TABLE IF NOT EXISTS EXAMEN_AULA (
        IDEXAMENAULA VARCHAR(50) NOT NULL PRIMARY KEY,
        IDEXAMEN VARCHAR(50) NOT NULL,
    FOREIGN KEY (IDEXAMEN) REFERENCES EXAMEN(IDEXAMEN),
        IDAULA VARCHAR(50) NOT NULL,
    FOREIGN KEY (IDAULA) REFERENCES AULA(IDAULA),
        CONSTRAINT UQ_EXAMEN_AULA UNIQUE (IDEXAMEN, IDAULA)
    );
    CREATE INDEX IX_EXAMEN_AULA_EXAMEN ON EXAMEN_AULA(IDEXAMEN);
    CREATE INDEX IX_EXAMEN_AULA_AULA   ON EXAMEN_AULA(IDAULA);
    SELECT 'Tabla EXAMEN_AULA creada.';

-- create if missing EXAMEN_PLANTILLA
    CREATE TABLE IF NOT EXISTS EXAMEN_PLANTILLA (
        IDPLANTILLA INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        TIPO        INT NOT NULL,           -- 40 o 100
        CODIGOMATERIA VARCHAR(50) NOT NULL,
        CANTIDAD    INT NOT NULL
    );
    SELECT 'Tabla EXAMEN_PLANTILLA creada.';

DELETE FROM EXAMEN_PLANTILLA;

-- Plantilla 40 preguntas (Academia 2.0)
INSERT INTO EXAMEN_PLANTILLA (TIPO, CODIGOMATERIA, CANTIDAD) VALUES
(40, 'HM', 4), (40, 'HV', 4),
(40, 'ARIT', 2), (40, 'GEO', 2), (40, 'ALGE', 2), (40, 'TRIGO', 2),
(40, 'LENGUA', 2), (40, 'PSI', 2), (40, 'CIV', 2), (40, 'HP', 2),
(40, 'HU', 2), (40, 'GEO_L', 2), (40, 'ECO', 2), (40, 'FILO', 2),
(40, 'FIS', 2), (40, 'QUI', 2), (40, 'BIO', 4);

-- Plantilla 100 (= ×2.5)
INSERT INTO EXAMEN_PLANTILLA (TIPO, CODIGOMATERIA, CANTIDAD) VALUES
(100, 'HM', 10), (100, 'HV', 10),
(100, 'ARIT', 5), (100, 'GEO', 5), (100, 'ALGE', 5), (100, 'TRIGO', 5),
(100, 'LENGUA', 5), (100, 'PSI', 5), (100, 'CIV', 5), (100, 'HP', 5),
(100, 'HU', 5), (100, 'GEO_L', 5), (100, 'ECO', 5), (100, 'FILO', 5),
(100, 'FIS', 5), (100, 'QUI', 5), (100, 'BIO', 10);

SELECT 'EXAMEN tablas y plantilla listos.';
