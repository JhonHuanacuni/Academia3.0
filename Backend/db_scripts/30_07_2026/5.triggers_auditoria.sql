/* ============================================================================
   Triggers de auditoría por tabla (log en AUDITORIA)
   Usa SESSION_CONTEXT(N'IDUSUARIO') establecido desde el backend.
   Fecha: 31/07/2026 — fix QUOTED_IDENTIFIER + sin UPDATE recursivo en misma tabla
   Prerequisito: 2.auditoria_tabla.sql
   ============================================================================ */

SET QUOTED_IDENTIFIER ON;
GO
SET ANSI_NULLS ON;
GO

IF OBJECT_ID('dbo.usp_auditoria_instalar_trigger', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_auditoria_instalar_trigger;
GO

SET QUOTED_IDENTIFIER ON;
GO
SET ANSI_NULLS ON;
GO

CREATE PROCEDURE dbo.usp_auditoria_instalar_trigger
    @Tabla SYSNAME,
    @ColumnaPk SYSNAME
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID(QUOTENAME('dbo') + '.' + QUOTENAME(@Tabla), 'U') IS NULL
    BEGIN
        PRINT 'Tabla omitida (no existe): ' + @Tabla;
        RETURN;
    END

    DECLARE @Trigger SYSNAME = N'tr_' + @Tabla + N'_auditoria';
    DECLARE @Sql NVARCHAR(MAX);

    IF OBJECT_ID(@Trigger, 'TR') IS NOT NULL
    BEGIN
        SET @Sql = N'DROP TRIGGER dbo.' + QUOTENAME(@Trigger) + N';';
        EXEC sp_executesql @Sql;
    END

    SET @Sql = N'
CREATE TRIGGER dbo.' + QUOTENAME(@Trigger) + N'
ON dbo.' + QUOTENAME(@Tabla) + N'
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @IdUsuario NVARCHAR(50) = TRY_CAST(SESSION_CONTEXT(N''IDUSUARIO'') AS NVARCHAR(50));
    DECLARE @Fecha CHAR(8) = dbo.fn_fecha_ddmmyyyy();
    DECLARE @Hora CHAR(8) = CONVERT(CHAR(8), GETDATE(), 108);
    DECLARE @IdAud NVARCHAR(50);
    DECLARE @IdReg NVARCHAR(50);
    DECLARE @JsonAntes NVARCHAR(MAX);
    DECLARE @JsonDespues NVARCHAR(MAX);
    DECLARE @TablaNombre NVARCHAR(100) = N''' + @Tabla + N''';

    IF EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted)
    BEGIN
        DECLARE curIns CURSOR LOCAL FAST_FORWARD FOR
            SELECT CAST(i.' + QUOTENAME(@ColumnaPk) + N' AS NVARCHAR(50)),
                   (SELECT i.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
            FROM inserted i;
        OPEN curIns;
        FETCH NEXT FROM curIns INTO @IdReg, @JsonDespues;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC dbo.usp_auditoria_siguiente_id @Id = @IdAud OUTPUT;
            INSERT INTO dbo.AUDITORIA (
                IDAUDITORIA, TABLA, IDREGISTRO, ACCION, IDUSUARIO, FECHA, HORA, DATOS_ANTES, DATOS_DESPUES
            ) VALUES (
                @IdAud, @TablaNombre, @IdReg, N''INSERT'', @IdUsuario, @Fecha, @Hora, NULL, @JsonDespues
            );
            FETCH NEXT FROM curIns INTO @IdReg, @JsonDespues;
        END
        CLOSE curIns;
        DEALLOCATE curIns;
    END

    IF EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
    BEGIN
        DECLARE curUpd CURSOR LOCAL FAST_FORWARD FOR
            SELECT CAST(i.' + QUOTENAME(@ColumnaPk) + N' AS NVARCHAR(50)),
                   (SELECT d.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER),
                   (SELECT i.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
            FROM inserted i
            INNER JOIN deleted d ON i.' + QUOTENAME(@ColumnaPk) + N' = d.' + QUOTENAME(@ColumnaPk) + N';
        OPEN curUpd;
        FETCH NEXT FROM curUpd INTO @IdReg, @JsonAntes, @JsonDespues;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC dbo.usp_auditoria_siguiente_id @Id = @IdAud OUTPUT;
            INSERT INTO dbo.AUDITORIA (
                IDAUDITORIA, TABLA, IDREGISTRO, ACCION, IDUSUARIO, FECHA, HORA, DATOS_ANTES, DATOS_DESPUES
            ) VALUES (
                @IdAud, @TablaNombre, @IdReg, N''UPDATE'', @IdUsuario, @Fecha, @Hora, @JsonAntes, @JsonDespues
            );
            FETCH NEXT FROM curUpd INTO @IdReg, @JsonAntes, @JsonDespues;
        END
        CLOSE curUpd;
        DEALLOCATE curUpd;
    END

    IF EXISTS (SELECT 1 FROM deleted) AND NOT EXISTS (SELECT 1 FROM inserted)
    BEGIN
        DECLARE curDel CURSOR LOCAL FAST_FORWARD FOR
            SELECT CAST(d.' + QUOTENAME(@ColumnaPk) + N' AS NVARCHAR(50)),
                   (SELECT d.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
            FROM deleted d;
        OPEN curDel;
        FETCH NEXT FROM curDel INTO @IdReg, @JsonAntes;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC dbo.usp_auditoria_siguiente_id @Id = @IdAud OUTPUT;
            INSERT INTO dbo.AUDITORIA (
                IDAUDITORIA, TABLA, IDREGISTRO, ACCION, IDUSUARIO, FECHA, HORA, DATOS_ANTES, DATOS_DESPUES
            ) VALUES (
                @IdAud, @TablaNombre, @IdReg, N''DELETE'', @IdUsuario, @Fecha, @Hora, @JsonAntes, NULL
            );
            FETCH NEXT FROM curDel INTO @IdReg, @JsonAntes;
        END
        CLOSE curDel;
        DEALLOCATE curDel;
    END
END;';

    SET QUOTED_IDENTIFIER ON;
    SET ANSI_NULLS ON;
    EXEC sp_executesql @Sql;
    PRINT 'Trigger instalado: ' + @Trigger;
END;
GO

DECLARE @Cfg TABLE (Tabla SYSNAME, ColumnaPk SYSNAME);
INSERT INTO @Cfg (Tabla, ColumnaPk) VALUES
    ('USUARIO', 'IDUSUARIO'),
    ('MENSUALIDAD', 'IDMENSUALIDAD'),
    ('PAGOMENSUALIDAD', 'IDPAGOMENSUALIDAD'),
    ('PAGOEXTRAORDINARIO', 'IDPAGOEXTRA'),
    ('AULA', 'IDAULA'),
    ('PLAN', 'IDPLAN'),
    ('TUTOR', 'IDTUTOR'),
    ('CATEGORIA', 'IDCATEGORIA'),
    ('MATERIA', 'IDMATERIA'),
    ('CONCEPTOPAGOEXTRA', 'IDCONCEPTO'),
    ('LIBRO', 'IDLIBRO'),
    ('HORARIO', 'IDHORARIO'),
    ('EXAMEN', 'IDEXAMEN'),
    ('ASISTENCIA', 'IDASISTENCIA'),
    ('JUSTIFICACION', 'IDJUSTIFICACION'),
    ('NOTAS_IMPORTACION', 'IDIMPORTACION'),
    ('NOTA_IMPORTADA', 'IDNOTA');

DECLARE @T SYSNAME, @Pk SYSNAME;
DECLARE c CURSOR LOCAL FAST_FORWARD FOR SELECT Tabla, ColumnaPk FROM @Cfg;
OPEN c;
FETCH NEXT FROM c INTO @T, @Pk;
WHILE @@FETCH_STATUS = 0
BEGIN
    EXEC dbo.usp_auditoria_instalar_trigger @Tabla = @T, @ColumnaPk = @Pk;
    FETCH NEXT FROM c INTO @T, @Pk;
END
CLOSE c;
DEALLOCATE c;
GO

PRINT 'Triggers de auditoría instalados.';
GO
