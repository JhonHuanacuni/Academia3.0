/* ============================================================================
   Pagos extraordinarios: últimos conceptos del estudiante (panel Nuevo pago)
   Fecha: 16/07/2026
   ============================================================================ */

IF OBJECT_ID('dbo.usp_pagoextra_listar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_pagoextra_listar;
GO
CREATE PROCEDURE dbo.usp_pagoextra_listar
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
    FROM PAGOEXTRAORDINARIO p
    INNER JOIN USUARIO u ON u.IDUSUARIO = p.IDUSUARIO
    INNER JOIN CONCEPTOPAGOEXTRA c ON c.IDCONCEPTO = p.IDCONCEPTO
    WHERE (@Buscar IS NULL OR @Buscar = '' OR
           p.IDPAGOEXTRA LIKE '%' + @Buscar + '%' OR
           u.NOMBRE LIKE '%' + @Buscar + '%' OR
           u.APELLIDO LIKE '%' + @Buscar + '%' OR
           u.DNI LIKE '%' + @Buscar + '%' OR
           c.NOMBRE LIKE '%' + @Buscar + '%');

    SELECT
        p.IDPAGOEXTRA,
        p.IDUSUARIO,
        UPPER(LTRIM(RTRIM(ISNULL(u.APELLIDO, '') + ' ' + ISNULL(u.NOMBRE, '')))) AS ESTUDIANTE_NOMBRE,
        u.DNI AS ESTUDIANTE_DNI,
        p.IDCONCEPTO,
        c.NOMBRE AS CONCEPTO_NOMBRE,
        p.MONTO,
        p.FECHAPAGO,
        p.OBSERVACIONES
    FROM PAGOEXTRAORDINARIO p
    INNER JOIN USUARIO u ON u.IDUSUARIO = p.IDUSUARIO
    INNER JOIN CONCEPTOPAGOEXTRA c ON c.IDCONCEPTO = p.IDCONCEPTO
    WHERE (@Buscar IS NULL OR @Buscar = '' OR
           p.IDPAGOEXTRA LIKE '%' + @Buscar + '%' OR
           u.NOMBRE LIKE '%' + @Buscar + '%' OR
           u.APELLIDO LIKE '%' + @Buscar + '%' OR
           u.DNI LIKE '%' + @Buscar + '%' OR
           c.NOMBRE LIKE '%' + @Buscar + '%')
    ORDER BY
        CASE WHEN @OrdenarPor = 'FECHAPAGO' AND @Direccion = 'ASC'  THEN p.FECHAPAGO END ASC,
        CASE WHEN @OrdenarPor = 'FECHAPAGO' AND @Direccion = 'DESC' THEN p.FECHAPAGO END DESC,
        CASE WHEN @OrdenarPor = 'MONTO' AND @Direccion = 'ASC' THEN p.MONTO END ASC,
        CASE WHEN @OrdenarPor = 'MONTO' AND @Direccion = 'DESC' THEN p.MONTO END DESC,
        CASE WHEN @OrdenarPor = 'ESTUDIANTE_NOMBRE' AND @Direccion = 'ASC' THEN u.APELLIDO END ASC,
        CASE WHEN @OrdenarPor = 'ESTUDIANTE_NOMBRE' AND @Direccion = 'DESC' THEN u.APELLIDO END DESC,
        CASE WHEN @OrdenarPor = 'CONCEPTO_NOMBRE' AND @Direccion = 'ASC' THEN c.NOMBRE END ASC,
        CASE WHEN @OrdenarPor = 'CONCEPTO_NOMBRE' AND @Direccion = 'DESC' THEN c.NOMBRE END DESC,
        p.FECHAPAGO DESC, p.IDPAGOEXTRA DESC
    OFFSET (@Pagina - 1) * @TamanioPagina ROWS
    FETCH NEXT @TamanioPagina ROWS ONLY;
END;
GO

IF OBJECT_ID('dbo.usp_pagoextra_conceptos_estudiante', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_pagoextra_conceptos_estudiante;
GO
CREATE PROCEDURE dbo.usp_pagoextra_conceptos_estudiante
    @IdUsuario NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP 5
        c.IDCONCEPTO,
        c.NOMBRE AS CONCEPTO_NOMBRE,
        c.COSTO,
        c.FECHAINICIO,
        c.FECHAFIN,
        ISNULL(SUM(p.MONTO), 0) AS PAGADO,
        CASE
            WHEN c.COSTO - ISNULL(SUM(p.MONTO), 0) < 0 THEN 0
            ELSE c.COSTO - ISNULL(SUM(p.MONTO), 0)
        END AS DEUDA,
        MAX(p.FECHAPAGO) AS ULTIMOPAGO
    FROM CONCEPTOPAGOEXTRA c
    INNER JOIN PAGOEXTRAORDINARIO p
        ON p.IDCONCEPTO = c.IDCONCEPTO AND p.IDUSUARIO = @IdUsuario
    GROUP BY c.IDCONCEPTO, c.NOMBRE, c.COSTO, c.FECHAINICIO, c.FECHAFIN
    ORDER BY MAX(p.FECHAPAGO) DESC;
END;
GO

PRINT 'usp_pagoextra_listar restaurado; usp_pagoextra_conceptos_estudiante creado.';
GO
