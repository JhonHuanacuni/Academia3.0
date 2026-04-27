IF OBJECT_ID('dbo.usp_get_clientes', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_get_clientes;
GO

CREATE PROCEDURE dbo.usp_get_clientes
AS
BEGIN
    SET NOCOUNT ON;
    SELECT id, nombre, email, activo, creado_en
    FROM clientes
    WHERE activo = 1;
END;
GO
