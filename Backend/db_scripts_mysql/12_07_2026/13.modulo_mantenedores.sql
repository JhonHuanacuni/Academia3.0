-- Convertido automáticamente desde db_scripts/12_07_2026/13.modulo_mantenedores.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   Módulo Mantenedores (MOD011)
   Mueve Aulas, Asesores y Planes desde Académico
   Nombres cortos: Aulas, Asesores, Planes
   Fecha: 12/07/2026
   ============================================================================ */

IF NOT EXISTS (SELECT 1 FROM MODULO WHERE IDMODULO = 'MOD011')
BEGIN
    INSERT INTO MODULO (IDMODULO, NOMBRE, DESCRIPCION, ICONO, ORDEN, ACTIVO, FECHACREACION)
    VALUES (
        'MOD011',
        'Mantenedores',
        'Catálogos y mantenedores del sistema',
        'faDatabase',
        8,
        1,
        fn_fecha_ddmmyyyy()
    );
    SELECT 'MOD011 (Mantenedores) creado.';

ELSE
BEGIN
    UPDATE MODULO SET
        NOMBRE = 'Mantenedores',
        DESCRIPCION = 'Catálogos y mantenedores del sistema',
        ICONO = 'faDatabase',
        ORDEN = 8,
        ACTIVO = 1
    WHERE IDMODULO = 'MOD011';
    SELECT 'MOD011 (Mantenedores) actualizado.';

-- Reordenar Académico e Informes si hace falta
UPDATE MODULO SET ORDEN = 7 WHERE IDMODULO = 'MOD009';
UPDATE MODULO SET ORDEN = 9 WHERE IDMODULO = 'MOD010';

-- Aulas
IF NOT EXISTS (SELECT 1 FROM SUBMODULO WHERE IDSUBMODULO = 'SUB010')
BEGIN
    INSERT INTO SUBMODULO (IDSUBMODULO, NOMBRE, DESCRIPCION, ICONO, ORDEN, ACTIVO, IDMODULO)
    VALUES ('SUB010', 'Aulas', 'Registrar y administrar aulas / salones', 'faChalkboard', 1, 1, 'MOD011');

ELSE
BEGIN
    UPDATE SUBMODULO SET
        NOMBRE = 'Aulas',
        DESCRIPCION = 'Registrar y administrar aulas / salones',
        ICONO = 'faChalkboard',
        ORDEN = 1,
        ACTIVO = 1,
        IDMODULO = 'MOD011'
    WHERE IDSUBMODULO = 'SUB010';

-- Asesores
IF NOT EXISTS (SELECT 1 FROM SUBMODULO WHERE IDSUBMODULO = 'SUB012')
BEGIN
    INSERT INTO SUBMODULO (IDSUBMODULO, NOMBRE, DESCRIPCION, ICONO, ORDEN, ACTIVO, IDMODULO)
    VALUES ('SUB012', 'Asesores', 'Registrar y administrar asesores', 'faIdCard', 2, 1, 'MOD011');

ELSE
BEGIN
    UPDATE SUBMODULO SET
        NOMBRE = 'Asesores',
        DESCRIPCION = 'Registrar y administrar asesores',
        ICONO = 'faIdCard',
        ORDEN = 2,
        ACTIVO = 1,
        IDMODULO = 'MOD011'
    WHERE IDSUBMODULO = 'SUB012';

-- Planes
IF NOT EXISTS (SELECT 1 FROM SUBMODULO WHERE IDSUBMODULO = 'SUB013')
BEGIN
    INSERT INTO SUBMODULO (IDSUBMODULO, NOMBRE, DESCRIPCION, ICONO, ORDEN, ACTIVO, IDMODULO)
    VALUES ('SUB013', 'Planes', 'Registrar y administrar tipos de plan', 'faLayerGroup', 3, 1, 'MOD011');

ELSE
BEGIN
    UPDATE SUBMODULO SET
        NOMBRE = 'Planes',
        DESCRIPCION = 'Registrar y administrar tipos de plan',
        ICONO = 'faLayerGroup',
        ORDEN = 3,
        ACTIVO = 1,
        IDMODULO = 'MOD011'
    WHERE IDSUBMODULO = 'SUB013';

-- Reordenar submódulos que quedan en Académico
UPDATE SUBMODULO SET ORDEN = 1 WHERE IDSUBMODULO = 'SUB014'; -- Biblioteca
UPDATE SUBMODULO SET ORDEN = 2 WHERE IDSUBMODULO = 'SUB015'; -- Exámenes
UPDATE SUBMODULO SET ORDEN = 3 WHERE IDSUBMODULO = 'SUB016'; -- Horario
UPDATE SUBMODULO SET ORDEN = 4 WHERE IDSUBMODULO = 'SUB017'; -- Clases

-- Permisos admin (tipo 3) sobre Mantenedores
IF NOT EXISTS (SELECT 1 FROM GRUPO_MODULO WHERE IDTIPOUSUARIO = '3' AND IDMODULO = 'MOD011' AND IDTIPOPERMISO = 'TP001')
BEGIN
    INSERT INTO GRUPO_MODULO (IDGRUPOMODULO, IDTIPOUSUARIO, IDMODULO, IDTIPOPERMISO)
    VALUES
        ('GRM060', '3', 'MOD011', 'TP001'),
        ('GRM061', '3', 'MOD011', 'TP002'),
        ('GRM062', '3', 'MOD011', 'TP003'),
        ('GRM063', '3', 'MOD011', 'TP004');

-- Permisos docente (tipo 2) lectura/escritura básica
IF NOT EXISTS (SELECT 1 FROM GRUPO_MODULO WHERE IDTIPOUSUARIO = '2' AND IDMODULO = 'MOD011' AND IDTIPOPERMISO = 'TP001')
BEGIN
    INSERT INTO GRUPO_MODULO (IDGRUPOMODULO, IDTIPOUSUARIO, IDMODULO, IDTIPOPERMISO)
    VALUES
        ('GRM064', '2', 'MOD011', 'TP001'),
        ('GRM065', '2', 'MOD011', 'TP002');

SELECT 'Módulo Mantenedores (MOD011) con Aulas, Asesores y Planes listo.';
