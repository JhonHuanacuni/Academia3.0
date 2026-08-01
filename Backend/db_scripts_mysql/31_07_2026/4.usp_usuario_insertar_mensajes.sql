-- Convertido automáticamente desde db_scripts/31_07_2026/4.usp_usuario_insertar_mensajes.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   usp_usuario_insertar: mensajes claros si el usuario/DNI existe (p. ej. Retirado)
   Ejecutar después de 3.usp_usuario_eliminar_fisica.sql
   Fecha: 31/07/2026
   ============================================================================ */

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
        SELECT ESTADO FROM USUARIO WHERE IDUSUARIO = p_Id INTO v_EstEx;
        SET p_Resultado = 0;
        SET p_Mensaje = CASE
            WHEN v_EstEx = 'Retirado'
                THEN 'Ese usuario ya existe como Retirado. En el listado usa el filtro Retirado o Todos para verlo, reactívalo o elimínalo.'
            ELSE 'El usuario ya existe.'
        END;
        LEAVE main;
    
    END IF;

    IF EXISTS (SELECT 1 FROM USUARIO WHERE DNI = p_Dni) THEN
        SELECT ESTADO FROM USUARIO WHERE DNI = p_Dni INTO v_EstEx;
        SET p_Resultado = 0;
        SET p_Mensaje = CASE
            WHEN v_EstEx = 'Retirado'
                THEN 'Ese DNI ya está registrado (Retirado). En el listado usa el filtro Retirado o Todos para verlo, reactívalo o elimínalo.'
            ELSE 'El DNI ya está registrado.'
        END;
        LEAVE main;
    
    END IF;

    IF EXISTS (SELECT 1 FROM USUARIO WHERE EMAIL = p_Email) THEN
        SELECT ESTADO FROM USUARIO WHERE EMAIL = p_Email INTO v_EstEx;
        SET p_Resultado = 0;
        SET p_Mensaje = CASE
            WHEN v_EstEx = 'Retirado'
                THEN 'Ese email ya está registrado (Retirado). En el listado usa el filtro Retirado o Todos.'
            ELSE 'El email ya está registrado.'
        END;
        LEAVE main;
    
    END IF;

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

    SET p_Resultado = 1;
    SET p_Mensaje = 'Usuario creado.';
END$$

DELIMITER ;