-- ============================================================================
-- Triggers de auditoría (MySQL 8)
-- La instalación la hace Python: scripts/install_auditoria_triggers.py
-- (MySQL no permite PREPARE/EXECUTE para CREATE TRIGGER)
-- Prerequisito: 3.auditoria_tabla.sql, 4.usp_auditoria_crud.sql
-- ============================================================================

USE `AcademiaDB`;

DROP PROCEDURE IF EXISTS usp_auditoria_instalar_trigger;

SELECT 'Ejecutar install_auditoria_triggers desde setup_mysql_db / validate_mysql_scripts.' AS info;
