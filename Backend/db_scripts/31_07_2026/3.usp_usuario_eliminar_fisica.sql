/* ============================================================================
   USUARIO eliminar: retiro (soft) vs eliminación física (solo administrador)
   Ejecutar después de 16.usuario_estado_retirado.sql
   Fecha: 31/07/2026
   ============================================================================ */

SET QUOTED_IDENTIFIER ON;
GO
SET ANSI_NULLS ON;
GO

IF OBJECT_ID('dbo.usp_usuario_eliminar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_usuario_eliminar;
GO

SET QUOTED_IDENTIFIER ON;
GO
SET ANSI_NULLS ON;
GO

CREATE PROCEDURE dbo.usp_usuario_eliminar
    @Id                 NVARCHAR(50),
    @EliminacionFisica  BIT           = 0,
    @Resultado          INT OUTPUT,
    @Mensaje            NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM USUARIO WHERE IDUSUARIO = @Id)
    BEGIN
        SET @Resultado = 0;
        SET @Mensaje = 'El usuario no existe.';
        RETURN;
    END

    IF @EliminacionFisica = 0
    BEGIN
        UPDATE USUARIO SET ESTADO = 'Retirado' WHERE IDUSUARIO = @Id;
        SET @Resultado = 1;
        SET @Mensaje = 'Usuario retirado.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM USUARIO WHERE IDUSUARIO = @Id AND IDTIPOUSUARIO = '3')
    BEGIN
        SET @Resultado = 0;
        SET @Mensaje = 'No se puede eliminar permanentemente a un administrador.';
        RETURN;
    END

    IF OBJECT_ID('EXAMEN', 'U') IS NOT NULL
       AND EXISTS (SELECT 1 FROM EXAMEN WHERE IDUSUARIO = @Id)
    BEGIN
        SET @Resultado = 0;
        SET @Mensaje = 'No se puede eliminar: el usuario tiene exámenes registrados como autor.';
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        IF OBJECT_ID('MENSUALIDAD', 'U') IS NOT NULL
            UPDATE MENSUALIDAD SET REGISTRADOPOR = NULL WHERE REGISTRADOPOR = @Id;

        IF OBJECT_ID('PAGOMENSUALIDAD', 'U') IS NOT NULL
            UPDATE PAGOMENSUALIDAD SET IDUSUARIO = NULL WHERE IDUSUARIO = @Id;

        IF OBJECT_ID('JUSTIFICACION', 'U') IS NOT NULL
        BEGIN
            DELETE FROM JUSTIFICACION WHERE IDUSUARIO = @Id;
            UPDATE JUSTIFICACION SET IDREGISTRADOR = NULL WHERE IDREGISTRADOR = @Id;
        END

        IF OBJECT_ID('ASISTENCIA', 'U') IS NOT NULL
            DELETE FROM ASISTENCIA WHERE IDUSUARIO = @Id;

        IF OBJECT_ID('RESPUESTA_ALUMNO', 'U') IS NOT NULL
           AND OBJECT_ID('INTENTO_EXAMEN', 'U') IS NOT NULL
        BEGIN
            DELETE ra
            FROM RESPUESTA_ALUMNO ra
            INNER JOIN INTENTO_EXAMEN i ON i.IDINTENTOEXAMEN = ra.IDINTENTOEXAMEN
            WHERE i.IDUSUARIO = @Id;

            DELETE FROM INTENTO_EXAMEN WHERE IDUSUARIO = @Id;
        END

        IF OBJECT_ID('NOTA_IMPORTADA', 'U') IS NOT NULL
            DELETE FROM NOTA_IMPORTADA WHERE IDUSUARIO = @Id;

        IF OBJECT_ID('MENSUALIDAD', 'U') IS NOT NULL
        BEGIN
            IF OBJECT_ID('NOTIFICACIONMENSUALIDAD', 'U') IS NOT NULL
                DELETE n
                FROM NOTIFICACIONMENSUALIDAD n
                INNER JOIN MENSUALIDAD m ON m.IDMENSUALIDAD = n.IDMENSUALIDAD
                WHERE m.IDUSUARIO = @Id;

            IF OBJECT_ID('PAGOMENSUALIDAD', 'U') IS NOT NULL
                DELETE p
                FROM PAGOMENSUALIDAD p
                INNER JOIN MENSUALIDAD m ON m.IDMENSUALIDAD = p.IDMENSUALIDAD
                WHERE m.IDUSUARIO = @Id;

            DELETE FROM MENSUALIDAD WHERE IDUSUARIO = @Id;
        END

        IF OBJECT_ID('PAGOEXTRAORDINARIO', 'U') IS NOT NULL
            DELETE FROM PAGOEXTRAORDINARIO WHERE IDUSUARIO = @Id;

        IF OBJECT_ID('ASESOR', 'U') IS NOT NULL
            DELETE FROM ASESOR WHERE IDUSUARIO = @Id;

        IF OBJECT_ID('USUARIO_MODULO', 'U') IS NOT NULL
            DELETE FROM USUARIO_MODULO WHERE IDUSUARIO = @Id;

        IF OBJECT_ID('USUARIO_MODULO_EXCLUIDO', 'U') IS NOT NULL
            DELETE FROM USUARIO_MODULO_EXCLUIDO WHERE IDUSUARIO = @Id;

        IF OBJECT_ID('USUARIO_SUBMODULO_EXCLUIDO', 'U') IS NOT NULL
            DELETE FROM USUARIO_SUBMODULO_EXCLUIDO WHERE IDUSUARIO = @Id;

        DELETE FROM USUARIO WHERE IDUSUARIO = @Id;

        COMMIT TRANSACTION;
        SET @Resultado = 1;
        SET @Mensaje = 'Usuario eliminado.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @Resultado = 0;
        SET @Mensaje = LEFT(ERROR_MESSAGE(), 200);
    END CATCH
END;
GO

PRINT 'usp_usuario_eliminar actualizado (retiro / eliminación física).';
GO
