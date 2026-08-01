-- Convertido automáticamente desde db_scripts/05_05_2026/data.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

INSERT INTO TIPOUSUARIO (idTipoUsuario, descripcion) VALUES
('1', 'Estudiante'),
('2', 'Trabajador'),
('3', 'Docente');

INSERT INTO USUARIO (idUsuario, contra, nombre, apellido, dni, fechaNacimiento, direccion, estado, distrito, colegio, grado, fechaActivo, email, telPersonal, telApoderado, situacionAcademica, idTipoUsuario) VALUES
('1', '1234', 'Carlos', 'Ramirez', '12345678', '15032000', 'Av. Lima 123', 'Activo', 'Miraflores', 'Colegio San Jose', '5to', '01012024', 'carlos@gmail.com', '987654321', '912345678', 'Regular', '1'),
('2', '1234', 'Maria', 'Lopez', '87654321', '20071990', 'Jr. Cusco 456', 'Activo', 'San Isidro', NULL, NULL, '01012024', 'maria@gmail.com', '998877665', NULL, NULL, '2'),
('3', '1234', 'Pedro', 'Torres', '11223344', '10111985', 'Calle Arequipa 789', 'Activo', 'Surco', NULL, NULL, '01012024', 'pedro@gmail.com', '977665544', NULL, NULL, '3');
