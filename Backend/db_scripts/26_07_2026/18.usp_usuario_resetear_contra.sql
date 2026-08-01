/* ============================================================================
   usp_usuario_resetear_contra — contraseña = DNI
   Ejecutar después de 17.mensualidad_filtro_deuda.sql
   Fecha: 27/07/2026
   ============================================================================ */

IF OBJECT_ID('dbo.usp_usuario_resetear_contra', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_usuario_resetear_contra;
GO
CREATE PROCEDURE dbo.usp_usuario_resetear_contra
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

    UPDATE USUARIO SET CONTRA = DNI WHERE IDUSUARIO = @Id;

    SET @Resultado = 1; SET @Mensaje = 'Contraseña restablecida al DNI.';
END;
GO

PRINT 'usp_usuario_resetear_contra listo.';
GO
