-- Convertido automáticamente desde db_scripts/16_07_2026/5.sub_pagos_extraordinarios_conceptos.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   Submódulos: Pagos extraordinarios (MOD004) + Conceptos (MOD011)
   Fecha: 16/07/2026
   Nota: asigna permisos desde Admin de módulos si no aparecen en el menú.
   ============================================================================ */

-- Pagos extraordinarios bajo Membresías
IF NOT EXISTS (SELECT 1 FROM SUBMODULO WHERE IDSUBMODULO = 'SUB018')
BEGIN
    INSERT INTO SUBMODULO (IDSUBMODULO, NOMBRE, DESCRIPCION, ICONO, ORDEN, ACTIVO, IDMODULO)
    VALUES (
        'SUB018',
        'Pagos extraordinarios',
        'Pagos no ligados a membresía (conceptos especiales)',
        'faMoneyBillWave',
        3,
        1,
        'MOD004'
    );
    SELECT 'SUB018 (Pagos extraordinarios) creado.';

ELSE
BEGIN
    UPDATE SUBMODULO SET
        NOMBRE = 'Pagos extraordinarios',
        DESCRIPCION = 'Pagos no ligados a membresía (conceptos especiales)',
        ICONO = 'faMoneyBillWave',
        ORDEN = 3,
        ACTIVO = 1,
        IDMODULO = 'MOD004'
    WHERE IDSUBMODULO = 'SUB018';
    SELECT 'SUB018 (Pagos extraordinarios) actualizado.';

-- Conceptos bajo Mantenedores
IF NOT EXISTS (SELECT 1 FROM SUBMODULO WHERE IDSUBMODULO = 'SUB019')
BEGIN
    INSERT INTO SUBMODULO (IDSUBMODULO, NOMBRE, DESCRIPCION, ICONO, ORDEN, ACTIVO, IDMODULO)
    VALUES (
        'SUB019',
        'Conceptos',
        'Conceptos de pago extraordinario (nombre y costo)',
        'faTags',
        4,
        1,
        'MOD011'
    );
    SELECT 'SUB019 (Conceptos) creado.';

ELSE
BEGIN
    UPDATE SUBMODULO SET
        NOMBRE = 'Conceptos',
        DESCRIPCION = 'Conceptos de pago extraordinario (nombre y costo)',
        ICONO = 'faTags',
        ORDEN = 4,
        ACTIVO = 1,
        IDMODULO = 'MOD011'
    WHERE IDSUBMODULO = 'SUB019';
    SELECT 'SUB019 (Conceptos) actualizado.';

SELECT 'Submódulos SUB018 y SUB019 listos.';