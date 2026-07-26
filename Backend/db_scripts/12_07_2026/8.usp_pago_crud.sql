/* ============================================================================
   Pagos: listar, abonar membresía, últimas 3 membresías con deuda
   Ejecutar después de 6.usp_membresia_estado_registro.sql
   Fecha: 12/07/2026
   ============================================================================ */

IF OBJECT_ID('dbo.usp_pago_listar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_pago_listar;
GO
CREATE PROCEDURE dbo.usp_pago_listar
    @Buscar         NVARCHAR(200) = NULL,
    @OrdenarPor     NVARCHAR(50)  = 'FECHAPAGO',
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
    FROM PAGOMEMBRESIA p
    INNER JOIN MEMBRESIA m ON m.IDMEMBRESIA = p.IDMEMBRESIA
    INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
    INNER JOIN [PLAN] pl ON pl.IDPLAN = m.IDPLAN
    LEFT JOIN METODO_PAGO mp ON mp.IDMETODOPAGO = p.IDMETODOPAGO
    WHERE (@Buscar IS NULL OR @Buscar = '' OR
           p.IDPAGOMEMBRESIA LIKE '%' + @Buscar + '%' OR
           m.IDMEMBRESIA LIKE '%' + @Buscar + '%' OR
           u.DNI LIKE '%' + @Buscar + '%' OR
           u.NOMBRE LIKE '%' + @Buscar + '%' OR
           u.APELLIDO LIKE '%' + @Buscar + '%' OR
           pl.NOMBRE LIKE '%' + @Buscar + '%' OR
           ISNULL(mp.TITULO, '') LIKE '%' + @Buscar + '%');

    SELECT
        p.IDPAGOMEMBRESIA,
        p.IDMEMBRESIA,
        p.MONTO,
        p.FECHAPAGO,
        p.HORAPAGO,
        p.OBSERVACIONES,
        p.IDMETODOPAGO,
        ISNULL(mp.TITULO, '') AS METODOPAGO_TITULO,
        UPPER(LTRIM(RTRIM(ISNULL(u.APELLIDO, '') + ' ' + ISNULL(u.NOMBRE, '')))) AS ESTUDIANTE_NOMBRE,
        u.DNI AS ESTUDIANTE_DNI,
        pl.NOMBRE AS PLAN_NOMBRE
    FROM PAGOMEMBRESIA p
    INNER JOIN MEMBRESIA m ON m.IDMEMBRESIA = p.IDMEMBRESIA
    INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
    INNER JOIN [PLAN] pl ON pl.IDPLAN = m.IDPLAN
    LEFT JOIN METODO_PAGO mp ON mp.IDMETODOPAGO = p.IDMETODOPAGO
    WHERE (@Buscar IS NULL OR @Buscar = '' OR
           p.IDPAGOMEMBRESIA LIKE '%' + @Buscar + '%' OR
           m.IDMEMBRESIA LIKE '%' + @Buscar + '%' OR
           u.DNI LIKE '%' + @Buscar + '%' OR
           u.NOMBRE LIKE '%' + @Buscar + '%' OR
           u.APELLIDO LIKE '%' + @Buscar + '%' OR
           pl.NOMBRE LIKE '%' + @Buscar + '%' OR
           ISNULL(mp.TITULO, '') LIKE '%' + @Buscar + '%')
    ORDER BY
        CASE WHEN @OrdenarPor = 'FECHAPAGO' AND @Direccion = 'ASC'  THEN p.FECHAPAGO END ASC,
        CASE WHEN @OrdenarPor = 'FECHAPAGO' AND @Direccion = 'DESC' THEN p.FECHAPAGO END DESC,
        CASE WHEN @OrdenarPor = 'MONTO' AND @Direccion = 'ASC'  THEN p.MONTO END ASC,
        CASE WHEN @OrdenarPor = 'MONTO' AND @Direccion = 'DESC' THEN p.MONTO END DESC,
        CASE WHEN @OrdenarPor = 'ESTUDIANTE_NOMBRE' AND @Direccion = 'ASC'  THEN u.APELLIDO END ASC,
        CASE WHEN @OrdenarPor = 'ESTUDIANTE_NOMBRE' AND @Direccion = 'DESC' THEN u.APELLIDO END DESC,
        CASE WHEN @OrdenarPor = 'IDPAGOMEMBRESIA' AND @Direccion = 'ASC'  THEN p.IDPAGOMEMBRESIA END ASC,
        CASE WHEN @OrdenarPor = 'IDPAGOMEMBRESIA' AND @Direccion = 'DESC' THEN p.IDPAGOMEMBRESIA END DESC,
        p.FECHAPAGO DESC, p.HORAPAGO DESC, p.IDPAGOMEMBRESIA DESC
    OFFSET (@Pagina - 1) * @TamanioPagina ROWS
    FETCH NEXT @TamanioPagina ROWS ONLY;
END;
GO

IF OBJECT_ID('dbo.usp_pago_membresias_estudiante', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_pago_membresias_estudiante;
GO
CREATE PROCEDURE dbo.usp_pago_membresias_estudiante
    @IdUsuario NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP 3
        m.IDMEMBRESIA,
        m.IDPLAN,
        pl.NOMBRE AS PLAN_NOMBRE,
        m.FECHAINICIO,
        m.FECHAFIN,
        m.MONTOTOTAL,
        ISNULL(pag.PAGADO, 0) AS PAGADO,
        CASE
            WHEN ISNULL(m.MONTOTOTAL, 0) - ISNULL(pag.PAGADO, 0) < 0 THEN 0
            ELSE ISNULL(m.MONTOTOTAL, 0) - ISNULL(pag.PAGADO, 0)
        END AS DEUDA,
        m.ESTADOMIEMBRO,
        CASE m.ESTADOMIEMBRO
            WHEN 2 THEN 'Activo'
            WHEN 3 THEN 'Vencido'
            ELSE 'Activo'
        END AS ESTADOMIEMBRO_DESCRIPCION,
        m.ESTADO,
        m.FECHAREGISTRO
    FROM MEMBRESIA m
    INNER JOIN [PLAN] pl ON pl.IDPLAN = m.IDPLAN
    OUTER APPLY (
        SELECT SUM(p.MONTO) AS PAGADO
        FROM PAGOMEMBRESIA p
        WHERE p.IDMEMBRESIA = m.IDMEMBRESIA
    ) pag
    WHERE m.IDUSUARIO = @IdUsuario
      AND m.ESTADO = 'Activo'
    ORDER BY m.FECHAREGISTRO DESC, m.IDMEMBRESIA DESC;
END;
GO

IF OBJECT_ID('dbo.usp_pago_insertar_abono', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_pago_insertar_abono;
GO
CREATE PROCEDURE dbo.usp_pago_insertar_abono
    @IdMembresia    NVARCHAR(50),
    @Monto          DECIMAL(10,2),
    @IdMetodoPago   NVARCHAR(50),
    @Observaciones  NVARCHAR(MAX) = NULL,
    @RegistradoPor  NVARCHAR(50)  = NULL,
    @Resultado      INT OUTPUT,
    @Mensaje        NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF @IdMembresia IS NULL OR @IdMembresia = ''
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Debe seleccionar una membresía.'; RETURN; END
    IF @Monto IS NULL OR @Monto <= 0
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ingrese un monto válido.'; RETURN; END
    IF @IdMetodoPago IS NULL OR @IdMetodoPago = ''
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Indique el método de pago.'; RETURN; END

    IF NOT EXISTS (SELECT 1 FROM MEMBRESIA WHERE IDMEMBRESIA = @IdMembresia AND ESTADO = 'Activo')
    BEGIN SET @Resultado = 0; SET @Mensaje = 'La membresía no existe o está inactiva.'; RETURN; END

    IF NOT EXISTS (SELECT 1 FROM METODO_PAGO WHERE IDMETODOPAGO = @IdMetodoPago AND ACTIVO = 1)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El método de pago no es válido.'; RETURN; END

    DECLARE @MontoTotal DECIMAL(10,2);
    DECLARE @Pagado DECIMAL(10,2);
    DECLARE @Deuda DECIMAL(10,2);

    SELECT @MontoTotal = ISNULL(MONTOTOTAL, 0) FROM MEMBRESIA WHERE IDMEMBRESIA = @IdMembresia;
    SELECT @Pagado = ISNULL(SUM(MONTO), 0) FROM PAGOMEMBRESIA WHERE IDMEMBRESIA = @IdMembresia;
    SET @Deuda = @MontoTotal - @Pagado;
    IF @Deuda < 0 SET @Deuda = 0;

    IF @Deuda <= 0
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Esta membresía no tiene deuda pendiente.'; RETURN; END
    IF @Monto > @Deuda
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El abono no puede superar la deuda (S/ ' + CAST(@Deuda AS NVARCHAR(20)) + ').'; RETURN; END

    DECLARE @IdPago NVARCHAR(50) = 'PAG' + RIGHT('000000' + CAST((
        ISNULL((SELECT MAX(TRY_CAST(SUBSTRING(IDPAGOMEMBRESIA, 4, 10) AS INT))
                FROM PAGOMEMBRESIA WHERE IDPAGOMEMBRESIA LIKE 'PAG%'), 0) + 1
    ) AS VARCHAR(10)), 6);

    INSERT INTO PAGOMEMBRESIA (
        IDPAGOMEMBRESIA, MONTO, FECHAPAGO, HORAPAGO, OBSERVACIONES,
        IDMEMBRESIA, IDMETODOPAGO, IDUSUARIO
    ) VALUES (
        @IdPago, @Monto, dbo.fn_fecha_ddmmyyyy(), CONVERT(CHAR(8), GETDATE(), 108),
        ISNULL(NULLIF(@Observaciones, ''), 'Abono'),
        @IdMembresia, @IdMetodoPago, @RegistradoPor
    );

    SET @Resultado = 1;
    SET @Mensaje = 'Abono registrado correctamente.';
END;
GO

PRINT 'SPs de pagos creados: listar, abono, membresías del estudiante.';
GO
