/* ============================================================================
   PLAN: turno por plan (FK TURNO). Mensualidad hereda turno del plan.
   Ejecutar después de 5.menu_mensualidad_tutor.sql
   Fecha: 26/07/2026
   ============================================================================ */

IF COL_LENGTH('PLAN', 'IDTURNO') IS NULL
BEGIN
    ALTER TABLE [PLAN] ADD IDTURNO NVARCHAR(50) NULL;
    PRINT 'Columna PLAN.IDTURNO agregada.';
END
ELSE
    PRINT 'Columna PLAN.IDTURNO ya existe.';
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_PLAN_TURNO'
)
BEGIN
    ALTER TABLE [PLAN]
        ADD CONSTRAINT FK_PLAN_TURNO FOREIGN KEY (IDTURNO) REFERENCES TURNO(IDTURNO);
    PRINT 'FK PLAN.IDTURNO → TURNO creada.';
END
GO

/* Catálogo Academia Vita: tarde en PLN002 y PLN006; resto mañana */
UPDATE [PLAN] SET IDTURNO = 'TUR002' WHERE IDPLAN IN ('PLN002', 'PLN006');
UPDATE [PLAN] SET IDTURNO = 'TUR001' WHERE IDTURNO IS NULL;
GO

/* Sincronizar mensualidades existentes con el turno del plan */
UPDATE m
SET m.IDTURNO = p.IDTURNO
FROM MENSUALIDAD m
INNER JOIN [PLAN] p ON p.IDPLAN = m.IDPLAN
WHERE p.IDTURNO IS NOT NULL;
GO

/* ---- usp_plan_* ---- */
IF OBJECT_ID('dbo.usp_plan_listar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_plan_listar;
GO
CREATE PROCEDURE dbo.usp_plan_listar
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
    FROM [PLAN] p
    WHERE (@Buscar IS NULL OR @Buscar = '' OR
           p.IDPLAN      LIKE '%' + @Buscar + '%' OR
           p.NOMBRE      LIKE '%' + @Buscar + '%' OR
           p.DESCRIPCION LIKE '%' + @Buscar + '%')
      AND (@Estado IS NULL OR @Estado = '' OR
           (@Estado = 'Activo' AND p.ACTIVO = 1) OR
           (@Estado = 'Inactivo' AND p.ACTIVO = 0));

    SELECT
        p.IDPLAN,
        p.NOMBRE,
        p.DESCRIPCION,
        p.COSTOMENSUAL,
        p.DIASASISTENCIA,
        p.IDTURNO,
        ISNULL(tu.DESCRIPCION, '') AS TURNO_DESCRIPCION,
        CASE WHEN p.ACTIVO = 1 THEN 'Activo' ELSE 'Inactivo' END AS ESTADO
    FROM [PLAN] p
    LEFT JOIN TURNO tu ON tu.IDTURNO = p.IDTURNO
    WHERE (@Buscar IS NULL OR @Buscar = '' OR
           p.IDPLAN      LIKE '%' + @Buscar + '%' OR
           p.NOMBRE      LIKE '%' + @Buscar + '%' OR
           p.DESCRIPCION LIKE '%' + @Buscar + '%')
      AND (@Estado IS NULL OR @Estado = '' OR
           (@Estado = 'Activo' AND p.ACTIVO = 1) OR
           (@Estado = 'Inactivo' AND p.ACTIVO = 0))
    ORDER BY
        CASE WHEN @OrdenarPor = 'IDPLAN' AND @Direccion = 'ASC'  THEN p.IDPLAN END ASC,
        CASE WHEN @OrdenarPor = 'IDPLAN' AND @Direccion = 'DESC' THEN p.IDPLAN END DESC,
        CASE WHEN @OrdenarPor = 'NOMBRE' AND @Direccion = 'ASC'  THEN p.NOMBRE END ASC,
        CASE WHEN @OrdenarPor = 'NOMBRE' AND @Direccion = 'DESC' THEN p.NOMBRE END DESC,
        CASE WHEN @OrdenarPor = 'COSTOMENSUAL' AND @Direccion = 'ASC'  THEN p.COSTOMENSUAL END ASC,
        CASE WHEN @OrdenarPor = 'COSTOMENSUAL' AND @Direccion = 'DESC' THEN p.COSTOMENSUAL END DESC,
        CASE WHEN @OrdenarPor = 'ESTADO' AND @Direccion = 'ASC'  THEN p.ACTIVO END ASC,
        CASE WHEN @OrdenarPor = 'ESTADO' AND @Direccion = 'DESC' THEN p.ACTIVO END DESC,
        p.NOMBRE
    OFFSET (@Pagina - 1) * @TamanioPagina ROWS
    FETCH NEXT @TamanioPagina ROWS ONLY;
END;
GO

IF OBJECT_ID('dbo.usp_plan_obtener', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_plan_obtener;
GO
CREATE PROCEDURE dbo.usp_plan_obtener
    @Id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        p.IDPLAN,
        p.NOMBRE,
        p.DESCRIPCION,
        p.COSTOMENSUAL,
        p.DIASASISTENCIA,
        p.IDTURNO,
        ISNULL(tu.DESCRIPCION, '') AS TURNO_DESCRIPCION,
        CASE WHEN p.ACTIVO = 1 THEN 'Activo' ELSE 'Inactivo' END AS ESTADO
    FROM [PLAN] p
    LEFT JOIN TURNO tu ON tu.IDTURNO = p.IDTURNO
    WHERE p.IDPLAN = @Id;
END;
GO

IF OBJECT_ID('dbo.usp_plan_insertar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_plan_insertar;
GO
CREATE PROCEDURE dbo.usp_plan_insertar
    @Id             NVARCHAR(50),
    @Nombre         NVARCHAR(100),
    @Descripcion    NVARCHAR(255)  = NULL,
    @CostoMensual   DECIMAL(10,2)  = NULL,
    @DiasAsistencia TINYINT        = 63,
    @IdTurno        NVARCHAR(50)   = NULL,
    @Estado         NVARCHAR(50)   = 'Activo',
    @Resultado      INT OUTPUT,
    @Mensaje        NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF @Id IS NULL OR LTRIM(RTRIM(@Id)) = ''
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ingresa el código del plan.'; RETURN; END

    IF @Nombre IS NULL OR LTRIM(RTRIM(@Nombre)) = ''
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ingresa el nombre del plan.'; RETURN; END

    IF @CostoMensual IS NOT NULL AND @CostoMensual < 0
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El costo mensual no puede ser negativo.'; RETURN; END

    IF @DiasAsistencia IS NULL OR @DiasAsistencia = 0
        SET @DiasAsistencia = 63;

    IF @IdTurno IS NOT NULL AND @IdTurno <> ''
       AND NOT EXISTS (SELECT 1 FROM TURNO WHERE IDTURNO = @IdTurno)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El turno seleccionado no es válido.'; RETURN; END

    IF EXISTS (SELECT 1 FROM [PLAN] WHERE IDPLAN = @Id)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El código de plan ya existe.'; RETURN; END

    IF EXISTS (SELECT 1 FROM [PLAN] WHERE NOMBRE = @Nombre)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ya existe un plan con ese nombre.'; RETURN; END

    INSERT INTO [PLAN] (IDPLAN, NOMBRE, DESCRIPCION, COSTOMENSUAL, DIASASISTENCIA, IDTURNO, ACTIVO)
    VALUES (
        @Id,
        @Nombre,
        @Descripcion,
        @CostoMensual,
        @DiasAsistencia,
        NULLIF(@IdTurno, ''),
        CASE WHEN @Estado = 'Activo' THEN 1 ELSE 0 END
    );

    SET @Resultado = 1; SET @Mensaje = 'Plan registrado.';
END;
GO

IF OBJECT_ID('dbo.usp_plan_actualizar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_plan_actualizar;
GO
CREATE PROCEDURE dbo.usp_plan_actualizar
    @Id             NVARCHAR(50),
    @Nombre         NVARCHAR(100),
    @Descripcion    NVARCHAR(255)  = NULL,
    @CostoMensual   DECIMAL(10,2)  = NULL,
    @DiasAsistencia TINYINT        = 63,
    @IdTurno        NVARCHAR(50)   = NULL,
    @Estado         NVARCHAR(50)   = 'Activo',
    @Resultado      INT OUTPUT,
    @Mensaje        NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM [PLAN] WHERE IDPLAN = @Id)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El plan no existe.'; RETURN; END

    IF @Nombre IS NULL OR LTRIM(RTRIM(@Nombre)) = ''
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ingresa el nombre del plan.'; RETURN; END

    IF @CostoMensual IS NOT NULL AND @CostoMensual < 0
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El costo mensual no puede ser negativo.'; RETURN; END

    IF @DiasAsistencia IS NULL OR @DiasAsistencia = 0
        SET @DiasAsistencia = 63;

    IF @IdTurno IS NOT NULL AND @IdTurno <> ''
       AND NOT EXISTS (SELECT 1 FROM TURNO WHERE IDTURNO = @IdTurno)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El turno seleccionado no es válido.'; RETURN; END

    IF EXISTS (SELECT 1 FROM [PLAN] WHERE NOMBRE = @Nombre AND IDPLAN <> @Id)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ya existe un plan con ese nombre.'; RETURN; END

    UPDATE [PLAN] SET
        NOMBRE          = @Nombre,
        DESCRIPCION     = @Descripcion,
        COSTOMENSUAL    = @CostoMensual,
        DIASASISTENCIA  = @DiasAsistencia,
        IDTURNO         = NULLIF(@IdTurno, ''),
        ACTIVO          = CASE WHEN @Estado = 'Activo' THEN 1 ELSE 0 END
    WHERE IDPLAN = @Id;

    UPDATE m
    SET m.IDTURNO = NULLIF(@IdTurno, '')
    FROM MENSUALIDAD m
    WHERE m.IDPLAN = @Id;

    SET @Resultado = 1; SET @Mensaje = 'Plan actualizado.';
END;
GO

/* ---- usp_mensualidad: turno heredado del plan ---- */
IF OBJECT_ID('dbo.usp_mensualidad_insertar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_mensualidad_insertar;
GO
CREATE PROCEDURE dbo.usp_mensualidad_insertar
    @Id                 NVARCHAR(50) = NULL,
    @IdUsuario          NVARCHAR(50),
    @IdPlan             NVARCHAR(50),
    @EstadoMiembro      INT           = 2,
    @FechaInicio        CHAR(8),
    @FechaFin           CHAR(8),
    @MontoTotal         DECIMAL(10,2),
    @PagoInicial        DECIMAL(10,2) = NULL,
    @IdMetodoPago       NVARCHAR(50)  = NULL,
    @IdAula             NVARCHAR(50)  = NULL,
    @IdTutor            NVARCHAR(50)  = NULL,
    @Observaciones      NVARCHAR(MAX) = NULL,
    @FechaCancelacion   CHAR(8)       = NULL,
    @RegistradoPor      NVARCHAR(50)  = NULL,
    @Resultado          INT OUTPUT,
    @Mensaje            NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @IdTurno NVARCHAR(50);

    IF @IdUsuario IS NULL OR @IdUsuario = ''
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Debe seleccionar un estudiante.'; RETURN; END
    IF @FechaInicio IS NULL OR @FechaFin IS NULL
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ingrese fecha de inicio y fin.'; RETURN; END
    IF @MontoTotal IS NULL
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ingrese el monto total.'; RETURN; END
    IF @EstadoMiembro NOT IN (2, 3)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Estado de mensualidad no válido.'; RETURN; END

    IF NOT EXISTS (SELECT 1 FROM USUARIO WHERE IDUSUARIO = @IdUsuario AND IDTIPOUSUARIO = '1')
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El estudiante no existe o no es válido.'; RETURN; END
    IF NOT EXISTS (SELECT 1 FROM [PLAN] WHERE IDPLAN = @IdPlan)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El plan seleccionado no es válido.'; RETURN; END

    SELECT @IdTurno = IDTURNO FROM [PLAN] WHERE IDPLAN = @IdPlan;

    IF @IdTutor IS NOT NULL AND @IdTutor <> ''
       AND NOT EXISTS (SELECT 1 FROM TUTOR WHERE IDTUTOR = @IdTutor AND ACTIVO = 1)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El tutor seleccionado no es válido.'; RETURN; END

    IF @PagoInicial IS NOT NULL AND @PagoInicial > 0
       AND (@IdMetodoPago IS NULL OR @IdMetodoPago = '')
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Indique el método de pago del pago inicial.'; RETURN; END

    IF @Id IS NULL OR @Id = ''
    BEGIN
        DECLARE @Next INT = ISNULL((
            SELECT MAX(TRY_CAST(SUBSTRING(IDMENSUALIDAD, 4, 10) AS INT))
            FROM MENSUALIDAD WHERE IDMENSUALIDAD LIKE 'MEM%'
        ), 0) + 1;
        SET @Id = 'MEM' + RIGHT('000000' + CAST(@Next AS VARCHAR(10)), 6);
    END

    IF EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = @Id)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'La mensualidad ya existe.'; RETURN; END

    INSERT INTO MENSUALIDAD (
        IDMENSUALIDAD, FECHAINICIO, FECHAFIN, ESTADOMIEMBRO, MONTOTOTAL, OBSERVACIONES,
        FECHAREGISTRO, HORAREGISTRO, IDPLAN, IDAULA, IDTURNO, IDUSUARIO, REGISTRADOPOR,
        IDTUTOR, FECHACANCELACION, ESTADO
    ) VALUES (
        @Id, @FechaInicio, @FechaFin, @EstadoMiembro, @MontoTotal, @Observaciones,
        dbo.fn_fecha_ddmmyyyy(), CONVERT(CHAR(8), GETDATE(), 108),
        @IdPlan, @IdAula, @IdTurno, @IdUsuario, @RegistradoPor,
        @IdTutor, @FechaCancelacion, 'Activo'
    );

    IF @PagoInicial IS NOT NULL AND @PagoInicial > 0
    BEGIN
        DECLARE @IdPago NVARCHAR(50) = 'PAG' + RIGHT('000000' + CAST((
            ISNULL((SELECT MAX(TRY_CAST(SUBSTRING(IDPAGOMENSUALIDAD, 4, 10) AS INT))
                    FROM PAGOMENSUALIDAD WHERE IDPAGOMENSUALIDAD LIKE 'PAG%'), 0) + 1
        ) AS VARCHAR(10)), 6);

        INSERT INTO PAGOMENSUALIDAD (
            IDPAGOMENSUALIDAD, MONTO, FECHAPAGO, HORAPAGO, OBSERVACIONES,
            IDMENSUALIDAD, IDMETODOPAGO, IDUSUARIO
        ) VALUES (
            @IdPago, @PagoInicial, dbo.fn_fecha_ddmmyyyy(), CONVERT(CHAR(8), GETDATE(), 108),
            'Pago inicial', @Id, @IdMetodoPago, @RegistradoPor
        );
    END

    SET @Resultado = 1; SET @Mensaje = 'Mensualidad registrada.';
END;
GO

IF OBJECT_ID('dbo.usp_mensualidad_actualizar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_mensualidad_actualizar;
GO
CREATE PROCEDURE dbo.usp_mensualidad_actualizar
    @Id                 NVARCHAR(50),
    @IdUsuario          NVARCHAR(50),
    @IdPlan             NVARCHAR(50),
    @EstadoMiembro      INT,
    @FechaInicio        CHAR(8),
    @FechaFin           CHAR(8),
    @MontoTotal         DECIMAL(10,2),
    @IdAula             NVARCHAR(50)  = NULL,
    @IdTutor            NVARCHAR(50)  = NULL,
    @Observaciones      NVARCHAR(MAX) = NULL,
    @FechaCancelacion   CHAR(8)       = NULL,
    @Resultado          INT OUTPUT,
    @Mensaje            NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @IdTurno NVARCHAR(50);

    IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = @Id)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'La mensualidad no existe.'; RETURN; END
    IF @EstadoMiembro NOT IN (2, 3)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Estado de mensualidad no válido.'; RETURN; END

    SELECT @IdTurno = IDTURNO FROM [PLAN] WHERE IDPLAN = @IdPlan;

    IF @IdTutor IS NOT NULL AND @IdTutor <> ''
       AND NOT EXISTS (SELECT 1 FROM TUTOR WHERE IDTUTOR = @IdTutor AND ACTIVO = 1)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El tutor seleccionado no es válido.'; RETURN; END

    UPDATE MENSUALIDAD SET
        IDUSUARIO        = @IdUsuario,
        IDPLAN           = @IdPlan,
        IDTURNO          = @IdTurno,
        ESTADOMIEMBRO    = @EstadoMiembro,
        FECHAINICIO      = @FechaInicio,
        FECHAFIN         = @FechaFin,
        MONTOTOTAL       = @MontoTotal,
        IDAULA           = @IdAula,
        IDTUTOR          = @IdTutor,
        OBSERVACIONES    = @Observaciones,
        FECHACANCELACION = @FechaCancelacion
    WHERE IDMENSUALIDAD = @Id;

    SET @Resultado = 1; SET @Mensaje = 'Mensualidad actualizada.';
END;
GO

IF OBJECT_ID('dbo.usp_mensualidad_listar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_mensualidad_listar;
GO
CREATE PROCEDURE dbo.usp_mensualidad_listar
    @Buscar         NVARCHAR(200) = NULL,
    @Estado         NVARCHAR(50)  = NULL,
    @OrdenarPor     NVARCHAR(50)  = 'FECHAREGISTRO',
    @Direccion      NVARCHAR(4)   = 'DESC',
    @Pagina         INT           = 1,
    @TamanioPagina  INT           = 10,
    @TotalRegistros INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    IF @Pagina < 1 SET @Pagina = 1;
    IF @TamanioPagina < 1 SET @TamanioPagina = 10;
    IF @Estado IS NULL OR @Estado = '' SET @Estado = 'Activo';

    SELECT @TotalRegistros = COUNT(*)
    FROM MENSUALIDAD m
    INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
    INNER JOIN [PLAN] pl ON pl.IDPLAN = m.IDPLAN
    LEFT JOIN AULA au ON au.IDAULA = m.IDAULA
    LEFT JOIN TUTOR ase ON ase.IDTUTOR = m.IDTUTOR
    WHERE m.ESTADO = @Estado
      AND (@Buscar IS NULL OR @Buscar = '' OR
           m.IDMENSUALIDAD LIKE '%' + @Buscar + '%' OR
           u.DNI LIKE '%' + @Buscar + '%' OR
           u.NOMBRE LIKE '%' + @Buscar + '%' OR
           u.APELLIDO LIKE '%' + @Buscar + '%' OR
           pl.NOMBRE LIKE '%' + @Buscar + '%' OR
           ISNULL(au.NOMBRE, '') LIKE '%' + @Buscar + '%' OR
           ISNULL(ase.NOMBRE, '') LIKE '%' + @Buscar + '%');

    SELECT
        m.IDMENSUALIDAD,
        m.IDUSUARIO,
        UPPER(LTRIM(RTRIM(ISNULL(u.APELLIDO, '') + ' ' + ISNULL(u.NOMBRE, '')))) AS ESTUDIANTE_NOMBRE,
        u.DNI AS ESTUDIANTE_DNI,
        m.IDPLAN,
        pl.NOMBRE AS PLAN_NOMBRE,
        ISNULL(tu.DESCRIPCION, '') AS TURNO_DESCRIPCION,
        m.ESTADOMIEMBRO,
        CASE m.ESTADOMIEMBRO
            WHEN 2 THEN 'Activo'
            WHEN 3 THEN 'Vencido'
            ELSE 'Activo'
        END AS ESTADOMIEMBRO_DESCRIPCION,
        m.FECHAINICIO,
        m.FECHAFIN,
        m.MONTOTOTAL,
        ISNULL(pag.PAGADO, 0) AS PAGADO,
        CASE
            WHEN ISNULL(m.MONTOTOTAL, 0) - ISNULL(pag.PAGADO, 0) < 0 THEN 0
            ELSE ISNULL(m.MONTOTOTAL, 0) - ISNULL(pag.PAGADO, 0)
        END AS DEUDA,
        ISNULL(au.NOMBRE, '') AS AULA_NOMBRE,
        m.IDTUTOR,
        ISNULL(ase.NOMBRE, ISNULL(m.TUTORLEGACY, '')) AS TUTOR_NOMBRE,
        m.ESTADO,
        m.FECHAREGISTRO
    FROM MENSUALIDAD m
    INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
    INNER JOIN [PLAN] pl ON pl.IDPLAN = m.IDPLAN
    LEFT JOIN TURNO tu ON tu.IDTURNO = ISNULL(pl.IDTURNO, m.IDTURNO)
    LEFT JOIN AULA au ON au.IDAULA = m.IDAULA
    LEFT JOIN TUTOR ase ON ase.IDTUTOR = m.IDTUTOR
    OUTER APPLY (
        SELECT SUM(p.MONTO) AS PAGADO
        FROM PAGOMENSUALIDAD p
        WHERE p.IDMENSUALIDAD = m.IDMENSUALIDAD
    ) pag
    WHERE m.ESTADO = @Estado
      AND (@Buscar IS NULL OR @Buscar = '' OR
           m.IDMENSUALIDAD LIKE '%' + @Buscar + '%' OR
           u.DNI LIKE '%' + @Buscar + '%' OR
           u.NOMBRE LIKE '%' + @Buscar + '%' OR
           u.APELLIDO LIKE '%' + @Buscar + '%' OR
           pl.NOMBRE LIKE '%' + @Buscar + '%' OR
           ISNULL(au.NOMBRE, '') LIKE '%' + @Buscar + '%' OR
           ISNULL(ase.NOMBRE, '') LIKE '%' + @Buscar + '%')
    ORDER BY
        CASE WHEN @OrdenarPor = 'IDMENSUALIDAD' AND @Direccion = 'ASC'  THEN m.IDMENSUALIDAD END ASC,
        CASE WHEN @OrdenarPor = 'IDMENSUALIDAD' AND @Direccion = 'DESC' THEN m.IDMENSUALIDAD END DESC,
        CASE WHEN @OrdenarPor = 'ESTUDIANTE_NOMBRE' AND @Direccion = 'ASC'  THEN u.APELLIDO END ASC,
        CASE WHEN @OrdenarPor = 'ESTUDIANTE_NOMBRE' AND @Direccion = 'DESC' THEN u.APELLIDO END DESC,
        CASE WHEN @OrdenarPor = 'FECHAINICIO' AND @Direccion = 'ASC'  THEN m.FECHAINICIO END ASC,
        CASE WHEN @OrdenarPor = 'FECHAINICIO' AND @Direccion = 'DESC' THEN m.FECHAINICIO END DESC,
        CASE WHEN @OrdenarPor = 'FECHAFIN' AND @Direccion = 'ASC'  THEN m.FECHAFIN END ASC,
        CASE WHEN @OrdenarPor = 'FECHAFIN' AND @Direccion = 'DESC' THEN m.FECHAFIN END DESC,
        CASE WHEN @OrdenarPor = 'MONTOTOTAL' AND @Direccion = 'ASC'  THEN m.MONTOTOTAL END ASC,
        CASE WHEN @OrdenarPor = 'MONTOTOTAL' AND @Direccion = 'DESC' THEN m.MONTOTOTAL END DESC,
        CASE WHEN @OrdenarPor = 'DEUDA' AND @Direccion = 'ASC' THEN
            ISNULL(m.MONTOTOTAL, 0) - ISNULL(pag.PAGADO, 0) END ASC,
        CASE WHEN @OrdenarPor = 'DEUDA' AND @Direccion = 'DESC' THEN
            ISNULL(m.MONTOTOTAL, 0) - ISNULL(pag.PAGADO, 0) END DESC,
        CASE WHEN @OrdenarPor = 'FECHAREGISTRO' AND @Direccion = 'ASC'  THEN m.FECHAREGISTRO END ASC,
        CASE WHEN @OrdenarPor = 'FECHAREGISTRO' AND @Direccion = 'DESC' THEN m.FECHAREGISTRO END DESC,
        m.IDMENSUALIDAD DESC
    OFFSET (@Pagina - 1) * @TamanioPagina ROWS
    FETCH NEXT @TamanioPagina ROWS ONLY;
END;
GO

IF OBJECT_ID('dbo.usp_mensualidad_obtener', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_mensualidad_obtener;
GO
CREATE PROCEDURE dbo.usp_mensualidad_obtener
    @Id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        m.IDMENSUALIDAD,
        m.IDUSUARIO,
        UPPER(LTRIM(RTRIM(ISNULL(u.APELLIDO, '') + ' ' + ISNULL(u.NOMBRE, '')))) AS ESTUDIANTE_NOMBRE,
        u.DNI AS ESTUDIANTE_DNI,
        m.IDPLAN,
        pl.NOMBRE AS PLAN_NOMBRE,
        ISNULL(tu.DESCRIPCION, '') AS TURNO_DESCRIPCION,
        m.ESTADOMIEMBRO,
        m.FECHAINICIO,
        m.FECHAFIN,
        m.MONTOTOTAL,
        m.IDAULA,
        ISNULL(au.NOMBRE, '') AS AULA_NOMBRE,
        m.IDTUTOR,
        ISNULL(ase.NOMBRE, ISNULL(m.TUTORLEGACY, '')) AS TUTOR_NOMBRE,
        m.OBSERVACIONES,
        m.FECHACANCELACION,
        m.ESTADO,
        m.FECHAREGISTRO,
        m.REGISTRADOPOR,
        ISNULL(pag.PAGOINICIAL, 0) AS PAGOINICIAL,
        pag.IDMETODOPAGO
    FROM MENSUALIDAD m
    INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
    INNER JOIN [PLAN] pl ON pl.IDPLAN = m.IDPLAN
    LEFT JOIN TURNO tu ON tu.IDTURNO = ISNULL(pl.IDTURNO, m.IDTURNO)
    LEFT JOIN AULA au ON au.IDAULA = m.IDAULA
    LEFT JOIN TUTOR ase ON ase.IDTUTOR = m.IDTUTOR
    OUTER APPLY (
        SELECT TOP 1 p.MONTO AS PAGOINICIAL, p.IDMETODOPAGO
        FROM PAGOMENSUALIDAD p
        WHERE p.IDMENSUALIDAD = m.IDMENSUALIDAD
        ORDER BY p.FECHAPAGO, p.IDPAGOMENSUALIDAD
    ) pag
    WHERE m.IDMENSUALIDAD = @Id;
END;
GO

PRINT 'PLAN.IDTURNO, usp_plan_* y usp_mensualidad_* (turno heredado) actualizados.';
GO
