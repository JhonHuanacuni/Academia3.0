/* ============================================================================
   CONCEPTOPAGOEXTRA — catálogo de conceptos (nombre + costo)
   Fecha: 16/07/2026
   ============================================================================ */

IF OBJECT_ID('dbo.CONCEPTOPAGOEXTRA', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.CONCEPTOPAGOEXTRA (
        IDCONCEPTO NVARCHAR(50)  NOT NULL PRIMARY KEY,
        NOMBRE     NVARCHAR(150) NOT NULL,
        COSTO      DECIMAL(10,2) NOT NULL DEFAULT 0,
        FECHAINICIO CHAR(8)      NULL
            CHECK (FECHAINICIO LIKE '[0-3][0-9][0-1][0-9][0-9][0-9][0-9][0-9]'),
        FECHAFIN    CHAR(8)      NULL
            CHECK (FECHAFIN LIKE '[0-3][0-9][0-1][0-9][0-9][0-9][0-9][0-9]'),
        ACTIVO     BIT           NOT NULL DEFAULT 1
    );
    PRINT 'Tabla CONCEPTOPAGOEXTRA creada.';
END
ELSE
    PRINT 'Tabla CONCEPTOPAGOEXTRA ya existe.';
GO
