-- ========================================
-- Crear base de datos AcademiaDB (MySQL 8)
-- Ejecutar PRIMERO, antes de cualquier carpeta de scripts.
-- ========================================

CREATE DATABASE IF NOT EXISTS `AcademiaDB`
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE `AcademiaDB`;

SELECT 'Base de datos AcademiaDB lista.' AS info;
