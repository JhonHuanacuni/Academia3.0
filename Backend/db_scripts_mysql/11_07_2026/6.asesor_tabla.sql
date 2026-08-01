-- Convertido automáticamente desde db_scripts/11_07_2026/6.asesor_tabla.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   Tabla ASESOR + FK en MEMBRESIA
   Fecha: 12/07/2026
   ============================================================================ */

-- create if missing ASESOR
    CREATE TABLE IF NOT EXISTS ASESOR (
        IDASESOR    VARCHAR(50)   NOT NULL PRIMARY KEY,
        NOMBRE      VARCHAR(150)  NOT NULL,
        ACTIVO      TINYINT(1)            NOT NULL CONSTRAINT DF_ASESOR_ACTIVO DEFAULT 1
    );
    SELECT 'Tabla ASESOR creada.';

IF NOT EXISTS (SELECT 1 FROM ASESOR WHERE IDASESOR = 'ASE001')
BEGIN
    INSERT INTO ASESOR (IDASESOR, NOMBRE, ACTIVO) VALUES
    ('ASE001', 'Asesor 1', 1),
    ('ASE002', 'Asesor 2', 1),
    ('ASE003', 'Asesor 3', 1);
    SELECT 'Asesores iniciales insertados.';

-- TODO MySQL: add column if missing on MEMBRESIA.IDASESOR
BEGIN
    ALTER TABLE MEMBRESIA ADD IDASESOR VARCHAR(50) NULL;
    SELECT 'Columna MEMBRESIA.IDASESOR agregada.';

IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_MEMBRESIA_ASESOR'
)
BEGIN
    ALTER TABLE MEMBRESIA
    ADD CONSTRAINT FK_MEMBRESIA_ASESOR
    FOREIGN KEY (IDASESOR) REFERENCES ASESOR(IDASESOR);
    SELECT 'FK_MEMBRESIA_ASESOR creada.';
