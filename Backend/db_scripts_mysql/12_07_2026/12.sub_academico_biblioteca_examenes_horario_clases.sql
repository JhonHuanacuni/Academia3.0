-- Convertido automáticamente desde db_scripts/12_07_2026/12.sub_academico_biblioteca_examenes_horario_clases.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   Submódulos bajo Académico (MOD009):
   Biblioteca, Exámenes, Horario, Clases
   Desactiva MOD005 (Biblioteca) y MOD006 (Exámenes) como módulos sueltos
   Fecha: 12/07/2026
   ============================================================================ */

-- Biblioteca
IF NOT EXISTS (SELECT 1 FROM SUBMODULO WHERE IDSUBMODULO = 'SUB014')
BEGIN
    INSERT INTO SUBMODULO (IDSUBMODULO, NOMBRE, DESCRIPCION, ICONO, ORDEN, ACTIVO, IDMODULO)
    VALUES (
        'SUB014',
        'Biblioteca',
        'Recursos educativos y archivos de la biblioteca',
        'faBook',
        4,
        1,
        'MOD009'
    );
    SELECT 'SUB014 (Biblioteca) creado.';

ELSE
BEGIN
    UPDATE SUBMODULO SET
        NOMBRE = 'Biblioteca',
        DESCRIPCION = 'Recursos educativos y archivos de la biblioteca',
        ICONO = 'faBook',
        ORDEN = 4,
        ACTIVO = 1,
        IDMODULO = 'MOD009'
    WHERE IDSUBMODULO = 'SUB014';
    SELECT 'SUB014 (Biblioteca) actualizado.';

-- Exámenes
IF NOT EXISTS (SELECT 1 FROM SUBMODULO WHERE IDSUBMODULO = 'SUB015')
BEGIN
    INSERT INTO SUBMODULO (IDSUBMODULO, NOMBRE, DESCRIPCION, ICONO, ORDEN, ACTIVO, IDMODULO)
    VALUES (
        'SUB015',
        'Exámenes',
        'Gestión de exámenes, resultados y evaluaciones',
        'faFileLines',
        5,
        1,
        'MOD009'
    );
    SELECT 'SUB015 (Exámenes) creado.';

ELSE
BEGIN
    UPDATE SUBMODULO SET
        NOMBRE = 'Exámenes',
        DESCRIPCION = 'Gestión de exámenes, resultados y evaluaciones',
        ICONO = 'faFileLines',
        ORDEN = 5,
        ACTIVO = 1,
        IDMODULO = 'MOD009'
    WHERE IDSUBMODULO = 'SUB015';
    SELECT 'SUB015 (Exámenes) actualizado.';

-- Horario
IF NOT EXISTS (SELECT 1 FROM SUBMODULO WHERE IDSUBMODULO = 'SUB016')
BEGIN
    INSERT INTO SUBMODULO (IDSUBMODULO, NOMBRE, DESCRIPCION, ICONO, ORDEN, ACTIVO, IDMODULO)
    VALUES (
        'SUB016',
        'Horario',
        'Agenda y horarios de clases, salones y eventos',
        'faCalendarDays',
        6,
        1,
        'MOD009'
    );
    SELECT 'SUB016 (Horario) creado.';

ELSE
BEGIN
    UPDATE SUBMODULO SET
        NOMBRE = 'Horario',
        DESCRIPCION = 'Agenda y horarios de clases, salones y eventos',
        ICONO = 'faCalendarDays',
        ORDEN = 6,
        ACTIVO = 1,
        IDMODULO = 'MOD009'
    WHERE IDSUBMODULO = 'SUB016';
    SELECT 'SUB016 (Horario) actualizado.';

-- Clases
IF NOT EXISTS (SELECT 1 FROM SUBMODULO WHERE IDSUBMODULO = 'SUB017')
BEGIN
    INSERT INTO SUBMODULO (IDSUBMODULO, NOMBRE, DESCRIPCION, ICONO, ORDEN, ACTIVO, IDMODULO)
    VALUES (
        'SUB017',
        'Clases',
        'Registro y administración de clases',
        'faChalkboardTeacher',
        7,
        1,
        'MOD009'
    );
    SELECT 'SUB017 (Clases) creado.';

ELSE
BEGIN
    UPDATE SUBMODULO SET
        NOMBRE = 'Clases',
        DESCRIPCION = 'Registro y administración de clases',
        ICONO = 'faChalkboardTeacher',
        ORDEN = 7,
        ACTIVO = 1,
        IDMODULO = 'MOD009'
    WHERE IDSUBMODULO = 'SUB017';
    SELECT 'SUB017 (Clases) actualizado.';

-- Evitar duplicados en el menú: desactivar módulos sueltos Biblioteca y Exámenes
UPDATE MODULO SET ACTIVO = 0 WHERE IDMODULO IN ('MOD005', 'MOD006');
UPDATE SUBMODULO SET ACTIVO = 0 WHERE IDMODULO IN ('MOD005', 'MOD006');

SELECT 'Submódulos Académico: Biblioteca, Exámenes, Horario, Clases listos.';