/* ============================================================================
   usp_mensualidad_listar_pagos
   Ejecutar después de 18.usp_usuario_resetear_contra.sql
   Fecha: 27/07/2026
   ============================================================================ */

IF OBJECT_ID('dbo.usp_mensualidad_listar_pagos', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_mensualidad_listar_pagos;
GO
CREATE PROCEDURE dbo.usp_mensualidad_listar_pagos
    @IdMensualidad NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = @IdMensualidad)
    BEGIN
        RAISERROR('La mensualidad no existe.', 16, 1);
        RETURN;
    END

    SELECT
        p.IDPAGOMENSUALIDAD,
        p.MONTO,
        p.FECHAPAGO,
        p.HORAPAGO,
        p.OBSERVACIONES,
        ISNULL(mp.TITULO, '') AS METODOPAGO_TITULO,
        UPPER(LTRIM(RTRIM(
            ISNULL(reg.APELLIDO, '') + ' ' + ISNULL(reg.NOMBRE, '')
        ))) AS REGISTRADO_POR
    FROM PAGOMENSUALIDAD p
    LEFT JOIN METODO_PAGO mp ON mp.IDMETODOPAGO = p.IDMETODOPAGO
    LEFT JOIN USUARIO reg ON reg.IDUSUARIO = p.IDUSUARIO
    WHERE p.IDMENSUALIDAD = @IdMensualidad
    ORDER BY p.FECHAPAGO DESC, p.HORAPAGO DESC, p.IDPAGOMENSUALIDAD DESC;
END;
GO

PRINT 'usp_mensualidad_listar_pagos listo.';
GO
