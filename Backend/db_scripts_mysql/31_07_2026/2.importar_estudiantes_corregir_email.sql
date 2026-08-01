-- Convertido automáticamente desde db_scripts/31_07_2026/2.importar_estudiantes_corregir_email.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   CORRECCIÓN — 2 estudiantes con email duplicado en importación
   DNI 61759251: CARLOS@GMAIL.COM  -> 61759251@import.academia.local
   DNI 77732703: MARIA@GMAIL.COM   -> 77732703@import.academia.local
   Ejecutar después de 1.importar_estudiantes.sql
   Fecha: 31/07/2026
   ============================================================================ */

-- [1/2] CARLOS FARID SALAZAR CANCHAYA (DNI 61759251)
DECLARE @R INT, @M VARCHAR(200);
EXEC usp_usuario_insertar
    @Id                 = N'61759251',
    @Contra             = N'61759251',
    @Nombre             = N'CARLOS FARID',
    @Apellido           = N'SALAZAR CANCHAYA',
    @Dni                = N'61759251',
    @Email              = N'61759251@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'28032009',
    @Direccion          = N'AA.HH. VILLA SOLIDARIDAD  MZ  K  LT 02 - SJM',
    @Distrito           = N'SAN JUA DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'961568251',
    @TelApoderado       = N'947153621',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/affecc92-2504-40ed-ac50-c421350bf89c_5 (2).jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 SELECT CONCAT('OK DNI 61759251: ', @M); 

-- [2/2] MARIA STEPHANIE SOTO ALVINO (DNI 77732703)
DECLARE @R INT, @M VARCHAR(200);
EXEC usp_usuario_insertar
    @Id                 = N'77732703',
    @Contra             = N'77732703',
    @Nombre             = N'MARIA STEPHANIE',
    @Apellido           = N'SOTO ALVINO',
    @Dni                = N'77732703',
    @Email              = N'77732703@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'28062012',
    @Direccion          = N'MZ A LT 18 AMP VILLA SAN LUIS',
    @Distrito           = N'PAMPLONA ALTA',
    @Colegio            = N'SAN LUIS GONZAGA',
    @Grado              = N'2DO',
    @TelPersonal        = N'991511994',
    @TelApoderado       = N'991511994',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/13306b0a-fffe-4470-9168-4f5e9237947c_16.jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 SELECT CONCAT('OK DNI 77732703: ', @M);
