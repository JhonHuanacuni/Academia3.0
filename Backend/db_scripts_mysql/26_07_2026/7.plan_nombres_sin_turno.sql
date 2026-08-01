-- ============================================================================
-- Planes: quitar turno del nombre y asignarlo en PLAN.IDTURNO — MySQL 8
-- Ejecutar después de 6.plan_turno.sql
-- Fecha: 26/07/2026
-- ============================================================================

USE `AcademiaDB`;

UPDATE `PLAN` SET NOMBRE = 'Plan Anual 1',                 IDTURNO = 'TUR001' WHERE IDPLAN = 'PLN001';
UPDATE `PLAN` SET NOMBRE = 'Plan Anual 2',                 IDTURNO = 'TUR002' WHERE IDPLAN = 'PLN002';
UPDATE `PLAN` SET NOMBRE = 'Plan Anual 3',                 IDTURNO = 'TUR001' WHERE IDPLAN = 'PLN003';
UPDATE `PLAN` SET NOMBRE = 'Plan Anual Virtual',           IDTURNO = 'TUR001' WHERE IDPLAN = 'PLN004';
UPDATE `PLAN` SET NOMBRE = 'Plan Escolar 1 (Interdiario)', IDTURNO = 'TUR001' WHERE IDPLAN = 'PLN005';
UPDATE `PLAN` SET NOMBRE = 'Plan Escolar 2 (Interdiario)', IDTURNO = 'TUR002' WHERE IDPLAN = 'PLN006';
UPDATE `PLAN` SET NOMBRE = 'Plan Sabatino 1',              IDTURNO = 'TUR001' WHERE IDPLAN = 'PLN007';
UPDATE `PLAN` SET NOMBRE = 'Plan Beca 18',                 IDTURNO = 'TUR001' WHERE IDPLAN = 'PLN008';
UPDATE `PLAN` SET NOMBRE = 'Plan Semi-Anual',              IDTURNO = 'TUR001' WHERE IDPLAN = 'PLN009';
UPDATE `PLAN` SET NOMBRE = 'Plan Semestral',               IDTURNO = 'TUR001' WHERE IDPLAN = 'PLN010';
UPDATE `PLAN` SET NOMBRE = 'Plan Beca 18 - Sabatino',      IDTURNO = 'TUR001' WHERE IDPLAN = 'PLN011';

UPDATE MENSUALIDAD m
INNER JOIN `PLAN` p ON p.IDPLAN = m.IDPLAN
SET m.IDTURNO = p.IDTURNO
WHERE p.IDTURNO IS NOT NULL;
