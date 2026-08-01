-- Convertido automáticamente desde db_scripts/31_07_2026/3.usp_usuario_eliminar_fisica.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   USUARIO eliminar: retiro (soft) vs eliminación física (solo administrador)
   Ejecutar después de 16.usuario_estado_retirado.sql
   Fecha: 31/07/2026
   ============================================================================ */

DROP PROCEDURE IF EXISTS usp_usuario_eliminar;

DROP PROCEDURE IF EXISTS usp_usuario_eliminar;

DELIMITER $$

CREATE PROCEDURE usp_usuario_eliminar(
    IN p_Id VARCHAR(50),
    IN p_EliminacionFisica TINYINT(1),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
IF NOT EXISTS (SELECT 1 FROM USUARIO WHERE IDUSUARIO = p_Id)
    BEGIN
        SET p_Resultado = 0;
        SET p_Mensaje = 'El usuario no existe.';
        LEAVE main;
    
    IF p_EliminacionFisica = 0
    BEGIN
        UPDATE USUARIO SET ESTADO = 'Retirado' WHERE IDUSUARIO = p_Id;
        SET p_Resultado = 1;
        SET p_Mensaje = 'Usuario retirado.';
        LEAVE main;
    
    IF EXISTS (SELECT 1 FROM USUARIO WHERE IDUSUARIO = p_Id AND IDTIPOUSUARIO = '3')
    BEGIN
        SET p_Resultado = 0;
        SET p_Mensaje = 'No se puede eliminar permanentemente a un administrador.';
        LEAVE main;
    
    IF OBJECT_ID('EXAMEN', 'U') IS NOT NULL
       AND EXISTS (SELECT 1 FROM EXAMEN WHERE IDUSUARIO = p_Id)
    BEGIN
        SET p_Resultado = 0;
        SET p_Mensaje = 'No se puede eliminar: el usuario tiene exámenes registrados como autor.';
        LEAVE main;
    
    BEGIN TRY
        BEGIN TRANSACTION;

        IF OBJECT_ID('MENSUALIDAD', 'U') IS NOT NULL
            UPDATE MENSUALIDAD SET REGISTRADOPOR = NULL WHERE REGISTRADOPOR = p_Id;

        IF OBJECT_ID('PAGOMENSUALIDAD', 'U') IS NOT NULL
            UPDATE PAGOMENSUALIDAD SET IDUSUARIO = NULL WHERE IDUSUARIO = p_Id;

        IF OBJECT_ID('JUSTIFICACION', 'U') IS NOT NULL
        BEGIN
            DELETE FROM JUSTIFICACION WHERE IDUSUARIO = p_Id;
            UPDATE JUSTIFICACION SET IDREGISTRADOR = NULL WHERE IDREGISTRADOR = p_Id;
        
        IF OBJECT_ID('ASISTENCIA', 'U') IS NOT NULL
            DELETE FROM ASISTENCIA WHERE IDUSUARIO = p_Id;

        IF OBJECT_ID('RESPUESTA_ALUMNO', 'U') IS NOT NULL
           AND OBJECT_ID('INTENTO_EXAMEN', 'U') IS NOT NULL
        BEGIN
            DELETE ra
            FROM RESPUESTA_ALUMNO ra
            INNER JOIN INTENTO_EXAMEN i ON i.IDINTENTOEXAMEN = ra.IDINTENTOEXAMEN
            WHERE i.IDUSUARIO = p_Id;

            DELETE FROM INTENTO_EXAMEN WHERE IDUSUARIO = p_Id;
        
        IF OBJECT_ID('NOTA_IMPORTADA', 'U') IS NOT NULL
            DELETE FROM NOTA_IMPORTADA WHERE IDUSUARIO = p_Id;

        IF OBJECT_ID('MENSUALIDAD', 'U') IS NOT NULL
        BEGIN
            IF OBJECT_ID('NOTIFICACIONMENSUALIDAD', 'U') IS NOT NULL
                DELETE n
                FROM NOTIFICACIONMENSUALIDAD n
                INNER JOIN MENSUALIDAD m ON m.IDMENSUALIDAD = n.IDMENSUALIDAD
                WHERE m.IDUSUARIO = p_Id;

            IF OBJECT_ID('PAGOMENSUALIDAD', 'U') IS NOT NULL
                DELETE p
                FROM PAGOMENSUALIDAD p
                INNER JOIN MENSUALIDAD m ON m.IDMENSUALIDAD = p.IDMENSUALIDAD
                WHERE m.IDUSUARIO = p_Id;

            DELETE FROM MENSUALIDAD WHERE IDUSUARIO = p_Id;
        
        IF OBJECT_ID('PAGOEXTRAORDINARIO', 'U') IS NOT NULL
            DELETE FROM PAGOEXTRAORDINARIO WHERE IDUSUARIO = p_Id;

        IF OBJECT_ID('ASESOR', 'U') IS NOT NULL
            DELETE FROM ASESOR WHERE IDUSUARIO = p_Id;

        IF OBJECT_ID('USUARIO_MODULO', 'U') IS NOT NULL
            DELETE FROM USUARIO_MODULO WHERE IDUSUARIO = p_Id;

        IF OBJECT_ID('USUARIO_MODULO_EXCLUIDO', 'U') IS NOT NULL
            DELETE FROM USUARIO_MODULO_EXCLUIDO WHERE IDUSUARIO = p_Id;

        IF OBJECT_ID('USUARIO_SUBMODULO_EXCLUIDO', 'U') IS NOT NULL
            DELETE FROM USUARIO_SUBMODULO_EXCLUIDO WHERE IDUSUARIO = p_Id;

        DELETE FROM USUARIO WHERE IDUSUARIO = p_Id;

        COMMIT TRANSACTION;
        SET p_Resultado = 1;
        SET p_Mensaje = 'Usuario eliminado.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET p_Resultado = 0;
        SET p_Mensaje = LEFT(ERROR_MESSAGE(), 200);
    END CATCH
END;

SELECT 'usp_usuario_eliminar actualizado (retiro / eliminación física).';
    SELECT p_Resultado AS Resultado, p_Mensaje AS Mensaje
END$$

DELIMITER ;
