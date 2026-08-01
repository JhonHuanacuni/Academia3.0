/* ============================================================================
   IMPORTACIÓN MENSUALIDADES VIGENTES — desde memebresias.txt
   Archivo: 270 filas, 222 vigentes brutas, 153 únicas deduplicadas
   Criterio vigente: FECHAFIN >= 31/07/2026 y sin fecha_cancelacion
   Pago inicial (adelanto): 0 — los pagos van en script 7
   IDMENSUALIDAD: MEM + id legacy | IF NOT EXISTS evita duplicados al re-ejecutar
   Ejecutar después de importar usuarios
   Fecha: 31/07/2026
   ============================================================================ */

SET NOCOUNT ON;
GO

-- [1/153] Membresia legacy #328 — IGNACIO ANTONIO  DAVILA RIVEIRO (DNI 62344562) fin 2026-12-09 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000328')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000328',
        @IdUsuario          = N'62344562',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'09032026',
        @FechaFin           = N'09122026',
        @MontoTotal         = 2700.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL011',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #328 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000328: ' + @M; ELSE PRINT 'ERROR MEM000328: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000328 ya existe';
GO

-- [2/153] Membresia legacy #343 — JOHAN CRISTOFER CERNA VIVANCO (DNI 62548834) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000343')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000343',
        @IdUsuario          = N'62548834',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'09032026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 2700.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL009',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #343 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000343: ' + @M; ELSE PRINT 'ERROR MEM000343: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000343 ya existe';
GO

-- [3/153] Membresia legacy #344 — ADRIEL MARTIN FLORES HUAMANI (DNI 61466262) fin 2026-12-09 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000344')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000344',
        @IdUsuario          = N'61466262',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'09032026',
        @FechaFin           = N'09122026',
        @MontoTotal         = 3150.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL008',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #344 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000344: ' + @M; ELSE PRINT 'ERROR MEM000344: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000344 ya existe';
GO

-- [4/153] Membresia legacy #516 — ADRIANO NEYMAR QUISPE VILLAR (DNI 80961735) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000516')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000516',
        @IdUsuario          = N'80961735',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'14032026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 1080.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL003',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #516 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000516: ' + @M; ELSE PRINT 'ERROR MEM000516: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000516 ya existe';
GO

-- [5/153] Membresia legacy #518 — ITALO SEBASTIAN  HUAMAN SULCA (DNI 61042238) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000518')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000518',
        @IdUsuario          = N'61042238',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'09032026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 3150.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL008',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #518 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000518: ' + @M; ELSE PRINT 'ERROR MEM000518: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000518 ya existe';
GO

-- [6/153] Membresia legacy #521 — IVAN AYALA BARRUETA (DNI 62587561) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000521')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000521',
        @IdUsuario          = N'62587561',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'09032026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 2700.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL009',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #521 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000521: ' + @M; ELSE PRINT 'ERROR MEM000521: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000521 ya existe';
GO

-- [7/153] Membresia legacy #522 — LUHANA RUBY HERRERA ROJAS (DNI 63708419) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000522')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000522',
        @IdUsuario          = N'63708419',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'14032026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 1080.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL003',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #522 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000522: ' + @M; ELSE PRINT 'ERROR MEM000522: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000522 ya existe';
GO

-- [8/153] Membresia legacy #525 — GREICY MARILLY PAMPAÑAUPA CONTRERAS (DNI 77883165) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000525')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000525',
        @IdUsuario          = N'77883165',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'09032026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 3150.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = NULL,
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #525 | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000525: ' + @M; ELSE PRINT 'ERROR MEM000525: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000525 ya existe';
GO

-- [9/153] Membresia legacy #526 — LUANA GERALDINE SANDOVAL SANDOVAL (DNI 62019086) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000526')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000526',
        @IdUsuario          = N'62019086',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'09032026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 3150.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL008',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #526 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000526: ' + @M; ELSE PRINT 'ERROR MEM000526: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000526 ya existe';
GO

-- [10/153] Membresia legacy #529 — YANIRA ISABEL RAMOS HUAYHUAS (DNI 62011916) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000529')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000529',
        @IdUsuario          = N'62011916',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'09032026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 3150.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL008',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #529 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000529: ' + @M; ELSE PRINT 'ERROR MEM000529: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000529 ya existe';
GO

-- [11/153] Membresia legacy #535 — PIERO ANGELO ACUÑA FLORES (DNI 75026943) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000535')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000535',
        @IdUsuario          = N'75026943',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'10032026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 2700.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL012',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #535 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000535: ' + @M; ELSE PRINT 'ERROR MEM000535: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000535 ya existe';
GO

-- [12/153] Membresia legacy #536 — LUNA BELEN ESTRADA RIVERA (DNI 74511921) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000536')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000536',
        @IdUsuario          = N'74511921',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'09032026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 3150.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = NULL,
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #536 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000536: ' + @M; ELSE PRINT 'ERROR MEM000536: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000536 ya existe';
GO

-- [13/153] Membresia legacy #537 — SAMANTHA ISABELLA  CANO MENDIVIL (DNI 74794155) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000537')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000537',
        @IdUsuario          = N'74794155',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'09032026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 2700.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL009',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #537 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000537: ' + @M; ELSE PRINT 'ERROR MEM000537: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000537 ya existe';
GO

-- [14/153] Membresia legacy #540 — ROCIO LIZETH LUQUE PAREDES (DNI 72820448) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000540')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000540',
        @IdUsuario          = N'72820448',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'09032026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 3150.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL008',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #540 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000540: ' + @M; ELSE PRINT 'ERROR MEM000540: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000540 ya existe';
GO

-- [15/153] Membresia legacy #543 — ROMINA SHANTAL  AGUILAR PALOMINO (DNI 61932289) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000543')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000543',
        @IdUsuario          = N'61932289',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'10032026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 1980.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL012',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #543 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000543: ' + @M; ELSE PRINT 'ERROR MEM000543: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000543 ya existe';
GO

-- [16/153] Membresia legacy #545 — ANDREA SOFIA PADILLA VASQUEZ (DNI 61470118) fin 2026-08-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000545')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000545',
        @IdUsuario          = N'61470118',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'09032026',
        @FechaFin           = N'30082026',
        @MontoTotal         = 2500.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL001',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #545 | Asesor: JESUS | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000545: ' + @M; ELSE PRINT 'ERROR MEM000545: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000545 ya existe';
GO

-- [17/153] Membresia legacy #546 — PAUL ANDRES  HUAMAN HUAYANAY (DNI 61878690) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000546')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000546',
        @IdUsuario          = N'61878690',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'09032026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 2700.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = NULL,
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #546 | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000546: ' + @M; ELSE PRINT 'ERROR MEM000546: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000546 ya existe';
GO

-- [18/153] Membresia legacy #548 — KIARA SHARLYN PALOMINO GONZALES (DNI 72059754) fin 2026-12-30 estado activa
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000548')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000548',
        @IdUsuario          = N'72059754',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'09032026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 500.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL009',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #548 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000548: ' + @M; ELSE PRINT 'ERROR MEM000548: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000548 ya existe';
GO

-- [19/153] Membresia legacy #550 — ANDERSON SMITH CHUQUIHUANCA ARANDA (DNI 61802136) fin 2026-09-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000550')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000550',
        @IdUsuario          = N'61802136',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'10032026',
        @FechaFin           = N'30092026',
        @MontoTotal         = 1320.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL002',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #550 | Asesor: JESUS | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000550: ' + @M; ELSE PRINT 'ERROR MEM000550: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000550 ya existe';
GO

-- [20/153] Membresia legacy #551 — DAVID CALLA BIZARRO (DNI 61802063) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000551')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000551',
        @IdUsuario          = N'61802063',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'09032026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 2700.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL009',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #551 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000551: ' + @M; ELSE PRINT 'ERROR MEM000551: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000551 ya existe';
GO

-- [21/153] Membresia legacy #552 — GABRIELA SUSANA LEDESMA TORRES (DNI 61529497) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000552')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000552',
        @IdUsuario          = N'61529497',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'09032026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 3150.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL008',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #552 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000552: ' + @M; ELSE PRINT 'ERROR MEM000552: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000552 ya existe';
GO

-- [22/153] Membresia legacy #555 — ANTONY ANDERSON SERNA GUERRERO (DNI 61582577) fin 2026-08-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000555')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000555',
        @IdUsuario          = N'61582577',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'09032026',
        @FechaFin           = N'30082026',
        @MontoTotal         = 2500.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL001',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #555 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000555: ' + @M; ELSE PRINT 'ERROR MEM000555: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000555 ya existe';
GO

-- [23/153] Membresia legacy #556 — YONNER HUSSEIN SUAREZ HUAMANLAZO (DNI 77862597) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000556')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000556',
        @IdUsuario          = N'77862597',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'14032026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 1080.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL003',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #556 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000556: ' + @M; ELSE PRINT 'ERROR MEM000556: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000556 ya existe';
GO

-- [24/153] Membresia legacy #557 — MILAGROS LILI RIVADENEYRA CHERO (DNI 71672104) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000557')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000557',
        @IdUsuario          = N'71672104',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'09032026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 3150.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL008',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #557 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000557: ' + @M; ELSE PRINT 'ERROR MEM000557: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000557 ya existe';
GO

-- [25/153] Membresia legacy #558 — FRANZ MATT QUISPE HUCHARIMA (DNI 62587797) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000558')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000558',
        @IdUsuario          = N'62587797',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'10032026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 1980.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL012',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #558 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000558: ' + @M; ELSE PRINT 'ERROR MEM000558: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000558 ya existe';
GO

-- [26/153] Membresia legacy #559 — BLANCA SOFIA ESTHER CHUMPITAZ CAYCHO (DNI 61215514) fin 2026-08-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000559')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000559',
        @IdUsuario          = N'61215514',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'09032026',
        @FechaFin           = N'30082026',
        @MontoTotal         = 1750.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL001',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #559 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000559: ' + @M; ELSE PRINT 'ERROR MEM000559: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000559 ya existe';
GO

-- [27/153] Membresia legacy #562 — LIZBETH KATERINE OCAS CHACON (DNI 61371087) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000562')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000562',
        @IdUsuario          = N'61371087',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'09032026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 3150.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL008',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #562 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000562: ' + @M; ELSE PRINT 'ERROR MEM000562: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000562 ya existe';
GO

-- [28/153] Membresia legacy #563 — LUIS THIAGO HUINCHO LOPEZ (DNI 61359712) fin 2026-08-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000563')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000563',
        @IdUsuario          = N'61359712',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'09032026',
        @FechaFin           = N'30082026',
        @MontoTotal         = 1750.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL001',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #563 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000563: ' + @M; ELSE PRINT 'ERROR MEM000563: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000563 ya existe';
GO

-- [29/153] Membresia legacy #565 — VALERIA BRISEIDA MARTINEZ RAYMI (DNI 61434209) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000565')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000565',
        @IdUsuario          = N'61434209',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'09032026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 2700.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = NULL,
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #565 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000565: ' + @M; ELSE PRINT 'ERROR MEM000565: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000565 ya existe';
GO

-- [30/153] Membresia legacy #571 — KIARA JAMILE ALVAREZ LLATA (DNI 62011761) fin 2026-08-30 estado activa
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000571')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000571',
        @IdUsuario          = N'62011761',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'09032026',
        @FechaFin           = N'30082026',
        @MontoTotal         = 1400.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL001',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #571 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000571: ' + @M; ELSE PRINT 'ERROR MEM000571: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000571 ya existe';
GO

-- [31/153] Membresia legacy #572 — LEONARDO NIKOLAS  GONZALEZ SARMIENTO (DNI 90273203) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000572')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000572',
        @IdUsuario          = N'90273203',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'14032026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 1080.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL002',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #572 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000572: ' + @M; ELSE PRINT 'ERROR MEM000572: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000572 ya existe';
GO

-- [32/153] Membresia legacy #573 — TREYCI NICOLE BEJAR PAQUIYAURI (DNI 77312764) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000573')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000573',
        @IdUsuario          = N'77312764',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'14032026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 1080.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL003',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #573 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000573: ' + @M; ELSE PRINT 'ERROR MEM000573: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000573 ya existe';
GO

-- [33/153] Membresia legacy #581 — DAYRA LUANA SURCA MORENO (DNI 62646301) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000581')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000581',
        @IdUsuario          = N'62646301',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'14032026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 1080.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL002',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #581 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000581: ' + @M; ELSE PRINT 'ERROR MEM000581: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000581 ya existe';
GO

-- [34/153] Membresia legacy #584 — ALEXIA VALERIA MUÑOZ FLORES (DNI 72594120) fin 2026-08-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000584')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000584',
        @IdUsuario          = N'72594120',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'09032026',
        @FechaFin           = N'30082026',
        @MontoTotal         = 1750.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL001',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #584 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000584: ' + @M; ELSE PRINT 'ERROR MEM000584: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000584 ya existe';
GO

-- [35/153] Membresia legacy #585 — ANALIA MIA POMA PEREZ  (DNI 61363621) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000585')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000585',
        @IdUsuario          = N'61363621',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'09032026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 3150.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL008',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #585 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000585: ' + @M; ELSE PRINT 'ERROR MEM000585: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000585 ya existe';
GO

-- [36/153] Membresia legacy #586 — DANIEL LEONIVES CHIMPAY ROCA (DNI 61933199) fin 2026-12-30 estado activa
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000586')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000586',
        @IdUsuario          = N'61933199',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'09032026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 500.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL009',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #586 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000586: ' + @M; ELSE PRINT 'ERROR MEM000586: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000586 ya existe';
GO

-- [37/153] Membresia legacy #587 — LIXUE SAYURI LUIZA CORONADO MENDOZA (DNI 62712398) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000587')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000587',
        @IdUsuario          = N'62712398',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'14032026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 1080.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = NULL,
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #587 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000587: ' + @M; ELSE PRINT 'ERROR MEM000587: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000587 ya existe';
GO

-- [38/153] Membresia legacy #588 — FELIX ANDERSON HUAMANI HUAMANI (DNI 76851010) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000588')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000588',
        @IdUsuario          = N'76851010',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'09032026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 3150.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = NULL,
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #588 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000588: ' + @M; ELSE PRINT 'ERROR MEM000588: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000588 ya existe';
GO

-- [39/153] Membresia legacy #592 — ANDREA XIMENA PFUÑO CCALLA (DNI 75870439) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000592')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000592',
        @IdUsuario          = N'75870439',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'09032026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 3150.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL008',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #592 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000592: ' + @M; ELSE PRINT 'ERROR MEM000592: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000592 ya existe';
GO

-- [40/153] Membresia legacy #593 — JESUS MANUEL PEÑALOZA HUAMAN (DNI 77711407) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000593')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000593',
        @IdUsuario          = N'77711407',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'09032026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 3150.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL010',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #593 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000593: ' + @M; ELSE PRINT 'ERROR MEM000593: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000593 ya existe';
GO

-- [41/153] Membresia legacy #594 — CELINE GOMEZ JOYO (DNI 61358939) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000594')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000594',
        @IdUsuario          = N'61358939',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'09032026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 3150.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = NULL,
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #594 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000594: ' + @M; ELSE PRINT 'ERROR MEM000594: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000594 ya existe';
GO

-- [42/153] Membresia legacy #595 — KEVIN LUIS ASCUE CORREA (DNI 61511784) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000595')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000595',
        @IdUsuario          = N'61511784',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'09032026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 3150.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = NULL,
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #595 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000595: ' + @M; ELSE PRINT 'ERROR MEM000595: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000595 ya existe';
GO

-- [43/153] Membresia legacy #596 — XIMENA FERNANDA DELIA VERA TARAZONA (DNI 72829337) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000596')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000596',
        @IdUsuario          = N'72829337',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'09032026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 2700.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL009',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #596 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000596: ' + @M; ELSE PRINT 'ERROR MEM000596: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000596 ya existe';
GO

-- [44/153] Membresia legacy #597 — DANTE EMMANUEL ARMAS MONTES (DNI 61215706) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000597')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000597',
        @IdUsuario          = N'61215706',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'09032026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 2700.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL009',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #597 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000597: ' + @M; ELSE PRINT 'ERROR MEM000597: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000597 ya existe';
GO

-- [45/153] Membresia legacy #598 — JEANPIERRE SMITH MORALES CORNELIO (DNI 60401193) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000598')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000598',
        @IdUsuario          = N'60401193',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'09032026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 3150.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL001',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #598 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000598: ' + @M; ELSE PRINT 'ERROR MEM000598: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000598 ya existe';
GO

-- [46/153] Membresia legacy #599 — DENNY JUNIOR CARDENAS VERA (DNI 61755261) fin 2026-08-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000599')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000599',
        @IdUsuario          = N'61755261',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'09032026',
        @FechaFin           = N'30082026',
        @MontoTotal         = 2500.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL001',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #599 | Asesor: JESUS | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000599: ' + @M; ELSE PRINT 'ERROR MEM000599: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000599 ya existe';
GO

-- [47/153] Membresia legacy #600 — ARIANA JIMENA LUJAN VERA (DNI 61434259) fin 2026-08-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000600')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000600',
        @IdUsuario          = N'61434259',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'09032026',
        @FechaFin           = N'30082026',
        @MontoTotal         = 2500.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL001',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #600 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000600: ' + @M; ELSE PRINT 'ERROR MEM000600: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000600 ya existe';
GO

-- [48/153] Membresia legacy #608 — ESAUD AARON ACUÑA CARMONA (DNI 62587598) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000608')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000608',
        @IdUsuario          = N'62587598',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'14032026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 1080.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL002',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #608 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000608: ' + @M; ELSE PRINT 'ERROR MEM000608: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000608 ya existe';
GO

-- [49/153] Membresia legacy #609 — JOSE DANIEL SALVATIERRA NOA (DNI 60919931) fin 2026-08-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000609')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000609',
        @IdUsuario          = N'60919931',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'11032026',
        @FechaFin           = N'30082026',
        @MontoTotal         = 1750.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL001',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #609 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000609: ' + @M; ELSE PRINT 'ERROR MEM000609: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000609 ya existe';
GO

-- [50/153] Membresia legacy #611 — ROGER ANDRE CONDORI MALLQUI (DNI 61216936) fin 2026-08-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000611')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000611',
        @IdUsuario          = N'61216936',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'10032026',
        @FechaFin           = N'30082026',
        @MontoTotal         = 1700.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL005',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #611 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000611: ' + @M; ELSE PRINT 'ERROR MEM000611: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000611 ya existe';
GO

-- [51/153] Membresia legacy #614 — ASTRID ILLARI  CHIMPAY ROCA (DNI 77983623) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000614')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000614',
        @IdUsuario          = N'77983623',
        @IdPlan             = N'PLN007',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'14032026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 1080.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL003',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #614 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000614: ' + @M; ELSE PRINT 'ERROR MEM000614: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000614 ya existe';
GO

-- [52/153] Membresia legacy #616 — DANIEL  MORENO YSLA (DNI 73717309) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000616')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000616',
        @IdUsuario          = N'73717309',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'11032026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 2700.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL009',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #616 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000616: ' + @M; ELSE PRINT 'ERROR MEM000616: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000616 ya existe';
GO

-- [53/153] Membresia legacy #617 — JOSE LUIS CRUZ HUAMAN (DNI 61392984) fin 2026-08-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000617')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000617',
        @IdUsuario          = N'61392984',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'12032026',
        @FechaFin           = N'30082026',
        @MontoTotal         = 1500.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = NULL,
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #617 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000617: ' + @M; ELSE PRINT 'ERROR MEM000617: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000617 ya existe';
GO

-- [54/153] Membresia legacy #621 — SHANTAL ADAMARI RODRIGUEZ CHANCOS (DNI 71174041) fin 2026-08-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000621')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000621',
        @IdUsuario          = N'71174041',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'13032026',
        @FechaFin           = N'30082026',
        @MontoTotal         = 1750.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL008',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #621 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000621: ' + @M; ELSE PRINT 'ERROR MEM000621: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000621 ya existe';
GO

-- [55/153] Membresia legacy #623 — THIAGO ALONSO CABRERA ALANOCA (DNI 81092107) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000623')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000623',
        @IdUsuario          = N'81092107',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'14032026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 1080.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL003',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #623 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000623: ' + @M; ELSE PRINT 'ERROR MEM000623: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000623 ya existe';
GO

-- [56/153] Membresia legacy #628 — DAVID MOISES VEGA PUMALLANQUI (DNI 61616950) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000628')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000628',
        @IdUsuario          = N'61616950',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'16032026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 3150.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL010',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #628 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000628: ' + @M; ELSE PRINT 'ERROR MEM000628: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000628 ya existe';
GO

-- [57/153] Membresia legacy #631 — ARMANDO ADRIAN CABALLA MENDOZA (DNI 61530086) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000631')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000631',
        @IdUsuario          = N'61530086',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'18032026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 3150.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL001',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #631 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000631: ' + @M; ELSE PRINT 'ERROR MEM000631: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000631 ya existe';
GO

-- [58/153] Membresia legacy #632 — JOSHUA DANNY GABRIEL RAMOS CHOQUE (DNI 74102922) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000632')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000632',
        @IdUsuario          = N'74102922',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'21032026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 1080.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = NULL,
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #632 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000632: ' + @M; ELSE PRINT 'ERROR MEM000632: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000632 ya existe';
GO

-- [59/153] Membresia legacy #633 — FABIOLA DANUSKA HUAROTO ROMERO (DNI 61454016) fin 2026-08-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000633')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000633',
        @IdUsuario          = N'61454016',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'23032026',
        @FechaFin           = N'30082026',
        @MontoTotal         = 1750.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = NULL,
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #633 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000633: ' + @M; ELSE PRINT 'ERROR MEM000633: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000633 ya existe';
GO

-- [60/153] Membresia legacy #634 — LUCIA DAYANA  CARDENAS AGUILAR (DNI 72064739) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000634')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000634',
        @IdUsuario          = N'72064739',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'19032026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 2700.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL009',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #634 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000634: ' + @M; ELSE PRINT 'ERROR MEM000634: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000634 ya existe';
GO

-- [61/153] Membresia legacy #636 — URIEL ULIANOV ALVARON YANAMA (DNI 73405063) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000636')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000636',
        @IdUsuario          = N'73405063',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'21032026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 1080.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = NULL,
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #636 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000636: ' + @M; ELSE PRINT 'ERROR MEM000636: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000636 ya existe';
GO

-- [62/153] Membresia legacy #638 — NAOMI SIOMARA NICOL BARRAZA GARCIA (DNI 62018675) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000638')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000638',
        @IdUsuario          = N'62018675',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'20032026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 3150.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL008',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #638 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000638: ' + @M; ELSE PRINT 'ERROR MEM000638: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000638 ya existe';
GO

-- [63/153] Membresia legacy #639 — KIARA ANGELY GRANDEZ CABELLO (DNI 61901038) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000639')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000639',
        @IdUsuario          = N'61901038',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'21032026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 1080.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL002',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #639 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000639: ' + @M; ELSE PRINT 'ERROR MEM000639: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000639 ya existe';
GO

-- [64/153] Membresia legacy #640 — DANNA MIREYA MUNAYCO CONDORI (DNI 62547773) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000640')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000640',
        @IdUsuario          = N'62547773',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'20032026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 2700.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL009',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #640 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000640: ' + @M; ELSE PRINT 'ERROR MEM000640: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000640 ya existe';
GO

-- [65/153] Membresia legacy #641 — ZAMIRA CHARLOTTE CAYRE PACHACAMA (DNI 61891330) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000641')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000641',
        @IdUsuario          = N'61891330',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'23032026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 2700.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL011',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #641 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000641: ' + @M; ELSE PRINT 'ERROR MEM000641: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000641 ya existe';
GO

-- [66/153] Membresia legacy #642 — DASHA IOANNYS QUIROZ DEZA (DNI 61510610) fin 2026-09-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000642')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000642',
        @IdUsuario          = N'61510610',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'23032026',
        @FechaFin           = N'30092026',
        @MontoTotal         = 2100.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL010',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #642 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000642: ' + @M; ELSE PRINT 'ERROR MEM000642: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000642 ya existe';
GO

-- [67/153] Membresia legacy #643 — MARIA  LLANOS RODRIGUEZ (DNI 62544760) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000643')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000643',
        @IdUsuario          = N'62544760',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'24032026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 1980.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = NULL,
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #643 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000643: ' + @M; ELSE PRINT 'ERROR MEM000643: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000643 ya existe';
GO

-- [68/153] Membresia legacy #644 — JURMIX ALBERTO CARBAJAL ROJAS (DNI 60469851) fin 2026-08-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000644')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000644',
        @IdUsuario          = N'60469851',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'23032026',
        @FechaFin           = N'30082026',
        @MontoTotal         = 1750.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL001',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #644 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000644: ' + @M; ELSE PRINT 'ERROR MEM000644: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000644 ya existe';
GO

-- [69/153] Membresia legacy #648 — JORGE ANTONIO CASAFRANCA VILLANO (DNI 60275890) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000648')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000648',
        @IdUsuario          = N'60275890',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'23032026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 2700.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = NULL,
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #648 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000648: ' + @M; ELSE PRINT 'ERROR MEM000648: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000648 ya existe';
GO

-- [70/153] Membresia legacy #649 — ADRIAN HUAHUAMULLO POMARI (DNI 73724021) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000649')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000649',
        @IdUsuario          = N'73724021',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'23032026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 2700.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = NULL,
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #649 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000649: ' + @M; ELSE PRINT 'ERROR MEM000649: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000649 ya existe';
GO

-- [71/153] Membresia legacy #653 — GIANCARLO  MARIÑO GARCIA (DNI 74300675) fin 2026-12-31 estado activa
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000653')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000653',
        @IdUsuario          = N'74300675',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'24032026',
        @FechaFin           = N'31122026',
        @MontoTotal         = 1.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL006',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #653 | Asesor: JESÚS | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'10033907',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000653: ' + @M; ELSE PRINT 'ERROR MEM000653: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000653 ya existe';
GO

-- [72/153] Membresia legacy #654 — ESTEBAN BERNABE CHIPANA VERA (DNI 45976762) fin 2026-12-31 estado activa
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000654')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000654',
        @IdUsuario          = N'45976762',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'24032026',
        @FechaFin           = N'31122026',
        @MontoTotal         = 1.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL006',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #654 | Asesor: JESÚS | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'10033907',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000654: ' + @M; ELSE PRINT 'ERROR MEM000654: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000654 ya existe';
GO

-- [73/153] Membresia legacy #655 — JEFERSON JOSE CIEZA HUAMBACHANO (DNI 70399417) fin 2026-12-31 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000655')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000655',
        @IdUsuario          = N'70399417',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'24032026',
        @FechaFin           = N'31122026',
        @MontoTotal         = 3150.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL006',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #655 | Asesor: JESÚS | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'10033907',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000655: ' + @M; ELSE PRINT 'ERROR MEM000655: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000655 ya existe';
GO

-- [74/153] Membresia legacy #657 — MIGUEL ÁNGEL ALBERTO ALE (DNI 41581670) fin 2026-12-31 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000657')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000657',
        @IdUsuario          = N'41581670',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'24032026',
        @FechaFin           = N'31122026',
        @MontoTotal         = 3150.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL006',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #657 | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'10033907',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000657: ' + @M; ELSE PRINT 'ERROR MEM000657: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000657 ya existe';
GO

-- [75/153] Membresia legacy #658 — LUÍS ALBERTO YACTAYO OJEDA (DNI 10234238) fin 2026-12-31 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000658')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000658',
        @IdUsuario          = N'10234238',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'24032026',
        @FechaFin           = N'31122026',
        @MontoTotal         = 3150.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL006',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #658 | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'10033907',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000658: ' + @M; ELSE PRINT 'ERROR MEM000658: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000658 ya existe';
GO

-- [76/153] Membresia legacy #659 — 	CIRILO ALFONSO  MAURICIO VERASTEGUI (DNI 10748993) fin 2026-12-31 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000659')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000659',
        @IdUsuario          = N'10748993',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'24032026',
        @FechaFin           = N'31122026',
        @MontoTotal         = 3150.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL006',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #659 | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'10033907',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000659: ' + @M; ELSE PRINT 'ERROR MEM000659: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000659 ya existe';
GO

-- [77/153] Membresia legacy #660 — MARGOT LÓPEZ (DNI 44745110) fin 2026-12-31 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000660')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000660',
        @IdUsuario          = N'44745110',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'24032026',
        @FechaFin           = N'31122026',
        @MontoTotal         = 3150.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL006',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #660 | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'10033907',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000660: ' + @M; ELSE PRINT 'ERROR MEM000660: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000660 ya existe';
GO

-- [78/153] Membresia legacy #661 — WILLIAM PAUL SANCHEZ ZARATE (DNI 61355000) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000661')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000661',
        @IdUsuario          = N'61355000',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'25032026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 2700.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = NULL,
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #661 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000661: ' + @M; ELSE PRINT 'ERROR MEM000661: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000661 ya existe';
GO

-- [79/153] Membresia legacy #662 — FREDY ALFARO CHAVEZ ASESOR ACADEMICO (DNI 41591259) fin 2026-12-31 estado activa
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

-- [80/153] Membresia legacy #663 — JESÚS SALINAS  (DNI 10033907) fin 2026-10-31 estado con deuda
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

-- [81/153] Membresia legacy #664 — FERNANDA MORALES VASQUEZ (DNI 73878120) fin 2026-12-31 estado con deuda
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

-- [82/153] Membresia legacy #665 — SARA HUAMAN SALINAS (DNI 74806860) fin 2026-12-31 estado activa
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

-- [83/153] Membresia legacy #666 — STEFANO QUISPE BALDEON (DNI 61364448) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000666')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000666',
        @IdUsuario          = N'61364448',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'27032026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 3150.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL008',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #666 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000666: ' + @M; ELSE PRINT 'ERROR MEM000666: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000666 ya existe';
GO

-- [84/153] Membresia legacy #667 — MILAGROS CANELA QUISPE MAMANI (DNI 61033502) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000667')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000667',
        @IdUsuario          = N'61033502',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'27032026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 3150.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL010',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #667 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000667: ' + @M; ELSE PRINT 'ERROR MEM000667: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000667 ya existe';
GO

-- [85/153] Membresia legacy #668 — CARMEN ELENA CAMARO PEREZ (DNI 02306330) fin 2026-12-31 estado activa
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000668')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000668',
        @IdUsuario          = N'02306330',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'26032026',
        @FechaFin           = N'31122026',
        @MontoTotal         = 1.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL007',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #668 | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'10033907',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000668: ' + @M; ELSE PRINT 'ERROR MEM000668: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000668 ya existe';
GO

-- [86/153] Membresia legacy #669 — SANTOS CLORINDA SANDOVAL RAMIREZ (DNI 41024168) fin 2026-12-31 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000669')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000669',
        @IdUsuario          = N'41024168',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'26032026',
        @FechaFin           = N'31122026',
        @MontoTotal         = 3150.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL007',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #669 | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'10033907',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000669: ' + @M; ELSE PRINT 'ERROR MEM000669: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000669 ya existe';
GO

-- [87/153] Membresia legacy #670 — MARÍA MAGALY  SALINAS CARRANZA (DNI 41320903) fin 2026-12-31 estado activa
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000670')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000670',
        @IdUsuario          = N'41320903',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'26032026',
        @FechaFin           = N'31122026',
        @MontoTotal         = 1.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL007',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #670 | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'10033907',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000670: ' + @M; ELSE PRINT 'ERROR MEM000670: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000670 ya existe';
GO

-- [88/153] Membresia legacy #671 — ANDREA JIMENA CORREA CALIZAYA (DNI 61118481) fin 2026-12-31 estado activa
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000671')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000671',
        @IdUsuario          = N'61118481',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'26032026',
        @FechaFin           = N'31122026',
        @MontoTotal         = 1.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL007',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #671 | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'10033907',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000671: ' + @M; ELSE PRINT 'ERROR MEM000671: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000671 ya existe';
GO

-- [89/153] Membresia legacy #674 — FAIRUZ SILVIA RIOS ZAMBRANO (DNI 75234130) fin 2026-12-31 estado activa
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

-- [90/153] Membresia legacy #676 — GUILLERMO SALVADOR QUINTANA HUACCHILLO (DNI 61031108) fin 2026-12-31 estado activa
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000676')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000676',
        @IdUsuario          = N'61031108',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'27032026',
        @FechaFin           = N'31122026',
        @MontoTotal         = 1.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL007',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #676 | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'10033907',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000676: ' + @M; ELSE PRINT 'ERROR MEM000676: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000676 ya existe';
GO

-- [91/153] Membresia legacy #677 — EDICER DEL VALLE TOCUYO MACIAS (DNI 06597413) fin 2026-12-31 estado activa
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000677')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000677',
        @IdUsuario          = N'06597413',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'27032026',
        @FechaFin           = N'31122026',
        @MontoTotal         = 1.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL007',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #677 | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'10033907',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000677: ' + @M; ELSE PRINT 'ERROR MEM000677: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000677 ya existe';
GO

-- [92/153] Membresia legacy #679 — GERSSON  FLORES MAMANI (DNI 47880339) fin 2026-12-31 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000679')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000679',
        @IdUsuario          = N'47880339',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'27032026',
        @FechaFin           = N'31122026',
        @MontoTotal         = 3150.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL007',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #679 | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'10033907',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000679: ' + @M; ELSE PRINT 'ERROR MEM000679: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000679 ya existe';
GO

-- [93/153] Membresia legacy #681 — RUT BETSA  SAMANAMU ROJAS (DNI 61497190) fin 2026-08-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000681')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000681',
        @IdUsuario          = N'61497190',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'31032026',
        @FechaFin           = N'30082026',
        @MontoTotal         = 1250.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL005',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #681 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'41591259',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000681: ' + @M; ELSE PRINT 'ERROR MEM000681: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000681 ya existe';
GO

-- [94/153] Membresia legacy #682 — ALEXANDRA IRAYDA MARZANO GOMEZ (DNI 61948069) fin 2026-08-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000682')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000682',
        @IdUsuario          = N'61948069',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'31032026',
        @FechaFin           = N'30082026',
        @MontoTotal         = 2500.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL001',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #682 | Asesor: JESUS | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'41591259',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000682: ' + @M; ELSE PRINT 'ERROR MEM000682: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000682 ya existe';
GO

-- [95/153] Membresia legacy #683 — XIARA JIMENA SEGAMA MENDOZA (DNI 70714607) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000683')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000683',
        @IdUsuario          = N'70714607',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'01042026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 3150.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = NULL,
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #683 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000683: ' + @M; ELSE PRINT 'ERROR MEM000683: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000683 ya existe';
GO

-- [96/153] Membresia legacy #684 — KIARA MELINA ALDERETE GARCIA (DNI 60800847) fin 2026-08-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000684')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000684',
        @IdUsuario          = N'60800847',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'01042026',
        @FechaFin           = N'30082026',
        @MontoTotal         = 1750.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL001',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #684 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000684: ' + @M; ELSE PRINT 'ERROR MEM000684: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000684 ya existe';
GO

-- [97/153] Membresia legacy #686 — MEDALY TREBEJO SAAVEDRA (DNI 77761993) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000686')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000686',
        @IdUsuario          = N'77761993',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'04042026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 960.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL002',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #686 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000686: ' + @M; ELSE PRINT 'ERROR MEM000686: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000686 ya existe';
GO

-- [98/153] Membresia legacy #690 — IKER ALONSO PICHIHUA ALATA (DNI 77629601) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000690')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000690',
        @IdUsuario          = N'77629601',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'04042026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 960.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL003',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #690 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000690: ' + @M; ELSE PRINT 'ERROR MEM000690: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000690 ya existe';
GO

-- [99/153] Membresia legacy #691 — LUCIO VALENTIN SANDOVAL CASTAÑEDA (DNI 73547798) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000691')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000691',
        @IdUsuario          = N'73547798',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'06042026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 2400.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL009',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #691 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000691: ' + @M; ELSE PRINT 'ERROR MEM000691: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000691 ya existe';
GO

-- [100/153] Membresia legacy #697 — FELIX SALVADOR FREY ZANABRIA CAMASCA (DNI 72055929) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000697')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000697',
        @IdUsuario          = N'72055929',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'07042026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 2400.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = NULL,
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #697 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000697: ' + @M; ELSE PRINT 'ERROR MEM000697: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000697 ya existe';
GO

-- [101/153] Membresia legacy #699 — OSCAR MENDOZA HERNANDEZ (DNI 61506720) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000699')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000699',
        @IdUsuario          = N'61506720',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'07042026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 2800.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL012',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #699 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000699: ' + @M; ELSE PRINT 'ERROR MEM000699: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000699 ya existe';
GO

-- [102/153] Membresia legacy #700 — JOSS AYLI ANDIA FLORES (DNI 60295980) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000700')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000700',
        @IdUsuario          = N'60295980',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'07042026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 2400.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL011',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #700 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000700: ' + @M; ELSE PRINT 'ERROR MEM000700: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000700 ya existe';
GO

-- [103/153] Membresia legacy #704 — ZADITH CRISTINA SANDOVAL ACHO (DNI 61851485) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000704')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000704',
        @IdUsuario          = N'61851485',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'09042026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 2400.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = NULL,
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #704 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000704: ' + @M; ELSE PRINT 'ERROR MEM000704: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000704 ya existe';
GO

-- [104/153] Membresia legacy #707 — REY ALEXANDER MONTAÑO HUACHUACO (DNI 75288169) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000707')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000707',
        @IdUsuario          = N'75288169',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'14042026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 2400.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = NULL,
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #707 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000707: ' + @M; ELSE PRINT 'ERROR MEM000707: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000707 ya existe';
GO

-- [105/153] Membresia legacy #709 — ESTEFANO JOSSET CONTRERAS ESPINOZA (DNI 61802112) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000709')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000709',
        @IdUsuario          = N'61802112',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'16042026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 2400.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL009',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #709 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000709: ' + @M; ELSE PRINT 'ERROR MEM000709: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000709 ya existe';
GO

-- [106/153] Membresia legacy #710 — JAIRO FRANCISCO CONTRERAS ESPINOZA (DNI 61295917) fin 2026-09-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000710')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000710',
        @IdUsuario          = N'61295917',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'16042026',
        @FechaFin           = N'30092026',
        @MontoTotal         = 1750.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL001',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #710 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000710: ' + @M; ELSE PRINT 'ERROR MEM000710: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000710 ya existe';
GO

-- [107/153] Membresia legacy #712 — CARIM JASER MATHIAS VELARDE RINCON (DNI 61759135) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000712')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000712',
        @IdUsuario          = N'61759135',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'20042026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 2400.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL011',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #712 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000712: ' + @M; ELSE PRINT 'ERROR MEM000712: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000712 ya existe';
GO

-- [108/153] Membresia legacy #714 — NELLY ELENA SINCE PINARES (DNI 61420550) fin 2026-09-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000714')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000714',
        @IdUsuario          = N'61420550',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'21042026',
        @FechaFin           = N'30092026',
        @MontoTotal         = 1750.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL001',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #714 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000714: ' + @M; ELSE PRINT 'ERROR MEM000714: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000714 ya existe';
GO

-- [109/153] Membresia legacy #716 — JADE ESTRELLA GOMEZ OSORIO (DNI 76719410) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000716')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000716',
        @IdUsuario          = N'76719410',
        @IdPlan             = N'PLN007',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'25042026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 960.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL002',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #716 | Asesor: FAIRUZ | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000716: ' + @M; ELSE PRINT 'ERROR MEM000716: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000716 ya existe';
GO

-- [110/153] Membresia legacy #719 — MIRYAM  PRADO MILLA  (DNI 09489925) fin 2026-12-31 estado activa
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000719')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000719',
        @IdUsuario          = N'09489925',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'24042026',
        @FechaFin           = N'31122026',
        @MontoTotal         = 1.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL006',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #719 | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'10033907',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000719: ' + @M; ELSE PRINT 'ERROR MEM000719: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000719 ya existe';
GO

-- [111/153] Membresia legacy #722 — KARIN BERROSPI ZELAYA (DNI 71186317) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000722')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000722',
        @IdUsuario          = N'71186317',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'28042026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 2800.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL010',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #722 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000722: ' + @M; ELSE PRINT 'ERROR MEM000722: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000722 ya existe';
GO

-- [112/153] Membresia legacy #726 — MARIANA FERNANDA VARGAS GUEVARA (DNI 73724531) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000726')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000726',
        @IdUsuario          = N'73724531',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'02052026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 2100.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL011',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #726 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000726: ' + @M; ELSE PRINT 'ERROR MEM000726: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000726 ya existe';
GO

-- [113/153] Membresia legacy #729 — MISSAEL UZIEL  ROBLES GAMBOA (DNI 78158981) fin 2026-12-31 estado activa
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000729')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000729',
        @IdUsuario          = N'78158981',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'04052026',
        @FechaFin           = N'31122026',
        @MontoTotal         = 1.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL007',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #729 | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'10033907',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000729: ' + @M; ELSE PRINT 'ERROR MEM000729: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000729 ya existe';
GO

-- [114/153] Membresia legacy #730 — KEISY LUCERO FERNANDEZ VILLALOBOS (DNI 61276113) fin 2026-09-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000730')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000730',
        @IdUsuario          = N'61276113',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'04052026',
        @FechaFin           = N'30092026',
        @MontoTotal         = 2000.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL001',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #730 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000730: ' + @M; ELSE PRINT 'ERROR MEM000730: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000730 ya existe';
GO

-- [115/153] Membresia legacy #734 — ASHLEY  CUYA ORIZANO (DNI 71731637) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000734')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000734',
        @IdUsuario          = N'71731637',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'11052026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 2450.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = NULL,
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #734 | Asesor: JESUS | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000734: ' + @M; ELSE PRINT 'ERROR MEM000734: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000734 ya existe';
GO

-- [116/153] Membresia legacy #738 — NICOLAS USURIAGA MINAYA (DNI 75645913) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000738')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000738',
        @IdUsuario          = N'75645913',
        @IdPlan             = N'PLN006',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'08052026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 1540.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL011',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #738 | Asesor: JESUS | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000738: ' + @M; ELSE PRINT 'ERROR MEM000738: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000738 ya existe';
GO

-- [117/153] Membresia legacy #739 — MILAGROS ESTHER MAYTA BACARREZ (DNI 61434762) fin 2026-11-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000739')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000739',
        @IdUsuario          = N'61434762',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'11052026',
        @FechaFin           = N'30112026',
        @MontoTotal         = 2100.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL001',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #739 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000739: ' + @M; ELSE PRINT 'ERROR MEM000739: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000739 ya existe';
GO

-- [118/153] Membresia legacy #740 — LUCY ESTELA RAYME VALDERRAMA (DNI 61901312) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000740')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000740',
        @IdUsuario          = N'61901312',
        @IdPlan             = N'PLN007',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'16052026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 840.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL002',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #740 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000740: ' + @M; ELSE PRINT 'ERROR MEM000740: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000740 ya existe';
GO

-- [119/153] Membresia legacy #742 — YAMILE VALERY SANCHEZ MALLMA (DNI 76793055) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000742')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000742',
        @IdUsuario          = N'76793055',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'18052026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 2450.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = NULL,
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #742 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000742: ' + @M; ELSE PRINT 'ERROR MEM000742: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000742 ya existe';
GO

-- [120/153] Membresia legacy #743 — BRUNO ALCIVIADES NEYRA RAMOS (DNI 74009072) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000743')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000743',
        @IdUsuario          = N'74009072',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'16052026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 840.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL002',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #743 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000743: ' + @M; ELSE PRINT 'ERROR MEM000743: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000743 ya existe';
GO

-- [121/153] Membresia legacy #744 — MASSIELL ROJAS ESPINOZA (DNI 78930326) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000744')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000744',
        @IdUsuario          = N'78930326',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'18052026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 2450.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL010',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #744 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000744: ' + @M; ELSE PRINT 'ERROR MEM000744: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000744 ya existe';
GO

-- [122/153] Membresia legacy #746 — DEISY MEDALY VICTORIO JUSTINIANO (DNI 61380799) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000746')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000746',
        @IdUsuario          = N'61380799',
        @IdPlan             = N'PLN002',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'18052026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 2100.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL011',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #746 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000746: ' + @M; ELSE PRINT 'ERROR MEM000746: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000746 ya existe';
GO

-- [123/153] Membresia legacy #747 — ARIANA MOSAURIETA RAMIREZ (DNI 62011023) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000747')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000747',
        @IdUsuario          = N'62011023',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'20052026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 2450.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL010',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #747 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000747: ' + @M; ELSE PRINT 'ERROR MEM000747: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000747 ya existe';
GO

-- [124/153] Membresia legacy #752 — MARIA FERNANDA GUEVARA ALVARADO (DNI 78156289) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000752')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000752',
        @IdUsuario          = N'78156289',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'25052026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 2100.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL011',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #752 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000752: ' + @M; ELSE PRINT 'ERROR MEM000752: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000752 ya existe';
GO

-- [125/153] Membresia legacy #753 — NICOLAS SNAYD CARDENAS RAZURI (DNI 74014440) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000753')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000753',
        @IdUsuario          = N'74014440',
        @IdPlan             = N'PLN002',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'25052026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 2100.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL011',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #753 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000753: ' + @M; ELSE PRINT 'ERROR MEM000753: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000753 ya existe';
GO

-- [126/153] Membresia legacy #754 — JOSE ALBERTO SILUPU PERNIA (DNI 71676613) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000754')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000754',
        @IdUsuario          = N'71676613',
        @IdPlan             = N'PLN002',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'27052026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 2100.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL011',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #754 | Asesor: FAIRUZ | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000754: ' + @M; ELSE PRINT 'ERROR MEM000754: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000754 ya existe';
GO

-- [127/153] Membresia legacy #755 — GRECIA IVETH MAMANI MAMANI (DNI 74128404) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000755')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000755',
        @IdUsuario          = N'74128404',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'27052026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 2450.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = NULL,
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #755 | Asesor: TABY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000755: ' + @M; ELSE PRINT 'ERROR MEM000755: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000755 ya existe';
GO

-- [128/153] Membresia legacy #757 — DIANA RAMIREZ ZUMBA (DNI 61596763) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000757')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000757',
        @IdUsuario          = N'61596763',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'30052026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 2450.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL010',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #757 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000757: ' + @M; ELSE PRINT 'ERROR MEM000757: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000757 ya existe';
GO

-- [129/153] Membresia legacy #762 — MARICIELO ESCARCENA ELIAS (DNI 71188061) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000762')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000762',
        @IdUsuario          = N'71188061',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'02062026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 2100.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL010',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #762 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000762: ' + @M; ELSE PRINT 'ERROR MEM000762: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000762 ya existe';
GO

-- [130/153] Membresia legacy #763 — MAGDYEL ARMACCANCCE PUMA (DNI 62587364) fin 2026-10-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000763')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000763',
        @IdUsuario          = N'62587364',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'02062026',
        @FechaFin           = N'30102026',
        @MontoTotal         = 1000.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL005',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #763 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000763: ' + @M; ELSE PRINT 'ERROR MEM000763: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000763 ya existe';
GO

-- [131/153] Membresia legacy #764 — JUAN DANIEL DIAZ HUAMANI (DNI 76896103) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000764')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000764',
        @IdUsuario          = N'76896103',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'03062026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 1320.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL010',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #764 | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000764: ' + @M; ELSE PRINT 'ERROR MEM000764: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000764 ya existe';
GO

-- [132/153] Membresia legacy #765 — GABRIELA  AVEDAÑO MOSCOSO (DNI 60815028) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000765')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000765',
        @IdUsuario          = N'60815028',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'04062026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 1080.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL010',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #765 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'41591259',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000765: ' + @M; ELSE PRINT 'ERROR MEM000765: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000765 ya existe';
GO

-- [133/153] Membresia legacy #766 — SHEYLA YULIZA MUÑICO FLORES (DNI 71683268) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000766')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000766',
        @IdUsuario          = N'71683268',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'04062026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 2100.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL010',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #766 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000766: ' + @M; ELSE PRINT 'ERROR MEM000766: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000766 ya existe';
GO

-- [134/153] Membresia legacy #767 — VICTOR MINAYA LOZADA (DNI 61852062) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000767')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000767',
        @IdUsuario          = N'61852062',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'06062026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 1800.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL011',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #767 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000767: ' + @M; ELSE PRINT 'ERROR MEM000767: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000767 ya existe';
GO

-- [135/153] Membresia legacy #768 — JEREMY NEYMAR  TINCO TEJADA (DNI 77373939) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000768')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000768',
        @IdUsuario          = N'77373939',
        @IdPlan             = N'PLN007',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'06062026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 720.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL003',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #768 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000768: ' + @M; ELSE PRINT 'ERROR MEM000768: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000768 ya existe';
GO

-- [136/153] Membresia legacy #770 — EVELYN JIMENA RIOS ARDILES (DNI 61250833) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000770')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000770',
        @IdUsuario          = N'61250833',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'09062026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 2100.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = NULL,
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #770 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000770: ' + @M; ELSE PRINT 'ERROR MEM000770: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000770 ya existe';
GO

-- [137/153] Membresia legacy #771 — DAYANNA YAZURY TITO RODAS (DNI 73559849) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000771')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000771',
        @IdUsuario          = N'73559849',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'08062026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 1800.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL011',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #771 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000771: ' + @M; ELSE PRINT 'ERROR MEM000771: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000771 ya existe';
GO

-- [138/153] Membresia legacy #772 — YARUMI CAMILA  VIDAL POVIS (DNI 62374449) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000772')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000772',
        @IdUsuario          = N'62374449',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'08062026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 1800.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL011',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #772 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000772: ' + @M; ELSE PRINT 'ERROR MEM000772: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000772 ya existe';
GO

-- [139/153] Membresia legacy #775 — LUZ ESTRELLA JESUSI JIMENEZ (DNI 74187032) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000775')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000775',
        @IdUsuario          = N'74187032',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'18062026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 1800.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL011',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #775 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000775: ' + @M; ELSE PRINT 'ERROR MEM000775: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000775 ya existe';
GO

-- [140/153] Membresia legacy #776 — AUDER  GUEVARA BARBOZA (DNI 45580526) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000776')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000776',
        @IdUsuario          = N'45580526',
        @IdPlan             = N'PLN004',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'24062026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 1080.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL010',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #776 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000776: ' + @M; ELSE PRINT 'ERROR MEM000776: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000776 ya existe';
GO

-- [141/153] Membresia legacy #777 — JOEL ADRIEL CONTRERAS PANIURA (DNI 61136536) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000777')
BEGIN
    INSERT INTO MENSUALIDAD (
        IDMENSUALIDAD, FECHAINICIO, FECHAFIN, ESTADOMIEMBRO, MONTOTOTAL, OBSERVACIONES,
        FECHAREGISTRO, HORAREGISTRO, IDPLAN, IDAULA, IDTURNO, IDUSUARIO, REGISTRADOPOR,
        IDTUTOR, FECHACANCELACION, ESTADO
    )
    SELECT
        N'MEM000777', N'30062026', N'30122026', 2, 2100.00, N'Import legacy membresia #777 | Asesor: FREDY | Tipo: INDIVIDUAL',
        dbo.fn_fecha_ddmmyyyy(), CONVERT(CHAR(8), GETDATE(), 108),
        N'PLN001', NULL, p.IDTURNO, N'61136536', N'72618032',
        NULL, NULL, N'Activo'
    FROM [PLAN] p WHERE p.IDPLAN = N'PLN001';
    PRINT 'OK MEM000777: insertado (usuario no estudiante)';
END
ELSE
    PRINT 'SKIP MEM000777 ya existe';
GO

-- [142/153] Membresia legacy #781 — FABIAN ANTUAN AGAPITO ARAUJO (DNI 93922779) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000781')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000781',
        @IdUsuario          = N'93922779',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'04072026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 900.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL002',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #781 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000781: ' + @M; ELSE PRINT 'ERROR MEM000781: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000781 ya existe';
GO

-- [143/153] Membresia legacy #782 — LUCIANA MILAGRITOS  MORA MORENO (DNI 73729192) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000782')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000782',
        @IdUsuario          = N'73729192',
        @IdPlan             = N'PLN002',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'01072026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 1800.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL011',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #782 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000782: ' + @M; ELSE PRINT 'ERROR MEM000782: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000782 ya existe';
GO

-- [144/153] Membresia legacy #783 — KEVIN PIERO QUIJANDRIA ORTIZ (DNI 72461131) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000783')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000783',
        @IdUsuario          = N'72461131',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'03072026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 1750.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL010',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #783 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000783: ' + @M; ELSE PRINT 'ERROR MEM000783: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000783 ya existe';
GO

-- [145/153] Membresia legacy #784 — FABIANA MIA VALENZUELA VILLALBA (DNI 62442709) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000784')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000784',
        @IdUsuario          = N'62442709',
        @IdPlan             = N'PLN005',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'04072026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 1100.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL010',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #784 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000784: ' + @M; ELSE PRINT 'ERROR MEM000784: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000784 ya existe';
GO

-- [146/153] Membresia legacy #785 — ANTONY SAMIR CAÑARI CANGALAYA (DNI 22222222) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000785')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000785',
        @IdUsuario          = N'22222222',
        @IdPlan             = N'PLN007',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'04072026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 600.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL002',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #785 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000785: ' + @M; ELSE PRINT 'ERROR MEM000785: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000785 ya existe';
GO

-- [147/153] Membresia legacy #786 — ROBERT ADRIANO SILVA URETA (DNI 62655954) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000786')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000786',
        @IdUsuario          = N'62655954',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'07072026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 1500.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL011',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #786 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000786: ' + @M; ELSE PRINT 'ERROR MEM000786: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000786 ya existe';
GO

-- [148/153] Membresia legacy #787 — ANTHONY MIJAEL DIAZ ALCALA (DNI 61852402) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000787')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000787',
        @IdUsuario          = N'61852402',
        @IdPlan             = N'PLN002',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'18072026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 1800.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL011',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #787 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000787: ' + @M; ELSE PRINT 'ERROR MEM000787: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000787 ya existe';
GO

-- [149/153] Membresia legacy #788 — DONOVAN SAENZ CASTILLA (DNI 61434811) fin 2026-09-21 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000788')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000788',
        @IdUsuario          = N'61434811',
        @IdPlan             = N'PLN009',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'21072026',
        @FechaFin           = N'21092026',
        @MontoTotal         = 700.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL001',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #788 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000788: ' + @M; ELSE PRINT 'ERROR MEM000788: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000788 ya existe';
GO

-- [150/153] Membresia legacy #791 — SAMANTA MAGNOLIA CAMARGO OLIVER (DNI 74475423) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000791')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000791',
        @IdUsuario          = N'74475423',
        @IdPlan             = N'PLN009',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'03082026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 2000.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL001',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #791 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000791: ' + @M; ELSE PRINT 'ERROR MEM000791: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000791 ya existe';
GO

-- [151/153] Membresia legacy #792 — JASMIN NORMA RECINA ROJAS (DNI 72060981) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000792')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000792',
        @IdUsuario          = N'72060981',
        @IdPlan             = N'PLN008',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'03082026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 750.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL005',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #792 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000792: ' + @M; ELSE PRINT 'ERROR MEM000792: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000792 ya existe';
GO

-- [152/153] Membresia legacy #794 — AYELEN LUANA BEGAZO ROJAS (DNI 63253740) fin 2026-12-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000794')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000794',
        @IdUsuario          = N'63253740',
        @IdPlan             = N'PLN001',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'03082026',
        @FechaFin           = N'30122026',
        @MontoTotal         = 1400.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL001',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #794 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000794: ' + @M; ELSE PRINT 'ERROR MEM000794: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000794 ya existe';
GO

-- [153/153] Membresia legacy #795 — BIANCA JIMENA FLORES ARONI (DNI 61801187) fin 2026-11-30 estado con deuda
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'MEM000795')
BEGIN
    DECLARE @R INT, @M NVARCHAR(200);
    EXEC dbo.usp_mensualidad_insertar
        @Id                 = N'MEM000795',
        @IdUsuario          = N'61801187',
        @IdPlan             = N'PLN008',
        @EstadoMiembro      = 2,
        @FechaInicio        = N'04082026',
        @FechaFin           = N'30112026',
        @MontoTotal         = 1400.00,
        @PagoInicial        = 0,
        @IdMetodoPago       = NULL,
        @IdAula             = N'AUL005',
        @IdTutor            = NULL,
        @Observaciones      = N'Import legacy membresia #795 | Asesor: FREDY | Tipo: INDIVIDUAL',
        @FechaCancelacion   = NULL,
        @RegistradoPor      = N'72618032',
        @Resultado          = @R OUTPUT,
        @Mensaje            = @M OUTPUT;
    IF @R = 1 PRINT 'OK MEM000795: ' + @M; ELSE PRINT 'ERROR MEM000795: ' + @M;
END
ELSE
    PRINT 'SKIP MEM000795 ya existe';
GO
