/* ============================================================================
   AULA: vincular tutor (IDTUTOR) + SPs CRUD
   Ejecutar después de 26_07_2026/21.usp_tutor_crud.sql
   Fecha: 31/07/2026
   ============================================================================ */

IF COL_LENGTH('AULA', 'IDTUTOR') IS NULL
BEGIN
    ALTER TABLE AULA ADD IDTUTOR NVARCHAR(50) NULL;
    ALTER TABLE AULA ADD CONSTRAINT FK_AULA_TUTOR FOREIGN KEY (IDTUTOR) REFERENCES TUTOR(IDTUTOR);
    PRINT 'Columna AULA.IDTUTOR agregada.';
END
GO

IF OBJECT_ID('dbo.usp_aula_listar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_aula_listar;
GO
CREATE PROCEDURE dbo.usp_aula_listar
    @Buscar         NVARCHAR(200) = NULL,
    @Estado         NVARCHAR(50)  = NULL,
    @OrdenarPor     NVARCHAR(50)  = 'NOMBRE',
    @Direccion      NVARCHAR(4)   = 'ASC',
    @Pagina         INT           = 1,
    @TamanioPagina  INT           = 10,
    @TotalRegistros INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    IF @Pagina < 1 SET @Pagina = 1;
    IF @TamanioPagina < 1 SET @TamanioPagina = 10;

    SELECT @TotalRegistros = COUNT(*)
    FROM AULA a
    LEFT JOIN TUTOR t ON t.IDTUTOR = a.IDTUTOR
    WHERE (@Buscar IS NULL OR @Buscar = '' OR
           a.IDAULA LIKE '%' + @Buscar + '%' OR
           a.NOMBRE LIKE '%' + @Buscar + '%' OR
           a.DESCRIPCION LIKE '%' + @Buscar + '%' OR
           ISNULL(t.NOMBRE, '') LIKE '%' + @Buscar + '%')
      AND (@Estado IS NULL OR @Estado = '' OR
           (@Estado = 'Activo' AND a.ACTIVO = 1) OR
           (@Estado = 'Inactivo' AND a.ACTIVO = 0));

    SELECT
        a.IDAULA,
        a.NOMBRE,
        a.DESCRIPCION,
        a.CAPACIDAD,
        a.ENLACEVIRTUAL,
        a.ENLACECUESTIONARIO,
        a.IDTUTOR,
        ISNULL(t.NOMBRE, '') AS TUTOR_NOMBRE,
        CASE WHEN a.ACTIVO = 1 THEN 'Activo' ELSE 'Inactivo' END AS ESTADO
    FROM AULA a
    LEFT JOIN TUTOR t ON t.IDTUTOR = a.IDTUTOR
    WHERE (@Buscar IS NULL OR @Buscar = '' OR
           a.IDAULA LIKE '%' + @Buscar + '%' OR
           a.NOMBRE LIKE '%' + @Buscar + '%' OR
           a.DESCRIPCION LIKE '%' + @Buscar + '%' OR
           ISNULL(t.NOMBRE, '') LIKE '%' + @Buscar + '%')
      AND (@Estado IS NULL OR @Estado = '' OR
           (@Estado = 'Activo' AND a.ACTIVO = 1) OR
           (@Estado = 'Inactivo' AND a.ACTIVO = 0))
    ORDER BY
        CASE WHEN @OrdenarPor = 'IDAULA' AND @Direccion = 'ASC' THEN a.IDAULA END ASC,
        CASE WHEN @OrdenarPor = 'IDAULA' AND @Direccion = 'DESC' THEN a.IDAULA END DESC,
        CASE WHEN @OrdenarPor = 'NOMBRE' AND @Direccion = 'ASC' THEN a.NOMBRE END ASC,
        CASE WHEN @OrdenarPor = 'NOMBRE' AND @Direccion = 'DESC' THEN a.NOMBRE END DESC,
        CASE WHEN @OrdenarPor = 'TUTOR_NOMBRE' AND @Direccion = 'ASC' THEN t.NOMBRE END ASC,
        CASE WHEN @OrdenarPor = 'TUTOR_NOMBRE' AND @Direccion = 'DESC' THEN t.NOMBRE END DESC,
        CASE WHEN @OrdenarPor = 'CAPACIDAD' AND @Direccion = 'ASC' THEN a.CAPACIDAD END ASC,
        CASE WHEN @OrdenarPor = 'CAPACIDAD' AND @Direccion = 'DESC' THEN a.CAPACIDAD END DESC,
        CASE WHEN @OrdenarPor = 'ESTADO' AND @Direccion = 'ASC' THEN a.ACTIVO END ASC,
        CASE WHEN @OrdenarPor = 'ESTADO' AND @Direccion = 'DESC' THEN a.ACTIVO END DESC,
        a.NOMBRE
    OFFSET (@Pagina - 1) * @TamanioPagina ROWS
    FETCH NEXT @TamanioPagina ROWS ONLY;
END;
GO

IF OBJECT_ID('dbo.usp_aula_obtener', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_aula_obtener;
GO
CREATE PROCEDURE dbo.usp_aula_obtener @Id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        a.IDAULA, a.NOMBRE, a.DESCRIPCION, a.CAPACIDAD,
        a.ENLACEVIRTUAL, a.ENLACECUESTIONARIO, a.IDTUTOR,
        ISNULL(t.NOMBRE, '') AS TUTOR_NOMBRE,
        CASE WHEN a.ACTIVO = 1 THEN 'Activo' ELSE 'Inactivo' END AS ESTADO
    FROM AULA a
    LEFT JOIN TUTOR t ON t.IDTUTOR = a.IDTUTOR
    WHERE a.IDAULA = @Id;
END;
GO

IF OBJECT_ID('dbo.usp_aula_insertar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_aula_insertar;
GO
CREATE PROCEDURE dbo.usp_aula_insertar
    @Id                 NVARCHAR(50),
    @Nombre             NVARCHAR(100),
    @Descripcion        NVARCHAR(MAX) = NULL,
    @Capacidad          INT = NULL,
    @EnlaceVirtual      NVARCHAR(255) = NULL,
    @EnlaceCuestionario NVARCHAR(255) = NULL,
    @IdTutor            NVARCHAR(50)  = NULL,
    @Estado             NVARCHAR(50),
    @Resultado          INT OUTPUT,
    @Mensaje            NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    IF @Id IS NULL OR LTRIM(RTRIM(@Id)) = '' BEGIN SET @Resultado = 0; SET @Mensaje = 'Ingresa el código del aula.'; RETURN; END
    IF @Nombre IS NULL OR LTRIM(RTRIM(@Nombre)) = '' BEGIN SET @Resultado = 0; SET @Mensaje = 'Ingresa el nombre del aula.'; RETURN; END
    IF EXISTS (SELECT 1 FROM AULA WHERE IDAULA = @Id) BEGIN SET @Resultado = 0; SET @Mensaje = 'El código de aula ya existe.'; RETURN; END
    IF EXISTS (SELECT 1 FROM AULA WHERE NOMBRE = @Nombre) BEGIN SET @Resultado = 0; SET @Mensaje = 'Ya existe un aula con ese nombre.'; RETURN; END
    IF @IdTutor IS NOT NULL AND LTRIM(RTRIM(@IdTutor)) <> ''
       AND NOT EXISTS (SELECT 1 FROM TUTOR WHERE IDTUTOR = @IdTutor AND ACTIVO = 1)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El tutor seleccionado no es válido.'; RETURN; END

    INSERT INTO AULA (IDAULA, NOMBRE, DESCRIPCION, CAPACIDAD, ACTIVO, ENLACEVIRTUAL, ENLACECUESTIONARIO, IDTUTOR)
    VALUES (@Id, @Nombre, @Descripcion, @Capacidad,
            CASE WHEN @Estado = 'Activo' THEN 1 ELSE 0 END,
            @EnlaceVirtual, @EnlaceCuestionario, NULLIF(LTRIM(RTRIM(@IdTutor)), ''));

    SET @Resultado = 1; SET @Mensaje = 'Aula registrada.';
END;
GO

IF OBJECT_ID('dbo.usp_aula_actualizar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_aula_actualizar;
GO
CREATE PROCEDURE dbo.usp_aula_actualizar
    @Id                 NVARCHAR(50),
    @Nombre             NVARCHAR(100),
    @Descripcion        NVARCHAR(MAX) = NULL,
    @Capacidad          INT = NULL,
    @EnlaceVirtual      NVARCHAR(255) = NULL,
    @EnlaceCuestionario NVARCHAR(255) = NULL,
    @IdTutor            NVARCHAR(50)  = NULL,
    @Estado             NVARCHAR(50),
    @Resultado          INT OUTPUT,
    @Mensaje            NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM AULA WHERE IDAULA = @Id) BEGIN SET @Resultado = 0; SET @Mensaje = 'El aula no existe.'; RETURN; END
    IF @Nombre IS NULL OR LTRIM(RTRIM(@Nombre)) = '' BEGIN SET @Resultado = 0; SET @Mensaje = 'Ingresa el nombre del aula.'; RETURN; END
    IF EXISTS (SELECT 1 FROM AULA WHERE NOMBRE = @Nombre AND IDAULA <> @Id) BEGIN SET @Resultado = 0; SET @Mensaje = 'Ya existe un aula con ese nombre.'; RETURN; END
    IF @IdTutor IS NOT NULL AND LTRIM(RTRIM(@IdTutor)) <> ''
       AND NOT EXISTS (SELECT 1 FROM TUTOR WHERE IDTUTOR = @IdTutor AND ACTIVO = 1)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El tutor seleccionado no es válido.'; RETURN; END

    UPDATE AULA SET
        NOMBRE = @Nombre, DESCRIPCION = @Descripcion, CAPACIDAD = @Capacidad,
        ENLACEVIRTUAL = @EnlaceVirtual, ENLACECUESTIONARIO = @EnlaceCuestionario,
        IDTUTOR = NULLIF(LTRIM(RTRIM(@IdTutor)), ''),
        ACTIVO = CASE WHEN @Estado = 'Activo' THEN 1 ELSE 0 END
    WHERE IDAULA = @Id;

    SET @Resultado = 1; SET @Mensaje = 'Aula actualizada.';
END;
GO

PRINT 'AULA.IDTUTOR y SPs usp_aula_* actualizados.';
GO
