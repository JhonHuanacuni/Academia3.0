-- ============================================================================
-- Tabla central AUDITORIA + secuencia (MySQL 8)
-- Fecha: 31/07/2026
-- Prerequisito: 2.auditoria_columnas_tablas.sql
-- ============================================================================

USE `AcademiaDB`;

CREATE TABLE IF NOT EXISTS AUDITORIA (
    IDAUDITORIA     VARCHAR(50)  NOT NULL PRIMARY KEY,
    TABLA           VARCHAR(100) NOT NULL,
    IDREGISTRO      VARCHAR(50)  NOT NULL,
    ACCION          VARCHAR(20)  NOT NULL,
    IDUSUARIO       VARCHAR(50)  NULL,
    FECHA           CHAR(8)      NOT NULL,
    HORA            CHAR(8)      NOT NULL,
    DATOS_ANTES     LONGTEXT     NULL,
    DATOS_DESPUES   LONGTEXT     NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX IX_AUDITORIA_TABLA_FECHA ON AUDITORIA (TABLA, FECHA, HORA);
CREATE INDEX IX_AUDITORIA_USUARIO ON AUDITORIA (IDUSUARIO, FECHA);
CREATE INDEX IX_AUDITORIA_REGISTRO ON AUDITORIA (TABLA, IDREGISTRO);

DROP PROCEDURE IF EXISTS usp_auditoria_siguiente_id;

DELIMITER $$

CREATE PROCEDURE usp_auditoria_siguiente_id(OUT p_Id VARCHAR(50))
main: BEGIN
    DECLARE v_Num INT DEFAULT 1;
    SELECT IFNULL(MAX(CAST(SUBSTRING(IDAUDITORIA, 4, 10) AS UNSIGNED)), 0) + 1
    INTO v_Num
    FROM AUDITORIA
    WHERE IDAUDITORIA LIKE 'AUD%';
    SET p_Id = CONCAT('AUD', LPAD(v_Num, 6, '0'));
END$$

DELIMITER ;

SELECT 'Tabla AUDITORIA y usp_auditoria_siguiente_id listos.' AS info;
