-- ============================================================================
-- Informe asistencias: alinear buscador con aula/plan/turno y DIASASISTENCIA
-- Evita que un filtro por salón/ciclo liste alumnos pero omita sus marcas.
-- Fecha: 03/09/2026
-- ============================================================================

USE `AcademiaDB`;

DROP PROCEDURE IF EXISTS usp_asistencia_informe;

DELIMITER $$

CREATE PROCEDURE usp_asistencia_informe(
    IN p_FechaDesde CHAR(8),
    IN p_FechaHasta CHAR(8),
    IN p_Buscar VARCHAR(200),
    IN p_IDPlan VARCHAR(20),
    IN p_EstadoUsuario VARCHAR(50)
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
        UPPER(IFNULL(tut.NOMBRE, '')) AS TUTORA,
        IFNULL(au.NOMBRE, '') AS AULA,
        UPPER(TRIM(CONCAT(
            IFNULL(pl.NOMBRE, ''),
            CASE WHEN tu.DESCRIPCION IS NOT NULL AND tu.DESCRIPCION <> '' THEN CONCAT(' ', tu.DESCRIPCION) ELSE '' END
        ))) AS CICLO,
        mem.FECHAINICIO AS FECHA_INICIO_MEM,
        mem.FECHAFIN AS FECHA_VENCE,
        mem.IDPLAN,
        IFNULL(pl.DIASASISTENCIA, 63) AS DIASASISTENCIA
    FROM USUARIO u
    LEFT JOIN LATERAL (
        SELECT m.IDAULA, m.IDPLAN, m.IDTURNO, m.FECHAINICIO, m.FECHAFIN
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
    LEFT JOIN USUARIO tut ON tut.IDUSUARIO = au.IDTUTORA
    LEFT JOIN `PLAN` pl ON pl.IDPLAN = mem.IDPLAN
    LEFT JOIN TURNO tu ON tu.IDTURNO = mem.IDTURNO
    WHERE u.IDTIPOUSUARIO = '1'
      AND (
          p_EstadoUsuario IS NULL OR p_EstadoUsuario = '' OR
          UPPER(IFNULL(u.ESTADO, 'Activo')) = UPPER(p_EstadoUsuario)
      )
      AND (
          p_IDPlan IS NULL OR p_IDPlan = '' OR mem.IDPLAN = p_IDPlan
      )
      AND (
          p_Buscar IS NULL OR p_Buscar = '' OR
          u.DNI LIKE CONCAT('%', p_Buscar, '%') OR
          u.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
          u.APELLIDO LIKE CONCAT('%', p_Buscar, '%') OR
          u.IDUSUARIO LIKE CONCAT('%', p_Buscar, '%') OR
          IFNULL(au.NOMBRE, '') LIKE CONCAT('%', p_Buscar, '%') OR
          IFNULL(pl.NOMBRE, '') LIKE CONCAT('%', p_Buscar, '%') OR
          IFNULL(tu.DESCRIPCION, '') LIKE CONCAT('%', p_Buscar, '%')
      )
    ORDER BY u.APELLIDO, u.NOMBRE;

    SELECT
        a.IDUSUARIO,
        a.FECHAREGISTRO,
        a.ESTADO,
        a.JUSTIFICADO
    FROM ASISTENCIA a
    INNER JOIN USUARIO u ON u.IDUSUARIO = a.IDUSUARIO
    WHERE u.IDTIPOUSUARIO = '1'
      AND a.FECHAREGISTRO IS NOT NULL
      AND TRIM(a.FECHAREGISTRO) <> ''
      AND STR_TO_DATE(a.FECHAREGISTRO, '%d%m%Y')
          BETWEEN STR_TO_DATE(p_FechaDesde, '%d%m%Y')
              AND STR_TO_DATE(p_FechaHasta, '%d%m%Y')
      AND (
          p_EstadoUsuario IS NULL OR p_EstadoUsuario = '' OR
          UPPER(IFNULL(u.ESTADO, 'Activo')) = UPPER(p_EstadoUsuario)
      )
      AND (
          p_IDPlan IS NULL OR p_IDPlan = '' OR
          EXISTS (
              SELECT 1
              FROM MENSUALIDAD m
              WHERE m.IDUSUARIO = u.IDUSUARIO
                AND m.IDPLAN = p_IDPlan
                AND (m.ESTADO IS NULL OR m.ESTADO = 'Activo')
                AND (m.FECHAINICIO IS NULL OR m.FECHAINICIO <= p_FechaHasta)
                AND (m.FECHAFIN IS NULL OR m.FECHAFIN >= p_FechaDesde)
          )
      )
      AND (
          p_Buscar IS NULL OR p_Buscar = '' OR
          u.DNI LIKE CONCAT('%', p_Buscar, '%') OR
          u.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
          u.APELLIDO LIKE CONCAT('%', p_Buscar, '%') OR
          u.IDUSUARIO LIKE CONCAT('%', p_Buscar, '%') OR
          EXISTS (
              SELECT 1
              FROM MENSUALIDAD m
              LEFT JOIN AULA au2 ON au2.IDAULA = m.IDAULA
              LEFT JOIN `PLAN` pl2 ON pl2.IDPLAN = m.IDPLAN
              LEFT JOIN TURNO tu2 ON tu2.IDTURNO = m.IDTURNO
              WHERE m.IDUSUARIO = u.IDUSUARIO
                AND (m.ESTADO IS NULL OR m.ESTADO = 'Activo')
                AND (
                    IFNULL(au2.NOMBRE, '') LIKE CONCAT('%', p_Buscar, '%') OR
                    IFNULL(pl2.NOMBRE, '') LIKE CONCAT('%', p_Buscar, '%') OR
                    IFNULL(tu2.DESCRIPCION, '') LIKE CONCAT('%', p_Buscar, '%')
                )
          )
      );
END$$

DELIMITER ;

SELECT 'usp_asistencia_informe: buscador alineado + fechas por STR_TO_DATE.' AS info;
