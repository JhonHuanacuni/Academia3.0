/* ============================================================================
   Pregunta guardar: imágenes por alternativa A–E
   Fecha: 17/07/2026
   ============================================================================ */

IF OBJECT_ID('dbo.usp_examen_pregunta_guardar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_examen_pregunta_guardar;
GO
CREATE PROCEDURE dbo.usp_examen_pregunta_guardar
    @IdExamen       NVARCHAR(50),
    @IdPregunta     NVARCHAR(50),
    @Descripcion    NVARCHAR(MAX) = NULL,
    @ImageUrl       NVARCHAR(255) = NULL,
    @QuitarImagen   BIT = 0,
    @Alt1           NVARCHAR(MAX) = NULL,
    @Alt2           NVARCHAR(MAX) = NULL,
    @Alt3           NVARCHAR(MAX) = NULL,
    @Alt4           NVARCHAR(MAX) = NULL,
    @Alt5           NVARCHAR(MAX) = NULL,
    @ImgAlt1        NVARCHAR(255) = NULL,
    @ImgAlt2        NVARCHAR(255) = NULL,
    @ImgAlt3        NVARCHAR(255) = NULL,
    @ImgAlt4        NVARCHAR(255) = NULL,
    @ImgAlt5        NVARCHAR(255) = NULL,
    @QuitarImgAlt1  BIT = 0,
    @QuitarImgAlt2  BIT = 0,
    @QuitarImgAlt3  BIT = 0,
    @QuitarImgAlt4  BIT = 0,
    @QuitarImgAlt5  BIT = 0,
    @CorrectaOrden  INT = 1,
    @Resultado      INT OUTPUT,
    @Mensaje        NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM PREGUNTA WHERE IDPREGUNTA = @IdPregunta AND IDEXAMEN = @IdExamen)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'La pregunta no existe en este examen.'; RETURN; END

    IF @CorrectaOrden IS NULL OR @CorrectaOrden < 1 OR @CorrectaOrden > 5
        SET @CorrectaOrden = 1;

    UPDATE PREGUNTA SET
        DESCRIPCION = @Descripcion,
        IMAGEURL = CASE
            WHEN @QuitarImagen = 1 THEN NULL
            WHEN @ImageUrl IS NOT NULL AND LTRIM(RTRIM(@ImageUrl)) <> '' THEN @ImageUrl
            ELSE IMAGEURL
        END
    WHERE IDPREGUNTA = @IdPregunta;

    UPDATE ALTERNATIVA SET
        DESCRIPCION = CASE ORDEN
            WHEN 1 THEN ISNULL(@Alt1, N'')
            WHEN 2 THEN ISNULL(@Alt2, N'')
            WHEN 3 THEN ISNULL(@Alt3, N'')
            WHEN 4 THEN ISNULL(@Alt4, N'')
            WHEN 5 THEN ISNULL(@Alt5, N'')
            ELSE DESCRIPCION
        END,
        IMAGEURL = CASE ORDEN
            WHEN 1 THEN CASE
                WHEN @QuitarImgAlt1 = 1 THEN NULL
                WHEN @ImgAlt1 IS NOT NULL AND LTRIM(RTRIM(@ImgAlt1)) <> '' THEN @ImgAlt1
                ELSE IMAGEURL END
            WHEN 2 THEN CASE
                WHEN @QuitarImgAlt2 = 1 THEN NULL
                WHEN @ImgAlt2 IS NOT NULL AND LTRIM(RTRIM(@ImgAlt2)) <> '' THEN @ImgAlt2
                ELSE IMAGEURL END
            WHEN 3 THEN CASE
                WHEN @QuitarImgAlt3 = 1 THEN NULL
                WHEN @ImgAlt3 IS NOT NULL AND LTRIM(RTRIM(@ImgAlt3)) <> '' THEN @ImgAlt3
                ELSE IMAGEURL END
            WHEN 4 THEN CASE
                WHEN @QuitarImgAlt4 = 1 THEN NULL
                WHEN @ImgAlt4 IS NOT NULL AND LTRIM(RTRIM(@ImgAlt4)) <> '' THEN @ImgAlt4
                ELSE IMAGEURL END
            WHEN 5 THEN CASE
                WHEN @QuitarImgAlt5 = 1 THEN NULL
                WHEN @ImgAlt5 IS NOT NULL AND LTRIM(RTRIM(@ImgAlt5)) <> '' THEN @ImgAlt5
                ELSE IMAGEURL END
            ELSE IMAGEURL
        END,
        ESCORRECTA = CASE WHEN ORDEN = @CorrectaOrden THEN 1 ELSE 0 END
    WHERE IDPREGUNTA = @IdPregunta;

    SET @Resultado = 1; SET @Mensaje = 'Pregunta guardada.';
END;
GO

PRINT 'usp_examen_pregunta_guardar: imágenes por alternativa.';
GO
