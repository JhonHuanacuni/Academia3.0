-- Convertido automáticamente desde db_scripts/11_07_2026/2.usp_usuario_apoderado.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   SPs usuario: soporte NOMBREAPODERADO y PARENTESCO
   Ejecutar después de 1.usuario_columnas_apoderado.sql
   Fecha: 11/07/2026
   ============================================================================ */

DROP PROCEDURE IF EXISTS usp_usuario_listar;

DROP PROCEDURE IF EXISTS usp_usuario_listar;

DELIMITER $$

CREATE PROCEDURE usp_usuario_listar(
    IN p_Buscar VARCHAR(200),
    IN p_Estado VARCHAR(50),
    IN p_OrdenarPor VARCHAR(50),
    IN p_Direccion VARCHAR(4),
    IN p_Pagina INT,
    IN p_TamanioPagina INT,
    OUT p_TotalRegistros INT
)
main: BEGIN
    DECLARE v_offset INT DEFAULT 0;
IF p_Pagina < 1 THEN SET p_Pagina = 1; END IF;
    IF p_TamanioPagina < 1 THEN SET p_TamanioPagina = 10; END IF;

    SET v_offset = (p_Pagina - 1) * p_TamanioPagina;
    SELECT COUNT(*) INTO p_TotalRegistros
    FROM USUARIO u
    INNER JOIN TIPOUSUARIO t ON t.IDTIPOUSUARIO = u.IDTIPOUSUARIO
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           u.IDUSUARIO  LIKE CONCAT('%', p_Buscar, '%') OR
           u.NOMBRE     LIKE CONCAT('%', p_Buscar, '%') OR
           u.APELLIDO   LIKE CONCAT('%', p_Buscar, '%') OR
           u.DNI        LIKE CONCAT('%', p_Buscar, '%') OR
           u.EMAIL      LIKE CONCAT('%', p_Buscar, '%') OR
           IFNULL(u.NOMBREAPODERADO, '') LIKE CONCAT('%', p_Buscar, '%'))
      AND (p_Estado IS NULL OR p_Estado = '' OR u.ESTADO = p_Estado);

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
        u.TELPERSONAL,
        u.TELAPODERADO,
        u.NOMBREAPODERADO,
        u.PARENTESCO,
        u.SITUACIONACADEMICA
    FROM USUARIO u
    INNER JOIN TIPOUSUARIO t ON t.IDTIPOUSUARIO = u.IDTIPOUSUARIO
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           u.IDUSUARIO  LIKE CONCAT('%', p_Buscar, '%') OR
           u.NOMBRE     LIKE CONCAT('%', p_Buscar, '%') OR
           u.APELLIDO   LIKE CONCAT('%', p_Buscar, '%') OR
           u.DNI        LIKE CONCAT('%', p_Buscar, '%') OR
           u.EMAIL      LIKE CONCAT('%', p_Buscar, '%') OR
           IFNULL(u.NOMBREAPODERADO, '') LIKE CONCAT('%', p_Buscar, '%'))
      AND (p_Estado IS NULL OR p_Estado = '' OR u.ESTADO = p_Estado)
    ORDER BY
        CASE WHEN p_OrdenarPor = 'IDUSUARIO' AND p_Direccion = 'ASC'  THEN u.IDUSUARIO END ASC,
        CASE WHEN p_OrdenarPor = 'IDUSUARIO' AND p_Direccion = 'DESC' THEN u.IDUSUARIO END DESC,
        CASE WHEN p_OrdenarPor = 'NOMBRE'    AND p_Direccion = 'ASC'  THEN u.NOMBRE END ASC,
        CASE WHEN p_OrdenarPor = 'NOMBRE'    AND p_Direccion = 'DESC' THEN u.NOMBRE END DESC,
        CASE WHEN p_OrdenarPor = 'APELLIDO'  AND p_Direccion = 'ASC'  THEN u.APELLIDO END ASC,
        CASE WHEN p_OrdenarPor = 'APELLIDO'  AND p_Direccion = 'DESC' THEN u.APELLIDO END DESC,
        CASE WHEN p_OrdenarPor = 'DNI'       AND p_Direccion = 'ASC'  THEN u.DNI END ASC,
        CASE WHEN p_OrdenarPor = 'DNI'       AND p_Direccion = 'DESC' THEN u.DNI END DESC,
        CASE WHEN p_OrdenarPor = 'EMAIL'     AND p_Direccion = 'ASC'  THEN u.EMAIL END ASC,
        CASE WHEN p_OrdenarPor = 'EMAIL'     AND p_Direccion = 'DESC' THEN u.EMAIL END DESC,
        CASE WHEN p_OrdenarPor = 'ESTADO'    AND p_Direccion = 'ASC'  THEN u.ESTADO END ASC,
        CASE WHEN p_OrdenarPor = 'ESTADO'    AND p_Direccion = 'DESC' THEN u.ESTADO END DESC,
        CASE WHEN p_OrdenarPor = 'NOMBREAPODERADO' AND p_Direccion = 'ASC'  THEN u.NOMBREAPODERADO END ASC,
        CASE WHEN p_OrdenarPor = 'NOMBREAPODERADO' AND p_Direccion = 'DESC' THEN u.NOMBREAPODERADO END DESC,
        CASE WHEN p_OrdenarPor = 'TELAPODERADO'    AND p_Direccion = 'ASC'  THEN u.TELAPODERADO END ASC,
        CASE WHEN p_OrdenarPor = 'TELAPODERADO'    AND p_Direccion = 'DESC' THEN u.TELAPODERADO END DESC,
        CASE WHEN p_OrdenarPor = 'PARENTESCO'      AND p_Direccion = 'ASC'  THEN u.PARENTESCO END ASC,
        CASE WHEN p_OrdenarPor = 'PARENTESCO'      AND p_Direccion = 'DESC' THEN u.PARENTESCO END DESC,
        u.IDUSUARIO
    LIMIT p_TamanioPagina OFFSET v_offset;
    SELECT p_TotalRegistros AS TotalRegistros
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_usuario_obtener;

DROP PROCEDURE IF EXISTS usp_usuario_obtener;

DELIMITER $$

CREATE PROCEDURE usp_usuario_obtener(
    IN p_Id VARCHAR(50)
)
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
        u.NOMBREAPODERADO,
        u.PARENTESCO,
        u.SITUACIONACADEMICA,
        u.FOTO
    FROM USUARIO u
    INNER JOIN TIPOUSUARIO t ON t.IDTIPOUSUARIO = u.IDTIPOUSUARIO
    WHERE u.IDUSUARIO = p_Id;
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
    
    INSERT INTO USUARIO (
        IDUSUARIO, CONTRA, NOMBRE, APELLIDO, DNI, EMAIL, IDTIPOUSUARIO, ESTADO,
        FECHANACIMIENTO, DIRECCION, DISTRITO, COLEGIO, GRADO,
        TELPERSONAL, TELAPODERADO, NOMBREAPODERADO, PARENTESCO,
        SITUACIONACADEMICA, FECHAACTIVO, FOTO
    ) VALUES (
        p_Id, p_Contra, p_Nombre, p_Apellido, p_Dni, p_Email, p_IdTipoUsuario, p_Estado,
        p_FechaNacimiento, p_Direccion, p_Distrito, p_Colegio, p_Grado,
        p_TelPersonal, p_TelApoderado, p_NombreApoderado, p_Parentesco,
        p_SituacionAcademica, fn_fecha_ddmmyyyy(), p_Foto
    );

    SET p_Resultado = 1; SET p_Mensaje = 'Usuario creado.';
    SELECT p_Resultado AS Resultado, p_Mensaje AS Mensaje
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_usuario_actualizar;

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
        NOMBREAPODERADO    = p_NombreApoderado,
        PARENTESCO         = p_Parentesco,
        SITUACIONACADEMICA = p_SituacionAcademica,
        CONTRA             = CASE WHEN p_Contra IS NOT NULL AND p_Contra <> '' THEN p_Contra ELSE CONTRA END,
        FOTO               = CASE WHEN p_ActualizarFoto = 1 THEN p_Foto ELSE FOTO 
    WHERE IDUSUARIO = p_Id;

    SET p_Resultado = 1; SET p_Mensaje = 'Usuario actualizado.';
END;

SELECT 'usp_usuario_listar / obtener / insertar / actualizar actualizados con apoderado.';
    SELECT p_Resultado AS Resultado, p_Mensaje AS Mensaje
END$$

DELIMITER ;