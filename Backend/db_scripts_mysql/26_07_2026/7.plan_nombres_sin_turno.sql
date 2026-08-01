-- Convertido automáticamente desde db_scripts/26_07_2026/7.plan_nombres_sin_turno.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   Planes: quitar turno del nombre y asignarlo en PLAN.IDTURNO
   Ejecutar después de 6.plan_turno.sql
   Fecha: 26/07/2026
   ============================================================================ */

-- TODO MySQL: add column if missing on PLAN.IDTURNO
    RAISERROR('Ejecute primero 6.plan_turno.sql (columna PLAN.IDTURNO).', 16, 1);
    RETURN;

UPDATE `PLAN` SET NOMBRE = 'Plan Anual 1',                    IDTURNO = 'TUR001' WHERE IDPLAN = 'PLN001';
UPDATE `PLAN` SET NOMBRE = 'Plan Anual 2',                    IDTURNO = 'TUR002' WHERE IDPLAN = 'PLN002';
UPDATE `PLAN` SET NOMBRE = 'Plan Anual 3',                    IDTURNO = 'TUR001' WHERE IDPLAN = 'PLN003';
UPDATE `PLAN` SET NOMBRE = 'Plan Anual Virtual',              IDTURNO = 'TUR001' WHERE IDPLAN = 'PLN004';
UPDATE `PLAN` SET NOMBRE = 'Plan Escolar 1 (Interdiario)',    IDTURNO = 'TUR001' WHERE IDPLAN = 'PLN005';
UPDATE `PLAN` SET NOMBRE = 'Plan Escolar 2 (Interdiario)',    IDTURNO = 'TUR002' WHERE IDPLAN = 'PLN006';
UPDATE `PLAN` SET NOMBRE = 'Plan Sabatino 1',                 IDTURNO = 'TUR001' WHERE IDPLAN = 'PLN007';
UPDATE `PLAN` SET NOMBRE = 'Plan Beca 18',                    IDTURNO = 'TUR001' WHERE IDPLAN = 'PLN008';
UPDATE `PLAN` SET NOMBRE = 'Plan Semi-Anual',                 IDTURNO = 'TUR001' WHERE IDPLAN = 'PLN009';
UPDATE `PLAN` SET NOMBRE = 'Plan Semestral',                  IDTURNO = 'TUR001' WHERE IDPLAN = 'PLN010';
UPDATE `PLAN` SET NOMBRE = 'Plan Beca 18 - Sabatino',         IDTURNO = 'TUR001' WHERE IDPLAN = 'PLN011';

UPDATE m SET m.IDTURNO = p.IDTURNO
FROM MENSUALIDAD m
INNER JOIN `PLAN` p ON p.IDPLAN = m.IDPLAN
WHERE p.IDTURNO IS NOT NULL;

SELECT 'Nombres de plan sin turno entre paréntesis; IDTURNO actualizado.';