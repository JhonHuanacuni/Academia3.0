-- Email opcional en USUARIO: NULL permitido; no duplicar si viene vacío.
-- Fecha: 24/08/2026

USE `AcademiaDB`;

ALTER TABLE USUARIO
    MODIFY EMAIL VARCHAR(150) NULL;

UPDATE USUARIO
SET EMAIL = NULL
WHERE TRIM(IFNULL(EMAIL, '')) = '';

DROP PROCEDURE IF EXISTS usp_usuario_insertar;

DELIMITER $$

CREATE PROCEDURE usp_usuario_insertar(
    INOUT p_Id VARCHAR(50),
    INOUT p_Contra VARCHAR(255),
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
    DECLARE v_EstEx VARCHAR(50);
    DECLARE v_Email VARCHAR(150);

    SET v_Email = NULLIF(TRIM(IFNULL(p_Email, '')), '');

    IF p_Dni IS NULL OR TRIM(p_Dni) = '' THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa el DNI.';
        LEAVE main;
    END IF;

    IF p_Id IS NULL OR TRIM(p_Id) = '' THEN
        SET p_Id = TRIM(p_Dni);
    END IF;

    IF p_Contra IS NULL OR TRIM(p_Contra) = '' THEN
        SET p_Contra = p_Id;
    END IF;

    IF EXISTS (SELECT 1 FROM USUARIO WHERE IDUSUARIO = p_Id) THEN
        SELECT ESTADO INTO v_EstEx FROM USUARIO WHERE IDUSUARIO = p_Id;
        SET p_Resultado = 0;
        SET p_Mensaje = CASE
            WHEN v_EstEx = 'Retirado'
                THEN 'Ese usuario ya existe como Retirado. En el listado usa el filtro Retirado o Todos para verlo, reactívalo o elimínalo.'
            ELSE 'El usuario ya existe.'
        END;
        LEAVE main;
    END IF;

    IF EXISTS (SELECT 1 FROM USUARIO WHERE DNI = p_Dni) THEN
        SELECT ESTADO INTO v_EstEx FROM USUARIO WHERE DNI = p_Dni;
        SET p_Resultado = 0;
        SET p_Mensaje = CASE
            WHEN v_EstEx = 'Retirado'
                THEN 'Ese DNI ya está registrado (Retirado). En el listado usa el filtro Retirado o Todos para verlo, reactívalo o elimínalo.'
            ELSE 'El DNI ya está registrado.'
        END;
        LEAVE main;
    END IF;

    IF v_Email IS NOT NULL AND EXISTS (SELECT 1 FROM USUARIO WHERE EMAIL = v_Email) THEN
        SELECT ESTADO INTO v_EstEx FROM USUARIO WHERE EMAIL = v_Email;
        SET p_Resultado = 0;
        SET p_Mensaje = CASE
            WHEN v_EstEx = 'Retirado'
                THEN 'Ese email ya está registrado (Retirado). En el listado usa el filtro Retirado o Todos.'
            ELSE 'El email ya está registrado.'
        END;
        LEAVE main;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM TIPOUSUARIO WHERE IDTIPOUSUARIO = p_IdTipoUsuario) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Tipo de usuario no válido.';
        LEAVE main;
    END IF;

    INSERT INTO USUARIO (
        IDUSUARIO, CONTRA, NOMBRE, APELLIDO, DNI, EMAIL, IDTIPOUSUARIO, ESTADO,
        FECHANACIMIENTO, DIRECCION, DISTRITO, COLEGIO, GRADO,
        TELPERSONAL, TELAPODERADO, NOMBREAPODERADO, PARENTESCO,
        SITUACIONACADEMICA, COMOENTERO, FECHAACTIVO, FOTO
    ) VALUES (
        p_Id, p_Contra, p_Nombre, p_Apellido, p_Dni, v_Email, p_IdTipoUsuario, p_Estado,
        p_FechaNacimiento, p_Direccion, p_Distrito, p_Colegio, p_Grado,
        p_TelPersonal, p_TelApoderado, p_NombreApoderado, p_Parentesco,
        p_SituacionAcademica, p_ComoEntero, fn_fecha_ddmmyyyy(), p_Foto
    );

    SET p_Resultado = 1;
    SET p_Mensaje = 'Usuario creado.';
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_usuario_actualizar;

DELIMITER $$

CREATE PROCEDURE usp_usuario_actualizar(
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
    IN p_ActualizarFoto TINYINT(1),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
    DECLARE v_Email VARCHAR(150);
    SET v_Email = NULLIF(TRIM(IFNULL(p_Email, '')), '');

    IF NOT EXISTS (SELECT 1 FROM USUARIO WHERE IDUSUARIO = p_Id) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'El usuario no existe.'; LEAVE main;
    END IF;
    IF EXISTS (SELECT 1 FROM USUARIO WHERE DNI = p_Dni AND IDUSUARIO <> p_Id) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'El DNI ya está registrado.'; LEAVE main;
    END IF;
    IF v_Email IS NOT NULL AND EXISTS (SELECT 1 FROM USUARIO WHERE EMAIL = v_Email AND IDUSUARIO <> p_Id) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'El email ya está registrado.'; LEAVE main;
    END IF;

    UPDATE USUARIO SET
        NOMBRE = p_Nombre, APELLIDO = p_Apellido, DNI = p_Dni, EMAIL = v_Email,
        IDTIPOUSUARIO = p_IdTipoUsuario, ESTADO = p_Estado,
        FECHANACIMIENTO = p_FechaNacimiento, DIRECCION = p_Direccion,
        DISTRITO = p_Distrito, COLEGIO = p_Colegio, GRADO = p_Grado,
        TELPERSONAL = p_TelPersonal, TELAPODERADO = p_TelApoderado,
        NOMBREAPODERADO = p_NombreApoderado, PARENTESCO = p_Parentesco,
        SITUACIONACADEMICA = p_SituacionAcademica, COMOENTERO = p_ComoEntero,
        CONTRA = CASE WHEN p_Contra IS NOT NULL AND p_Contra <> '' THEN p_Contra ELSE CONTRA END,
        FOTO = CASE WHEN p_ActualizarFoto = 1 THEN p_Foto ELSE FOTO END
    WHERE IDUSUARIO = p_Id;

    SET p_Resultado = 1; SET p_Mensaje = 'Usuario actualizado.';
END$$

DELIMITER ;

SELECT 'USUARIO.EMAIL opcional (NULL) y SPs insertar/actualizar actualizados.' AS info;
