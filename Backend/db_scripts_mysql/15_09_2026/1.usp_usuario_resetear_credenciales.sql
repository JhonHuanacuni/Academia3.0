-- ============================================================================
-- 1. usp_usuario_resetear_contra
-- Restablece USUARIO (IDUSUARIO) y CONTRASEÑA al DNI.
-- phpMyAdmin: selecciona tu BD, pega TODO y ejecuta
-- ============================================================================

DROP PROCEDURE IF EXISTS usp_usuario_resetear_contra;

DELIMITER $$

CREATE PROCEDURE usp_usuario_resetear_contra(
    IN p_Id VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
    DECLARE v_Dni VARCHAR(20);
    DECLARE v_IdActual VARCHAR(50);
    DECLARE v_Tabla VARCHAR(64);
    DECLARE v_Col VARCHAR(64);
    DECLARE v_Done INT DEFAULT 0;
    DECLARE cur CURSOR FOR
        SELECT TABLE_NAME, COLUMN_NAME
        FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND COLUMN_NAME IN ('IDUSUARIO', 'REGISTRADOPOR', 'IDREGISTRADOR', 'IMPORTADO_POR')
          AND TABLE_NAME <> 'USUARIO';
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_Done = 1;

    IF NOT EXISTS (SELECT 1 FROM USUARIO WHERE IDUSUARIO = p_Id) THEN
        SET p_Resultado = 0;
        SET p_Mensaje = 'El usuario no existe.';
        LEAVE main;
    END IF;

    SELECT IDUSUARIO, TRIM(IFNULL(DNI, '')) INTO v_IdActual, v_Dni
    FROM USUARIO WHERE IDUSUARIO = p_Id LIMIT 1;

    IF v_Dni IS NULL OR v_Dni = '' THEN
        SET p_Resultado = 0;
        SET p_Mensaje = 'El usuario no tiene DNI. No se pueden restablecer las credenciales.';
        LEAVE main;
    END IF;

    IF v_IdActual <> v_Dni AND EXISTS (
        SELECT 1 FROM USUARIO WHERE IDUSUARIO = v_Dni AND IDUSUARIO <> v_IdActual
    ) THEN
        SET p_Resultado = 0;
        SET p_Mensaje = CONCAT('No se pudo cambiar el usuario: ya existe otro registro con usuario ', v_Dni, '.');
        LEAVE main;
    END IF;

    IF v_IdActual = v_Dni THEN
        UPDATE USUARIO SET CONTRA = v_Dni WHERE IDUSUARIO = v_IdActual;
        SET p_Resultado = 1;
        SET p_Mensaje = CONCAT('Credenciales restablecidas. Usuario y contraseña: ', v_Dni);
        LEAVE main;
    END IF;

    SET FOREIGN_KEY_CHECKS = 0;

    OPEN cur;
    rename_loop: LOOP
        FETCH cur INTO v_Tabla, v_Col;
        IF v_Done = 1 THEN
            LEAVE rename_loop;
        END IF;
        SET @sql = CONCAT('UPDATE `', v_Tabla, '` SET `', v_Col, '` = ? WHERE `', v_Col, '` = ?');
        PREPARE stmt FROM @sql;
        SET @nuevo = v_Dni;
        SET @viejo = v_IdActual;
        EXECUTE stmt USING @nuevo, @viejo;
        DEALLOCATE PREPARE stmt;
    END LOOP;
    CLOSE cur;

    UPDATE USUARIO SET IDUSUARIO = v_Dni, CONTRA = v_Dni WHERE IDUSUARIO = v_IdActual;

    SET FOREIGN_KEY_CHECKS = 1;

    SET p_Resultado = 1;
    SET p_Mensaje = CONCAT('Credenciales restablecidas. Usuario y contraseña: ', v_Dni);
END$$

DELIMITER ;

SELECT '1. usp_usuario_resetear_contra: usuario y contraseña = DNI.' AS info;
