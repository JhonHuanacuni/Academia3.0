/* ============================================================================
   CRUD EXAMEN + preguntas + distribución
   Ejecutar después de 1.examen_tablas_plantilla.sql
   Fecha: 17/07/2026
   ============================================================================ */

IF OBJECT_ID('dbo.usp_examen_listar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_examen_listar;
GO
CREATE PROCEDURE dbo.usp_examen_listar
    @Buscar         NVARCHAR(200) = NULL,
    @OrdenarPor     NVARCHAR(50)  = 'FECHAINICIO',
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
    FROM EXAMEN e
    WHERE (@Buscar IS NULL OR @Buscar = '' OR
           e.IDEXAMEN LIKE '%' + @Buscar + '%' OR
           e.TITULO LIKE '%' + @Buscar + '%' OR
           ISNULL(e.DESCRIPCION, '') LIKE '%' + @Buscar + '%');

    SELECT
        e.IDEXAMEN,
        e.TITULO,
        e.DESCRIPCION,
        e.TIPO,
        e.DURACIONMIN,
        e.FECHAINICIO,
        e.FECHAFIN,
        e.HORAINICIO,
        e.HORAFIN,
        e.VISIBLE,
        ISNULL(e.TODASLASULA, 1) AS TODASLASULA,
        e.IDUSUARIO,
        (SELECT COUNT(*) FROM PREGUNTA p WHERE p.IDEXAMEN = e.IDEXAMEN) AS CANTPREGUNTAS
    FROM EXAMEN e
    WHERE (@Buscar IS NULL OR @Buscar = '' OR
           e.IDEXAMEN LIKE '%' + @Buscar + '%' OR
           e.TITULO LIKE '%' + @Buscar + '%' OR
           ISNULL(e.DESCRIPCION, '') LIKE '%' + @Buscar + '%')
    ORDER BY
        CASE WHEN @OrdenarPor = 'TITULO' AND @Direccion = 'ASC'  THEN e.TITULO END ASC,
        CASE WHEN @OrdenarPor = 'TITULO' AND @Direccion = 'DESC' THEN e.TITULO END DESC,
        CASE WHEN @OrdenarPor = 'TIPO' AND @Direccion = 'ASC'  THEN e.TIPO END ASC,
        CASE WHEN @OrdenarPor = 'TIPO' AND @Direccion = 'DESC' THEN e.TIPO END DESC,
        CASE WHEN @OrdenarPor = 'FECHAINICIO' AND @Direccion = 'ASC'  THEN e.FECHAINICIO END ASC,
        CASE WHEN @OrdenarPor = 'FECHAINICIO' AND @Direccion = 'DESC' THEN e.FECHAINICIO END DESC,
        e.IDEXAMEN DESC
    OFFSET (@Pagina - 1) * @TamanioPagina ROWS
    FETCH NEXT @TamanioPagina ROWS ONLY;
END;
GO

IF OBJECT_ID('dbo.usp_examen_obtener', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_examen_obtener;
GO
CREATE PROCEDURE dbo.usp_examen_obtener
    @Id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        e.IDEXAMEN,
        e.TITULO,
        e.DESCRIPCION,
        e.TIPO,
        e.DURACIONMIN,
        e.PUNTAJETOTAL,
        e.PUNTAJEAPROBADO,
        e.FECHAINICIO,
        e.FECHAFIN,
        e.HORAINICIO,
        e.HORAFIN,
        e.TIEMPOLIMITE,
        e.INTENTOSMAX,
        e.VISIBLE,
        ISNULL(e.TODASLASULA, 1) AS TODASLASULA,
        e.IDUSUARIO
    FROM EXAMEN e
    WHERE e.IDEXAMEN = @Id;

    SELECT ea.IDAULA
    FROM EXAMEN_AULA ea
    WHERE ea.IDEXAMEN = @Id
    ORDER BY ea.IDAULA;

    SELECT
        p.IDPREGUNTA,
        p.TITULO,
        p.DESCRIPCION,
        p.PUNTAJE,
        p.ORDEN,
        p.IMAGEURL,
        p.IDMATERIA,
        m.CODIGO AS MATERIA_CODIGO,
        m.NOMBRE AS MATERIA_NOMBRE,
        c.IDCATEGORIA,
        c.NOMBRE AS CATEGORIA_NOMBRE
    FROM PREGUNTA p
    LEFT JOIN MATERIA m ON m.IDMATERIA = p.IDMATERIA
    LEFT JOIN CATEGORIA c ON c.IDCATEGORIA = m.IDCATEGORIA
    WHERE p.IDEXAMEN = @Id
    ORDER BY p.ORDEN, p.IDPREGUNTA;
END;
GO

IF OBJECT_ID('dbo.usp_examen_pregunta_detalle', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_examen_pregunta_detalle;
GO
CREATE PROCEDURE dbo.usp_examen_pregunta_detalle
    @IdExamen   NVARCHAR(50),
    @IdPregunta NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.IDPREGUNTA,
        p.TITULO,
        p.DESCRIPCION,
        p.PUNTAJE,
        p.ORDEN,
        p.IMAGEURL,
        p.IDEXAMEN,
        p.IDMATERIA,
        m.CODIGO AS MATERIA_CODIGO,
        m.NOMBRE AS MATERIA_NOMBRE
    FROM PREGUNTA p
    LEFT JOIN MATERIA m ON m.IDMATERIA = p.IDMATERIA
    WHERE p.IDEXAMEN = @IdExamen AND p.IDPREGUNTA = @IdPregunta;

    SELECT
        a.IDALTERNATIVA,
        a.DESCRIPCION,
        a.ESCORRECTA,
        a.ORDEN,
        a.IMAGEURL
    FROM ALTERNATIVA a
    WHERE a.IDPREGUNTA = @IdPregunta
    ORDER BY a.ORDEN, a.IDALTERNATIVA;
END;
GO

IF OBJECT_ID('dbo.usp_examen_distribucion', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_examen_distribucion;
GO
CREATE PROCEDURE dbo.usp_examen_distribucion
    @Tipo     INT = NULL,
    @IdExamen NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @IdExamen IS NOT NULL AND LTRIM(RTRIM(@IdExamen)) <> ''
    BEGIN
        SELECT
            c.IDCATEGORIA,
            c.NOMBRE AS CATEGORIA_NOMBRE,
            c.PORCENTAJE,
            c.ORDEN AS CATEGORIA_ORDEN,
            COUNT(DISTINCT m.IDMATERIA) AS AREAS,
            COUNT(p.IDPREGUNTA) AS TOTALPREGUNTAS
        FROM PREGUNTA p
        INNER JOIN MATERIA m ON m.IDMATERIA = p.IDMATERIA
        INNER JOIN CATEGORIA c ON c.IDCATEGORIA = m.IDCATEGORIA
        WHERE p.IDEXAMEN = @IdExamen
        GROUP BY c.IDCATEGORIA, c.NOMBRE, c.PORCENTAJE, c.ORDEN
        ORDER BY c.ORDEN, c.NOMBRE;

        SELECT
            c.IDCATEGORIA,
            m.IDMATERIA,
            m.CODIGO,
            m.NOMBRE AS MATERIA_NOMBRE,
            COUNT(p.IDPREGUNTA) AS CANTIDAD
        FROM PREGUNTA p
        INNER JOIN MATERIA m ON m.IDMATERIA = p.IDMATERIA
        INNER JOIN CATEGORIA c ON c.IDCATEGORIA = m.IDCATEGORIA
        WHERE p.IDEXAMEN = @IdExamen
        GROUP BY c.IDCATEGORIA, m.IDMATERIA, m.CODIGO, m.NOMBRE, c.ORDEN, m.CODIGO
        ORDER BY c.ORDEN, m.CODIGO;
        RETURN;
    END

    IF @Tipo IS NULL SET @Tipo = 40;

    SELECT
        c.IDCATEGORIA,
        c.NOMBRE AS CATEGORIA_NOMBRE,
        c.PORCENTAJE,
        c.ORDEN AS CATEGORIA_ORDEN,
        COUNT(DISTINCT m.IDMATERIA) AS AREAS,
        SUM(pl.CANTIDAD) AS TOTALPREGUNTAS
    FROM EXAMEN_PLANTILLA pl
    INNER JOIN MATERIA m ON m.CODIGO = pl.CODIGOMATERIA
    INNER JOIN CATEGORIA c ON c.IDCATEGORIA = m.IDCATEGORIA
    WHERE pl.TIPO = @Tipo
    GROUP BY c.IDCATEGORIA, c.NOMBRE, c.PORCENTAJE, c.ORDEN
    ORDER BY c.ORDEN, c.NOMBRE;

    SELECT
        c.IDCATEGORIA,
        m.IDMATERIA,
        m.CODIGO,
        m.NOMBRE AS MATERIA_NOMBRE,
        pl.CANTIDAD
    FROM EXAMEN_PLANTILLA pl
    INNER JOIN MATERIA m ON m.CODIGO = pl.CODIGOMATERIA
    INNER JOIN CATEGORIA c ON c.IDCATEGORIA = m.IDCATEGORIA
    WHERE pl.TIPO = @Tipo
    ORDER BY c.ORDEN, m.CODIGO;
END;
GO

IF OBJECT_ID('dbo.usp_examen_insertar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_examen_insertar;
GO
CREATE PROCEDURE dbo.usp_examen_insertar
    @Titulo       NVARCHAR(200),
    @Descripcion  NVARCHAR(MAX) = NULL,
    @Tipo         INT           = 40,
    @DuracionMin  INT           = 120,
    @FechaInicio  CHAR(8)       = NULL,
    @FechaFin     CHAR(8)       = NULL,
    @HoraInicio   CHAR(8)       = NULL,
    @HoraFin      CHAR(8)       = NULL,
    @Visible      BIT           = 1,
    @TodasLasAula BIT           = 1,
    @IdUsuario    NVARCHAR(50),
    @AulasCsv     NVARCHAR(MAX) = NULL,
    @IdGenerado   NVARCHAR(50) OUTPUT,
    @Resultado    INT OUTPUT,
    @Mensaje      NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @IdGenerado = NULL;

    IF @Titulo IS NULL OR LTRIM(RTRIM(@Titulo)) = ''
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ingresa el título del examen.'; RETURN; END

    IF @IdUsuario IS NULL OR LTRIM(RTRIM(@IdUsuario)) = ''
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Usuario creador no válido.'; RETURN; END

    IF @Tipo NOT IN (40, 100) SET @Tipo = 40;

    IF NOT EXISTS (SELECT 1 FROM EXAMEN_PLANTILLA WHERE TIPO = @Tipo)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'No hay plantilla de distribución para ese tipo.'; RETURN; END

    IF EXISTS (
        SELECT 1 FROM EXAMEN_PLANTILLA pl
        WHERE pl.TIPO = @Tipo
          AND NOT EXISTS (SELECT 1 FROM MATERIA m WHERE m.CODIGO = pl.CODIGOMATERIA)
    )
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Faltan materias de la plantilla. Revisa el mantenedor de materias.'; RETURN; END

    DECLARE @NextNum INT;
    SELECT @NextNum = ISNULL(MAX(TRY_CAST(REPLACE(IDEXAMEN, 'EXA', '') AS INT)), 0) + 1
    FROM EXAMEN WHERE IDEXAMEN LIKE 'EXA%';
    SET @IdGenerado = 'EXA' + RIGHT('000' + CAST(@NextNum AS VARCHAR(3)), 3);

    INSERT INTO EXAMEN (
        IDEXAMEN, TITULO, DESCRIPCION, TIPO, DURACIONMIN,
        FECHAINICIO, FECHAFIN, HORAINICIO, HORAFIN,
        INTENTOSMAX, VISIBLE, TODASLASULA, IDUSUARIO
    )
    VALUES (
        @IdGenerado, @Titulo, @Descripcion, @Tipo, @DuracionMin,
        @FechaInicio, @FechaFin, @HoraInicio, @HoraFin,
        1, @Visible, @TodasLasAula, @IdUsuario
    );

    IF @TodasLasAula = 0 AND @AulasCsv IS NOT NULL AND LTRIM(RTRIM(@AulasCsv)) <> ''
    BEGIN
        INSERT INTO EXAMEN_AULA (IDEXAMENAULA, IDEXAMEN, IDAULA)
        SELECT
            'EXAUL' + REPLACE(CONVERT(NVARCHAR(36), NEWID()), '-', ''),
            @IdGenerado,
            LTRIM(RTRIM(value))
        FROM STRING_SPLIT(@AulasCsv, ',')
        WHERE LTRIM(RTRIM(value)) <> '';
    END

    DECLARE @Orden INT = 0;
    DECLARE @Codigo NVARCHAR(50), @Cant INT, @IdMateria NVARCHAR(50);
    DECLARE @i INT, @IdPreg NVARCHAR(50), @PregNum INT;
    DECLARE @AltOrd INT, @Letra CHAR(1);

    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
        SELECT pl.CODIGOMATERIA, pl.CANTIDAD, m.IDMATERIA
        FROM EXAMEN_PLANTILLA pl
        INNER JOIN MATERIA m ON m.CODIGO = pl.CODIGOMATERIA
        INNER JOIN CATEGORIA c ON c.IDCATEGORIA = m.IDCATEGORIA
        WHERE pl.TIPO = @Tipo
        ORDER BY c.ORDEN, m.CODIGO;

    OPEN cur;
    FETCH NEXT FROM cur INTO @Codigo, @Cant, @IdMateria;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @i = 1;
        WHILE @i <= @Cant
        BEGIN
            SET @Orden = @Orden + 1;
            SET @IdPreg = @IdGenerado + '_P' + RIGHT('000' + CAST(@Orden AS VARCHAR(3)), 3);

            INSERT INTO PREGUNTA (IDPREGUNTA, TITULO, DESCRIPCION, PUNTAJE, ORDEN, IMAGEURL, IDEXAMEN, IDMATERIA)
            VALUES (
                @IdPreg,
                N'Pregunta ' + CAST(@Orden AS NVARCHAR(10)),
                NULL,
                1,
                @Orden,
                NULL,
                @IdGenerado,
                @IdMateria
            );

            SET @AltOrd = 1;
            WHILE @AltOrd <= 5
            BEGIN
                SET @Letra = CHAR(64 + @AltOrd); -- A=65
                INSERT INTO ALTERNATIVA (IDALTERNATIVA, DESCRIPCION, ESCORRECTA, ORDEN, IMAGEURL, IDPREGUNTA)
                VALUES (
                    @IdPreg + '_A' + CAST(@AltOrd AS VARCHAR(1)),
                    N'',
                    CASE WHEN @AltOrd = 1 THEN 1 ELSE 0 END,
                    @AltOrd,
                    NULL,
                    @IdPreg
                );
                SET @AltOrd = @AltOrd + 1;
            END

            SET @i = @i + 1;
        END
        FETCH NEXT FROM cur INTO @Codigo, @Cant, @IdMateria;
    END
    CLOSE cur;
    DEALLOCATE cur;

    SET @Resultado = 1;
    SET @Mensaje = 'Examen creado con ' + CAST(@Orden AS NVARCHAR(10)) + ' preguntas.';
END;
GO

IF OBJECT_ID('dbo.usp_examen_actualizar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_examen_actualizar;
GO
CREATE PROCEDURE dbo.usp_examen_actualizar
    @Id           NVARCHAR(50),
    @Titulo       NVARCHAR(200),
    @Descripcion  NVARCHAR(MAX) = NULL,
    @DuracionMin  INT           = 120,
    @FechaInicio  CHAR(8)       = NULL,
    @FechaFin     CHAR(8)       = NULL,
    @HoraInicio   CHAR(8)       = NULL,
    @HoraFin      CHAR(8)       = NULL,
    @Visible      BIT           = 1,
    @TodasLasAula BIT           = 1,
    @AulasCsv     NVARCHAR(MAX) = NULL,
    @Resultado    INT OUTPUT,
    @Mensaje      NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM EXAMEN WHERE IDEXAMEN = @Id)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El examen no existe.'; RETURN; END

    IF @Titulo IS NULL OR LTRIM(RTRIM(@Titulo)) = ''
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ingresa el título del examen.'; RETURN; END

    UPDATE EXAMEN SET
        TITULO = @Titulo,
        DESCRIPCION = @Descripcion,
        DURACIONMIN = @DuracionMin,
        FECHAINICIO = @FechaInicio,
        FECHAFIN = @FechaFin,
        HORAINICIO = @HoraInicio,
        HORAFIN = @HoraFin,
        VISIBLE = @Visible,
        TODASLASULA = @TodasLasAula
    WHERE IDEXAMEN = @Id;

    DELETE FROM EXAMEN_AULA WHERE IDEXAMEN = @Id;

    IF @TodasLasAula = 0 AND @AulasCsv IS NOT NULL AND LTRIM(RTRIM(@AulasCsv)) <> ''
    BEGIN
        INSERT INTO EXAMEN_AULA (IDEXAMENAULA, IDEXAMEN, IDAULA)
        SELECT
            'EXAUL' + REPLACE(CONVERT(NVARCHAR(36), NEWID()), '-', ''),
            @Id,
            LTRIM(RTRIM(value))
        FROM STRING_SPLIT(@AulasCsv, ',')
        WHERE LTRIM(RTRIM(value)) <> '';
    END

    SET @Resultado = 1; SET @Mensaje = 'Examen actualizado.';
END;
GO

IF OBJECT_ID('dbo.usp_examen_eliminar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_examen_eliminar;
GO
CREATE PROCEDURE dbo.usp_examen_eliminar
    @Id        NVARCHAR(50),
    @Resultado INT OUTPUT,
    @Mensaje   NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM EXAMEN WHERE IDEXAMEN = @Id)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El examen no existe.'; RETURN; END

    IF EXISTS (SELECT 1 FROM INTENTO_EXAMEN WHERE IDEXAMEN = @Id)
    BEGIN
        SET @Resultado = 0;
        SET @Mensaje = 'No se puede eliminar: hay intentos de estudiantes.';
        RETURN;
    END

    DELETE FROM ALTERNATIVA
    WHERE IDPREGUNTA IN (SELECT IDPREGUNTA FROM PREGUNTA WHERE IDEXAMEN = @Id);

    DELETE FROM PREGUNTA WHERE IDEXAMEN = @Id;
    DELETE FROM EXAMEN_AULA WHERE IDEXAMEN = @Id;
    DELETE FROM EXAMEN WHERE IDEXAMEN = @Id;

    SET @Resultado = 1; SET @Mensaje = 'Examen eliminado.';
END;
GO

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
        ESCORRECTA = CASE WHEN ORDEN = @CorrectaOrden THEN 1 ELSE 0 END
    WHERE IDPREGUNTA = @IdPregunta;

    SET @Resultado = 1; SET @Mensaje = 'Pregunta guardada.';
END;
GO

PRINT 'SPs usp_examen_* creados.';
GO
