/* Rol Trabajador y mora separada por pago de cuota — SQL Server */

UPDATE dbo.TIPOUSUARIO
SET DESCRIPCION = N'Trabajador'
WHERE IDTIPOUSUARIO = N'2';
GO

IF COL_LENGTH('dbo.PAGOMENSUALIDAD', 'MORA') IS NULL
BEGIN
    ALTER TABLE dbo.PAGOMENSUALIDAD
        ADD MORA DECIMAL(10,2) NOT NULL
            CONSTRAINT DF_PAGOMENSUALIDAD_MORA DEFAULT (0);
END;
GO

PRINT 'Rol Trabajador y mora de pagos listos.';
GO
