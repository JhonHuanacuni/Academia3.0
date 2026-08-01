/* ============================================================================
   CORRECCIÓN MENSUALIDADES — registros que fallaron en script 6
   - Staff/admin/secretario: INSERT directo (SP solo acepta estudiantes)
   - Estudiante faltante 61136536: crear usuario + mensualidad
   Ejecutar antes del script 7 (pagos)
   Fecha: 31/07/2026
   ============================================================================ */

SET NOCOUNT ON;
GO

-- [1/1] Membresia legacy #662 — FREDY ALFARO CHAVEZ ASESOR ACADEMICO (DNI 41591259) fin 2026-12-31 estado activa
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000662')
BEGIN
    INSERT INTO MENSUALIDAD (
        IDMENSUALIDAD, FECHAINICIO, FECHAFIN, ESTADOMIEMBRO, MONTOTOTAL, OBSERVACIONES,
        FECHAREGISTRO, HORAREGISTRO, IDPLAN, IDAULA, IDTURNO, IDUSUARIO, REGISTRADOPOR,
        IDTUTOR, FECHACANCELACION, ESTADO
    )
    SELECT
        N'MEM000662', N'26032026', N'31122026', 2, 1.00, N'Import legacy membresia #662 | Tipo: INDIVIDUAL',
        dbo.fn_fecha_ddmmyyyy(), CONVERT(CHAR(8), GETDATE(), 108),
        N'PLN001', N'AUL007', p.IDTURNO, N'41591259', N'10033907',
        NULL, NULL, N'Activo'
    FROM [PLAN] p WHERE p.IDPLAN = N'PLN001';
    PRINT 'OK MEM000662: insertado (usuario no estudiante)';
END
ELSE
    PRINT 'SKIP MEM000662 ya existe';
GO

-- [1/1] Membresia legacy #663 — JESÚS SALINAS  (DNI 10033907) fin 2026-10-31 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000663')
BEGIN
    INSERT INTO MENSUALIDAD (
        IDMENSUALIDAD, FECHAINICIO, FECHAFIN, ESTADOMIEMBRO, MONTOTOTAL, OBSERVACIONES,
        FECHAREGISTRO, HORAREGISTRO, IDPLAN, IDAULA, IDTURNO, IDUSUARIO, REGISTRADOPOR,
        IDTUTOR, FECHACANCELACION, ESTADO
    )
    SELECT
        N'MEM000663', N'26032026', N'31102026', 2, 2450.00, N'Import legacy membresia #663 | Tipo: INDIVIDUAL',
        dbo.fn_fecha_ddmmyyyy(), CONVERT(CHAR(8), GETDATE(), 108),
        N'PLN001', N'AUL007', p.IDTURNO, N'10033907', N'10033907',
        NULL, NULL, N'Activo'
    FROM [PLAN] p WHERE p.IDPLAN = N'PLN001';
    PRINT 'OK MEM000663: insertado (usuario no estudiante)';
END
ELSE
    PRINT 'SKIP MEM000663 ya existe';
GO

-- [1/1] Membresia legacy #664 — FERNANDA MORALES VASQUEZ (DNI 73878120) fin 2026-12-31 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000664')
BEGIN
    INSERT INTO MENSUALIDAD (
        IDMENSUALIDAD, FECHAINICIO, FECHAFIN, ESTADOMIEMBRO, MONTOTOTAL, OBSERVACIONES,
        FECHAREGISTRO, HORAREGISTRO, IDPLAN, IDAULA, IDTURNO, IDUSUARIO, REGISTRADOPOR,
        IDTUTOR, FECHACANCELACION, ESTADO
    )
    SELECT
        N'MEM000664', N'26032026', N'31122026', 2, 1.00, N'Import legacy membresia #664 | Tipo: INDIVIDUAL',
        dbo.fn_fecha_ddmmyyyy(), CONVERT(CHAR(8), GETDATE(), 108),
        N'PLN001', N'AUL007', p.IDTURNO, N'73878120', N'10033907',
        NULL, NULL, N'Activo'
    FROM [PLAN] p WHERE p.IDPLAN = N'PLN001';
    PRINT 'OK MEM000664: insertado (usuario no estudiante)';
END
ELSE
    PRINT 'SKIP MEM000664 ya existe';
GO

-- [1/1] Membresia legacy #665 — SARA HUAMAN SALINAS (DNI 74806860) fin 2026-12-31 estado activa
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000665')
BEGIN
    INSERT INTO MENSUALIDAD (
        IDMENSUALIDAD, FECHAINICIO, FECHAFIN, ESTADOMIEMBRO, MONTOTOTAL, OBSERVACIONES,
        FECHAREGISTRO, HORAREGISTRO, IDPLAN, IDAULA, IDTURNO, IDUSUARIO, REGISTRADOPOR,
        IDTUTOR, FECHACANCELACION, ESTADO
    )
    SELECT
        N'MEM000665', N'26032026', N'31122026', 2, 1.00, N'Import legacy membresia #665 | Tipo: INDIVIDUAL',
        dbo.fn_fecha_ddmmyyyy(), CONVERT(CHAR(8), GETDATE(), 108),
        N'PLN001', N'AUL007', p.IDTURNO, N'74806860', N'10033907',
        NULL, NULL, N'Activo'
    FROM [PLAN] p WHERE p.IDPLAN = N'PLN001';
    PRINT 'OK MEM000665: insertado (usuario no estudiante)';
END
ELSE
    PRINT 'SKIP MEM000665 ya existe';
GO

-- [1/1] Membresia legacy #674 — FAIRUZ SILVIA RIOS ZAMBRANO (DNI 75234130) fin 2026-12-31 estado activa
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000674')
BEGIN
    INSERT INTO MENSUALIDAD (
        IDMENSUALIDAD, FECHAINICIO, FECHAFIN, ESTADOMIEMBRO, MONTOTOTAL, OBSERVACIONES,
        FECHAREGISTRO, HORAREGISTRO, IDPLAN, IDAULA, IDTURNO, IDUSUARIO, REGISTRADOPOR,
        IDTUTOR, FECHACANCELACION, ESTADO
    )
    SELECT
        N'MEM000674', N'26032026', N'31122026', 2, 1.00, N'Import legacy membresia #674 | Tipo: INDIVIDUAL',
        dbo.fn_fecha_ddmmyyyy(), CONVERT(CHAR(8), GETDATE(), 108),
        N'PLN001', N'AUL007', p.IDTURNO, N'75234130', N'10033907',
        NULL, NULL, N'Activo'
    FROM [PLAN] p WHERE p.IDPLAN = N'PLN001';
    PRINT 'OK MEM000674: insertado (usuario no estudiante)';
END
ELSE
    PRINT 'SKIP MEM000674 ya existe';
GO

-- Crear estudiante faltante DNI 61136536
IF NOT EXISTS (SELECT 1 FROM USUARIO WHERE IDUSUARIO = N'61136536')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_usuario_insertar
        @Id                 = N'61136536',
        @Contra             = N'61136536',
        @Nombre             = N'JOEL ADRIEL',
        @Apellido           = N'CONTRERAS PANIURA',
        @Dni                = N'61136536',
        @Email              = N'61136536@import.academia.local',
        @IdTipoUsuario      = N'1',
        @Estado             = N'Activo',
        @FechaNacimiento    = NULL,
        @Direccion          = NULL,
        @Distrito           = NULL,
        @Colegio            = NULL,
        @Grado              = NULL,
        @TelPersonal        = N'906658536',
        @TelApoderado       = N'901132489',
        @NombreApoderado    = NULL,
        @Parentesco         = NULL,
        @SituacionAcademica = NULL,
        @ComoEntero         = NULL,
        @Foto               = NULL,
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK usuario 61136536: ' + @M; ELSE PRINT 'ERROR usuario 61136536: ' + @M;
END
GO

-- [1/1] Membresia legacy #777 — JOEL ADRIEL CONTRERAS PANIURA (DNI 61136536) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000777')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000777',
        @IdUsuario          = N'61136536',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'30062026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 2100.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = NULL,
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #777 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000777: ' + @M; ELSE PRINT 'ERROR MEM000777: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000777 ya existe';
GO
