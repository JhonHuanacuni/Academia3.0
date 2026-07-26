/* ============================================================================
   Tabla ASESOR + FK en MEMBRESIA
   Fecha: 12/07/2026
   ============================================================================ */

IF OBJECT_ID('dbo.ASESOR', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.ASESOR (
        IDASESOR    NVARCHAR(50)   NOT NULL PRIMARY KEY,
        NOMBRE      NVARCHAR(150)  NOT NULL,
        ACTIVO      BIT            NOT NULL CONSTRAINT DF_ASESOR_ACTIVO DEFAULT 1
    );
    PRINT 'Tabla ASESOR creada.';
END
ELSE
    PRINT 'Tabla ASESOR ya existe.';
GO

IF NOT EXISTS (SELECT 1 FROM ASESOR WHERE IDASESOR = 'ASE001')
BEGIN
    INSERT INTO ASESOR (IDASESOR, NOMBRE, ACTIVO) VALUES
    ('ASE001', 'Asesor 1', 1),
    ('ASE002', 'Asesor 2', 1),
    ('ASE003', 'Asesor 3', 1);
    PRINT 'Asesores iniciales insertados.';
END
GO

IF COL_LENGTH('MEMBRESIA', 'IDASESOR') IS NULL
BEGIN
    ALTER TABLE MEMBRESIA ADD IDASESOR NVARCHAR(50) NULL;
    PRINT 'Columna MEMBRESIA.IDASESOR agregada.';
END
ELSE
    PRINT 'Columna MEMBRESIA.IDASESOR ya existe.';
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_MEMBRESIA_ASESOR'
)
BEGIN
    ALTER TABLE MEMBRESIA
    ADD CONSTRAINT FK_MEMBRESIA_ASESOR
    FOREIGN KEY (IDASESOR) REFERENCES ASESOR(IDASESOR);
    PRINT 'FK_MEMBRESIA_ASESOR creada.';
END
GO
