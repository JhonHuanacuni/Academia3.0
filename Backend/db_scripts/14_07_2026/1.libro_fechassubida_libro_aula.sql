/* ============================================================================
   BIBLIOTECA — columnas y relación libro ↔ salón
   Fecha: 14/07/2026
   ============================================================================ */

-- Fecha de subida (DDMMYYYY)
IF COL_LENGTH('dbo.LIBRO', 'FECHASUBIDA') IS NULL
BEGIN
    ALTER TABLE dbo.LIBRO ADD FECHASUBIDA CHAR(8) NULL
        CHECK (FECHASUBIDA LIKE '[0-3][0-9][0-1][0-9][0-9][0-9][0-9][0-9]');
END
GO

-- Relación N:M libro ↔ aula (salones con acceso)
IF OBJECT_ID('dbo.LIBRO_AULA', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.LIBRO_AULA (
        IDLIBROAULA NVARCHAR(50) NOT NULL PRIMARY KEY,
        IDLIBRO     NVARCHAR(50) NOT NULL FOREIGN KEY REFERENCES dbo.LIBRO(IDLIBRO),
        IDAULA      NVARCHAR(50) NOT NULL FOREIGN KEY REFERENCES dbo.AULA(IDAULA),
        CONSTRAINT UQ_LIBRO_AULA UNIQUE (IDLIBRO, IDAULA)
    );
    CREATE INDEX IX_LIBRO_AULA_LIBRO ON dbo.LIBRO_AULA(IDLIBRO);
    CREATE INDEX IX_LIBRO_AULA_AULA  ON dbo.LIBRO_AULA(IDAULA);
END
GO

PRINT 'LIBRO.FECHASUBIDA y LIBRO_AULA listos.';
GO
