-- Convertido automáticamente desde db_scripts/26_07_2026/13.mantenedores_codigo_autogenerado.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   Códigos autogenerados en mantenedores (PLN, AUL, CAT, MAT, usuario=DNI)
   Ejecutar después de 12.plan_hora_entrada_tardanza.sql
   Fecha: 26/07/2026
   ============================================================================ */

DROP PROCEDURE IF EXISTS usp_plan_insertar;

DROP PROCEDURE IF EXISTS usp_plan_insertar;

DELIMITER $$

CREATE PROCEDURE usp_plan_insertar(
    IN p_Id VARCHAR(50),
    IN p_Nombre VARCHAR(100),
    IN p_Descripcion VARCHAR(255),
    IN p_CostoMensual DECIMAL(10,2),
    IN p_DiasAsistencia TINYINT,
    IN p_IdTurno VARCHAR(50),
    IN p_HoraEntrada TIME,
    IN p_TiempoExtra INT,
    IN p_Estado VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
IF p_Nombre IS NULL OR TRIM(p_Nombre) = '' THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa el nombre del plan.'; LEAVE main;     END IF;

    IF p_CostoMensual IS NOT NULL AND p_CostoMensual < 0 THEN
        SET p_Resultado = 0; SET p_Mensaje = 'El costo mensual no puede ser negativo.'; LEAVE main;     END IF;

    IF p_DiasAsistencia IS NULL OR p_DiasAsistencia = 0 THEN SET p_DiasAsistencia = 63; END IF;

    IF p_HoraEntrada IS NULL THEN SET p_HoraEntrada = CAST('08:00:00' AS TIME); END IF;

    IF p_TiempoExtra IS NULL OR p_TiempoExtra < 0 THEN SET p_TiempoExtra = 0; END IF;

    IF p_IdTurno IS NOT NULL AND p_IdTurno <> ''
       AND NOT EXISTS (SELECT 1 FROM TURNO WHERE IDTURNO = p_IdTurno)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'El turno seleccionado no es válido.'; LEAVE main; 
    END IF;

    IF p_Id IS NULL OR TRIM(p_Id) = '' THEN
SET p_Id = CONCAT('PLN', RIGHT(CONCAT('000', CAST(v_NextPln AS CHAR(10))), 3);
    
ELSE
        SET p_Id = UPPER(TRIM(p_Id);

    IF EXISTS (SELECT 1 FROM `PLAN` WHERE IDPLAN = p_Id) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'El código de plan ya existe.'; LEAVE main;     END IF;

    IF EXISTS (SELECT 1 FROM `PLAN` WHERE NOMBRE = p_Nombre) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ya existe un plan con ese nombre.'; LEAVE main;     END IF;
    INSERT INTO `PLAN` (IDPLAN, NOMBRE, DESCRIPCION, COSTOMENSUAL, DIASASISTENCIA, IDTURNO, HORAENTRADA, TIEMPOEXTRA, ACTIVO)
    VALUES (
        p_Id,
        p_Nombre,
        p_Descripcion,
        p_CostoMensual,
        p_DiasAsistencia,
        NULLIF(p_IdTurno, ''),
        p_HoraEntrada,
        p_TiempoExtra,
        CASE WHEN p_Estado = 'Activo' THEN 1 ELSE 0 END);

    SET p_Resultado = 1; SET p_Mensaje = 'Plan registrado.';
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_aula_insertar;

DROP PROCEDURE IF EXISTS usp_aula_insertar;

DELIMITER $$

CREATE PROCEDURE usp_aula_insertar(
    IN p_Id VARCHAR(50),
    IN p_Nombre VARCHAR(100),
    IN p_Descripcion LONGTEXT,
    IN p_Capacidad INT,
    IN p_EnlaceVirtual VARCHAR(255),
    IN p_EnlaceCuestionario VARCHAR(255),
    IN p_Estado VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
IF p_Nombre IS NULL OR TRIM(p_Nombre) = '' THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa el nombre del aula.'; LEAVE main;     END IF;

    IF p_Id IS NULL OR TRIM(p_Id) = '' THEN
SET p_Id = CONCAT('AUL', RIGHT(CONCAT('000', CAST(v_NextAul AS CHAR(10))), 3);
    
ELSE
        SET p_Id = UPPER(TRIM(p_Id);

    IF EXISTS (SELECT 1 FROM AULA WHERE IDAULA = p_Id) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'El código de aula ya existe.'; LEAVE main;     END IF;

    IF EXISTS (SELECT 1 FROM AULA WHERE NOMBRE = p_Nombre) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ya existe un aula con ese nombre.'; LEAVE main;     END IF;
    INSERT INTO AULA (IDAULA, NOMBRE, DESCRIPCION, CAPACIDAD, ACTIVO, ENLACEVIRTUAL, ENLACECUESTIONARIO)
    VALUES (
        p_Id,
        p_Nombre,
        p_Descripcion,
        p_Capacidad,
        CASE WHEN p_Estado = 'Activo' THEN 1 ELSE 0 END,
        p_EnlaceVirtual,
        p_EnlaceCuestionario
    );

    SET p_Resultado = 1; SET p_Mensaje = 'Aula registrada.';
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_categoria_insertar;

DROP PROCEDURE IF EXISTS usp_categoria_insertar;

DELIMITER $$

CREATE PROCEDURE usp_categoria_insertar(
    IN p_Nombre VARCHAR(100),
    IN p_Porcentaje DECIMAL(5,2),
    IN p_Orden INT,
    IN p_Estado VARCHAR(50),
    OUT p_IdGenerado VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
SET p_IdGenerado = NULL;

    IF p_Nombre IS NULL OR TRIM(p_Nombre) = '' THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa el nombre de la categoría.'; LEAVE main;     END IF;

    IF p_Porcentaje IS NOT NULL AND (p_Porcentaje < 0 OR p_Porcentaje > 100) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'El porcentaje debe estar entre 0 y 100.'; LEAVE main;     END IF;

    IF EXISTS (SELECT 1 FROM CATEGORIA WHERE NOMBRE = p_Nombre) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ya existe una categoría con ese nombre.'; LEAVE main;     END IF;
SELECT IFNULL(MAX(CAST(REPLACE(IDCATEGORIA, 'CAT', '') AS INT)), 0) + 1 INTO v_NextCat
    FROM CATEGORIA WHERE IDCATEGORIA LIKE 'CAT%';
    SET p_IdGenerado = CONCAT('CAT', RIGHT(CONCAT('000', CAST(v_NextCat AS CHAR(3))), 3);

    INSERT INTO CATEGORIA (IDCATEGORIA, NOMBRE, PORCENTAJE, ORDEN, ACTIVO)
    VALUES (
        p_IdGenerado,
        p_Nombre,
        p_Porcentaje,
        IFNULL(p_Orden, 0),
        CASE WHEN p_Estado = 'Activo' THEN 1 ELSE 0 END);

    SET p_Resultado = 1; SET p_Mensaje = 'Categoría registrada.';
    SELECT p_IdGenerado AS IdGenerado, p_Resultado AS Resultado, p_Mensaje AS Mensaje
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_materia_insertar;

DROP PROCEDURE IF EXISTS usp_materia_insertar;

DELIMITER $$

CREATE PROCEDURE usp_materia_insertar(
    IN p_Codigo VARCHAR(50),
    IN p_Nombre VARCHAR(150),
    IN p_IdCategoria VARCHAR(50),
    IN p_Estado VARCHAR(50),
    OUT p_IdGenerado VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
SET p_IdGenerado = NULL;

    IF p_Nombre IS NULL OR TRIM(p_Nombre) = '' THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa el nombre de la materia.'; LEAVE main;     END IF;

    IF EXISTS (SELECT 1 FROM MATERIA WHERE NOMBRE = p_Nombre) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ya existe una materia con ese nombre.'; LEAVE main;     END IF;

    IF p_IdCategoria IS NOT NULL AND TRIM(p_IdCategoria) <> ''
       AND NOT EXISTS (SELECT 1 FROM CATEGORIA WHERE IDCATEGORIA = p_IdCategoria)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'La categoría no existe.'; LEAVE main; 
    END IF;

    IF p_Codigo IS NOT NULL AND TRIM(p_Codigo) <> ''
       AND EXISTS (SELECT 1 FROM MATERIA WHERE CODIGO = p_Codigo)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'Ya existe una materia con ese código corto.'; LEAVE main; 
SELECT IFNULL(MAX(CAST(REPLACE(IDMATERIA, 'MAT', '') AS INT)), 0) + 1 INTO v_NextMat
    FROM MATERIA WHERE IDMATERIA LIKE 'MAT%';
    SET p_IdGenerado = CONCAT('MAT', RIGHT(CONCAT('000', CAST(v_NextMat AS CHAR(3))), 3);

    INSERT INTO MATERIA (IDMATERIA, CODIGO, NOMBRE, IDCATEGORIA, ACTIVO)
    VALUES (
        p_IdGenerado,
        NULLIF(TRIM(p_Codigo), ''),
        p_Nombre,
        NULLIF(TRIM(p_IdCategoria), ''),
        CASE WHEN p_Estado = 'Activo' THEN 1 ELSE 0 END);

    SET p_Resultado = 1; SET p_Mensaje = 'Materia registrada.';
    SELECT p_IdGenerado AS IdGenerado, p_Resultado AS Resultado, p_Mensaje AS Mensaje
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_usuario_insertar;

DROP PROCEDURE IF EXISTS usp_usuario_insertar;

DELIMITER $$

CREATE PROCEDURE usp_usuario_insertar(
    IN p_Id VARCHAR(50),
    IN p_Contra VARCHAR(255),
    IN p_Nombre VARCHAR(100),
    IN p_Apellido VARCHAR(100),
    IN p_Dni VARCHAR(20),
    IN p_Email VARCHAR(150),
    IN p_IdTipoUsuario VARCHAR(50),
    IN p_Estado VARCHAR(50),
    IN p_FechaNacimiento CHAR(8),
    IN p_Direccion VARCHAR(255),
    IN p_Distrito VARCHAR(100),
    IN p_Colegio VARCHAR(150),
    IN p_Grado VARCHAR(50),
    IN p_TelPersonal VARCHAR(20),
    IN p_TelApoderado VARCHAR(20),
    IN p_NombreApoderado VARCHAR(200),
    IN p_Parentesco VARCHAR(50),
    IN p_SituacionAcademica VARCHAR(100),
    IN p_ComoEntero VARCHAR(100),
    IN p_Foto LONGTEXT,
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
IF p_Dni IS NULL OR TRIM(p_Dni) = '' THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa el DNI.'; LEAVE main;     END IF;

    IF p_Id IS NULL OR TRIM(p_Id) = '' THEN SET p_Id = TRIM(p_Dni); END IF;

    IF p_Contra IS NULL OR TRIM(p_Contra) = '' THEN SET p_Contra = p_Id; END IF;

    IF EXISTS (SELECT 1 FROM USUARIO WHERE IDUSUARIO = p_Id) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'El usuario ya existe.'; LEAVE main;     END IF;

    IF EXISTS (SELECT 1 FROM USUARIO WHERE DNI = p_Dni) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'El DNI ya está registrado.'; LEAVE main;     END IF;

    IF EXISTS (SELECT 1 FROM USUARIO WHERE EMAIL = p_Email) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'El email ya está registrado.'; LEAVE main;     END IF;

    IF NOT EXISTS (SELECT 1 FROM TIPOUSUARIO WHERE IDTIPOUSUARIO = p_IdTipoUsuario) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Tipo de usuario no válido.'; LEAVE main;     END IF;
    INSERT INTO USUARIO (
        IDUSUARIO, CONTRA, NOMBRE, APELLIDO, DNI, EMAIL, IDTIPOUSUARIO, ESTADO,
        FECHANACIMIENTO, DIRECCION, DISTRITO, COLEGIO, GRADO,
        TELPERSONAL, TELAPODERADO, NOMBREAPODERADO, PARENTESCO,
        SITUACIONACADEMICA, COMOENTERO, FECHAACTIVO, FOTO
    ) VALUES (
        p_Id, p_Contra, p_Nombre, p_Apellido, p_Dni, p_Email, p_IdTipoUsuario, p_Estado,
        p_FechaNacimiento, p_Direccion, p_Distrito, p_Colegio, p_Grado,
        p_TelPersonal, p_TelApoderado, p_NombreApoderado, p_Parentesco,
        p_SituacionAcademica, p_ComoEntero, fn_fecha_ddmmyyyy(), p_Foto
    );

    SET p_Resultado = 1; SET p_Mensaje = 'Usuario creado.';
END$$

DELIMITER ;