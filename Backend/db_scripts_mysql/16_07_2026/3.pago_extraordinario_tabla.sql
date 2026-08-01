-- Convertido automáticamente desde db_scripts/16_07_2026/3.pago_extraordinario_tabla.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   PAGOEXTRAORDINARIO — pagos no ligados a membresía
   Prerequisito: 1.concepto_pago_extra_tabla.sql
   Fecha: 16/07/2026
   ============================================================================ */

-- create if missing PAGOEXTRAORDINARIO
    CREATE TABLE IF NOT EXISTS PAGOEXTRAORDINARIO (
        IDPAGOEXTRA    VARCHAR(50)  NOT NULL PRIMARY KEY,
        IDUSUARIO VARCHAR(50) NOT NULL,
    FOREIGN KEY (IDUSUARIO) REFERENCES USUARIO(IDUSUARIO),
        IDCONCEPTO VARCHAR(50) NOT NULL,
    FOREIGN KEY (IDCONCEPTO) REFERENCES CONCEPTOPAGOEXTRA(IDCONCEPTO),
        MONTO          DECIMAL(10,2) NOT NULL,
        FECHAPAGO      CHAR(8)       NULL,
        FECHAINICIO    CHAR(8)       NULL,
        FECHAFIN       CHAR(8)       NULL,
        OBSERVACIONES  LONGTEXT NULL,
        IDREGISTRADOR VARCHAR(50) NULL,
    FOREIGN KEY (IDREGISTRADOR) REFERENCES USUARIO(IDUSUARIO)
    );
    CREATE INDEX IX_PAGOEXTRA_USUARIO ON PAGOEXTRAORDINARIO(IDUSUARIO);
    CREATE INDEX IX_PAGOEXTRA_CONCEPTO ON PAGOEXTRAORDINARIO(IDCONCEPTO);
    CREATE INDEX IX_PAGOEXTRA_FECHA ON PAGOEXTRAORDINARIO(FECHAPAGO);
    SELECT 'Tabla PAGOEXTRAORDINARIO creada.';