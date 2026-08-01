/* ============================================================================
   USUARIO: estado Inactivo -> Retirado
   Ejecutar después de 15.usp_justificacion_actualizar.sql
   Fecha: 27/07/2026
   ============================================================================ */

UPDATE USUARIO SET ESTADO = 'Retirado' WHERE ESTADO = 'Inactivo';
GO

IF OBJECT_ID('dbo.usp_usuario_eliminar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_usuario_eliminar;
GO
CREATE PROCEDURE dbo.usp_usuario_eliminar
    @Id        NVARCHAR(50),
    @Resultado INT OUTPUT,
    @Mensaje   NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM USUARIO WHERE IDUSUARIO = @Id)
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'El usuario no existe.';
        RETURN;
    END

    UPDATE USUARIO SET ESTADO = 'Retirado' WHERE IDUSUARIO = @Id;

    SET @Resultado = 1; SET @Mensaje = 'Usuario retirado.';
END;
GO

PRINT 'USUARIO: estado Retirado aplicado (datos + usp_usuario_eliminar).';
GO
