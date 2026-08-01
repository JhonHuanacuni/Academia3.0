-- Convertido automáticamente desde db_scripts/06_07_2026/10.usp_asistencia_informe_vence_vigente.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   Alter: FECHA_VENCE = fin de membresía vigente en el período (columna VENCE)
   Ejecutar después de 3.alter_usp_asistencia_informe_vence.sql
   Fecha: 06/07/2026
   ============================================================================ */

DROP PROCEDURE IF EXISTS usp_asistencia_informe;

DROP PROCEDURE IF EXISTS usp_asistencia_informe;

DELIMITER $$

CREATE PROCEDURE usp_asistencia_informe(
    IN p_FechaDesde CHAR(8),
    IN p_FechaHasta CHAR(8),
    IN p_Buscar VARCHAR(200)
)
main: BEGIN
IF p_FechaDesde IS NULL OR p_FechaDesde = '' OR p_FechaHasta IS NULL OR p_FechaHasta = '' THEN
        RAISERROR('Debe indicar fecha desde y fecha hasta.', 16, 1);
        LEAVE main;
    
    END IF;

    IF p_FechaDesde > p_FechaHasta THEN
        RAISERROR('La fecha desde no puede ser mayor que la fecha hasta.', 16, 1);
        LEAVE main;
    
    SELECT
        u.IDUSUARIO,
        UPPER(TRIM(
            CONCAT(IFNULL(u.APELLIDO, ''), ' ') + IFNULL(u.NOMBRE, '')
        ))) AS NOMBRE_COMPLETO,
        UPPER(IFNULL(u.ESTADO, 'Activo')) AS ESTADO,
        UPPER(IFNULL(tut.NOMBRE, '')) AS TUTORA,
        IFNULL(au.NOMBRE, '') AS AULA,
        CONCAT(UPPER(TRIM(
            IFNULL(pl.NOMBRE, ''), CASE) WHEN tu.DESCRIPCION IS NOT NULL AND tu.DESCRIPCION <> ''
                 THEN CONCAT(' ', tu.DESCRIPCION) ELSE '' 
        ))) AS CICLO,
        mem.FECHAFIN AS FECHA_VENCE
    FROM USUARIO u
    OUTER APPLY (
        SELECT TOP 1 m.IDAULA, m.IDPLAN, m.IDTURNO, m.FECHAFIN
        FROM MEMBRESIA m
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
    ) mem
    LEFT JOIN AULA au ON au.IDAULA = mem.IDAULA
    LEFT JOIN USUARIO tut ON tut.IDUSUARIO = au.IDTUTORA
    LEFT JOIN `PLAN` pl ON pl.IDPLAN = mem.IDPLAN
    LEFT JOIN TURNO tu ON tu.IDTURNO = mem.IDTURNO
    WHERE u.IDTIPOUSUARIO = '1'
      AND u.ESTADO = 'Activo'
      AND (
          p_Buscar IS NULL OR p_Buscar = '' OR
          u.DNI LIKE CONCAT('%', p_Buscar, '%') OR
          u.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
          u.APELLIDO LIKE CONCAT('%', p_Buscar, '%') OR
          u.IDUSUARIO LIKE CONCAT('%', p_Buscar, '%') OR
          IFNULL(au.NOMBRE, '') LIKE CONCAT('%', p_Buscar, '%')
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
      AND a.FECHAREGISTRO >= p_FechaDesde
      AND a.FECHAREGISTRO <= p_FechaHasta
      AND (
          p_Buscar IS NULL OR p_Buscar = '' OR
          u.DNI LIKE CONCAT('%', p_Buscar, '%') OR
          u.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
          u.APELLIDO LIKE CONCAT('%', p_Buscar, '%') OR
          u.IDUSUARIO LIKE CONCAT('%', p_Buscar, '%')
      );
END;

SELECT 'usp_asistencia_informe: FECHA_VENCE desde membresía vigente (FECHAFIN).';
END$$

DELIMITER ;