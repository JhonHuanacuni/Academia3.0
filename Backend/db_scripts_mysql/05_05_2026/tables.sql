-- Convertido automáticamente desde db_scripts/05_05_2026/tables.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

-- Nombre: Jhon 
-- Fecha: 2024-06-20
-- Descripción: CREACIÓN DE TABLA CLIENTES - TIPO CLIENTES

CREATE TABLE IF NOT EXISTS TIPOUSUARIO (
    idTipoUsuario   VARCHAR(50)    PRIMARY KEY,
    descripcion     VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS USUARIO (
    idUsuario           VARCHAR(50)    PRIMARY KEY,
    contra              VARCHAR(255),
    nombre              VARCHAR(100),
    apellido            VARCHAR(100),
    dni                 VARCHAR(20),
    fechaNacimiento     VARCHAR(20),
    direccion           VARCHAR(255),
    estado              VARCHAR(50),
    distrito            VARCHAR(100),
    colegio             VARCHAR(150),
    grado               VARCHAR(50),
    fechaActivo         VARCHAR(20),
    email               VARCHAR(150),
    telPersonal         VARCHAR(20),
    telApoderado        VARCHAR(20),
    situacionAcademica  VARCHAR(100),
    idTipoUsuario       VARCHAR(50)    FOREIGN KEY REFERENCES TIPOUSUARIO(idTipoUsuario)
);
