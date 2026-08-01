-- Convertido automáticamente desde db_scripts/30_07_2026/2.auditoria_columnas_tablas.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   Columnas de auditoría en tablas principales y delicadas
   CREADO_POR, FECHACREACION, HORACREACION,
   MODIFICADO_POR, FECHAMODIFICACION, HORAMODIFICACION
   Fecha: 31/07/2026
   ============================================================================ */

DROP PROCEDURE IF EXISTS usp_auditoria_agregar_columnas;

DROP PROCEDURE IF EXISTS usp_auditoria_agregar_columnas;

DELIMITER $$

CREATE PROCEDURE usp_auditoria_agregar_columnas(
    IN p_Tabla VARCHAR(128)
)
main: BEGIN
IF OBJECT_ID(QUOTENAME('dbo') + '.' + QUOTENAME(p_Tabla), 'U') IS NULL
    BEGIN
        SELECT CONCAT('Tabla omitida (no existe): ', p_Tabla);
        LEAVE main;
    
    DECLARE v_Sql LONGTEXT;

    IF COL_LENGTH(p_Tabla, 'CREADO_POR') IS NULL
    BEGIN
        SET v_Sql = N'ALTER TABLE ' + QUOTENAME(p_Tabla) + N' ADD CREADO_POR VARCHAR(50) NULL;';
        EXEC sp_executesql v_Sql;
    
    IF COL_LENGTH(p_Tabla, 'FECHACREACION') IS NULL
    BEGIN
        SET v_Sql = N'ALTER TABLE ' + QUOTENAME(p_Tabla) + N' ADD FECHACREACION CHAR(8) NULL;';
        EXEC sp_executesql v_Sql;
    
    IF COL_LENGTH(p_Tabla, 'HORACREACION') IS NULL
    BEGIN
        SET v_Sql = N'ALTER TABLE ' + QUOTENAME(p_Tabla) + N' ADD HORACREACION CHAR(8) NULL;';
        EXEC sp_executesql v_Sql;
    
    IF COL_LENGTH(p_Tabla, 'MODIFICADO_POR') IS NULL
    BEGIN
        SET v_Sql = N'ALTER TABLE ' + QUOTENAME(p_Tabla) + N' ADD MODIFICADO_POR VARCHAR(50) NULL;';
        EXEC sp_executesql v_Sql;
    
    IF COL_LENGTH(p_Tabla, 'FECHAMODIFICACION') IS NULL
    BEGIN
        SET v_Sql = N'ALTER TABLE ' + QUOTENAME(p_Tabla) + N' ADD FECHAMODIFICACION CHAR(8) NULL;';
        EXEC sp_executesql v_Sql;
    
    IF COL_LENGTH(p_Tabla, 'HORAMODIFICACION') IS NULL
    BEGIN
        SET v_Sql = N'ALTER TABLE ' + QUOTENAME(p_Tabla) + N' ADD HORAMODIFICACION CHAR(8) NULL;';
        EXEC sp_executesql v_Sql;
    
    SELECT CONCAT('Columnas de auditoría verificadas en ', p_Tabla) + '.';
END;

EXEC usp_auditoria_agregar_columnas p_Tabla = 'USUARIO';
EXEC usp_auditoria_agregar_columnas p_Tabla = 'MENSUALIDAD';
EXEC usp_auditoria_agregar_columnas p_Tabla = 'PAGOMENSUALIDAD';
EXEC usp_auditoria_agregar_columnas p_Tabla = 'PAGOEXTRAORDINARIO';
EXEC usp_auditoria_agregar_columnas p_Tabla = 'AULA';
EXEC usp_auditoria_agregar_columnas p_Tabla = 'PLAN';
EXEC usp_auditoria_agregar_columnas p_Tabla = 'TUTOR';
EXEC usp_auditoria_agregar_columnas p_Tabla = 'CATEGORIA';
EXEC usp_auditoria_agregar_columnas p_Tabla = 'MATERIA';
EXEC usp_auditoria_agregar_columnas p_Tabla = 'CONCEPTOPAGOEXTRA';
EXEC usp_auditoria_agregar_columnas p_Tabla = 'LIBRO';
EXEC usp_auditoria_agregar_columnas p_Tabla = 'HORARIO';
EXEC usp_auditoria_agregar_columnas p_Tabla = 'EXAMEN';
EXEC usp_auditoria_agregar_columnas p_Tabla = 'ASISTENCIA';
EXEC usp_auditoria_agregar_columnas p_Tabla = 'JUSTIFICACION';
EXEC usp_auditoria_agregar_columnas p_Tabla = 'NOTAS_IMPORTACION';
EXEC usp_auditoria_agregar_columnas p_Tabla = 'NOTA_IMPORTADA';
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_auditoria_agregar_columnas;

/* Backfill desde columnas legacy donde aplique */
IF COL_LENGTH('MENSUALIDAD', 'CREADO_POR') IS NOT NULL
   AND COL_LENGTH('MENSUALIDAD', 'REGISTRADOPOR') IS NOT NULL
BEGIN
    UPDATE MENSUALIDAD
    SET CREADO_POR = COALESCE(CREADO_POR, REGISTRADOPOR),
        FECHACREACION = COALESCE(FECHACREACION, FECHAREGISTRO),
        HORACREACION = COALESCE(HORACREACION, HORAREGISTRO)
    WHERE REGISTRADOPOR IS NOT NULL OR FECHAREGISTRO IS NOT NULL;

IF COL_LENGTH('NOTAS_IMPORTACION', 'CREADO_POR') IS NOT NULL
   AND COL_LENGTH('NOTAS_IMPORTACION', 'IMPORTADO_POR') IS NOT NULL
BEGIN
    UPDATE NOTAS_IMPORTACION
    SET CREADO_POR = COALESCE(CREADO_POR, IMPORTADO_POR)
    WHERE IMPORTADO_POR IS NOT NULL;

IF COL_LENGTH('JUSTIFICACION', 'CREADO_POR') IS NOT NULL
   AND COL_LENGTH('JUSTIFICACION', 'IDREGISTRADOR') IS NOT NULL
BEGIN
    UPDATE JUSTIFICACION
    SET CREADO_POR = COALESCE(CREADO_POR, IDREGISTRADOR),
        HORACREACION = COALESCE(HORACREACION, HORAREGISTRO)
    WHERE IDREGISTRADOR IS NOT NULL;

SELECT 'Columnas de auditoría listas.';
