/* ============================================================================
   Módulo Informes (MOD010) + submódulo Asistencias (SUB011)
   Ejecutar después de scripts 22_06_2026 y 29_06_2026
   Fecha: 06/07/2026
   ============================================================================ */

/* Tutora asignada al aula (opcional, para columna TUTORA del informe) */
IF COL_LENGTH('AULA', 'IDTUTORA') IS NULL
BEGIN
    ALTER TABLE AULA ADD IDTUTORA NVARCHAR(50) NULL;
    ALTER TABLE AULA ADD CONSTRAINT FK_AULA_TUTORA
        FOREIGN KEY (IDTUTORA) REFERENCES USUARIO(IDUSUARIO);
END
GO

IF NOT EXISTS (SELECT 1 FROM MODULO WHERE IDMODULO = 'MOD010')
BEGIN
    INSERT INTO MODULO (IDMODULO, NOMBRE, DESCRIPCION, ICONO, ORDEN, ACTIVO, FECHACREACION)
    VALUES ('MOD010', 'Informes', 'Reportes y estadísticas del instituto', 'faChartColumn', 9, 1, dbo.fn_fecha_ddmmyyyy());
END
ELSE
BEGIN
    UPDATE MODULO SET
        NOMBRE = 'Informes',
        DESCRIPCION = 'Reportes y estadísticas del instituto',
        ICONO = 'faChartColumn',
        ORDEN = 9,
        ACTIVO = 1
    WHERE IDMODULO = 'MOD010';
END
GO

IF NOT EXISTS (SELECT 1 FROM SUBMODULO WHERE IDSUBMODULO = 'SUB011')
BEGIN
    INSERT INTO SUBMODULO (IDSUBMODULO, NOMBRE, DESCRIPCION, ICONO, ORDEN, ACTIVO, IDMODULO)
    VALUES ('SUB011', 'Asistencias', 'Informe de asistencias por rango de fechas', 'faCalendarDays', 1, 1, 'MOD010');
END
ELSE
BEGIN
    UPDATE SUBMODULO SET
        NOMBRE = 'Asistencias',
        DESCRIPCION = 'Informe de asistencias por rango de fechas',
        ICONO = 'faCalendarDays',
        ORDEN = 1,
        ACTIVO = 1,
        IDMODULO = 'MOD010'
    WHERE IDSUBMODULO = 'SUB011';
END
GO

/* Permisos — administrador: CRUD completo */
IF NOT EXISTS (SELECT 1 FROM GRUPO_MODULO WHERE IDGRUPOMODULO = 'GRM055')
    INSERT INTO GRUPO_MODULO (IDGRUPOMODULO, IDTIPOUSUARIO, IDMODULO, IDTIPOPERMISO) VALUES
    ('GRM055', '3', 'MOD010', 'TP001'),
    ('GRM056', '3', 'MOD010', 'TP002'),
    ('GRM057', '3', 'MOD010', 'TP003'),
    ('GRM058', '3', 'MOD010', 'TP004');
GO

/* Docente: solo ver informes */
IF NOT EXISTS (SELECT 1 FROM GRUPO_MODULO WHERE IDGRUPOMODULO = 'GRM059')
    INSERT INTO GRUPO_MODULO (IDGRUPOMODULO, IDTIPOUSUARIO, IDMODULO, IDTIPOPERMISO) VALUES
    ('GRM059', '2', 'MOD010', 'TP001');
GO

PRINT 'Módulo Informes (MOD010) y submódulo Asistencias (SUB011) listos.';
GO
