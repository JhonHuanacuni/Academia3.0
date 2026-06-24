-- ========================================
-- SCRIPT: Inserción de Datos Iniciales de Módulos
-- Fecha: 2026-05-09
-- Descripción: Módulos base para la academia
-- ========================================

-- 1. Insertar Tipos de Permisos
INSERT INTO TIPO_PERMISO (IDPERMISO, NOMBRE, DESCRIPCION)
VALUES 
    ('PER001', 'read', 'Lectura: Solo visualizar información'),
    ('PER002', 'write', 'Escritura: Crear y editar información'),
    ('PER003', 'delete', 'Eliminación: Eliminar registros'),
    ('PER004', 'admin', 'Administración: Control total del módulo')
GO

-- 2. Insertar Módulos Principales
INSERT INTO MODULO (IDMODULO, NOMBRE, DESCRIPCION, ICONO, ORDEN, ACTIVO)
VALUES 
    ('MOD001', 'Dashboard', 'Panel de control principal', 'faGauge', 1, 1),
    ('MOD002', 'Usuarios', 'Gestión de usuarios y roles', 'faUsers', 2, 1),
    ('MOD003', 'Asistencias', 'Control de asistencias', 'faCalendarCheck', 3, 1),
    ('MOD004', 'Membresías', 'Gestión de membresías', 'faIdCard', 4, 1),
    ('MOD005', 'Biblioteca', 'Gestión de biblioteca', 'faBook', 5, 1),
    ('MOD006', 'Exámenes', 'Gestión de exámenes', 'faFileLines', 6, 1),
    ('MOD007', 'Notas', 'Gestión de calificaciones', 'faFilePen', 7, 1),
    ('MOD008', 'Administración de Módulos', 'Asignar acceso a módulos', 'faCog', 99, 1)
GO

-- 3. Insertar Submódulos (ejemplos para algunos módulos)
INSERT INTO SUBMODULO (IDSUBMODULO, IDMODULO, NOMBRE, DESCRIPCION, ICONO, ORDEN, ACTIVO)
VALUES 
    -- Dashboard
    ('SUB001', 'MOD001', 'Estadísticas', 'Ver estadísticas generales', 'faChartBar', 1, 1),
    ('SUB002', 'MOD001', 'Reportes', 'Generar reportes', 'faFileLines', 2, 1),
    
    -- Usuarios
    ('SUB003', 'MOD002', 'Registrar usuario', 'Crear nuevo usuario', 'faUserPlus', 1, 1),
    ('SUB004', 'MOD002', 'Listado de usuarios', 'Ver todos los usuarios', 'faClipboardList', 2, 1),
    ('SUB005', 'MOD002', 'Editar usuario', 'Modificar datos de usuario', 'faPencil', 3, 1),
    
    -- Asistencias
    ('SUB006', 'MOD003', 'Marcar asistencia', 'Registrar asistencia diaria', 'faCalendarCheck', 1, 1),
    ('SUB007', 'MOD003', 'Ver asistencias', 'Consultar historial', 'faClipboardList', 2, 1),
    ('SUB008', 'MOD003', 'Reportes asistencia', 'Reportes por período', 'faBarChart', 3, 1),
    
    -- Membresías
    ('SUB009', 'MOD004', 'Registrar membresía', 'Crear nueva membresía', 'faUserPlus', 1, 1),
    ('SUB010', 'MOD004', 'Ver membresías', 'Listar membresías activas', 'faClipboardList', 2, 1),
    ('SUB011', 'MOD004', 'Pagos', 'Gestionar pagos', 'faMoneyBill', 3, 1),
    
    -- Exámenes
    ('SUB012', 'MOD006', 'Crear examen', 'Registrar nuevo examen', 'faPlus', 1, 1),
    ('SUB013', 'MOD006', 'Ver exámenes', 'Listar exámenes', 'faClipboardList', 2, 1),
    ('SUB014', 'MOD006', 'Calificar', 'Ingresar calificaciones', 'faPencil', 3, 1),
    
    -- Notas
    ('SUB015', 'MOD007', 'Ver notas', 'Consultar calificaciones', 'faEye', 1, 1),
    ('SUB016', 'MOD007', 'Registrar notas', 'Ingresar notas', 'faPencil', 2, 1),
    
    -- Administración de Módulos
    ('SUB017', 'MOD008', 'Asignar módulos', 'Dar acceso a módulos', 'faKey', 1, 1),
    ('SUB018', 'MOD008', 'Gestionar roles', 'Configurar permisos por rol', 'faShield', 2, 1)
GO

-- 4. Asignar módulos a grupos/roles (Ejemplo: admin tiene acceso a todo)
INSERT INTO GRUPO_MODULO (IDGRUPO_MODULO, IDGRUPO, IDMODULO, PERMISOS, ACTIVO)
VALUES 
    -- Admin: Acceso total a todos los módulos
    ('GRM001', '3', 'MOD001', '["read","write","delete","admin"]', 1),
    ('GRM002', '3', 'MOD002', '["read","write","delete","admin"]', 1),
    ('GRM003', '3', 'MOD003', '["read","write","delete","admin"]', 1),
    ('GRM004', '3', 'MOD004', '["read","write","delete","admin"]', 1),
    ('GRM005', '3', 'MOD005', '["read","write","delete","admin"]', 1),
    ('GRM006', '3', 'MOD006', '["read","write","delete","admin"]', 1),
    ('GRM007', '3', 'MOD007', '["read","write","delete","admin"]', 1),
    ('GRM008', '3', 'MOD008', '["read","write","delete","admin"]', 1),
    
    -- Secretario: Acceso a la mayoría excepto admin de módulos
    ('GRM009', '2', 'MOD001', '["read","write"]', 1),
    ('GRM010', '2', 'MOD002', '["read","write"]', 1),
    ('GRM011', '2', 'MOD003', '["read","write"]', 1),
    ('GRM012', '2', 'MOD004', '["read","write"]', 1),
    ('GRM013', '2', 'MOD005', '["read"]', 1),
    ('GRM014', '2', 'MOD006', '["read"]', 1),
    ('GRM015', '2', 'MOD007', '["read"]', 1),
    
    -- Usuario regular: Solo lectura en algunos módulos
    ('GRM016', '1', 'MOD005', '["read"]', 1),
    ('GRM017', '1', 'MOD006', '["read"]', 1),
    ('GRM018', '1', 'MOD007', '["read"]', 1)
GO

PRINT 'Datos iniciales insertados exitosamente';
GO

-- Verificar datos
SELECT 'Módulos:' AS [Tipo de Dato];
SELECT IDMODULO, NOMBRE FROM MODULO WHERE ACTIVO = 1 ORDER BY ORDEN;

SELECT 'Submódulos:' AS [Tipo de Dato];
SELECT IDSUBMODULO, NOMBRE, IDMODULO FROM SUBMODULO WHERE ACTIVO = 1 ORDER BY IDMODULO, ORDEN;
