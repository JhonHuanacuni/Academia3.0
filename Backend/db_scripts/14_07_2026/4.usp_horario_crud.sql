/* ============================================================================
   CRUD HORARIO — Académico
   Prerequisito: 3.horario_tabla.sql
   Fecha: 14/07/2026
   ============================================================================ */

IF OBJECT_ID('dbo.usp_horario_listar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_horario_listar;
GO
CREATE PROCEDURE dbo.usp_horario_listar
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
    FROM HORARIO h
    WHERE (@Buscar IS NULL OR @Buscar = '' OR
           h.IDHORARIO   LIKE '%' + @Buscar + '%' OR
           h.TITULO      LIKE '%' + @Buscar + '%' OR
           h.DESCRIPCION LIKE '%' + @Buscar + '%')
      AND (@Estado IS NULL OR @Estado = '' OR h.ESTADO = @Estado);

    SELECT
        h.IDHORARIO,
        h.TITULO,
        h.DESCRIPCION,
        h.FECHASUBIDA,
        h.ESTADO,
        h.URLIMAGEN
    FROM HORARIO h
    WHERE (@Buscar IS NULL OR @Buscar = '' OR
           h.IDHORARIO   LIKE '%' + @Buscar + '%' OR
           h.TITULO      LIKE '%' + @Buscar + '%' OR
           h.DESCRIPCION LIKE '%' + @Buscar + '%')
      AND (@Estado IS NULL OR @Estado = '' OR h.ESTADO = @Estado)
    ORDER BY
        CASE WHEN @OrdenarPor = 'IDHORARIO'   AND @Direccion = 'ASC'  THEN h.IDHORARIO END ASC,
        CASE WHEN @OrdenarPor = 'IDHORARIO'   AND @Direccion = 'DESC' THEN h.IDHORARIO END DESC,
        CASE WHEN @OrdenarPor = 'TITULO'      AND @Direccion = 'ASC'  THEN h.TITULO END ASC,
        CASE WHEN @OrdenarPor = 'TITULO'      AND @Direccion = 'DESC' THEN h.TITULO END DESC,
        CASE WHEN @OrdenarPor = 'FECHASUBIDA' AND @Direccion = 'ASC'  THEN h.FECHASUBIDA END ASC,
        CASE WHEN @OrdenarPor = 'FECHASUBIDA' AND @Direccion = 'DESC' THEN h.FECHASUBIDA END DESC,
        CASE WHEN @OrdenarPor = 'ESTADO'      AND @Direccion = 'ASC'  THEN h.ESTADO END ASC,
        CASE WHEN @OrdenarPor = 'ESTADO'      AND @Direccion = 'DESC' THEN h.ESTADO END DESC,
        h.FECHASUBIDA DESC, h.IDHORARIO DESC
    OFFSET (@Pagina - 1) * @TamanioPagina ROWS
    FETCH NEXT @TamanioPagina ROWS ONLY;
END;
GO

IF OBJECT_ID('dbo.usp_horario_obtener', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_horario_obtener;
GO
CREATE PROCEDURE dbo.usp_horario_obtener
    @Id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        h.IDHORARIO,
        h.TITULO,
        h.DESCRIPCION,
        h.URLIMAGEN,
        h.FECHASUBIDA,
        h.ESTADO
    FROM HORARIO h
    WHERE h.IDHORARIO = @Id;

    SELECT ha.IDAULA
    FROM HORARIO_AULA ha
    WHERE ha.IDHORARIO = @Id
    ORDER BY ha.IDAULA;
END;
GO

IF OBJECT_ID('dbo.usp_horario_insertar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_horario_insertar;
GO
CREATE PROCEDURE dbo.usp_horario_insertar
    @Titulo       NVARCHAR(200),
    @Descripcion  NVARCHAR(MAX)  = NULL,
    @UrlImagen    NVARCHAR(255)  = NULL,
    @FechaSubida  CHAR(8)        = NULL,
    @Estado       NVARCHAR(50)   = 'Activo',
    @AulasCsv     NVARCHAR(MAX)  = NULL,
    @IdGenerado   NVARCHAR(50) OUTPUT,
    @Resultado    INT OUTPUT,
    @Mensaje      NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @IdGenerado = NULL;

    IF @Titulo IS NULL OR LTRIM(RTRIM(@Titulo)) = ''
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'Ingresa el título del horario.';
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
    SELECT @NextNum = ISNULL(MAX(TRY_CAST(IDHORARIO AS INT)), 0) + 1 FROM HORARIO;
    SET @IdGenerado = CAST(@NextNum AS NVARCHAR(50));

    BEGIN TRY
        BEGIN TRAN;

        INSERT INTO HORARIO (IDHORARIO, TITULO, DESCRIPCION, URLIMAGEN, FECHASUBIDA, ESTADO)
        VALUES (@IdGenerado, @Titulo, @Descripcion, @UrlImagen, @FechaSubida, @Estado);

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
                    INSERT INTO HORARIO_AULA (IDHORARIOAULA, IDHORARIO, IDAULA)
                    VALUES (@IdGenerado + '-A' + RIGHT('000' + CAST(@seq AS VARCHAR(3)), 3), @IdGenerado, @token);
                    SET @seq = @seq + 1;
                END
                SET @pos = @next + 1;
            END
        END

        COMMIT TRAN;
        SET @Resultado = 1; SET @Mensaje = 'Horario registrado.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        SET @IdGenerado = NULL;
        SET @Resultado = 0;
        SET @Mensaje = LEFT(ERROR_MESSAGE(), 200);
    END CATCH
END;
GO

IF OBJECT_ID('dbo.usp_horario_actualizar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_horario_actualizar;
GO
CREATE PROCEDURE dbo.usp_horario_actualizar
    @Id           NVARCHAR(50),
    @Titulo       NVARCHAR(200),
    @Descripcion  NVARCHAR(MAX)  = NULL,
    @UrlImagen    NVARCHAR(255)  = NULL,
    @Estado       NVARCHAR(50)   = 'Activo',
    @AulasCsv     NVARCHAR(MAX)  = NULL,
    @Resultado    INT OUTPUT,
    @Mensaje      NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM HORARIO WHERE IDHORARIO = @Id)
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'El horario no existe.';
        RETURN;
    END

    IF @Titulo IS NULL OR LTRIM(RTRIM(@Titulo)) = ''
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'Ingresa el título del horario.';
        RETURN;
    END

    IF @Estado IS NULL OR LTRIM(RTRIM(@Estado)) = ''
        SET @Estado = 'Activo';

    BEGIN TRY
        BEGIN TRAN;

        UPDATE HORARIO SET
            TITULO = @Titulo,
            DESCRIPCION = @Descripcion,
            URLIMAGEN = CASE
                WHEN @UrlImagen IS NOT NULL AND LTRIM(RTRIM(@UrlImagen)) <> ''
                THEN @UrlImagen ELSE URLIMAGEN END,
            ESTADO = @Estado
        WHERE IDHORARIO = @Id;

        DELETE FROM HORARIO_AULA WHERE IDHORARIO = @Id;

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
                    INSERT INTO HORARIO_AULA (IDHORARIOAULA, IDHORARIO, IDAULA)
                    VALUES (@Id + '-A' + RIGHT('000' + CAST(@seq AS VARCHAR(3)), 3), @Id, @token);
                    SET @seq = @seq + 1;
                END
                SET @pos = @next + 1;
            END
        END

        COMMIT TRAN;
        SET @Resultado = 1; SET @Mensaje = 'Horario actualizado.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        SET @Resultado = 0;
        SET @Mensaje = LEFT(ERROR_MESSAGE(), 200);
    END CATCH
END;
GO

IF OBJECT_ID('dbo.usp_horario_eliminar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_horario_eliminar;
GO
CREATE PROCEDURE dbo.usp_horario_eliminar
    @Id        NVARCHAR(50),
    @Resultado INT OUTPUT,
    @Mensaje   NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM HORARIO WHERE IDHORARIO = @Id)
    BEGIN
        SET @Resultado = 0; SET @Mensaje = 'El horario no existe.';
        RETURN;
    END

    BEGIN TRY
        BEGIN TRAN;
        DELETE FROM HORARIO_AULA WHERE IDHORARIO = @Id;
        DELETE FROM HORARIO WHERE IDHORARIO = @Id;
        COMMIT TRAN;
        SET @Resultado = 1; SET @Mensaje = 'Horario eliminado.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        SET @Resultado = 0;
        SET @Mensaje = LEFT(ERROR_MESSAGE(), 200);
    END CATCH
END;
GO

PRINT 'SPs usp_horario_* creados.';
GO
