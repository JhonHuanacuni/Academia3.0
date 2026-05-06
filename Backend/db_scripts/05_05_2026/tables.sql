-- Nombre: Jhon 
-- Fecha: 2024-06-20
-- Descripción: CREACIÓN DE TABLA CLIENTES - TIPO CLIENTES

CREATE TABLE TIPOUSUARIO (
    idTipoUsuario   NVARCHAR(50)    PRIMARY KEY,
    descripcion     NVARCHAR(255)
);
GO

CREATE TABLE USUARIO (
    idUsuario           NVARCHAR(50)    PRIMARY KEY,
    contra              NVARCHAR(255),
    nombre              NVARCHAR(100),
    apellido            NVARCHAR(100),
    dni                 NVARCHAR(20),
    fechaNacimiento     NVARCHAR(20),
    direccion           NVARCHAR(255),
    estado              NVARCHAR(50),
    distrito            NVARCHAR(100),
    colegio             NVARCHAR(150),
    grado               NVARCHAR(50),
    fechaActivo         NVARCHAR(20),
    email               NVARCHAR(150),
    telPersonal         NVARCHAR(20),
    telApoderado        NVARCHAR(20),
    situacionAcademica  NVARCHAR(100),
    idTipoUsuario       NVARCHAR(50)    FOREIGN KEY REFERENCES TIPOUSUARIO(idTipoUsuario)
);
GO