-- ============================================================================
-- 5. usp_asistencia_informe (con filtros aula y tutor)
-- Fecha: 13/09/2026
-- phpMyAdmin: selecciona tu BD, pega TODO y ejecuta
-- ============================================================================

DROP PROCEDURE IF EXISTS usp_asistencia_informe;

DELIMITER $$

CREATE PROCEDURE usp_asistencia_informe(
    IN p_FechaDesde CHAR(8),
    IN p_FechaHasta CHAR(8),
    IN p_Buscar VARCHAR(200),
    IN p_IDPlan VARCHAR(20),
    IN p_EstadoUsuario VARCHAR(50),
    IN p_IDAula VARCHAR(50),
    IN p_IDTutor VARCHAR(50)
)
main: BEGIN
    IF p_FechaDesde IS NULL OR p_FechaDesde = '' OR p_FechaHasta IS NULL OR p_FechaHasta = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe indicar fecha desde y fecha hasta.';
    END IF;

    IF p_FechaDesde > p_FechaHasta THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La fecha desde no puede ser mayor que la fecha hasta.';
    END IF;

    SELECT
        u.IDUSUARIO,
        UPPER(TRIM(CONCAT(IFNULL(u.APELLIDO, ''), ' ', IFNULL(u.NOMBRE, '')))) AS NOMBRE_COMPLETO,
        UPPER(IFNULL(u.ESTADO, 'Activo')) AS ESTADO,
        UPPER(TRIM(COALESCE(NULLIF(tut_mem.NOMBRE, ''), NULLIF(tut_aula.NOMBRE, ''), ''))) AS TUTORA,
        IFNULL(au.NOMBRE, '') AS AULA,
        UPPER(TRIM(CONCAT(
            IFNULL(pl.NOMBRE, ''),
            CASE WHEN tu.DESCRIPCION IS NOT NULL AND tu.DESCRIPCION <> '' THEN CONCAT(' ', tu.DESCRIPCION) ELSE '' END
        ))) AS CICLO,
        mem.FECHAINICIO AS FECHA_INICIO_MEM,
        mem.FECHAFIN AS FECHA_VENCE,
        mem.IDPLAN,
        mem.IDAULA,
        mem.IDTUTOR,
        IFNULL(pl.DIASASISTENCIA, 63) AS DIASASISTENCIA
    FROM USUARIO u
    LEFT JOIN LATERAL (
        SELECT m.IDAULA, m.IDPLAN, m.IDTURNO, m.IDTUTOR, m.FECHAINICIO, m.FECHAFIN
        FROM MENSUALIDAD m
        WHERE m.IDUSUARIO = u.IDUSUARIO
          AND (m.ESTADO IS NULL OR m.ESTADO = 'Activo')
        ORDER BY
            CASE
                WHEN (m.FECHAINICIO IS NULL OR m.FECHAINICIO <= p_FechaHasta)
                 AND (m.FECHAFIN IS NULL OR m.FECHAFIN >= p_FechaDesde)
                THEN 0 ELSE 1
            END,
            m.FECHAREGISTRO DESC,
            m.FECHAINICIO DESC
        LIMIT 1
    ) mem ON TRUE
    LEFT JOIN AULA au ON au.IDAULA = mem.IDAULA
    LEFT JOIN TUTOR tut_mem ON tut_mem.IDTUTOR = mem.IDTUTOR
    LEFT JOIN TUTOR tut_aula ON tut_aula.IDTUTOR = au.IDTUTOR
    LEFT JOIN `PLAN` pl ON pl.IDPLAN = mem.IDPLAN
    LEFT JOIN TURNO tu ON tu.IDTURNO = mem.IDTURNO
    WHERE u.IDTIPOUSUARIO = '1'
      AND (
          p_EstadoUsuario IS NULL OR p_EstadoUsuario = '' OR
          UPPER(IFNULL(u.ESTADO, 'Activo')) = UPPER(p_EstadoUsuario)
      )
      AND (p_IDPlan IS NULL OR p_IDPlan = '' OR mem.IDPLAN = p_IDPlan)
      AND (p_IDAula IS NULL OR p_IDAula = '' OR mem.IDAULA = p_IDAula)
      AND (
          p_IDTutor IS NULL OR p_IDTutor = '' OR
          mem.IDTUTOR = p_IDTutor OR au.IDTUTOR = p_IDTutor
      )
      AND (
          p_Buscar IS NULL OR p_Buscar = '' OR
          u.DNI LIKE CONCAT('%', p_Buscar, '%') OR
          u.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
          u.APELLIDO LIKE CONCAT('%', p_Buscar, '%') OR
          u.IDUSUARIO LIKE CONCAT('%', p_Buscar, '%') OR
          IFNULL(au.NOMBRE, '') LIKE CONCAT('%', p_Buscar, '%') OR
          IFNULL(pl.NOMBRE, '') LIKE CONCAT('%', p_Buscar, '%') OR
          IFNULL(tu.DESCRIPCION, '') LIKE CONCAT('%', p_Buscar, '%') OR
          IFNULL(tut_mem.NOMBRE, '') LIKE CONCAT('%', p_Buscar, '%')
      )
    ORDER BY u.APELLIDO, u.NOMBRE;
END$$

DELIMITER ;

SELECT '5. usp_asistencia_informe listo.' AS info;
