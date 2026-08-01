-- Convertido automáticamente desde db_scripts/16_07_2026/1.concepto_pago_extra_tabla.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   CONCEPTOPAGOEXTRA — catálogo de conceptos (CONCAT(nombre, costo))
   Fecha: 16/07/2026
   ============================================================================ */

-- create if missing CONCEPTOPAGOEXTRA
    CREATE TABLE IF NOT EXISTS CONCEPTOPAGOEXTRA (
        IDCONCEPTO VARCHAR(50)  NOT NULL PRIMARY KEY,
        NOMBRE     VARCHAR(150) NOT NULL,
        COSTO      DECIMAL(10,2) NOT NULL DEFAULT 0,
        FECHAINICIO CHAR(8)      NULL,
        FECHAFIN    CHAR(8)      NULL,
        ACTIVO     TINYINT(1)           NOT NULL DEFAULT 1
    );
    SELECT 'Tabla CONCEPTOPAGOEXTRA creada.';