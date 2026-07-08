/* ============================================================================
   Módulo Académico (MOD009) + submódulo Mantenedor de Aulas (SUB010)
   Ejecutar después de modulos_admin.sql (carpeta 22_06_2026)
   Fecha: 29/06/2026
   ============================================================================ */

IF NOT EXISTS (SELECT 1 FROM MODULO WHERE IDMODULO = 'MOD009')
BEGIN
    INSERT INTO MODULO (IDMODULO, NOMBRE, DESCRIPCION, ICONO, ORDEN, ACTIVO, FECHACREACION)
    VALUES ('MOD009', 'Académico', 'Gestión académica: aulas, horarios y turnos', 'faGraduationCap', 8, 1, dbo.fn_fecha_ddmmyyyy());
END
ELSE
BEGIN
    UPDATE MODULO SET
        NOMBRE = 'Académico',
        DESCRIPCION = 'Gestión académica: aulas, horarios y turnos',
        ICONO = 'faGraduationCap',
        ORDEN = 8,
        ACTIVO = 1
    WHERE IDMODULO = 'MOD009';
END
GO

IF NOT EXISTS (SELECT 1 FROM SUBMODULO WHERE IDSUBMODULO = 'SUB010')
BEGIN
    INSERT INTO SUBMODULO (IDSUBMODULO, NOMBRE, DESCRIPCION, ICONO, ORDEN, ACTIVO, IDMODULO)
    VALUES ('SUB010', 'Mantenedor de aulas', 'Registrar y administrar aulas / salones', 'faChalkboard', 1, 1, 'MOD009');
END
ELSE
BEGIN
    UPDATE SUBMODULO SET
        NOMBRE = 'Mantenedor de aulas',
        DESCRIPCION = 'Registrar y administrar aulas / salones',
        ICONO = 'faChalkboard',
        ORDEN = 1,
        ACTIVO = 1,
        IDMODULO = 'MOD009'
    WHERE IDSUBMODULO = 'SUB010';
END
GO

/* Permisos por rol — administrador: CRUD completo */
IF NOT EXISTS (SELECT 1 FROM GRUPO_MODULO WHERE IDGRUPOMODULO = 'GRM048')
    INSERT INTO GRUPO_MODULO (IDGRUPOMODULO, IDTIPOUSUARIO, IDMODULO, IDTIPOPERMISO) VALUES
    ('GRM048', '3', 'MOD009', 'TP001'),
    ('GRM049', '3', 'MOD009', 'TP002'),
    ('GRM050', '3', 'MOD009', 'TP003'),
    ('GRM051', '3', 'MOD009', 'TP004');
GO

/* Docente: ver, crear y editar aulas */
IF NOT EXISTS (SELECT 1 FROM GRUPO_MODULO WHERE IDGRUPOMODULO = 'GRM052')
    INSERT INTO GRUPO_MODULO (IDGRUPOMODULO, IDTIPOUSUARIO, IDMODULO, IDTIPOPERMISO) VALUES
    ('GRM052', '2', 'MOD009', 'TP001'),
    ('GRM053', '2', 'MOD009', 'TP002'),
    ('GRM054', '2', 'MOD009', 'TP003');
GO

/* Datos de ejemplo (salones como Intranet_Vita) */
IF NOT EXISTS (SELECT 1 FROM AULA)
BEGIN
    INSERT INTO AULA (IDAULA, NOMBRE, DESCRIPCION, CAPACIDAD, ACTIVO, ENLACEVIRTUAL, ENLACECUESTIONARIO) VALUES
    ('AUL001', 'Salón A', 'Aula principal — nivel inicial', 25, 1, NULL, NULL),
    ('AUL002', 'Salón B', 'Aula intermedio', 20, 1, NULL, NULL),
    ('AUL003', 'Salón C', 'Aula avanzado', 18, 1, NULL, NULL);
END
GO

PRINT 'Módulo Académico (MOD009) y submódulo Aulas (SUB010) listos.';
GO
