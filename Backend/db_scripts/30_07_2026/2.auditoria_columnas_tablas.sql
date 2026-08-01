/* ============================================================================
   Columnas de auditoría en tablas principales y delicadas
   CREADO_POR, FECHACREACION, HORACREACION,
   MODIFICADO_POR, FECHAMODIFICACION, HORAMODIFICACION
   Fecha: 31/07/2026
   ============================================================================ */

IF OBJECT_ID('dbo.usp_auditoria_agregar_columnas', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_auditoria_agregar_columnas;
GO
CREATE PROCEDURE dbo.usp_auditoria_agregar_columnas
    @Tabla SYSNAME
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID(QUOTENAME('dbo') + '.' + QUOTENAME(@Tabla), 'U') IS NULL
    BEGIN
        PRINT 'Tabla omitida (no existe): ' + @Tabla;
        RETURN;
    END

    DECLARE @Sql NVARCHAR(MAX);

    IF COL_LENGTH(@Tabla, 'CREADO_POR') IS NULL
    BEGIN
        SET @Sql = N'ALTER TABLE dbo.' + QUOTENAME(@Tabla) + N' ADD CREADO_POR NVARCHAR(50) NULL;';
        EXEC sp_executesql @Sql;
    END

    IF COL_LENGTH(@Tabla, 'FECHACREACION') IS NULL
    BEGIN
        SET @Sql = N'ALTER TABLE dbo.' + QUOTENAME(@Tabla) + N' ADD FECHACREACION CHAR(8) NULL;';
        EXEC sp_executesql @Sql;
    END

    IF COL_LENGTH(@Tabla, 'HORACREACION') IS NULL
    BEGIN
        SET @Sql = N'ALTER TABLE dbo.' + QUOTENAME(@Tabla) + N' ADD HORACREACION CHAR(8) NULL;';
        EXEC sp_executesql @Sql;
    END

    IF COL_LENGTH(@Tabla, 'MODIFICADO_POR') IS NULL
    BEGIN
        SET @Sql = N'ALTER TABLE dbo.' + QUOTENAME(@Tabla) + N' ADD MODIFICADO_POR NVARCHAR(50) NULL;';
        EXEC sp_executesql @Sql;
    END

    IF COL_LENGTH(@Tabla, 'FECHAMODIFICACION') IS NULL
    BEGIN
        SET @Sql = N'ALTER TABLE dbo.' + QUOTENAME(@Tabla) + N' ADD FECHAMODIFICACION CHAR(8) NULL;';
        EXEC sp_executesql @Sql;
    END

    IF COL_LENGTH(@Tabla, 'HORAMODIFICACION') IS NULL
    BEGIN
        SET @Sql = N'ALTER TABLE dbo.' + QUOTENAME(@Tabla) + N' ADD HORAMODIFICACION CHAR(8) NULL;';
        EXEC sp_executesql @Sql;
    END

    PRINT 'Columnas de auditoría verificadas en ' + @Tabla + '.';
END;
GO

EXEC dbo.usp_auditoria_agregar_columnas @Tabla = 'USUARIO';
EXEC dbo.usp_auditoria_agregar_columnas @Tabla = 'MENSUALIDAD';
EXEC dbo.usp_auditoria_agregar_columnas @Tabla = 'PAGOMENSUALIDAD';
EXEC dbo.usp_auditoria_agregar_columnas @Tabla = 'PAGOEXTRAORDINARIO';
EXEC dbo.usp_auditoria_agregar_columnas @Tabla = 'AULA';
EXEC dbo.usp_auditoria_agregar_columnas @Tabla = 'PLAN';
EXEC dbo.usp_auditoria_agregar_columnas @Tabla = 'TUTOR';
EXEC dbo.usp_auditoria_agregar_columnas @Tabla = 'CATEGORIA';
EXEC dbo.usp_auditoria_agregar_columnas @Tabla = 'MATERIA';
EXEC dbo.usp_auditoria_agregar_columnas @Tabla = 'CONCEPTOPAGOEXTRA';
EXEC dbo.usp_auditoria_agregar_columnas @Tabla = 'LIBRO';
EXEC dbo.usp_auditoria_agregar_columnas @Tabla = 'HORARIO';
EXEC dbo.usp_auditoria_agregar_columnas @Tabla = 'EXAMEN';
EXEC dbo.usp_auditoria_agregar_columnas @Tabla = 'ASISTENCIA';
EXEC dbo.usp_auditoria_agregar_columnas @Tabla = 'JUSTIFICACION';
EXEC dbo.usp_auditoria_agregar_columnas @Tabla = 'NOTAS_IMPORTACION';
EXEC dbo.usp_auditoria_agregar_columnas @Tabla = 'NOTA_IMPORTADA';
GO

IF OBJECT_ID('dbo.usp_auditoria_agregar_columnas', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_auditoria_agregar_columnas;
GO

/* Backfill desde columnas legacy donde aplique */
IF COL_LENGTH('MENSUALIDAD', 'CREADO_POR') IS NOT NULL
   AND COL_LENGTH('MENSUALIDAD', 'REGISTRADOPOR') IS NOT NULL
BEGIN
    UPDATE dbo.MENSUALIDAD
    SET CREADO_POR = COALESCE(CREADO_POR, REGISTRADOPOR),
        FECHACREACION = COALESCE(FECHACREACION, FECHAREGISTRO),
        HORACREACION = COALESCE(HORACREACION, HORAREGISTRO)
    WHERE REGISTRADOPOR IS NOT NULL OR FECHAREGISTRO IS NOT NULL;
END
GO

IF COL_LENGTH('NOTAS_IMPORTACION', 'CREADO_POR') IS NOT NULL
   AND COL_LENGTH('NOTAS_IMPORTACION', 'IMPORTADO_POR') IS NOT NULL
BEGIN
    UPDATE dbo.NOTAS_IMPORTACION
    SET CREADO_POR = COALESCE(CREADO_POR, IMPORTADO_POR)
    WHERE IMPORTADO_POR IS NOT NULL;
END
GO

IF COL_LENGTH('JUSTIFICACION', 'CREADO_POR') IS NOT NULL
   AND COL_LENGTH('JUSTIFICACION', 'IDREGISTRADOR') IS NOT NULL
BEGIN
    UPDATE dbo.JUSTIFICACION
    SET CREADO_POR = COALESCE(CREADO_POR, IDREGISTRADOR),
        HORACREACION = COALESCE(HORACREACION, HORAREGISTRO)
    WHERE IDREGISTRADOR IS NOT NULL;
END
GO

PRINT 'Columnas de auditoría listas.';
GO
