/* ============================================================================
   CRUD LIBRO — Biblioteca (Académico)
   Prerequisito: 1.libro_fechassubida_libro_aula.sql
   Fecha: 14/07/2026
   ============================================================================ */

IF OBJECT_ID('dbo.usp_libro_listar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_libro_listar;
GO
CREATE PROCEDURE dbo.usp_libro_listar
    @Buscar         NVARCHAR(200) = NULL,
    @Estado         NVARCHAR(50)  = NULL,
    @OrdenarPor     NVARCHAR(50)  = 'FECHASUBIDA',
    @Direccion      NVARCHAR(4)   = 'DESC',
    @Pagina         INT           = 1,
    @TamanioPagina  INT           = 10,
    @TotalRegistros INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF @Pagina < 1 SET @Pagina = 1;
    IF @TamanioPagina < 1 SET @TamanioPagina = 10;

    SELECT @TotalRegistros = COUNT(*)
    FROM LIBRO l
    WHERE (@Buscar IS NULL OR @Buscar = '' OR
           l.IDLIBRO    LIKE '%' + @Buscar + '%' OR
           l.TITULO     LIKE '%' + @Buscar + '%' OR
           l.DESCRIPCION LIKE '%' + @Buscar + '%')
      AND (@Estado IS NULL OR @Estado = '' OR l.ESTADO = @Estado);

    SELECT
        l.IDLIBRO,
        l.TITULO,
        l.DESCRIPCION,
        l.FECHASUBIDA,
        l.ESTADO,
        l.URLCONTENIDO,
        l.IMGPORTADA
    FROM LIBRO l
    WHERE (@Buscar IS NULL OR @Buscar = '' OR
           l.IDLIBRO    LIKE '%' + @Buscar + '%' OR
           l.TITULO     LIKE '%' + @Buscar + '%' OR
           l.DESCRIPCION LIKE '%' + @Buscar + '%')
      AND (@Estado IS NULL OR @Estado = '' OR l.ESTADO = @Estado)
    ORDER BY
        CASE WHEN @OrdenarPor = 'IDLIBRO'     AND @Direccion = 'ASC'  THEN l.IDLIBRO END ASC,
        CASE WHEN @OrdenarPor = 'IDLIBRO'     AND @Direccion = 'DESC' THEN l.IDLIBRO END DESC,
        CASE WHEN @OrdenarPor = 'TITULO'      AND @Direccion = 'ASC'  THEN l.TITULO END ASC,
        CASE WHEN @OrdenarPor = 'TITULO'      AND @Direccion = 'DESC' THEN l.TITULO END DESC,
        CASE WHEN @OrdenarPor = 'FECHASUBIDA' AND @Direccion = 'ASC'  THEN l.FECHASUBIDA END ASC,
        CASE WHEN @OrdenarPor = 'FECHASUBIDA' AND @Direccion = 'DESC' THEN l.FECHASUBIDA END DESC,
        CASE WHEN @OrdenarPor = 'ESTADO'      AND @Direccion = 'ASC'  THEN l.ESTADO END ASC,
        CASE WHEN @OrdenarPor = 'ESTADO'      AND @Direccion = 'DESC' THEN l.ESTADO END DESC,
        l.FECHASUBIDA DESC, l.IDLIBRO DESC
    OFFSET (@Pagina - 1) * @TamanioPagina ROWS
    FETCH NEXT @TamanioPagina ROWS ONLY;
END;
GO

IF OBJECT_ID('dbo.usp_libro_obtener', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_libro_obtener;
GO
CREATE PROCEDURE dbo.usp_libro_obtener
    @Id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        l.IDLIBRO,
        l.TITULO,
        l.DESCRIPCION,
        l.AUTOR,
        l.ANIOPUBLICACION,
        l.URLCONTENIDO,
        l.IMGPORTADA,
        l.FECHASUBIDA,
        l.ESTADO
    FROM LIBRO l
    WHERE l.IDLIBRO = @Id;

    SELECT la.IDAULA
    FROM LIBRO_AULA la
    WHERE la.IDLIBRO = @Id
    ORDER BY la.IDAULA;
END;
GO

IF OBJECT_ID('dbo.usp_libro_insertar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_libro_insertar;
GO
CREATE PROCEDURE dbo.usp_libro_insertar
    @Titulo         NVARCHAR(200),
    @Descripcion    NVARCHAR(MAX)  = NULL,
    @UrlContenido   NVARCHAR(255)  = NULL,
    @ImgPortada     NVARCHAR(255)  = NULL,
    @FechaSubida    CHAR(8)        = NULL,
    @Estado         NVARCHAR(50)   = 'Activo',
    @AulasCsv       NVARCHAR(MAX)  = NULL,  -- IDAULA separados por coma
    @IdGenerado     NVARCHAR(50) OUTPUT,
    @Resultado      INT OUTPUT,
    @Mensaje        NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @IdGenerado = NULL;

    IF @Titulo IS NULL OR LTRIM(RTRIM(@Titulo)) = ''
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'Ingresa el título del documento.';
        RETURN;
    END

    IF @Estado IS NULL OR LTRIM(RTRIM(@Estado)) = ''
        SET @Estado = 'Activo';

    IF @FechaSubida IS NULL OR LTRIM(RTRIM(@FechaSubida)) = '' OR LEN(@FechaSubida) <> 8
        SET @FechaSubida =
            RIGHT('0' + CAST(DAY(GETDATE()) AS VARCHAR(2)), 2) +
            RIGHT('0' + CAST(MONTH(GETDATE()) AS VARCHAR(2)), 2) +
            CAST(YEAR(GETDATE()) AS VARCHAR(4));

    DECLARE @NextNum INT;
    SELECT @NextNum = ISNULL(MAX(TRY_CAST(IDLIBRO AS INT)), 0) + 1 FROM LIBRO;
    SET @IdGenerado = CAST(@NextNum AS NVARCHAR(50));

    BEGIN TRY
        BEGIN TRAN;

        INSERT INTO LIBRO (
            IDLIBRO, TITULO, DESCRIPCION, URLCONTENIDO, IMGPORTADA, FECHASUBIDA, ESTADO
        )
        VALUES (
            @IdGenerado, @Titulo, @Descripcion, @UrlContenido, @ImgPortada, @FechaSubida, @Estado
        );

        IF @AulasCsv IS NOT NULL AND LTRIM(RTRIM(@AulasCsv)) <> ''
        BEGIN
            DECLARE @pos INT = 1, @next INT, @token NVARCHAR(50), @seq INT = 1;
            DECLARE @csv NVARCHAR(MAX) = @AulasCsv + ',';

            WHILE @pos <= LEN(@csv)
            BEGIN
                SET @next = CHARINDEX(',', @csv, @pos);
                IF @next = 0 BREAK;
                SET @token = LTRIM(RTRIM(SUBSTRING(@csv, @pos, @next - @pos)));
                IF @token <> '' AND EXISTS (SELECT 1 FROM AULA WHERE IDAULA = @token)
                BEGIN
                    INSERT INTO LIBRO_AULA (IDLIBROAULA, IDLIBRO, IDAULA)
                    VALUES (@IdGenerado + '-A' + RIGHT('000' + CAST(@seq AS VARCHAR(3)), 3), @IdGenerado, @token);
                    SET @seq = @seq + 1;
                END
                SET @pos = @next + 1;
            END
        END

        COMMIT TRAN;
        SET @Resultado = 1; SET @Mensaje = 'Documento registrado.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        SET @IdGenerado = NULL;
        SET @Resultado = 0;
        SET @Mensaje = LEFT(ERROR_MESSAGE(), 200);
    END CATCH
END;
GO

IF OBJECT_ID('dbo.usp_libro_actualizar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_libro_actualizar;
GO
CREATE PROCEDURE dbo.usp_libro_actualizar
    @Id             NVARCHAR(50),
    @Titulo         NVARCHAR(200),
    @Descripcion    NVARCHAR(MAX)  = NULL,
    @UrlContenido   NVARCHAR(255)  = NULL,
    @ImgPortada     NVARCHAR(255)  = NULL,
    @Estado         NVARCHAR(50)   = 'Activo',
    @AulasCsv       NVARCHAR(MAX)  = NULL,
    @Resultado      INT OUTPUT,
    @Mensaje        NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM LIBRO WHERE IDLIBRO = @Id)
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'El documento no existe.';
        RETURN;
    END

    IF @Titulo IS NULL OR LTRIM(RTRIM(@Titulo)) = ''
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'Ingresa el título del documento.';
        RETURN;
    END

    IF @Estado IS NULL OR LTRIM(RTRIM(@Estado)) = ''
        SET @Estado = 'Activo';

    BEGIN TRY
        BEGIN TRAN;

        UPDATE LIBRO SET
            TITULO = @Titulo,
            DESCRIPCION = @Descripcion,
            URLCONTENIDO = CASE
                WHEN @UrlContenido IS NOT NULL AND LTRIM(RTRIM(@UrlContenido)) <> ''
                THEN @UrlContenido ELSE URLCONTENIDO END,
            IMGPORTADA = CASE
                WHEN @ImgPortada IS NOT NULL AND LTRIM(RTRIM(@ImgPortada)) <> ''
                THEN @ImgPortada ELSE IMGPORTADA END,
            ESTADO = @Estado
        WHERE IDLIBRO = @Id;

        DELETE FROM LIBRO_AULA WHERE IDLIBRO = @Id;

        IF @AulasCsv IS NOT NULL AND LTRIM(RTRIM(@AulasCsv)) <> ''
        BEGIN
            DECLARE @pos INT = 1, @next INT, @token NVARCHAR(50), @seq INT = 1;
            DECLARE @csv NVARCHAR(MAX) = @AulasCsv + ',';

            WHILE @pos <= LEN(@csv)
            BEGIN
                SET @next = CHARINDEX(',', @csv, @pos);
                IF @next = 0 BREAK;
                SET @token = LTRIM(RTRIM(SUBSTRING(@csv, @pos, @next - @pos)));
                IF @token <> '' AND EXISTS (SELECT 1 FROM AULA WHERE IDAULA = @token)
                BEGIN
                    INSERT INTO LIBRO_AULA (IDLIBROAULA, IDLIBRO, IDAULA)
                    VALUES (@Id + '-A' + RIGHT('000' + CAST(@seq AS VARCHAR(3)), 3), @Id, @token);
                    SET @seq = @seq + 1;
                END
                SET @pos = @next + 1;
            END
        END

        COMMIT TRAN;
        SET @Resultado = 1; SET @Mensaje = 'Documento actualizado.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        SET @Resultado = 0;
        SET @Mensaje = LEFT(ERROR_MESSAGE(), 200);
    END CATCH
END;
GO

IF OBJECT_ID('dbo.usp_libro_eliminar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_libro_eliminar;
GO
CREATE PROCEDURE dbo.usp_libro_eliminar
    @Id        NVARCHAR(50),
    @Resultado INT OUTPUT,
    @Mensaje   NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM LIBRO WHERE IDLIBRO = @Id)
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'El documento no existe.';
        RETURN;
    END

    BEGIN TRY
        BEGIN TRAN;

        DELETE FROM LIBRO_ACCESO WHERE IDLIBRO = @Id;
        DELETE FROM LIBRO_MATERIA WHERE IDLIBRO = @Id;
        DELETE FROM LIBRO_AULA WHERE IDLIBRO = @Id;
        DELETE FROM LIBRO WHERE IDLIBRO = @Id;

        COMMIT TRAN;
        SET @Resultado = 1; SET @Mensaje = 'Documento eliminado.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        SET @Resultado = 0;
        SET @Mensaje = LEFT(ERROR_MESSAGE(), 200);
    END CATCH
END;
GO

PRINT 'SPs usp_libro_* creados.';
GO
