-- Convertido automáticamente desde db_scripts/26_07_2026/4.rename_membresia_asesor_a_mensualidad_tutor.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   Renombrar MEMBRESIA -> MENSUALIDAD, ASESOR -> TUTOR
   Ejecutar despues de 26_07_2026/3.aula_catalogo_academia_vita.sql
   Fecha: 26/07/2026

   Cambios:
   - Tablas: MENSUALIDAD, TUTOR, PAGOMENSUALIDAD, NOTIFICACIONMENSUALIDAD
   - Columnas: IDMENSUALIDAD, IDTUTOR, IDPAGOMENSUALIDAD, etc.
   - SPs: usp_mensualidad_*, usp_tutor_*, usp_pago_mensualidades_*
   - Columna legacy MEMBRESIA.ASESOR -> MENSUALIDAD.TUTORLEGACY
   ============================================================================ */

/* --- 1) Eliminar FKs que referencian MEMBRESIA / ASESOR --- */
DECLARE @sql LONGTEXT = N'';
SELECT @sql = @sql + N'ALTER TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) + N'.' + QUOTENAME(OBJECT_NAME(parent_object_id))
    + N' DROP CONSTRAINT ' + QUOTENAME(name) + N';' + CHAR(13)
FROM sys.foreign_keys
WHERE referenced_object_id IN (OBJECT_ID('MEMBRESIA'), OBJECT_ID('ASESOR'))
   OR parent_object_id IN (OBJECT_ID('MEMBRESIA'), OBJECT_ID('PAGOMEMBRESIA'), OBJECT_ID('NOTIFICACIONMEMBRESIA'), OBJECT_ID('ASESOR'));
EXEC sp_executesql @sql;

/* --- 2) Renombrar tablas --- */
IF OBJECT_ID('NOTIFICACIONMEMBRESIA', 'U') IS NOT NULL
    RENAME TABLE `NOTIFICACIONMEMBRESIA` TO `NOTIFICACIONMENSUALIDAD`;
IF OBJECT_ID('PAGOMEMBRESIA', 'U') IS NOT NULL
    RENAME TABLE `NOTIFICACIONMEMBRESIA` TO `NOTIFICACIONMENSUALIDAD`;
IF COL_LENGTH('MEMBRESIA', 'ASESOR') IS NOT NULL
    EXEC sp_rename 'MEMBRESIA.ASESOR', 'TUTORLEGACY', 'COLUMN';
IF OBJECT_ID('MEMBRESIA', 'U') IS NOT NULL
    RENAME TABLE `NOTIFICACIONMEMBRESIA` TO `NOTIFICACIONMENSUALIDAD`;
IF OBJECT_ID('ASESOR', 'U') IS NOT NULL
    RENAME TABLE `NOTIFICACIONMEMBRESIA` TO `NOTIFICACIONMENSUALIDAD`;

/* --- 3) Renombrar columnas PK/FK --- */
IF COL_LENGTH('NOTIFICACIONMENSUALIDAD', 'IDNOTIFICACIONMEMBRESIA') IS NOT NULL
    EXEC sp_rename 'NOTIFICACIONMENSUALIDAD.IDNOTIFICACIONMEMBRESIA', 'IDNOTIFICACIONMENSUALIDAD', 'COLUMN';
IF COL_LENGTH('NOTIFICACIONMENSUALIDAD', 'IDMEMBRESIA') IS NOT NULL
    EXEC sp_rename 'NOTIFICACIONMENSUALIDAD.IDMEMBRESIA', 'IDMENSUALIDAD', 'COLUMN';
IF COL_LENGTH('PAGOMENSUALIDAD', 'IDPAGOMEMBRESIA') IS NOT NULL
    EXEC sp_rename 'PAGOMENSUALIDAD.IDPAGOMEMBRESIA', 'IDPAGOMENSUALIDAD', 'COLUMN';
IF COL_LENGTH('PAGOMENSUALIDAD', 'IDMEMBRESIA') IS NOT NULL
    EXEC sp_rename 'PAGOMENSUALIDAD.IDMEMBRESIA', 'IDMENSUALIDAD', 'COLUMN';
IF COL_LENGTH('MENSUALIDAD', 'IDMEMBRESIA') IS NOT NULL
    EXEC sp_rename 'MENSUALIDAD.IDMEMBRESIA', 'IDMENSUALIDAD', 'COLUMN';
IF COL_LENGTH('MENSUALIDAD', 'IDASESOR') IS NOT NULL
    EXEC sp_rename 'MENSUALIDAD.IDASESOR', 'IDTUTOR', 'COLUMN';
IF COL_LENGTH('MENSUALIDAD', 'TIPOMEMBRESIA') IS NOT NULL
    EXEC sp_rename 'MENSUALIDAD.TIPOMEMBRESIA', 'TIPOMENSUALIDAD', 'COLUMN';
IF COL_LENGTH('TUTOR', 'IDASESOR') IS NOT NULL
    EXEC sp_rename 'TUTOR.IDASESOR', 'IDTUTOR', 'COLUMN';

/* --- 4) Recrear FKs --- */
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_MENSUALIDAD_PLAN')
    ALTER TABLE MENSUALIDAD ADD CONSTRAINT FK_MENSUALIDAD_PLAN
        FOREIGN KEY (IDPLAN) REFERENCES [PLAN](IDPLAN);
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_MENSUALIDAD_AULA')
    ALTER TABLE MENSUALIDAD ADD CONSTRAINT FK_MENSUALIDAD_AULA
        FOREIGN KEY (IDAULA) REFERENCES AULA(IDAULA);
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_MENSUALIDAD_TURNO')
    ALTER TABLE MENSUALIDAD ADD CONSTRAINT FK_MENSUALIDAD_TURNO
        FOREIGN KEY (IDTURNO) REFERENCES TURNO(IDTURNO);
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_MENSUALIDAD_PROMOCION')
    ALTER TABLE MENSUALIDAD ADD CONSTRAINT FK_MENSUALIDAD_PROMOCION
        FOREIGN KEY (IDPROMOCION) REFERENCES PROMOCIONES(IDPROMOCION);
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_MENSUALIDAD_USUARIO')
    ALTER TABLE MENSUALIDAD ADD CONSTRAINT FK_MENSUALIDAD_USUARIO
        FOREIGN KEY (IDUSUARIO) REFERENCES USUARIO(IDUSUARIO);
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_MENSUALIDAD_REGISTRADOPOR')
    ALTER TABLE MENSUALIDAD ADD CONSTRAINT FK_MENSUALIDAD_REGISTRADOPOR
        FOREIGN KEY (REGISTRADOPOR) REFERENCES USUARIO(IDUSUARIO);
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_MENSUALIDAD_TUTOR')
    ALTER TABLE MENSUALIDAD ADD CONSTRAINT FK_MENSUALIDAD_TUTOR
        FOREIGN KEY (IDTUTOR) REFERENCES TUTOR(IDTUTOR);
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_PAGOMENSUALIDAD_MENSUALIDAD')
    ALTER TABLE PAGOMENSUALIDAD ADD CONSTRAINT FK_PAGOMENSUALIDAD_MENSUALIDAD
        FOREIGN KEY (IDMENSUALIDAD) REFERENCES MENSUALIDAD(IDMENSUALIDAD);
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_PAGOMENSUALIDAD_METODOPAGO')
    ALTER TABLE PAGOMENSUALIDAD ADD CONSTRAINT FK_PAGOMENSUALIDAD_METODOPAGO
        FOREIGN KEY (IDMETODOPAGO) REFERENCES METODO_PAGO(IDMETODOPAGO);
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_PAGOMENSUALIDAD_USUARIO')
    ALTER TABLE PAGOMENSUALIDAD ADD CONSTRAINT FK_PAGOMENSUALIDAD_USUARIO
        FOREIGN KEY (IDUSUARIO) REFERENCES USUARIO(IDUSUARIO);
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_NOTIFMENSUALIDAD_MENSUALIDAD')
    ALTER TABLE NOTIFICACIONMENSUALIDAD ADD CONSTRAINT FK_NOTIFMENSUALIDAD_MENSUALIDAD
        FOREIGN KEY (IDMENSUALIDAD) REFERENCES MENSUALIDAD(IDMENSUALIDAD);
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_NOTIFMENSUALIDAD_USUARIO')
    ALTER TABLE NOTIFICACIONMENSUALIDAD ADD CONSTRAINT FK_NOTIFMENSUALIDAD_USUARIO
        FOREIGN KEY (IDUSUARIO) REFERENCES USUARIO(IDUSUARIO);

/* --- 5) Eliminar SPs legacy --- */
DECLARE @drop LONGTEXT = N'';
SELECT @drop = @drop + N'DROP PROCEDURE ' + QUOTENAME(name, '[') + N';' + CHAR(13)
FROM sys.procedures
WHERE name LIKE 'usp_membresia_%'
   OR name LIKE 'usp_asesor_%'
   OR name = 'usp_pago_membresias_estudiante';
IF LEN(@drop) > 0 EXEC sp_executesql @drop;

/* --- 6) Recrear SPs con nombres nuevos --- */
/* ============================================================================
   CRUD ASESOR — Mantenedor de tutores (módulo Académico)
   Ejecutar después de 6.tutor_tabla.sql (11_07_2026)
   Fecha: 12/07/2026
   ============================================================================ */

DROP PROCEDURE IF EXISTS usp_tutor_listar;

DROP PROCEDURE IF EXISTS usp_tutor_listar;

DELIMITER $$

CREATE PROCEDURE usp_tutor_listar(
    IN p_Buscar VARCHAR(200),
    IN p_Estado VARCHAR(50),
    IN p_OrdenarPor VARCHAR(50),
    IN p_Direccion VARCHAR(4),
    IN p_Pagina INT,
    IN p_TamanioPagina INT,
    OUT p_TotalRegistros INT
)
main: BEGIN
IF p_Pagina < 1 THEN SET p_Pagina = 1; END IF;
    IF p_TamanioPagina < 1 THEN SET p_TamanioPagina = 10; END IF;

    SELECT COUNT(*) INTO p_TotalRegistros
    FROM TUTOR a
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           a.IDTUTOR LIKE CONCAT('%', p_Buscar, '%') OR
           a.NOMBRE   LIKE CONCAT('%', p_Buscar, '%'))
      AND (p_Estado IS NULL OR p_Estado = '' OR
           (p_Estado = 'Activo' AND a.ACTIVO = 1) OR
           (p_Estado = 'Inactivo' AND a.ACTIVO = 0));

    SELECT
        a.IDTUTOR,
        a.NOMBRE,
        CASE WHEN a.ACTIVO = 1 THEN 'Activo' ELSE 'Inactivo' END AS ESTADO
    FROM TUTOR a
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           a.IDTUTOR LIKE CONCAT('%', p_Buscar, '%') OR
           a.NOMBRE   LIKE CONCAT('%', p_Buscar, '%'))
      AND (p_Estado IS NULL OR p_Estado = '' OR
           (p_Estado = 'Activo' AND a.ACTIVO = 1) OR
           (p_Estado = 'Inactivo' AND a.ACTIVO = 0))
    ORDER BY
        CASE WHEN p_OrdenarPor = 'IDTUTOR' AND p_Direccion = 'ASC'  THEN a.IDTUTOR END ASC,
        CASE WHEN p_OrdenarPor = 'IDTUTOR' AND p_Direccion = 'DESC' THEN a.IDTUTOR END DESC,
        CASE WHEN p_OrdenarPor = 'NOMBRE'   AND p_Direccion = 'ASC'  THEN a.NOMBRE END ASC,
        CASE WHEN p_OrdenarPor = 'NOMBRE'   AND p_Direccion = 'DESC' THEN a.NOMBRE END DESC,
        CASE WHEN p_OrdenarPor = 'ESTADO'   AND p_Direccion = 'ASC'  THEN a.ACTIVO END ASC,
        CASE WHEN p_OrdenarPor = 'ESTADO'   AND p_Direccion = 'DESC' THEN a.ACTIVO END DESC,
        a.NOMBRE
    LIMIT p_TamanioPagina OFFSET ((p_Pagina - 1) * p_TamanioPagina);
    SELECT p_TotalRegistros AS TotalRegistros
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_tutor_obtener;

DROP PROCEDURE IF EXISTS usp_tutor_obtener;

DELIMITER $$

CREATE PROCEDURE usp_tutor_obtener(
    IN p_Id VARCHAR(50)
)
main: BEGIN
SELECT
        a.IDTUTOR,
        a.NOMBRE,
        CASE WHEN a.ACTIVO = 1 THEN 'Activo' ELSE 'Inactivo' END AS ESTADO
    FROM TUTOR a
    WHERE a.IDTUTOR = p_Id;
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_tutor_insertar;

DROP PROCEDURE IF EXISTS usp_tutor_insertar;

DELIMITER $$

CREATE PROCEDURE usp_tutor_insertar(
    IN p_Id VARCHAR(50),
    IN p_Nombre VARCHAR(150),
    IN p_Estado VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
IF p_Id IS NULL OR TRIM(p_Id)) = ''
    BEGIN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa el código del tutor.';
        LEAVE main;
    
    IF p_Nombre IS NULL OR TRIM(p_Nombre)) = ''
    BEGIN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa el nombre del tutor.';
        LEAVE main;
    
    IF EXISTS (SELECT 1 FROM TUTOR WHERE IDTUTOR = p_Id)
    BEGIN
        SET p_Resultado = 0; SET p_Mensaje = 'El código de tutor ya existe.';
        LEAVE main;
    
    IF EXISTS (SELECT 1 FROM TUTOR WHERE NOMBRE = p_Nombre)
    BEGIN
        SET p_Resultado = 0; SET p_Mensaje = 'Ya existe un tutor con ese nombre.';
        LEAVE main;
    
    INSERT INTO TUTOR (IDTUTOR, NOMBRE, ACTIVO)
    VALUES (
        p_Id,
        p_Nombre,
        CASE WHEN p_Estado = 'Activo' THEN 1 ELSE 0 
    );

    SET p_Resultado = 1; SET p_Mensaje = 'Tutor registrado.';
    SELECT p_Resultado AS Resultado, p_Mensaje AS Mensaje
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_tutor_actualizar;

DROP PROCEDURE IF EXISTS usp_tutor_actualizar;

DELIMITER $$

CREATE PROCEDURE usp_tutor_actualizar(
    IN p_Id VARCHAR(50),
    IN p_Nombre VARCHAR(150),
    IN p_Estado VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
IF NOT EXISTS (SELECT 1 FROM TUTOR WHERE IDTUTOR = p_Id)
    BEGIN
        SET p_Resultado = 0; SET p_Mensaje = 'El tutor no existe.';
        LEAVE main;
    
    IF p_Nombre IS NULL OR TRIM(p_Nombre)) = ''
    BEGIN
        SET p_Resultado = 0; SET p_Mensaje = 'Ingresa el nombre del tutor.';
        LEAVE main;
    
    IF EXISTS (SELECT 1 FROM TUTOR WHERE NOMBRE = p_Nombre AND IDTUTOR <> p_Id)
    BEGIN
        SET p_Resultado = 0; SET p_Mensaje = 'Ya existe un tutor con ese nombre.';
        LEAVE main;
    
    UPDATE TUTOR SET
        NOMBRE = p_Nombre,
        ACTIVO = CASE WHEN p_Estado = 'Activo' THEN 1 ELSE 0 
    WHERE IDTUTOR = p_Id;

    SET p_Resultado = 1; SET p_Mensaje = 'Tutor actualizado.';
    SELECT p_Resultado AS Resultado, p_Mensaje AS Mensaje
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_tutor_eliminar;

DROP PROCEDURE IF EXISTS usp_tutor_eliminar;

DELIMITER $$

CREATE PROCEDURE usp_tutor_eliminar(
    IN p_Id VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
IF NOT EXISTS (SELECT 1 FROM TUTOR WHERE IDTUTOR = p_Id)
    BEGIN
        SET p_Resultado = 0; SET p_Mensaje = 'El tutor no existe.';
        LEAVE main;
    
    IF EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDTUTOR = p_Id)
    BEGIN
        SET p_Resultado = 0;
        SET p_Mensaje = 'No se puede eliminar: el tutor tiene mensualidads asociadas.';
        LEAVE main;
    
    DELETE FROM TUTOR WHERE IDTUTOR = p_Id;

    SET p_Resultado = 1; SET p_Mensaje = 'Tutor eliminado.';
END;

/* ============================================================================
   Mensualidads: columna DEUDA en listado (MONTOTOTAL − suma pagos)
   Ejecutar después de 12_07_2026/10.comoentero_a_usuario.sql
   Fecha: 16/07/2026
   ============================================================================ */
    SELECT p_Resultado AS Resultado, p_Mensaje AS Mensaje
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_mensualidad_listar;

DROP PROCEDURE IF EXISTS usp_mensualidad_listar;

DELIMITER $$

CREATE PROCEDURE usp_mensualidad_listar(
    IN p_Buscar VARCHAR(200),
    IN p_Estado VARCHAR(50),
    IN p_OrdenarPor VARCHAR(50),
    IN p_Direccion VARCHAR(4),
    IN p_Pagina INT,
    IN p_TamanioPagina INT,
    OUT p_TotalRegistros INT
)
main: BEGIN
IF p_Pagina < 1 THEN SET p_Pagina = 1; END IF;
    IF p_TamanioPagina < 1 THEN SET p_TamanioPagina = 10; END IF;
    IF p_Estado IS NULL OR p_Estado = '' THEN SET p_Estado = 'Activo'; END IF;

    SELECT COUNT(*) INTO p_TotalRegistros
    FROM MENSUALIDAD m
    INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
    INNER JOIN [PLAN] pl ON pl.IDPLAN = m.IDPLAN
    LEFT JOIN AULA au ON au.IDAULA = m.IDAULA
    LEFT JOIN TURNO tu ON tu.IDTURNO = m.IDTURNO
    LEFT JOIN TUTOR ase ON ase.IDTUTOR = m.IDTUTOR
    WHERE m.ESTADO = p_Estado
      AND (p_Buscar IS NULL OR p_Buscar = '' OR
           m.IDMENSUALIDAD LIKE CONCAT('%', p_Buscar, '%') OR
           u.DNI LIKE CONCAT('%', p_Buscar, '%') OR
           u.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
           u.APELLIDO LIKE CONCAT('%', p_Buscar, '%') OR
           pl.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
           IFNULL(au.NOMBRE, '') LIKE CONCAT('%', p_Buscar, '%') OR
           IFNULL(ase.NOMBRE, '') LIKE CONCAT('%', p_Buscar, '%'));

    SELECT
        m.IDMENSUALIDAD,
        m.IDUSUARIO,
        UPPER(TRIM(CONCAT(IFNULL(u.APELLIDO, ''), ' ') + IFNULL(u.NOMBRE, '')))) AS ESTUDIANTE_NOMBRE,
        u.DNI AS ESTUDIANTE_DNI,
        m.IDPLAN,
        pl.NOMBRE AS PLAN_NOMBRE,
        IFNULL(tu.DESCRIPCION, '') AS TURNO_DESCRIPCION,
        m.ESTADOMIEMBRO,
        CASE m.ESTADOMIEMBRO
            WHEN 2 THEN 'Activo'
            WHEN 3 THEN 'Vencido'
            ELSE 'Activo'
        END AS ESTADOMIEMBRO_DESCRIPCION,
        m.FECHAINICIO,
        m.FECHAFIN,
        m.MONTOTOTAL,
        IFNULL(pag.PAGADO, 0) AS PAGADO,
        CASE
            WHEN IFNULL(m.MONTOTOTAL, 0) - IFNULL(pag.PAGADO, 0) < 0 THEN 0
            ELSE IFNULL(m.MONTOTOTAL, 0) - IFNULL(pag.PAGADO, 0)
        END AS DEUDA,
        IFNULL(au.NOMBRE, '') AS AULA_NOMBRE,
        m.IDTUTOR,
        IFNULL(ase.NOMBRE, IFNULL(m.TUTORLEGACY, '')) AS TUTOR_NOMBRE,
        m.ESTADO,
        m.FECHAREGISTRO
    FROM MENSUALIDAD m
    INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
    INNER JOIN [PLAN] pl ON pl.IDPLAN = m.IDPLAN
    LEFT JOIN AULA au ON au.IDAULA = m.IDAULA
    LEFT JOIN TURNO tu ON tu.IDTURNO = m.IDTURNO
    LEFT JOIN TUTOR ase ON ase.IDTUTOR = m.IDTUTOR
    OUTER APPLY (
        SELECT SUM(p.MONTO) AS PAGADO
        FROM PAGOMENSUALIDAD p
        WHERE p.IDMENSUALIDAD = m.IDMENSUALIDAD
    ) pag
    WHERE m.ESTADO = p_Estado
      AND (p_Buscar IS NULL OR p_Buscar = '' OR
           m.IDMENSUALIDAD LIKE CONCAT('%', p_Buscar, '%') OR
           u.DNI LIKE CONCAT('%', p_Buscar, '%') OR
           u.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
           u.APELLIDO LIKE CONCAT('%', p_Buscar, '%') OR
           pl.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
           IFNULL(au.NOMBRE, '') LIKE CONCAT('%', p_Buscar, '%') OR
           IFNULL(ase.NOMBRE, '') LIKE CONCAT('%', p_Buscar, '%'))
    ORDER BY
        CASE WHEN p_OrdenarPor = 'IDMENSUALIDAD' AND p_Direccion = 'ASC'  THEN m.IDMENSUALIDAD END ASC,
        CASE WHEN p_OrdenarPor = 'IDMENSUALIDAD' AND p_Direccion = 'DESC' THEN m.IDMENSUALIDAD END DESC,
        CASE WHEN p_OrdenarPor = 'ESTUDIANTE_NOMBRE' AND p_Direccion = 'ASC'  THEN u.APELLIDO END ASC,
        CASE WHEN p_OrdenarPor = 'ESTUDIANTE_NOMBRE' AND p_Direccion = 'DESC' THEN u.APELLIDO END DESC,
        CASE WHEN p_OrdenarPor = 'FECHAINICIO' AND p_Direccion = 'ASC'  THEN m.FECHAINICIO END ASC,
        CASE WHEN p_OrdenarPor = 'FECHAINICIO' AND p_Direccion = 'DESC' THEN m.FECHAINICIO END DESC,
        CASE WHEN p_OrdenarPor = 'FECHAFIN' AND p_Direccion = 'ASC'  THEN m.FECHAFIN END ASC,
        CASE WHEN p_OrdenarPor = 'FECHAFIN' AND p_Direccion = 'DESC' THEN m.FECHAFIN END DESC,
        CASE WHEN p_OrdenarPor = 'MONTOTOTAL' AND p_Direccion = 'ASC'  THEN m.MONTOTOTAL END ASC,
        CASE WHEN p_OrdenarPor = 'MONTOTOTAL' AND p_Direccion = 'DESC' THEN m.MONTOTOTAL END DESC,
        CASE WHEN p_OrdenarPor = 'DEUDA' AND p_Direccion = 'ASC' THEN
            IFNULL(m.MONTOTOTAL, 0) - IFNULL(pag.PAGADO, 0) END ASC,
        CASE WHEN p_OrdenarPor = 'DEUDA' AND p_Direccion = 'DESC' THEN
            IFNULL(m.MONTOTOTAL, 0) - IFNULL(pag.PAGADO, 0) END DESC,
        CASE WHEN p_OrdenarPor = 'FECHAREGISTRO' AND p_Direccion = 'ASC'  THEN m.FECHAREGISTRO END ASC,
        CASE WHEN p_OrdenarPor = 'FECHAREGISTRO' AND p_Direccion = 'DESC' THEN m.FECHAREGISTRO END DESC,
        m.IDMENSUALIDAD DESC
    LIMIT p_TamanioPagina OFFSET ((p_Pagina - 1) * p_TamanioPagina);
    SELECT p_TotalRegistros AS TotalRegistros
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_mensualidad_obtener;

DROP PROCEDURE IF EXISTS usp_mensualidad_obtener;

DELIMITER $$

CREATE PROCEDURE usp_mensualidad_obtener(
    IN p_Id VARCHAR(50)
)
main: BEGIN
SELECT
        m.IDMENSUALIDAD,
        m.IDUSUARIO,
        UPPER(TRIM(CONCAT(IFNULL(u.APELLIDO, ''), ' ') + IFNULL(u.NOMBRE, '')))) AS ESTUDIANTE_NOMBRE,
        u.DNI AS ESTUDIANTE_DNI,
        m.IDPLAN,
        pl.NOMBRE AS PLAN_NOMBRE,
        m.IDTURNO,
        IFNULL(tu.DESCRIPCION, '') AS TURNO_DESCRIPCION,
        m.ESTADOMIEMBRO,
        m.FECHAINICIO,
        m.FECHAFIN,
        m.MONTOTOTAL,
        m.IDAULA,
        IFNULL(au.NOMBRE, '') AS AULA_NOMBRE,
        m.IDTUTOR,
        IFNULL(ase.NOMBRE, IFNULL(m.TUTORLEGACY, '')) AS TUTOR_NOMBRE,
        m.OBSERVACIONES,
        m.FECHACANCELACION,
        m.ESTADO,
        m.FECHAREGISTRO,
        m.REGISTRADOPOR,
        IFNULL(pag.PAGOINICIAL, 0) AS PAGOINICIAL,
        pag.IDMETODOPAGO
    FROM MENSUALIDAD m
    INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
    INNER JOIN [PLAN] pl ON pl.IDPLAN = m.IDPLAN
    LEFT JOIN AULA au ON au.IDAULA = m.IDAULA
    LEFT JOIN TURNO tu ON tu.IDTURNO = m.IDTURNO
    LEFT JOIN TUTOR ase ON ase.IDTUTOR = m.IDTUTOR
    OUTER APPLY (
        SELECT TOP 1 p.MONTO AS PAGOINICIAL, p.IDMETODOPAGO
        FROM PAGOMENSUALIDAD p
        WHERE p.IDMENSUALIDAD = m.IDMENSUALIDAD
        ORDER BY p.FECHAPAGO, p.IDPAGOMENSUALIDAD
    ) pag
    WHERE m.IDMENSUALIDAD = p_Id;
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_mensualidad_insertar;

DROP PROCEDURE IF EXISTS usp_mensualidad_insertar;

DELIMITER $$

CREATE PROCEDURE usp_mensualidad_insertar(
    IN p_Id VARCHAR(50),
    IN p_IdUsuario VARCHAR(50),
    IN p_IdPlan VARCHAR(50),
    IN p_IdTurno VARCHAR(50),
    IN p_EstadoMiembro INT,
    IN p_FechaInicio CHAR(8),
    IN p_FechaFin CHAR(8),
    IN p_MontoTotal DECIMAL(10,2),
    IN p_PagoInicial DECIMAL(10,2),
    IN p_IdMetodoPago VARCHAR(50),
    IN p_IdAula VARCHAR(50),
    IN p_IdTutor VARCHAR(50),
    IN p_Observaciones LONGTEXT,
    IN p_FechaCancelacion CHAR(8),
    IN p_RegistradoPor VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
IF p_IdUsuario IS NULL OR p_IdUsuario = ''
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'Debe seleccionar un estudiante.'; LEAVE main; 
    IF p_FechaInicio IS NULL OR p_FechaFin IS NULL
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'Ingrese fecha de inicio y fin.'; LEAVE main; 
    IF p_MontoTotal IS NULL
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'Ingrese el monto total.'; LEAVE main; 
    IF p_EstadoMiembro NOT IN (2, 3)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'Estado de mensualidad no válido.'; LEAVE main; 
    IF NOT EXISTS (SELECT 1 FROM USUARIO WHERE IDUSUARIO = p_IdUsuario AND IDTIPOUSUARIO = '1')
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'El estudiante no existe o no es válido.'; LEAVE main; 
    IF NOT EXISTS (SELECT 1 FROM [PLAN] WHERE IDPLAN = p_IdPlan)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'El plan seleccionado no es válido.'; LEAVE main; 
    IF p_IdTutor IS NOT NULL AND p_IdTutor <> ''
       AND NOT EXISTS (SELECT 1 FROM TUTOR WHERE IDTUTOR = p_IdTutor AND ACTIVO = 1)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'El tutor seleccionado no es válido.'; LEAVE main; 
    IF p_PagoInicial IS NOT NULL AND p_PagoInicial > 0
       AND (p_IdMetodoPago IS NULL OR p_IdMetodoPago = '')
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'Indique el método de pago del pago inicial.'; LEAVE main; 
    IF p_Id IS NULL OR p_Id = ''
    BEGIN
        DECLARE v_Next INT = IFNULL((
            SELECT MAX(CAST(SUBSTRING(IDMENSUALIDAD, 4, 10) AS INT))
            FROM MENSUALIDAD WHERE IDMENSUALIDAD LIKE 'MEM%'
        ), 0) + 1;
        SET p_Id = CONCAT('MEM', RIGHT('000000' + CAST(v_Next AS VARCHAR(10)), 6);
    
    IF EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = p_Id)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'La mensualidad ya existe.'; LEAVE main; 
    INSERT INTO MENSUALIDAD (
        IDMENSUALIDAD, FECHAINICIO, FECHAFIN, ESTADOMIEMBRO, MONTOTOTAL, OBSERVACIONES,
        FECHAREGISTRO, HORAREGISTRO, IDPLAN, IDAULA, IDTURNO, IDUSUARIO, REGISTRADOPOR,
        IDTUTOR, FECHACANCELACION, ESTADO
    ) VALUES (
        p_Id, p_FechaInicio, p_FechaFin, p_EstadoMiembro, p_MontoTotal, p_Observaciones,
        fn_fecha_ddmmyyyy(), TIME_FORMAT(NOW(), '%H:%i:%s'),
        p_IdPlan, p_IdAula, p_IdTurno, p_IdUsuario, p_RegistradoPor,
        p_IdTutor, p_FechaCancelacion, 'Activo'
    );

    IF p_PagoInicial IS NOT NULL AND p_PagoInicial > 0
    BEGIN
        DECLARE v_IdPago VARCHAR(50) = CONCAT('PAG', RIGHT('000000' + CAST((
            IFNULL((SELECT MAX(CAST(SUBSTRING(IDPAGOMENSUALIDAD, 4, 10) AS INT))
                    FROM PAGOMENSUALIDAD WHERE IDPAGOMENSUALIDAD LIKE 'PAG%'), 0) + 1
        ) AS VARCHAR(10)), 6);

        INSERT INTO PAGOMENSUALIDAD (
            IDPAGOMENSUALIDAD, MONTO, FECHAPAGO, HORAPAGO, OBSERVACIONES,
            IDMENSUALIDAD, IDMETODOPAGO, IDUSUARIO
        ) VALUES (
            v_IdPago, p_PagoInicial, fn_fecha_ddmmyyyy(), TIME_FORMAT(NOW(), '%H:%i:%s'),
            'Pago inicial', p_Id, p_IdMetodoPago, p_RegistradoPor
        );
    
    SET p_Resultado = 1; SET p_Mensaje = 'Mensualidad registrada.';
    SELECT p_Resultado AS Resultado, p_Mensaje AS Mensaje
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_mensualidad_actualizar;

DROP PROCEDURE IF EXISTS usp_mensualidad_actualizar;

DELIMITER $$

CREATE PROCEDURE usp_mensualidad_actualizar(
    IN p_Id VARCHAR(50),
    IN p_IdUsuario VARCHAR(50),
    IN p_IdPlan VARCHAR(50),
    IN p_IdTurno VARCHAR(50),
    IN p_EstadoMiembro INT,
    IN p_FechaInicio CHAR(8),
    IN p_FechaFin CHAR(8),
    IN p_MontoTotal DECIMAL(10,2),
    IN p_IdAula VARCHAR(50),
    IN p_IdTutor VARCHAR(50),
    IN p_Observaciones LONGTEXT,
    IN p_FechaCancelacion CHAR(8),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = p_Id)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'La mensualidad no existe.'; LEAVE main; 
    IF p_EstadoMiembro NOT IN (2, 3)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'Estado de mensualidad no válido.'; LEAVE main; 
    IF p_IdTutor IS NOT NULL AND p_IdTutor <> ''
       AND NOT EXISTS (SELECT 1 FROM TUTOR WHERE IDTUTOR = p_IdTutor AND ACTIVO = 1)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'El tutor seleccionado no es válido.'; LEAVE main; 
    UPDATE MENSUALIDAD SET
        IDUSUARIO        = p_IdUsuario,
        IDPLAN           = p_IdPlan,
        IDTURNO          = p_IdTurno,
        ESTADOMIEMBRO    = p_EstadoMiembro,
        FECHAINICIO      = p_FechaInicio,
        FECHAFIN         = p_FechaFin,
        MONTOTOTAL       = p_MontoTotal,
        IDAULA           = p_IdAula,
        IDTUTOR         = p_IdTutor,
        OBSERVACIONES    = p_Observaciones,
        FECHACANCELACION = p_FechaCancelacion
    WHERE IDMENSUALIDAD = p_Id;

    SET p_Resultado = 1; SET p_Mensaje = 'Mensualidad actualizada.';
    SELECT p_Resultado AS Resultado, p_Mensaje AS Mensaje
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_pago_mensualidades_estudiante;

DROP PROCEDURE IF EXISTS usp_pago_mensualidades_estudiante;

DELIMITER $$

CREATE PROCEDURE usp_pago_mensualidades_estudiante(
    IN p_IdUsuario VARCHAR(50)
)
main: BEGIN
SELECT TOP 3
        m.IDMENSUALIDAD,
        m.IDPLAN,
        pl.NOMBRE AS PLAN_NOMBRE,
        m.IDTURNO,
        m.IDAULA,
        m.IDTUTOR,
        m.OBSERVACIONES,
        m.FECHAINICIO,
        m.FECHAFIN,
        m.MONTOTOTAL,
        IFNULL(pag.PAGADO, 0) AS PAGADO,
        CASE
            WHEN IFNULL(m.MONTOTOTAL, 0) - IFNULL(pag.PAGADO, 0) < 0 THEN 0
            ELSE IFNULL(m.MONTOTOTAL, 0) - IFNULL(pag.PAGADO, 0)
        END AS DEUDA,
        m.ESTADOMIEMBRO,
        CASE m.ESTADOMIEMBRO
            WHEN 2 THEN 'Activo'
            WHEN 3 THEN 'Vencido'
            ELSE 'Activo'
        END AS ESTADOMIEMBRO_DESCRIPCION,
        m.ESTADO,
        m.FECHAREGISTRO
    FROM MENSUALIDAD m
    INNER JOIN [PLAN] pl ON pl.IDPLAN = m.IDPLAN
    OUTER APPLY (
        SELECT SUM(p.MONTO) AS PAGADO
        FROM PAGOMENSUALIDAD p
        WHERE p.IDMENSUALIDAD = m.IDMENSUALIDAD
    ) pag
    WHERE m.IDUSUARIO = p_IdUsuario
      AND m.ESTADO = 'Activo'
    ORDER BY m.FECHAREGISTRO DESC, m.IDMENSUALIDAD DESC;
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_mensualidad_eliminar;

DROP PROCEDURE IF EXISTS usp_mensualidad_eliminar;

DELIMITER $$

CREATE PROCEDURE usp_mensualidad_eliminar(
    IN p_Id VARCHAR(50),
    IN p_EliminacionFisica TINYINT(1),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = p_Id)
    BEGIN
        SET p_Resultado = 0;
        SET p_Mensaje = 'La mensualidad no existe.';
        LEAVE main;
    
    IF p_EliminacionFisica = 1
    BEGIN
        DELETE FROM NOTIFICACIONMENSUALIDAD WHERE IDMENSUALIDAD = p_Id;
        DELETE FROM PAGOMENSUALIDAD WHERE IDMENSUALIDAD = p_Id;
        DELETE FROM MENSUALIDAD WHERE IDMENSUALIDAD = p_Id;
        SET p_Resultado = 1;
        SET p_Mensaje = 'Mensualidad eliminada permanentemente.';
        LEAVE main;
    
    UPDATE MENSUALIDAD
    SET ESTADO = 'Inactivo'
    WHERE IDMENSUALIDAD = p_Id;

    SET p_Resultado = 1;
    SET p_Mensaje = 'Mensualidad desactivada.';
    SELECT p_Resultado AS Resultado, p_Mensaje AS Mensaje
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_mensualidad_buscar_estudiantes;

DROP PROCEDURE IF EXISTS usp_mensualidad_buscar_estudiantes;

DELIMITER $$

CREATE PROCEDURE usp_mensualidad_buscar_estudiantes(
    IN p_Buscar VARCHAR(200)
)
main: BEGIN
SELECT TOP 20
        u.IDUSUARIO,
        u.DNI,
        u.NOMBRE,
        u.APELLIDO,
        UPPER(TRIM(CONCAT(IFNULL(u.APELLIDO, ''), ' ') + IFNULL(u.NOMBRE, '')))) AS NOMBRE_COMPLETO
    FROM USUARIO u
    WHERE u.IDTIPOUSUARIO = '1'
      AND u.ESTADO = 'Activo'
      AND (p_Buscar IS NULL OR p_Buscar = '' OR
           u.DNI LIKE CONCAT('%', p_Buscar, '%') OR
           u.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
           u.APELLIDO LIKE CONCAT('%', p_Buscar, '%') OR
           (u.APELLIDO + ' ' + u.NOMBRE) LIKE CONCAT('%', p_Buscar, '%'))
    ORDER BY u.APELLIDO, u.NOMBRE;
END;

/* ============================================================================
   Pagos: listar, abonar mensualidad, últimas 3 mensualidads con deuda
   Ejecutar después de 6.usp_mensualidad_estado_registro.sql
   Fecha: 12/07/2026
   ============================================================================ */
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_pago_listar;

DROP PROCEDURE IF EXISTS usp_pago_listar;

DELIMITER $$

CREATE PROCEDURE usp_pago_listar(
    IN p_Buscar VARCHAR(200),
    IN p_OrdenarPor VARCHAR(50),
    IN p_Direccion VARCHAR(4),
    IN p_Pagina INT,
    IN p_TamanioPagina INT,
    OUT p_TotalRegistros INT
)
main: BEGIN
IF p_Pagina < 1 THEN SET p_Pagina = 1; END IF;
    IF p_TamanioPagina < 1 THEN SET p_TamanioPagina = 10; END IF;

    SELECT COUNT(*) INTO p_TotalRegistros
    FROM PAGOMENSUALIDAD p
    INNER JOIN MENSUALIDAD m ON m.IDMENSUALIDAD = p.IDMENSUALIDAD
    INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
    INNER JOIN [PLAN] pl ON pl.IDPLAN = m.IDPLAN
    LEFT JOIN METODO_PAGO mp ON mp.IDMETODOPAGO = p.IDMETODOPAGO
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           p.IDPAGOMENSUALIDAD LIKE CONCAT('%', p_Buscar, '%') OR
           m.IDMENSUALIDAD LIKE CONCAT('%', p_Buscar, '%') OR
           u.DNI LIKE CONCAT('%', p_Buscar, '%') OR
           u.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
           u.APELLIDO LIKE CONCAT('%', p_Buscar, '%') OR
           pl.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
           IFNULL(mp.TITULO, '') LIKE CONCAT('%', p_Buscar, '%'));

    SELECT
        p.IDPAGOMENSUALIDAD,
        p.IDMENSUALIDAD,
        p.MONTO,
        p.FECHAPAGO,
        p.HORAPAGO,
        p.OBSERVACIONES,
        p.IDMETODOPAGO,
        IFNULL(mp.TITULO, '') AS METODOPAGO_TITULO,
        UPPER(TRIM(CONCAT(IFNULL(u.APELLIDO, ''), ' ') + IFNULL(u.NOMBRE, '')))) AS ESTUDIANTE_NOMBRE,
        u.DNI AS ESTUDIANTE_DNI,
        pl.NOMBRE AS PLAN_NOMBRE
    FROM PAGOMENSUALIDAD p
    INNER JOIN MENSUALIDAD m ON m.IDMENSUALIDAD = p.IDMENSUALIDAD
    INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
    INNER JOIN [PLAN] pl ON pl.IDPLAN = m.IDPLAN
    LEFT JOIN METODO_PAGO mp ON mp.IDMETODOPAGO = p.IDMETODOPAGO
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           p.IDPAGOMENSUALIDAD LIKE CONCAT('%', p_Buscar, '%') OR
           m.IDMENSUALIDAD LIKE CONCAT('%', p_Buscar, '%') OR
           u.DNI LIKE CONCAT('%', p_Buscar, '%') OR
           u.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
           u.APELLIDO LIKE CONCAT('%', p_Buscar, '%') OR
           pl.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
           IFNULL(mp.TITULO, '') LIKE CONCAT('%', p_Buscar, '%'))
    ORDER BY
        CASE WHEN p_OrdenarPor = 'FECHAPAGO' AND p_Direccion = 'ASC'  THEN p.FECHAPAGO END ASC,
        CASE WHEN p_OrdenarPor = 'FECHAPAGO' AND p_Direccion = 'DESC' THEN p.FECHAPAGO END DESC,
        CASE WHEN p_OrdenarPor = 'MONTO' AND p_Direccion = 'ASC'  THEN p.MONTO END ASC,
        CASE WHEN p_OrdenarPor = 'MONTO' AND p_Direccion = 'DESC' THEN p.MONTO END DESC,
        CASE WHEN p_OrdenarPor = 'ESTUDIANTE_NOMBRE' AND p_Direccion = 'ASC'  THEN u.APELLIDO END ASC,
        CASE WHEN p_OrdenarPor = 'ESTUDIANTE_NOMBRE' AND p_Direccion = 'DESC' THEN u.APELLIDO END DESC,
        CASE WHEN p_OrdenarPor = 'IDPAGOMENSUALIDAD' AND p_Direccion = 'ASC'  THEN p.IDPAGOMENSUALIDAD END ASC,
        CASE WHEN p_OrdenarPor = 'IDPAGOMENSUALIDAD' AND p_Direccion = 'DESC' THEN p.IDPAGOMENSUALIDAD END DESC,
        p.FECHAPAGO DESC, p.HORAPAGO DESC, p.IDPAGOMENSUALIDAD DESC
    LIMIT p_TamanioPagina OFFSET ((p_Pagina - 1) * p_TamanioPagina);
    SELECT p_TotalRegistros AS TotalRegistros
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_pago_insertar_abono;

DROP PROCEDURE IF EXISTS usp_pago_insertar_abono;

DELIMITER $$

CREATE PROCEDURE usp_pago_insertar_abono(
    IN p_IdMensualidad VARCHAR(50),
    IN p_Monto DECIMAL(10,2),
    IN p_IdMetodoPago VARCHAR(50),
    IN p_Observaciones LONGTEXT,
    IN p_RegistradoPor VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
IF p_IdMensualidad IS NULL OR p_IdMensualidad = ''
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'Debe seleccionar una mensualidad.'; LEAVE main; 
    IF p_Monto IS NULL OR p_Monto <= 0
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'Ingrese un monto válido.'; LEAVE main; 
    IF p_IdMetodoPago IS NULL OR p_IdMetodoPago = ''
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'Indique el método de pago.'; LEAVE main; 
    IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = p_IdMensualidad AND ESTADO = 'Activo')
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'La mensualidad no existe o está inactiva.'; LEAVE main; 
    IF NOT EXISTS (SELECT 1 FROM METODO_PAGO WHERE IDMETODOPAGO = p_IdMetodoPago AND ACTIVO = 1)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'El método de pago no es válido.'; LEAVE main; 
    DECLARE v_MontoTotal DECIMAL(10,2);
    DECLARE v_Pagado DECIMAL(10,2);
    DECLARE v_Deuda DECIMAL(10,2);

    SELECT IFNULL(MONTOTOTAL, 0) FROM MENSUALIDAD WHERE IDMENSUALIDAD = p_IdMensualidad INTO v_MontoTotal;
    SELECT IFNULL(SUM(MONTO), 0) FROM PAGOMENSUALIDAD WHERE IDMENSUALIDAD = p_IdMensualidad INTO v_Pagado;
    SET v_Deuda = v_MontoTotal - v_Pagado;
    IF v_Deuda < 0 THEN SET v_Deuda = 0; END IF;

    IF v_Deuda <= 0
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'Esta mensualidad no tiene deuda pendiente.'; LEAVE main; 
    IF p_Monto > v_Deuda
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'El abono no puede superar la deuda (S/ ' + CAST(v_Deuda AS VARCHAR(20)) + ').'; LEAVE main; 
    DECLARE v_IdPago VARCHAR(50) = CONCAT('PAG', RIGHT('000000' + CAST((
        IFNULL((SELECT MAX(CAST(SUBSTRING(IDPAGOMENSUALIDAD, 4, 10) AS INT))
                FROM PAGOMENSUALIDAD WHERE IDPAGOMENSUALIDAD LIKE 'PAG%'), 0) + 1
    ) AS VARCHAR(10)), 6);

    INSERT INTO PAGOMENSUALIDAD (
        IDPAGOMENSUALIDAD, MONTO, FECHAPAGO, HORAPAGO, OBSERVACIONES,
        IDMENSUALIDAD, IDMETODOPAGO, IDUSUARIO
    ) VALUES (
        v_IdPago, p_Monto, fn_fecha_ddmmyyyy(), TIME_FORMAT(NOW(), '%H:%i:%s'),
        IFNULL(NULLIF(p_Observaciones, ''), 'Abono'),
        p_IdMensualidad, p_IdMetodoPago, p_RegistradoPor
    );

    SET p_Resultado = 1;
    SET p_Mensaje = 'Abono registrado correctamente.';
END;

/* ============================================================================
   Pagos: obtener, actualizar y eliminar
   Ejecutar después de 10.comoentero_a_usuario.sql
   Fecha: 12/07/2026
   ============================================================================ */
    SELECT p_Resultado AS Resultado, p_Mensaje AS Mensaje
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_pago_obtener;

DROP PROCEDURE IF EXISTS usp_pago_obtener;

DELIMITER $$

CREATE PROCEDURE usp_pago_obtener(
    IN p_Id VARCHAR(50)
)
main: BEGIN
SELECT
        p.IDPAGOMENSUALIDAD,
        p.IDMENSUALIDAD,
        p.MONTO,
        p.FECHAPAGO,
        p.HORAPAGO,
        p.OBSERVACIONES,
        p.IDMETODOPAGO,
        IFNULL(mp.TITULO, '') AS METODOPAGO_TITULO,
        m.IDUSUARIO,
        UPPER(TRIM(CONCAT(IFNULL(u.APELLIDO, ''), ' ') + IFNULL(u.NOMBRE, '')))) AS ESTUDIANTE_NOMBRE,
        u.DNI AS ESTUDIANTE_DNI,
        pl.NOMBRE AS PLAN_NOMBRE,
        m.MONTOTOTAL,
        IFNULL(pag.PAGADO, 0) AS PAGADO,
        CASE
            WHEN IFNULL(m.MONTOTOTAL, 0) - IFNULL(pag.PAGADO, 0) < 0 THEN 0
            ELSE IFNULL(m.MONTOTOTAL, 0) - IFNULL(pag.PAGADO, 0)
        END AS DEUDA
    FROM PAGOMENSUALIDAD p
    INNER JOIN MENSUALIDAD m ON m.IDMENSUALIDAD = p.IDMENSUALIDAD
    INNER JOIN USUARIO u ON u.IDUSUARIO = m.IDUSUARIO
    INNER JOIN [PLAN] pl ON pl.IDPLAN = m.IDPLAN
    LEFT JOIN METODO_PAGO mp ON mp.IDMETODOPAGO = p.IDMETODOPAGO
    OUTER APPLY (
        SELECT SUM(x.MONTO) AS PAGADO
        FROM PAGOMENSUALIDAD x
        WHERE x.IDMENSUALIDAD = m.IDMENSUALIDAD
    ) pag
    WHERE p.IDPAGOMENSUALIDAD = p_Id;
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_pago_actualizar;

DROP PROCEDURE IF EXISTS usp_pago_actualizar;

DELIMITER $$

CREATE PROCEDURE usp_pago_actualizar(
    IN p_Id VARCHAR(50),
    IN p_Monto DECIMAL(10,2),
    IN p_IdMetodoPago VARCHAR(50),
    IN p_FechaPago CHAR(8),
    IN p_Observaciones LONGTEXT,
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
IF NOT EXISTS (SELECT 1 FROM PAGOMENSUALIDAD WHERE IDPAGOMENSUALIDAD = p_Id)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'El pago no existe.'; LEAVE main; 
    IF p_Monto IS NULL OR p_Monto <= 0
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'Ingrese un monto válido.'; LEAVE main; 
    IF p_IdMetodoPago IS NULL OR p_IdMetodoPago = ''
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'Indique el método de pago.'; LEAVE main; 
    IF NOT EXISTS (SELECT 1 FROM METODO_PAGO WHERE IDMETODOPAGO = p_IdMetodoPago AND ACTIVO = 1)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'El método de pago no es válido.'; LEAVE main; 
    DECLARE v_IdMensualidad VARCHAR(50);
    DECLARE v_MontoAnterior DECIMAL(10,2);
    DECLARE v_MontoTotal DECIMAL(10,2);
    DECLARE v_PagadoOtros DECIMAL(10,2);
    DECLARE v_Maximo DECIMAL(10,2);

    SELECT IDMENSUALIDAD, v_MontoAnterior = MONTO INTO v_IdMensualidad
    FROM PAGOMENSUALIDAD WHERE IDPAGOMENSUALIDAD = p_Id;

    SELECT IFNULL(MONTOTOTAL, 0) FROM MENSUALIDAD WHERE IDMENSUALIDAD = v_IdMensualidad INTO v_MontoTotal;
    SELECT IFNULL(SUM(MONTO), 0) INTO v_PagadoOtros
    FROM PAGOMENSUALIDAD
    WHERE IDMENSUALIDAD = v_IdMensualidad AND IDPAGOMENSUALIDAD <> p_Id;

    SET v_Maximo = v_MontoTotal - v_PagadoOtros;
    IF v_Maximo < 0 THEN SET v_Maximo = 0; END IF;
    IF p_Monto > v_Maximo
    BEGIN
        SET p_Resultado = 0;
        SET p_Mensaje = 'El monto no puede superar S/ ' + CAST(v_Maximo AS VARCHAR(20)) + '.';
        LEAVE main;
    
    UPDATE PAGOMENSUALIDAD SET
        MONTO          = p_Monto,
        IDMETODOPAGO   = p_IdMetodoPago,
        FECHAPAGO      = CASE WHEN p_FechaPago IS NOT NULL AND p_FechaPago <> '' THEN p_FechaPago ELSE FECHAPAGO END,
        OBSERVACIONES  = p_Observaciones
    WHERE IDPAGOMENSUALIDAD = p_Id;

    SET p_Resultado = 1;
    SET p_Mensaje = 'Pago actualizado.';
    SELECT p_Resultado AS Resultado, p_Mensaje AS Mensaje
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_pago_eliminar;

DROP PROCEDURE IF EXISTS usp_pago_eliminar;

DELIMITER $$

CREATE PROCEDURE usp_pago_eliminar(
    IN p_Id VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
IF NOT EXISTS (SELECT 1 FROM PAGOMENSUALIDAD WHERE IDPAGOMENSUALIDAD = p_Id)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'El pago no existe.'; LEAVE main; 
    DELETE FROM PAGOMENSUALIDAD WHERE IDPAGOMENSUALIDAD = p_Id;

    SET p_Resultado = 1;
    SET p_Mensaje = 'Pago eliminado.';
END;

/* ============================================================================
   Pagos: últimas mensualidads incluyen COSTOMENSUAL del plan
   Ejecutar después de 11.plan_costo_mensual.sql
   Fecha: 16/07/2026
   ============================================================================ */
    SELECT p_Resultado AS Resultado, p_Mensaje AS Mensaje
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_pago_mensualidades_estudiante;

DROP PROCEDURE IF EXISTS usp_plan_listar;

DROP PROCEDURE IF EXISTS usp_plan_listar;

DELIMITER $$

CREATE PROCEDURE usp_plan_listar(
    IN p_Buscar VARCHAR(200),
    IN p_Estado VARCHAR(50),
    IN p_OrdenarPor VARCHAR(50),
    IN p_Direccion VARCHAR(4),
    IN p_Pagina INT,
    IN p_TamanioPagina INT,
    OUT p_TotalRegistros INT
)
main: BEGIN
IF p_Pagina < 1 THEN SET p_Pagina = 1; END IF;
    IF p_TamanioPagina < 1 THEN SET p_TamanioPagina = 10; END IF;

    SELECT COUNT(*) INTO p_TotalRegistros
    FROM [PLAN] p
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           p.IDPLAN      LIKE CONCAT('%', p_Buscar, '%') OR
           p.NOMBRE      LIKE CONCAT('%', p_Buscar, '%') OR
           p.DESCRIPCION LIKE CONCAT('%', p_Buscar, '%'))
      AND (p_Estado IS NULL OR p_Estado = '' OR
           (p_Estado = 'Activo' AND p.ACTIVO = 1) OR
           (p_Estado = 'Inactivo' AND p.ACTIVO = 0));

    SELECT
        p.IDPLAN,
        p.NOMBRE,
        p.DESCRIPCION,
        p.COSTOMENSUAL,
        p.DIASASISTENCIA,
        CASE WHEN p.ACTIVO = 1 THEN 'Activo' ELSE 'Inactivo' END AS ESTADO
    FROM [PLAN] p
    WHERE (p_Buscar IS NULL OR p_Buscar = '' OR
           p.IDPLAN      LIKE CONCAT('%', p_Buscar, '%') OR
           p.NOMBRE      LIKE CONCAT('%', p_Buscar, '%') OR
           p.DESCRIPCION LIKE CONCAT('%', p_Buscar, '%'))
      AND (p_Estado IS NULL OR p_Estado = '' OR
           (p_Estado = 'Activo' AND p.ACTIVO = 1) OR
           (p_Estado = 'Inactivo' AND p.ACTIVO = 0))
    ORDER BY
        CASE WHEN p_OrdenarPor = 'IDPLAN' AND p_Direccion = 'ASC'  THEN p.IDPLAN END ASC,
        CASE WHEN p_OrdenarPor = 'IDPLAN' AND p_Direccion = 'DESC' THEN p.IDPLAN END DESC,
        CASE WHEN p_OrdenarPor = 'NOMBRE' AND p_Direccion = 'ASC'  THEN p.NOMBRE END ASC,
        CASE WHEN p_OrdenarPor = 'NOMBRE' AND p_Direccion = 'DESC' THEN p.NOMBRE END DESC,
        CASE WHEN p_OrdenarPor = 'COSTOMENSUAL' AND p_Direccion = 'ASC'  THEN p.COSTOMENSUAL END ASC,
        CASE WHEN p_OrdenarPor = 'COSTOMENSUAL' AND p_Direccion = 'DESC' THEN p.COSTOMENSUAL END DESC,
        CASE WHEN p_OrdenarPor = 'ESTADO' AND p_Direccion = 'ASC'  THEN p.ACTIVO END ASC,
        CASE WHEN p_OrdenarPor = 'ESTADO' AND p_Direccion = 'DESC' THEN p.ACTIVO END DESC,
        p.NOMBRE
    LIMIT p_TamanioPagina OFFSET ((p_Pagina - 1) * p_TamanioPagina);
    SELECT p_TotalRegistros AS TotalRegistros
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_plan_obtener;

DROP PROCEDURE IF EXISTS usp_plan_obtener;

DELIMITER $$

CREATE PROCEDURE usp_plan_obtener(
    IN p_Id VARCHAR(50)
)
main: BEGIN
SELECT
        p.IDPLAN,
        p.NOMBRE,
        p.DESCRIPCION,
        p.COSTOMENSUAL,
        p.DIASASISTENCIA,
        CASE WHEN p.ACTIVO = 1 THEN 'Activo' ELSE 'Inactivo' END AS ESTADO
    FROM [PLAN] p
    WHERE p.IDPLAN = p_Id;
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_plan_insertar;

DROP PROCEDURE IF EXISTS usp_plan_insertar;

DELIMITER $$

CREATE PROCEDURE usp_plan_insertar(
    IN p_Id VARCHAR(50),
    IN p_Nombre VARCHAR(100),
    IN p_Descripcion VARCHAR(255),
    IN p_CostoMensual DECIMAL(10,2),
    IN p_DiasAsistencia TINYINT,
    IN p_Estado VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
IF p_Id IS NULL OR TRIM(p_Id)) = ''
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'Ingresa el código del plan.'; LEAVE main; 
    IF p_Nombre IS NULL OR TRIM(p_Nombre)) = ''
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'Ingresa el nombre del plan.'; LEAVE main; 
    IF p_CostoMensual IS NOT NULL AND p_CostoMensual < 0
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'El costo mensual no puede ser negativo.'; LEAVE main; 
    IF p_DiasAsistencia IS NULL OR p_DiasAsistencia = 0 THEN SET p_DiasAsistencia = 63; END IF;

    IF EXISTS (SELECT 1 FROM [PLAN] WHERE IDPLAN = p_Id)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'El código de plan ya existe.'; LEAVE main; 
    IF EXISTS (SELECT 1 FROM [PLAN] WHERE NOMBRE = p_Nombre)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'Ya existe un plan con ese nombre.'; LEAVE main; 
    INSERT INTO [PLAN] (IDPLAN, NOMBRE, DESCRIPCION, COSTOMENSUAL, DIASASISTENCIA, ACTIVO)
    VALUES (
        p_Id,
        p_Nombre,
        p_Descripcion,
        p_CostoMensual,
        p_DiasAsistencia,
        CASE WHEN p_Estado = 'Activo' THEN 1 ELSE 0 
    );

    SET p_Resultado = 1; SET p_Mensaje = 'Plan registrado.';
    SELECT p_Resultado AS Resultado, p_Mensaje AS Mensaje
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_plan_actualizar;

DROP PROCEDURE IF EXISTS usp_plan_actualizar;

DELIMITER $$

CREATE PROCEDURE usp_plan_actualizar(
    IN p_Id VARCHAR(50),
    IN p_Nombre VARCHAR(100),
    IN p_Descripcion VARCHAR(255),
    IN p_CostoMensual DECIMAL(10,2),
    IN p_DiasAsistencia TINYINT,
    IN p_Estado VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
IF NOT EXISTS (SELECT 1 FROM [PLAN] WHERE IDPLAN = p_Id)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'El plan no existe.'; LEAVE main; 
    IF p_Nombre IS NULL OR TRIM(p_Nombre)) = ''
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'Ingresa el nombre del plan.'; LEAVE main; 
    IF p_CostoMensual IS NOT NULL AND p_CostoMensual < 0
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'El costo mensual no puede ser negativo.'; LEAVE main; 
    IF p_DiasAsistencia IS NULL OR p_DiasAsistencia = 0 THEN SET p_DiasAsistencia = 63; END IF;

    IF EXISTS (SELECT 1 FROM [PLAN] WHERE NOMBRE = p_Nombre AND IDPLAN <> p_Id)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'Ya existe un plan con ese nombre.'; LEAVE main; 
    UPDATE [PLAN] SET
        NOMBRE          = p_Nombre,
        DESCRIPCION     = p_Descripcion,
        COSTOMENSUAL    = p_CostoMensual,
        DIASASISTENCIA  = p_DiasAsistencia,
        ACTIVO          = CASE WHEN p_Estado = 'Activo' THEN 1 ELSE 0 
    WHERE IDPLAN = p_Id;

    SET p_Resultado = 1; SET p_Mensaje = 'Plan actualizado.';
    SELECT p_Resultado AS Resultado, p_Mensaje AS Mensaje
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_asistencia_informe;

DROP PROCEDURE IF EXISTS usp_asistencia_informe;

DELIMITER $$

CREATE PROCEDURE usp_asistencia_informe(
    IN p_FechaDesde CHAR(8),
    IN p_FechaHasta CHAR(8),
    IN p_Buscar VARCHAR(200),
    IN p_IDPlan VARCHAR(20),
    IN p_EstadoUsuario VARCHAR(50)
)
main: BEGIN
IF p_FechaDesde IS NULL OR p_FechaDesde = '' OR p_FechaHasta IS NULL OR p_FechaHasta = ''
    BEGIN
        RAISERROR('Debe indicar fecha desde y fecha hasta.', 16, 1);
        LEAVE main;
    
    IF p_FechaDesde > p_FechaHasta
    BEGIN
        RAISERROR('La fecha desde no puede ser mayor que la fecha hasta.', 16, 1);
        LEAVE main;
    
    SELECT
        u.IDUSUARIO,
        UPPER(TRIM(
            CONCAT(IFNULL(u.APELLIDO, ''), ' ') + IFNULL(u.NOMBRE, '')
        ))) AS NOMBRE_COMPLETO,
        UPPER(IFNULL(u.ESTADO, 'Activo')) AS ESTADO,
        UPPER(IFNULL(tut.NOMBRE, '')) AS TUTORA,
        IFNULL(au.NOMBRE, '') AS AULA,
        UPPER(TRIM(
            IFNULL(pl.NOMBRE, '') +
            CASE WHEN tu.DESCRIPCION IS NOT NULL AND tu.DESCRIPCION <> ''
                 THEN ' ' + tu.DESCRIPCION ELSE '' 
        ))) AS CICLO,
        mem.FECHAINICIO AS FECHA_INICIO_MEM,
        mem.FECHAFIN AS FECHA_VENCE,
        mem.IDPLAN,
        IFNULL(pl.DIASASISTENCIA, 63) AS DIASASISTENCIA
    FROM USUARIO u
    OUTER APPLY (
        SELECT TOP 1 m.IDAULA, m.IDPLAN, m.IDTURNO, m.FECHAINICIO, m.FECHAFIN
        FROM MENSUALIDAD m
        WHERE m.IDUSUARIO = u.IDUSUARIO
          AND (m.ESTADO IS NULL OR m.ESTADO = 'Activo')
        ORDER BY
            CASE
                WHEN (m.FECHAINICIO IS NULL OR m.FECHAINICIO <= p_FechaHasta)
                 AND (m.FECHAFIN IS NULL OR m.FECHAFIN >= p_FechaDesde)
                THEN 0 ELSE 1
            END,
            m.FECHAREGISTRO DESC,
            m.FECHAINICIO DESC
    ) mem
    LEFT JOIN AULA au ON au.IDAULA = mem.IDAULA
    LEFT JOIN USUARIO tut ON tut.IDUSUARIO = au.IDTUTORA
    LEFT JOIN [PLAN] pl ON pl.IDPLAN = mem.IDPLAN
    LEFT JOIN TURNO tu ON tu.IDTURNO = mem.IDTURNO
    WHERE u.IDTIPOUSUARIO = '1'
      AND (
          p_EstadoUsuario IS NULL OR p_EstadoUsuario = '' OR
          UPPER(IFNULL(u.ESTADO, 'Activo')) = UPPER(p_EstadoUsuario)
      )
      AND (
          p_IDPlan IS NULL OR p_IDPlan = '' OR mem.IDPLAN = p_IDPlan
      )
      AND (
          p_Buscar IS NULL OR p_Buscar = '' OR
          u.DNI LIKE CONCAT('%', p_Buscar, '%') OR
          u.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
          u.APELLIDO LIKE CONCAT('%', p_Buscar, '%') OR
          u.IDUSUARIO LIKE CONCAT('%', p_Buscar, '%') OR
          IFNULL(au.NOMBRE, '') LIKE CONCAT('%', p_Buscar, '%')
      )
    ORDER BY u.APELLIDO, u.NOMBRE;

    SELECT
        a.IDUSUARIO,
        a.FECHAREGISTRO,
        a.ESTADO,
        a.JUSTIFICADO
    FROM ASISTENCIA a
    INNER JOIN USUARIO u ON u.IDUSUARIO = a.IDUSUARIO
    WHERE u.IDTIPOUSUARIO = '1'
      AND a.FECHAREGISTRO >= p_FechaDesde
      AND a.FECHAREGISTRO <= p_FechaHasta
      AND (
          p_EstadoUsuario IS NULL OR p_EstadoUsuario = '' OR
          UPPER(IFNULL(u.ESTADO, 'Activo')) = UPPER(p_EstadoUsuario)
      )
      AND (
          p_IDPlan IS NULL OR p_IDPlan = '' OR
          EXISTS (
              SELECT 1
              FROM MENSUALIDAD m
              WHERE m.IDUSUARIO = u.IDUSUARIO
                AND m.IDPLAN = p_IDPlan
                AND (m.ESTADO IS NULL OR m.ESTADO = 'Activo')
                AND (m.FECHAINICIO IS NULL OR m.FECHAINICIO <= p_FechaHasta)
                AND (m.FECHAFIN IS NULL OR m.FECHAFIN >= p_FechaDesde)
          )
      )
      AND (
          p_Buscar IS NULL OR p_Buscar = '' OR
          u.DNI LIKE CONCAT('%', p_Buscar, '%') OR
          u.NOMBRE LIKE CONCAT('%', p_Buscar, '%') OR
          u.APELLIDO LIKE CONCAT('%', p_Buscar, '%') OR
          u.IDUSUARIO LIKE CONCAT('%', p_Buscar, '%')
      );
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_plan_eliminar;

DROP PROCEDURE IF EXISTS usp_plan_eliminar;

DELIMITER $$

CREATE PROCEDURE usp_plan_eliminar(
    IN p_Id VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
IF NOT EXISTS (SELECT 1 FROM [PLAN] WHERE IDPLAN = p_Id)
    BEGIN SET p_Resultado = 0; SET p_Mensaje = 'El plan no existe.'; LEAVE main; 
    IF EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDPLAN = p_Id)
    BEGIN
        SET p_Resultado = 0;
        SET p_Mensaje = 'No se puede eliminar: el plan tiene mensualidads asociadas.';
        LEAVE main;
    
    DELETE FROM [PLAN] WHERE IDPLAN = p_Id;

    SET p_Resultado = 1; SET p_Mensaje = 'Plan eliminado.';
    SELECT p_Resultado AS Resultado, p_Mensaje AS Mensaje
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_aula_eliminar;

DROP PROCEDURE IF EXISTS usp_aula_eliminar;

DELIMITER $$

CREATE PROCEDURE usp_aula_eliminar(
    IN p_Id VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
IF NOT EXISTS (SELECT 1 FROM AULA WHERE IDAULA = p_Id)
    BEGIN
        SET p_Resultado = 0; SET p_Mensaje = 'El aula no existe.';
        LEAVE main;
    
    IF EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDAULA = p_Id)
    BEGIN
        SET p_Resultado = 0;
        SET p_Mensaje = 'No se puede eliminar: el aula tiene mensualidads asociadas.';
        LEAVE main;
    
    DELETE FROM AULA WHERE IDAULA = p_Id;

    SET p_Resultado = 1; SET p_Mensaje = 'Aula eliminada.';
END;

/* ============================================================================
   Exámenes — flujo estudiante (listar / iniciar / pregunta / responder / finalizar)
   Ejecutar después de 2.usp_examen_crud.sql
   Fecha: 17/07/2026
   ============================================================================ */

/* Helper inline: ddmmyyyy + hora → DATETIME */
/* Uso: dbo no tiene fn; se repite patrón TRY_CONVERT */
    SELECT p_Resultado AS Resultado, p_Mensaje AS Mensaje
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_examen_estudiante_listar;

DROP PROCEDURE IF EXISTS usp_examen_estudiante_listar;

DELIMITER $$

CREATE PROCEDURE usp_examen_estudiante_listar(
    IN p_IdUsuario VARCHAR(50)
)
main: BEGIN
IF p_IdUsuario IS NULL OR TRIM(p_IdUsuario)) = ''
    BEGIN
        SELECT CAST(NULL AS VARCHAR(50)) AS IDEXAMEN WHERE 1 = 0;
        LEAVE main;
    
    DECLARE v_Ahora DATETIME = NOW();
    DECLARE v_IdAula VARCHAR(50) = NULL;

    SELECT TOP 1 v_IdAula = m.IDAULA
    FROM MENSUALIDAD m
    WHERE m.IDUSUARIO = p_IdUsuario
      AND (m.ESTADOMIEMBRO IS NULL OR m.ESTADOMIEMBRO <> 3)
    ORDER BY m.FECHAREGISTRO DESC, m.IDMENSUALIDAD DESC;

    ;WITH Base AS (
        SELECT
            e.IDEXAMEN,
            e.TITULO,
            e.DESCRIPCION,
            e.TIPO,
            e.DURACIONMIN,
            e.FECHAINICIO,
            e.FECHAFIN,
            e.HORAINICIO,
            e.HORAFIN,
            e.INTENTOSMAX,
            e.VISIBLE,
            IFNULL(e.TODASLASULA, 1) AS TODASLASULA,
            IFNULL(e.PUNTAJETOTAL, 0) AS PUNTAJETOTAL,
            (SELECT COUNT(*) FROM PREGUNTA p WHERE p.IDEXAMEN = e.IDEXAMEN) AS CANTPREGUNTAS,
            TRY_CONVERT(DATETIME,
                SUBSTRING(e.FECHAINICIO, 5, 4) + '-' + SUBSTRING(e.FECHAINICIO, 3, 2) + '-' + SUBSTRING(e.FECHAINICIO, 1, 2)
                + ' ' + LEFT(IFNULL(NULLIF(RTRIM(e.HORAINICIO), ''), '00:00:00') + '00', 8),
                120) AS DT_INICIO,
            TRY_CONVERT(DATETIME,
                SUBSTRING(e.FECHAFIN, 5, 4) + '-' + SUBSTRING(e.FECHAFIN, 3, 2) + '-' + SUBSTRING(e.FECHAFIN, 1, 2)
                + ' ' + LEFT(IFNULL(NULLIF(RTRIM(e.HORAFIN), ''), '23:59:59') + '00', 8),
                120) AS DT_FIN
        FROM EXAMEN e
        WHERE e.VISIBLE = 1
          AND (SELECT COUNT(*) FROM PREGUNTA p WHERE p.IDEXAMEN = e.IDEXAMEN) > 0
          AND (
                IFNULL(e.TODASLASULA, 1) = 1
                OR EXISTS (
                    SELECT 1 FROM EXAMEN_AULA ea
                    WHERE ea.IDEXAMEN = e.IDEXAMEN
                      AND ea.IDAULA = v_IdAula
                )
              )
    )
    SELECT
        b.IDEXAMEN,
        b.TITULO,
        b.DESCRIPCION,
        b.TIPO,
        b.DURACIONMIN,
        b.FECHAINICIO,
        b.FECHAFIN,
        b.HORAINICIO,
        b.HORAFIN,
        b.INTENTOSMAX,
        b.CANTPREGUNTAS,
        b.PUNTAJETOTAL,
        CASE
            WHEN b.DT_INICIO IS NOT NULL AND v_Ahora < b.DT_INICIO THEN 'proximamente'
            WHEN b.DT_FIN IS NOT NULL AND v_Ahora > b.DT_FIN THEN 'cerrado'
            ELSE 'disponible'
        END AS ESTADOEXAMEN,
        IFNULL((
            SELECT COUNT(*)
            FROM INTENTO_EXAMEN i
            WHERE i.IDEXAMEN = b.IDEXAMEN
              AND i.IDUSUARIO = p_IdUsuario
              AND IFNULL(i.ESTADO, 0) = 1
        ), 0) AS INTENTOSFINALIZADOS,
        (
            SELECT TOP 1 i.IDINTENTOEXAMEN
            FROM INTENTO_EXAMEN i
            WHERE i.IDEXAMEN = b.IDEXAMEN
              AND i.IDUSUARIO = p_IdUsuario
              AND IFNULL(i.ESTADO, 0) = 0
            ORDER BY i.NUMEROINTENTO DESC
        ) AS IDINTENTOENCURSO,
        (
            SELECT TOP 1 i.PUNTAJEOBTENIDO
            FROM INTENTO_EXAMEN i
            WHERE i.IDEXAMEN = b.IDEXAMEN
              AND i.IDUSUARIO = p_IdUsuario
              AND IFNULL(i.ESTADO, 0) = 1
            ORDER BY i.NUMEROINTENTO DESC
        ) AS ULTIMOPUNTAJE,
        CASE
            WHEN EXISTS (
                SELECT 1 FROM INTENTO_EXAMEN i
                WHERE i.IDEXAMEN = b.IDEXAMEN
                  AND i.IDUSUARIO = p_IdUsuario
                  AND IFNULL(i.ESTADO, 0) = 0
            ) THEN 'continuar'
            WHEN (
                SELECT COUNT(*) FROM INTENTO_EXAMEN i
                WHERE i.IDEXAMEN = b.IDEXAMEN
                  AND i.IDUSUARIO = p_IdUsuario
                  AND IFNULL(i.ESTADO, 0) = 1
            ) >= IFNULL(NULLIF(b.INTENTOSMAX, 0), 1)
            THEN 'agotado'
            WHEN b.DT_INICIO IS NOT NULL AND v_Ahora < b.DT_INICIO THEN 'proximamente'
            WHEN b.DT_FIN IS NOT NULL AND v_Ahora > b.DT_FIN THEN 'cerrado'
            ELSE 'desarrollar'
        END AS ACCION
    FROM Base b
    ORDER BY
        CASE
            WHEN b.DT_INICIO IS NOT NULL AND v_Ahora < b.DT_INICIO THEN 2
            WHEN b.DT_FIN IS NOT NULL AND v_Ahora > b.DT_FIN THEN 3
            ELSE 1
        END,
        b.DT_INICIO DESC,
        b.TITULO;
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS usp_examen_intento_iniciar;

DROP PROCEDURE IF EXISTS usp_examen_intento_iniciar;

DELIMITER $$

CREATE PROCEDURE usp_examen_intento_iniciar(
    IN p_IdExamen VARCHAR(50),
    IN p_IdUsuario VARCHAR(50),
    OUT p_IdIntento VARCHAR(50),
    OUT p_Resultado INT,
    OUT p_Mensaje VARCHAR(200)
)
main: BEGIN
SET p_IdIntento = NULL;
    SET p_Resultado = 0;
    SET p_Mensaje = 'Error desconocido.';

    IF p_IdExamen IS NULL OR p_IdUsuario IS NULL
    BEGIN SET p_Mensaje = 'Datos incompletos.'; LEAVE main; 
    IF NOT EXISTS (SELECT 1 FROM USUARIO WHERE IDUSUARIO = p_IdUsuario)
    BEGIN SET p_Mensaje = 'Usuario no válido.'; LEAVE main; 
    DECLARE v_Visible TINYINT(1), @Todas TINYINT(1), @IntentosMax INT, @Duracion INT;
    DECLARE v_Fi CHAR(8), @Ff CHAR(8), @Hi CHAR(8), @Hf CHAR(8);

    SELECT e.VISIBLE, INTO v_Visible
        @Todas = IFNULL(e.TODASLASULA, 1),
        @IntentosMax = IFNULL(NULLIF(e.INTENTOSMAX, 0), 1),
        @Duracion = e.DURACIONMIN,
        v_Fi = e.FECHAINICIO,
        @Ff = e.FECHAFIN,
        @Hi = e.HORAINICIO,
        @Hf = e.HORAFIN
    FROM EXAMEN e
    WHERE e.IDEXAMEN = p_IdExamen;

    IF v_Visible IS NULL
    BEGIN SET p_Mensaje = 'El examen no existe.'; LEAVE main; 
    IF v_Visible <> 1
    BEGIN SET p_Mensaje = 'El examen no está visible.'; LEAVE main; 
    IF NOT EXISTS (SELECT 1 FROM PREGUNTA WHERE IDEXAMEN = p_IdExamen)
    BEGIN SET p_Mensaje = 'El examen no tiene preguntas.'; LEAVE main; 
    DECLARE v_IdAula VARCHAR(50) = NULL;
    SELECT TOP 1 v_IdAula = m.IDAULA
    FROM MENSUALIDAD m
    WHERE m.IDUSUARIO = p_IdUsuario
      AND (m.ESTADOMIEMBRO IS NULL OR m.ESTADOMIEMBRO <> 3)
    ORDER BY m.FECHAREGISTRO DESC, m.IDMENSUALIDAD DESC;

    IF @Todas = 0 AND NOT EXISTS (
        SELECT 1 FROM EXAMEN_AULA ea
        WHERE ea.IDEXAMEN = p_IdExamen AND ea.IDAULA = v_IdAula
    )
    BEGIN SET p_Mensaje = 'No tienes acceso a este examen (aula).'; LEAVE main; 
    DECLARE v_Ahora DATETIME = NOW();
    DECLARE v_DT_INICIO DATETIME = TRY_CONVERT(DATETIME,
        SUBSTRING(v_Fi, 5, 4) + '-' + SUBSTRING(v_Fi, 3, 2) + '-' + SUBSTRING(v_Fi, 1, 2)
        + ' ' + LEFT(IFNULL(NULLIF(RTRIM(@Hi), ''), '00:00:00') + '00', 8), 120);
    DECLARE v_DT_FIN DATETIME = TRY_CONVERT(DATETIME,
        SUBSTRING(@Ff, 5, 4) + '-' + SUBSTRING(@Ff, 3, 2) + '-' + SUBSTRING(@Ff, 1, 2)
        + ' ' + LEFT(IFNULL(NULLIF(RTRIM(@Hf), ''), '23:59:59') + '00', 8), 120);

    IF v_DT_INICIO IS NOT NULL AND v_Ahora < v_DT_INICIO
    BEGIN SET p_Mensaje = 'El examen aún no está disponible.'; LEAVE main; 
    IF v_DT_FIN IS NOT NULL AND v_Ahora > v_DT_FIN
    BEGIN SET p_Mensaje = 'El examen ya cerró.'; LEAVE main; 
    -- Reanudar intento en curso
    SELECT TOP 1 p_IdIntento = i.IDINTENTOEXAMEN
    FROM INTENTO_EXAMEN i
    WHERE i.IDEXAMEN = p_IdExamen
      AND i.IDUSUARIO = p_IdUsuario
      AND IFNULL(i.ESTADO, 0) = 0
    ORDER BY i.NUMEROINTENTO DESC;

    IF p_IdIntento IS NOT NULL
    BEGIN
        SET p_Resultado = 1;
        SET p_Mensaje = 'Intento en curso reanudado.';
        LEAVE main;
    
    DECLARE v_Finalizados INT = (
        SELECT COUNT(*) FROM INTENTO_EXAMEN
        WHERE IDEXAMEN = p_IdExamen AND IDUSUARIO = p_IdUsuario AND IFNULL(ESTADO, 0) = 1
    );
    IF v_Finalizados >= @IntentosMax
    BEGIN SET p_Mensaje = 'Ya usaste todos los intentos permitidos.'; LEAVE main; 
    DECLARE v_Num INT = v_Finalizados + 1;
    DECLARE v_NextNum INT;
    SELECT IFNULL(MAX(CAST(REPLACE(IDINTENTOEXAMEN, 'INT', '') AS INT)), 0) + 1 INTO v_NextNum
    FROM INTENTO_EXAMEN WHERE IDINTENTOEXAMEN LIKE 'INT%';
    SET p_IdIntento = CONCAT('INT', RIGHT('00000' + CAST(v_NextNum AS VARCHAR(5)), 5);

    INSERT INTO INTENTO_EXAMEN (
        IDINTENTOEXAMEN, NUMEROINTENTO,
        FECHAINICIO, HORAINICIO,
        PUNTAJEOBTENIDO, CANTCORRECTAS, CANTINCORRECTAS, CANTSINRESPONDER,
        ESTADO, APROBADO, IDEXAMEN, IDUSUARIO
    )
    VALUES (
        p_IdIntento, v_Num,
        fn_fecha_ddmmyyyy(), TIME_FORMAT(NOW(), '%H:%i:%s'),
        NULL, 0, 0, 0,
        0, NULL, p_IdExamen, p_IdUsuario
    );

    SET p_Resultado = 1;
    SET p_Mensaje = 'Intento iniciado.';
END;

SELECT 'Renombrado MEMBRESIA/ASESOR -> MENSUALIDAD/TUTOR completado.';
    SELECT p_IdIntento AS IdIntento, p_Resultado AS Resultado, p_Mensaje AS Mensaje
END$$

DELIMITER ;
