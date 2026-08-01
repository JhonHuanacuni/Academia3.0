-- Convertido automáticamente desde db_scripts/31_07_2026/5.importar_usuarios_otros_roles.sql
-- MySQL 8 — Academia 3.0

USE `AcademiaDB`;

/* ============================================================================
   IMPORTACIÓN USUARIOS — roles SECRETARIO y ADMIN
   Total registros: 9 (4 secretarios + 5 admins)
   Mapeo: SECRETARIO -> @IdTipoUsuario '2' (Docente)
          ADMIN      -> @IdTipoUsuario '3' (Administrador)
   Contraseña inicial: DNI
   Emails duplicados en estudiantes.txt -> {dni}@import.academia.local
   Ejecutar después de 1.importar_estudiantes.sql
   Fecha: 31/07/2026
   ============================================================================ */

-- [1/9] ADMIN — JESÚS SALINAS (DNI 10033907)
DECLARE @R INT, @M VARCHAR(200);
EXEC usp_usuario_insertar
    @Id                 = N'10033907',
    @Contra             = N'10033907',
    @Nombre             = N'JESÚS',
    @Apellido           = N'SALINAS',
    @Dni                = N'10033907',
    @Email              = N'10033907@import.academia.local',
    @IdTipoUsuario      = N'3',
    @Estado             = N'Activo',
    @FechaNacimiento    = NULL,
    @Direccion          = NULL,
    @Distrito           = NULL,
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'927661702',
    @TelApoderado       = NULL,
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = NULL,
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/89c89b66-ba1d-4bab-8e1e-5b98e2e796d9_perfil.jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 SELECT CONCAT('OK DNI 10033907: ', @M); 

-- [2/9] ADMIN — FREDY ALFARO CHAVEZ ASESOR ACADEMICO (DNI 41591259)
DECLARE @R INT, @M VARCHAR(200);
EXEC usp_usuario_insertar
    @Id                 = N'41591259',
    @Contra             = N'41591259',
    @Nombre             = N'FREDY ALFARO CHAVEZ',
    @Apellido           = N'ASESOR ACADEMICO',
    @Dni                = N'41591259',
    @Email              = N'fredy@gmail.com',
    @IdTipoUsuario      = N'3',
    @Estado             = N'Activo',
    @FechaNacimiento    = NULL,
    @Direccion          = NULL,
    @Distrito           = NULL,
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = NULL,
    @TelApoderado       = NULL,
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = NULL,
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/b5b34592-50ff-4211-9bfa-efa0036a0e96_perfil.jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 SELECT CONCAT('OK DNI 41591259: ', @M); 

-- [3/9] ADMIN — VICTOR ARGENIS MORALES ALFARO (DNI 47047653)
DECLARE @R INT, @M VARCHAR(200);
EXEC usp_usuario_insertar
    @Id                 = N'47047653',
    @Contra             = N'47047653',
    @Nombre             = N'VICTOR ARGENIS',
    @Apellido           = N'MORALES ALFARO',
    @Dni                = N'47047653',
    @Email              = N'VMORALESAL@GMAIL.COM',
    @IdTipoUsuario      = N'3',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'30121991',
    @Direccion          = NULL,
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'989842351',
    @TelApoderado       = N'922635340',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = NULL,
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 SELECT CONCAT('OK DNI 47047653: ', @M); 

-- [4/9] ADMIN — AXEL TURPO ALFARO (DNI 72618032)
DECLARE @R INT, @M VARCHAR(200);
EXEC usp_usuario_insertar
    @Id                 = N'72618032',
    @Contra             = N'72618032',
    @Nombre             = N'AXEL',
    @Apellido           = N'TURPO ALFARO',
    @Dni                = N'72618032',
    @Email              = N'axelturpoalfaro7@gmail.com',
    @IdTipoUsuario      = N'3',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'06111997',
    @Direccion          = N'REPÚBLICA FEDERAL ALEMANA MZ "E" LT "43"',
    @Distrito           = NULL,
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'926570030',
    @TelApoderado       = N'926570030',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = NULL,
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/252fa342-eb9b-4810-800a-d842a0f54eb2_imagenprueba.png',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 SELECT CONCAT('OK DNI 72618032: ', @M); 

-- [5/9] ADMIN — TABELICKT RIOS SALINAS (DNI 74806861)
DECLARE @R INT, @M VARCHAR(200);
EXEC usp_usuario_insertar
    @Id                 = N'74806861',
    @Contra             = N'74806861',
    @Nombre             = N'TABELICKT',
    @Apellido           = N'RIOS SALINAS',
    @Dni                = N'74806861',
    @Email              = N'tabelickt@gmail.com',
    @IdTipoUsuario      = N'3',
    @Estado             = N'Activo',
    @FechaNacimiento    = NULL,
    @Direccion          = NULL,
    @Distrito           = NULL,
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = NULL,
    @TelApoderado       = NULL,
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = NULL,
    @ComoEntero         = NULL,
    @Foto               = NULL,
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 SELECT CONCAT('OK DNI 74806861: ', @M); 

-- [6/9] SECRETARIO — FERNANDA MORALES VASQUEZ (DNI 73878120)
DECLARE @R INT, @M VARCHAR(200);
EXEC usp_usuario_insertar
    @Id                 = N'73878120',
    @Contra             = N'73878120',
    @Nombre             = N'FERNANDA',
    @Apellido           = N'MORALES VASQUEZ',
    @Dni                = N'73878120',
    @Email              = N'fernandamrls47@hotmail.com',
    @IdTipoUsuario      = N'2',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'26082004',
    @Direccion          = NULL,
    @Distrito           = NULL,
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'919499187',
    @TelApoderado       = NULL,
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = NULL,
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/3648b9bf-b591-4d47-a951-528a0ea99a25_xd.png',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 SELECT CONCAT('OK DNI 73878120: ', @M); 

-- [7/9] SECRETARIO — CAMILA MIA TELLO CAÑARI (DNI 74176216)
DECLARE @R INT, @M VARCHAR(200);
EXEC usp_usuario_insertar
    @Id                 = N'74176216',
    @Contra             = N'74176216',
    @Nombre             = N'CAMILA MIA',
    @Apellido           = N'TELLO CAÑARI',
    @Dni                = N'74176216',
    @Email              = N'CAMILAMIAALEJANDRAMARIANA@GMAIL.COM',
    @IdTipoUsuario      = N'2',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'05101997',
    @Direccion          = NULL,
    @Distrito           = NULL,
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'984738440',
    @TelApoderado       = NULL,
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = NULL,
    @ComoEntero         = NULL,
    @Foto               = NULL,
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 SELECT CONCAT('OK DNI 74176216: ', @M); 

-- [8/9] SECRETARIO — SARA HUAMAN SALINAS (DNI 74806860)
DECLARE @R INT, @M VARCHAR(200);
EXEC usp_usuario_insertar
    @Id                 = N'74806860',
    @Contra             = N'74806860',
    @Nombre             = N'SARA',
    @Apellido           = N'HUAMAN SALINAS',
    @Dni                = N'74806860',
    @Email              = N'huamansalinassara8@gmail.com',
    @IdTipoUsuario      = N'2',
    @Estado             = N'Activo',
    @FechaNacimiento    = NULL,
    @Direccion          = NULL,
    @Distrito           = NULL,
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = NULL,
    @TelApoderado       = NULL,
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = NULL,
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/19bcf632-31f8-49bb-97f6-f3caad3cd5a2_Retrato en primer plano de joven mujer.png',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 SELECT CONCAT('OK DNI 74806860: ', @M); 

-- [9/9] SECRETARIO — FAIRUZ SILVIA RIOS ZAMBRANO (DNI 75234130)
DECLARE @R INT, @M VARCHAR(200);
EXEC usp_usuario_insertar
    @Id                 = N'75234130',
    @Contra             = N'75234130',
    @Nombre             = N'FAIRUZ SILVIA',
    @Apellido           = N'RIOS ZAMBRANO',
    @Dni                = N'75234130',
    @Email              = N'fairuzsilvia.17@icloud.com',
    @IdTipoUsuario      = N'2',
    @Estado             = N'Activo',
    @FechaNacimiento    = NULL,
    @Direccion          = N'sjm',
    @Distrito           = NULL,
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = NULL,
    @TelApoderado       = NULL,
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = NULL,
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/17a6d231-f792-45ea-8f5f-4730d51cd57a_fairuz.png',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 SELECT CONCAT('OK DNI 75234130: ', @M);
