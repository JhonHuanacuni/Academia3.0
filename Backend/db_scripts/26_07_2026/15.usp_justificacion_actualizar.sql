/* ============================================================================
   usp_justificacion_actualizar
   Ejecutar después de 14.justificacion.sql
   Fecha: 27/07/2026
   ============================================================================ */

IF OBJECT_ID('dbo.usp_justificacion_actualizar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_justificacion_actualizar;
GO
CREATE PROCEDURE dbo.usp_justificacion_actualizar
    @Id             NVARCHAR(50),
    @IdUsuario      NVARCHAR(50),
    @Fecha          CHAR(8),
    @Observacion    NVARCHAR(500) = NULL,
    @Resultado      INT OUTPUT,
    @Mensaje        NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM JUSTIFICACION WHERE IDJUSTIFICACION = @Id)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'La justificación no existe.'; RETURN; END

    IF @IdUsuario IS NULL OR LTRIM(RTRIM(@IdUsuario)) = ''
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Selecciona un estudiante.'; RETURN; END

    IF @Fecha IS NULL OR LTRIM(RTRIM(@Fecha)) = ''
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Selecciona la fecha a justificar.'; RETURN; END

    IF NOT EXISTS (SELECT 1 FROM USUARIO WHERE IDUSUARIO = @IdUsuario AND ESTADO = 'Activo')
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El estudiante no existe o está inactivo.'; RETURN; END

    DECLARE @OldUsuario NVARCHAR(50);
    DECLARE @OldFecha CHAR(8);
    SELECT @OldUsuario = IDUSUARIO, @OldFecha = FECHA FROM JUSTIFICACION WHERE IDJUSTIFICACION = @Id;

    IF EXISTS (
        SELECT 1 FROM JUSTIFICACION
        WHERE IDUSUARIO = @IdUsuario AND FECHA = @Fecha AND IDJUSTIFICACION <> @Id
    )
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ya existe una justificación para ese estudiante en esa fecha.'; RETURN; END

    UPDATE JUSTIFICACION SET
        IDUSUARIO   = @IdUsuario,
        FECHA       = @Fecha,
        OBSERVACION = NULLIF(LTRIM(RTRIM(@Observacion)), '')
    WHERE IDJUSTIFICACION = @Id;

    IF @OldUsuario <> @IdUsuario OR @OldFecha <> @Fecha
    BEGIN
        IF EXISTS (SELECT 1 FROM ASISTENCIA WHERE IDUSUARIO = @OldUsuario AND FECHAREGISTRO = @OldFecha AND ESTADO = 'Falta' AND JUSTIFICADO = 1)
           AND NOT EXISTS (
               SELECT 1 FROM ASISTENCIA
               WHERE IDUSUARIO = @OldUsuario AND FECHAREGISTRO = @OldFecha
                 AND (ESTADO <> 'Falta' OR JUSTIFICADO = 0)
           )
            DELETE FROM ASISTENCIA WHERE IDUSUARIO = @OldUsuario AND FECHAREGISTRO = @OldFecha AND ESTADO = 'Falta';
        ELSE IF EXISTS (SELECT 1 FROM ASISTENCIA WHERE IDUSUARIO = @OldUsuario AND FECHAREGISTRO = @OldFecha)
            UPDATE ASISTENCIA SET JUSTIFICADO = 0 WHERE IDUSUARIO = @OldUsuario AND FECHAREGISTRO = @OldFecha;

        IF EXISTS (SELECT 1 FROM ASISTENCIA WHERE IDUSUARIO = @IdUsuario AND FECHAREGISTRO = @Fecha)
            UPDATE ASISTENCIA SET JUSTIFICADO = 1 WHERE IDUSUARIO = @IdUsuario AND FECHAREGISTRO = @Fecha;
        ELSE
        BEGIN
            DECLARE @Hora CHAR(8) = CONVERT(CHAR(8), CAST(SYSDATETIMEOFFSET() AT TIME ZONE 'SA Pacific Standard Time' AS TIME), 108);
            INSERT INTO ASISTENCIA (IDASISTENCIA, FECHAREGISTRO, HORAINICIO, ESTADO, JUSTIFICADO, IDUSUARIO)
            VALUES ('AS_' + REPLACE(CONVERT(NVARCHAR(36), NEWID()), '-', ''), @Fecha, @Hora, 'Falta', 1, @IdUsuario);
        END
    END
    ELSE IF EXISTS (SELECT 1 FROM ASISTENCIA WHERE IDUSUARIO = @IdUsuario AND FECHAREGISTRO = @Fecha)
        UPDATE ASISTENCIA SET JUSTIFICADO = 1 WHERE IDUSUARIO = @IdUsuario AND FECHAREGISTRO = @Fecha;

    SET @Resultado = 1; SET @Mensaje = 'Justificación actualizada.';
END;
GO

PRINT 'usp_justificacion_actualizar listo.';
GO
