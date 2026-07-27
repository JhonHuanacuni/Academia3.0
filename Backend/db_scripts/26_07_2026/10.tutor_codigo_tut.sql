/* ============================================================================
   TUTOR: códigos TUT001, TUT002… (renombrar ASE* heredados de ASESOR)
   Ejecutar después de 9.menu_tutores_asesores.sql
   Fecha: 26/07/2026
   ============================================================================ */

IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_MENSUALIDAD_TUTOR')
    ALTER TABLE MENSUALIDAD DROP CONSTRAINT FK_MENSUALIDAD_TUTOR;
GO

UPDATE m
SET m.IDTUTOR = 'TUT' + SUBSTRING(m.IDTUTOR, 4, 47)
FROM MENSUALIDAD m
WHERE m.IDTUTOR LIKE 'ASE%';
GO

UPDATE t
SET t.IDTUTOR = 'TUT' + SUBSTRING(t.IDTUTOR, 4, 47)
FROM TUTOR t
WHERE t.IDTUTOR LIKE 'ASE%';
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_MENSUALIDAD_TUTOR')
BEGIN
    ALTER TABLE MENSUALIDAD ADD CONSTRAINT FK_MENSUALIDAD_TUTOR
        FOREIGN KEY (IDTUTOR) REFERENCES TUTOR(IDTUTOR);
END
GO

IF OBJECT_ID('dbo.usp_tutor_insertar', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_tutor_insertar;
GO
CREATE PROCEDURE dbo.usp_tutor_insertar
    @Id        NVARCHAR(50)  = NULL,
    @Nombre    NVARCHAR(150),
    @Estado    NVARCHAR(50)  = 'Activo',
    @Resultado INT OUTPUT,
    @Mensaje   NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF @Nombre IS NULL OR LTRIM(RTRIM(@Nombre)) = ''
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ingresa el nombre del tutor.'; RETURN; END

    IF @Id IS NULL OR LTRIM(RTRIM(@Id)) = ''
    BEGIN
        DECLARE @Next INT = ISNULL((
            SELECT MAX(TRY_CAST(SUBSTRING(IDTUTOR, 4, 10) AS INT))
            FROM TUTOR WHERE IDTUTOR LIKE 'TUT%'
        ), 0) + 1;
        SET @Id = 'TUT' + RIGHT('000' + CAST(@Next AS VARCHAR(10)), 3);
    END

    SET @Id = UPPER(LTRIM(RTRIM(@Id)));

    IF @Id NOT LIKE 'TUT[0-9]%'
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El código debe ser TUT seguido del número (ej. TUT001).'; RETURN; END

    IF EXISTS (SELECT 1 FROM TUTOR WHERE IDTUTOR = @Id)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'El código de tutor ya existe.'; RETURN; END

    IF EXISTS (SELECT 1 FROM TUTOR WHERE NOMBRE = @Nombre)
    BEGIN SET @Resultado = 0; SET @Mensaje = 'Ya existe un tutor con ese nombre.'; RETURN; END

    INSERT INTO TUTOR (IDTUTOR, NOMBRE, ACTIVO)
    VALUES (@Id, @Nombre, CASE WHEN @Estado = 'Activo' THEN 1 ELSE 0 END);

    SET @Resultado = 1; SET @Mensaje = 'Tutor registrado.';
END;
GO

PRINT 'TUTOR: códigos ASE* → TUT* y usp_tutor_insertar actualizado.';
GO
