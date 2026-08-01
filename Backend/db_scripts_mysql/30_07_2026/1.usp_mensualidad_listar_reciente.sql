-- ============================================================================
-- Mensualidad listar: una fila por estudiante (mensualidad más reciente) — MySQL 8
-- + listar todas las mensualidades de un estudiante
-- Fecha: 30/07/2026
-- ============================================================================

USE `AcademiaDB`;

DROP PROCEDURE IF EXISTS usp_mensualidad_listar;

DELIMITER $$

CREATE PROCEDURE usp_mensualidad_listar(
    IN p_Buscar VARCHAR(200),
    IN p_Deuda VARCHAR(50),
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

    WITH Base AS (
        SELECT
            m.IDMENSUALIDAD,
            m.IDUSUARIO,
            UPPER(TRIM(CONCAT(IFNULL(u.APELLIDO, ''), ' ', IFNULL(u.NOMBRE, '')))) AS ESTUDIANTE_NOMBRE,
            u.DNI AS ESTUDIANTE_DNI,
            pl.NOMBRE AS PLAN_NOMBRE,
            IFNULL(au.NOMBRE, '') AS AULA_NOMBRE,
            IFNULL(tut.NOMBRE, IFNULL(m.TUTORLEGACY, '')) AS TUTOR_NOMBRE,
            CASE WHEN IFNULL(m.MONTOTOTAL, 0) - IFNULL(pag.PAGADO, 0) < 0 THEN 0
                 ELSE IFNULL(m.MONTOTOTAL, 0) - IFNULL(pag.PAGADO, 0) END AS DEUDA,
            ROW_NUMBER() OVER (
                PARTITION BY m.IDUSUARIO
                ORDER BY m.FECHAREGISTRO DESC, m.IDMENSUALIDAD DESC
            ) AS RN
        FROM MENSUALIDAD m
        INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
        INNER JOIN `PLAN` pl ON pl.IDPLAN = m.IDPLAN
        LEFT JOIN AULA au ON au.IDAULA = m.IDAULA
        LEFT JOIN TUTOR tut ON tut.IDTUTOR = m.IDTUTOR
        LEFT JOIN LATERAL (
            SELECT SUM(p.MONTO) AS PAGADO
            FROM PAGOMENSUALIDAD p
            WHERE p.IDMENSUALIDAD = m.IDMENSUALIDAD
        ) pag ON TRUE
        WHERE m.ESTADO = 'Activo'
    ),
    Filtrada AS (
        SELECT IDMENSUALIDAD
        FROM Base
        WHERE RN = 1
          AND (p_Buscar IS NULL OR p_Buscar = '' OR
               IDMENSUALIDAD LIKE CONCAT('%', p_Buscar, '%') OR
               ESTUDIANTE_DNI LIKE CONCAT('%', p_Buscar, '%') OR
               ESTUDIANTE_NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
               PLAN_NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
               AULA_NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
               TUTOR_NOMBRE LIKE CONCAT('%', p_Buscar, '%'))
          AND (
              p_Deuda IS NULL OR p_Deuda = '' OR
              (p_Deuda IN ('con', 'Con deuda') AND DEUDA > 0) OR
              (p_Deuda IN ('sin', 'Sin deuda') AND DEUDA <= 0)
          )
    )
    SELECT COUNT(*) INTO p_TotalRegistros FROM Filtrada;

    WITH Base AS (
        SELECT
            m.IDMENSUALIDAD,
            m.IDUSUARIO,
            UPPER(TRIM(CONCAT(IFNULL(u.APELLIDO, ''), ' ', IFNULL(u.NOMBRE, '')))) AS ESTUDIANTE_NOMBRE,
            u.DNI AS ESTUDIANTE_DNI,
            m.IDPLAN,
            pl.NOMBRE AS PLAN_NOMBRE,
            IFNULL(tu.DESCRIPCION, '') AS TURNO_DESCRIPCION,
            m.ESTADOMIEMBRO,
            m.FECHAINICIO,
            m.FECHAFIN,
            m.MONTOTOTAL,
            IFNULL(pag.PAGADO, 0) AS PAGADO,
            CASE WHEN IFNULL(m.MONTOTOTAL, 0) - IFNULL(pag.PAGADO, 0) < 0 THEN 0
                 ELSE IFNULL(m.MONTOTOTAL, 0) - IFNULL(pag.PAGADO, 0) END AS DEUDA,
            IFNULL(au.NOMBRE, '') AS AULA_NOMBRE,
            m.IDTUTOR,
            IFNULL(tut.NOMBRE, IFNULL(m.TUTORLEGACY, '')) AS TUTOR_NOMBRE,
            m.REGISTRADOPOR,
            UPPER(TRIM(CONCAT(IFNULL(reg.APELLIDO, ''), ' ', IFNULL(reg.NOMBRE, '')))) AS ASESOR_NOMBRE,
            m.ESTADO,
            m.FECHAREGISTRO,
            ROW_NUMBER() OVER (
                PARTITION BY m.IDUSUARIO
                ORDER BY m.FECHAREGISTRO DESC, m.IDMENSUALIDAD DESC
            ) AS RN
        FROM MENSUALIDAD m
        INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
        INNER JOIN `PLAN` pl ON pl.IDPLAN = m.IDPLAN
        LEFT JOIN TURNO tu ON tu.IDTURNO = IFNULL(pl.IDTURNO, m.IDTURNO)
        LEFT JOIN AULA au ON au.IDAULA = m.IDAULA
        LEFT JOIN TUTOR tut ON tut.IDTUTOR = m.IDTUTOR
        LEFT JOIN USUARIO reg ON reg.IDUSUARIO = m.REGISTRADOPOR
        LEFT JOIN LATERAL (
            SELECT SUM(p.MONTO) AS PAGADO
            FROM PAGOMENSUALIDAD p
            WHERE p.IDMENSUALIDAD = m.IDMENSUALIDAD
        ) pag ON TRUE
        WHERE m.ESTADO = 'Activo'
    ),
    Filtrada AS (
        SELECT *
        FROM Base
        WHERE RN = 1
          AND (p_Buscar IS NULL OR p_Buscar = '' OR
               IDMENSUALIDAD LIKE CONCAT('%', p_Buscar, '%') OR
               ESTUDIANTE_DNI LIKE CONCAT('%', p_Buscar, '%') OR
               ESTUDIANTE_NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
               PLAN_NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
               AULA_NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
               TUTOR_NOMBRE LIKE CONCAT('%', p_Buscar, '%'))
          AND (
              p_Deuda IS NULL OR p_Deuda = '' OR
              (p_Deuda IN ('con', 'Con deuda') AND DEUDA > 0) OR
              (p_Deuda IN ('sin', 'Sin deuda') AND DEUDA <= 0)
          )
    )
    SELECT
        IDMENSUALIDAD,
        IDUSUARIO,
        ESTUDIANTE_NOMBRE,
        ESTUDIANTE_DNI,
        IDPLAN,
        PLAN_NOMBRE,
        TURNO_DESCRIPCION,
        ESTADOMIEMBRO,
        FECHAINICIO,
        FECHAFIN,
        MONTOTOTAL,
        PAGADO,
        DEUDA,
        AULA_NOMBRE,
        IDTUTOR,
        TUTOR_NOMBRE,
        REGISTRADOPOR,
        ASESOR_NOMBRE,
        ESTADO,
        FECHAREGISTRO
    FROM Filtrada
    ORDER BY
        CASE WHEN p_OrdenarPor = 'FECHAREGISTRO' AND p_Direccion = 'DESC' THEN FECHAREGISTRO END DESC,
        CASE WHEN p_OrdenarPor = 'FECHAREGISTRO' AND p_Direccion = 'ASC'  THEN FECHAREGISTRO END ASC,
        CASE WHEN p_OrdenarPor = 'DEUDA' AND p_Direccion = 'DESC' THEN DEUDA END DESC,
        CASE WHEN p_OrdenarPor = 'DEUDA' AND p_Direccion = 'ASC' THEN DEUDA END ASC,
        CASE WHEN p_OrdenarPor = 'ESTUDIANTE_NOMBRE' AND p_Direccion = 'DESC' THEN ESTUDIANTE_NOMBRE END DESC,
        CASE WHEN p_OrdenarPor = 'ESTUDIANTE_NOMBRE' AND p_Direccion = 'ASC' THEN ESTUDIANTE_NOMBRE END ASC,
        CASE WHEN p_OrdenarPor = 'FECHAFIN' AND p_Direccion = 'DESC' THEN FECHAFIN END DESC,
        CASE WHEN p_OrdenarPor = 'FECHAFIN' AND p_Direccion = 'ASC' THEN FECHAFIN END ASC,
        IDMENSUALIDAD DESC
    LIMIT p_TamanioPagina OFFSET v_offset;
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_mensualidad_listar_estudiante;

DELIMITER $$

CREATE PROCEDURE usp_mensualidad_listar_estudiante(IN p_IdUsuario VARCHAR(50))
main: BEGIN
    SELECT
        m.IDMENSUALIDAD,
        m.IDUSUARIO,
        m.IDPLAN,
        pl.NOMBRE AS PLAN_NOMBRE,
        m.FECHAINICIO,
        m.FECHAFIN,
        m.MONTOTOTAL,
        IFNULL(pag.PAGADO, 0) AS PAGADO,
        CASE WHEN IFNULL(m.MONTOTOTAL, 0) - IFNULL(pag.PAGADO, 0) < 0 THEN 0
             ELSE IFNULL(m.MONTOTOTAL, 0) - IFNULL(pag.PAGADO, 0) END AS DEUDA,
        m.ESTADOMIEMBRO,
        CASE m.ESTADOMIEMBRO
            WHEN 2 THEN 'Activo'
            WHEN 3 THEN 'Vencido'
            ELSE 'Activo'
        END AS ESTADOMIEMBRO_DESCRIPCION,
        m.ESTADO,
        m.FECHAREGISTRO,
        IFNULL(au.NOMBRE, '') AS AULA_NOMBRE
    FROM MENSUALIDAD m
    INNER JOIN `PLAN` pl ON pl.IDPLAN = m.IDPLAN
    LEFT JOIN AULA au ON au.IDAULA = m.IDAULA
    LEFT JOIN LATERAL (
        SELECT SUM(p.MONTO) AS PAGADO
        FROM PAGOMENSUALIDAD p
        WHERE p.IDMENSUALIDAD = m.IDMENSUALIDAD
    ) pag ON TRUE
    WHERE m.IDUSUARIO = p_IdUsuario
      AND m.ESTADO = 'Activo'
    ORDER BY m.FECHAREGISTRO DESC, m.IDMENSUALIDAD DESC;
END$$

DELIMITER ;
