-- ============================================================================
-- SPs usuario: soporte columna FOTO (Base64) — MySQL 8
-- Ejecutar después de 4.usuario_columna_foto.sql
-- ============================================================================

USE `AcademiaDB`;

DROP PROCEDURE IF EXISTS usp_usuario_obtener;

DELIMITER $$

CREATE PROCEDURE usp_usuario_obtener(IN p_Id VARCHAR(50))
main: BEGIN
    SELECT
        u.IDUSUARIO,
        u.NOMBRE,
        u.APELLIDO,
        u.DNI,
        u.EMAIL,
        u.ESTADO,
        u.IDTIPOUSUARIO,
        t.DESCRIPCION AS TIPOUSUARIO_DESCRIPCION,
        u.FECHANACIMIENTO,
        u.DIRECCION,
        u.DISTRITO,
        u.COLEGIO,
        u.GRADO,
        u.FECHAACTIVO,
        u.TELPERSONAL,
        u.TELAPODERADO,
        u.SITUACIONACADEMICA,
        u.FOTO
    FROM USUARIO u
    INNER JOIN TIPOUSUARIO t ON t.IDTIPOUSUARIO = u.IDTIPOUSUARIO
    WHERE u.IDUSUARIO = p_Id;
END$$

DELIMITER ;

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
    IN p_SituacionAcademica VARCHAR(100),
    IN p_Foto LONGTEXT,
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
    IF EXISTS (SELECT 1 FROM USUARIO WHERE IDUSUARIO = p_Id) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'El usuario ya existe.';
        LEAVE main;
    END IF;

    IF EXISTS (SELECT 1 FROM USUARIO WHERE DNI = p_Dni) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'El DNI ya está registrado.';
        LEAVE main;
    END IF;

    IF EXISTS (SELECT 1 FROM USUARIO WHERE EMAIL = p_Email) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'El email ya está registrado.';
        LEAVE main;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM TIPOUSUARIO WHERE IDTIPOUSUARIO = p_IdTipoUsuario) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'Tipo de usuario no válido.';
        LEAVE main;
    END IF;

    INSERT INTO USUARIO (
        IDUSUARIO, CONTRA, NOMBRE, APELLIDO, DNI, EMAIL, IDTIPOUSUARIO, ESTADO,
        FECHANACIMIENTO, DIRECCION, DISTRITO, COLEGIO, GRADO,
        TELPERSONAL, TELAPODERADO, SITUACIONACADEMICA, FECHAACTIVO, FOTO
    ) VALUES (
        p_Id, p_Contra, p_Nombre, p_Apellido, p_Dni, p_Email, p_IdTipoUsuario, p_Estado,
        p_FechaNacimiento, p_Direccion, p_Distrito, p_Colegio, p_Grado,
        p_TelPersonal, p_TelApoderado, p_SituacionAcademica, fn_fecha_ddmmyyyy(), p_Foto
    );

    SET p_Resultado = 1; SET p_Mensaje = 'Usuario creado.';
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
    IN p_SituacionAcademica VARCHAR(100),
    IN p_Foto LONGTEXT,
    IN p_ActualizarFoto TINYINT(1),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
    IF NOT EXISTS (SELECT 1 FROM USUARIO WHERE IDUSUARIO = p_Id) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'El usuario no existe.';
        LEAVE main;
    END IF;

    IF EXISTS (SELECT 1 FROM USUARIO WHERE DNI = p_Dni AND IDUSUARIO <> p_Id) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'El DNI ya está registrado.';
        LEAVE main;
    END IF;

    IF EXISTS (SELECT 1 FROM USUARIO WHERE EMAIL = p_Email AND IDUSUARIO <> p_Id) THEN
        SET p_Resultado = 0; SET p_Mensaje = 'El email ya está registrado.';
        LEAVE main;
    END IF;

    UPDATE USUARIO SET
        NOMBRE             = p_Nombre,
        APELLIDO           = p_Apellido,
        DNI                = p_Dni,
        EMAIL              = p_Email,
        IDTIPOUSUARIO      = p_IdTipoUsuario,
        ESTADO             = p_Estado,
        FECHANACIMIENTO    = p_FechaNacimiento,
        DIRECCION          = p_Direccion,
        DISTRITO           = p_Distrito,
        COLEGIO            = p_Colegio,
        GRADO              = p_Grado,
        TELPERSONAL        = p_TelPersonal,
        TELAPODERADO       = p_TelApoderado,
        SITUACIONACADEMICA = p_SituacionAcademica,
        CONTRA             = CASE WHEN p_Contra IS NOT NULL AND p_Contra <> '' THEN p_Contra ELSE CONTRA END,
        FOTO               = CASE WHEN p_ActualizarFoto = 1 THEN p_Foto ELSE FOTO END
    WHERE IDUSUARIO = p_Id;

    SET p_Resultado = 1; SET p_Mensaje = 'Usuario actualizado.';
END$$

DELIMITER ;

SELECT 'usp_usuario_obtener / insertar / actualizar actualizados con FOTO.' AS info;
