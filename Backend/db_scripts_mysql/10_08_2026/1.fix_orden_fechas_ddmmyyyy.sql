-- ============================================================================
-- Orden cronológico de fechas CHAR(8) DDMMYYYY en listados
-- Convierte a YYYYMMDD para ORDER BY / MAX
-- Fecha: 10/08/2026
-- ============================================================================

USE `AcademiaDB`;

-- Expresión reusable (inline):
-- CONCAT(SUBSTRING(col,5,4), SUBSTRING(col,3,2), SUBSTRING(col,1,2))

/* ---------- PAGOS ---------- */
DROP PROCEDURE IF EXISTS usp_pago_listar;

DELIMITER $$

CREATE PROCEDURE usp_pago_listar(
    IN p_Buscar VARCHAR(200),
    IN p_OrdenarPor VARCHAR(50),
    IN p_Direccion VARCHAR(4),
    IN p_Pagina INT,
    IN p_TamanioPagina INT,
    OUT p_TotalRegistros INT
)
main: BEGIN
    DECLARE v_offset INT DEFAULT 0;

    IF p_Pagina < 1 THEN SET p_Pagina = 1; END IF;
    IF p_TamanioPagina < 1 THEN SET p_TamanioPagina = 10; END IF;
    SET v_offset = (p_Pagina - 1) * p_TamanioPagina;

    SELECT COUNT(*) INTO p_TotalRegistros
    FROM PAGOMENSUALIDAD p
    INNER JOIN MENSUALIDAD m ON m.IDMENSUALIDAD = p.IDMENSUALIDAD
    INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
    INNER JOIN `PLAN` pl ON pl.IDPLAN = m.IDPLAN
    LEFT JOIN METODO_PAGO mp ON mp.IDMETODOPAGO = p.IDMETODOPAGO
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           p.IDPAGOMENSUALIDAD LIKE CONCAT('%', p_Buscar, '%') OR
           m.IDMENSUALIDAD LIKE CONCAT('%', p_Buscar, '%') OR
           u.DNI LIKE CONCAT('%', p_Buscar, '%') OR
           u.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
           u.APELLIDO LIKE CONCAT('%', p_Buscar, '%') OR
           pl.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
           IFNULL(mp.TITULO, '') LIKE CONCAT('%', p_Buscar, '%'));

    SELECT
        p.IDPAGOMENSUALIDAD,
        p.IDMENSUALIDAD,
        p.MONTO,
        p.FECHAPAGO,
        p.HORAPAGO,
        p.OBSERVACIONES,
        p.IDMETODOPAGO,
        IFNULL(mp.TITULO, '') AS METODOPAGO_TITULO,
        UPPER(TRIM(CONCAT(IFNULL(u.APELLIDO, ''), ' ', IFNULL(u.NOMBRE, '')))) AS ESTUDIANTE_NOMBRE,
        u.DNI AS ESTUDIANTE_DNI,
        pl.NOMBRE AS PLAN_NOMBRE
    FROM PAGOMENSUALIDAD p
    INNER JOIN MENSUALIDAD m ON m.IDMENSUALIDAD = p.IDMENSUALIDAD
    INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
    INNER JOIN `PLAN` pl ON pl.IDPLAN = m.IDPLAN
    LEFT JOIN METODO_PAGO mp ON mp.IDMETODOPAGO = p.IDMETODOPAGO
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           p.IDPAGOMENSUALIDAD LIKE CONCAT('%', p_Buscar, '%') OR
           m.IDMENSUALIDAD LIKE CONCAT('%', p_Buscar, '%') OR
           u.DNI LIKE CONCAT('%', p_Buscar, '%') OR
           u.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
           u.APELLIDO LIKE CONCAT('%', p_Buscar, '%') OR
           pl.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
           IFNULL(mp.TITULO, '') LIKE CONCAT('%', p_Buscar, '%'))
    ORDER BY
        CASE WHEN p_OrdenarPor = 'FECHAPAGO' AND p_Direccion = 'ASC'
            THEN CONCAT(SUBSTRING(p.FECHAPAGO,5,4), SUBSTRING(p.FECHAPAGO,3,2), SUBSTRING(p.FECHAPAGO,1,2)) END ASC,
        CASE WHEN p_OrdenarPor = 'FECHAPAGO' AND p_Direccion = 'DESC'
            THEN CONCAT(SUBSTRING(p.FECHAPAGO,5,4), SUBSTRING(p.FECHAPAGO,3,2), SUBSTRING(p.FECHAPAGO,1,2)) END DESC,
        CASE WHEN p_OrdenarPor = 'MONTO' AND p_Direccion = 'ASC'  THEN p.MONTO END ASC,
        CASE WHEN p_OrdenarPor = 'MONTO' AND p_Direccion = 'DESC' THEN p.MONTO END DESC,
        CASE WHEN p_OrdenarPor = 'ESTUDIANTE_NOMBRE' AND p_Direccion = 'ASC'  THEN u.APELLIDO END ASC,
        CASE WHEN p_OrdenarPor = 'ESTUDIANTE_NOMBRE' AND p_Direccion = 'DESC' THEN u.APELLIDO END DESC,
        CASE WHEN p_OrdenarPor = 'IDPAGOMENSUALIDAD' AND p_Direccion = 'ASC'  THEN p.IDPAGOMENSUALIDAD END ASC,
        CASE WHEN p_OrdenarPor = 'IDPAGOMENSUALIDAD' AND p_Direccion = 'DESC' THEN p.IDPAGOMENSUALIDAD END DESC,
        CONCAT(SUBSTRING(p.FECHAPAGO,5,4), SUBSTRING(p.FECHAPAGO,3,2), SUBSTRING(p.FECHAPAGO,1,2)) DESC,
        p.HORAPAGO DESC,
        p.IDPAGOMENSUALIDAD DESC
    LIMIT p_TamanioPagina OFFSET v_offset;
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_mensualidad_listar_pagos;

DELIMITER $$

CREATE PROCEDURE usp_mensualidad_listar_pagos(IN p_IdMensualidad VARCHAR(50))
main: BEGIN
    IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = p_IdMensualidad) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La mensualidad no existe.';
        LEAVE main;
    END IF;

    SELECT
        p.IDPAGOMENSUALIDAD,
        p.MONTO,
        p.FECHAPAGO,
        p.HORAPAGO,
        p.OBSERVACIONES,
        IFNULL(mp.TITULO, '') AS METODOPAGO_TITULO,
        UPPER(TRIM(CONCAT(IFNULL(reg.APELLIDO, ''), ' ', IFNULL(reg.NOMBRE, '')))) AS REGISTRADO_POR
    FROM PAGOMENSUALIDAD p
    LEFT JOIN METODO_PAGO mp ON mp.IDMETODOPAGO = p.IDMETODOPAGO
    LEFT JOIN USUARIO reg ON reg.IDUSUARIO = p.IDUSUARIO
    WHERE p.IDMENSUALIDAD = p_IdMensualidad
    ORDER BY
        CONCAT(SUBSTRING(p.FECHAPAGO,5,4), SUBSTRING(p.FECHAPAGO,3,2), SUBSTRING(p.FECHAPAGO,1,2)) DESC,
        p.HORAPAGO DESC,
        p.IDPAGOMENSUALIDAD DESC;
END$$

DELIMITER ;

/* ---------- PAGO EXTRA ---------- */
DROP PROCEDURE IF EXISTS usp_pagoextra_listar;

DELIMITER $$

CREATE PROCEDURE usp_pagoextra_listar(
    IN p_Buscar VARCHAR(200),
    IN p_OrdenarPor VARCHAR(50),
    IN p_Direccion VARCHAR(4),
    IN p_Pagina INT,
    IN p_TamanioPagina INT,
    OUT p_TotalRegistros INT
)
main: BEGIN
    DECLARE v_offset INT DEFAULT 0;

    IF p_Pagina < 1 THEN SET p_Pagina = 1; END IF;
    IF p_TamanioPagina < 1 THEN SET p_TamanioPagina = 10; END IF;
    SET v_offset = (p_Pagina - 1) * p_TamanioPagina;

    SELECT COUNT(*) INTO p_TotalRegistros
    FROM (
        SELECT p.IDUSUARIO, p.IDCONCEPTO
        FROM PAGOEXTRAORDINARIO p
        INNER JOIN USUARIO u ON u.IDUSUARIO = p.IDUSUARIO
        INNER JOIN CONCEPTOPAGOEXTRA c ON c.IDCONCEPTO = p.IDCONCEPTO
        WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
               u.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
               u.APELLIDO LIKE CONCAT('%', p_Buscar, '%') OR
               u.DNI LIKE CONCAT('%', p_Buscar, '%') OR
               c.NOMBRE LIKE CONCAT('%', p_Buscar, '%'))
        GROUP BY p.IDUSUARIO, p.IDCONCEPTO
    ) g;

    SELECT *
    FROM (
        SELECT
            CONCAT(p.IDUSUARIO, '|', p.IDCONCEPTO) AS GRUPO_KEY,
            p.IDUSUARIO,
            UPPER(TRIM(CONCAT(IFNULL(u.APELLIDO, ''), ' ', IFNULL(u.NOMBRE, '')))) AS ESTUDIANTE_NOMBRE,
            u.DNI AS ESTUDIANTE_DNI,
            p.IDCONCEPTO,
            c.NOMBRE AS CONCEPTO_NOMBRE,
            c.COSTO AS MONTO_TOTAL,
            IFNULL(SUM(p.MONTO), 0) AS PAGADO,
            CASE
                WHEN c.COSTO - IFNULL(SUM(p.MONTO), 0) < 0 THEN 0
                ELSE c.COSTO - IFNULL(SUM(p.MONTO), 0)
            END AS DEUDA,
            COUNT(p.IDPAGOEXTRA) AS CANTIDAD_PAGOS,
            DATE_FORMAT(
                MAX(STR_TO_DATE(p.FECHAPAGO, '%d%m%Y')),
                '%d%m%Y'
            ) AS ULTIMO_PAGO
        FROM PAGOEXTRAORDINARIO p
        INNER JOIN USUARIO u ON u.IDUSUARIO = p.IDUSUARIO
        INNER JOIN CONCEPTOPAGOEXTRA c ON c.IDCONCEPTO = p.IDCONCEPTO
        WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
               u.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
               u.APELLIDO LIKE CONCAT('%', p_Buscar, '%') OR
               u.DNI LIKE CONCAT('%', p_Buscar, '%') OR
               c.NOMBRE LIKE CONCAT('%', p_Buscar, '%'))
        GROUP BY p.IDUSUARIO, u.APELLIDO, u.NOMBRE, u.DNI, p.IDCONCEPTO, c.NOMBRE, c.COSTO
    ) base
    ORDER BY
        CASE WHEN p_OrdenarPor = 'DEUDA' AND p_Direccion = 'ASC' THEN base.DEUDA END ASC,
        CASE WHEN p_OrdenarPor = 'DEUDA' AND p_Direccion = 'DESC' THEN base.DEUDA END DESC,
        CASE WHEN p_OrdenarPor = 'PAGADO' AND p_Direccion = 'ASC' THEN base.PAGADO END ASC,
        CASE WHEN p_OrdenarPor = 'PAGADO' AND p_Direccion = 'DESC' THEN base.PAGADO END DESC,
        CASE WHEN p_OrdenarPor = 'MONTO_TOTAL' AND p_Direccion = 'ASC' THEN base.MONTO_TOTAL END ASC,
        CASE WHEN p_OrdenarPor = 'MONTO_TOTAL' AND p_Direccion = 'DESC' THEN base.MONTO_TOTAL END DESC,
        CASE WHEN p_OrdenarPor IN ('FECHAPAGO', 'ULTIMO_PAGO') AND p_Direccion = 'ASC'
            THEN CONCAT(SUBSTRING(base.ULTIMO_PAGO,5,4), SUBSTRING(base.ULTIMO_PAGO,3,2), SUBSTRING(base.ULTIMO_PAGO,1,2)) END ASC,
        CASE WHEN p_OrdenarPor IN ('FECHAPAGO', 'ULTIMO_PAGO') AND p_Direccion = 'DESC'
            THEN CONCAT(SUBSTRING(base.ULTIMO_PAGO,5,4), SUBSTRING(base.ULTIMO_PAGO,3,2), SUBSTRING(base.ULTIMO_PAGO,1,2)) END DESC,
        CASE WHEN p_OrdenarPor = 'ESTUDIANTE_NOMBRE' AND p_Direccion = 'ASC' THEN base.ESTUDIANTE_NOMBRE END ASC,
        CASE WHEN p_OrdenarPor = 'ESTUDIANTE_NOMBRE' AND p_Direccion = 'DESC' THEN base.ESTUDIANTE_NOMBRE END DESC,
        CASE WHEN p_OrdenarPor = 'CONCEPTO_NOMBRE' AND p_Direccion = 'ASC' THEN base.CONCEPTO_NOMBRE END ASC,
        CASE WHEN p_OrdenarPor = 'CONCEPTO_NOMBRE' AND p_Direccion = 'DESC' THEN base.CONCEPTO_NOMBRE END DESC,
        CONCAT(SUBSTRING(base.ULTIMO_PAGO,5,4), SUBSTRING(base.ULTIMO_PAGO,3,2), SUBSTRING(base.ULTIMO_PAGO,1,2)) DESC
    LIMIT p_TamanioPagina OFFSET v_offset;
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_pagoextra_listar_detalle;

DELIMITER $$

CREATE PROCEDURE usp_pagoextra_listar_detalle(
    IN p_IdUsuario VARCHAR(50),
    IN p_IdConcepto VARCHAR(50)
)
main: BEGIN
    SELECT
        p.IDPAGOEXTRA,
        p.IDUSUARIO,
        UPPER(TRIM(CONCAT(IFNULL(u.APELLIDO, ''), ' ', IFNULL(u.NOMBRE, '')))) AS ESTUDIANTE_NOMBRE,
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
    WHERE p.IDUSUARIO = p_IdUsuario
      AND p.IDCONCEPTO = p_IdConcepto
    ORDER BY
        CONCAT(SUBSTRING(p.FECHAPAGO,5,4), SUBSTRING(p.FECHAPAGO,3,2), SUBSTRING(p.FECHAPAGO,1,2)) DESC,
        p.IDPAGOEXTRA DESC;
END$$

DELIMITER ;

/* ---------- EXAMEN ---------- */
DROP PROCEDURE IF EXISTS usp_examen_listar;

DELIMITER $$

CREATE PROCEDURE usp_examen_listar(
    IN p_Buscar VARCHAR(200),
    IN p_OrdenarPor VARCHAR(50),
    IN p_Direccion VARCHAR(4),
    IN p_Pagina INT,
    IN p_TamanioPagina INT,
    OUT p_TotalRegistros INT
)
main: BEGIN
    DECLARE v_offset INT DEFAULT 0;
    IF p_Pagina < 1 THEN SET p_Pagina = 1; END IF;
    IF p_TamanioPagina < 1 THEN SET p_TamanioPagina = 10; END IF;
    SET v_offset = (p_Pagina - 1) * p_TamanioPagina;

    SELECT COUNT(*) INTO p_TotalRegistros
    FROM EXAMEN e
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           e.IDEXAMEN LIKE CONCAT('%', p_Buscar, '%') OR
           e.TITULO LIKE CONCAT('%', p_Buscar, '%') OR
           IFNULL(e.DESCRIPCION, '') LIKE CONCAT('%', p_Buscar, '%'));

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
        IFNULL(e.TODASLASULA, 1) AS TODASLASULA,
        e.IDUSUARIO,
        (SELECT COUNT(*) FROM PREGUNTA p WHERE p.IDEXAMEN = e.IDEXAMEN) AS CANTPREGUNTAS
    FROM EXAMEN e
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           e.IDEXAMEN LIKE CONCAT('%', p_Buscar, '%') OR
           e.TITULO LIKE CONCAT('%', p_Buscar, '%') OR
           IFNULL(e.DESCRIPCION, '') LIKE CONCAT('%', p_Buscar, '%'))
    ORDER BY
        CASE WHEN p_OrdenarPor = 'TITULO' AND p_Direccion = 'ASC'  THEN e.TITULO END ASC,
        CASE WHEN p_OrdenarPor = 'TITULO' AND p_Direccion = 'DESC' THEN e.TITULO END DESC,
        CASE WHEN p_OrdenarPor = 'TIPO' AND p_Direccion = 'ASC'  THEN e.TIPO END ASC,
        CASE WHEN p_OrdenarPor = 'TIPO' AND p_Direccion = 'DESC' THEN e.TIPO END DESC,
        CASE WHEN p_OrdenarPor = 'FECHAINICIO' AND p_Direccion = 'ASC'
            THEN CONCAT(SUBSTRING(e.FECHAINICIO,5,4), SUBSTRING(e.FECHAINICIO,3,2), SUBSTRING(e.FECHAINICIO,1,2)) END ASC,
        CASE WHEN p_OrdenarPor = 'FECHAINICIO' AND p_Direccion = 'DESC'
            THEN CONCAT(SUBSTRING(e.FECHAINICIO,5,4), SUBSTRING(e.FECHAINICIO,3,2), SUBSTRING(e.FECHAINICIO,1,2)) END DESC,
        e.IDEXAMEN DESC
    LIMIT p_TamanioPagina OFFSET v_offset;
END$$

DELIMITER ;

/* ---------- LIBRO ---------- */
DROP PROCEDURE IF EXISTS usp_libro_listar;

DELIMITER $$

CREATE PROCEDURE usp_libro_listar(
    IN p_Buscar VARCHAR(200),
    IN p_Estado VARCHAR(50),
    IN p_OrdenarPor VARCHAR(50),
    IN p_Direccion VARCHAR(4),
    IN p_Pagina INT,
    IN p_TamanioPagina INT,
    OUT p_TotalRegistros INT
)
main: BEGIN
    DECLARE v_offset INT DEFAULT 0;
    IF p_Pagina < 1 THEN SET p_Pagina = 1; END IF;
    IF p_TamanioPagina < 1 THEN SET p_TamanioPagina = 10; END IF;
    SET v_offset = (p_Pagina - 1) * p_TamanioPagina;

    SELECT COUNT(*) INTO p_TotalRegistros
    FROM LIBRO l
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           l.IDLIBRO LIKE CONCAT('%', p_Buscar, '%') OR
           l.TITULO LIKE CONCAT('%', p_Buscar, '%') OR
           l.DESCRIPCION LIKE CONCAT('%', p_Buscar, '%'))
      AND (p_Estado IS NULL OR p_Estado = '' OR l.ESTADO = p_Estado);

    SELECT
        l.IDLIBRO,
        l.TITULO,
        l.DESCRIPCION,
        l.FECHASUBIDA,
        l.ESTADO,
        l.URLCONTENIDO,
        l.IMGPORTADA
    FROM LIBRO l
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           l.IDLIBRO LIKE CONCAT('%', p_Buscar, '%') OR
           l.TITULO LIKE CONCAT('%', p_Buscar, '%') OR
           l.DESCRIPCION LIKE CONCAT('%', p_Buscar, '%'))
      AND (p_Estado IS NULL OR p_Estado = '' OR l.ESTADO = p_Estado)
    ORDER BY
        CASE WHEN p_OrdenarPor = 'IDLIBRO'     AND p_Direccion = 'ASC'  THEN l.IDLIBRO END ASC,
        CASE WHEN p_OrdenarPor = 'IDLIBRO'     AND p_Direccion = 'DESC' THEN l.IDLIBRO END DESC,
        CASE WHEN p_OrdenarPor = 'TITULO'      AND p_Direccion = 'ASC'  THEN l.TITULO END ASC,
        CASE WHEN p_OrdenarPor = 'TITULO'      AND p_Direccion = 'DESC' THEN l.TITULO END DESC,
        CASE WHEN p_OrdenarPor = 'FECHASUBIDA' AND p_Direccion = 'ASC'
            THEN CONCAT(SUBSTRING(l.FECHASUBIDA,5,4), SUBSTRING(l.FECHASUBIDA,3,2), SUBSTRING(l.FECHASUBIDA,1,2)) END ASC,
        CASE WHEN p_OrdenarPor = 'FECHASUBIDA' AND p_Direccion = 'DESC'
            THEN CONCAT(SUBSTRING(l.FECHASUBIDA,5,4), SUBSTRING(l.FECHASUBIDA,3,2), SUBSTRING(l.FECHASUBIDA,1,2)) END DESC,
        CASE WHEN p_OrdenarPor = 'ESTADO'      AND p_Direccion = 'ASC'  THEN l.ESTADO END ASC,
        CASE WHEN p_OrdenarPor = 'ESTADO'      AND p_Direccion = 'DESC' THEN l.ESTADO END DESC,
        CONCAT(SUBSTRING(l.FECHASUBIDA,5,4), SUBSTRING(l.FECHASUBIDA,3,2), SUBSTRING(l.FECHASUBIDA,1,2)) DESC,
        l.IDLIBRO DESC
    LIMIT p_TamanioPagina OFFSET v_offset;
END$$

DELIMITER ;

/* ---------- HORARIO ---------- */
DROP PROCEDURE IF EXISTS usp_horario_listar;

DELIMITER $$

CREATE PROCEDURE usp_horario_listar(
    IN p_Buscar VARCHAR(200),
    IN p_Estado VARCHAR(50),
    IN p_OrdenarPor VARCHAR(50),
    IN p_Direccion VARCHAR(4),
    IN p_Pagina INT,
    IN p_TamanioPagina INT,
    OUT p_TotalRegistros INT
)
main: BEGIN
    DECLARE v_offset INT DEFAULT 0;
    IF p_Pagina < 1 THEN SET p_Pagina = 1; END IF;
    IF p_TamanioPagina < 1 THEN SET p_TamanioPagina = 10; END IF;
    SET v_offset = (p_Pagina - 1) * p_TamanioPagina;

    SELECT COUNT(*) INTO p_TotalRegistros
    FROM HORARIO h
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           h.IDHORARIO LIKE CONCAT('%', p_Buscar, '%') OR
           h.TITULO LIKE CONCAT('%', p_Buscar, '%') OR
           h.DESCRIPCION LIKE CONCAT('%', p_Buscar, '%'))
      AND (p_Estado IS NULL OR p_Estado = '' OR h.ESTADO = p_Estado);

    SELECT
        h.IDHORARIO,
        h.TITULO,
        h.DESCRIPCION,
        h.FECHASUBIDA,
        h.ESTADO,
        h.URLIMAGEN
    FROM HORARIO h
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           h.IDHORARIO LIKE CONCAT('%', p_Buscar, '%') OR
           h.TITULO LIKE CONCAT('%', p_Buscar, '%') OR
           h.DESCRIPCION LIKE CONCAT('%', p_Buscar, '%'))
      AND (p_Estado IS NULL OR p_Estado = '' OR h.ESTADO = p_Estado)
    ORDER BY
        CASE WHEN p_OrdenarPor = 'IDHORARIO'   AND p_Direccion = 'ASC'  THEN h.IDHORARIO END ASC,
        CASE WHEN p_OrdenarPor = 'IDHORARIO'   AND p_Direccion = 'DESC' THEN h.IDHORARIO END DESC,
        CASE WHEN p_OrdenarPor = 'TITULO'      AND p_Direccion = 'ASC'  THEN h.TITULO END ASC,
        CASE WHEN p_OrdenarPor = 'TITULO'      AND p_Direccion = 'DESC' THEN h.TITULO END DESC,
        CASE WHEN p_OrdenarPor = 'FECHASUBIDA' AND p_Direccion = 'ASC'
            THEN CONCAT(SUBSTRING(h.FECHASUBIDA,5,4), SUBSTRING(h.FECHASUBIDA,3,2), SUBSTRING(h.FECHASUBIDA,1,2)) END ASC,
        CASE WHEN p_OrdenarPor = 'FECHASUBIDA' AND p_Direccion = 'DESC'
            THEN CONCAT(SUBSTRING(h.FECHASUBIDA,5,4), SUBSTRING(h.FECHASUBIDA,3,2), SUBSTRING(h.FECHASUBIDA,1,2)) END DESC,
        CASE WHEN p_OrdenarPor = 'ESTADO'      AND p_Direccion = 'ASC'  THEN h.ESTADO END ASC,
        CASE WHEN p_OrdenarPor = 'ESTADO'      AND p_Direccion = 'DESC' THEN h.ESTADO END DESC,
        CONCAT(SUBSTRING(h.FECHASUBIDA,5,4), SUBSTRING(h.FECHASUBIDA,3,2), SUBSTRING(h.FECHASUBIDA,1,2)) DESC,
        h.IDHORARIO DESC
    LIMIT p_TamanioPagina OFFSET v_offset;
END$$

DELIMITER ;

/* ---------- AUDITORÍA ---------- */
DROP PROCEDURE IF EXISTS usp_auditoria_listar;

DELIMITER $$

CREATE PROCEDURE usp_auditoria_listar(
    IN p_Buscar VARCHAR(200),
    IN p_Tabla VARCHAR(100),
    IN p_Accion VARCHAR(20),
    IN p_IdUsuario VARCHAR(50),
    IN p_FechaDesde CHAR(8),
    IN p_FechaHasta CHAR(8),
    IN p_OrdenarPor VARCHAR(50),
    IN p_Direccion VARCHAR(4),
    IN p_Pagina INT,
    IN p_TamanioPagina INT,
    OUT p_TotalRegistros INT
)
main: BEGIN
    DECLARE v_offset INT DEFAULT 0;
    IF p_Pagina < 1 THEN SET p_Pagina = 1; END IF;
    IF p_TamanioPagina < 1 THEN SET p_TamanioPagina = 10; END IF;
    SET v_offset = (p_Pagina - 1) * p_TamanioPagina;

    SELECT COUNT(*) INTO p_TotalRegistros
    FROM AUDITORIA a
    LEFT JOIN USUARIO u ON u.IDUSUARIO = a.IDUSUARIO
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           a.IDAUDITORIA LIKE CONCAT('%', p_Buscar, '%') OR
           a.TABLA LIKE CONCAT('%', p_Buscar, '%') OR
           a.IDREGISTRO LIKE CONCAT('%', p_Buscar, '%') OR
           a.ACCION LIKE CONCAT('%', p_Buscar, '%') OR
           CONCAT(IFNULL(u.NOMBRE, ''), ' ', IFNULL(u.APELLIDO, '')) LIKE CONCAT('%', p_Buscar, '%') OR
           IFNULL(a.IDUSUARIO, '') LIKE CONCAT('%', p_Buscar, '%'))
      AND (p_Tabla IS NULL OR p_Tabla = '' OR a.TABLA = p_Tabla)
      AND (p_Accion IS NULL OR p_Accion = '' OR a.ACCION = p_Accion)
      AND (p_IdUsuario IS NULL OR p_IdUsuario = '' OR a.IDUSUARIO = p_IdUsuario)
      AND (p_FechaDesde IS NULL OR p_FechaDesde = '' OR
           CONCAT(SUBSTRING(a.FECHA,5,4), SUBSTRING(a.FECHA,3,2), SUBSTRING(a.FECHA,1,2))
             >= CONCAT(SUBSTRING(p_FechaDesde,5,4), SUBSTRING(p_FechaDesde,3,2), SUBSTRING(p_FechaDesde,1,2)))
      AND (p_FechaHasta IS NULL OR p_FechaHasta = '' OR
           CONCAT(SUBSTRING(a.FECHA,5,4), SUBSTRING(a.FECHA,3,2), SUBSTRING(a.FECHA,1,2))
             <= CONCAT(SUBSTRING(p_FechaHasta,5,4), SUBSTRING(p_FechaHasta,3,2), SUBSTRING(p_FechaHasta,1,2)));

    SELECT
        a.IDAUDITORIA,
        a.TABLA,
        a.IDREGISTRO,
        a.ACCION,
        a.IDUSUARIO,
        TRIM(CONCAT(IFNULL(u.NOMBRE, ''), ' ', IFNULL(u.APELLIDO, ''))) AS USUARIO_NOMBRE,
        a.FECHA,
        a.HORA,
        a.DATOS_ANTES,
        a.DATOS_DESPUES
    FROM AUDITORIA a
    LEFT JOIN USUARIO u ON u.IDUSUARIO = a.IDUSUARIO
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           a.IDAUDITORIA LIKE CONCAT('%', p_Buscar, '%') OR
           a.TABLA LIKE CONCAT('%', p_Buscar, '%') OR
           a.IDREGISTRO LIKE CONCAT('%', p_Buscar, '%') OR
           a.ACCION LIKE CONCAT('%', p_Buscar, '%') OR
           CONCAT(IFNULL(u.NOMBRE, ''), ' ', IFNULL(u.APELLIDO, '')) LIKE CONCAT('%', p_Buscar, '%') OR
           IFNULL(a.IDUSUARIO, '') LIKE CONCAT('%', p_Buscar, '%'))
      AND (p_Tabla IS NULL OR p_Tabla = '' OR a.TABLA = p_Tabla)
      AND (p_Accion IS NULL OR p_Accion = '' OR a.ACCION = p_Accion)
      AND (p_IdUsuario IS NULL OR p_IdUsuario = '' OR a.IDUSUARIO = p_IdUsuario)
      AND (p_FechaDesde IS NULL OR p_FechaDesde = '' OR
           CONCAT(SUBSTRING(a.FECHA,5,4), SUBSTRING(a.FECHA,3,2), SUBSTRING(a.FECHA,1,2))
             >= CONCAT(SUBSTRING(p_FechaDesde,5,4), SUBSTRING(p_FechaDesde,3,2), SUBSTRING(p_FechaDesde,1,2)))
      AND (p_FechaHasta IS NULL OR p_FechaHasta = '' OR
           CONCAT(SUBSTRING(a.FECHA,5,4), SUBSTRING(a.FECHA,3,2), SUBSTRING(a.FECHA,1,2))
             <= CONCAT(SUBSTRING(p_FechaHasta,5,4), SUBSTRING(p_FechaHasta,3,2), SUBSTRING(p_FechaHasta,1,2)))
    ORDER BY
        CASE WHEN p_OrdenarPor = 'FECHA' AND p_Direccion = 'DESC'
            THEN CONCAT(SUBSTRING(a.FECHA,5,4), SUBSTRING(a.FECHA,3,2), SUBSTRING(a.FECHA,1,2)) END DESC,
        CASE WHEN p_OrdenarPor = 'FECHA' AND p_Direccion = 'ASC'
            THEN CONCAT(SUBSTRING(a.FECHA,5,4), SUBSTRING(a.FECHA,3,2), SUBSTRING(a.FECHA,1,2)) END ASC,
        CASE WHEN p_OrdenarPor = 'HORA' AND p_Direccion = 'DESC' THEN a.HORA END DESC,
        CASE WHEN p_OrdenarPor = 'HORA' AND p_Direccion = 'ASC'  THEN a.HORA END ASC,
        CASE WHEN p_OrdenarPor = 'TABLA' AND p_Direccion = 'DESC' THEN a.TABLA END DESC,
        CASE WHEN p_OrdenarPor = 'TABLA' AND p_Direccion = 'ASC'  THEN a.TABLA END ASC,
        CASE WHEN p_OrdenarPor = 'ACCION' AND p_Direccion = 'DESC' THEN a.ACCION END DESC,
        CASE WHEN p_OrdenarPor = 'ACCION' AND p_Direccion = 'ASC'  THEN a.ACCION END ASC,
        CASE WHEN p_OrdenarPor = 'IDREGISTRO' AND p_Direccion = 'DESC' THEN a.IDREGISTRO END DESC,
        CASE WHEN p_OrdenarPor = 'IDREGISTRO' AND p_Direccion = 'ASC'  THEN a.IDREGISTRO END ASC,
        CASE WHEN p_OrdenarPor = 'USUARIO_NOMBRE' AND p_Direccion = 'DESC'
            THEN TRIM(CONCAT(IFNULL(u.NOMBRE, ''), ' ', IFNULL(u.APELLIDO, ''))) END DESC,
        CASE WHEN p_OrdenarPor = 'USUARIO_NOMBRE' AND p_Direccion = 'ASC'
            THEN TRIM(CONCAT(IFNULL(u.NOMBRE, ''), ' ', IFNULL(u.APELLIDO, ''))) END ASC,
        CONCAT(SUBSTRING(a.FECHA,5,4), SUBSTRING(a.FECHA,3,2), SUBSTRING(a.FECHA,1,2)) DESC,
        a.HORA DESC,
        a.IDAUDITORIA DESC
    LIMIT p_TamanioPagina OFFSET v_offset;
END$$

DELIMITER ;

/* ---------- CLASE GRABADA ---------- */
DROP PROCEDURE IF EXISTS usp_clase_grabada_listar;

DELIMITER $$

CREATE PROCEDURE usp_clase_grabada_listar(
    IN p_Buscar VARCHAR(200),
    IN p_Estado VARCHAR(50),
    IN p_IdMateria VARCHAR(50),
    IN p_IdAula VARCHAR(50),
    IN p_IdUsuario VARCHAR(50),
    IN p_OrdenarPor VARCHAR(50),
    IN p_Direccion VARCHAR(4),
    IN p_Pagina INT,
    IN p_TamanioPagina INT,
    OUT p_TotalRegistros INT
)
main: BEGIN
    DECLARE v_offset INT DEFAULT 0;
    IF p_Pagina < 1 THEN SET p_Pagina = 1; END IF;
    IF p_TamanioPagina < 1 THEN SET p_TamanioPagina = 10; END IF;
    SET v_offset = (p_Pagina - 1) * p_TamanioPagina;

    SELECT COUNT(*) INTO p_TotalRegistros
    FROM CLASE_GRABADA cg
    INNER JOIN AULA au ON au.IDAULA = cg.IDAULA
    INNER JOIN MATERIA m ON m.IDMATERIA = cg.IDMATERIA
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           cg.IDCLASEGRABADA LIKE CONCAT('%', p_Buscar, '%') OR
           cg.DETALLES LIKE CONCAT('%', p_Buscar, '%') OR
           cg.ENLACE LIKE CONCAT('%', p_Buscar, '%') OR
           au.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
           m.NOMBRE LIKE CONCAT('%', p_Buscar, '%'))
      AND (p_Estado IS NULL OR p_Estado = '' OR cg.ESTADO = p_Estado)
      AND (p_IdMateria IS NULL OR p_IdMateria = '' OR cg.IDMATERIA = p_IdMateria)
      AND (p_IdAula IS NULL OR p_IdAula = '' OR cg.IDAULA = p_IdAula)
      AND (
          p_IdUsuario IS NULL OR p_IdUsuario = '' OR
          cg.IDAULA IN (
              SELECT DISTINCT ms.IDAULA
              FROM MENSUALIDAD ms
              WHERE ms.IDUSUARIO = p_IdUsuario
                AND ms.ESTADO = 'Activo'
                AND ms.IDAULA IS NOT NULL
          )
      );

    SELECT
        cg.IDCLASEGRABADA,
        cg.IDAULA,
        au.NOMBRE AS AULA_NOMBRE,
        cg.IDMATERIA,
        m.NOMBRE AS MATERIA_NOMBRE,
        cg.ENLACE,
        cg.DETALLES,
        cg.FECHASUBIDA,
        cg.HORASUBIDA,
        cg.ESTADO,
        cg.CREADO_POR,
        UPPER(TRIM(CONCAT(IFNULL(uc.APELLIDO, ''), ' ', IFNULL(uc.NOMBRE, '')))) AS CREADO_POR_NOMBRE,
        cg.FECHACREACION,
        cg.HORACREACION,
        cg.MODIFICADO_POR,
        UPPER(TRIM(CONCAT(IFNULL(um.APELLIDO, ''), ' ', IFNULL(um.NOMBRE, '')))) AS MODIFICADO_POR_NOMBRE,
        cg.FECHAMODIFICACION,
        cg.HORAMODIFICACION
    FROM CLASE_GRABADA cg
    INNER JOIN AULA au ON au.IDAULA = cg.IDAULA
    INNER JOIN MATERIA m ON m.IDMATERIA = cg.IDMATERIA
    LEFT JOIN USUARIO uc ON uc.IDUSUARIO = cg.CREADO_POR
    LEFT JOIN USUARIO um ON um.IDUSUARIO = cg.MODIFICADO_POR
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           cg.IDCLASEGRABADA LIKE CONCAT('%', p_Buscar, '%') OR
           cg.DETALLES LIKE CONCAT('%', p_Buscar, '%') OR
           cg.ENLACE LIKE CONCAT('%', p_Buscar, '%') OR
           au.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
           m.NOMBRE LIKE CONCAT('%', p_Buscar, '%'))
      AND (p_Estado IS NULL OR p_Estado = '' OR cg.ESTADO = p_Estado)
      AND (p_IdMateria IS NULL OR p_IdMateria = '' OR cg.IDMATERIA = p_IdMateria)
      AND (p_IdAula IS NULL OR p_IdAula = '' OR cg.IDAULA = p_IdAula)
      AND (
          p_IdUsuario IS NULL OR p_IdUsuario = '' OR
          cg.IDAULA IN (
              SELECT DISTINCT ms.IDAULA
              FROM MENSUALIDAD ms
              WHERE ms.IDUSUARIO = p_IdUsuario
                AND ms.ESTADO = 'Activo'
                AND ms.IDAULA IS NOT NULL
          )
      )
    ORDER BY
        CASE WHEN p_OrdenarPor = 'FECHASUBIDA' AND p_Direccion = 'DESC'
            THEN CONCAT(SUBSTRING(cg.FECHASUBIDA,5,4), SUBSTRING(cg.FECHASUBIDA,3,2), SUBSTRING(cg.FECHASUBIDA,1,2)) END DESC,
        CASE WHEN p_OrdenarPor = 'FECHASUBIDA' AND p_Direccion = 'ASC'
            THEN CONCAT(SUBSTRING(cg.FECHASUBIDA,5,4), SUBSTRING(cg.FECHASUBIDA,3,2), SUBSTRING(cg.FECHASUBIDA,1,2)) END ASC,
        CASE WHEN p_OrdenarPor = 'DETALLES' AND p_Direccion = 'DESC' THEN cg.DETALLES END DESC,
        CASE WHEN p_OrdenarPor = 'DETALLES' AND p_Direccion = 'ASC' THEN cg.DETALLES END ASC,
        CASE WHEN p_OrdenarPor = 'AULA_NOMBRE' AND p_Direccion = 'DESC' THEN au.NOMBRE END DESC,
        CASE WHEN p_OrdenarPor = 'AULA_NOMBRE' AND p_Direccion = 'ASC' THEN au.NOMBRE END ASC,
        cg.HORASUBIDA DESC,
        cg.IDCLASEGRABADA DESC
    LIMIT p_TamanioPagina OFFSET v_offset;
END$$

DELIMITER ;

/* ---------- CONCEPTO ---------- */
DROP PROCEDURE IF EXISTS usp_concepto_listar;

DELIMITER $$

CREATE PROCEDURE usp_concepto_listar(
    IN p_Buscar VARCHAR(200),
    IN p_Estado VARCHAR(50),
    IN p_OrdenarPor VARCHAR(50),
    IN p_Direccion VARCHAR(4),
    IN p_Pagina INT,
    IN p_TamanioPagina INT,
    OUT p_TotalRegistros INT
)
main: BEGIN
    DECLARE v_offset INT DEFAULT 0;

    IF p_Pagina < 1 THEN SET p_Pagina = 1; END IF;
    IF p_TamanioPagina < 1 THEN SET p_TamanioPagina = 10; END IF;
    SET v_offset = (p_Pagina - 1) * p_TamanioPagina;

    SELECT COUNT(*) INTO p_TotalRegistros
    FROM CONCEPTOPAGOEXTRA c
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           c.IDCONCEPTO LIKE CONCAT('%', p_Buscar, '%') OR
           c.NOMBRE     LIKE CONCAT('%', p_Buscar, '%'))
      AND (p_Estado IS NULL OR p_Estado = '' OR
           (p_Estado = 'Activo' AND c.ACTIVO = 1) OR
           (p_Estado = 'Inactivo' AND c.ACTIVO = 0));

    SELECT
        c.IDCONCEPTO,
        c.NOMBRE,
        c.COSTO,
        c.FECHAINICIO,
        c.FECHAFIN,
        CASE WHEN c.ACTIVO = 1 THEN 'Activo' ELSE 'Inactivo' END AS ESTADO
    FROM CONCEPTOPAGOEXTRA c
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           c.IDCONCEPTO LIKE CONCAT('%', p_Buscar, '%') OR
           c.NOMBRE     LIKE CONCAT('%', p_Buscar, '%'))
      AND (p_Estado IS NULL OR p_Estado = '' OR
           (p_Estado = 'Activo' AND c.ACTIVO = 1) OR
           (p_Estado = 'Inactivo' AND c.ACTIVO = 0))
    ORDER BY
        CASE WHEN p_OrdenarPor = 'IDCONCEPTO' AND p_Direccion = 'ASC'  THEN c.IDCONCEPTO END ASC,
        CASE WHEN p_OrdenarPor = 'IDCONCEPTO' AND p_Direccion = 'DESC' THEN c.IDCONCEPTO END DESC,
        CASE WHEN p_OrdenarPor = 'NOMBRE'     AND p_Direccion = 'ASC'  THEN c.NOMBRE END ASC,
        CASE WHEN p_OrdenarPor = 'NOMBRE'     AND p_Direccion = 'DESC' THEN c.NOMBRE END DESC,
        CASE WHEN p_OrdenarPor = 'COSTO'      AND p_Direccion = 'ASC'  THEN c.COSTO END ASC,
        CASE WHEN p_OrdenarPor = 'COSTO'      AND p_Direccion = 'DESC' THEN c.COSTO END DESC,
        CASE WHEN p_OrdenarPor = 'FECHAINICIO' AND p_Direccion = 'ASC'
            THEN CONCAT(SUBSTRING(c.FECHAINICIO,5,4), SUBSTRING(c.FECHAINICIO,3,2), SUBSTRING(c.FECHAINICIO,1,2)) END ASC,
        CASE WHEN p_OrdenarPor = 'FECHAINICIO' AND p_Direccion = 'DESC'
            THEN CONCAT(SUBSTRING(c.FECHAINICIO,5,4), SUBSTRING(c.FECHAINICIO,3,2), SUBSTRING(c.FECHAINICIO,1,2)) END DESC,
        CASE WHEN p_OrdenarPor = 'FECHAFIN' AND p_Direccion = 'ASC'
            THEN CONCAT(SUBSTRING(c.FECHAFIN,5,4), SUBSTRING(c.FECHAFIN,3,2), SUBSTRING(c.FECHAFIN,1,2)) END ASC,
        CASE WHEN p_OrdenarPor = 'FECHAFIN' AND p_Direccion = 'DESC'
            THEN CONCAT(SUBSTRING(c.FECHAFIN,5,4), SUBSTRING(c.FECHAFIN,3,2), SUBSTRING(c.FECHAFIN,1,2)) END DESC,
        CASE WHEN p_OrdenarPor = 'ESTADO'     AND p_Direccion = 'ASC'  THEN c.ACTIVO END ASC,
        CASE WHEN p_OrdenarPor = 'ESTADO'     AND p_Direccion = 'DESC' THEN c.ACTIVO END DESC,
        c.NOMBRE
    LIMIT p_TamanioPagina OFFSET v_offset;
END$$

DELIMITER ;
