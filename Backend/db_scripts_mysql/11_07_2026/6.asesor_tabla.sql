-- ============================================================================
-- Tabla ASESOR + FK en MEMBRESIA — MySQL 8
-- ============================================================================

USE `AcademiaDB`;

CREATE TABLE IF NOT EXISTS ASESOR (
    IDASESOR    VARCHAR(50)   NOT NULL PRIMARY KEY,
    NOMBRE      VARCHAR(150)  NOT NULL,
    ACTIVO      TINYINT(1)    NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO ASESOR (IDASESOR, NOMBRE, ACTIVO) VALUES
('ASE001', 'Asesor 1', 1),
('ASE002', 'Asesor 2', 1),
('ASE003', 'Asesor 3', 1);

SET @col_mem_idasesor := (
    SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'MEMBRESIA' AND COLUMN_NAME = 'IDASESOR'
);
SET @sql_mem_idasesor := IF(@col_mem_idasesor = 0,
    'ALTER TABLE MEMBRESIA ADD IDASESOR VARCHAR(50) NULL',
    'SELECT 1'
);
PREPARE stmt FROM @sql_mem_idasesor; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @fk_mem_asesor := (
    SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_SCHEMA = DATABASE() AND CONSTRAINT_NAME = 'FK_MEMBRESIA_ASESOR'
);
SET @sql_mem_asesor := IF(@fk_mem_asesor = 0,
    'ALTER TABLE MEMBRESIA ADD CONSTRAINT FK_MEMBRESIA_ASESOR FOREIGN KEY (IDASESOR) REFERENCES ASESOR(IDASESOR)',
    'SELECT 1'
);
PREPARE stmt FROM @sql_mem_asesor; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SELECT 'Tabla ASESOR y FK MEMBRESIA listos.' AS info;