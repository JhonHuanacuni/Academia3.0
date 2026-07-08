/* ============================================================================
   Eliminar membresía: admin = borrado físico, demás roles = desactivar
   Ejecutar después de 8.usp_membresia_listar_activos.sql
   Fecha: 06/07/2026
   ============================================================================ */

IF OBJECT_ID('dbo.usp_membresia_eliminar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_membresia_eliminar;
GO
CREATE PROCEDURE dbo.usp_membresia_eliminar
    @Id                 NVARCHAR(50),
    @EliminacionFisica  BIT           = 0,
    @Resultado          INT OUTPUT,
    @Mensaje            NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM MEMBRESIA WHERE IDMEMBRESIA = @Id)
    BEGIN
        SET @Resultado = 0;
        SET @Mensaje = 'La membresía no existe.';
        RETURN;
    END

    IF @EliminacionFisica = 1
    BEGIN
        DELETE FROM NOTIFICACIONMEMBRESIA WHERE IDMEMBRESIA = @Id;
        DELETE FROM PAGOMEMBRESIA WHERE IDMEMBRESIA = @Id;
        DELETE FROM MEMBRESIA WHERE IDMEMBRESIA = @Id;
        SET @Resultado = 1;
        SET @Mensaje = 'Membresía eliminada permanentemente.';
        RETURN;
    END

    UPDATE MEMBRESIA
    SET ESTADO = 'Inactivo', ESTADOMIEMBRO = 4
    WHERE IDMEMBRESIA = @Id;

    SET @Resultado = 1;
    SET @Mensaje = 'Membresía desactivada.';
END;
GO

PRINT 'usp_membresia_eliminar actualizado: físico (admin) o desactivar (otros roles).';
GO
