-- ============================================================================
-- Justificación listar: filtros tutor, ciclo (plan), fechas y turno — MySQL 8
-- Ejecutar después de 26_07_2026/14.justificacion.sql
-- Fecha: 31/07/2026
-- ============================================================================

USE `AcademiaDB`;

DROP PROCEDURE IF EXISTS usp_justificacion_listar;

DELIMITER $$

CREATE PROCEDURE usp_justificacion_listar(
    IN p_Buscar VARCHAR(200),
    IN p_IdTutor VARCHAR(50),
    IN p_IdPlan VARCHAR(20),
    IN p_FechaDesde CHAR(8),
    IN p_FechaHasta CHAR(8),
    IN p_IdTurno VARCHAR(50),
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
    FROM JUSTIFICACION j
    INNER JOIN USUARIO est ON est.IDUSUARIO = j.IDUSUARIO
    LEFT JOIN USUARIO reg ON reg.IDUSUARIO = j.IDREGISTRADOR
    LEFT JOIN LATERAL (
        SELECT m.IDPLAN, m.IDTURNO, m.IDTUTOR
        FROM MENSUALIDAD m
        WHERE m.IDUSUARIO = j.IDUSUARIO
          AND (m.ESTADO IS NULL OR m.ESTADO = 'Activo')
          AND (m.FECHAINICIO IS NULL OR m.FECHAINICIO <= j.FECHA)
          AND (m.FECHAFIN IS NULL OR m.FECHAFIN >= j.FECHA)
        ORDER BY m.FECHAREGISTRO DESC, m.IDMENSUALIDAD DESC
        LIMIT 1
    ) mem ON TRUE
    LEFT JOIN `PLAN` pl ON pl.IDPLAN = mem.IDPLAN
    WHERE (p_Buscar IS NULL OR p_Buscar = ''
       OR est.DNI LIKE CONCAT('%', p_Buscar, '%')
       OR est.NOMBRE LIKE CONCAT('%', p_Buscar, '%')
       OR est.APELLIDO LIKE CONCAT('%', p_Buscar, '%')
       OR j.OBSERVACION LIKE CONCAT('%', p_Buscar, '%')
       OR reg.NOMBRE LIKE CONCAT('%', p_Buscar, '%')
       OR reg.APELLIDO LIKE CONCAT('%', p_Buscar, '%'))
      AND (p_FechaDesde IS NULL OR p_FechaDesde = '' OR j.FECHA >= p_FechaDesde)
      AND (p_FechaHasta IS NULL OR p_FechaHasta = '' OR j.FECHA <= p_FechaHasta)
      AND (p_IdTutor IS NULL OR p_IdTutor = '' OR mem.IDTUTOR = p_IdTutor)
      AND (p_IdPlan IS NULL OR p_IdPlan = '' OR mem.IDPLAN = p_IdPlan)
      AND (p_IdTurno IS NULL OR p_IdTurno = '' OR IFNULL(pl.IDTURNO, mem.IDTURNO) = p_IdTurno);

    SELECT
        j.IDJUSTIFICACION,
        j.IDUSUARIO,
        j.FECHA,
        j.HORAREGISTRO,
        j.IDREGISTRADOR,
        j.OBSERVACION,
        est.NOMBRE AS ESTUDIANTE_NOMBRE,
        est.APELLIDO AS ESTUDIANTE_APELLIDO,
        est.DNI,
        TRIM(CONCAT(IFNULL(reg.NOMBRE, ''), ' ', IFNULL(reg.APELLIDO, ''))) AS REGISTRADOR_NOMBRE
    FROM JUSTIFICACION j
    INNER JOIN USUARIO est ON est.IDUSUARIO = j.IDUSUARIO
    LEFT JOIN USUARIO reg ON reg.IDUSUARIO = j.IDREGISTRADOR
    LEFT JOIN LATERAL (
        SELECT m.IDPLAN, m.IDTURNO, m.IDTUTOR
        FROM MENSUALIDAD m
        WHERE m.IDUSUARIO = j.IDUSUARIO
          AND (m.ESTADO IS NULL OR m.ESTADO = 'Activo')
          AND (m.FECHAINICIO IS NULL OR m.FECHAINICIO <= j.FECHA)
          AND (m.FECHAFIN IS NULL OR m.FECHAFIN >= j.FECHA)
        ORDER BY m.FECHAREGISTRO DESC, m.IDMENSUALIDAD DESC
        LIMIT 1
    ) mem ON TRUE
    LEFT JOIN `PLAN` pl ON pl.IDPLAN = mem.IDPLAN
    WHERE (p_Buscar IS NULL OR p_Buscar = ''
       OR est.DNI LIKE CONCAT('%', p_Buscar, '%')
       OR est.NOMBRE LIKE CONCAT('%', p_Buscar, '%')
       OR est.APELLIDO LIKE CONCAT('%', p_Buscar, '%')
       OR j.OBSERVACION LIKE CONCAT('%', p_Buscar, '%')
       OR reg.NOMBRE LIKE CONCAT('%', p_Buscar, '%')
       OR reg.APELLIDO LIKE CONCAT('%', p_Buscar, '%'))
      AND (p_FechaDesde IS NULL OR p_FechaDesde = '' OR j.FECHA >= p_FechaDesde)
      AND (p_FechaHasta IS NULL OR p_FechaHasta = '' OR j.FECHA <= p_FechaHasta)
      AND (p_IdTutor IS NULL OR p_IdTutor = '' OR mem.IDTUTOR = p_IdTutor)
      AND (p_IdPlan IS NULL OR p_IdPlan = '' OR mem.IDPLAN = p_IdPlan)
      AND (p_IdTurno IS NULL OR p_IdTurno = '' OR IFNULL(pl.IDTURNO, mem.IDTURNO) = p_IdTurno)
    ORDER BY j.FECHA DESC, j.HORAREGISTRO DESC
    LIMIT p_TamanioPagina OFFSET v_offset;
END$$

DELIMITER ;
