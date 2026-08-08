/* ============================================================================
   Pagos extraordinarios: listado agrupado por estudiante + concepto
   + detalle de pagos individuales
   Ejecutar después de 16_07_2026/9.pagoextra_deuda_conceptos_estudiante.sql
   Fecha: 31/07/2026
   ============================================================================ */

IF OBJECT_ID('dbo.usp_pagoextra_listar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_pagoextra_listar;
GO
CREATE PROCEDURE dbo.usp_pagoextra_listar
    @Buscar         NVARCHAR(200) = NULL,
    @OrdenarPor     NVARCHAR(50)  = 'ULTIMO_PAGO',
    @Direccion      NVARCHAR(4)   = 'DESC',
    @Pagina         INT           = 1,
    @TamanioPagina  INT           = 10,
    @TotalRegistros INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    IF @Pagina < 1 SET @Pagina = 1;
    IF @TamanioPagina < 1 SET @TamanioPagina = 10;

    ;WITH Base AS (
        SELECT
            p.IDUSUARIO,
            p.IDCONCEPTO,
            UPPER(LTRIM(RTRIM(ISNULL(u.APELLIDO, '') + ' ' + ISNULL(u.NOMBRE, '')))) AS ESTUDIANTE_NOMBRE,
            u.DNI AS ESTUDIANTE_DNI,
            c.NOMBRE AS CONCEPTO_NOMBRE,
            c.COSTO AS MONTO_TOTAL,
            ISNULL(SUM(p.MONTO), 0) AS PAGADO,
            CASE
                WHEN c.COSTO - ISNULL(SUM(p.MONTO), 0) < 0 THEN 0
                ELSE c.COSTO - ISNULL(SUM(p.MONTO), 0)
            END AS DEUDA,
            COUNT(p.IDPAGOEXTRA) AS CANTIDAD_PAGOS,
            MAX(p.FECHAPAGO) AS ULTIMO_PAGO
        FROM PAGOEXTRAORDINARIO p
        INNER JOIN USUARIO u ON u.IDUSUARIO = p.IDUSUARIO
        INNER JOIN CONCEPTOPAGOEXTRA c ON c.IDCONCEPTO = p.IDCONCEPTO
        WHERE (@Buscar IS NULL OR @Buscar = '' OR
               u.NOMBRE LIKE '%' + @Buscar + '%' OR
               u.APELLIDO LIKE '%' + @Buscar + '%' OR
               u.DNI LIKE '%' + @Buscar + '%' OR
               c.NOMBRE LIKE '%' + @Buscar + '%')
        GROUP BY p.IDUSUARIO, p.IDCONCEPTO, u.APELLIDO, u.NOMBRE, u.DNI, c.NOMBRE, c.COSTO
    )
    SELECT @TotalRegistros = COUNT(*) FROM Base;

    ;WITH Base AS (
        SELECT
            p.IDUSUARIO,
            p.IDCONCEPTO,
            UPPER(LTRIM(RTRIM(ISNULL(u.APELLIDO, '') + ' ' + ISNULL(u.NOMBRE, '')))) AS ESTUDIANTE_NOMBRE,
            u.DNI AS ESTUDIANTE_DNI,
            c.NOMBRE AS CONCEPTO_NOMBRE,
            c.COSTO AS MONTO_TOTAL,
            ISNULL(SUM(p.MONTO), 0) AS PAGADO,
            CASE
                WHEN c.COSTO - ISNULL(SUM(p.MONTO), 0) < 0 THEN 0
                ELSE c.COSTO - ISNULL(SUM(p.MONTO), 0)
            END AS DEUDA,
            COUNT(p.IDPAGOEXTRA) AS CANTIDAD_PAGOS,
            MAX(p.FECHAPAGO) AS ULTIMO_PAGO
        FROM PAGOEXTRAORDINARIO p
        INNER JOIN USUARIO u ON u.IDUSUARIO = p.IDUSUARIO
        INNER JOIN CONCEPTOPAGOEXTRA c ON c.IDCONCEPTO = p.IDCONCEPTO
        WHERE (@Buscar IS NULL OR @Buscar = '' OR
               u.NOMBRE LIKE '%' + @Buscar + '%' OR
               u.APELLIDO LIKE '%' + @Buscar + '%' OR
               u.DNI LIKE '%' + @Buscar + '%' OR
               c.NOMBRE LIKE '%' + @Buscar + '%')
        GROUP BY p.IDUSUARIO, p.IDCONCEPTO, u.APELLIDO, u.NOMBRE, u.DNI, c.NOMBRE, c.COSTO
    )
    SELECT
        b.IDUSUARIO + '|' + b.IDCONCEPTO AS GRUPO_KEY,
        b.IDUSUARIO,
        b.ESTUDIANTE_NOMBRE,
        b.ESTUDIANTE_DNI,
        b.IDCONCEPTO,
        b.CONCEPTO_NOMBRE,
        b.MONTO_TOTAL,
        b.PAGADO,
        b.DEUDA,
        b.CANTIDAD_PAGOS,
        b.ULTIMO_PAGO
    FROM Base b
    ORDER BY
        CASE WHEN @OrdenarPor = 'DEUDA' AND @Direccion = 'ASC' THEN b.DEUDA END ASC,
        CASE WHEN @OrdenarPor = 'DEUDA' AND @Direccion = 'DESC' THEN b.DEUDA END DESC,
        CASE WHEN @OrdenarPor = 'PAGADO' AND @Direccion = 'ASC' THEN b.PAGADO END ASC,
        CASE WHEN @OrdenarPor = 'PAGADO' AND @Direccion = 'DESC' THEN b.PAGADO END DESC,
        CASE WHEN @OrdenarPor = 'MONTO_TOTAL' AND @Direccion = 'ASC' THEN b.MONTO_TOTAL END ASC,
        CASE WHEN @OrdenarPor = 'MONTO_TOTAL' AND @Direccion = 'DESC' THEN b.MONTO_TOTAL END DESC,
        CASE WHEN @OrdenarPor IN ('FECHAPAGO', 'ULTIMO_PAGO') AND @Direccion = 'ASC' THEN b.ULTIMO_PAGO END ASC,
        CASE WHEN @OrdenarPor IN ('FECHAPAGO', 'ULTIMO_PAGO') AND @Direccion = 'DESC' THEN b.ULTIMO_PAGO END DESC,
        CASE WHEN @OrdenarPor = 'ESTUDIANTE_NOMBRE' AND @Direccion = 'ASC' THEN b.ESTUDIANTE_NOMBRE END ASC,
        CASE WHEN @OrdenarPor = 'ESTUDIANTE_NOMBRE' AND @Direccion = 'DESC' THEN b.ESTUDIANTE_NOMBRE END DESC,
        CASE WHEN @OrdenarPor = 'CONCEPTO_NOMBRE' AND @Direccion = 'ASC' THEN b.CONCEPTO_NOMBRE END ASC,
        CASE WHEN @OrdenarPor = 'CONCEPTO_NOMBRE' AND @Direccion = 'DESC' THEN b.CONCEPTO_NOMBRE END DESC,
        b.ULTIMO_PAGO DESC
    OFFSET (@Pagina - 1) * @TamanioPagina ROWS
    FETCH NEXT @TamanioPagina ROWS ONLY;
END;
GO

IF OBJECT_ID('dbo.usp_pagoextra_listar_detalle', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_pagoextra_listar_detalle;
GO
CREATE PROCEDURE dbo.usp_pagoextra_listar_detalle
    @IdUsuario NVARCHAR(50),
    @IdConcepto NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.IDPAGOEXTRA,
        p.IDUSUARIO,
        UPPER(LTRIM(RTRIM(ISNULL(u.APELLIDO, '') + ' ' + ISNULL(u.NOMBRE, '')))) AS ESTUDIANTE_NOMBRE,
        u.DNI AS ESTUDIANTE_DNI,
        p.IDCONCEPTO,
        c.NOMBRE AS CONCEPTO_NOMBRE,
        c.COSTO AS MONTO_TOTAL,
        p.MONTO,
        p.FECHAPAGO,
        p.OBSERVACIONES
    FROM PAGOEXTRAORDINARIO p
    INNER JOIN USUARIO u ON u.IDUSUARIO = p.IDUSUARIO
    INNER JOIN CONCEPTOPAGOEXTRA c ON c.IDCONCEPTO = p.IDCONCEPTO
    WHERE p.IDUSUARIO = @IdUsuario
      AND p.IDCONCEPTO = @IdConcepto
    ORDER BY p.FECHAPAGO DESC, p.IDPAGOEXTRA DESC;
END;
GO

PRINT 'usp_pagoextra_listar agrupado y usp_pagoextra_listar_detalle listos.';
GO
