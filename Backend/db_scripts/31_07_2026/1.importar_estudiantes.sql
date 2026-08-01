/* ============================================================================
   IMPORTACIÓN ESTUDIANTES — desde estudiantes.txt
   Total registros: 318 (rol USUARIO)
   Ejecutar con usp_usuario_insertar (@IdTipoUsuario = '1' Estudiante)
   Contraseña inicial: DNI
   Emails duplicados en origen -> {dni}@import.academia.local
   Fecha: 31/07/2026
   ============================================================================ */

SET NOCOUNT ON;
GO

-- [1/318] CARMEN ELENA CAMARO PEREZ (DNI 02306330)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'02306330',
    @Contra             = N'02306330',
    @Nombre             = N'CARMEN ELENA',
    @Apellido           = N'CAMARO PEREZ',
    @Dni                = N'02306330',
    @Email              = N'camarocarmen09@gmail.com',
    @IdTipoUsuario      = N'1',
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
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/02c177a9-0ff1-440c-8676-55c989c805d9_ChatGPT Image 1 abr 2026, 04_18_40 p.m..png',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 02306330: ' + @M; ELSE PRINT 'ERROR DNI 02306330: ' + @M;
GO

-- [2/318] EDICER DEL VALLE TOCUYO MACIAS (DNI 06597413)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'06597413',
    @Contra             = N'06597413',
    @Nombre             = N'EDICER DEL VALLE',
    @Apellido           = N'TOCUYO MACIAS',
    @Dni                = N'06597413',
    @Email              = N'edicerdelvalletocuyomacias@gmail.com',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = NULL,
    @Direccion          = NULL,
    @Distrito           = NULL,
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'955352037',
    @TelApoderado       = NULL,
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = NULL,
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 06597413: ' + @M; ELSE PRINT 'ERROR DNI 06597413: ' + @M;
GO

-- [3/318] JOEL ENRIQUE ZAMORA OCHOA (DNI 06821701)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'06821701',
    @Contra             = N'06821701',
    @Nombre             = N'JOEL ENRIQUE',
    @Apellido           = N'ZAMORA OCHOA',
    @Dni                = N'06821701',
    @Email              = N'JOEL@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'06092008',
    @Direccion          = N'URB. RICARDO PALMA - PISO 5 DPTO 501 - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'953908374',
    @TelApoderado       = N'953908374',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/faa1631d-20cf-4852-ace9-221fa996c365_WhatsApp Image 2026-03-24 at 9.41.11 AM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 06821701: ' + @M; ELSE PRINT 'ERROR DNI 06821701: ' + @M;
GO

-- [4/318] MIRYAM PRADO MILLA (DNI 09489925)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'09489925',
    @Contra             = N'09489925',
    @Nombre             = N'MIRYAM',
    @Apellido           = N'PRADO MILLA',
    @Dni                = N'09489925',
    @Email              = N'miryamprado2203@gmail.com',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'22031970',
    @Direccion          = NULL,
    @Distrito           = NULL,
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'986416736',
    @TelApoderado       = NULL,
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/6add8c57-fd41-4efe-b7f5-d9a6639183be_MIRYAM PRADO.png',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 09489925: ' + @M; ELSE PRINT 'ERROR DNI 09489925: ' + @M;
GO

-- [5/318] LUÍS ALBERTO YACTAYO OJEDA (DNI 10234238)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'10234238',
    @Contra             = N'10234238',
    @Nombre             = N'LUÍS ALBERTO',
    @Apellido           = N'YACTAYO OJEDA',
    @Dni                = N'10234238',
    @Email              = N'layotraducciones@hotmail.com',
    @IdTipoUsuario      = N'1',
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
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/44a54caf-af3b-4a92-b504-4ee7b8ffd30f_LUIS.png',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 10234238: ' + @M; ELSE PRINT 'ERROR DNI 10234238: ' + @M;
GO

-- [6/318] CIRILO ALFONSO MAURICIO VERASTEGUI (DNI 10748993)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'10748993',
    @Contra             = N'10748993',
    @Nombre             = N'CIRILO ALFONSO',
    @Apellido           = N'MAURICIO VERASTEGUI',
    @Dni                = N'10748993',
    @Email              = N'cirilo_mauricio@hotmail.com',
    @IdTipoUsuario      = N'1',
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
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/e07fce7e-4cfd-4548-a4ff-19c4dd86ff33_CIRILO M.png',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 10748993: ' + @M; ELSE PRINT 'ERROR DNI 10748993: ' + @M;
GO

-- [7/318] ANTONY SAMIR CAÑARI CANGALAYA (DNI 22222222)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'22222222',
    @Contra             = N'22222222',
    @Nombre             = N'ANTONY SAMIR',
    @Apellido           = N'CAÑARI CANGALAYA',
    @Dni                = N'22222222',
    @Email              = N'ANTONY@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'10102010',
    @Direccion          = N'CHORRILLOS',
    @Distrito           = N'CHORRILLOS',
    @Colegio            = N'IEP CIRO ALEGRIA',
    @Grado              = N'5TO',
    @TelPersonal        = N'982634303',
    @TelApoderado       = N'982634303',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = NULL,
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 22222222: ' + @M; ELSE PRINT 'ERROR DNI 22222222: ' + @M;
GO

-- [8/318] SANTOS CLORINDA SANDOVAL RAMIREZ (DNI 41024168)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'41024168',
    @Contra             = N'41024168',
    @Nombre             = N'SANTOS CLORINDA',
    @Apellido           = N'SANDOVAL RAMIREZ',
    @Dni                = N'41024168',
    @Email              = N'SANTOSCLORINDASANDOVALRAMIREZ@GMAIL.COM',
    @IdTipoUsuario      = N'1',
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
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/13c5ff18-f69f-4494-ab3a-4e03e65001b7_SANTOS.png',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 41024168: ' + @M; ELSE PRINT 'ERROR DNI 41024168: ' + @M;
GO

-- [9/318] GIERALDINE MILAGROS LOPEZ BERNUY (DNI 41106202)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'41106202',
    @Contra             = N'41106202',
    @Nombre             = N'GIERALDINE MILAGROS',
    @Apellido           = N'LOPEZ BERNUY',
    @Dni                = N'41106202',
    @Email              = N'GIERALDINE@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'17012012',
    @Direccion          = N'SAN JUAN DE MIRAFLORES',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'IE SAN JUAN BOSCO - ANCASH',
    @Grado              = N'2DO',
    @TelPersonal        = NULL,
    @TelApoderado       = N'954060817',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/d36001da-e099-4bdf-ad1a-42832531d050_WhatsApp Image 2026-01-21 at 13.20.32.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 41106202: ' + @M; ELSE PRINT 'ERROR DNI 41106202: ' + @M;
GO

-- [10/318] MARÍA MAGALY SALINAS CARRANZA (DNI 41320903)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'41320903',
    @Contra             = N'41320903',
    @Nombre             = N'MARÍA MAGALY',
    @Apellido           = N'SALINAS CARRANZA',
    @Dni                = N'41320903',
    @Email              = N'MARYMARYSC14@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'14051980',
    @Direccion          = NULL,
    @Distrito           = NULL,
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'955038434',
    @TelApoderado       = NULL,
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/84dac834-9dfe-49d9-a753-612291207710_MARIA SALINAS.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 41320903: ' + @M; ELSE PRINT 'ERROR DNI 41320903: ' + @M;
GO

-- [11/318] MIGUEL ÁNGEL ALBERTO ALE (DNI 41581670)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'41581670',
    @Contra             = N'41581670',
    @Nombre             = N'MIGUEL ÁNGEL',
    @Apellido           = N'ALBERTO ALE',
    @Dni                = N'41581670',
    @Email              = N'miguela.mej@gmail.com',
    @IdTipoUsuario      = N'1',
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
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/db34e13e-9150-42e7-9474-4c4fa00b6bf0_MIGUEL ANGEL.png',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 41581670: ' + @M; ELSE PRINT 'ERROR DNI 41581670: ' + @M;
GO

-- [12/318] MARGOT LÓPEZ (DNI 44745110)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'44745110',
    @Contra             = N'44745110',
    @Nombre             = N'MARGOT',
    @Apellido           = N'LÓPEZ',
    @Dni                = N'44745110',
    @Email              = N'dylam255@gmail.com',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = NULL,
    @Direccion          = NULL,
    @Distrito           = NULL,
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'933017389',
    @TelApoderado       = NULL,
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/10078005-ef3a-4abe-9a33-f296967e0007_MARGOT L.png',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 44745110: ' + @M; ELSE PRINT 'ERROR DNI 44745110: ' + @M;
GO

-- [13/318] AUDER GUEVARA BARBOZA (DNI 45580526)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'45580526',
    @Contra             = N'45580526',
    @Nombre             = N'AUDER',
    @Apellido           = N'GUEVARA BARBOZA',
    @Dni                = N'45580526',
    @Email              = N'AUDER@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'28111988',
    @Direccion          = N'TARAPOTO',
    @Distrito           = N'TARAPOTO',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'972416795',
    @TelApoderado       = N'972416795',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = NULL,
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 45580526: ' + @M; ELSE PRINT 'ERROR DNI 45580526: ' + @M;
GO

-- [14/318] ESTEBAN BERNABE CHIPANA VERA (DNI 45976762)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'45976762',
    @Contra             = N'45976762',
    @Nombre             = N'ESTEBAN BERNABE',
    @Apellido           = N'CHIPANA VERA',
    @Dni                = N'45976762',
    @Email              = N'estevanchipana23@gmail.com',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'24091989',
    @Direccion          = NULL,
    @Distrito           = NULL,
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'981265486',
    @TelApoderado       = NULL,
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/1bd445fa-75e3-495c-b500-a8d3b9b80b9c_perfil.jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 45976762: ' + @M; ELSE PRINT 'ERROR DNI 45976762: ' + @M;
GO

-- [15/318] ANGELO YOVERA (DNI 46295899)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'46295899',
    @Contra             = N'46295899',
    @Nombre             = N'ANGELO',
    @Apellido           = N'YOVERA',
    @Dni                = N'46295899',
    @Email              = N'46295899@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = NULL,
    @Direccion          = NULL,
    @Distrito           = NULL,
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'933017389',
    @TelApoderado       = NULL,
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/27668ec2-56d8-4bcc-b804-88457441b504_YOVERA.png',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 46295899: ' + @M; ELSE PRINT 'ERROR DNI 46295899: ' + @M;
GO

-- [16/318] JUAN ROJAS (DNI 46691058)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'46691058',
    @Contra             = N'46691058',
    @Nombre             = N'JUAN',
    @Apellido           = N'ROJAS',
    @Dni                = N'46691058',
    @Email              = N'46691058@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = NULL,
    @Direccion          = NULL,
    @Distrito           = NULL,
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'933017389',
    @TelApoderado       = NULL,
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/3a03af5c-9600-46e7-a886-c69cc81e5928_ROJAS.png',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 46691058: ' + @M; ELSE PRINT 'ERROR DNI 46691058: ' + @M;
GO

-- [17/318] JESÚS MORENO (DNI 46971273)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'46971273',
    @Contra             = N'46971273',
    @Nombre             = N'JESÚS',
    @Apellido           = N'MORENO',
    @Dni                = N'46971273',
    @Email              = N'46971273@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = NULL,
    @Direccion          = NULL,
    @Distrito           = NULL,
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'933017389',
    @TelApoderado       = NULL,
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/50445ba7-132b-418e-aa00-94277e51cf3f_MORENO.png',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 46971273: ' + @M; ELSE PRINT 'ERROR DNI 46971273: ' + @M;
GO

-- [18/318] CARLOS VENTURA CHIRA (DNI 47047658)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'47047658',
    @Contra             = N'47047658',
    @Nombre             = N'CARLOS',
    @Apellido           = N'VENTURA CHIRA',
    @Dni                = N'47047658',
    @Email              = N'47047658@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = NULL,
    @Direccion          = NULL,
    @Distrito           = NULL,
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'933017389',
    @TelApoderado       = NULL,
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/44bdd074-fc83-4b86-9d9f-aa54ac4a2833_Ventura.png',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 47047658: ' + @M; ELSE PRINT 'ERROR DNI 47047658: ' + @M;
GO

-- [19/318] GERSSON FLORES MAMANI (DNI 47880339)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'47880339',
    @Contra             = N'47880339',
    @Nombre             = N'GERSSON',
    @Apellido           = N'FLORES MAMANI',
    @Dni                = N'47880339',
    @Email              = N'gerssonfloresmamani30@gmail.com',
    @IdTipoUsuario      = N'1',
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
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/0cdd5bcb-ede3-473d-9c19-850cf4e6f0f5_GERSON.png',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 47880339: ' + @M; ELSE PRINT 'ERROR DNI 47880339: ' + @M;
GO

-- [20/318] MILGROS LUZ CARRASCO MEDINA (DNI 60005249)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'60005249',
    @Contra             = N'60005249',
    @Nombre             = N'MILGROS LUZ',
    @Apellido           = N'CARRASCO MEDINA',
    @Dni                = N'60005249',
    @Email              = N'MILAGROS@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'06012007',
    @Direccion          = N'CHORRILLOS',
    @Distrito           = N'CHORRILLOS',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'902579485',
    @TelApoderado       = N'918197437',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/93df7b68-ef5f-4eb5-9d74-0fffa2510543_WhatsApp Image 2026-03-24 at 9.35.50 AM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 60005249: ' + @M; ELSE PRINT 'ERROR DNI 60005249: ' + @M;
GO

-- [21/318] WILDER YEFRI HINOSTROZA QUICAÑO (DNI 60046034)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'60046034',
    @Contra             = N'60046034',
    @Nombre             = N'WILDER YEFRI',
    @Apellido           = N'HINOSTROZA QUICAÑO',
    @Dni                = N'60046034',
    @Email              = N'WILDER@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'22082006',
    @Direccion          = N'VILLA SOLIDARIDAD MZ  G  LT  08 - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'916903315',
    @TelApoderado       = N'917779544',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/b2e77be7-84c9-4a1a-bcdd-1300192eb544_WhatsApp Image 2026-02-05 at 9.56.36 AM (1).jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 60046034: ' + @M; ELSE PRINT 'ERROR DNI 60046034: ' + @M;
GO

-- [22/318] JORGE ANTONIO CASAFRANCA VILLANO (DNI 60275890)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'60275890',
    @Contra             = N'60275890',
    @Nombre             = N'JORGE ANTONIO',
    @Apellido           = N'CASAFRANCA VILLANO',
    @Dni                = N'60275890',
    @Email              = N'ANTONIO@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'08072007',
    @Direccion          = N'SANTA ISABEL - CHORRILLOS',
    @Distrito           = N'CHORRILLOS',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'907676121',
    @TelApoderado       = N'938344515',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/3c5dafa1-e69e-44e8-8c8d-40846cfa692c_WhatsApp Image 2026-03-25 at 4.52.58 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 60275890: ' + @M; ELSE PRINT 'ERROR DNI 60275890: ' + @M;
GO

-- [23/318] JOSS AYLI ANDIA FLORES (DNI 60295980)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'60295980',
    @Contra             = N'60295980',
    @Nombre             = N'JOSS AYLI',
    @Apellido           = N'ANDIA FLORES',
    @Dni                = N'60295980',
    @Email              = N'JOSS@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'14082008',
    @Direccion          = N'LOS PORTALES DEL SUR MZ D LT 6 - COOP AMERICA - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'986612737',
    @TelApoderado       = N'920213747',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/1dbef7b3-b2af-49fa-b33f-509dd0f112bc_WhatsApp Image 2026-04-07 at 4.55.14 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 60295980: ' + @M; ELSE PRINT 'ERROR DNI 60295980: ' + @M;
GO

-- [24/318] KAREN DANITZA GRANDEZ MONTOYA (DNI 60387805)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'60387805',
    @Contra             = N'60387805',
    @Nombre             = N'KAREN DANITZA',
    @Apellido           = N'GRANDEZ MONTOYA',
    @Dni                = N'60387805',
    @Email              = N'KAREN@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'12012009',
    @Direccion          = N'AV. PACHACUTEC 1697 P.J CERCADO',
    @Distrito           = N'VMT',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'901000806',
    @TelApoderado       = N'994423727',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/a0142205-e8f9-49a6-ace3-13027d2987f0_WhatsApp Image 2026-01-10 at 2.19.21 PM (4).jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 60387805: ' + @M; ELSE PRINT 'ERROR DNI 60387805: ' + @M;
GO

-- [25/318] JEANPIERRE SMITH MORALES CORNELIO (DNI 60401193)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'60401193',
    @Contra             = N'60401193',
    @Nombre             = N'JEANPIERRE SMITH',
    @Apellido           = N'MORALES CORNELIO',
    @Dni                = N'60401193',
    @Email              = N'SMITH@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'08122008',
    @Direccion          = N'GUARDIA CIVIL 901 - CHORRILLOS',
    @Distrito           = N'CHORRILLOS',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'902512951',
    @TelApoderado       = N'902512951',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/76cc3cb3-5492-4c02-ab5a-b707b5178aec_WhatsApp Image 2026-03-17 at 3.59.22 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 60401193: ' + @M; ELSE PRINT 'ERROR DNI 60401193: ' + @M;
GO

-- [26/318] JURMIX ALBERTO CARBAJAL ROJAS (DNI 60469851)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'60469851',
    @Contra             = N'60469851',
    @Nombre             = N'JURMIX ALBERTO',
    @Apellido           = N'CARBAJAL ROJAS',
    @Dni                = N'60469851',
    @Email              = N'JURMIX@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'19102006',
    @Direccion          = N'PJ 2 SECT VIRGEN DEL BUEN PASO - AA.HH. FRONT. V. MZ A LT11 - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'923944619',
    @TelApoderado       = N'966867170',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/ee8b31d2-fc70-43ea-9e73-eee179850bed_WhatsApp Image 2026-03-24 at 11.34.51 AM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 60469851: ' + @M; ELSE PRINT 'ERROR DNI 60469851: ' + @M;
GO

-- [27/318] JHOSEPH LEONEL ABRIGO QUISPE (DNI 60628226)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'60628226',
    @Contra             = N'60628226',
    @Nombre             = N'JHOSEPH LEONEL',
    @Apellido           = N'ABRIGO QUISPE',
    @Dni                = N'60628226',
    @Email              = N'JHOSEPH@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'13102008',
    @Direccion          = N'CALLE 13 DE OCTUBRE MZ L LOTE 07 - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'918377320',
    @TelApoderado       = N'900740432',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/3da7250f-130f-46f8-8960-f97d3d4eca87_WhatsApp Image 2026-03-17 at 3.59.24 PM (1).jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 60628226: ' + @M; ELSE PRINT 'ERROR DNI 60628226: ' + @M;
GO

-- [28/318] KIARA MELINA ALDERETE GARCIA (DNI 60800847)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'60800847',
    @Contra             = N'60800847',
    @Nombre             = N'KIARA MELINA',
    @Apellido           = N'ALDERETE GARCIA',
    @Dni                = N'60800847',
    @Email              = N'KIARA@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'16072006',
    @Direccion          = N'SAN JUAN DE MIRAFLORES',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'963787001',
    @TelApoderado       = N'963787001',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = NULL,
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 60800847: ' + @M; ELSE PRINT 'ERROR DNI 60800847: ' + @M;
GO

-- [29/318] GABRIELA AVEDAÑO MOSCOSO (DNI 60815028)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'60815028',
    @Contra             = N'60815028',
    @Nombre             = N'GABRIELA',
    @Apellido           = N'AVEDAÑO MOSCOSO',
    @Dni                = N'60815028',
    @Email              = N'GABRIELA@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'13082006',
    @Direccion          = N'AV. EL CARMEN # 1288 - VMT',
    @Distrito           = N'VILLA MARIA DEL TRIUNFO',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'987351254',
    @TelApoderado       = N'957791418',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = NULL,
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 60815028: ' + @M; ELSE PRINT 'ERROR DNI 60815028: ' + @M;
GO

-- [30/318] JOSE DANIEL SALVATIERRA NOA (DNI 60919931)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'60919931',
    @Contra             = N'60919931',
    @Nombre             = N'JOSE DANIEL',
    @Apellido           = N'SALVATIERRA NOA',
    @Dni                = N'60919931',
    @Email              = N'JOSE@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'05122006',
    @Direccion          = N'MZ E11 LT 6 AMPL. 4 SECT 12 DE NOVIEMBRE - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'903467615',
    @TelApoderado       = N'906100734',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/7db9b3b6-9c2b-41a0-8b43-ad9c64429987_WhatsApp Image 2026-03-18 at 10.06.44 AM (1).jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 60919931: ' + @M; ELSE PRINT 'ERROR DNI 60919931: ' + @M;
GO

-- [31/318] GUILLERMO SALVADOR QUINTANA HUACCHILLO (DNI 61031108)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61031108',
    @Contra             = N'61031108',
    @Nombre             = N'GUILLERMO SALVADOR',
    @Apellido           = N'QUINTANA HUACCHILLO',
    @Dni                = N'61031108',
    @Email              = N's69371776@gmail.com',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'26032026',
    @Direccion          = NULL,
    @Distrito           = NULL,
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'991052942',
    @TelApoderado       = NULL,
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/f5c5b493-5235-4712-8765-ef43fa0853c5_SALVADOR.png',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61031108: ' + @M; ELSE PRINT 'ERROR DNI 61031108: ' + @M;
GO

-- [32/318] FABRICIO ALDAIR CONDORI CORNEJO (DNI 61032850)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61032850',
    @Contra             = N'61032850',
    @Nombre             = N'FABRICIO ALDAIR',
    @Apellido           = N'CONDORI CORNEJO',
    @Dni                = N'61032850',
    @Email              = N'FABRICIO@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'26042007',
    @Direccion          = N'AA.HH LAS FLORES MZ B LT 6 SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'926617302',
    @TelApoderado       = N'921569733',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/5aeed915-f4f8-49f4-9d26-7ef9d13bf82f_WhatsApp Image 2026-01-10 at 11.22.21 (1).jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61032850: ' + @M; ELSE PRINT 'ERROR DNI 61032850: ' + @M;
GO

-- [33/318] MILAGROS CANELA QUISPE MAMANI (DNI 61033502)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61033502',
    @Contra             = N'61033502',
    @Nombre             = N'MILAGROS CANELA',
    @Apellido           = N'QUISPE MAMANI',
    @Dni                = N'61033502',
    @Email              = N'61033502@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'07032007',
    @Direccion          = N'AA.HH. LAS FLORES DE VILLA MZ A1 - LOTE 3  -  SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'967675578',
    @TelApoderado       = N'963033560',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/337688c4-4059-44cb-9fdc-b3c94e43f8de_WhatsApp Image 2026-04-01 at 4.58.32 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61033502: ' + @M; ELSE PRINT 'ERROR DNI 61033502: ' + @M;
GO

-- [34/318] ITALO SEBASTIAN HUAMAN SULCA (DNI 61042238)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61042238',
    @Contra             = N'61042238',
    @Nombre             = N'ITALO SEBASTIAN',
    @Apellido           = N'HUAMAN SULCA',
    @Dni                = N'61042238',
    @Email              = N'ITALO@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'13042007',
    @Direccion          = N'ASOC. VIV. 27 DE JULIO MZ L LOTE 03 - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = NULL,
    @TelApoderado       = N'984031081',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/fb1d2e23-f6b5-4bc0-829a-78cfc190d35f_WhatsApp Image 2026-03-17 at 3.59.25 PM (1).jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61042238: ' + @M; ELSE PRINT 'ERROR DNI 61042238: ' + @M;
GO

-- [35/318] DARIELA QUISPE TAYPE (DNI 61092160)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61092160',
    @Contra             = N'61092160',
    @Nombre             = N'DARIELA',
    @Apellido           = N'QUISPE TAYPE',
    @Dni                = N'61092160',
    @Email              = N'DARIELA@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'22052007',
    @Direccion          = N'V. VECINAL INDEPENDIZADA NRP 1 MZ B LT 1-A',
    @Distrito           = N'VES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'902276661',
    @TelApoderado       = N'994043157',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/e689474b-5c03-4f75-97dc-1e04729e59e5_WhatsApp Image 2026-01-10 at 2.19.20 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61092160: ' + @M; ELSE PRINT 'ERROR DNI 61092160: ' + @M;
GO

-- [36/318] ANDREA JIMENA CORREA CALIZAYA (DNI 61118481)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61118481',
    @Contra             = N'61118481',
    @Nombre             = N'ANDREA JIMENA',
    @Apellido           = N'CORREA CALIZAYA',
    @Dni                = N'61118481',
    @Email              = N'ANDREITA19_17@HOTMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'19052007',
    @Direccion          = NULL,
    @Distrito           = NULL,
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'932421177',
    @TelApoderado       = NULL,
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/6e9c6c06-43ae-49cf-8bc2-e8394bcc9956_perfil.jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61118481: ' + @M; ELSE PRINT 'ERROR DNI 61118481: ' + @M;
GO

-- [37/318] CARMEN VICTORA MENDOZA SEVILLANO (DNI 61119137)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61119137',
    @Contra             = N'61119137',
    @Nombre             = N'CARMEN VICTORA',
    @Apellido           = N'MENDOZA SEVILLANO',
    @Dni                = N'61119137',
    @Email              = N'CARMEN@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'22062007',
    @Direccion          = N'MANUEL GARCIA # 215 PAMPLONA BAJA - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'902659411',
    @TelApoderado       = N'902313220',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/d6439e67-7ca1-4d8b-bd5f-f7633edf3202_Foto carnet (2).jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61119137: ' + @M; ELSE PRINT 'ERROR DNI 61119137: ' + @M;
GO

-- [38/318] ANYELA DAYANA MARCA ORACO (DNI 61163441)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61163441',
    @Contra             = N'61163441',
    @Nombre             = N'ANYELA DAYANA',
    @Apellido           = N'MARCA ORACO',
    @Dni                = N'61163441',
    @Email              = N'ANYELA@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'06092007',
    @Direccion          = N'AA.HH. LOS FICUS DEL PEDREGAL - MZ B LT 11 - VMT',
    @Distrito           = N'VILLA MARIA DEL TRIUNFO',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'945263305',
    @TelApoderado       = N'922441869',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/f5dd12f7-4802-42b7-a044-0e4a25cc0e14_Captura de pantalla 2026-03-20 135758.png',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61163441: ' + @M; ELSE PRINT 'ERROR DNI 61163441: ' + @M;
GO

-- [39/318] VICTOR MANUEL DOMINGUEZ PATIÑO (DNI 61173184)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61173184',
    @Contra             = N'61173184',
    @Nombre             = N'VICTOR MANUEL',
    @Apellido           = N'DOMINGUEZ PATIÑO',
    @Dni                = N'61173184',
    @Email              = N'VICTOR@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'17082007',
    @Direccion          = N'MZ A LT 2 SEC 6 HEROES DE SAN JUAN - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'977648009',
    @TelApoderado       = N'946140133',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/5e00fdab-dc2a-4621-9265-1d4304eb19d8_WhatsApp Image 2026-01-15 at 11.56.28 AM (1).jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61173184: ' + @M; ELSE PRINT 'ERROR DNI 61173184: ' + @M;
GO

-- [40/318] MILAGROS CISNEROS VELASQUEZ (DNI 61180102)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61180102',
    @Contra             = N'61180102',
    @Nombre             = N'MILAGROS',
    @Apellido           = N'CISNEROS VELASQUEZ',
    @Dni                = N'61180102',
    @Email              = N'61180102@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'19102007',
    @Direccion          = N'AMPL VILLA SAN LUIS MZ I8 LT 8',
    @Distrito           = N'SJM',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'912710534',
    @TelApoderado       = N'906236954',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/eee4c4fe-4cc1-4a1d-a20a-c5cd881defbe_WhatsApp Image 2026-01-10 at 2.19.23 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61180102: ' + @M; ELSE PRINT 'ERROR DNI 61180102: ' + @M;
GO

-- [41/318] XIOMARA DIANA ALCANTARA BURGOS (DNI 61200585)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61200585',
    @Contra             = N'61200585',
    @Nombre             = N'XIOMARA DIANA',
    @Apellido           = N'ALCANTARA BURGOS',
    @Dni                = N'61200585',
    @Email              = N'DIANA@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'08052008',
    @Direccion          = N'MZ M LT 9 AH. MANUEL SCORZA',
    @Distrito           = N'SAN JUA DE MIRAFLORES',
    @Colegio            = N'IE REPUBLICA ALEMANA 7100',
    @Grado              = N'5TO',
    @TelPersonal        = N'971953808',
    @TelApoderado       = N'989135053',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/187a0881-a2bc-4bcc-aaf5-8a3b37576087_WhatsApp Image 2026-01-15 at 3.34.35 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61200585: ' + @M; ELSE PRINT 'ERROR DNI 61200585: ' + @M;
GO

-- [42/318] BLANCA SOFIA ESTHER CHUMPITAZ CAYCHO (DNI 61215514)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61215514',
    @Contra             = N'61215514',
    @Nombre             = N'BLANCA SOFIA ESTHER',
    @Apellido           = N'CHUMPITAZ CAYCHO',
    @Dni                = N'61215514',
    @Email              = N'BLANCA@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'04122007',
    @Direccion          = N'AV. CESAR CANEVARO 140 - MZ O3 LT 15 ZN C - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'61215514',
    @TelApoderado       = N'998541600',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/89e9560c-e181-4e6a-95f1-ac31ae4b68fe_IMG_20260309_115345.jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61215514: ' + @M; ELSE PRINT 'ERROR DNI 61215514: ' + @M;
GO

-- [43/318] DANTE EMMANUEL ARMAS MONTES (DNI 61215706)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61215706',
    @Contra             = N'61215706',
    @Nombre             = N'DANTE EMMANUEL',
    @Apellido           = N'ARMAS MONTES',
    @Dni                = N'61215706',
    @Email              = N'DANTE@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'17112007',
    @Direccion          = N'AA.HH. CRUZ DE MOTUPE MZ C LOTE 10 - VMT',
    @Distrito           = N'VILLA MARIA DEL TRIUNFO',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'906738241',
    @TelApoderado       = N'922696133',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/e49d9425-bff9-4bb1-bbf4-7a79240ac47e_WhatsApp Image 2026-03-21 at 7.28.38 AM (1).jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61215706: ' + @M; ELSE PRINT 'ERROR DNI 61215706: ' + @M;
GO

-- [44/318] ROGER ANDRE CONDORI MALLQUI (DNI 61216936)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61216936',
    @Contra             = N'61216936',
    @Nombre             = N'ROGER ANDRE',
    @Apellido           = N'CONDORI MALLQUI',
    @Dni                = N'61216936',
    @Email              = N'ROGER@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'27072007',
    @Direccion          = N'PASAJE LOS NARDOS',
    @Distrito           = N'SJM',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'977128206',
    @TelApoderado       = N'980931642',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/cf0f969b-aa2a-4aa2-8e19-8f61979514cb_10 (1).jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61216936: ' + @M; ELSE PRINT 'ERROR DNI 61216936: ' + @M;
GO

-- [45/318] EVELYN JIMENA RIOS ARDILES (DNI 61250833)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61250833',
    @Contra             = N'61250833',
    @Nombre             = N'EVELYN JIMENA',
    @Apellido           = N'RIOS ARDILES',
    @Dni                = N'61250833',
    @Email              = N'EVELYN@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'11012008',
    @Direccion          = N'JR. LEONCIO PRADO - SURCO',
    @Distrito           = N'CHORRILOS',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'932274129',
    @TelApoderado       = N'932274129',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/dc1d333f-096f-44ae-81a6-62e4d3ac43e9_WhatsApp Image 2026-06-11 at 9.41.13 AM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61250833: ' + @M; ELSE PRINT 'ERROR DNI 61250833: ' + @M;
GO

-- [46/318] KEISY LUCERO FERNANDEZ VILLALOBOS (DNI 61276113)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61276113',
    @Contra             = N'61276113',
    @Nombre             = N'KEISY LUCERO',
    @Apellido           = N'FERNANDEZ VILLALOBOS',
    @Dni                = N'61276113',
    @Email              = N'KEISY@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'30042008',
    @Direccion          = N'MZ J LOTE 17 - SAN JUAN DE MIRAFLORES',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'HEROES DEL ALTO CENEPA',
    @Grado              = N'5TO',
    @TelPersonal        = N'959229155',
    @TelApoderado       = N'952989839',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/b8ac2cb3-03fd-417d-bb37-1a84f56af39e_WhatsApp Image 2026-05-12 at 9.42.18 AM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61276113: ' + @M; ELSE PRINT 'ERROR DNI 61276113: ' + @M;
GO

-- [47/318] ANYELO DAVID CCASA GARRO (DNI 61295544)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61295544',
    @Contra             = N'61295544',
    @Nombre             = N'ANYELO DAVID',
    @Apellido           = N'CCASA GARRO',
    @Dni                = N'61295544',
    @Email              = N'ANYELO@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'13012008',
    @Direccion          = N'CALLE 4 AH. REP DEM ALEMANA MZ Z2 LT 5 - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'946056520',
    @TelApoderado       = N'934656467',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/dea0f637-3243-4a14-a77c-637822aac78b_WhatsApp Image 2026-03-17 at 3.59.11 PM (1).jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61295544: ' + @M; ELSE PRINT 'ERROR DNI 61295544: ' + @M;
GO

-- [48/318] JAIRO FRANCISCO CONTRERAS ESPINOZA (DNI 61295917)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61295917',
    @Contra             = N'61295917',
    @Nombre             = N'JAIRO FRANCISCO',
    @Apellido           = N'CONTRERAS ESPINOZA',
    @Dni                = N'61295917',
    @Email              = N'JAIRO@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'31012008',
    @Direccion          = N'AV. MANUEL VELARDE # 820 ZN "D" - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'987182138',
    @TelApoderado       = N'945250237',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/c4a42374-47de-4df9-8cb5-5c24de9aa638_WhatsApp Image 2026-04-17 at 10.37.31 AM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61295917: ' + @M; ELSE PRINT 'ERROR DNI 61295917: ' + @M;
GO

-- [49/318] NICOLAS ANTHONY SALVADOR QUISPE (DNI 61313366)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61313366',
    @Contra             = N'61313366',
    @Nombre             = N'NICOLAS ANTHONY',
    @Apellido           = N'SALVADOR QUISPE',
    @Dni                = N'61313366',
    @Email              = N'NICOLAS@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'05102009',
    @Direccion          = N'SAN JUAN DE MIRAFLORES',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'917157999',
    @TelApoderado       = N'935364502',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/ccce59ca-4d29-401a-bf13-7dd41b85d4fe_WhatsApp Image 2026-03-24 at 9.39.25 AM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61313366: ' + @M; ELSE PRINT 'ERROR DNI 61313366: ' + @M;
GO

-- [50/318] NATHALY NORIEL ZORAIDA RAMÍREZ ANCHAYHUA (DNI 61330467)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61330467',
    @Contra             = N'61330467',
    @Nombre             = N'NATHALY NORIEL ZORAIDA',
    @Apellido           = N'RAMÍREZ ANCHAYHUA',
    @Dni                = N'61330467',
    @Email              = N'NATHALY@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'05052007',
    @Direccion          = N'AC. ÁNGEL DE LA GUARDA MZ B2 LT 14 P.A SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'957385555',
    @TelApoderado       = N'939635308',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/9cb95194-c8b0-46ab-9fbb-5034dae5b584_WhatsApp Image 2026-01-10 at 12.52.07 PM (1).jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61330467: ' + @M; ELSE PRINT 'ERROR DNI 61330467: ' + @M;
GO

-- [51/318] RODRIGO ALBERT OVIEDO MARCAS (DNI 61332734)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61332734',
    @Contra             = N'61332734',
    @Nombre             = N'RODRIGO ALBERT',
    @Apellido           = N'OVIEDO MARCAS',
    @Dni                = N'61332734',
    @Email              = N'RODRIGO@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'08042008',
    @Direccion          = N'MZ I LOTE 2 SECTOR LAS MALVINAS AA.HH. PROY. INT. - VMT',
    @Distrito           = N'VILLA MARIA DEL TRIUNFO',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'922511057',
    @TelApoderado       = N'931397504',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/56586951-a38b-4576-b1ac-ae3586c446f6_WhatsApp Image 2026-03-17 at 3.59.22 PM (6).jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61332734: ' + @M; ELSE PRINT 'ERROR DNI 61332734: ' + @M;
GO

-- [52/318] WILLIAM PAUL SANCHEZ ZARATE (DNI 61355000)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61355000',
    @Contra             = N'61355000',
    @Nombre             = N'WILLIAM PAUL',
    @Apellido           = N'SANCHEZ ZARATE',
    @Dni                = N'61355000',
    @Email              = N'WILLIAM@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'21032008',
    @Direccion          = N'AA.HH. VILLA SAN JUAN MZ G LT 12 PAMPLONA ALTA - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'972009685',
    @TelApoderado       = N'921291345',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = NULL,
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61355000: ' + @M; ELSE PRINT 'ERROR DNI 61355000: ' + @M;
GO

-- [53/318] CELINE GOMEZ JOYO (DNI 61358939)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61358939',
    @Contra             = N'61358939',
    @Nombre             = N'CELINE',
    @Apellido           = N'GOMEZ JOYO',
    @Dni                = N'61358939',
    @Email              = N'CELINE@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'22022008',
    @Direccion          = N'AV. VILCABAMBA DELICIAS DE VILLA MZ G9 LT6A - CHORRILLOS',
    @Distrito           = N'CHORRILLOS',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'926715068',
    @TelApoderado       = N'922952535',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/2fad0e17-01f8-44d5-8aff-5a4c55200441_WhatsApp Image 2026-03-17 at 3.59.11 PM (3).jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61358939: ' + @M; ELSE PRINT 'ERROR DNI 61358939: ' + @M;
GO

-- [54/318] LUIS THIAGO HUINCHO LOPEZ (DNI 61359712)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61359712',
    @Contra             = N'61359712',
    @Nombre             = N'LUIS THIAGO',
    @Apellido           = N'HUINCHO LOPEZ',
    @Dni                = N'61359712',
    @Email              = N'LUIS@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'13042008',
    @Direccion          = N'SECTOR 2 GRUPO 20 MZ J LT24 VES',
    @Distrito           = N'VILLA EL SALVADOR',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'925696419',
    @TelApoderado       = N'980904850',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/618dfe42-e485-4563-87c9-0f1948bc7da7_perfil.jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61359712: ' + @M; ELSE PRINT 'ERROR DNI 61359712: ' + @M;
GO

-- [55/318] ANALIA MIA POMA PEREZ (DNI 61363621)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61363621',
    @Contra             = N'61363621',
    @Nombre             = N'ANALIA MIA',
    @Apellido           = N'POMA PEREZ',
    @Dni                = N'61363621',
    @Email              = N'ANALIA@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'30042008',
    @Direccion          = N'AA.HH. TRES DE OCTUBRE DE VILLA  MZ 20  LT 9 - CHORRILLOS',
    @Distrito           = N'CHORRILLOS',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'940327837',
    @TelApoderado       = N'999923981',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/4b14d88b-2b30-43be-a9ad-682831823fbb_WhatsApp Image 2026-03-17 at 3.59.13 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61363621: ' + @M; ELSE PRINT 'ERROR DNI 61363621: ' + @M;
GO

-- [56/318] ROONEY JUAREZ TUNQUIPA (DNI 61363784)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61363784',
    @Contra             = N'61363784',
    @Nombre             = N'ROONEY',
    @Apellido           = N'JUAREZ TUNQUIPA',
    @Dni                = N'61363784',
    @Email              = N'ROONEY@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'23052008',
    @Direccion          = N'MZ. LI LT. 18 13 OCTUBRE',
    @Distrito           = N'SJM',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'972381646',
    @TelApoderado       = N'968069340',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/f78f606b-75aa-4e04-a0f4-db798416b384_WhatsApp Image 2026-01-10 at 1.23.44 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61363784: ' + @M; ELSE PRINT 'ERROR DNI 61363784: ' + @M;
GO

-- [57/318] ABRIL GUIZADO ABATE (DNI 61363829)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61363829',
    @Contra             = N'61363829',
    @Nombre             = N'ABRIL',
    @Apellido           = N'GUIZADO ABATE',
    @Dni                = N'61363829',
    @Email              = N'ABRIL@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'26042008',
    @Direccion          = N'VILLA LOS ANGELES 2 MZ L LT 18 P.A SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'901426383',
    @TelApoderado       = N'927492040',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/554204f0-fdef-4f05-abdb-ea15ff4388b1_WhatsApp Image 2026-01-10 at 2.19.22 PM (4).jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61363829: ' + @M; ELSE PRINT 'ERROR DNI 61363829: ' + @M;
GO

-- [58/318] GUADALUPE OSCCO ROJAS (DNI 61364064)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61364064',
    @Contra             = N'61364064',
    @Nombre             = N'GUADALUPE',
    @Apellido           = N'OSCCO ROJAS',
    @Dni                = N'61364064',
    @Email              = N'GUADALUPE@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'24052008',
    @Direccion          = N'AMPL. 2 SECT. 5 DE MAYO P. ALTA MZ. N7 LT. 14',
    @Distrito           = NULL,
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'927269260',
    @TelApoderado       = N'926011097',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/5427d1e7-eebb-460a-ab8e-ea3f23c30396_WhatsApp Image 2026-01-15 at 11.55.09 AM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61364064: ' + @M; ELSE PRINT 'ERROR DNI 61364064: ' + @M;
GO

-- [59/318] STEFANO QUISPE BALDEON (DNI 61364448)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61364448',
    @Contra             = N'61364448',
    @Nombre             = N'STEFANO',
    @Apellido           = N'QUISPE BALDEON',
    @Dni                = N'61364448',
    @Email              = N'STEFANO@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'23062008',
    @Direccion          = N'MZ C LT 3 LT 9 - DPTO 301 - URB SANTA ROSA 1RA ETAPA - STGO SURCO',
    @Distrito           = N'SURCO',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = NULL,
    @TelApoderado       = N'992809716',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/ba8eb1cd-0863-4a4f-9697-f6e636d1d33a_WhatsApp Image 2026-04-07 at 2.01.57 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61364448: ' + @M; ELSE PRINT 'ERROR DNI 61364448: ' + @M;
GO

-- [60/318] LIZBETH KATERINE OCAS CHACON (DNI 61371087)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61371087',
    @Contra             = N'61371087',
    @Nombre             = N'LIZBETH KATERINE',
    @Apellido           = N'OCAS CHACON',
    @Dni                = N'61371087',
    @Email              = N'LIZBETH@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'19062008',
    @Direccion          = N'CA. A MZ. N1 LT. 31 AH. LAS FLORES DE VILLA',
    @Distrito           = N'SJM',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'938877512',
    @TelApoderado       = N'969050021',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/370ffb9e-727a-42fd-931c-2136faf5d1ee_WhatsApp Image 2026-03-17 at 3.59.22 PM (2).jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61371087: ' + @M; ELSE PRINT 'ERROR DNI 61371087: ' + @M;
GO

-- [61/318] DEISY MEDALY VICTORIO JUSTINIANO (DNI 61380799)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61380799',
    @Contra             = N'61380799',
    @Nombre             = N'DEISY MEDALY',
    @Apellido           = N'VICTORIO JUSTINIANO',
    @Dni                = N'61380799',
    @Email              = N'DEISY@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'27052008',
    @Direccion          = N'PUEBLO JOVEN AVENIDA PERU - CALLE YANAHUANCA - PASCO',
    @Distrito           = N'CERRO DE PASCO - DEPARTAMENTO',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'913477483',
    @TelApoderado       = N'979760423',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = NULL,
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61380799: ' + @M; ELSE PRINT 'ERROR DNI 61380799: ' + @M;
GO

-- [62/318] JOSE LUIS CRUZ HUAMAN (DNI 61392984)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61392984',
    @Contra             = N'61392984',
    @Nombre             = N'JOSE LUIS',
    @Apellido           = N'CRUZ HUAMAN',
    @Dni                = N'61392984',
    @Email              = N'61392984@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'04062008',
    @Direccion          = N'LOS JAZMINES 245 - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'902187984',
    @TelApoderado       = N'961873408',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/6dd6b753-f21d-446e-a41b-d26364876beb_WhatsApp Image 2026-03-21 at 7.28.38 AM (2).jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61392984: ' + @M; ELSE PRINT 'ERROR DNI 61392984: ' + @M;
GO

-- [63/318] NELLY ELENA SINCE PINARES (DNI 61420550)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61420550',
    @Contra             = N'61420550',
    @Nombre             = N'NELLY ELENA',
    @Apellido           = N'SINCE PINARES',
    @Dni                = N'61420550',
    @Email              = N'NELLY@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'27062008',
    @Direccion          = N'COOP AMERICA MZ P LOTE 28 - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'970992105',
    @TelApoderado       = N'970580519',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/50eb5c6c-62c3-4713-881d-a349fec701a0_WhatsApp Image 2026-04-22 at 10.09.01 AM (1).jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61420550: ' + @M; ELSE PRINT 'ERROR DNI 61420550: ' + @M;
GO

-- [64/318] MIREYA SHANTAL ROMAN GUARNIZO (DNI 61428090)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61428090',
    @Contra             = N'61428090',
    @Nombre             = N'MIREYA SHANTAL',
    @Apellido           = N'ROMAN GUARNIZO',
    @Dni                = N'61428090',
    @Email              = N'MIREYA@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'10082008',
    @Direccion          = N'SAN JUAN DE MIRAFLORES',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'960843527',
    @TelApoderado       = N'933457690',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/eac37ab9-76e0-439e-a9e1-034311ce2386_perfil.jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61428090: ' + @M; ELSE PRINT 'ERROR DNI 61428090: ' + @M;
GO

-- [65/318] VALERIA BRISEIDA MARTINEZ RAYMI (DNI 61434209)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61434209',
    @Contra             = N'61434209',
    @Nombre             = N'VALERIA BRISEIDA',
    @Apellido           = N'MARTINEZ RAYMI',
    @Dni                = N'61434209',
    @Email              = N'VALERIA@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'03082008',
    @Direccion          = N'ASENT. H. MANUEL SCORZA MZ N LT 20  - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'IE JAVIER HERAUD',
    @Grado              = N'5TO',
    @TelPersonal        = N'952055559',
    @TelApoderado       = N'996057978',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/a9b4cd79-64de-4c73-9429-2da44263a12d_WhatsApp Image 2026-03-26 at 5.02.08 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61434209: ' + @M; ELSE PRINT 'ERROR DNI 61434209: ' + @M;
GO

-- [66/318] ARIANA JIMENA LUJAN VERA (DNI 61434259)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61434259',
    @Contra             = N'61434259',
    @Nombre             = N'ARIANA JIMENA',
    @Apellido           = N'LUJAN VERA',
    @Dni                = N'61434259',
    @Email              = N'ARIANA@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'30082008',
    @Direccion          = N'MZ X7 LT32 VILLA SAN LUIS PAMPLONA ALTA SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'916571588',
    @TelApoderado       = N'970611240',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/dc268e70-ecdb-4a9c-a039-4d04f6487919_WhatsApp Image 2026-01-10 at 2.19.22 PM (5).jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61434259: ' + @M; ELSE PRINT 'ERROR DNI 61434259: ' + @M;
GO

-- [67/318] OMAR STEPHANO  ALEX LEO PALACIOS (DNI 61434396)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61434396',
    @Contra             = N'61434396',
    @Nombre             = N'OMAR STEPHANO  ALEX',
    @Apellido           = N'LEO PALACIOS',
    @Dni                = N'61434396',
    @Email              = N'OMAR@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'07072008',
    @Direccion          = N'SANTA ISABEL DE VILLA MZ M LT 5 - STGO DE SURCO',
    @Distrito           = N'SURCO',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'925246355',
    @TelApoderado       = N'974287107',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/b6529f94-d3f1-466f-9234-3720c22ae062_WhatsApp Image 2026-03-17 at 3.59.22 PM (5).jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61434396: ' + @M; ELSE PRINT 'ERROR DNI 61434396: ' + @M;
GO

-- [68/318] KASANDRA YANET VARGAS QUISPE (DNI 61434578)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61434578',
    @Contra             = N'61434578',
    @Nombre             = N'KASANDRA YANET',
    @Apellido           = N'VARGAS QUISPE',
    @Dni                = N'61434578',
    @Email              = N'kasandrabarrios11@gmail.com',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'25072008',
    @Direccion          = N'EL PACIFICO 1ERA ETAPA MZ A LT 01',
    @Distrito           = N'SJM',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'939649675',
    @TelApoderado       = N'939649675',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = NULL,
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61434578: ' + @M; ELSE PRINT 'ERROR DNI 61434578: ' + @M;
GO

-- [69/318] MILAGROS ESTHER MAYTA BACARREZ (DNI 61434762)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61434762',
    @Contra             = N'61434762',
    @Nombre             = N'MILAGROS ESTHER',
    @Apellido           = N'MAYTA BACARREZ',
    @Dni                = N'61434762',
    @Email              = N'61434762@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'02082008',
    @Direccion          = N'SAN JUAN DE LA LIBERTAD COMTE 7 LOTE 8 MAZ -Z - CHORRILLOS',
    @Distrito           = N'CHORRILLOS',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'935915311',
    @TelApoderado       = N'935474700',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/c72ac03b-c52e-4fb8-8cf1-ea9e71a8ae63_WhatsApp Image 2026-05-12 at 9.39.29 AM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61434762: ' + @M; ELSE PRINT 'ERROR DNI 61434762: ' + @M;
GO

-- [70/318] DONOVAN SAENZ CASTILLA (DNI 61434811)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61434811',
    @Contra             = N'61434811',
    @Nombre             = N'DONOVAN',
    @Apellido           = N'SAENZ CASTILLA',
    @Dni                = N'61434811',
    @Email              = N'DONOVAN@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'29072008',
    @Direccion          = N'VILLA LOS ANGELES - PAMPLONA BAJA - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'933784822',
    @TelApoderado       = NULL,
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = NULL,
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61434811: ' + @M; ELSE PRINT 'ERROR DNI 61434811: ' + @M;
GO

-- [71/318] DAYAN NICOLE BAUTISTA HUAMANI (DNI 61434993)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61434993',
    @Contra             = N'61434993',
    @Nombre             = N'DAYAN NICOLE',
    @Apellido           = N'BAUTISTA HUAMANI',
    @Dni                = N'61434993',
    @Email              = N'DAYAN@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'31082008',
    @Direccion          = N'SJM',
    @Distrito           = N'SJM',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'963709936',
    @TelApoderado       = N'963252918',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = NULL,
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61434993: ' + @M; ELSE PRINT 'ERROR DNI 61434993: ' + @M;
GO

-- [72/318] PIERO VALENTINO PEREZ CACERES (DNI 61435218)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61435218',
    @Contra             = N'61435218',
    @Nombre             = N'PIERO VALENTINO',
    @Apellido           = N'PEREZ CACERES',
    @Dni                = N'61435218',
    @Email              = N'PIERO@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'29082008',
    @Direccion          = N'CALLE MANUEL WAGNER 1143 - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'986949608',
    @TelApoderado       = N'902432687',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/c6301c40-fb18-424d-83b0-be261205637f_WhatsApp Image 2026-03-17 at 3.59.24 PM (3).jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61435218: ' + @M; ELSE PRINT 'ERROR DNI 61435218: ' + @M;
GO

-- [73/318] FABIOLA DANUSKA HUAROTO ROMERO (DNI 61454016)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61454016',
    @Contra             = N'61454016',
    @Nombre             = N'FABIOLA DANUSKA',
    @Apellido           = N'HUAROTO ROMERO',
    @Dni                = N'61454016',
    @Email              = N'FABIOLA@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'19072008',
    @Direccion          = N'ASOCIACION VILLA EL MILAGRO MZ W LT 3 - VILLA EL SALVADOR',
    @Distrito           = N'VILLA EL SALVADOR',
    @Colegio            = N'IEP LEONARD EULER',
    @Grado              = N'5TO',
    @TelPersonal        = N'947849228',
    @TelApoderado       = N'984032642',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/9d9b9953-9d87-4137-9e13-7d8eae38fea3_WhatsApp Image 2026-01-10 at 11.30.02 (1).jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61454016: ' + @M; ELSE PRINT 'ERROR DNI 61454016: ' + @M;
GO

-- [74/318] ADRIEL MARTIN FLORES HUAMANI (DNI 61466262)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61466262',
    @Contra             = N'61466262',
    @Nombre             = N'ADRIEL MARTIN',
    @Apellido           = N'FLORES HUAMANI',
    @Dni                = N'61466262',
    @Email              = N'ADRIEL@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'05082008',
    @Direccion          = N'AV. RICARDO PALMA MZ E LT 12 - CHORRILLOS',
    @Distrito           = N'CHORRILLOS',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'964342295',
    @TelApoderado       = N'994875049',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/93bea274-6161-4835-9b18-b2b656f4cc97_WhatsApp Image 2026-03-17 at 3.59.25 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61466262: ' + @M; ELSE PRINT 'ERROR DNI 61466262: ' + @M;
GO

-- [75/318] ANDREA SOFIA PADILLA VASQUEZ (DNI 61470118)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61470118',
    @Contra             = N'61470118',
    @Nombre             = N'ANDREA SOFIA',
    @Apellido           = N'PADILLA VASQUEZ',
    @Dni                = N'61470118',
    @Email              = N'ANDREA@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'09092008',
    @Direccion          = N'JR MANCO CAPAC - 1300 - VMT',
    @Distrito           = N'VILLA MARIA DEL TRIUNFO',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'904839405',
    @TelApoderado       = N'943387932',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/026039ea-512f-41df-9d26-081ec18c5015_1001270773.jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61470118: ' + @M; ELSE PRINT 'ERROR DNI 61470118: ' + @M;
GO

-- [76/318] DAYRA DANISA PALOMINO ARANGO (DNI 61494389)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61494389',
    @Contra             = N'61494389',
    @Nombre             = N'DAYRA DANISA',
    @Apellido           = N'PALOMINO ARANGO',
    @Dni                = N'61494389',
    @Email              = N'DAYRA@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'06102008',
    @Direccion          = N'CERRO VERDE P.A. - MZ A LT7 - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'936061845',
    @TelApoderado       = N'957954504',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/c9be2e23-9c6e-4aff-bd0c-2baf7dd34faf_WhatsApp Image 2026-04-07 at 2.07.15 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61494389: ' + @M; ELSE PRINT 'ERROR DNI 61494389: ' + @M;
GO

-- [77/318] DANIELA YAMILET HERNANDEZ GUERRERO (DNI 61494468)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61494468',
    @Contra             = N'61494468',
    @Nombre             = N'DANIELA YAMILET',
    @Apellido           = N'HERNANDEZ GUERRERO',
    @Dni                = N'61494468',
    @Email              = N'DANIELA@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'05092008',
    @Direccion          = N'HEROES DE SAN JUAN MZ  I LOTE 42 SECTOR 5 - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'976844306',
    @TelApoderado       = N'975597181',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/488c4f7a-4ef8-4f8f-9c2e-863e2ba23e0f_WhatsApp Image 2026-03-17 at 3.59.25 PM (2).jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61494468: ' + @M; ELSE PRINT 'ERROR DNI 61494468: ' + @M;
GO

-- [78/318] RUT BETSA SAMANAMU ROJAS (DNI 61497190)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61497190',
    @Contra             = N'61497190',
    @Nombre             = N'RUT BETSA',
    @Apellido           = N'SAMANAMU ROJAS',
    @Dni                = N'61497190',
    @Email              = N'RUT@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'14102008',
    @Direccion          = N'MZ Q10 LOTE 7B P.A. - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'907658659',
    @TelApoderado       = N'930687899',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/47e3de42-7e7b-4b85-af85-e79ca5d8a95b_WhatsApp Image 2026-04-18 at 8.32.23 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61497190: ' + @M; ELSE PRINT 'ERROR DNI 61497190: ' + @M;
GO

-- [79/318] FLOR MILAGROS ACHULLI VALERIANO (DNI 61497604)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61497604',
    @Contra             = N'61497604',
    @Nombre             = N'FLOR MILAGROS',
    @Apellido           = N'ACHULLI VALERIANO',
    @Dni                = N'61497604',
    @Email              = N'FLOR@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'14102008',
    @Direccion          = N'MZ A1 LT 6 - AA.HH. INDOAMERICA - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'910730682',
    @TelApoderado       = N'926306004',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/05235176-a7d2-41a7-9810-d90ca998e291_WhatsApp Image 2026-01-15 at 3.35.23 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61497604: ' + @M; ELSE PRINT 'ERROR DNI 61497604: ' + @M;
GO

-- [80/318] LEYLI DARHIANA JESUS MOGOLLON PANTA (DNI 61501394)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61501394',
    @Contra             = N'61501394',
    @Nombre             = N'LEYLI DARHIANA JESUS',
    @Apellido           = N'MOGOLLON PANTA',
    @Dni                = N'61501394',
    @Email              = N'LEYLI@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'16012008',
    @Direccion          = N'AA. HH. MARTIN JOSE OLAYA. MZ. C LT. 3',
    @Distrito           = N'SJM',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'972782196',
    @TelApoderado       = N'906633294',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/7fae462a-af4d-4455-99bb-1ef672498b3b_4227BFA4-B10E-408D-BD87-63EC2CD9F393.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61501394: ' + @M; ELSE PRINT 'ERROR DNI 61501394: ' + @M;
GO

-- [81/318] OSCAR MENDOZA HERNANDEZ (DNI 61506720)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61506720',
    @Contra             = N'61506720',
    @Nombre             = N'OSCAR',
    @Apellido           = N'MENDOZA HERNANDEZ',
    @Dni                = N'61506720',
    @Email              = N'OSCAR@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'08102008',
    @Direccion          = N'MZ. A LT. 06 ASOC. STA ELENA',
    @Distrito           = N'VES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'973474362',
    @TelApoderado       = N'993030313',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/16d8465c-3df6-414f-af08-3e43c2c0100c_IMG_20260401_111102_938.jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61506720: ' + @M; ELSE PRINT 'ERROR DNI 61506720: ' + @M;
GO

-- [82/318] DASHA IOANNYS QUIROZ DEZA (DNI 61510610)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61510610',
    @Contra             = N'61510610',
    @Nombre             = N'DASHA IOANNYS',
    @Apellido           = N'QUIROZ DEZA',
    @Dni                = N'61510610',
    @Email              = N'IOANNYS@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'01112008',
    @Direccion          = N'NUESTRA SRA DE GUADALUPE MZ E LT 3 -  SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'952125399',
    @TelApoderado       = N'907008705',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/b4aa5c42-55d9-4129-9f5e-94a6c00751e3_WhatsApp Image 2026-03-24 at 9.47.53 AM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61510610: ' + @M; ELSE PRINT 'ERROR DNI 61510610: ' + @M;
GO

-- [83/318] DANNA LUCIA FARFAN QUISPE (DNI 61511403)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61511403',
    @Contra             = N'61511403',
    @Nombre             = N'DANNA LUCIA',
    @Apellido           = N'FARFAN QUISPE',
    @Dni                = N'61511403',
    @Email              = N'DANNA@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'06092008',
    @Direccion          = N'LOS NOGALES 150 COOP. LA FORTALEZA - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'992733906',
    @TelApoderado       = N'941516730',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/0aa8dced-88a1-4a27-af4b-76ec7fb81934_WhatsApp Image 2026-03-17 at 3.59.14 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61511403: ' + @M; ELSE PRINT 'ERROR DNI 61511403: ' + @M;
GO

-- [84/318] KEVIN LUIS ASCUE CORREA (DNI 61511784)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61511784',
    @Contra             = N'61511784',
    @Nombre             = N'KEVIN LUIS',
    @Apellido           = N'ASCUE CORREA',
    @Dni                = N'61511784',
    @Email              = N'KEVIN@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'04022009',
    @Direccion          = N'JR. SAN LUIS PAMPLONA ALTA MZ X-7 LT 07 -SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'958093349',
    @TelApoderado       = N'980588063',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/4b9dc487-1b3b-4a44-87f4-4c1fee72a14d_WhatsApp Image 2026-03-17 at 3.59.10 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61511784: ' + @M; ELSE PRINT 'ERROR DNI 61511784: ' + @M;
GO

-- [85/318] FABIAN EDUARDO QUISPE PINTO (DNI 61516877)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61516877',
    @Contra             = N'61516877',
    @Nombre             = N'FABIAN EDUARDO',
    @Apellido           = N'QUISPE PINTO',
    @Dni                = N'61516877',
    @Email              = N'FABIAN@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'13122008',
    @Direccion          = N'MZ B2 LT 4 - LOS JARDINES DE LA RINCONADA - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'907439336',
    @TelApoderado       = N'991213830',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/f86a4bdc-fc1b-4676-9298-18d338f7e03a_WhatsApp Image 2026-02-05 at 9.56.35 AM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61516877: ' + @M; ELSE PRINT 'ERROR DNI 61516877: ' + @M;
GO

-- [86/318] DAVID ANDRE HAU MEZA (DNI 61516928)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61516928',
    @Contra             = N'61516928',
    @Nombre             = N'DAVID ANDRE',
    @Apellido           = N'HAU MEZA',
    @Dni                = N'61516928',
    @Email              = N'DAVID@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'15122008',
    @Direccion          = N'LAS ANTARAS 255 - URB. SAN JUAN BAUTISTA - CHORRILLOS',
    @Distrito           = N'CHORRILLOS',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'984346173',
    @TelApoderado       = N'993006594',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/140719de-c243-4b20-bf18-91afdb82614e_perfil.jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61516928: ' + @M; ELSE PRINT 'ERROR DNI 61516928: ' + @M;
GO

-- [87/318] GABRIELA SUSANA LEDESMA TORRES (DNI 61529497)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61529497',
    @Contra             = N'61529497',
    @Nombre             = N'GABRIELA SUSANA',
    @Apellido           = N'LEDESMA TORRES',
    @Dni                = N'61529497',
    @Email              = N'61529497@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'27122008',
    @Direccion          = N'ENRIQUE OPPENHEIMER 498 ZN B',
    @Distrito           = N'SJM',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'901534272',
    @TelApoderado       = N'928743390',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/e1b98a99-2c1f-4f99-a4b7-3510e1456c24_WhatsApp Image 2026-01-10 at 1.31.10 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61529497: ' + @M; ELSE PRINT 'ERROR DNI 61529497: ' + @M;
GO

-- [88/318] ARMANDO ADRIAN CABALLA MENDOZA (DNI 61530086)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61530086',
    @Contra             = N'61530086',
    @Nombre             = N'ARMANDO ADRIAN',
    @Apellido           = N'CABALLA MENDOZA',
    @Dni                = N'61530086',
    @Email              = N'ARMANDO@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'10122008',
    @Direccion          = N'AV. EL CARMEN - 736 - SAN ROQUE SURCO',
    @Distrito           = N'SURCO',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'906433686',
    @TelApoderado       = N'903256066',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/59abf5f1-f2ae-4932-a981-9584afbe887a_WhatsApp Image 2026-03-20 at 9.51.30 AM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61530086: ' + @M; ELSE PRINT 'ERROR DNI 61530086: ' + @M;
GO

-- [89/318] ALFREDO JESUS LEYVA SANCHEZ (DNI 61538801)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61538801',
    @Contra             = N'61538801',
    @Nombre             = N'ALFREDO JESUS',
    @Apellido           = N'LEYVA SANCHEZ',
    @Dni                = N'61538801',
    @Email              = N'ALFREDO@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'10112008',
    @Direccion          = N'AA.HH. NUEVO MILENIO MZ J LT 17 - CHORRILLOS',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'932002984',
    @TelApoderado       = N'928217318',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/4fb9ae04-f789-4a7d-b098-46bef6642bef_WhatsApp Image 2026-01-12 at 7.40.55 AM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61538801: ' + @M; ELSE PRINT 'ERROR DNI 61538801: ' + @M;
GO

-- [90/318] JIMENA XIOMARA DEPAZ HUANCAS (DNI 61539230)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61539230',
    @Contra             = N'61539230',
    @Nombre             = N'JIMENA XIOMARA',
    @Apellido           = N'DEPAZ HUANCAS',
    @Dni                = N'61539230',
    @Email              = N'JIMENA@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'23122008',
    @Direccion          = N'MZ F - LOTE 8 - TACALA - CHORRILLOS',
    @Distrito           = N'CHORRILLOS',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'927185294',
    @TelApoderado       = N'910434863',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/4b3bf204-10c3-4694-96d3-6a45809d3cd5_G0c3sMCbsAA-tuw.png',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61539230: ' + @M; ELSE PRINT 'ERROR DNI 61539230: ' + @M;
GO

-- [91/318] ANTONY ANDERSON SERNA GUERRERO (DNI 61582577)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61582577',
    @Contra             = N'61582577',
    @Nombre             = N'ANTONY ANDERSON',
    @Apellido           = N'SERNA GUERRERO',
    @Dni                = N'61582577',
    @Email              = N'61582577@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'08012009',
    @Direccion          = N'MZ. H LT. 13 FLORES DE VILLA',
    @Distrito           = N'SJM',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'986653161',
    @TelApoderado       = N'986653161',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/b3198dd4-677e-4617-aca2-942859f34a97_WhatsApp Image 2026-01-13 at 9.40.39 AM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61582577: ' + @M; ELSE PRINT 'ERROR DNI 61582577: ' + @M;
GO

-- [92/318] DIANA RAMIREZ ZUMBA (DNI 61596763)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61596763',
    @Contra             = N'61596763',
    @Nombre             = N'DIANA',
    @Apellido           = N'RAMIREZ ZUMBA',
    @Dni                = N'61596763',
    @Email              = N'61596763@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'17092008',
    @Direccion          = N'CALLE TNTE. JIMENEZ # 381 - LA CAMPIÑA - CHORRILLOS',
    @Distrito           = N'CHORRILLOS',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'997513398',
    @TelApoderado       = N'962379220',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/c996b1eb-6f45-49ff-8d56-4e71d407b620_WhatsApp Image 2026-06-01 at 11.37.48 AM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61596763: ' + @M; ELSE PRINT 'ERROR DNI 61596763: ' + @M;
GO

-- [93/318] DAVID MOISES VEGA PUMALLANQUI (DNI 61616950)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61616950',
    @Contra             = N'61616950',
    @Nombre             = N'DAVID MOISES',
    @Apellido           = N'VEGA PUMALLANQUI',
    @Dni                = N'61616950',
    @Email              = N'61616950@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'11102008',
    @Direccion          = N'MZ B LT 19 - SAN JOSE 1 - CHORRILLOS',
    @Distrito           = N'CHORRILLOS',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'991571604',
    @TelApoderado       = N'922553137',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/0de050f2-c0e1-492b-ad9d-9c82fd1bae8c_WhatsApp Image 2026-03-17 at 3.59.11 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61616950: ' + @M; ELSE PRINT 'ERROR DNI 61616950: ' + @M;
GO

-- [94/318] ALESSANDRA RODRIGUEZ ROJAS (DNI 61627650)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61627650',
    @Contra             = N'61627650',
    @Nombre             = N'ALESSANDRA',
    @Apellido           = N'RODRIGUEZ ROJAS',
    @Dni                = N'61627650',
    @Email              = N'ALESSANDRA@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'06122008',
    @Direccion          = N'CALLE LAS AZUCENAS URB VIÑA DEL MAR',
    @Distrito           = N'VES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'992776995',
    @TelApoderado       = N'959255892',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/e2e95d3e-5581-4ff8-926b-bc8ee707f6ab_WhatsApp Image 2026-01-10 at 1.24.31 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61627650: ' + @M; ELSE PRINT 'ERROR DNI 61627650: ' + @M;
GO

-- [95/318] DIEGO ABEL HUAYASCACHI SANTANA (DNI 61742245)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61742245',
    @Contra             = N'61742245',
    @Nombre             = N'DIEGO ABEL',
    @Apellido           = N'HUAYASCACHI SANTANA',
    @Dni                = N'61742245',
    @Email              = N'DIEGO@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'01092009',
    @Direccion          = N'MZ  P LT 1 LAS AMERICAS - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'IEP CARMELITAS HIGH SCHOOL',
    @Grado              = N'5TO',
    @TelPersonal        = N'976715151',
    @TelApoderado       = N'976715151',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/b1b31d50-e32f-4d92-95e8-e6c4a89556a5_Foto carnet (5).jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61742245: ' + @M; ELSE PRINT 'ERROR DNI 61742245: ' + @M;
GO

-- [96/318] ALEXIA MILAGROS SOLIS HUALLPAR (DNI 61742521)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61742521',
    @Contra             = N'61742521',
    @Nombre             = N'ALEXIA MILAGROS',
    @Apellido           = N'SOLIS HUALLPAR',
    @Dni                = N'61742521',
    @Email              = N'ALEXIA@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'29072009',
    @Direccion          = N'MZ N LOTE 13 - AA.HH. LA RINCONADA - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'JULIO CESAR ESCOBAR',
    @Grado              = N'5TO',
    @TelPersonal        = N'945734825',
    @TelApoderado       = N'934242959',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/eb0874ce-6c06-4080-8cd3-22383a36e978_WhatsApp Image 2026-03-30 at 2.32.24 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61742521: ' + @M; ELSE PRINT 'ERROR DNI 61742521: ' + @M;
GO

-- [97/318] DENNY JUNIOR CARDENAS VERA (DNI 61755261)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61755261',
    @Contra             = N'61755261',
    @Nombre             = N'DENNY JUNIOR',
    @Apellido           = N'CARDENAS VERA',
    @Dni                = N'61755261',
    @Email              = N'DENNY@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'29032009',
    @Direccion          = N'MZ X-7 LT 32 VILLA SAN LUIS - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'922712327',
    @TelApoderado       = N'970611240',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/8d543b74-a33f-42b5-bef8-be2f81964269_WhatsApp Image 2026-03-18 at 10.06.45 AM (4).jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61755261: ' + @M; ELSE PRINT 'ERROR DNI 61755261: ' + @M;
GO

-- [98/318] KARLA CELESTE B LUDEÑA CALDERON (DNI 61755375)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61755375',
    @Contra             = N'61755375',
    @Nombre             = N'KARLA CELESTE B',
    @Apellido           = N'LUDEÑA CALDERON',
    @Dni                = N'61755375',
    @Email              = N'KARLA@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'31032009',
    @Direccion          = N'MZ 9A LT 14 - SECTOR ANTUNEZ DE MAYOLO - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'997850131',
    @TelApoderado       = N'980745727',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/ffd81975-b5af-4e22-91e2-7fb889580177_WhatsApp Image 2026-02-05 at 9.54.32 AM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61755375: ' + @M; ELSE PRINT 'ERROR DNI 61755375: ' + @M;
GO

-- [99/318] ANAHI GREYCI CARRANZA ALARCON (DNI 61759097)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61759097',
    @Contra             = N'61759097',
    @Nombre             = N'ANAHI GREYCI',
    @Apellido           = N'CARRANZA ALARCON',
    @Dni                = N'61759097',
    @Email              = N'ANAHI@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'09102008',
    @Direccion          = N'MZ N1 LT 22 FLORES DE VILLA - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'958196395',
    @TelApoderado       = N'978431766',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/15cf0519-bc05-4a3d-9175-c3cf52675447_WhatsApp Image 2026-01-12 at 3.39.28 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61759097: ' + @M; ELSE PRINT 'ERROR DNI 61759097: ' + @M;
GO

-- [100/318] CARIM JASER MATHIAS VELARDE RINCON (DNI 61759135)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61759135',
    @Contra             = N'61759135',
    @Nombre             = N'CARIM JASER MATHIAS',
    @Apellido           = N'VELARDE RINCON',
    @Dni                = N'61759135',
    @Email              = N'CARIM@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'03042009',
    @Direccion          = N'AV. LAS LAGUNAS AA.HH. EL INTI MZ F LOTE 31 - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'IE JOSE MARIA ARGUEDAS',
    @Grado              = N'5TO',
    @TelPersonal        = N'957401302',
    @TelApoderado       = N'929188301',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/688148d6-f5be-4ec5-8400-72c290232a27_WhatsApp Image 2026-04-21 at 3.12.58 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61759135: ' + @M; ELSE PRINT 'ERROR DNI 61759135: ' + @M;
GO

-- [101/318] CARLOS FARID SALAZAR CANCHAYA (DNI 61759251)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
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
IF @R = 1 PRINT 'OK DNI 61759251: ' + @M; ELSE PRINT 'ERROR DNI 61759251: ' + @M;
GO

-- [102/318] NICOLE YAMILE ZEVALLOS AQUINO (DNI 61759894)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61759894',
    @Contra             = N'61759894',
    @Nombre             = N'NICOLE YAMILE',
    @Apellido           = N'ZEVALLOS AQUINO',
    @Dni                = N'61759894',
    @Email              = N'NICOLE@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'13032009',
    @Direccion          = N'CALLE 3 MZD LT3 AH REP DE ALEMAN SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'935621320',
    @TelApoderado       = N'961829319',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/ab13825f-e87f-4b27-ab9d-9a7480b11909_3 (1).jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61759894: ' + @M; ELSE PRINT 'ERROR DNI 61759894: ' + @M;
GO

-- [103/318] REYNA MARIA QUIROZ VILCHEZ (DNI 61760138)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61760138',
    @Contra             = N'61760138',
    @Nombre             = N'REYNA MARIA',
    @Apellido           = N'QUIROZ VILCHEZ',
    @Dni                = N'61760138',
    @Email              = N'REYNA@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'25022009',
    @Direccion          = N'AA.HH. 15 DE SETIEMBRE MZ D LOTE 21 - SAN JUAN DE MIRAFLORES',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'IEP SAN ANDRES',
    @Grado              = N'5TO',
    @TelPersonal        = N'917950463',
    @TelApoderado       = N'900874387',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/70e4d420-ff1b-46eb-b8e1-f5f0c290962a_WhatsApp Image 2026-03-24 at 7.31.19 AM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61760138: ' + @M; ELSE PRINT 'ERROR DNI 61760138: ' + @M;
GO

-- [104/318] VALENTINA NICOL YSASI ACUÑA (DNI 61770643)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61770643',
    @Contra             = N'61770643',
    @Nombre             = N'VALENTINA NICOL',
    @Apellido           = N'YSASI ACUÑA',
    @Dni                = N'61770643',
    @Email              = N'VALENTINA@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'23022009',
    @Direccion          = N'MZ. D LT. 15 REP. DEM. ALEMANA',
    @Distrito           = N'SJM',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'900186378',
    @TelApoderado       = N'965813679',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/80b585c1-e34e-4877-b4f5-f99a0dd09a6c_WhatsApp Image 2026-01-12 at 3.41.29 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61770643: ' + @M; ELSE PRINT 'ERROR DNI 61770643: ' + @M;
GO

-- [105/318] MATHIAS BENJAMIN VILCA RIVERA (DNI 61791537)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61791537',
    @Contra             = N'61791537',
    @Nombre             = N'MATHIAS BENJAMIN',
    @Apellido           = N'VILCA RIVERA',
    @Dni                = N'61791537',
    @Email              = N'MATHIAS@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'30032009',
    @Direccion          = N'COOP UMAMARCA MZ. K LT. 24 CA. LOS CEDROS',
    @Distrito           = N'SJM',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'958809842',
    @TelApoderado       = N'952299917',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/1c32cf00-3352-4919-9065-9b191b84c848_WhatsApp Image 2026-01-12 at 3.43.09 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61791537: ' + @M; ELSE PRINT 'ERROR DNI 61791537: ' + @M;
GO

-- [106/318] BIANCA JIMENA FLORES ARONI (DNI 61801187)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61801187',
    @Contra             = N'61801187',
    @Nombre             = N'BIANCA JIMENA',
    @Apellido           = N'FLORES ARONI',
    @Dni                = N'61801187',
    @Email              = N'BIANCA@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'04092009',
    @Direccion          = N'SAN JOSE DE VILLA MZ "D" LOTE "15" - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'IE 6097 MATEO PUMACAHUA',
    @Grado              = N'5TO',
    @TelPersonal        = N'952156987',
    @TelApoderado       = N'952156987',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = NULL,
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61801187: ' + @M; ELSE PRINT 'ERROR DNI 61801187: ' + @M;
GO

-- [107/318] JOSUE PILLACA ONCEBAY (DNI 61801265)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61801265',
    @Contra             = N'61801265',
    @Nombre             = N'JOSUE',
    @Apellido           = N'PILLACA ONCEBAY',
    @Dni                = N'61801265',
    @Email              = N'JOSUE@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'26042009',
    @Direccion          = N'MZ C11 -  LOTE 15 - LEONCIO PRADO PAMPLONA ALTA - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'ADVENTISTA REDENTOR',
    @Grado              = N'5TO',
    @TelPersonal        = N'922756539',
    @TelApoderado       = N'980506092',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/05f0e889-9eba-4ae7-af6b-4bd872895db9_WhatsApp Image 2026-03-26 at 5.03.26 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61801265: ' + @M; ELSE PRINT 'ERROR DNI 61801265: ' + @M;
GO

-- [108/318] ARIANA MARIANA JIMENEZ TAIPE (DNI 61801861)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61801861',
    @Contra             = N'61801861',
    @Nombre             = N'ARIANA MARIANA',
    @Apellido           = N'JIMENEZ TAIPE',
    @Dni                = N'61801861',
    @Email              = N'61801861@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'10062009',
    @Direccion          = N'MZ K LOTE 22 GRUPO 22A - SECT. 1 - VES',
    @Distrito           = N'VILLA EL SALVADOR',
    @Colegio            = N'IEP INNOVA SCHOOL',
    @Grado              = N'5TO',
    @TelPersonal        = N'923571660',
    @TelApoderado       = N'993772772',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/4166c01e-3462-43fa-8efe-8de863466b41_WhatsApp Image 2026-03-14 at 11.54.49 AM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61801861: ' + @M; ELSE PRINT 'ERROR DNI 61801861: ' + @M;
GO

-- [109/318] DAVID CALLA BIZARRO (DNI 61802063)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61802063',
    @Contra             = N'61802063',
    @Nombre             = N'DAVID',
    @Apellido           = N'CALLA BIZARRO',
    @Dni                = N'61802063',
    @Email              = N'61802063@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'18072009',
    @Direccion          = N'A.H 20 DE MAYO MZ. D LT. 16',
    @Distrito           = N'SJM',
    @Colegio            = N'IE SAN JUAN',
    @Grado              = N'5 TO',
    @TelPersonal        = N'943580885',
    @TelApoderado       = N'983405225',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/36d08779-87e9-4310-91d7-f2621b4e1a8f_DAVID CALLA BIZARRO.jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61802063: ' + @M; ELSE PRINT 'ERROR DNI 61802063: ' + @M;
GO

-- [110/318] ANDRES NICANOR BECERRA PACHECO (DNI 61802087)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61802087',
    @Contra             = N'61802087',
    @Nombre             = N'ANDRES NICANOR',
    @Apellido           = N'BECERRA PACHECO',
    @Dni                = N'61802087',
    @Email              = N'ANDRES@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'12072009',
    @Direccion          = N'MZ H LT 01 - AA.HH. JAVIER HERAUD - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'IE TUPAC AMARU 7055 - VMT',
    @Grado              = N'5TO',
    @TelPersonal        = N'960749657',
    @TelApoderado       = N'902165671',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/8e55fd01-7f8a-4c72-bd90-6fc362ca38af_WhatsApp Image 2026-03-21 at 7.28.38 AM (4).jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61802087: ' + @M; ELSE PRINT 'ERROR DNI 61802087: ' + @M;
GO

-- [111/318] ESTEFANO JOSSET CONTRERAS ESPINOZA (DNI 61802112)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61802112',
    @Contra             = N'61802112',
    @Nombre             = N'ESTEFANO JOSSET',
    @Apellido           = N'CONTRERAS ESPINOZA',
    @Dni                = N'61802112',
    @Email              = N'ESTEFANO@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'12062009',
    @Direccion          = N'MANUEL VELARDE # 820 ZN "D" - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'IEP SAN MARCOS',
    @Grado              = N'5TO',
    @TelPersonal        = N'945250237',
    @TelApoderado       = N'945250237',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/63517833-e2a7-49c3-b6b0-76ef2b65faf1_WhatsApp Image 2026-04-28 at 4.58.53 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61802112: ' + @M; ELSE PRINT 'ERROR DNI 61802112: ' + @M;
GO

-- [112/318] ANDERSON SMITH CHUQUIHUANCA ARANDA (DNI 61802136)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61802136',
    @Contra             = N'61802136',
    @Nombre             = N'ANDERSON SMITH',
    @Apellido           = N'CHUQUIHUANCA ARANDA',
    @Dni                = N'61802136',
    @Email              = N'ANDERSON@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'30082009',
    @Direccion          = N'MZ M LOTE 21 NAZARENO PAMPLONA ALTA -SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'IE NAZARENO',
    @Grado              = N'5TO',
    @TelPersonal        = N'977927414',
    @TelApoderado       = N'991482033',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/250da64e-5caf-4773-98bf-1c88b5bb28ff_WhatsApp Image 2026-03-21 at 9.36.26 AM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61802136: ' + @M; ELSE PRINT 'ERROR DNI 61802136: ' + @M;
GO

-- [113/318] ANGELINE MASIEL CARDENAS ORTIZ (DNI 61802307)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61802307',
    @Contra             = N'61802307',
    @Nombre             = N'ANGELINE MASIEL',
    @Apellido           = N'CARDENAS ORTIZ',
    @Dni                = N'61802307',
    @Email              = N'ANGELINE@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'23052009',
    @Direccion          = N'CALLE 3 MZ E LT 8 - MARTIRES DE SAN JUAN - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'IE JAVIER HERAUD',
    @Grado              = N'4TO',
    @TelPersonal        = N'976095824',
    @TelApoderado       = N'976070042',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/7c7b854a-e3d0-4cf9-9588-3a4f51167327_Foto carnet (3).jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61802307: ' + @M; ELSE PRINT 'ERROR DNI 61802307: ' + @M;
GO

-- [114/318] LUANA MORELLY MEDINA VELARDE (DNI 61824980)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61824980',
    @Contra             = N'61824980',
    @Nombre             = N'LUANA MORELLY',
    @Apellido           = N'MEDINA VELARDE',
    @Dni                = N'61824980',
    @Email              = N'LUANA@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'07062009',
    @Direccion          = N'VILLA DE JESUS MZ 11 LT 7 VES',
    @Distrito           = N'VILLA EL SALVADOR',
    @Colegio            = N'I.E HEROES DEL ALTO CENEPA 6070',
    @Grado              = N'5TO',
    @TelPersonal        = N'914712879',
    @TelApoderado       = N'997123625',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/efdca78b-4022-4515-80c7-ead808006eb1_perfil.jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61824980: ' + @M; ELSE PRINT 'ERROR DNI 61824980: ' + @M;
GO

-- [115/318] YUBITZA CCOICCA FLORES (DNI 61842805)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61842805',
    @Contra             = N'61842805',
    @Nombre             = N'YUBITZA',
    @Apellido           = N'CCOICCA FLORES',
    @Dni                = N'61842805',
    @Email              = N'YUBITZA@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'17082009',
    @Direccion          = N'MZ "J" LOTE "5" AA.HH. TAMAYO DIAZ',
    @Distrito           = N'CHORRILLOS',
    @Colegio            = N'IE MATEO PUMACAHUA',
    @Grado              = N'5TO',
    @TelPersonal        = N'952037496',
    @TelApoderado       = N'954100437',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/04b1693a-e13e-400d-aa65-70b9e7e90dfa_WhatsApp Image 2026-06-11 at 3.07.49 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61842805: ' + @M; ELSE PRINT 'ERROR DNI 61842805: ' + @M;
GO

-- [116/318] JHONNY LEO VELIZ BENITES (DNI 61843531)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61843531',
    @Contra             = N'61843531',
    @Nombre             = N'JHONNY LEO',
    @Apellido           = N'VELIZ BENITES',
    @Dni                = N'61843531',
    @Email              = N'JHONNY@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'15082009',
    @Direccion          = N'AMPLIACION VIRGEN DEL BUEN PASO MZD8 LT2',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'FE Y ALEGRIA 03',
    @Grado              = N'5TO',
    @TelPersonal        = N'976804233',
    @TelApoderado       = N'943290252',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/14ea209d-70cd-48a6-b4d6-17c141f19dd5_10 (1).jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61843531: ' + @M; ELSE PRINT 'ERROR DNI 61843531: ' + @M;
GO

-- [117/318] MARICIELO GARRIAZO VIZA (DNI 61845000)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61845000',
    @Contra             = N'61845000',
    @Nombre             = N'MARICIELO',
    @Apellido           = N'GARRIAZO VIZA',
    @Dni                = N'61845000',
    @Email              = N'MARICIELO@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'02092009',
    @Direccion          = N'MZ A LT8 AA.HH JMA SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'FLORES DE VILLA 7230',
    @Grado              = N'5TO',
    @TelPersonal        = N'925797713',
    @TelApoderado       = N'900455165',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/73397c2d-39ca-4b98-87f6-191c550b80f6_WhatsApp Image 2026-01-10 at 2.19.20 PM (3).jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61845000: ' + @M; ELSE PRINT 'ERROR DNI 61845000: ' + @M;
GO

-- [118/318] ZADITH CRISTINA SANDOVAL ACHO (DNI 61851485)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61851485',
    @Contra             = N'61851485',
    @Nombre             = N'ZADITH CRISTINA',
    @Apellido           = N'SANDOVAL ACHO',
    @Dni                = N'61851485',
    @Email              = N'ZADITH@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'29072009',
    @Direccion          = N'VILLA SOLIDARIDAD 2DA ETAPA MZ K2 LOTE 24 - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'IE LEONARD EULER',
    @Grado              = N'5TO',
    @TelPersonal        = N'934968983',
    @TelApoderado       = N'934017128',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/acf2b6ac-66ba-438c-804f-a05df8dd8e63_WhatsApp Image 2026-04-28 at 4.24.54 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61851485: ' + @M; ELSE PRINT 'ERROR DNI 61851485: ' + @M;
GO

-- [119/318] ANTHONY ORLANDO MACAVILCA PACHECO (DNI 61851846)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61851846',
    @Contra             = N'61851846',
    @Nombre             = N'ANTHONY ORLANDO',
    @Apellido           = N'MACAVILCA PACHECO',
    @Dni                = N'61851846',
    @Email              = N'ANTHONY@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'25082009',
    @Direccion          = N'AV SANTA ANITA MZ A1 LT 7 VILLA MARINA',
    @Distrito           = NULL,
    @Colegio            = N'SAN PEDRO DE CHORRILLOS',
    @Grado              = N'5 TO',
    @TelPersonal        = N'956458731',
    @TelApoderado       = N'956458731',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/2d5c9386-43d3-45b2-a828-3f1bdd75ba38_macavilca.jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61851846: ' + @M; ELSE PRINT 'ERROR DNI 61851846: ' + @M;
GO

-- [120/318] ANTONELLA ALVAREZ CAMPOS (DNI 61851895)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61851895',
    @Contra             = N'61851895',
    @Nombre             = N'ANTONELLA',
    @Apellido           = N'ALVAREZ CAMPOS',
    @Dni                = N'61851895',
    @Email              = N'ANTONELLA@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'27082009',
    @Direccion          = N'MZ I1 LT27 - ALF UGARTE P.A. - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'IE NIÑO JESUS PARROQUIAL',
    @Grado              = N'5TO',
    @TelPersonal        = N'919468452',
    @TelApoderado       = N'987011951',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/52adc8d0-43f3-462d-ad6c-8b3bcf6d48cc_WhatsApp Image 2026-03-26 at 5.03.08 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61851895: ' + @M; ELSE PRINT 'ERROR DNI 61851895: ' + @M;
GO

-- [121/318] VICTOR MINAYA LOZADA (DNI 61852062)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61852062',
    @Contra             = N'61852062',
    @Nombre             = N'VICTOR',
    @Apellido           = N'MINAYA LOZADA',
    @Dni                = N'61852062',
    @Email              = N'61852062@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'04092009',
    @Direccion          = N'CALLE JOSE MARIA VILCHEZ # 150 - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'LINCOLN',
    @Grado              = N'5',
    @TelPersonal        = N'922329611',
    @TelApoderado       = N'962216594',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/1ad4c07b-5389-4571-8dd6-1c3909702f25_WhatsApp Image 2026-06-06 at 10.39.03 AM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61852062: ' + @M; ELSE PRINT 'ERROR DNI 61852062: ' + @M;
GO

-- [122/318] ANTHONY MIJAEL DIAZ ALCALA (DNI 61852402)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61852402',
    @Contra             = N'61852402',
    @Nombre             = N'ANTHONY MIJAEL',
    @Apellido           = N'DIAZ ALCALA',
    @Dni                = N'61852402',
    @Email              = N'MIJAEL@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'26092009',
    @Direccion          = N'MZ K LOTE 10 - LOS MARTIRES DE SAN JUAN MIRAFLORES',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'JAVIER HERAUD',
    @Grado              = N'5TO',
    @TelPersonal        = N'992717191',
    @TelApoderado       = N'936373110',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = NULL,
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61852402: ' + @M; ELSE PRINT 'ERROR DNI 61852402: ' + @M;
GO

-- [123/318] PAUL ANDRES HUAMAN HUAYANAY (DNI 61878690)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61878690',
    @Contra             = N'61878690',
    @Nombre             = N'PAUL ANDRES',
    @Apellido           = N'HUAMAN HUAYANAY',
    @Dni                = N'61878690',
    @Email              = N'PAUL@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'09112009',
    @Direccion          = N'AV. CENTRAL 309 - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'IEP ANIES SCHOOL',
    @Grado              = N'5TO',
    @TelPersonal        = N'933814193',
    @TelApoderado       = N'904170989',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/81d37c51-a6e6-4359-913a-9698783e48ec_WhatsApp Image 2026-03-21 at 7.28.37 AM (3).jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61878690: ' + @M; ELSE PRINT 'ERROR DNI 61878690: ' + @M;
GO

-- [124/318] ZAMIRA CHARLOTTE CAYRE PACHACAMA (DNI 61891330)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61891330',
    @Contra             = N'61891330',
    @Nombre             = N'ZAMIRA CHARLOTTE',
    @Apellido           = N'CAYRE PACHACAMA',
    @Dni                = N'61891330',
    @Email              = N'CHARLOTTE@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'09062009',
    @Direccion          = N'MZ M LOTE 3 PACIFICO 1 AV. RAIMONDI - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'IE SAN JUAN',
    @Grado              = N'5',
    @TelPersonal        = N'984636991',
    @TelApoderado       = N'969573086',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/15ad08b4-fec8-4fc8-8564-9145cbec6c95_WhatsApp Image 2026-03-25 at 4.52.24 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61891330: ' + @M; ELSE PRINT 'ERROR DNI 61891330: ' + @M;
GO

-- [125/318] KIARA ANGELY GRANDEZ CABELLO (DNI 61901038)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61901038',
    @Contra             = N'61901038',
    @Nombre             = N'KIARA ANGELY',
    @Apellido           = N'GRANDEZ CABELLO',
    @Dni                = N'61901038',
    @Email              = N'61901038@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'14092009',
    @Direccion          = N'MZ N2 LT 25 LA RINCONADA P.A SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'I.E EL NAZARENO 7087',
    @Grado              = N'5TO',
    @TelPersonal        = N'933338703',
    @TelApoderado       = N'974293043',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/eff2cc9e-6ea4-4bbe-9d14-7a0512eff67e_13.jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61901038: ' + @M; ELSE PRINT 'ERROR DNI 61901038: ' + @M;
GO

-- [126/318] LUCY ESTELA RAYME VALDERRAMA (DNI 61901312)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61901312',
    @Contra             = N'61901312',
    @Nombre             = N'LUCY ESTELA',
    @Apellido           = N'RAYME VALDERRAMA',
    @Dni                = N'61901312',
    @Email              = N'LUCY@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'07102009',
    @Direccion          = N'JR. PROGRESO # 1621 - PJ HOGAR POLICIAL - VMT',
    @Distrito           = N'VILLA MARIA DEL TRIUNFO',
    @Colegio            = N'IE 7073 - SANTA ROSA',
    @Grado              = N'5TO',
    @TelPersonal        = N'907422036',
    @TelApoderado       = N'902874618',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/38206484-cfaa-471d-b4a4-77db2405d816_WhatsApp Image 2026-06-05 at 8.40.51 AM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61901312: ' + @M; ELSE PRINT 'ERROR DNI 61901312: ' + @M;
GO

-- [127/318] JAIR JUSTIN HUAMAN FLORES (DNI 61908936)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61908936',
    @Contra             = N'61908936',
    @Nombre             = N'JAIR JUSTIN',
    @Apellido           = N'HUAMAN FLORES',
    @Dni                = N'61908936',
    @Email              = N'JAIR@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'20102009',
    @Direccion          = N'VILLA MARIA',
    @Distrito           = N'VILLA MARIA DEL TRIUNFO',
    @Colegio            = N'VILLA LIMATAMBO',
    @Grado              = N'5TO',
    @TelPersonal        = N'907787320',
    @TelApoderado       = N'900950331',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/976fe127-519c-4af5-ba9f-9652f64c9831_WhatsApp Image 2026-04-06 at 5.12.31 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61908936: ' + @M; ELSE PRINT 'ERROR DNI 61908936: ' + @M;
GO

-- [128/318] ANGIE ANTONELLA GONZALES MONTALVO (DNI 61912529)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61912529',
    @Contra             = N'61912529',
    @Nombre             = N'ANGIE ANTONELLA',
    @Apellido           = N'GONZALES MONTALVO',
    @Dni                = N'61912529',
    @Email              = N'ANGIE@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'29102009',
    @Direccion          = N'CALLE ARQUIMEDES MZ B1 - LOTE 16 - URB. LA CAMPIÑA - CHORRILLOS',
    @Distrito           = N'CHORRILLOS',
    @Colegio            = N'IE MERCEDES INDACOCHEA',
    @Grado              = N'5TO',
    @TelPersonal        = N'989919706',
    @TelApoderado       = N'977209592',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/120cabea-c66e-485c-ba1a-acc0a33bd9f0_WhatsApp Image 2026-05-13 at 5.06.18 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61912529: ' + @M; ELSE PRINT 'ERROR DNI 61912529: ' + @M;
GO

-- [129/318] ROMINA SHANTAL AGUILAR PALOMINO (DNI 61932289)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61932289',
    @Contra             = N'61932289',
    @Nombre             = N'ROMINA SHANTAL',
    @Apellido           = N'AGUILAR PALOMINO',
    @Dni                = N'61932289',
    @Email              = N'ROMINA@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'27092009',
    @Direccion          = N'MZ G6 LT 17 SECT 5 DE MAYO P. ALTA - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'LEONCIO PRADO',
    @Grado              = N'5TO',
    @TelPersonal        = N'984789031',
    @TelApoderado       = N'987110679',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/97cde0b8-48cf-4241-ab38-ac0acdf4aa34_WhatsApp Image 2026-04-07 at 4.56.30 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61932289: ' + @M; ELSE PRINT 'ERROR DNI 61932289: ' + @M;
GO

-- [130/318] DANIEL LEONIVES CHIMPAY ROCA (DNI 61933199)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61933199',
    @Contra             = N'61933199',
    @Nombre             = N'DANIEL LEONIVES',
    @Apellido           = N'CHIMPAY ROCA',
    @Dni                = N'61933199',
    @Email              = N'DANIEL@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'25102009',
    @Direccion          = N'URB. TERRAZAS DE VILLA - MZ E LT 12 - CHORRILLOS',
    @Distrito           = N'CHORRILLOS',
    @Colegio            = N'IE TUPAC AMARU II',
    @Grado              = N'5TO',
    @TelPersonal        = N'971347174',
    @TelApoderado       = N'927107225',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/2b3a2c33-9428-4ab6-bbef-e5c0a0bdb056_WhatsApp Image 2026-06-05 at 8.40.51 AM (1).jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61933199: ' + @M; ELSE PRINT 'ERROR DNI 61933199: ' + @M;
GO

-- [131/318] ALEXANDRA IRAYDA MARZANO GOMEZ (DNI 61948069)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61948069',
    @Contra             = N'61948069',
    @Nombre             = N'ALEXANDRA IRAYDA',
    @Apellido           = N'MARZANO GOMEZ',
    @Dni                = N'61948069',
    @Email              = N'ALEXANDRA@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'05012009',
    @Direccion          = N'PROLOGANCION MARTIR JOSE OLAYA - MZ B LOTE 11 - PAMPLONA BAJA -SJM',
    @Distrito           = N'SAN JUAN DE MIRFAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'991413385',
    @TelApoderado       = N'952480984',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/2aebd925-9153-441a-abc8-02b4a613fc33_WhatsApp Image 2026-04-08 at 9.43.10 AM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61948069: ' + @M; ELSE PRINT 'ERROR DNI 61948069: ' + @M;
GO

-- [132/318] BRIAN ANTHONY GORDON GARCIA (DNI 61956249)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61956249',
    @Contra             = N'61956249',
    @Nombre             = N'BRIAN ANTHONY',
    @Apellido           = N'GORDON GARCIA',
    @Dni                = N'61956249',
    @Email              = N'BRIAN@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'11042009',
    @Direccion          = N'SJM',
    @Distrito           = N'SJM',
    @Colegio            = N'IEP PALP',
    @Grado              = N'5TO',
    @TelPersonal        = N'917846991',
    @TelApoderado       = N'929141025',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = NULL,
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61956249: ' + @M; ELSE PRINT 'ERROR DNI 61956249: ' + @M;
GO

-- [133/318] JHIMY EDGAR GALVEZ YARANGA (DNI 61964709)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61964709',
    @Contra             = N'61964709',
    @Nombre             = N'JHIMY EDGAR',
    @Apellido           = N'GALVEZ YARANGA',
    @Dni                = N'61964709',
    @Email              = N'JHIMY@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'07072009',
    @Direccion          = N'AV. SAMUEL VILLARAN 224 - CIUDAD DE DIOS',
    @Distrito           = N'SJM',
    @Colegio            = N'INCA PACHACUTEC IE.',
    @Grado              = N'5 TO',
    @TelPersonal        = NULL,
    @TelApoderado       = N'989572873',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/dbe54f16-a181-4168-990c-af32b3286219_WhatsApp Image 2026-01-10 at 1.26.15 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61964709: ' + @M; ELSE PRINT 'ERROR DNI 61964709: ' + @M;
GO

-- [134/318] TRACY ALEXANDRA LOPEZ ROJAS (DNI 61981912)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61981912',
    @Contra             = N'61981912',
    @Nombre             = N'TRACY ALEXANDRA',
    @Apellido           = N'LOPEZ ROJAS',
    @Dni                = N'61981912',
    @Email              = N'TRACY@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'20062009',
    @Direccion          = N'SECTOR 6 GRUPO 3A MZ G LT22 - VES',
    @Distrito           = N'VILLA EL SALVADOR',
    @Colegio            = N'IE HEROES DE SAN JUAN',
    @Grado              = N'5TO',
    @TelPersonal        = N'917491936',
    @TelApoderado       = N'900207258',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/a1c4e7a5-9989-4837-840b-6949a31d5298_WhatsApp Image 2026-03-21 at 9.32.29 AM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61981912: ' + @M; ELSE PRINT 'ERROR DNI 61981912: ' + @M;
GO

-- [135/318] TIM MAX HERNANDEZ ACUÑA (DNI 61995687)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61995687',
    @Contra             = N'61995687',
    @Nombre             = N'TIM MAX',
    @Apellido           = N'HERNANDEZ ACUÑA',
    @Dni                = N'61995687',
    @Email              = N'TIM@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'25052009',
    @Direccion          = N'MZ E LOTE 40 - CALLE LOS CLAVELES - SURCO',
    @Distrito           = N'SURCO',
    @Colegio            = N'LOS PROCERES - SURCO',
    @Grado              = N'5TO',
    @TelPersonal        = N'920248746',
    @TelApoderado       = N'920248746',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = NULL,
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61995687: ' + @M; ELSE PRINT 'ERROR DNI 61995687: ' + @M;
GO

-- [136/318] ALONSO MIGUEL PUZA HUESA (DNI 61995932)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'61995932',
    @Contra             = N'61995932',
    @Nombre             = N'ALONSO MIGUEL',
    @Apellido           = N'PUZA HUESA',
    @Dni                = N'61995932',
    @Email              = N'ALONSO@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'17062009',
    @Direccion          = N'PROLONGACION  CESAR CANEVARO MZ K LT 5 - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'IE RAMON CASTILLA',
    @Grado              = N'5TO',
    @TelPersonal        = N'907218238',
    @TelApoderado       = N'961775175',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/3e03171f-edba-4099-9e23-aafcd489ccd0_WhatsApp Image 2026-06-05 at 8.40.54 AM (1).jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 61995932: ' + @M; ELSE PRINT 'ERROR DNI 61995932: ' + @M;
GO

-- [137/318] RUT MARIA AGUILAR SAAVEDRA (DNI 62009536)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'62009536',
    @Contra             = N'62009536',
    @Nombre             = N'RUT MARIA',
    @Apellido           = N'AGUILAR SAAVEDRA',
    @Dni                = N'62009536',
    @Email              = N'62009536@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'20112010',
    @Direccion          = N'CP TOCCSO SAURI - HUACCANA - CHICHEROS - APURIMAC',
    @Distrito           = N'VMT',
    @Colegio            = N'JOSE M. ARGUEDAS - APURIMAC',
    @Grado              = N'3RO',
    @TelPersonal        = NULL,
    @TelApoderado       = N'973442503',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/b09f5abf-277a-418e-b673-48d13fd646ad_Foto carnet (1).jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 62009536: ' + @M; ELSE PRINT 'ERROR DNI 62009536: ' + @M;
GO

-- [138/318] ARIANA MOSAURIETA RAMIREZ (DNI 62011023)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'62011023',
    @Contra             = N'62011023',
    @Nombre             = N'ARIANA',
    @Apellido           = N'MOSAURIETA RAMIREZ',
    @Dni                = N'62011023',
    @Email              = N'62011023@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'29012008',
    @Direccion          = N'COOP AMERICA MZ "O" LT 12 - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'904492147',
    @TelApoderado       = N'947101825',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/8adc8303-23cd-4bf8-a1b4-3d36b4812d1d_1000004009.jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 62011023: ' + @M; ELSE PRINT 'ERROR DNI 62011023: ' + @M;
GO

-- [139/318] FABRIZIO MARTIN LOZANO HUAMANI (DNI 62011435)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'62011435',
    @Contra             = N'62011435',
    @Nombre             = N'FABRIZIO MARTIN',
    @Apellido           = N'LOZANO HUAMANI',
    @Dni                = N'62011435',
    @Email              = N'FABRIZIO@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'18122008',
    @Direccion          = N'CALLA STA. CATALINA MZ "A" LOTE 08 - COOP VIV. STA. URSULA - SJM',
    @Distrito           = N'SAN JUAN DE MOIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'987342265',
    @TelApoderado       = N'912317269',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/f647e8fb-6189-49a6-9529-946fd1571394_IMG_20260517_213458_599.jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 62011435: ' + @M; ELSE PRINT 'ERROR DNI 62011435: ' + @M;
GO

-- [140/318] KIARA JAMILE ALVAREZ LLATA (DNI 62011761)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'62011761',
    @Contra             = N'62011761',
    @Nombre             = N'KIARA JAMILE',
    @Apellido           = N'ALVAREZ LLATA',
    @Dni                = N'62011761',
    @Email              = N'62011761@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'13122008',
    @Direccion          = N'MZ C LOTE 8 - COOP AMERICA - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'960753982',
    @TelApoderado       = N'960101770',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/b6ac1c60-2352-43cc-af85-fac909f6f6f8_WhatsApp Image 2026-03-18 at 10.06.45 AM (3).jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 62011761: ' + @M; ELSE PRINT 'ERROR DNI 62011761: ' + @M;
GO

-- [141/318] NICOLE ARACELY SIVIPAUCAR MAMANI (DNI 62011869)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'62011869',
    @Contra             = N'62011869',
    @Nombre             = N'NICOLE ARACELY',
    @Apellido           = N'SIVIPAUCAR MAMANI',
    @Dni                = N'62011869',
    @Email              = N'62011869@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'25122008',
    @Direccion          = N'MZ K LT 01 ROSALES NUEVA RINCONADA P.A. - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'908638570',
    @TelApoderado       = N'949731059',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/080171a6-0de3-456d-b3ef-1b99ea90f177_WhatsApp Image 2026-03-18 at 10.06.45 AM (5).jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 62011869: ' + @M; ELSE PRINT 'ERROR DNI 62011869: ' + @M;
GO

-- [142/318] YANIRA ISABEL RAMOS HUAYHUAS (DNI 62011916)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'62011916',
    @Contra             = N'62011916',
    @Nombre             = N'YANIRA ISABEL',
    @Apellido           = N'RAMOS HUAYHUAS',
    @Dni                = N'62011916',
    @Email              = N'YANIRA@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'31122008',
    @Direccion          = N'MZ A LOTE 10 NUEVO AMANECER ARMATAMBO - CHORRILLOS',
    @Distrito           = N'CHORRILLOS',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'942784024',
    @TelApoderado       = N'959198832',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/2cdb3b67-a8c2-411a-ab8f-5b795ee3f506_perfil.jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 62011916: ' + @M; ELSE PRINT 'ERROR DNI 62011916: ' + @M;
GO

-- [143/318] JOB DANIEL HUARANCCA SANCHEZ (DNI 62011980)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'62011980',
    @Contra             = N'62011980',
    @Nombre             = N'JOB DANIEL',
    @Apellido           = N'HUARANCCA SANCHEZ',
    @Dni                = N'62011980',
    @Email              = N'JOB@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'25122008',
    @Direccion          = N'AA. HH. JAIME YOSHIYAMA MZ  C  LT  8 - VES',
    @Distrito           = N'VILLA EL SALVADOR',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'914552477',
    @TelApoderado       = N'954698448',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/cd44c7b4-d36a-4e7c-a21f-ecf910110398_WhatsApp Image 2026-03-17 at 3.59.25 PM (4).jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 62011980: ' + @M; ELSE PRINT 'ERROR DNI 62011980: ' + @M;
GO

-- [144/318] NAOMI SIOMARA NICOL BARRAZA GARCIA (DNI 62018675)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'62018675',
    @Contra             = N'62018675',
    @Nombre             = N'NAOMI SIOMARA NICOL',
    @Apellido           = N'BARRAZA GARCIA',
    @Dni                = N'62018675',
    @Email              = N'NAOMI@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'22122008',
    @Direccion          = N'MZ C3 LT09 AA.HH. CERRO DE PUQUIO - NVA RINCONADA - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'994637878',
    @TelApoderado       = N'976447174',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/825678ea-8125-4f9e-9390-4ad5571fe3d6_WhatsApp Image 2026-03-20 at 9.50.35 AM (1).jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 62018675: ' + @M; ELSE PRINT 'ERROR DNI 62018675: ' + @M;
GO

-- [145/318] LUANA GERALDINE SANDOVAL SANDOVAL (DNI 62019086)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'62019086',
    @Contra             = N'62019086',
    @Nombre             = N'LUANA GERALDINE',
    @Apellido           = N'SANDOVAL SANDOVAL',
    @Dni                = N'62019086',
    @Email              = N'62019086@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'05012009',
    @Direccion          = N'MZ R5 LOTE 02 JR PIURA LEONCIO PRADO P.B. - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'956670104',
    @TelApoderado       = N'947022732',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/e9bc5bc3-7929-4ea6-aa04-fc698b7f5a04_WhatsApp Image 2026-03-17 at 3.59.22 PM (4).jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 62019086: ' + @M; ELSE PRINT 'ERROR DNI 62019086: ' + @M;
GO

-- [146/318] LUIS FABIAN TAIPE ESCALANTE (DNI 62022128)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'62022128',
    @Contra             = N'62022128',
    @Nombre             = N'LUIS FABIAN',
    @Apellido           = N'TAIPE ESCALANTE',
    @Dni                = N'62022128',
    @Email              = N'62022128@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'14112008',
    @Direccion          = N'MZ "T" LOTE "5" CMTE 36 - MATEO PUMACAHUA - SURCO',
    @Distrito           = N'SURCO',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'962369250',
    @TelApoderado       = N'966487733',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = NULL,
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 62022128: ' + @M; ELSE PRINT 'ERROR DNI 62022128: ' + @M;
GO

-- [147/318] CRISTOFER ESTEFANO ANCASI HUAMANI (DNI 62024280)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'62024280',
    @Contra             = N'62024280',
    @Nombre             = N'CRISTOFER ESTEFANO',
    @Apellido           = N'ANCASI HUAMANI',
    @Dni                = N'62024280',
    @Email              = N'CRISTOFER@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'16012009',
    @Direccion          = N'PAMPLONA ALTA - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'902034606',
    @TelApoderado       = N'912614651',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = NULL,
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 62024280: ' + @M; ELSE PRINT 'ERROR DNI 62024280: ' + @M;
GO

-- [148/318] DAYANA SHANTAL SABOYA CABALLERO (DNI 62049937)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'62049937',
    @Contra             = N'62049937',
    @Nombre             = N'DAYANA SHANTAL',
    @Apellido           = N'SABOYA CABALLERO',
    @Dni                = N'62049937',
    @Email              = N'DAYANA@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'18022009',
    @Direccion          = N'MZ R LOTE 10  - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = NULL,
    @TelApoderado       = N'935163402',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/8937ed21-000e-42c9-a7cf-7e14e59898f0_Foto carnet (3).jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 62049937: ' + @M; ELSE PRINT 'ERROR DNI 62049937: ' + @M;
GO

-- [149/318] MARIO ALONSO CHIPANA GUTIERREZ (DNI 62051915)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'62051915',
    @Contra             = N'62051915',
    @Nombre             = N'MARIO ALONSO',
    @Apellido           = N'CHIPANA GUTIERREZ',
    @Dni                = N'62051915',
    @Email              = N'MARIO@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'15012009',
    @Direccion          = N'JR. MANUEL VELARDE 828 ZONA D - SJM',
    @Distrito           = N'SAN JUA DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'980803213',
    @TelApoderado       = N'969093180',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/a9205269-1eaf-4b5b-8191-d7f449b74044_WhatsApp Image 2026-03-18 at 10.06.45 AM (1).jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 62051915: ' + @M; ELSE PRINT 'ERROR DNI 62051915: ' + @M;
GO

-- [150/318] RUTH GIMENA BAUTISTA RAMOS (DNI 62081686)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'62081686',
    @Contra             = N'62081686',
    @Nombre             = N'RUTH GIMENA',
    @Apellido           = N'BAUTISTA RAMOS',
    @Dni                = N'62081686',
    @Email              = N'RUTH@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = NULL,
    @Direccion          = NULL,
    @Distrito           = NULL,
    @Colegio            = N'COLEGIO DE AREQUIPA',
    @Grado              = N'5 TO',
    @TelPersonal        = N'941559143',
    @TelApoderado       = N'936259300',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/f8d97f79-d20f-468a-8fe4-ccc8425e0e93_WhatsApp Image 2026-01-12 at 9.38.48 AM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 62081686: ' + @M; ELSE PRINT 'ERROR DNI 62081686: ' + @M;
GO

-- [151/318] ZULY VALENTINA CARRASCO HUAMANI (DNI 62136026)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'62136026',
    @Contra             = N'62136026',
    @Nombre             = N'ZULY VALENTINA',
    @Apellido           = N'CARRASCO HUAMANI',
    @Dni                = N'62136026',
    @Email              = N'ZULY@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'25072012',
    @Direccion          = N'SAN JUAN DE MIRAFLORES - 28 JULIO',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'CE APURIMAC',
    @Grado              = N'2DO',
    @TelPersonal        = NULL,
    @TelApoderado       = N'981454071',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/a52a00e8-de5f-4d78-861e-2d7981dfa6b7_WhatsApp Image 2026-01-21 at 13.18.53.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 62136026: ' + @M; ELSE PRINT 'ERROR DNI 62136026: ' + @M;
GO

-- [152/318] IGNACIO ANTONIO DAVILA RIVEIRO (DNI 62344562)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'62344562',
    @Contra             = N'62344562',
    @Nombre             = N'IGNACIO ANTONIO',
    @Apellido           = N'DAVILA RIVEIRO',
    @Dni                = N'62344562',
    @Email              = N'IGNACIO@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'21102009',
    @Direccion          = N'MZ L LOTE 20 - CALLE LAS ORQUIDEAS ASOC. URANMARCA - SJM',
    @Distrito           = N'SAN JUAN DE  MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'913094352',
    @TelApoderado       = N'992566177',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/d857f9e0-368b-4e5d-9a83-342de586f11e_WhatsApp Image 2026-03-21 at 7.28.37 AM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 62344562: ' + @M; ELSE PRINT 'ERROR DNI 62344562: ' + @M;
GO

-- [153/318] YARUMI CAMILA VIDAL POVIS (DNI 62374449)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'62374449',
    @Contra             = N'62374449',
    @Nombre             = N'YARUMI CAMILA',
    @Apellido           = N'VIDAL POVIS',
    @Dni                = N'62374449',
    @Email              = N'YARUMI@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'06102009',
    @Direccion          = N'MZ P - LOTE  3 - NAZARENO - P. ALTA - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'FE Y ALEGRIA',
    @Grado              = N'5TO',
    @TelPersonal        = N'977304788',
    @TelApoderado       = N'977473540',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/cb032209-c51e-477e-b273-024bf20e2924_WhatsApp Image 2026-06-11 at 3.07.35 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 62374449: ' + @M; ELSE PRINT 'ERROR DNI 62374449: ' + @M;
GO

-- [154/318] NOEMI ANDREA GOMEZ SALINAS (DNI 62374572)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'62374572',
    @Contra             = N'62374572',
    @Nombre             = N'NOEMI ANDREA',
    @Apellido           = N'GOMEZ SALINAS',
    @Dni                = N'62374572',
    @Email              = N'NOEMI@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'22102009',
    @Direccion          = N'JR. IQUITOS 238 - VMT',
    @Distrito           = N'VILLA MARIA DEL TRIUNFO',
    @Colegio            = N'IE JUAN GUERRERO QUIMPER',
    @Grado              = N'5TO',
    @TelPersonal        = N'946288881',
    @TelApoderado       = N'946288881',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/17cdd503-18f8-4214-82ed-cf3e410b3d24_Foto carnet.jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 62374572: ' + @M; ELSE PRINT 'ERROR DNI 62374572: ' + @M;
GO

-- [155/318] FABIANA MIA VALENZUELA VILLALBA (DNI 62442709)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'62442709',
    @Contra             = N'62442709',
    @Nombre             = N'FABIANA MIA',
    @Apellido           = N'VALENZUELA VILLALBA',
    @Dni                = N'62442709',
    @Email              = N'FABIANA@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'14072010',
    @Direccion          = N'JR. BUENA VENTURA AGUIRRE #1197 ZONA C - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'IE SAN JUAN',
    @Grado              = N'4TO',
    @TelPersonal        = N'999458377',
    @TelApoderado       = N'960186206',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = NULL,
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 62442709: ' + @M; ELSE PRINT 'ERROR DNI 62442709: ' + @M;
GO

-- [156/318] MATEO ALEXANDER HUASHUAYO NEYRA (DNI 62472094)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'62472094',
    @Contra             = N'62472094',
    @Nombre             = N'MATEO ALEXANDER',
    @Apellido           = N'HUASHUAYO NEYRA',
    @Dni                = N'62472094',
    @Email              = N'MATEO@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'09032010',
    @Direccion          = N'REPÚBLICA FEDERAL ALEMANA MZ "F" LT "6"',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'934492713',
    @TelApoderado       = N'977916914',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/ad226856-044a-4842-8345-51798244ca39_WhatsApp Image 2026-06-05 at 8.40.52 AM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 62472094: ' + @M; ELSE PRINT 'ERROR DNI 62472094: ' + @M;
GO

-- [157/318] HELEN ZOE ZAPATA GARCIA (DNI 62478895)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'62478895',
    @Contra             = N'62478895',
    @Nombre             = N'HELEN ZOE',
    @Apellido           = N'ZAPATA GARCIA',
    @Dni                = N'62478895',
    @Email              = N'HELEN@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'23082010',
    @Direccion          = N'ADALBERTO DEL CAMINO - URB. SAN JUAN',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'IE SAN JUAN',
    @Grado              = N'4TO',
    @TelPersonal        = N'960972225',
    @TelApoderado       = N'960972225',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/171483c6-059a-4c82-b682-4df61cf8a6cf_WhatsApp Image 2026-05-02 at 9.54.23 AM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 62478895: ' + @M; ELSE PRINT 'ERROR DNI 62478895: ' + @M;
GO

-- [158/318] GABRIEL SANTIAGO HIDALGO CUEVA (DNI 62503041)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'62503041',
    @Contra             = N'62503041',
    @Nombre             = N'GABRIEL SANTIAGO',
    @Apellido           = N'HIDALGO CUEVA',
    @Dni                = N'62503041',
    @Email              = N'GABRIEL@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'08022011',
    @Direccion          = N'MZ Q LT 7 VILLA SAN LUIS P.A SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'I.E MANUEL GONZALES PRADA HUARÍ ANCASH',
    @Grado              = N'4TO',
    @TelPersonal        = N'918432100',
    @TelApoderado       = N'918432100',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/6a6da637-3487-486b-81ff-5ec691882855_1000013540.png',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 62503041: ' + @M; ELSE PRINT 'ERROR DNI 62503041: ' + @M;
GO

-- [159/318] JOSEPH DEL PIERO MONTERO MUJICA (DNI 62539683)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'62539683',
    @Contra             = N'62539683',
    @Nombre             = N'JOSEPH DEL PIERO',
    @Apellido           = N'MONTERO MUJICA',
    @Dni                = N'62539683',
    @Email              = N'JOSEPH@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'20012010',
    @Direccion          = N'AA.HH. DEFENSORES DE LIMA MZ C LT 9 - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'IE LAS FLORES DE VILLA',
    @Grado              = N'5TO',
    @TelPersonal        = N'963100322',
    @TelApoderado       = N'955991257',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/49b8d129-869b-4b02-8009-709b8963beb1_WhatsApp Image 2026-01-10 at 2.19.23 PM (5).jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 62539683: ' + @M; ELSE PRINT 'ERROR DNI 62539683: ' + @M;
GO

-- [160/318] MARIA LLANOS RODRIGUEZ (DNI 62544760)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'62544760',
    @Contra             = N'62544760',
    @Nombre             = N'MARIA',
    @Apellido           = N'LLANOS RODRIGUEZ',
    @Dni                = N'62544760',
    @Email              = N'FERNANDA@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'05032010',
    @Direccion          = N'JR FRANCISCO VALLEJO 445 P. BAJA - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'IE NIÑO JESUS - PARROQUIAL',
    @Grado              = N'5TO',
    @TelPersonal        = N'933480067',
    @TelApoderado       = N'934700696',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/6129f921-5e08-4fea-90b9-293e10d6139b_WhatsApp Image 2026-03-26 at 5.02.24 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 62544760: ' + @M; ELSE PRINT 'ERROR DNI 62544760: ' + @M;
GO

-- [161/318] DANNA MIREYA MUNAYCO CONDORI (DNI 62547773)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'62547773',
    @Contra             = N'62547773',
    @Nombre             = N'DANNA MIREYA',
    @Apellido           = N'MUNAYCO CONDORI',
    @Dni                = N'62547773',
    @Email              = N'62547773@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'26122009',
    @Direccion          = N'CALLE - 2 MZ F LOTE 05 AA.HH. JOSE OLAYA B - CHORRILLOS',
    @Distrito           = N'CHORRILLOS',
    @Colegio            = N'CRISTIANIA',
    @Grado              = N'5TO',
    @TelPersonal        = N'987240845',
    @TelApoderado       = N'980678774',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/0ecd304f-48c1-4c11-9916-148942245839_IMG-20260312-WA0035.jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 62547773: ' + @M; ELSE PRINT 'ERROR DNI 62547773: ' + @M;
GO

-- [162/318] NICOLAS FABIAN VASQUEZ MIGUEL (DNI 62547798)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'62547798',
    @Contra             = N'62547798',
    @Nombre             = N'NICOLAS FABIAN',
    @Apellido           = N'VASQUEZ MIGUEL',
    @Dni                = N'62547798',
    @Email              = N'62547798@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'30012010',
    @Direccion          = N'ASOC. LA FLORESTA MZ F LOTE 20 DPTO 101 - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'IEP SAGRADO CORAZON DE MONTERRICO',
    @Grado              = N'5TO',
    @TelPersonal        = N'940006556',
    @TelApoderado       = N'949120523',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/88ade435-298f-4120-8a7c-245117d684e5_perfil.jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 62547798: ' + @M; ELSE PRINT 'ERROR DNI 62547798: ' + @M;
GO

-- [163/318] GIANELLA MARGARET RAMOS MENDOZA (DNI 62548636)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'62548636',
    @Contra             = N'62548636',
    @Nombre             = N'GIANELLA MARGARET',
    @Apellido           = N'RAMOS MENDOZA',
    @Dni                = N'62548636',
    @Email              = N'GIANELLA@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'23022010',
    @Direccion          = N'MZ. H2 LT. 1 LA RINCONADA P. A.',
    @Distrito           = N'SJM',
    @Colegio            = N'IE LEONCIO PRADO',
    @Grado              = N'4 TO',
    @TelPersonal        = N'960572394',
    @TelApoderado       = N'910242601',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/7b09f618-0a09-4d1a-947c-eb61a23fca88_9 (1).jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 62548636: ' + @M; ELSE PRINT 'ERROR DNI 62548636: ' + @M;
GO

-- [164/318] JHON ANGEL MAMANI ANCCO (DNI 62548706)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'62548706',
    @Contra             = N'62548706',
    @Nombre             = N'JHON ANGEL',
    @Apellido           = N'MAMANI ANCCO',
    @Dni                = N'62548706',
    @Email              = N'JHON@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'26022010',
    @Direccion          = N'MZ F LT 8 AGRUPACION LAS ROCAS PAMPLONA ALTA - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'IEP CARMELITAS AMERICAN SCHOOL',
    @Grado              = N'5TO',
    @TelPersonal        = N'901221318',
    @TelApoderado       = N'980474965',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/7c5a4ef1-c725-4176-87e0-0666bfc9e758_1000016074.jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 62548706: ' + @M; ELSE PRINT 'ERROR DNI 62548706: ' + @M;
GO

-- [165/318] VICTOR GABRIEL RODRIGUEZ TUANAMA (DNI 62548764)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'62548764',
    @Contra             = N'62548764',
    @Nombre             = N'VICTOR GABRIEL',
    @Apellido           = N'RODRIGUEZ TUANAMA',
    @Dni                = N'62548764',
    @Email              = N'62548764@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'26122009',
    @Direccion          = N'C.R.E.S. HEROES DE SAN JUAN - BLOCK 06 - DPTO 404',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'EMILIO SOYER CAVERO',
    @Grado              = N'5TO',
    @TelPersonal        = N'946648910',
    @TelApoderado       = N'939108325',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/230e6879-39c5-42bf-880f-1ccd507d3cfd_WhatsApp Image 2026-06-06 at 9.39.18 AM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 62548764: ' + @M; ELSE PRINT 'ERROR DNI 62548764: ' + @M;
GO

-- [166/318] JOHAN CRISTOFER CERNA VIVANCO (DNI 62548834)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'62548834',
    @Contra             = N'62548834',
    @Nombre             = N'JOHAN CRISTOFER',
    @Apellido           = N'CERNA VIVANCO',
    @Dni                = N'62548834',
    @Email              = N'JOHAN@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'30122009',
    @Direccion          = N'MZ B LT 3 - AA.HH. ALTO PROGRESO - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'FE Y ALEGRIA',
    @Grado              = N'5TO',
    @TelPersonal        = N'958317282',
    @TelApoderado       = N'968041619',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/e16e38a1-6932-46ad-8543-14d242fbce72_WhatsApp Image 2026-01-10 at 2.19.23 PM (4).jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 62548834: ' + @M; ELSE PRINT 'ERROR DNI 62548834: ' + @M;
GO

-- [167/318] JHON ANDERSON SALAS MARTINEZ (DNI 62549041)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'62549041',
    @Contra             = N'62549041',
    @Nombre             = N'JHON ANDERSON',
    @Apellido           = N'SALAS MARTINEZ',
    @Dni                = N'62549041',
    @Email              = N'62549041@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'26122009',
    @Direccion          = N'TREBOL AZUL MZT LT3 SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'I.E.P PROLOG',
    @Grado              = N'5TO',
    @TelPersonal        = N'930353047',
    @TelApoderado       = N'944879607',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/1921b0b9-2db7-42f1-87bf-4e036c36850f_WhatsApp Image 2026-01-10 at 2.19.23 PM (1).jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 62549041: ' + @M; ELSE PRINT 'ERROR DNI 62549041: ' + @M;
GO

-- [168/318] LUANA JOSEFINA HUAMANTINCO FLORES (DNI 62580188)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'62580188',
    @Contra             = N'62580188',
    @Nombre             = N'LUANA JOSEFINA',
    @Apellido           = N'HUAMANTINCO FLORES',
    @Dni                = N'62580188',
    @Email              = N'62580188@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'26022010',
    @Direccion          = N'CALLE LOS CIPRECES 154 URB VALLE SHARON SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'I.E.P ANDRES BELLO',
    @Grado              = N'5TO',
    @TelPersonal        = N'970289502',
    @TelApoderado       = N'992147863',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/b5cecf99-192d-4d2a-ab88-66b8e3b7a787_1 (1).jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 62580188: ' + @M; ELSE PRINT 'ERROR DNI 62580188: ' + @M;
GO

-- [169/318] CAMILA NICOLE YUPANQUI CONTRERAS (DNI 62580344)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'62580344',
    @Contra             = N'62580344',
    @Nombre             = N'CAMILA NICOLE',
    @Apellido           = N'YUPANQUI CONTRERAS',
    @Dni                = N'62580344',
    @Email              = N'CAMILA@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'25012010',
    @Direccion          = N'SAN JOSE DE VILLA MZ C LOTE 04 - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'IEP NIÑO JESUS',
    @Grado              = N'5TO',
    @TelPersonal        = N'951568485',
    @TelApoderado       = N'951568485',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/69810e79-8893-49a6-9647-adddcdb58522_WhatsApp Image 2026-03-26 at 5.02.53 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 62580344: ' + @M; ELSE PRINT 'ERROR DNI 62580344: ' + @M;
GO

-- [170/318] ANGHELY XIOMARA RAMIREZ CHUQUIYAURI (DNI 62587078)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'62587078',
    @Contra             = N'62587078',
    @Nombre             = N'ANGHELY XIOMARA',
    @Apellido           = N'RAMIREZ CHUQUIYAURI',
    @Dni                = N'62587078',
    @Email              = N'ANGHELY@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'19022010',
    @Direccion          = N'MZ 7 LT 23 SECT. 1 DE MAYO PAMPLONA ALTA - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'IE LEONCIO PRADO',
    @Grado              = N'5TO',
    @TelPersonal        = N'916535615',
    @TelApoderado       = N'982552840',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/540554cd-fa9a-44a4-ba80-99a01bffc570_WhatsApp Image 2026-04-25 at 9.49.32 AM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 62587078: ' + @M; ELSE PRINT 'ERROR DNI 62587078: ' + @M;
GO

-- [171/318] MAGDYEL ARMACCANCCE PUMA (DNI 62587364)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'62587364',
    @Contra             = N'62587364',
    @Nombre             = N'MAGDYEL',
    @Apellido           = N'ARMACCANCCE PUMA',
    @Dni                = N'62587364',
    @Email              = N'MAGDYEL@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'17032010',
    @Direccion          = N'A.H. INDOAMERICA - MZ "F" LOTE "3" - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'JAVIER HERAUD',
    @Grado              = N'5TO',
    @TelPersonal        = N'976615310',
    @TelApoderado       = N'982574718',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = NULL,
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 62587364: ' + @M; ELSE PRINT 'ERROR DNI 62587364: ' + @M;
GO

-- [172/318] IVAN AYALA BARRUETA (DNI 62587561)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'62587561',
    @Contra             = N'62587561',
    @Nombre             = N'IVAN',
    @Apellido           = N'AYALA BARRUETA',
    @Dni                = N'62587561',
    @Email              = N'IVAN@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'28032010',
    @Direccion          = N'MZ D LT 3 - LOS PINOS PAMPLONA ALTA - LA RINCONADA - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'SAN MARTIN',
    @Grado              = N'5TO',
    @TelPersonal        = N'926354804',
    @TelApoderado       = N'921797441',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/845f20b3-7e9c-4105-abed-e2afd2b91021_WhatsApp Image 2026-01-10 at 2.19.23 PM (3).jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 62587561: ' + @M; ELSE PRINT 'ERROR DNI 62587561: ' + @M;
GO

-- [173/318] ESAUD AARON ACUÑA CARMONA (DNI 62587598)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'62587598',
    @Contra             = N'62587598',
    @Nombre             = N'ESAUD AARON',
    @Apellido           = N'ACUÑA CARMONA',
    @Dni                = N'62587598',
    @Email              = N'ESAUD@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'20032010',
    @Direccion          = N'VISTA ALEGRE DE VILLA MZ. C2 LT. 3 COP 27',
    @Distrito           = N'CHORRILLOS',
    @Colegio            = N'CESAR VALLEJO 6091',
    @Grado              = N'5 TO',
    @TelPersonal        = N'935098268',
    @TelApoderado       = N'925923329',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/f5bf2783-325c-46fb-861b-50f5b1e73130_perfil.jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 62587598: ' + @M; ELSE PRINT 'ERROR DNI 62587598: ' + @M;
GO

-- [174/318] FRANZ MATT QUISPE HUCHARIMA (DNI 62587797)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'62587797',
    @Contra             = N'62587797',
    @Nombre             = N'FRANZ MATT',
    @Apellido           = N'QUISPE HUCHARIMA',
    @Dni                = N'62587797',
    @Email              = N'FRANZ@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'06052010',
    @Direccion          = N'TREBOL AZUL MZ J LOTE 4 - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'IE JAVIER HERAUD',
    @Grado              = N'4TO',
    @TelPersonal        = N'959814111',
    @TelApoderado       = N'930655960',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/d4ed29a3-3062-466f-8a98-4cdac56a7ac1_WhatsApp Image 2026-04-07 at 4.59.06 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 62587797: ' + @M; ELSE PRINT 'ERROR DNI 62587797: ' + @M;
GO

-- [175/318] YOCELIN PAMELA EZPINOZA GUTIERREZ (DNI 62587841)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'62587841',
    @Contra             = N'62587841',
    @Nombre             = N'YOCELIN PAMELA',
    @Apellido           = N'EZPINOZA GUTIERREZ',
    @Dni                = N'62587841',
    @Email              = N'YOCELIN@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'20032010',
    @Direccion          = N'MZ L5 LT8 AMPL. 2 - 12 DE NOVIEMBRE-SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'IE JUANA ALARCO DE DAMMERT',
    @Grado              = N'5TO',
    @TelPersonal        = N'984233317',
    @TelApoderado       = N'919693181',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/eac75753-0c7c-434a-8c42-eb5b0ce206de_WhatsApp Image 2026-04-07 at 4.57.45 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 62587841: ' + @M; ELSE PRINT 'ERROR DNI 62587841: ' + @M;
GO

-- [176/318] YHADIRA ANGULO CHILENO (DNI 62645729)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'62645729',
    @Contra             = N'62645729',
    @Nombre             = N'YHADIRA',
    @Apellido           = N'ANGULO CHILENO',
    @Dni                = N'62645729',
    @Email              = N'YHADIRA@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'25032010',
    @Direccion          = NULL,
    @Distrito           = NULL,
    @Colegio            = N'SANTA ROSA DE LIMA',
    @Grado              = N'5TO',
    @TelPersonal        = N'960821756',
    @TelApoderado       = N'960821756',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/90c85ca1-95ca-40c8-8c5c-b630ff874bd4_11 (1).jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 62645729: ' + @M; ELSE PRINT 'ERROR DNI 62645729: ' + @M;
GO

-- [177/318] DAYRA LUANA SURCA MORENO (DNI 62646301)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'62646301',
    @Contra             = N'62646301',
    @Nombre             = N'DAYRA LUANA',
    @Apellido           = N'SURCA MORENO',
    @Dni                = N'62646301',
    @Email              = N'62646301@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'29062009',
    @Direccion          = N'MZ. J LT. 28 LEONCIO PRADO',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'RAMON CASTILLA 7207',
    @Grado              = N'5 TO',
    @TelPersonal        = N'973026690',
    @TelApoderado       = N'989794638',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/1485a0fd-d33a-44a7-9f84-333709a187c0_1600w-orhYGC8lcKI.webp',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 62646301: ' + @M; ELSE PRINT 'ERROR DNI 62646301: ' + @M;
GO

-- [178/318] ROBERT ADRIANO SILVA URETA (DNI 62655954)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'62655954',
    @Contra             = N'62655954',
    @Nombre             = N'ROBERT ADRIANO',
    @Apellido           = N'SILVA URETA',
    @Dni                = N'62655954',
    @Email              = N'ROBERT@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'07022009',
    @Direccion          = N'JR. ESMERALDA 385 - VMT',
    @Distrito           = N'VILLA MARIA DEL TRIUNFO',
    @Colegio            = N'IEP REDIMER JESUS',
    @Grado              = N'5TO',
    @TelPersonal        = N'929374936',
    @TelApoderado       = N'929374936',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = NULL,
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 62655954: ' + @M; ELSE PRINT 'ERROR DNI 62655954: ' + @M;
GO

-- [179/318] LIXUE SAYURI LUIZA CORONADO MENDOZA (DNI 62712398)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'62712398',
    @Contra             = N'62712398',
    @Nombre             = N'LIXUE SAYURI LUIZA',
    @Apellido           = N'CORONADO MENDOZA',
    @Dni                = N'62712398',
    @Email              = N'LIXUE@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'03102010',
    @Direccion          = N'DANIEL GARCES 512 PAMPLOTA BAJA - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'IE LEONCIO PRADO',
    @Grado              = N'4TO',
    @TelPersonal        = N'932278875',
    @TelApoderado       = N'939179966',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/084970e4-ea65-46a7-8f5a-c7febbf29d37_WhatsApp Image 2026-03-14 at 11.55.48 AM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 62712398: ' + @M; ELSE PRINT 'ERROR DNI 62712398: ' + @M;
GO

-- [180/318] SANTIAGO TREYZO VILLASANTE COCHACHIN (DNI 62783088)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'62783088',
    @Contra             = N'62783088',
    @Nombre             = N'SANTIAGO TREYZO',
    @Apellido           = N'VILLASANTE COCHACHIN',
    @Dni                = N'62783088',
    @Email              = N'SANTIAGO@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'13112011',
    @Direccion          = N'AA. HH. MANUEL SCORZA MZ B1 LT 4  - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'IE MARISCAL RAMON CASTILLA',
    @Grado              = N'3RO',
    @TelPersonal        = NULL,
    @TelApoderado       = N'949153947',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/df2de91f-93b6-4584-9678-0f54b73db574_WhatsApp Image 2026-01-06 at 11.35.47 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 62783088: ' + @M; ELSE PRINT 'ERROR DNI 62783088: ' + @M;
GO

-- [181/318] BIANCA BERENICE PAUCAR BRAVO (DNI 62946684)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'62946684',
    @Contra             = N'62946684',
    @Nombre             = N'BIANCA BERENICE',
    @Apellido           = N'PAUCAR BRAVO',
    @Dni                = N'62946684',
    @Email              = N'62946684@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'24102011',
    @Direccion          = N'CALLE BUENAVENTURA AGUIRRE  1095 - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'IEP GASTON MARIA',
    @Grado              = N'3RO',
    @TelPersonal        = N'908852699',
    @TelApoderado       = N'951788472',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/012ac3ab-d056-4ef3-8322-202b23d59e3d_15.jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 62946684: ' + @M; ELSE PRINT 'ERROR DNI 62946684: ' + @M;
GO

-- [182/318] CRISTIAN JACOB AGUILAR ESPINOZA (DNI 62979088)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'62979088',
    @Contra             = N'62979088',
    @Nombre             = N'CRISTIAN JACOB',
    @Apellido           = N'AGUILAR ESPINOZA',
    @Dni                = N'62979088',
    @Email              = N'CRISTIAN@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'12032012',
    @Direccion          = N'AGRUPACION LAS ROCAS MZ D LT 1 P.A. - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'IE ANDRES A. CACERES - APURIMAC',
    @Grado              = N'3RO',
    @TelPersonal        = N'918117090',
    @TelApoderado       = N'918117090',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/8b1c5dd6-f21a-47eb-b7f7-66cd733b621b_WhatsApp Image 2026-01-28 at 13.26.06.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 62979088: ' + @M; ELSE PRINT 'ERROR DNI 62979088: ' + @M;
GO

-- [183/318] PAMELA KIARA JHANDY GERONIMO MENDOZA (DNI 63072713)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'63072713',
    @Contra             = N'63072713',
    @Nombre             = N'PAMELA KIARA JHANDY',
    @Apellido           = N'GERONIMO MENDOZA',
    @Dni                = N'63072713',
    @Email              = N'PAMELA@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'20092011',
    @Direccion          = NULL,
    @Distrito           = N'SJM',
    @Colegio            = N'SAN RAMON',
    @Grado              = N'3 ERO',
    @TelPersonal        = N'940994725',
    @TelApoderado       = N'966804526',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/78489b14-ff9f-4ee9-b63c-85842539922a_4.jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 63072713: ' + @M; ELSE PRINT 'ERROR DNI 63072713: ' + @M;
GO

-- [184/318] DANIELA CORTEZ GUARNIZO (DNI 63083453)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'63083453',
    @Contra             = N'63083453',
    @Nombre             = N'DANIELA',
    @Apellido           = N'CORTEZ GUARNIZO',
    @Dni                = N'63083453',
    @Email              = N'63083453@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = NULL,
    @Direccion          = N'MZ. O LT. 8 ASOC RICARDO PALMA',
    @Distrito           = N'SJM',
    @Colegio            = N'I. C. ESCOBAR',
    @Grado              = N'3 ERO',
    @TelPersonal        = N'900476762',
    @TelApoderado       = N'942516014',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/7069ecdd-32ea-48f7-9f8b-bd3e81810f81_rotated.jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 63083453: ' + @M; ELSE PRINT 'ERROR DNI 63083453: ' + @M;
GO

-- [185/318] HARUMI MARIANNA LOPEZ ESCOBAR (DNI 63237511)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'63237511',
    @Contra             = N'63237511',
    @Nombre             = N'HARUMI MARIANNA',
    @Apellido           = N'LOPEZ ESCOBAR',
    @Dni                = N'63237511',
    @Email              = N'HARUMI@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'07022012',
    @Direccion          = N'CALLE 1  MZ  B  LT  1  ASOC. DE VIVIENDA CRUZ DE MAYO - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'IE LEONCIO PRADO',
    @Grado              = N'3RO',
    @TelPersonal        = N'903522534',
    @TelApoderado       = N'956717041',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/18afd87d-79ab-4a4c-813c-7eb8e76ba7ae_14.jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 63237511: ' + @M; ELSE PRINT 'ERROR DNI 63237511: ' + @M;
GO

-- [186/318] AYELEN LUANA BEGAZO ROJAS (DNI 63253740)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'63253740',
    @Contra             = N'63253740',
    @Nombre             = N'AYELEN LUANA',
    @Apellido           = N'BEGAZO ROJAS',
    @Dni                = N'63253740',
    @Email              = N'AYELEN@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'06032010',
    @Direccion          = N'MZ A LT15 ASOC RICARDO PALMA SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'I.E RAMIRO PRIALE',
    @Grado              = N'5TO',
    @TelPersonal        = N'906313813',
    @TelApoderado       = N'906313813',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/365afd35-8f32-4e00-8cdb-1ba3bd0a8a0a_24.jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 63253740: ' + @M; ELSE PRINT 'ERROR DNI 63253740: ' + @M;
GO

-- [187/318] RUTH ALCÍRA GRANDEZ MONTOYA (DNI 63321761)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'63321761',
    @Contra             = N'63321761',
    @Nombre             = N'RUTH ALCÍRA',
    @Apellido           = N'GRANDEZ MONTOYA',
    @Dni                = N'63321761',
    @Email              = N'63321761@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'20052011',
    @Direccion          = N'AV PACHACUTEC VMT',
    @Distrito           = N'VILLA MARÍA DEL TRIUNFO',
    @Colegio            = N'FE Y ALEGRÍA',
    @Grado              = N'3RO',
    @TelPersonal        = N'931129409',
    @TelApoderado       = N'994423727',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/18197e8b-18e2-4943-a056-21ef38c50b21_7.jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 63321761: ' + @M; ELSE PRINT 'ERROR DNI 63321761: ' + @M;
GO

-- [188/318] LUHANA RUBY HERRERA ROJAS (DNI 63708419)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'63708419',
    @Contra             = N'63708419',
    @Nombre             = N'LUHANA RUBY',
    @Apellido           = N'HERRERA ROJAS',
    @Dni                = N'63708419',
    @Email              = N'LUHANA@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'15032012',
    @Direccion          = N'AV. GUARDIA CIVIL - 951 - CHORRILLOS',
    @Distrito           = N'CHORRILLOS',
    @Colegio            = N'IEP LEONARD EULER',
    @Grado              = N'2DO',
    @TelPersonal        = NULL,
    @TelApoderado       = N'960224917',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/55db7adc-123e-4137-bbeb-c6f9aa197a0e_WhatsApp Image 2026-03-14 at 11.45.43 AM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 63708419: ' + @M; ELSE PRINT 'ERROR DNI 63708419: ' + @M;
GO

-- [189/318] CIELO VALENTINA FARFAN QUEVEDO (DNI 63718608)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'63718608',
    @Contra             = N'63718608',
    @Nombre             = N'CIELO VALENTINA',
    @Apellido           = N'FARFAN QUEVEDO',
    @Dni                = N'63718608',
    @Email              = N'CIELO@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'09062011',
    @Direccion          = N'AV. ALAMOS LT. 7 MZ. G',
    @Distrito           = N'SJM',
    @Colegio            = N'IEP. LEONARD EULER',
    @Grado              = N'3 ERO',
    @TelPersonal        = N'994445221',
    @TelApoderado       = N'943609050',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/292a4a3a-1c87-4a2d-8bfb-e2077653c11f_WhatsApp Image 2026-01-21 at 13.19.51.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 63718608: ' + @M; ELSE PRINT 'ERROR DNI 63718608: ' + @M;
GO

-- [190/318] JEFERSON JOSE CIEZA HUAMBACHANO (DNI 70399417)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'70399417',
    @Contra             = N'70399417',
    @Nombre             = N'JEFERSON JOSE',
    @Apellido           = N'CIEZA HUAMBACHANO',
    @Dni                = N'70399417',
    @Email              = N'h.jeferson2017@gmail.com',
    @IdTipoUsuario      = N'1',
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
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/9a0f8249-84ca-4903-9d45-639f64ca4c6f_CIEZA.png',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 70399417: ' + @M; ELSE PRINT 'ERROR DNI 70399417: ' + @M;
GO

-- [191/318] ADAIR WEILL (DNI 70604028)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'70604028',
    @Contra             = N'70604028',
    @Nombre             = N'ADAIR',
    @Apellido           = N'WEILL',
    @Dni                = N'70604028',
    @Email              = N'70604028@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = NULL,
    @Direccion          = NULL,
    @Distrito           = NULL,
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'933017389',
    @TelApoderado       = NULL,
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/0ff899e2-26e2-4b6e-afa8-d754fdc68231_ADAIR WEILL.png',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 70604028: ' + @M; ELSE PRINT 'ERROR DNI 70604028: ' + @M;
GO

-- [192/318] XIARA JIMENA SEGAMA MENDOZA (DNI 70714607)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'70714607',
    @Contra             = N'70714607',
    @Nombre             = N'XIARA JIMENA',
    @Apellido           = N'SEGAMA MENDOZA',
    @Dni                = N'70714607',
    @Email              = N'XIARA@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'28062007',
    @Direccion          = N'COOPERATIVA AMERICA MZ P LOTE  34 - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'992845000',
    @TelApoderado       = N'992276257',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/b6bba442-bf0a-472d-bc29-4bc793e11a0e_WhatsApp Image 2026-04-08 at 9.39.20 AM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 70714607: ' + @M; ELSE PRINT 'ERROR DNI 70714607: ' + @M;
GO

-- [193/318] DAYANNA VALENTINA HUAMAN DE LA CRUZ (DNI 71166123)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'71166123',
    @Contra             = N'71166123',
    @Nombre             = N'DAYANNA VALENTINA',
    @Apellido           = N'HUAMAN DE LA CRUZ',
    @Dni                = N'71166123',
    @Email              = N'DAYANNA@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'14022008',
    @Direccion          = N'AA. HH. 1 DE ABRIL - SJM',
    @Distrito           = N'SAN JUA DE MIRAFLORES',
    @Colegio            = N'FRANCISCO FLORES - ICA',
    @Grado              = N'5',
    @TelPersonal        = N'952851884',
    @TelApoderado       = N'914744299',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/ec0fc3a1-fabc-411b-af48-cfb1da6d764e_IMG20260414145328.jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 71166123: ' + @M; ELSE PRINT 'ERROR DNI 71166123: ' + @M;
GO

-- [194/318] SHANTAL ADAMARI RODRIGUEZ CHANCOS (DNI 71174041)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'71174041',
    @Contra             = N'71174041',
    @Nombre             = N'SHANTAL ADAMARI',
    @Apellido           = N'RODRIGUEZ CHANCOS',
    @Dni                = N'71174041',
    @Email              = N'ADAMARI@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'16022008',
    @Direccion          = N'MZ F1 - LT9 AA. HH. MINAS 2000 - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'966731905',
    @TelApoderado       = N'941376057',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/35f4aa8e-1b5d-47a6-9487-e448fe1467e7_WhatsApp Image 2026-03-17 at 3.59.11 PM (2).jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 71174041: ' + @M; ELSE PRINT 'ERROR DNI 71174041: ' + @M;
GO

-- [195/318] KARIN BERROSPI ZELAYA (DNI 71186317)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'71186317',
    @Contra             = N'71186317',
    @Nombre             = N'KARIN',
    @Apellido           = N'BERROSPI ZELAYA',
    @Dni                = N'71186317',
    @Email              = N'KARIN@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'15032008',
    @Direccion          = N'SANN GABRIEL -  PARAISO - VMT',
    @Distrito           = N'VILLA MARIA DEL TRIUNFO',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'976337570',
    @TelApoderado       = N'952320780',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/c017365a-9c0e-410b-a2ed-739aa126ba5e_WhatsApp Image 2026-04-28 at 9.38.16 AM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 71186317: ' + @M; ELSE PRINT 'ERROR DNI 71186317: ' + @M;
GO

-- [196/318] MARICIELO ESCARCENA ELIAS (DNI 71188061)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'71188061',
    @Contra             = N'71188061',
    @Nombre             = N'MARICIELO',
    @Apellido           = N'ESCARCENA ELIAS',
    @Dni                = N'71188061',
    @Email              = N'71188061@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'05042008',
    @Direccion          = N'AV. EDILBERTO RAMOS - 527 - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'966385440',
    @TelApoderado       = N'991074954',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/d203902f-7745-4917-9fdf-cac1fb9a07c1_WhatsApp Image 2026-06-02 at 9.31.49 AM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 71188061: ' + @M; ELSE PRINT 'ERROR DNI 71188061: ' + @M;
GO

-- [197/318] MILAGROS LILI RIVADENEYRA CHERO (DNI 71672104)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'71672104',
    @Contra             = N'71672104',
    @Nombre             = N'MILAGROS LILI',
    @Apellido           = N'RIVADENEYRA CHERO',
    @Dni                = N'71672104',
    @Email              = N'71672104@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'08062008',
    @Direccion          = N'MZ. E LT. 31 LUIS FELIPE DE LAS CASAS',
    @Distrito           = N'SJM',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'902650555',
    @TelApoderado       = N'925927778',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/60f53163-bb67-43bf-a066-a95d861fe32d_perfil.jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 71672104: ' + @M; ELSE PRINT 'ERROR DNI 71672104: ' + @M;
GO

-- [198/318] JOSE ALBERTO SILUPU PERNIA (DNI 71676613)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'71676613',
    @Contra             = N'71676613',
    @Nombre             = N'JOSE ALBERTO',
    @Apellido           = N'SILUPU PERNIA',
    @Dni                = N'71676613',
    @Email              = N'71676613@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'02062008',
    @Direccion          = N'CALLE FRANCISCO DE PAULA UGARRITZA - 187 - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'INNOVA SCHOOL',
    @Grado              = N'5TO',
    @TelPersonal        = N'961206203',
    @TelApoderado       = N'984009604',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/42dd8ca2-417d-4d73-8f0f-37643c707d51_WhatsApp Image 2026-05-27 at 5.03.17 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 71676613: ' + @M; ELSE PRINT 'ERROR DNI 71676613: ' + @M;
GO

-- [199/318] SHEYLA YULIZA MUÑICO FLORES (DNI 71683268)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'71683268',
    @Contra             = N'71683268',
    @Nombre             = N'SHEYLA YULIZA',
    @Apellido           = N'MUÑICO FLORES',
    @Dni                = N'71683268',
    @Email              = N'SHEYLA@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'03072008',
    @Direccion          = N'MZ "D" LOTE "14" - A.H. 13 DE OCTUBRE - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'995802078',
    @TelApoderado       = N'999988952',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/8352143e-3e11-4739-98ef-8d87e1eb1c88_WhatsApp Image 2026-06-05 at 1.37.36 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 71683268: ' + @M; ELSE PRINT 'ERROR DNI 71683268: ' + @M;
GO

-- [200/318] ASHLEY CUYA ORIZANO (DNI 71731637)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'71731637',
    @Contra             = N'71731637',
    @Nombre             = N'ASHLEY',
    @Apellido           = N'CUYA ORIZANO',
    @Dni                = N'71731637',
    @Email              = N'ASHLEY@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'02042006',
    @Direccion          = N'JR. YERUPATA URB. DELICIAS DE VILLA - MZ D-6 LOTE 06',
    @Distrito           = N'CHORRILLOS',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'925026692',
    @TelApoderado       = N'987338766',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/55e26f84-dcd3-442b-825d-a9fcf239f437_WhatsApp Image 2026-05-18 at 1.12.20 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 71731637: ' + @M; ELSE PRINT 'ERROR DNI 71731637: ' + @M;
GO

-- [201/318] FELIX SALVADOR FREY ZANABRIA CAMASCA (DNI 72055929)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'72055929',
    @Contra             = N'72055929',
    @Nombre             = N'FELIX SALVADOR FREY',
    @Apellido           = N'ZANABRIA CAMASCA',
    @Dni                = N'72055929',
    @Email              = N'FELIX@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'20072008',
    @Direccion          = N'CALLE LOS EUCALIPTOS 317 URB VALLE SHARON',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'RAMON CASTILLA',
    @Grado              = N'5TO',
    @TelPersonal        = N'915117797',
    @TelApoderado       = N'908784035',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/631a3fbe-18dd-4aba-8a47-3e28d57ce610_perfil.jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 72055929: ' + @M; ELSE PRINT 'ERROR DNI 72055929: ' + @M;
GO

-- [202/318] MARIA DEL ROSARIO MARCELO RIOS (DNI 72058510)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'72058510',
    @Contra             = N'72058510',
    @Nombre             = N'MARIA DEL ROSARIO',
    @Apellido           = N'MARCELO RIOS',
    @Dni                = N'72058510',
    @Email              = N'ROSARIO@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'02082008',
    @Direccion          = N'SECT. SAN FRANCISCO DE ASIS - MZ 39 - LOTE 14 - P.A. - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'943092567',
    @TelApoderado       = N'957444074',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/bc26bb52-fb21-4f92-950e-b8f115f85fe2_WhatsApp Image 2026-05-13 at 10.47.17 AM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 72058510: ' + @M; ELSE PRINT 'ERROR DNI 72058510: ' + @M;
GO

-- [203/318] KIARA SHARLYN PALOMINO GONZALES (DNI 72059754)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'72059754',
    @Contra             = N'72059754',
    @Nombre             = N'KIARA SHARLYN',
    @Apellido           = N'PALOMINO GONZALES',
    @Dni                = N'72059754',
    @Email              = N'72059754@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'26072007',
    @Direccion          = N'JR. JUAN NEYRA 170 P.B SJM POR CINE STAR',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'921245279',
    @TelApoderado       = N'900893590',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/79a1aa76-1473-4684-a9b8-3921bfc2c412_perfil.jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 72059754: ' + @M; ELSE PRINT 'ERROR DNI 72059754: ' + @M;
GO

-- [204/318] JASMIN NORMA RECINA ROJAS (DNI 72060981)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'72060981',
    @Contra             = N'72060981',
    @Nombre             = N'JASMIN NORMA',
    @Apellido           = N'RECINA ROJAS',
    @Dni                = N'72060981',
    @Email              = N'JASMIN@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'20072009',
    @Direccion          = N'LURIGANCHO - CHOSICA',
    @Distrito           = N'LURIGANCHO - CHOSICA',
    @Colegio            = N'MANUEL GONZALES PRADA',
    @Grado              = N'5TO',
    @TelPersonal        = N'963998695',
    @TelApoderado       = N'938858283',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = NULL,
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 72060981: ' + @M; ELSE PRINT 'ERROR DNI 72060981: ' + @M;
GO

-- [205/318] LUCIA DAYANA CARDENAS AGUILAR (DNI 72064739)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'72064739',
    @Contra             = N'72064739',
    @Nombre             = N'LUCIA DAYANA',
    @Apellido           = N'CARDENAS AGUILAR',
    @Dni                = N'72064739',
    @Email              = N'LUCIA@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'01082008',
    @Direccion          = N'SECT 02 GRUPO 11 - MZ C LT 7 - VES',
    @Distrito           = N'VILLA EL SALVADOR',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'970600772',
    @TelApoderado       = N'960386760',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/bdc26a18-da90-4320-ba4f-c0c0fccec2be_1000137334.jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 72064739: ' + @M; ELSE PRINT 'ERROR DNI 72064739: ' + @M;
GO

-- [206/318] LUIS MIGUEL ANDIA LUJAN (DNI 72345019)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'72345019',
    @Contra             = N'72345019',
    @Nombre             = N'LUIS MIGUEL',
    @Apellido           = N'ANDIA LUJAN',
    @Dni                = N'72345019',
    @Email              = N'72345019@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'26092008',
    @Direccion          = N'MZ D LT 19 - ALIPIO PONCE - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'945600881',
    @TelApoderado       = N'986074336',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/2b8eff34-40a4-4fc9-a935-375dc4a470c7_IMG-20260111-WA0002.jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 72345019: ' + @M; ELSE PRINT 'ERROR DNI 72345019: ' + @M;
GO

-- [207/318] JENNYFER ALEXANDRA CESPEDES SALVATIERRA (DNI 72347243)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'72347243',
    @Contra             = N'72347243',
    @Nombre             = N'JENNYFER ALEXANDRA',
    @Apellido           = N'CESPEDES SALVATIERRA',
    @Dni                = N'72347243',
    @Email              = N'DORA@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'12102008',
    @Direccion          = N'VILLA LOS ANGELES II MZ LT 11 VILLA LOS ANGELES II',
    @Distrito           = NULL,
    @Colegio            = N'SAN LUIS GONZAGA',
    @Grado              = N'5TO',
    @TelPersonal        = N'956258363',
    @TelApoderado       = N'965039874',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/db18bb16-8e25-42d7-b74b-5b9caaeef302_WhatsApp Image 2026-01-10 at 2.19.22 PM (6).jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 72347243: ' + @M; ELSE PRINT 'ERROR DNI 72347243: ' + @M;
GO

-- [208/318] MACEO KADAR VILLA AYLLON (DNI 72349571)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'72349571',
    @Contra             = N'72349571',
    @Nombre             = N'MACEO KADAR',
    @Apellido           = N'VILLA AYLLON',
    @Dni                = N'72349571',
    @Email              = N'MACEO@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'16102008',
    @Direccion          = N'AV GUARDIA CIVIL 354',
    @Distrito           = N'CHORRILLOS',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'934902606',
    @TelApoderado       = N'915120160',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/d0ec861e-7bbb-4650-9f40-22424981b4e4_Foto carnet (8).jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 72349571: ' + @M; ELSE PRINT 'ERROR DNI 72349571: ' + @M;
GO

-- [209/318] LUIS FERNANDO MONTOYA RIVERA (DNI 72392039)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'72392039',
    @Contra             = N'72392039',
    @Nombre             = N'LUIS FERNANDO',
    @Apellido           = N'MONTOYA RIVERA',
    @Dni                = N'72392039',
    @Email              = N'72392039@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'09121996',
    @Direccion          = N'MZ A LT14 VES',
    @Distrito           = N'VILLA EL SALVADOR',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'946480076',
    @TelApoderado       = N'997275996',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/63b4cbc5-33f6-452f-aa36-e66cc6dfccb5_WhatsApp Image 2026-06-11 at 9.42.20 AM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 72392039: ' + @M; ELSE PRINT 'ERROR DNI 72392039: ' + @M;
GO

-- [210/318] KEVIN PIERO QUIJANDRIA ORTIZ (DNI 72461131)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'72461131',
    @Contra             = N'72461131',
    @Nombre             = N'KEVIN PIERO',
    @Apellido           = N'QUIJANDRIA ORTIZ',
    @Dni                = N'72461131',
    @Email              = N'72461131@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'05122005',
    @Direccion          = N'AV ECHENIQUE # 388 - PAMPLONA BAJA - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = NULL,
    @TelApoderado       = N'970332798',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = NULL,
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 72461131: ' + @M; ELSE PRINT 'ERROR DNI 72461131: ' + @M;
GO

-- [211/318] SERGIO VALENTINO CCAYO GUTIERREZ (DNI 72586831)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'72586831',
    @Contra             = N'72586831',
    @Nombre             = N'SERGIO VALENTINO',
    @Apellido           = N'CCAYO GUTIERREZ',
    @Dni                = N'72586831',
    @Email              = N'SERGIO@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'28092008',
    @Direccion          = N'MZ J  4B  LT 18  SECTOR  12 DE NOVIEMBRE . P.A. - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'914719718',
    @TelApoderado       = N'997497760',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/ab3b2260-f3eb-4c81-ba7d-5b7e4c9c1db4_12.jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 72586831: ' + @M; ELSE PRINT 'ERROR DNI 72586831: ' + @M;
GO

-- [212/318] KYLIE NICOLE CRUZ CACERES (DNI 72591446)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'72591446',
    @Contra             = N'72591446',
    @Nombre             = N'KYLIE NICOLE',
    @Apellido           = N'CRUZ CACERES',
    @Dni                = N'72591446',
    @Email              = N'KYLIE@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'30102008',
    @Direccion          = N'LADERAS DE VILLA MZ K LT 24 - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'993470578',
    @TelApoderado       = N'993469859',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/bb6525de-86f0-4f6a-b18f-9271477cccab_WhatsApp Image 2026-03-17 at 3.59.22 PM (3).jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 72591446: ' + @M; ELSE PRINT 'ERROR DNI 72591446: ' + @M;
GO

-- [213/318] TATANIA CELESTE TORRES ZANABRIA (DNI 72593172)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'72593172',
    @Contra             = N'72593172',
    @Nombre             = N'TATANIA CELESTE',
    @Apellido           = N'TORRES ZANABRIA',
    @Dni                = N'72593172',
    @Email              = N'TAMANA@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'07112008',
    @Direccion          = N'AV MARIANO PASTOR SEVILLA MC. LT 32',
    @Distrito           = N'SJM',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'933883763',
    @TelApoderado       = N'952166599',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/d9e82247-b028-4ba7-8ec6-a64de279cdab_WhatsApp Image 2026-01-15 at 12.02.03 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 72593172: ' + @M; ELSE PRINT 'ERROR DNI 72593172: ' + @M;
GO

-- [214/318] ALEXIA VALERIA MUÑOZ FLORES (DNI 72594120)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'72594120',
    @Contra             = N'72594120',
    @Nombre             = N'ALEXIA VALERIA',
    @Apellido           = N'MUÑOZ FLORES',
    @Dni                = N'72594120',
    @Email              = N'72594120@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'11112008',
    @Direccion          = N'JR MANUEL ZELAYA 494 - URB. PAMPLONA BAJA - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'951265473',
    @TelApoderado       = N'999264815',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/5eba4676-4290-477a-98f2-01d0e1a94dcc_WhatsApp Image 2026-03-20 at 9.58.30 AM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 72594120: ' + @M; ELSE PRINT 'ERROR DNI 72594120: ' + @M;
GO

-- [215/318] STEFANNY MARICIELO VASQUEZ BAHAMONDE (DNI 72819751)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'72819751',
    @Contra             = N'72819751',
    @Nombre             = N'STEFANNY MARICIELO',
    @Apellido           = N'VASQUEZ BAHAMONDE',
    @Dni                = N'72819751',
    @Email              = N'STEFANNY@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'10122008',
    @Direccion          = N'NVA RINCONADA P.A. - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'950203685',
    @TelApoderado       = N'967267062',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/7ee31186-d7a6-4313-9efe-2ae1dab6f399_WhatsApp Image 2026-05-04 at 1.55.22 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 72819751: ' + @M; ELSE PRINT 'ERROR DNI 72819751: ' + @M;
GO

-- [216/318] ROCIO LIZETH LUQUE PAREDES (DNI 72820448)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'72820448',
    @Contra             = N'72820448',
    @Nombre             = N'ROCIO LIZETH',
    @Apellido           = N'LUQUE PAREDES',
    @Dni                = N'72820448',
    @Email              = N'ROCIO@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'10122008',
    @Direccion          = N'MZ Q7 LT 16 SECTOR 1 DE MAYO P. ALTA - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'950245371',
    @TelApoderado       = N'977178052',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/b63d13b9-ccba-4c74-9c48-f9848da2d42c_WhatsApp Image 2026-03-17 at 3.59.23 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 72820448: ' + @M; ELSE PRINT 'ERROR DNI 72820448: ' + @M;
GO

-- [217/318] ROSARIO STEFANNY LOPEZ SANDOVAL (DNI 72828584)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'72828584',
    @Contra             = N'72828584',
    @Nombre             = N'ROSARIO STEFANNY',
    @Apellido           = N'LOPEZ SANDOVAL',
    @Dni                = N'72828584',
    @Email              = N'72828584@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'02012009',
    @Direccion          = N'JOAQUIN TORRICO 120 ZONA B - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'994485907',
    @TelApoderado       = N'994485907',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/4188bfb3-6ef7-4eac-88dd-07c610060cce_Foto carnet (1).jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 72828584: ' + @M; ELSE PRINT 'ERROR DNI 72828584: ' + @M;
GO

-- [218/318] XIMENA FERNANDA DELIA VERA TARAZONA (DNI 72829337)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'72829337',
    @Contra             = N'72829337',
    @Nombre             = N'XIMENA FERNANDA DELIA',
    @Apellido           = N'VERA TARAZONA',
    @Dni                = N'72829337',
    @Email              = N'XIMENA@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'18122008',
    @Direccion          = N'NVA ESPERANZA PARADERO 10 JR CARAZ 211 - VMT',
    @Distrito           = N'VILLA MARIA DEL TRIUNFO',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'965613209',
    @TelApoderado       = N'934984007',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/0f7fe3bc-7d3c-4f65-8fe1-d66442c51a13_WhatsApp Image 2026-03-26 at 6.07.23 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 72829337: ' + @M; ELSE PRINT 'ERROR DNI 72829337: ' + @M;
GO

-- [219/318] KEVIN JESUS CUNIA SOCA (DNI 72831549)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'72831549',
    @Contra             = N'72831549',
    @Nombre             = N'KEVIN JESUS',
    @Apellido           = N'CUNIA SOCA',
    @Dni                = N'72831549',
    @Email              = N'72831549@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'23122008',
    @Direccion          = N'MZ G SUB LOTE 2 - SECTOR EL IMPERIAL PAMPLONA ALTA - SJM',
    @Distrito           = N'SAN  JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'923240607',
    @TelApoderado       = N'923240607',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/e34f5455-9d4f-4966-bd4b-f7e6eabee4c2_WhatsApp Image 2026-02-05 at 9.56.36 AM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 72831549: ' + @M; ELSE PRINT 'ERROR DNI 72831549: ' + @M;
GO

-- [220/318] GONZALO RODRIGUEZ SAENZ (DNI 72982380)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'72982380',
    @Contra             = N'72982380',
    @Nombre             = N'GONZALO',
    @Apellido           = N'RODRIGUEZ SAENZ',
    @Dni                = N'72982380',
    @Email              = N'GONZALO@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'12012009',
    @Direccion          = N'JR CIPRIANO RIVAS 999 - ZONA  D  - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'959986143',
    @TelApoderado       = N'922399374',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/bccb4a60-6a9b-4fe4-a6c2-18ae94038430_6 (1).jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 72982380: ' + @M; ELSE PRINT 'ERROR DNI 72982380: ' + @M;
GO

-- [221/318] DAYRON SAMIR LIMA GARCIA (DNI 72997877)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'72997877',
    @Contra             = N'72997877',
    @Nombre             = N'DAYRON SAMIR',
    @Apellido           = N'LIMA GARCIA',
    @Dni                = N'72997877',
    @Email              = N'DAYRON@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'12022009',
    @Direccion          = N'MZ L LOTE 01 COMITE VECINAL ANDES - VMT',
    @Distrito           = N'VILLA MARIA DEL TRIUNFO',
    @Colegio            = N'IE 7054',
    @Grado              = N'EGRESADO',
    @TelPersonal        = N'960911891',
    @TelApoderado       = N'972349984',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/0431227b-b048-4796-85bf-c1c9d3592874_Foto carnet (4).jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 72997877: ' + @M; ELSE PRINT 'ERROR DNI 72997877: ' + @M;
GO

-- [222/318] MARICIELO FERNANDEZ VALDERRAMA (DNI 73153552)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'73153552',
    @Contra             = N'73153552',
    @Nombre             = N'MARICIELO',
    @Apellido           = N'FERNANDEZ VALDERRAMA',
    @Dni                = N'73153552',
    @Email              = N'73153552@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'17022009',
    @Direccion          = N'ST 02 BARRIO 1  MZ K-1 LT 23 URB. PACHACAMAC - VES',
    @Distrito           = N'VILLA EL SALVADOR',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'993650571',
    @TelApoderado       = N'991180946',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/b880cb10-3bad-430e-bdbf-0f26a0542acc_WhatsApp Image 2026-03-17 at 3.59.22 PM (1).jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 73153552: ' + @M; ELSE PRINT 'ERROR DNI 73153552: ' + @M;
GO

-- [223/318] GABRIEL ESTRADA CLUSMAN (DNI 73166142)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'73166142',
    @Contra             = N'73166142',
    @Nombre             = N'GABRIEL',
    @Apellido           = N'ESTRADA CLUSMAN',
    @Dni                = N'73166142',
    @Email              = N'73166142@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'03032009',
    @Direccion          = N'SECTOR 2 GRUPO 19 MZ J LT21 - VES',
    @Distrito           = N'VILLA EL SALVADOR',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'941110562',
    @TelApoderado       = N'949186989',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/401a0355-af5e-42be-ba6b-7d8ec1bfed6c_1000157560.jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 73166142: ' + @M; ELSE PRINT 'ERROR DNI 73166142: ' + @M;
GO

-- [224/318] ANDERSON SANTIAGO CUSTODIO ROSALES (DNI 73167989)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'73167989',
    @Contra             = N'73167989',
    @Nombre             = N'ANDERSON SANTIAGO',
    @Apellido           = N'CUSTODIO ROSALES',
    @Dni                = N'73167989',
    @Email              = N'73167989@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'15032009',
    @Direccion          = N'CALLE LOS ALAMOS LOTE 3 - PARQUE INDUSTRIAL VILLA MARIA DEL TRINFO',
    @Distrito           = N'VILLA MARIA DEL TRIUNFO',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'963333906',
    @TelApoderado       = N'935129215',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/2ee97bd5-fa8f-4c23-a4c0-34ac4ba4fe97_WhatsApp Image 2026-01-13 at 11.34.31 AM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 73167989: ' + @M; ELSE PRINT 'ERROR DNI 73167989: ' + @M;
GO

-- [225/318] LINDA SALAS ALVA (DNI 73175979)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'73175979',
    @Contra             = N'73175979',
    @Nombre             = N'LINDA',
    @Apellido           = N'SALAS ALVA',
    @Dni                = N'73175979',
    @Email              = N'linda.salas@hotmail.com',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'14051999',
    @Direccion          = NULL,
    @Distrito           = NULL,
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = NULL,
    @TelApoderado       = NULL,
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/f9fbce53-dd11-4199-bbba-1b8e2e6d1252_SALAS.png',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 73175979: ' + @M; ELSE PRINT 'ERROR DNI 73175979: ' + @M;
GO

-- [226/318] FLAVIO SEBASTIAN SACA LOAYZA (DNI 73278694)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'73278694',
    @Contra             = N'73278694',
    @Nombre             = N'FLAVIO SEBASTIAN',
    @Apellido           = N'SACA LOAYZA',
    @Dni                = N'73278694',
    @Email              = N'FLAVIO@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'11042009',
    @Direccion          = N'AV. VARGAS MACHUCA # 154',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'IEP ROSA DE SANTA MARIA',
    @Grado              = N'5TO',
    @TelPersonal        = N'908856296',
    @TelApoderado       = N'908856296',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/af8fe69d-5b0e-4d96-b5e9-8441e7a4ee94_WhatsApp Image 2026-05-02 at 9.52.55 AM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 73278694: ' + @M; ELSE PRINT 'ERROR DNI 73278694: ' + @M;
GO

-- [227/318] JADE VANESA QUISPE ALVAREZ (DNI 73296664)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'73296664',
    @Contra             = N'73296664',
    @Nombre             = N'JADE VANESA',
    @Apellido           = N'QUISPE ALVAREZ',
    @Dni                = N'73296664',
    @Email              = N'JADE@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'07052009',
    @Direccion          = N'PSJ V1 MZ. 41 LT 26 PS LOS LAURELES P. A',
    @Distrito           = N'SJM',
    @Colegio            = N'JOSE ANTONIO ENCINAS 7059',
    @Grado              = N'5 TO',
    @TelPersonal        = N'978706315',
    @TelApoderado       = N'986216084',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/5515ecef-d660-4f61-803a-b50fd140b6c2_WhatsApp Image 2026-01-10 at 2.19.20 PM (6).jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 73296664: ' + @M; ELSE PRINT 'ERROR DNI 73296664: ' + @M;
GO

-- [228/318] URIEL ULIANOV ALVARON YANAMA (DNI 73405063)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'73405063',
    @Contra             = N'73405063',
    @Nombre             = N'URIEL ULIANOV',
    @Apellido           = N'ALVARON YANAMA',
    @Dni                = N'73405063',
    @Email              = N'URIEL@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'20062009',
    @Direccion          = N'CALLE S/N PAMPLONA MZ Q1 LT 11 SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'ALFONSO UGARTE',
    @Grado              = N'5to',
    @TelPersonal        = N'918992090',
    @TelApoderado       = N'996567871',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/061fd13b-dbd9-4585-b3d6-1ac814f21372_16.jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 73405063: ' + @M; ELSE PRINT 'ERROR DNI 73405063: ' + @M;
GO

-- [229/318] LUCIO VALENTIN SANDOVAL CASTAÑEDA (DNI 73547798)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'73547798',
    @Contra             = N'73547798',
    @Nombre             = N'LUCIO VALENTIN',
    @Apellido           = N'SANDOVAL CASTAÑEDA',
    @Dni                = N'73547798',
    @Email              = N'LUCIO@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'11072009',
    @Direccion          = N'JR. IGNACIO SEMINARIO 1289 - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'IE SAN JUAN',
    @Grado              = N'5TO',
    @TelPersonal        = N'964111067',
    @TelApoderado       = N'964111067',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/706fc917-12b3-42ac-9ba0-c3299c4761ee_WhatsApp Image 2026-04-07 at 4.58.28 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 73547798: ' + @M; ELSE PRINT 'ERROR DNI 73547798: ' + @M;
GO

-- [230/318] BAYRON CULE GUTIERREZ (DNI 73548440)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'73548440',
    @Contra             = N'73548440',
    @Nombre             = N'BAYRON',
    @Apellido           = N'CULE GUTIERREZ',
    @Dni                = N'73548440',
    @Email              = N'BAYRON@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'17062009',
    @Direccion          = N'MZ G LT 5 - SAN JUAN DE MIRAFLORES',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'IE SAN JUAN',
    @Grado              = N'5TO',
    @TelPersonal        = N'989134071',
    @TelApoderado       = N'989134071',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/4836e470-2d22-4b6a-a768-093a1944c337_Foto carnet (4).jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 73548440: ' + @M; ELSE PRINT 'ERROR DNI 73548440: ' + @M;
GO

-- [231/318] RODRIGO JOSE CONDORI VILCA (DNI 73551139)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'73551139',
    @Contra             = N'73551139',
    @Nombre             = N'RODRIGO JOSE',
    @Apellido           = N'CONDORI VILCA',
    @Dni                = N'73551139',
    @Email              = N'73551139@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'17072009',
    @Direccion          = N'MZ C LT 18 - COMITE 3 MATEO PUMACAHUA - CHORRILLOS',
    @Distrito           = N'CHORRILLOS',
    @Colegio            = N'IE SAN PEDRO DE CHORRILLOS',
    @Grado              = N'5TO',
    @TelPersonal        = N'955964073',
    @TelApoderado       = N'997079060',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = NULL,
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 73551139: ' + @M; ELSE PRINT 'ERROR DNI 73551139: ' + @M;
GO

-- [232/318] KAMILA SHANNY HUAYAPA VALDEZ (DNI 73551707)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'73551707',
    @Contra             = N'73551707',
    @Nombre             = N'KAMILA SHANNY',
    @Apellido           = N'HUAYAPA VALDEZ',
    @Dni                = N'73551707',
    @Email              = N'KAMILA@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'13072009',
    @Direccion          = N'LOS VIÑEDOS MZ. A LT. 16',
    @Distrito           = N'SURCO',
    @Colegio            = N'LOS PRECURSORES',
    @Grado              = N'5 TO',
    @TelPersonal        = N'951469621',
    @TelApoderado       = N'996631111',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/2fd1216f-131f-44b5-9fad-63cc1df06c9c_Foto carnet (3).jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 73551707: ' + @M; ELSE PRINT 'ERROR DNI 73551707: ' + @M;
GO

-- [233/318] ALMENDRA NAYUMI ROCA QUICHCA (DNI 73554615)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'73554615',
    @Contra             = N'73554615',
    @Nombre             = N'ALMENDRA NAYUMI',
    @Apellido           = N'ROCA QUICHCA',
    @Dni                = N'73554615',
    @Email              = N'NAYUMI@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'29072009',
    @Direccion          = N'MZ A LOTE 13 P.A. - ALTO PROGRESO -SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'IE LEONCIO PRADO',
    @Grado              = N'5TO',
    @TelPersonal        = N'997571919',
    @TelApoderado       = N'912787498',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/78917983-45fd-4b89-b029-3754ffa49fe1_WhatsApp Image 2026-03-26 at 5.00.48 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 73554615: ' + @M; ELSE PRINT 'ERROR DNI 73554615: ' + @M;
GO

-- [234/318] DAYANNA YAZURY TITO RODAS (DNI 73559849)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'73559849',
    @Contra             = N'73559849',
    @Nombre             = N'DAYANNA YAZURY',
    @Apellido           = N'TITO RODAS',
    @Dni                = N'73559849',
    @Email              = N'73559849@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'06082009',
    @Direccion          = N'MZ "P" LOTE "3" NAZARENO P.A. - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'CARMELITAS IEP',
    @Grado              = N'5TO',
    @TelPersonal        = N'981422109',
    @TelApoderado       = N'923228369',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/5fc471cf-5376-404b-b83d-2b7e39332da7_WhatsApp Image 2026-06-10 at 4.51.24 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 73559849: ' + @M; ELSE PRINT 'ERROR DNI 73559849: ' + @M;
GO

-- [235/318] DANIEL MORENO YSLA (DNI 73717309)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'73717309',
    @Contra             = N'73717309',
    @Nombre             = N'DANIEL',
    @Apellido           = N'MORENO YSLA',
    @Dni                = N'73717309',
    @Email              = N'73717309@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'28082009',
    @Direccion          = N'FAMILIAS UNIDAS ALIPIO PONCE MZ B1 - LT 1 - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'IE FE Y ALEGRIA 03',
    @Grado              = N'5TO',
    @TelPersonal        = N'985660714',
    @TelApoderado       = N'985660714',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/76dbaa5c-3131-4d72-841e-3c9de937620d_WhatsApp Image 2026-03-21 at 7.28.38 AM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 73717309: ' + @M; ELSE PRINT 'ERROR DNI 73717309: ' + @M;
GO

-- [236/318] LUHANA DARLEN YESQUEN VASQUEZ (DNI 73720126)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'73720126',
    @Contra             = N'73720126',
    @Nombre             = N'LUHANA DARLEN',
    @Apellido           = N'YESQUEN VASQUEZ',
    @Dni                = N'73720126',
    @Email              = N'73720126@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'04092009',
    @Direccion          = N'GENERAL CORDOBA 561 TABLADA DE LURIN',
    @Distrito           = N'VMT',
    @Colegio            = N'LA ALBORADA',
    @Grado              = N'5 TO',
    @TelPersonal        = N'946005760',
    @TelApoderado       = N'927724842',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/5b95c726-c90e-4a0a-9738-2483f7defcf4_WhatsApp Image 2026-01-16 at 3.34.42 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 73720126: ' + @M; ELSE PRINT 'ERROR DNI 73720126: ' + @M;
GO

-- [237/318] ADRIAN HUAHUAMULLO POMARI (DNI 73724021)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'73724021',
    @Contra             = N'73724021',
    @Nombre             = N'ADRIAN',
    @Apellido           = N'HUAHUAMULLO POMARI',
    @Dni                = N'73724021',
    @Email              = N'adrian@gmail.com',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'26052009',
    @Direccion          = N'CALLE SAN JUAN BAUTISTA 127 VMT',
    @Distrito           = N'VILLA MARIA DEL TRIUNFO',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'940342600',
    @TelApoderado       = N'917400982',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/7c4af2dc-5f64-4fec-8b39-4ded841ad993_WhatsApp Image 2026-03-25 at 4.53.34 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 73724021: ' + @M; ELSE PRINT 'ERROR DNI 73724021: ' + @M;
GO

-- [238/318] MARIANA FERNANDA VARGAS GUEVARA (DNI 73724531)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'73724531',
    @Contra             = N'73724531',
    @Nombre             = N'MARIANA FERNANDA',
    @Apellido           = N'VARGAS GUEVARA',
    @Dni                = N'73724531',
    @Email              = N'MARIANA@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'15092009',
    @Direccion          = N'LAS FLORES DE VILLA MZ A1 LOTE 40 - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'IE SILVIA OCHOA',
    @Grado              = N'5',
    @TelPersonal        = N'977902568',
    @TelApoderado       = N'977902568',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/a5221e6c-a34e-478d-b0cb-5b2f058f0447_WhatsApp Image 2026-05-13 at 5.04.24 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 73724531: ' + @M; ELSE PRINT 'ERROR DNI 73724531: ' + @M;
GO

-- [239/318] LUCIANA MILAGRITOS MORA MORENO (DNI 73729192)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'73729192',
    @Contra             = N'73729192',
    @Nombre             = N'LUCIANA MILAGRITOS',
    @Apellido           = N'MORA MORENO',
    @Dni                = N'73729192',
    @Email              = N'LUCIANA@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'24092009',
    @Direccion          = N'JR. FELIPE ARANCIVIA # 468 - ZONA "C" - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'IEP ANDRES BELLO',
    @Grado              = N'5',
    @TelPersonal        = N'947918897',
    @TelApoderado       = N'980835979',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = NULL,
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 73729192: ' + @M; ELSE PRINT 'ERROR DNI 73729192: ' + @M;
GO

-- [240/318] ANHAI ZEGARRA MALLMA (DNI 73730920)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'73730920',
    @Contra             = N'73730920',
    @Nombre             = N'ANHAI',
    @Apellido           = N'ZEGARRA MALLMA',
    @Dni                = N'73730920',
    @Email              = N'ANHAI@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'14092009',
    @Direccion          = N'MZ I1 - LOTE 28 - ALF. UGARTE - P.A. - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'FE Y ALEGRIA',
    @Grado              = N'5TO',
    @TelPersonal        = N'938478390',
    @TelApoderado       = N'957550175',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/3594cb6b-6734-418d-8137-fdfc445c190f_WhatsApp Image 2026-06-05 at 8.40.54 AM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 73730920: ' + @M; ELSE PRINT 'ERROR DNI 73730920: ' + @M;
GO

-- [241/318] JUAN JOEL DE LA CRUZ VELASQUEZ (DNI 73839348)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'73839348',
    @Contra             = N'73839348',
    @Nombre             = N'JUAN JOEL',
    @Apellido           = N'DE LA CRUZ VELASQUEZ',
    @Dni                = N'73839348',
    @Email              = N'JUAN@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'26092009',
    @Direccion          = N'CALLE GRAU 29 MZ B LT 30 PJ HEROES DE SAN JUAN - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'JULIO CESAR ESCOBAR',
    @Grado              = N'5TO',
    @TelPersonal        = N'969377194',
    @TelApoderado       = N'982764889',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/e83cce73-d911-43ad-900d-51d19ae1f61f_Foto carnet (4).jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 73839348: ' + @M; ELSE PRINT 'ERROR DNI 73839348: ' + @M;
GO

-- [242/318] LUANA AYLIN ALMEIDA GONZALEZ (DNI 73844686)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'73844686',
    @Contra             = N'73844686',
    @Nombre             = N'LUANA AYLIN',
    @Apellido           = N'ALMEIDA GONZALEZ',
    @Dni                = N'73844686',
    @Email              = N'73844686@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'08102009',
    @Direccion          = N'CALLE N COOP. AMERICA MZ T1 LT6',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'IE JOSE M ARGUEDAS 7081',
    @Grado              = N'5TO',
    @TelPersonal        = N'980514915',
    @TelApoderado       = N'992512515',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/004a3d31-fc90-44b1-9043-61d4a0b0140b_21.jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 73844686: ' + @M; ELSE PRINT 'ERROR DNI 73844686: ' + @M;
GO

-- [243/318] VALERIA CRUZ JANAMPA (DNI 73847142)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'73847142',
    @Contra             = N'73847142',
    @Nombre             = N'VALERIA',
    @Apellido           = N'CRUZ JANAMPA',
    @Dni                = N'73847142',
    @Email              = N'73847142@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'09112009',
    @Direccion          = N'MZ K7 LT08 - 1RO DE MAYO P.A. - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'IE EL NAZARANO',
    @Grado              = N'5TO',
    @TelPersonal        = N'947170753',
    @TelApoderado       = N'970723343',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/23c006bc-9530-43b4-93a3-5dd18763a728_WhatsApp Image 2026-03-21 at 9.33.25 AM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 73847142: ' + @M; ELSE PRINT 'ERROR DNI 73847142: ' + @M;
GO

-- [244/318] LUCIANA ALEXANDRA SOLSOL CCANAHUIRE (DNI 73848138)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'73848138',
    @Contra             = N'73848138',
    @Nombre             = N'LUCIANA ALEXANDRA',
    @Apellido           = N'SOLSOL CCANAHUIRE',
    @Dni                = N'73848138',
    @Email              = N'73848138@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'11112009',
    @Direccion          = N'CIRO ALEGRIA - MZ K - LOTE 20 - URB AMAUTA - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'ANDRES BELLO IEP',
    @Grado              = N'5TO',
    @TelPersonal        = N'981157036',
    @TelApoderado       = N'907048028',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/2e915b26-03c1-4c09-a4fc-96ef28b7539c_WhatsApp Image 2026-05-28 at 5.01.58 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 73848138: ' + @M; ELSE PRINT 'ERROR DNI 73848138: ' + @M;
GO

-- [245/318] ERICK ALEJANDRO MENDOZA LLAXA (DNI 73851612)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'73851612',
    @Contra             = N'73851612',
    @Nombre             = N'ERICK ALEJANDRO',
    @Apellido           = N'MENDOZA LLAXA',
    @Dni                = N'73851612',
    @Email              = N'ERICK@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'05052009',
    @Direccion          = N'AV. LOS EUCALIPTOS MZ A LT 06 ASOC. VIV. M. SANTOS - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'IE RAMON CASTILLA',
    @Grado              = N'5TO',
    @TelPersonal        = N'964426757',
    @TelApoderado       = N'993499262',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/c7051c96-f705-447b-8fea-90a1bdc3c04f_Foto carnet (2).jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 73851612: ' + @M; ELSE PRINT 'ERROR DNI 73851612: ' + @M;
GO

-- [246/318] SONIA AVIGAIL MAGDALEY NEVADO MENDOZA (DNI 73922177)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'73922177',
    @Contra             = N'73922177',
    @Nombre             = N'SONIA AVIGAIL MAGDALEY',
    @Apellido           = N'NEVADO MENDOZA',
    @Dni                = N'73922177',
    @Email              = N'SONIA@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'15122009',
    @Direccion          = NULL,
    @Distrito           = N'SJM',
    @Colegio            = N'INNOVA SCHOOLS',
    @Grado              = N'5 TO',
    @TelPersonal        = N'73922177',
    @TelApoderado       = N'966804526',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/f3db48b7-96d1-42ea-a4d1-ec50d749772d_Foto carnet (5).jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 73922177: ' + @M; ELSE PRINT 'ERROR DNI 73922177: ' + @M;
GO

-- [247/318] KIARA SABRINA EGUIA TORRES (DNI 73923915)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'73923915',
    @Contra             = N'73923915',
    @Nombre             = N'KIARA SABRINA',
    @Apellido           = N'EGUIA TORRES',
    @Dni                = N'73923915',
    @Email              = N'73923915@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'21122009',
    @Direccion          = N'AV. ANDRES AVELINO CACERES - MZ E LOTE 5 - HEROES DE SAN JUAN - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'NACIONES UNIDAS',
    @Grado              = N'5TO',
    @TelPersonal        = N'958861580',
    @TelApoderado       = N'917352150',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/4a514692-6ced-4689-873b-92afce98f197_WhatsApp Image 2026-06-05 at 8.40.53 AM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 73923915: ' + @M; ELSE PRINT 'ERROR DNI 73923915: ' + @M;
GO

-- [248/318] FLOR ESTEFANY BUSTAMANTE CACHIQUE (DNI 73925375)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'73925375',
    @Contra             = N'73925375',
    @Nombre             = N'FLOR ESTEFANY',
    @Apellido           = N'BUSTAMANTE CACHIQUE',
    @Dni                = N'73925375',
    @Email              = N'73925375@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'19122009',
    @Direccion          = N'PSJ. 32 S/N MZ T LOTE 11 -PISO 01 INTER C . AA.HH. SANTA ISABEL STGO SURCO',
    @Distrito           = N'SANTIAGO DE SURCO',
    @Colegio            = N'IE SANTA ISABEL DE VILLZ',
    @Grado              = N'5TO',
    @TelPersonal        = N'946823389',
    @TelApoderado       = N'928822619',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/2bcf4361-00bb-41b2-967e-56f2cce42702_WhatsApp Image 2026-05-13 at 5.06.39 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 73925375: ' + @M; ELSE PRINT 'ERROR DNI 73925375: ' + @M;
GO

-- [249/318] SANTILLAN GOICOCHEA FLOR ALESSANDRA J. (DNI 73925969)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'73925969',
    @Contra             = N'73925969',
    @Nombre             = N'SANTILLAN GOICOCHEA',
    @Apellido           = N'FLOR ALESSANDRA J.',
    @Dni                = N'73925969',
    @Email              = N'73925969@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'28122009',
    @Direccion          = N'CALLE MIRAMAR MZ F LT 05 STA ISABEL DE VILLA - SURCO',
    @Distrito           = N'SURCO',
    @Colegio            = N'IE BRISAS DE VILLA',
    @Grado              = N'5TO',
    @TelPersonal        = N'912123170',
    @TelApoderado       = N'924709374',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/a6ad18aa-830b-4b23-96df-ea8aa25d64ae_perfil.jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 73925969: ' + @M; ELSE PRINT 'ERROR DNI 73925969: ' + @M;
GO

-- [250/318] PATRICK HERRERA OVIEDO (DNI 74001859)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'74001859',
    @Contra             = N'74001859',
    @Nombre             = N'PATRICK',
    @Apellido           = N'HERRERA OVIEDO',
    @Dni                = N'74001859',
    @Email              = N'PATRICK@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'19092008',
    @Direccion          = N'JOYAS DE SAN SEBASTIAN - CUZCO',
    @Distrito           = N'CUZCO',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'925379495',
    @TelApoderado       = N'994821021',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = NULL,
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 74001859: ' + @M; ELSE PRINT 'ERROR DNI 74001859: ' + @M;
GO

-- [251/318] BRUNO ALCIVIADES NEYRA RAMOS (DNI 74009072)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'74009072',
    @Contra             = N'74009072',
    @Nombre             = N'BRUNO ALCIVIADES',
    @Apellido           = N'NEYRA RAMOS',
    @Dni                = N'74009072',
    @Email              = N'BRUNO@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'28012010',
    @Direccion          = N'AV. LAS ORQUIDEAS MZ A - LOTE 1A - VES',
    @Distrito           = N'VILLA EL SALVADOR',
    @Colegio            = N'PERUANO JAPONEZ',
    @Grado              = N'5',
    @TelPersonal        = N'907026121',
    @TelApoderado       = N'922416671',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = NULL,
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 74009072: ' + @M; ELSE PRINT 'ERROR DNI 74009072: ' + @M;
GO

-- [252/318] NICOLAS SNAYD CARDENAS RAZURI (DNI 74014440)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'74014440',
    @Contra             = N'74014440',
    @Nombre             = N'NICOLAS SNAYD',
    @Apellido           = N'CARDENAS RAZURI',
    @Dni                = N'74014440',
    @Email              = N'74014440@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'20012010',
    @Direccion          = N'MZ C - LOTE 18 - VILLA LAGO - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'BRISAS DE VILLA',
    @Grado              = N'5TO',
    @TelPersonal        = N'992158085',
    @TelApoderado       = N'938504749',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/0d6c6275-7d5b-4cdd-a9e5-ddeee06f8419_WhatsApp Image 2026-05-27 at 5.04.04 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 74014440: ' + @M; ELSE PRINT 'ERROR DNI 74014440: ' + @M;
GO

-- [253/318] JOSHUA DANNY GABRIEL RAMOS CHOQUE (DNI 74102922)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'74102922',
    @Contra             = N'74102922',
    @Nombre             = N'JOSHUA DANNY GABRIEL',
    @Apellido           = N'RAMOS CHOQUE',
    @Dni                = N'74102922',
    @Email              = N'DANNY@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'01032010',
    @Direccion          = N'CA. JUAN OCHOA 362 - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'IE JAVIER HERAUD',
    @Grado              = N'5TO',
    @TelPersonal        = N'957750616',
    @TelApoderado       = N'987923313',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/0df1ff07-3cf8-4dee-8354-af3d147b808f_WhatsApp Image 2026-03-21 at 9.37.01 AM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 74102922: ' + @M; ELSE PRINT 'ERROR DNI 74102922: ' + @M;
GO

-- [254/318] ABIE ADRIANA QUILLA SENCARA (DNI 74109317)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'74109317',
    @Contra             = N'74109317',
    @Nombre             = N'ABIE ADRIANA',
    @Apellido           = N'QUILLA SENCARA',
    @Dni                = N'74109317',
    @Email              = N'ABIE@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'13032010',
    @Direccion          = N'AA.HH. VILLA SAN JUAN - NVA RINCONADA - MZ D - LT 09 - P.A. - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'IE PARROQUIAL NIÑO JESUS',
    @Grado              = N'5',
    @TelPersonal        = N'919645739',
    @TelApoderado       = N'996163125',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/d7b03e9b-46ca-4f92-9f0a-cb60ac0db7e4_WhatsApp Image 2026-05-27 at 5.04.16 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 74109317: ' + @M; ELSE PRINT 'ERROR DNI 74109317: ' + @M;
GO

-- [255/318] PIERO ANDRES HUAMAN VILLALOBOS (DNI 74110561)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'74110561',
    @Contra             = N'74110561',
    @Nombre             = N'PIERO ANDRES',
    @Apellido           = N'HUAMAN VILLALOBOS',
    @Dni                = N'74110561',
    @Email              = N'74110561@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'16032010',
    @Direccion          = N'AA.HH. LOS JARDINES MZ C LT 01 - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'IE NACIONES UNIDAS',
    @Grado              = N'5TO',
    @TelPersonal        = NULL,
    @TelApoderado       = N'997481194',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/e1765f0f-82b2-461b-b105-44015ade5133_WhatsApp Image 2026-03-25 at 4.54.16 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 74110561: ' + @M; ELSE PRINT 'ERROR DNI 74110561: ' + @M;
GO

-- [256/318] GRECIA IVETH MAMANI MAMANI (DNI 74128404)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'74128404',
    @Contra             = N'74128404',
    @Nombre             = N'GRECIA IVETH',
    @Apellido           = N'MAMANI MAMANI',
    @Dni                = N'74128404',
    @Email              = N'GRECIA@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'13052005',
    @Direccion          = N'CALLE R1 - PJ. NUEVO HORIZONTE PAMP. ALT. MZ 25 - LT. 15',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'989208561',
    @TelApoderado       = N'982293583',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/1bb850f3-0541-4910-8d45-ae023d6f7ee2_WhatsApp Image 2026-05-27 at 9.36.15 AM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 74128404: ' + @M; ELSE PRINT 'ERROR DNI 74128404: ' + @M;
GO

-- [257/318] LUZ ESTRELLA JESUSI JIMENEZ (DNI 74187032)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'74187032',
    @Contra             = N'74187032',
    @Nombre             = N'LUZ ESTRELLA',
    @Apellido           = N'JESUSI JIMENEZ',
    @Dni                = N'74187032',
    @Email              = N'LUZ@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'10042010',
    @Direccion          = N'MZ "J" LOTE 18 - BRISAS DE VILLA - SURCO',
    @Distrito           = N'SURCO',
    @Colegio            = N'IE BRISAS DE VILLA',
    @Grado              = N'4TO',
    @TelPersonal        = N'902567912',
    @TelApoderado       = N'912482588',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = NULL,
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 74187032: ' + @M; ELSE PRINT 'ERROR DNI 74187032: ' + @M;
GO

-- [258/318] LUANA MICAELA RAMIREZ LOZADA (DNI 74187147)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'74187147',
    @Contra             = N'74187147',
    @Nombre             = N'LUANA MICAELA',
    @Apellido           = N'RAMIREZ LOZADA',
    @Dni                = N'74187147',
    @Email              = N'74187147@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'14042010',
    @Direccion          = N'AV. JUAN VELASCO ALVARADO 918 HEROES DE SAN JUAN -  SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'IE ANTONIO RAYMONDI',
    @Grado              = N'3RO',
    @TelPersonal        = N'927831133',
    @TelApoderado       = N'907657611',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/64571628-adf9-4e65-b637-e8738c0fecca_RAMIREZ LOZADA LUANA MICAELA.jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 74187147: ' + @M; ELSE PRINT 'ERROR DNI 74187147: ' + @M;
GO

-- [259/318] ADRIANA ALESSANDRA ARI RUIZ (DNI 74189523)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'74189523',
    @Contra             = N'74189523',
    @Nombre             = N'ADRIANA ALESSANDRA',
    @Apellido           = N'ARI RUIZ',
    @Dni                = N'74189523',
    @Email              = N'ADRIANA@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'03022010',
    @Direccion          = N'AV. JOSE MARIA SEGUIN # 588 - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'JOHAN KEPLER SJL',
    @Grado              = N'5TO',
    @TelPersonal        = N'991074593',
    @TelApoderado       = N'962752868',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/e388c188-9781-43c7-9de2-a31b20519711_WhatsApp Image 2026-06-01 at 11.37.31 AM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 74189523: ' + @M; ELSE PRINT 'ERROR DNI 74189523: ' + @M;
GO

-- [260/318] GIANCARLO MARIÑO GARCIA (DNI 74300675)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'74300675',
    @Contra             = N'74300675',
    @Nombre             = N'GIANCARLO',
    @Apellido           = N'MARIÑO GARCIA',
    @Dni                = N'74300675',
    @Email              = N'giancarlofilodoxia@gmail.com',
    @IdTipoUsuario      = N'1',
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
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/e8b1bb55-1d3f-436d-9265-7b1cbfb116be_MARIÑO.png',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 74300675: ' + @M; ELSE PRINT 'ERROR DNI 74300675: ' + @M;
GO

-- [261/318] EDUARD LEONEL OSCCO PORRAS (DNI 74331514)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'74331514',
    @Contra             = N'74331514',
    @Nombre             = N'EDUARD LEONEL',
    @Apellido           = N'OSCCO PORRAS',
    @Dni                = N'74331514',
    @Email              = N'EDUARD@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'22062010',
    @Direccion          = N'PROLONG PEDRO MIOTTA 715 - D - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'IE NACIONES UNIDAS',
    @Grado              = N'4TO',
    @TelPersonal        = NULL,
    @TelApoderado       = N'995577273',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/cf48f3ae-4ba7-4560-a0c1-32273f545169_WhatsApp Image 2026-03-19 at 12.59.33 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 74331514: ' + @M; ELSE PRINT 'ERROR DNI 74331514: ' + @M;
GO

-- [262/318] STEFANO CARDENAS LUDEÑA (DNI 74344076)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'74344076',
    @Contra             = N'74344076',
    @Nombre             = N'STEFANO',
    @Apellido           = N'CARDENAS LUDEÑA',
    @Dni                = N'74344076',
    @Email              = N'74344076@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'20072010',
    @Direccion          = N'ASOC. VILLA REPORTERO GRAFICO - STGO SURCO',
    @Distrito           = N'SANTIAGO DE SURCO',
    @Colegio            = N'IE VILLARREAL',
    @Grado              = N'5TO',
    @TelPersonal        = N'959701942',
    @TelApoderado       = N'957267116',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/2b090b62-cafa-4015-b927-85b42d9e63dd_WhatsApp Image 2026-05-27 at 5.04.29 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 74344076: ' + @M; ELSE PRINT 'ERROR DNI 74344076: ' + @M;
GO

-- [263/318] SAMANTA MAGNOLIA CAMARGO OLIVER (DNI 74475423)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'74475423',
    @Contra             = N'74475423',
    @Nombre             = N'SAMANTA MAGNOLIA',
    @Apellido           = N'CAMARGO OLIVER',
    @Dni                = N'74475423',
    @Email              = N'SAMANTA@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'30042005',
    @Direccion          = N'RESIDENCIAL ALIPIO PONCE - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'916344636',
    @TelApoderado       = N'988638564',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = NULL,
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 74475423: ' + @M; ELSE PRINT 'ERROR DNI 74475423: ' + @M;
GO

-- [264/318] LUNA BELEN ESTRADA RIVERA (DNI 74511921)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'74511921',
    @Contra             = N'74511921',
    @Nombre             = N'LUNA BELEN',
    @Apellido           = N'ESTRADA RIVERA',
    @Dni                = N'74511921',
    @Email              = N'74511921@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'08102007',
    @Direccion          = N'CALLE B 1RO DE MAYO MZ S7 LT 8 - P.A. - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'907258441',
    @TelApoderado       = N'943738716',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/69707ebd-5f24-4a87-b461-eb890812d24f_perfil.jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 74511921: ' + @M; ELSE PRINT 'ERROR DNI 74511921: ' + @M;
GO

-- [265/318] CARMEN BELEN PAULINO CARRASCO (DNI 74516048)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'74516048',
    @Contra             = N'74516048',
    @Nombre             = N'CARMEN BELEN',
    @Apellido           = N'PAULINO CARRASCO',
    @Dni                = N'74516048',
    @Email              = N'74516048@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'13082010',
    @Direccion          = N'MZ. B LT. 20 P. A - AV. EMANCIPACIÓN',
    @Distrito           = N'SJM',
    @Colegio            = N'JUANA ALARCO DE BAMMETET',
    @Grado              = N'4 TO',
    @TelPersonal        = N'960209398',
    @TelApoderado       = N'922071852',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/6f72bc54-c860-4272-944a-3dbbd5a3d3ac_1000449115.jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 74516048: ' + @M; ELSE PRINT 'ERROR DNI 74516048: ' + @M;
GO

-- [266/318] KIARA SALOME HUACCAICACHACC TAPIA (DNI 74679450)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'74679450',
    @Contra             = N'74679450',
    @Nombre             = N'KIARA SALOME',
    @Apellido           = N'HUACCAICACHACC TAPIA',
    @Dni                = N'74679450',
    @Email              = N'74679450@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'09062010',
    @Direccion          = N'CALLE 4 MZ X1 - LOTE 26 - ASOC. VILLA JESUS - VES',
    @Distrito           = N'VILLA EL SALVADOR',
    @Colegio            = N'IE REP BOLIVIA',
    @Grado              = N'4',
    @TelPersonal        = N'981164435',
    @TelApoderado       = N'998235354',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = NULL,
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 74679450: ' + @M; ELSE PRINT 'ERROR DNI 74679450: ' + @M;
GO

-- [267/318] ARIANA DE YADIRA HUACCAICACHACC TAPIA (DNI 74679464)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'74679464',
    @Contra             = N'74679464',
    @Nombre             = N'ARIANA DE YADIRA',
    @Apellido           = N'HUACCAICACHACC TAPIA',
    @Dni                = N'74679464',
    @Email              = N'74679464@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'09062010',
    @Direccion          = N'CALLE 4 MZ X1 - LOTE 26 - ASOC. VILLA JESUS - VES',
    @Distrito           = N'VILLA EL SALVADOR',
    @Colegio            = N'IE REP BOLIVIA',
    @Grado              = N'4',
    @TelPersonal        = N'944156257',
    @TelApoderado       = N'998235354',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = NULL,
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 74679464: ' + @M; ELSE PRINT 'ERROR DNI 74679464: ' + @M;
GO

-- [268/318] ADRIANA MARITZA VELARDE PALOMINO (DNI 74680296)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'74680296',
    @Contra             = N'74680296',
    @Nombre             = N'ADRIANA MARITZA',
    @Apellido           = N'VELARDE PALOMINO',
    @Dni                = N'74680296',
    @Email              = N'74680296@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'25092010',
    @Direccion          = N'AV. EL SOL # 1568 - CHORRILLOS',
    @Distrito           = N'CHORRILLOS',
    @Colegio            = N'INNOVA',
    @Grado              = N'4TO',
    @TelPersonal        = N'913841553',
    @TelApoderado       = N'949141746',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = NULL,
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 74680296: ' + @M; ELSE PRINT 'ERROR DNI 74680296: ' + @M;
GO

-- [269/318] CLARA STEPHANY REYES SANABRIA (DNI 74683870)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'74683870',
    @Contra             = N'74683870',
    @Nombre             = N'CLARA STEPHANY',
    @Apellido           = N'REYES SANABRIA',
    @Dni                = N'74683870',
    @Email              = N'CLARA@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'01102010',
    @Direccion          = N'MZ G1 LT 21 LAS FLORES DE VILLA',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'Las Flores de VIlla 7230',
    @Grado              = N'4TO',
    @TelPersonal        = N'917735322',
    @TelApoderado       = N'965135295',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/1eba788c-bc76-4bc9-9e3c-f8fdb5ff024b_perfil.jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 74683870: ' + @M; ELSE PRINT 'ERROR DNI 74683870: ' + @M;
GO

-- [270/318] SAMANTHA ISABELLA CANO MENDIVIL (DNI 74794155)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'74794155',
    @Contra             = N'74794155',
    @Nombre             = N'SAMANTHA ISABELLA',
    @Apellido           = N'CANO MENDIVIL',
    @Dni                = N'74794155',
    @Email              = N'SAMANTHA@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'28092010',
    @Direccion          = N'AV. TOMAS GUZMAN 963 - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'987569486',
    @TelApoderado       = N'982848551',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/dddfc3a7-c4c8-4882-8790-9546265785d9_359 sin título_20260320083931.png',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 74794155: ' + @M; ELSE PRINT 'ERROR DNI 74794155: ' + @M;
GO

-- [271/318] PIERO ANGELO ACUÑA FLORES (DNI 75026943)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'75026943',
    @Contra             = N'75026943',
    @Nombre             = N'PIERO ANGELO',
    @Apellido           = N'ACUÑA FLORES',
    @Dni                = N'75026943',
    @Email              = N'75026943@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'04112010',
    @Direccion          = N'MZ. D LT. 6 LAS PRADERAS PAMPLONA',
    @Distrito           = N'SJM',
    @Colegio            = N'IE EL NAZARENO',
    @Grado              = N'4 TO',
    @TelPersonal        = N'906728856',
    @TelApoderado       = N'951909848',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/8e6c5122-b5bd-4632-b25a-6c78712a6dc4_perfil.jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 75026943: ' + @M; ELSE PRINT 'ERROR DNI 75026943: ' + @M;
GO

-- [272/318] HEIDER MALLMA AQUINO (DNI 75135248)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'75135248',
    @Contra             = N'75135248',
    @Nombre             = N'HEIDER',
    @Apellido           = N'MALLMA AQUINO',
    @Dni                = N'75135248',
    @Email              = N'heider.mallama@hotmail.com',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'10111998',
    @Direccion          = NULL,
    @Distrito           = NULL,
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = NULL,
    @TelApoderado       = NULL,
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/910bcb9c-289c-4b17-badc-af740439746b_Heider.png',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 75135248: ' + @M; ELSE PRINT 'ERROR DNI 75135248: ' + @M;
GO

-- [273/318] REY ALEXANDER MONTAÑO HUACHUACO (DNI 75288169)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'75288169',
    @Contra             = N'75288169',
    @Nombre             = N'REY ALEXANDER',
    @Apellido           = N'MONTAÑO HUACHUACO',
    @Dni                = N'75288169',
    @Email              = N'REY@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'03122010',
    @Direccion          = N'AA.HH. MATEO PUMACAHUA SECT 2  - MZ A LT 01 - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'IE FLORES DE VILLA',
    @Grado              = N'4TO',
    @TelPersonal        = N'908585639',
    @TelApoderado       = N'967676266',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/56b20939-b234-48b8-a8a1-f240b39d63b5_WhatsApp Image 2026-04-21 at 3.12.40 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 75288169: ' + @M; ELSE PRINT 'ERROR DNI 75288169: ' + @M;
GO

-- [274/318] JOHAN MATIAS AMANQUI FLORES (DNI 75637824)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'75637824',
    @Contra             = N'75637824',
    @Nombre             = N'JOHAN MATIAS',
    @Apellido           = N'AMANQUI FLORES',
    @Dni                = N'75637824',
    @Email              = N'75637824@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'27122010',
    @Direccion          = N'MZ E LT 02 LAS LOMAS - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'IE LA RINCONADA',
    @Grado              = N'4TO',
    @TelPersonal        = N'983335867',
    @TelApoderado       = N'983335867',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/4d776ec5-f859-4bce-ad73-920e59b178c1_WhatsApp Image 2026-03-28 at 9.39.20 AM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 75637824: ' + @M; ELSE PRINT 'ERROR DNI 75637824: ' + @M;
GO

-- [275/318] ALESSANDRA ESCRIBA GOMEZ (DNI 75638045)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'75638045',
    @Contra             = N'75638045',
    @Nombre             = N'ALESSANDRA',
    @Apellido           = N'ESCRIBA GOMEZ',
    @Dni                = N'75638045',
    @Email              = N'75638045@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'14012011',
    @Direccion          = N'MZ 7G E LT 44 P.A. - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'IEP NIÑO JESUS',
    @Grado              = N'4TO',
    @TelPersonal        = N'934904746',
    @TelApoderado       = N'996102796',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/385d2dda-23a0-40f3-a08f-268b7a632870_perfil.jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 75638045: ' + @M; ELSE PRINT 'ERROR DNI 75638045: ' + @M;
GO

-- [276/318] JOSE EDU CRUCES PRADO (DNI 75644837)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'75644837',
    @Contra             = N'75644837',
    @Nombre             = N'JOSE EDU',
    @Apellido           = N'CRUCES PRADO',
    @Dni                = N'75644837',
    @Email              = N'75644837@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'10122010',
    @Direccion          = N'AV. CAHUIDE MZ. N LT. 01 URB. MATEO PUMACAHUA',
    @Distrito           = N'SURCO',
    @Colegio            = N'IE MATEO PUMACAHUA 6097',
    @Grado              = N'3 ERO',
    @TelPersonal        = N'968445277',
    @TelApoderado       = N'985828232',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/986d63c3-59b4-4c41-9b97-db8892ee742b_11.jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 75644837: ' + @M; ELSE PRINT 'ERROR DNI 75644837: ' + @M;
GO

-- [277/318] NICOLAS USURIAGA MINAYA (DNI 75645913)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'75645913',
    @Contra             = N'75645913',
    @Nombre             = N'NICOLAS',
    @Apellido           = N'USURIAGA MINAYA',
    @Dni                = N'75645913',
    @Email              = N'75645913@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'24012011',
    @Direccion          = N'ST 6 GRUPO 3 A - MZ F LOTE 27 -VES',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'IE PERUANO FRANCES',
    @Grado              = N'4TO',
    @TelPersonal        = N'950650728',
    @TelApoderado       = N'981225571',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/8da61a80-1c7c-4bbb-b44c-494ea7519b38_WhatsApp Image 2026-05-14 at 5.14.34 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 75645913: ' + @M; ELSE PRINT 'ERROR DNI 75645913: ' + @M;
GO

-- [278/318] ANDREA XIMENA PFUÑO CCALLA (DNI 75870439)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'75870439',
    @Contra             = N'75870439',
    @Nombre             = N'ANDREA XIMENA',
    @Apellido           = N'PFUÑO CCALLA',
    @Dni                = N'75870439',
    @Email              = N'75870439@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'04042006',
    @Direccion          = N'MZ. J4 LT. 5 AMPLIACIÓN 1 SECT. 12 NOV. P. A.',
    @Distrito           = N'SJM',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'912451519',
    @TelApoderado       = N'918287980',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/b341e437-5356-4c08-95f5-e7c810ef4fd0_WhatsApp Image 2026-01-10 at 2.19.20 PM (1).jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 75870439: ' + @M; ELSE PRINT 'ERROR DNI 75870439: ' + @M;
GO

-- [279/318] GERARDO GABRIEL RAVICHAGUA BASURTO (DNI 76401553)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'76401553',
    @Contra             = N'76401553',
    @Nombre             = N'GERARDO GABRIEL',
    @Apellido           = N'RAVICHAGUA BASURTO',
    @Dni                = N'76401553',
    @Email              = N'GERARDO@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'27032025',
    @Direccion          = N'MZ D - LOTE 22 - COOP ALIPIO PONCE - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'957120075',
    @TelApoderado       = N'939376469',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/315605cc-107a-470b-922c-5768bac219ac_WhatsApp Image 2026-06-09 at 4.56.14 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 76401553: ' + @M; ELSE PRINT 'ERROR DNI 76401553: ' + @M;
GO

-- [280/318] JADE ESTRELLA GOMEZ OSORIO (DNI 76719410)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'76719410',
    @Contra             = N'76719410',
    @Nombre             = N'JADE ESTRELLA',
    @Apellido           = N'GOMEZ OSORIO',
    @Dni                = N'76719410',
    @Email              = N'76719410@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'18032011',
    @Direccion          = N'MZ B - LOTE 31 - COOP. SANTA URSULA - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'IE JULIO CESAR ESCOBAR',
    @Grado              = N'4TO',
    @TelPersonal        = N'900114920',
    @TelApoderado       = N'990008655',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/1d334df9-9623-468c-86c1-1693335560af_WhatsApp Image 2026-04-25 at 9.50.47 AM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 76719410: ' + @M; ELSE PRINT 'ERROR DNI 76719410: ' + @M;
GO

-- [281/318] DANIEL LOZADA GARMA (DNI 76790492)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'76790492',
    @Contra             = N'76790492',
    @Nombre             = N'DANIEL',
    @Apellido           = N'LOZADA GARMA',
    @Dni                = N'76790492',
    @Email              = N'76790492@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'04011996',
    @Direccion          = N'SAN JUAN DE MIRAFLORES',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'952733685',
    @TelApoderado       = N'952733685',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = NULL,
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 76790492: ' + @M; ELSE PRINT 'ERROR DNI 76790492: ' + @M;
GO

-- [282/318] YAMILE VALERY SANCHEZ MALLMA (DNI 76793055)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'76793055',
    @Contra             = N'76793055',
    @Nombre             = N'YAMILE VALERY',
    @Apellido           = N'SANCHEZ MALLMA',
    @Dni                = N'76793055',
    @Email              = N'YAMILE@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'22062008',
    @Direccion          = N'LAS TERRAZAS DE VILLA MZ F - LOTE 06 SANTA ISABEL - CHORRILLOS',
    @Distrito           = N'CHORRILLOS',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'939941455',
    @TelApoderado       = N'971795654',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/9f2b481e-2922-471f-806f-ba6cd4dde0e7_WhatsApp Image 2026-05-18 at 1.13.00 PM (1).jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 76793055: ' + @M; ELSE PRINT 'ERROR DNI 76793055: ' + @M;
GO

-- [283/318] FELIX ANDERSON HUAMANI HUAMANI (DNI 76851010)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'76851010',
    @Contra             = N'76851010',
    @Nombre             = N'FELIX ANDERSON',
    @Apellido           = N'HUAMANI HUAMANI',
    @Dni                = N'76851010',
    @Email              = N'76851010@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'06062001',
    @Direccion          = N'MZ D LT 01 AA.HH. PATRON SANTIAGO - SJM',
    @Distrito           = N'SAN JUAN MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'938341920',
    @TelApoderado       = N'997563712',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = NULL,
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 76851010: ' + @M; ELSE PRINT 'ERROR DNI 76851010: ' + @M;
GO

-- [284/318] JESUS AARON ROJAS CUBAS (DNI 76883912)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'76883912',
    @Contra             = N'76883912',
    @Nombre             = N'JESUS AARON',
    @Apellido           = N'ROJAS CUBAS',
    @Dni                = N'76883912',
    @Email              = N'JESUS@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'19052011',
    @Direccion          = N'MZ Q LT  23 PACIFICO 1 - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'IE JAVIER HERAUD',
    @Grado              = N'3RO',
    @TelPersonal        = NULL,
    @TelApoderado       = N'916544890',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = NULL,
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 76883912: ' + @M; ELSE PRINT 'ERROR DNI 76883912: ' + @M;
GO

-- [285/318] JUAN DANIEL DIAZ HUAMANI (DNI 76896103)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'76896103',
    @Contra             = N'76896103',
    @Nombre             = N'JUAN DANIEL',
    @Apellido           = N'DIAZ HUAMANI',
    @Dni                = N'76896103',
    @Email              = N'76896103@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'19032014',
    @Direccion          = N'COOP UMAMARCA MZ "N" LOTE "8" - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'T.M.A.',
    @Grado              = N'4TO',
    @TelPersonal        = N'924204765',
    @TelApoderado       = N'926905270',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/637fa406-f474-4216-9b70-b2eee50d5dc8_perfil.jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 76896103: ' + @M; ELSE PRINT 'ERROR DNI 76896103: ' + @M;
GO

-- [286/318] LEONEL ALVARO HUAYANAY MAYHUA (DNI 76901582)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'76901582',
    @Contra             = N'76901582',
    @Nombre             = N'LEONEL ALVARO',
    @Apellido           = N'HUAYANAY MAYHUA',
    @Dni                = N'76901582',
    @Email              = N'LEONEL@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'13052011',
    @Direccion          = N'SECTOR 3 DE JULIO MZ. LL LT. 10 P. A',
    @Distrito           = N'SJM',
    @Colegio            = N'FE Y ALEGRIA 03',
    @Grado              = N'3ERO',
    @TelPersonal        = N'926209936',
    @TelApoderado       = N'926209936',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/2a92c140-5c9c-48e0-9a73-7696a84e496d_21.jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 76901582: ' + @M; ELSE PRINT 'ERROR DNI 76901582: ' + @M;
GO

-- [287/318] VLADIMIR ANGELINO SIHUINCHA (DNI 76966551)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'76966551',
    @Contra             = N'76966551',
    @Nombre             = N'VLADIMIR',
    @Apellido           = N'ANGELINO SIHUINCHA',
    @Dni                = N'76966551',
    @Email              = N'vladimir.angelino@hotmail.com',
    @IdTipoUsuario      = N'1',
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
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/dae41b14-7f6c-46ea-aae4-8f253790116f_VLADIMIR.png',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 76966551: ' + @M; ELSE PRINT 'ERROR DNI 76966551: ' + @M;
GO

-- [288/318] KIARA MELANY PALOMINO PAJUELO (DNI 77255732)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'77255732',
    @Contra             = N'77255732',
    @Nombre             = N'KIARA MELANY',
    @Apellido           = N'PALOMINO PAJUELO',
    @Dni                = N'77255732',
    @Email              = N'77255732@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'06082011',
    @Direccion          = N'MZ. P5 LT. 15 P. A. SECTOR LEONCIO PRADO',
    @Distrito           = N'SJM',
    @Colegio            = N'IE 7035 LEONCIO PRADO',
    @Grado              = N'3 ERO',
    @TelPersonal        = N'913277266',
    @TelApoderado       = N'995091761',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/dcad16e7-7fb5-46b6-ba5b-dc138ae0d520_2.jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 77255732: ' + @M; ELSE PRINT 'ERROR DNI 77255732: ' + @M;
GO

-- [289/318] BRYAN JASE VASQUEZ DOMINGUEZ (DNI 77303989)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'77303989',
    @Contra             = N'77303989',
    @Nombre             = N'BRYAN JASE',
    @Apellido           = N'VASQUEZ DOMINGUEZ',
    @Dni                = N'77303989',
    @Email              = N'BRYAN@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'10082011',
    @Direccion          = N'PSJ. TULIPANES MZ G - LOTE 2 - P.A. - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'IE NACIONES UNIDAS',
    @Grado              = N'3RO',
    @TelPersonal        = N'995889997',
    @TelApoderado       = N'995889997',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = NULL,
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 77303989: ' + @M; ELSE PRINT 'ERROR DNI 77303989: ' + @M;
GO

-- [290/318] TREYCI NICOLE BEJAR PAQUIYAURI (DNI 77312764)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'77312764',
    @Contra             = N'77312764',
    @Nombre             = N'TREYCI NICOLE',
    @Apellido           = N'BEJAR PAQUIYAURI',
    @Dni                = N'77312764',
    @Email              = N'TREYCI@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'07092011',
    @Direccion          = N'VILLA RESIDENCIAL MZ K LOTE 09 - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'HORACIO ZEVALLOS GAMEZ',
    @Grado              = N'4TO',
    @TelPersonal        = N'963586932',
    @TelApoderado       = N'971349882',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/a389b270-b167-4ffe-a7a5-9b04ffab7284_WhatsApp Image 2026-03-14 at 11.47.58 AM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 77312764: ' + @M; ELSE PRINT 'ERROR DNI 77312764: ' + @M;
GO

-- [291/318] ANDRE F ROJAS HUARCAYA (DNI 77313195)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'77313195',
    @Contra             = N'77313195',
    @Nombre             = N'ANDRE F',
    @Apellido           = N'ROJAS HUARCAYA',
    @Dni                = N'77313195',
    @Email              = N'ANDRE@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'16092011',
    @Direccion          = N'MZ B L T 14 AA.HH. INTIHUATANA - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'IE JAVIER HERAUD',
    @Grado              = N'2DO',
    @TelPersonal        = N'968010112',
    @TelApoderado       = N'968010112',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = NULL,
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 77313195: ' + @M; ELSE PRINT 'ERROR DNI 77313195: ' + @M;
GO

-- [292/318] JEREMY NEYMAR TINCO TEJADA (DNI 77373939)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'77373939',
    @Contra             = N'77373939',
    @Nombre             = N'JEREMY NEYMAR',
    @Apellido           = N'TINCO TEJADA',
    @Dni                = N'77373939',
    @Email              = N'JEREMY@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'18102011',
    @Direccion          = N'MZ "I" LOTE "25" - EL NAZARENO P.A. - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'CESAR VALLEJO TECNICO',
    @Grado              = N'5TO',
    @TelPersonal        = N'964240325',
    @TelApoderado       = N'916532558',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/e9e2cbcd-cff3-47c1-8a89-ecd462c5a344_WhatsApp Image 2026-06-18 at 7.50.08 AM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 77373939: ' + @M; ELSE PRINT 'ERROR DNI 77373939: ' + @M;
GO

-- [293/318] CESAR EDUARDO CHOQUEHUANCA CONDORI (DNI 77444857)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'77444857',
    @Contra             = N'77444857',
    @Nombre             = N'CESAR EDUARDO',
    @Apellido           = N'CHOQUEHUANCA CONDORI',
    @Dni                = N'77444857',
    @Email              = N'CESAR@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'20112011',
    @Direccion          = N'PAMPLONA ALTA NUEVO HORIZONTE MZ. L LT. 4 PJ. E-2',
    @Distrito           = N'SJM',
    @Colegio            = N'CESAR VALLEJO',
    @Grado              = N'3 ERO',
    @TelPersonal        = N'957510303',
    @TelApoderado       = N'957510303',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/5e54cf82-11d3-4dbc-9cfd-ad0fe6f67580_perfil.jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 77444857: ' + @M; ELSE PRINT 'ERROR DNI 77444857: ' + @M;
GO

-- [294/318] LUCIANA DANITZA MAYORA ALVARADO (DNI 77518312)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'77518312',
    @Contra             = N'77518312',
    @Nombre             = N'LUCIANA DANITZA',
    @Apellido           = N'MAYORA ALVARADO',
    @Dni                = N'77518312',
    @Email              = N'77518312@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'18122011',
    @Direccion          = N'JR. PIURA P. ALTA MZ Q5 LT. 19',
    @Distrito           = N'SJM',
    @Colegio            = N'IEP GASTON MARIA',
    @Grado              = N'3 ERO',
    @TelPersonal        = N'953107431',
    @TelApoderado       = N'964131039',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/485f03bb-a97d-487e-9141-cb25d8e2580a_7 (1).jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 77518312: ' + @M; ELSE PRINT 'ERROR DNI 77518312: ' + @M;
GO

-- [295/318] MARY PAZ NAOMI JAIME ROJAS (DNI 77523227)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'77523227',
    @Contra             = N'77523227',
    @Nombre             = N'MARY PAZ NAOMI',
    @Apellido           = N'JAIME ROJAS',
    @Dni                = N'77523227',
    @Email              = N'MARY@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'27092011',
    @Direccion          = N'CALLE G MZ  E7  LT 22  PJ  1RO DE MAYO - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'IE LEONCIO PRADO 7035',
    @Grado              = N'3RO',
    @TelPersonal        = N'963893651',
    @TelApoderado       = N'955122645',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/b3b442bf-3f12-4733-b6fb-4d92471bddde_1 esolar.jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 77523227: ' + @M; ELSE PRINT 'ERROR DNI 77523227: ' + @M;
GO

-- [296/318] VALERIE MATIAS ALFARO (DNI 77550741)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'77550741',
    @Contra             = N'77550741',
    @Nombre             = N'VALERIE',
    @Apellido           = N'MATIAS ALFARO',
    @Dni                = N'77550741',
    @Email              = N'VALERIE@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'24012012',
    @Direccion          = N'SAN JUAN DE MIRAFLORES',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'IEP SACO OLIVEROS',
    @Grado              = N'2',
    @TelPersonal        = N'904501481',
    @TelApoderado       = N'993938156',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = NULL,
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 77550741: ' + @M; ELSE PRINT 'ERROR DNI 77550741: ' + @M;
GO

-- [297/318] ALEX JEFRY QUISPE ALVAREZ (DNI 77624556)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'77624556',
    @Contra             = N'77624556',
    @Nombre             = N'ALEX JEFRY',
    @Apellido           = N'QUISPE ALVAREZ',
    @Dni                = N'77624556',
    @Email              = N'ALEX@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'10042012',
    @Direccion          = N'LOS LAURELES MZ. 41 ALT. 26 P. A.',
    @Distrito           = N'SJM',
    @Colegio            = N'JOSE ANTONIO ENCINA FRNCO 7059',
    @Grado              = N'2 DO',
    @TelPersonal        = N'948700093',
    @TelApoderado       = N'986216084',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/1de4c02a-3e2e-4e74-8eaa-fa19d0ecaf5f_24.jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 77624556: ' + @M; ELSE PRINT 'ERROR DNI 77624556: ' + @M;
GO

-- [298/318] IKER ALONSO PICHIHUA ALATA (DNI 77629601)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'77629601',
    @Contra             = N'77629601',
    @Nombre             = N'IKER ALONSO',
    @Apellido           = N'PICHIHUA ALATA',
    @Dni                = N'77629601',
    @Email              = N'IKER@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'09042012',
    @Direccion          = N'LAS BRISAS DE VILLA MZ G LT 11 - SURCO',
    @Distrito           = N'SURCO',
    @Colegio            = N'SANTA ISABEL DE VILLA - CHORRILLOS',
    @Grado              = N'2',
    @TelPersonal        = N'913762078',
    @TelApoderado       = N'913762078',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = NULL,
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 77629601: ' + @M; ELSE PRINT 'ERROR DNI 77629601: ' + @M;
GO

-- [299/318] JESUS MANUEL PEÑALOZA HUAMAN (DNI 77711407)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'77711407',
    @Contra             = N'77711407',
    @Nombre             = N'JESUS MANUEL',
    @Apellido           = N'PEÑALOZA HUAMAN',
    @Dni                = N'77711407',
    @Email              = N'77711407@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'12012008',
    @Direccion          = N'VISTA ALEGRE - CHORRILLOS',
    @Distrito           = N'CHORRILLOS',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'991162973',
    @TelApoderado       = N'973501242',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/0e3a9254-04f1-4a0c-ad50-888ef98a8481_WhatsApp Image 2026-03-25 at 4.02.52 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 77711407: ' + @M; ELSE PRINT 'ERROR DNI 77711407: ' + @M;
GO

-- [300/318] MARIA STEPHANIE SOTO ALVINO (DNI 77732703)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
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
IF @R = 1 PRINT 'OK DNI 77732703: ' + @M; ELSE PRINT 'ERROR DNI 77732703: ' + @M;
GO

-- [301/318] MEDALY TREBEJO SAAVEDRA (DNI 77761993)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'77761993',
    @Contra             = N'77761993',
    @Nombre             = N'MEDALY',
    @Apellido           = N'TREBEJO SAAVEDRA',
    @Dni                = N'77761993',
    @Email              = N'MEDALY@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'17072012',
    @Direccion          = N'LAS FLORES DEL PARAISO  MZ LL LT  06  - VMT',
    @Distrito           = N'VILLA MARIA DEL TRIUNFO',
    @Colegio            = N'IE SAGRADO CORAZON DE JESUS',
    @Grado              = N'2DO',
    @TelPersonal        = NULL,
    @TelApoderado       = N'927751087',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/64ca6a77-7221-45bc-a31a-0f1790539baf_Screenshot_20260120-164328_Pinterest.jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 77761993: ' + @M; ELSE PRINT 'ERROR DNI 77761993: ' + @M;
GO

-- [302/318] RICHARD MATIAS TITO CHINCHAY (DNI 77772553)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'77772553',
    @Contra             = N'77772553',
    @Nombre             = N'RICHARD MATIAS',
    @Apellido           = N'TITO CHINCHAY',
    @Dni                = N'77772553',
    @Email              = N'RICHARD@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'30062012',
    @Direccion          = N'AV. TINGO MARIA # 528 - VMT',
    @Distrito           = N'VILLA MARIA DEL TRIUNFO',
    @Colegio            = N'IE SAGRADO CORAZON DE JESUS',
    @Grado              = N'2DO',
    @TelPersonal        = N'936845783',
    @TelApoderado       = N'922413347',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = NULL,
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 77772553: ' + @M; ELSE PRINT 'ERROR DNI 77772553: ' + @M;
GO

-- [303/318] ISAAC CRUZ JANAMPA (DNI 77826671)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'77826671',
    @Contra             = N'77826671',
    @Nombre             = N'ISAAC',
    @Apellido           = N'CRUZ JANAMPA',
    @Dni                = N'77826671',
    @Email              = N'ISAAC@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'31082012',
    @Direccion          = N'MZ K7 LT 08 - 1RO DE MAYO P.A. - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'IE EL NAZARENO',
    @Grado              = N'2DO',
    @TelPersonal        = N'970723343',
    @TelApoderado       = N'970723343',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/441dd6c3-79e4-43ac-a44a-f5204bdd57be_WhatsApp Image 2026-03-21 at 9.35.32 AM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 77826671: ' + @M; ELSE PRINT 'ERROR DNI 77826671: ' + @M;
GO

-- [304/318] YONNER HUSSEIN SUAREZ HUAMANLAZO (DNI 77862597)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'77862597',
    @Contra             = N'77862597',
    @Nombre             = N'YONNER HUSSEIN',
    @Apellido           = N'SUAREZ HUAMANLAZO',
    @Dni                = N'77862597',
    @Email              = N'YONNER@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'10102012',
    @Direccion          = N'NVA. RNDA P.A. AA.HH. PORTADA DEL SOL  MZ B  LT 04 - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'IE LEONCIO PRADO',
    @Grado              = N'2DO',
    @TelPersonal        = NULL,
    @TelApoderado       = N'997047915',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/8999450e-8dee-417c-835b-b2622aecaa11_WhatsApp Image 2026-01-28 at 13.25.34.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 77862597: ' + @M; ELSE PRINT 'ERROR DNI 77862597: ' + @M;
GO

-- [305/318] GREICY MARILLY PAMPAÑAUPA CONTRERAS (DNI 77883165)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'77883165',
    @Contra             = N'77883165',
    @Nombre             = N'GREICY MARILLY',
    @Apellido           = N'PAMPAÑAUPA CONTRERAS',
    @Dni                = N'77883165',
    @Email              = N'GREICY@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'19032009',
    @Direccion          = N'AV. NEPOMOCENO VARGAS 388 PAMPLONA BAJA - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'IEP SACO OLIVEROS',
    @Grado              = N'5TO',
    @TelPersonal        = N'973792566',
    @TelApoderado       = N'907554751',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/295229a6-ba0c-49e7-9f59-075948a4c521_WhatsApp Image 2026-03-17 at 3.59.25 PM (3).jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 77883165: ' + @M; ELSE PRINT 'ERROR DNI 77883165: ' + @M;
GO

-- [306/318] ASTRID ILLARI CHIMPAY ROCA (DNI 77983623)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'77983623',
    @Contra             = N'77983623',
    @Nombre             = N'ASTRID ILLARI',
    @Apellido           = N'CHIMPAY ROCA',
    @Dni                = N'77983623',
    @Email              = N'ASTRID@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'24122012',
    @Direccion          = N'URB. TERRAZAS DE VILLA MZ E LT 12 - CHORRILLOS',
    @Distrito           = N'CHORRILLOS',
    @Colegio            = N'IE TUPAC AMARU II',
    @Grado              = N'2DO',
    @TelPersonal        = NULL,
    @TelApoderado       = N'971347174',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/a42042f9-a092-4a1a-a681-54b7468319a3_WhatsApp Image 2026-03-14 at 11.44.44 AM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 77983623: ' + @M; ELSE PRINT 'ERROR DNI 77983623: ' + @M;
GO

-- [307/318] MATHIAS ALFREDO POVES CANDIOTTY (DNI 78001822)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'78001822',
    @Contra             = N'78001822',
    @Nombre             = N'MATHIAS ALFREDO',
    @Apellido           = N'POVES CANDIOTTY',
    @Dni                = N'78001822',
    @Email              = N'78001822@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'14122009',
    @Direccion          = N'HIPOLITO UNANUE MZ B - LOTE 18 - MARIA AUX. - SJM',
    @Distrito           = NULL,
    @Colegio            = N'IE JULIO CESAR ESCOBAR',
    @Grado              = N'5TO',
    @TelPersonal        = N'925572584',
    @TelApoderado       = N'987145342',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/32747862-ed6e-42de-8276-19025e08769e_WhatsApp Image 2026-03-25 at 4.51.51 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 78001822: ' + @M; ELSE PRINT 'ERROR DNI 78001822: ' + @M;
GO

-- [308/318] MARIA FERNANDA GUEVARA ALVARADO (DNI 78156289)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'78156289',
    @Contra             = N'78156289',
    @Nombre             = N'MARIA FERNANDA',
    @Apellido           = N'GUEVARA ALVARADO',
    @Dni                = N'78156289',
    @Email              = N'78156289@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'12072009',
    @Direccion          = N'MZ N5 - LOTE 4 - VGN BUEN PASO - P.A. - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'NACIONES UNIDAS',
    @Grado              = N'5',
    @TelPersonal        = N'902267920',
    @TelApoderado       = N'910482423',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/c70c709f-5243-4327-8f0f-8e52ade00078_WhatsApp Image 2026-05-27 at 5.03.45 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 78156289: ' + @M; ELSE PRINT 'ERROR DNI 78156289: ' + @M;
GO

-- [309/318] MISSAEL UZIEL ROBLES GAMBOA (DNI 78158981)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'78158981',
    @Contra             = N'78158981',
    @Nombre             = N'MISSAEL UZIEL',
    @Apellido           = N'ROBLES GAMBOA',
    @Dni                = N'78158981',
    @Email              = N'mr20181998@gmail.com',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'17031998',
    @Direccion          = NULL,
    @Distrito           = N'SJM',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'920454959',
    @TelApoderado       = NULL,
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/ecb44a01-bc22-48c5-b4f5-2dfa695f89ad_MISSAEL Image 4 may 2026, 12_19_15 p.m..png',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 78158981: ' + @M; ELSE PRINT 'ERROR DNI 78158981: ' + @M;
GO

-- [310/318] THALIA DAMARIS MOLINA NEIRA (DNI 78164067)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'78164067',
    @Contra             = N'78164067',
    @Nombre             = N'THALIA DAMARIS',
    @Apellido           = N'MOLINA NEIRA',
    @Dni                = N'78164067',
    @Email              = N'THALIA@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'03072013',
    @Direccion          = N'CALLE SALVADOR ALLENDE AA. HH, REP DEM ALEM MZ, X LT. 16',
    @Distrito           = N'SJM',
    @Colegio            = N'IE JAVIER HERAUD',
    @Grado              = N'1 ERO',
    @TelPersonal        = N'959168784',
    @TelApoderado       = N'959168784',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/ff42b9c4-11d9-4917-9c20-4745cb21d92c_perfil.jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 78164067: ' + @M; ELSE PRINT 'ERROR DNI 78164067: ' + @M;
GO

-- [311/318] ANAHI KEYLA LEON CUPE (DNI 78265031)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'78265031',
    @Contra             = N'78265031',
    @Nombre             = N'ANAHI KEYLA',
    @Apellido           = N'LEON CUPE',
    @Dni                = N'78265031',
    @Email              = N'78265031@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'15092013',
    @Direccion          = N'VILLA EL SALVADOR',
    @Distrito           = N'VILLA EL SALVADOR',
    @Colegio            = N'IEP AMALIO LEON',
    @Grado              = N'1RO',
    @TelPersonal        = NULL,
    @TelApoderado       = N'933431101',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/1d37ec16-76b0-4f4a-93d8-d10f6cb87571_WhatsApp Image 2026-01-21 at 13.19.29.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 78265031: ' + @M; ELSE PRINT 'ERROR DNI 78265031: ' + @M;
GO

-- [312/318] LUANA GUADALUPE TORRES SUSANIBAR (DNI 78294848)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'78294848',
    @Contra             = N'78294848',
    @Nombre             = N'LUANA GUADALUPE',
    @Apellido           = N'TORRES SUSANIBAR',
    @Dni                = N'78294848',
    @Email              = N'78294848@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'04102013',
    @Direccion          = N'CALLE LOS PINOS MZ. Z LT. 17 UMAMARCA',
    @Distrito           = N'SJM',
    @Colegio            = N'IEP. LEONARD EULER',
    @Grado              = N'1 ERO',
    @TelPersonal        = NULL,
    @TelApoderado       = N'970367580',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/58289524-e659-4265-8f61-18bf9bc3934c_9.jpg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 78294848: ' + @M; ELSE PRINT 'ERROR DNI 78294848: ' + @M;
GO

-- [313/318] MASSIELL ROJAS ESPINOZA (DNI 78930326)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'78930326',
    @Contra             = N'78930326',
    @Nombre             = N'MASSIELL',
    @Apellido           = N'ROJAS ESPINOZA',
    @Dni                = N'78930326',
    @Email              = N'MASSIELL@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'02072008',
    @Direccion          = N'MZ E LOTE 06 - 13 DE OCTUBRE - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = NULL,
    @Grado              = NULL,
    @TelPersonal        = N'970422671',
    @TelApoderado       = N'947116801',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Egresado',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/b6a5806f-ca9f-46f6-8fb7-ac1bcb06086d_WhatsApp Image 2026-05-18 at 1.12.40 PM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 78930326: ' + @M; ELSE PRINT 'ERROR DNI 78930326: ' + @M;
GO

-- [314/318] ADRIANO NEYMAR QUISPE VILLAR (DNI 80961735)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'80961735',
    @Contra             = N'80961735',
    @Nombre             = N'ADRIANO NEYMAR',
    @Apellido           = N'QUISPE VILLAR',
    @Dni                = N'80961735',
    @Email              = N'ADRIANO@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'20102013',
    @Direccion          = N'AA.HH. TORRE DE MELGAR MZ 2 LOTE 6 PASAJE MORAS VMT',
    @Distrito           = N'VILLA MARIA DEL TRIUNFO',
    @Colegio            = N'IE MIGUEL GRAU',
    @Grado              = N'1RO',
    @TelPersonal        = NULL,
    @TelApoderado       = N'989027406',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/83d3be65-edfd-4858-810c-f43bf7305f73_WhatsApp Image 2026-01-28 at 13.25.16.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 80961735: ' + @M; ELSE PRINT 'ERROR DNI 80961735: ' + @M;
GO

-- [315/318] THIAGO ALONSO CABRERA ALANOCA (DNI 81092107)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'81092107',
    @Contra             = N'81092107',
    @Nombre             = N'THIAGO ALONSO',
    @Apellido           = N'CABRERA ALANOCA',
    @Dni                = N'81092107',
    @Email              = N'THIAGO@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'07012013',
    @Direccion          = N'VILLA SOLIDARIDAD MZ E1 LT 03 - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'IE NACIONES UNIDAS',
    @Grado              = N'2DO',
    @TelPersonal        = N'916444189',
    @TelApoderado       = N'916444189',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/c6721c59-9a91-49f9-b39d-5a543b09ec09_WhatsApp Image 2026-03-14 at 11.43.25 AM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 81092107: ' + @M; ELSE PRINT 'ERROR DNI 81092107: ' + @M;
GO

-- [316/318] LEONARDO NIKOLAS GONZALEZ SARMIENTO (DNI 90273203)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'90273203',
    @Contra             = N'90273203',
    @Nombre             = N'LEONARDO NIKOLAS',
    @Apellido           = N'GONZALEZ SARMIENTO',
    @Dni                = N'90273203',
    @Email              = N'LEONARDO@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'18122008',
    @Direccion          = N'CALLE MANUEL SCORZA MZ Ñ LOTE 01 - SJM',
    @Distrito           = N'SAN JUAN DE MIRAFLORES',
    @Colegio            = N'IE REP ALEMANA 7100',
    @Grado              = N'4TO',
    @TelPersonal        = N'977920511',
    @TelApoderado       = N'927933058',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = N'/media/profile/5310a471-d016-4cbd-bb11-5e7bbec4c479_WhatsApp Image 2026-03-14 at 11.54.20 AM.jpeg',
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 90273203: ' + @M; ELSE PRINT 'ERROR DNI 90273203: ' + @M;
GO

-- [317/318] KIMBERLY ADONAY NORIEGA FLORES (DNI 93158686)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'93158686',
    @Contra             = N'93158686',
    @Nombre             = N'KIMBERLY ADONAY',
    @Apellido           = N'NORIEGA FLORES',
    @Dni                = N'93158686',
    @Email              = N'KIMBERLY@GMAIL.COM',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'20112007',
    @Direccion          = N'CALLE LOS NARANJOS MZ E LOTE 12 - CHORRILLOS',
    @Distrito           = N'CHORRILLOS',
    @Colegio            = N'CIRO ALEGRIA BAZAN',
    @Grado              = N'5TO',
    @TelPersonal        = N'972802724',
    @TelApoderado       = N'982238185',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = NULL,
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 93158686: ' + @M; ELSE PRINT 'ERROR DNI 93158686: ' + @M;
GO

-- [318/318] FABIAN ANTUAN AGAPITO ARAUJO (DNI 93922779)
DECLARE @R INT, @M NVARCHAR(200);
EXEC dbo.usp_usuario_insertar
    @Id                 = N'93922779',
    @Contra             = N'93922779',
    @Nombre             = N'FABIAN ANTUAN',
    @Apellido           = N'AGAPITO ARAUJO',
    @Dni                = N'93922779',
    @Email              = N'93922779@import.academia.local',
    @IdTipoUsuario      = N'1',
    @Estado             = N'Activo',
    @FechaNacimiento    = N'26122009',
    @Direccion          = N'AV. BUENOS AIRES MZ 51 LOTE 09 -  CHORRILLOS',
    @Distrito           = N'CHORRILLOS',
    @Colegio            = N'IE MANUEL SCORZA',
    @Grado              = N'5TO',
    @TelPersonal        = N'992473289',
    @TelApoderado       = N'992473289',
    @NombreApoderado    = NULL,
    @Parentesco         = NULL,
    @SituacionAcademica = N'Estudiante',
    @ComoEntero         = NULL,
    @Foto               = NULL,
    @Resultado          = @R OUTPUT,
    @Mensaje            = @M OUTPUT;
IF @R = 1 PRINT 'OK DNI 93922779: ' + @M; ELSE PRINT 'ERROR DNI 93922779: ' + @M;
GO
