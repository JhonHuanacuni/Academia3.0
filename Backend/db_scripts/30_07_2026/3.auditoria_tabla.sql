/* ============================================================================
   Tabla central AUDITORIA — historial INSERT / UPDATE / DELETE
   Fecha: 31/07/2026
   Prerequisito: 1.auditoria_columnas_tablas.sql
   ============================================================================ */

IF OBJECT_ID('dbo.AUDITORIA', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.AUDITORIA (
        IDAUDITORIA     NVARCHAR(50)  NOT NULL PRIMARY KEY,
        TABLA           NVARCHAR(100) NOT NULL,
        IDREGISTRO      NVARCHAR(50)  NOT NULL,
        ACCION          NVARCHAR(20)  NOT NULL,
        IDUSUARIO       NVARCHAR(50)  NULL,
        FECHA           CHAR(8)       NOT NULL,
        HORA            CHAR(8)       NOT NULL,
        DATOS_ANTES     NVARCHAR(MAX) NULL,
        DATOS_DESPUES   NVARCHAR(MAX) NULL
    );

    CREATE INDEX IX_AUDITORIA_TABLA_FECHA ON dbo.AUDITORIA (TABLA, FECHA DESC, HORA DESC);
    CREATE INDEX IX_AUDITORIA_USUARIO ON dbo.AUDITORIA (IDUSUARIO, FECHA DESC);
    CREATE INDEX IX_AUDITORIA_REGISTRO ON dbo.AUDITORIA (TABLA, IDREGISTRO);

    PRINT 'Tabla AUDITORIA creada.';
END
ELSE
    PRINT 'Tabla AUDITORIA ya existe.';
GO

IF OBJECT_ID('dbo.usp_auditoria_siguiente_id', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_auditoria_siguiente_id;
GO
CREATE PROCEDURE dbo.usp_auditoria_siguiente_id
    @Id NVARCHAR(50) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Num INT = 1;
    SELECT @Num = ISNULL(MAX(TRY_CAST(SUBSTRING(IDAUDITORIA, 4, 10) AS INT)), 0) + 1
    FROM dbo.AUDITORIA
    WHERE IDAUDITORIA LIKE 'AUD%';
    SET @Id = 'AUD' + RIGHT('000000' + CAST(@Num AS VARCHAR(10)), 6);
END;
GO

PRINT 'Secuencia AUDITORIA lista.';
GO
