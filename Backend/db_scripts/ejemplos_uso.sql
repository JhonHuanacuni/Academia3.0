-- ========================================
-- EJEMPLOS DE USO: Operaciones Comunes
-- Fecha: 2026-05-09
-- Descripción: Queries útiles para administrar módulos
-- ========================================

-- ===========================================
-- 1. CONSULTAS DE LECTURA
-- ===========================================

-- 1.1 Listar todos los módulos activos
SELECT IDMODULO, NOMBRE, DESCRIPCION, ORDEN, ACTIVO
FROM MODULO
WHERE ACTIVO = 1
ORDER BY ORDEN
GO

-- 1.2 Listar submódulos de un módulo específico
SELECT IDSUBMODULO, NOMBRE, DESCRIPCION, ORDEN
FROM SUBMODULO
WHERE IDMODULO_id = 'MOD002'  -- Ejemplo: Usuarios
AND ACTIVO = 1
ORDER BY ORDEN
GO

-- 1.3 Ver todos los módulos asignados a un usuario
SELECT 
    um.IDUSUARIO,
    m.NOMBRE AS MODULO,
    um.PERMISOS,
    um.ASIGNADO_POR,
    um.FECHA_ASIGNACION
FROM USUARIO_MODULO um
JOIN MODULO m ON um.IDMODULO_id = m.IDMODULO
WHERE um.IDUSUARIO = 'admin'  -- Cambiar por usuario deseado
AND um.ACTIVO = 1
ORDER BY m.NOMBRE
GO

-- 1.4 Ver cuántos módulos tiene cada usuario
SELECT 
    um.IDUSUARIO,
    COUNT(um.IDMODULO_id) AS CANTIDAD_MODULOS,
    STRING_AGG(m.NOMBRE, ', ') AS MODULOS
FROM USUARIO_MODULO um
JOIN MODULO m ON um.IDMODULO_id = m.IDMODULO
WHERE um.ACTIVO = 1
GROUP BY um.IDUSUARIO
ORDER BY CANTIDAD_MODULOS DESC
GO

-- 1.5 Ver módulos asignados a un rol/grupo (Ej: admin = '3')
SELECT 
    m.NOMBRE AS MODULO,
    gm.PERMISOS,
    gm.ACTIVO,
    gm.FECHA_ASIGNACION
FROM GRUPO_MODULO gm
JOIN MODULO m ON gm.IDMODULO_id = m.IDMODULO
WHERE gm.IDGRUPO = '3'  -- Admin
AND gm.ACTIVO = 1
ORDER BY m.NOMBRE
GO

-- 1.6 Encontrar módulos SIN asignar a un usuario
SELECT DISTINCT m.IDMODULO, m.NOMBRE, m.DESCRIPCION
FROM MODULO m
WHERE m.ACTIVO = 1
AND m.IDMODULO NOT IN (
    SELECT IDMODULO_id
    FROM USUARIO_MODULO
    WHERE IDUSUARIO = 'juan'  -- Cambiar por usuario
    AND ACTIVO = 1
)
ORDER BY m.ORDEN
GO

-- 1.7 Usuarios que tienen acceso a un módulo específico
SELECT DISTINCT 
    um.IDUSUARIO,
    m.NOMBRE AS MODULO,
    um.PERMISOS
FROM USUARIO_MODULO um
JOIN MODULO m ON um.IDMODULO_id = m.IDMODULO
WHERE m.IDMODULO = 'MOD002'  -- Módulo: Usuarios
AND um.ACTIVO = 1
ORDER BY um.IDUSUARIO
GO

-- ===========================================
-- 2. OPERACIONES DE INSERCIÓN
-- ===========================================

-- 2.1 Asignar un módulo a un usuario
INSERT INTO USUARIO_MODULO (
    IDUSUARIO_MODULO,
    IDUSUARIO,
    IDMODULO_id,
    PERMISOS,
    ASIGNADO_POR,
    ACTIVO
)
VALUES (
    LOWER(REPLACE(NEWID(), '-', '')),  -- Genera ID único
    'juan',                             -- Usuario
    'MOD002',                          -- Módulo ID
    '["read", "write"]',               -- Permisos (JSON)
    'admin',                           -- Quién asignó
    1                                  -- Activo
)
GO

-- 2.2 Asignar un módulo a múltiples usuarios
DECLARE @usuarios TABLE (id NVARCHAR(50))
INSERT INTO @usuarios VALUES ('juan'), ('maria'), ('carlos')

INSERT INTO USUARIO_MODULO (IDUSUARIO_MODULO, IDUSUARIO, IDMODULO_id, PERMISOS, ASIGNADO_POR, ACTIVO)
SELECT 
    LOWER(REPLACE(NEWID(), '-', '')),
    u.id,
    'MOD005',                -- Biblioteca
    '["read"]',
    'admin',
    1
FROM @usuarios u
GO

-- 2.3 Crear un nuevo módulo
INSERT INTO MODULO (IDMODULO, NOMBRE, DESCRIPCION, ICONO, ORDEN, ACTIVO)
VALUES (
    'MOD009',
    'Comunicaciones',
    'Gestión de mensajes y comunicados',
    'faComments',
    9,
    1
)
GO

-- 2.4 Agregar submódulos al nuevo módulo
INSERT INTO SUBMODULO (IDSUBMODULO, IDMODULO_id, NOMBRE, DESCRIPCION, ICONO, ORDEN, ACTIVO)
VALUES 
    ('SUB020', 'MOD009', 'Enviar mensaje', 'faPaperPlane', 1, 1),
    ('SUB021', 'MOD009', 'Bandeja de entrada', 'faInbox', 2, 1),
    ('SUB022', 'MOD009', 'Archivados', 'faArchive', 3, 1)
GO

-- 2.5 Agregar permiso a un nuevo rol (ej: Profesor = '4')
INSERT INTO GRUPO_MODULO (IDGRUPO_MODULO, IDGRUPO, IDMODULO_id, PERMISOS, ACTIVO)
SELECT 
    LOWER(REPLACE(NEWID(), '-', '')),
    '4',  -- ID del rol Profesor
    IDMODULO,
    CASE IDMODULO
        WHEN 'MOD001' THEN '["read"]'           -- Dashboard: Solo lectura
        WHEN 'MOD002' THEN '["read"]'           -- Usuarios: Solo lectura
        WHEN 'MOD003' THEN '["read", "write"]'  -- Asistencias: Lectura y edición
        WHEN 'MOD006' THEN '["read", "write"]'  -- Exámenes: Lectura y edición
        WHEN 'MOD007' THEN '["read", "write"]'  -- Notas: Lectura y edición
        ELSE '["read"]'
    END,
    1
FROM MODULO
WHERE ACTIVO = 1
GO

-- ===========================================
-- 3. OPERACIONES DE ACTUALIZACIÓN
-- ===========================================

-- 3.1 Cambiar permisos de un usuario en un módulo
UPDATE USUARIO_MODULO
SET PERMISOS = '["read", "write", "delete"]',
    FECHA_ACTUALIZACION = CONVERT(NVARCHAR(8), GETDATE(), 112) + ' ' + CONVERT(NVARCHAR(8), GETDATE(), 108)
WHERE IDUSUARIO = 'juan'
AND IDMODULO_id = 'MOD002'
GO

-- 3.2 Desactivar (sin eliminar) un módulo
UPDATE MODULO
SET ACTIVO = 0,
    FECHA_ACTUALIZACION = CONVERT(NVARCHAR(8), GETDATE(), 112) + ' ' + CONVERT(NVARCHAR(8), GETDATE(), 108)
WHERE IDMODULO = 'MOD009'
GO

-- 3.3 Reactivar un módulo
UPDATE MODULO
SET ACTIVO = 1,
    FECHA_ACTUALIZACION = CONVERT(NVARCHAR(8), GETDATE(), 112) + ' ' + CONVERT(NVARCHAR(8), GETDATE(), 108)
WHERE IDMODULO = 'MOD009'
GO

-- 3.4 Cambiar orden de módulos en el menú
UPDATE MODULO SET ORDEN = 10 WHERE IDMODULO = 'MOD008'  -- Mover Admin al final
GO

-- 3.5 Actualizar descripción de módulo
UPDATE MODULO
SET DESCRIPCION = 'Nueva descripción del módulo',
    FECHA_ACTUALIZACION = CONVERT(NVARCHAR(8), GETDATE(), 112) + ' ' + CONVERT(NVARCHAR(8), GETDATE(), 108)
WHERE IDMODULO = 'MOD002'
GO

-- ===========================================
-- 4. OPERACIONES DE ELIMINACIÓN (SOFT DELETE)
-- ===========================================

-- 4.1 Desasignar un módulo a un usuario (soft delete)
UPDATE USUARIO_MODULO
SET ACTIVO = 0
WHERE IDUSUARIO = 'juan'
AND IDMODULO_id = 'MOD002'
GO

-- 4.2 Desasignar todos los módulos de un usuario
UPDATE USUARIO_MODULO
SET ACTIVO = 0
WHERE IDUSUARIO = 'juan'
GO

-- 4.3 Desactivar todos los permisos de un grupo en un módulo
UPDATE GRUPO_MODULO
SET ACTIVO = 0
WHERE IDGRUPO = '1'  -- Usuario regular
AND IDMODULO_id = 'MOD008'  -- Admin
GO

-- 4.4 Desactivar un módulo completamente (no aparece en menú)
-- Nota: Esto desactiva el módulo pero mantiene histórico de asignaciones
UPDATE MODULO SET ACTIVO = 0 WHERE IDMODULO = 'MOD009'
UPDATE SUBMODULO SET ACTIVO = 0 WHERE IDMODULO_id = 'MOD009'
UPDATE USUARIO_MODULO SET ACTIVO = 0 WHERE IDMODULO_id = 'MOD009'
UPDATE GRUPO_MODULO SET ACTIVO = 0 WHERE IDMODULO_id = 'MOD009'
GO

-- ===========================================
-- 5. CONSULTAS AVANZADAS / REPORTING
-- ===========================================

-- 5.1 Matriz de permisos: Usuarios × Módulos
SELECT 
    u.IDUSUARIO,
    (SELECT STRING_AGG(m.NOMBRE, ', ')
     FROM USUARIO_MODULO um
     JOIN MODULO m ON um.IDMODULO_id = m.IDMODULO
     WHERE um.IDUSUARIO = u.IDUSUARIO AND um.ACTIVO = 1) AS MODULOS_ASIGNADOS,
    (SELECT COUNT(*) FROM USUARIO_MODULO WHERE IDUSUARIO = u.IDUSUARIO AND ACTIVO = 1) AS TOTAL
FROM (
    SELECT DISTINCT IDUSUARIO FROM USUARIO_MODULO WHERE ACTIVO = 1
) u
ORDER BY u.IDUSUARIO
GO

-- 5.2 Módulos sin asignar a nadie
SELECT m.IDMODULO, m.NOMBRE
FROM MODULO m
WHERE m.ACTIVO = 1
AND NOT EXISTS (
    SELECT 1 FROM USUARIO_MODULO um 
    WHERE um.IDMODULO_id = m.IDMODULO AND um.ACTIVO = 1
)
ORDER BY m.ORDEN
GO

-- 5.3 Usuarios con acceso a todos los módulos
SELECT 
    u.IDUSUARIO,
    COUNT(DISTINCT um.IDMODULO_id) AS MODULOS_ASIGNADOS,
    (SELECT COUNT(*) FROM MODULO WHERE ACTIVO = 1) AS TOTAL_MODULOS
FROM USUARIO_MODULO u
WHERE u.ACTIVO = 1
GROUP BY u.IDUSUARIO
HAVING COUNT(DISTINCT u.IDMODULO_id) = (SELECT COUNT(*) FROM MODULO WHERE ACTIVO = 1)
ORDER BY u.IDUSUARIO
GO

-- 5.4 Historial de cambios: Cuándo se asignó cada módulo
SELECT 
    um.IDUSUARIO,
    m.NOMBRE AS MODULO,
    um.PERMISOS,
    um.ASIGNADO_POR,
    um.FECHA_ASIGNACION,
    um.FECHA_ACTUALIZACION,
    CASE WHEN um.ACTIVO = 0 THEN 'DESACTIVADO' ELSE 'ACTIVO' END AS ESTADO
FROM USUARIO_MODULO um
JOIN MODULO m ON um.IDMODULO_id = m.IDMODULO
ORDER BY um.FECHA_ASIGNACION DESC
GO

-- 5.5 Permisos por rol: Qué puede hacer cada rol
SELECT 
    gm.IDGRUPO,
    CASE gm.IDGRUPO
        WHEN '1' THEN 'Usuario'
        WHEN '2' THEN 'Secretario'
        WHEN '3' THEN 'Admin'
        WHEN '4' THEN 'Profesor'
        ELSE 'Desconocido'
    END AS ROL,
    m.NOMBRE AS MODULO,
    gm.PERMISOS,
    CASE 
        WHEN gm.PERMISOS LIKE '%admin%' THEN '🔴 Control total'
        WHEN gm.PERMISOS LIKE '%delete%' THEN '🟠 Lectura+Escritura+Eliminación'
        WHEN gm.PERMISOS LIKE '%write%' THEN '🟡 Lectura+Escritura'
        WHEN gm.PERMISOS LIKE '%read%' THEN '🟢 Solo lectura'
        ELSE '⚫ Sin acceso'
    END AS NIVEL_ACCESO
FROM GRUPO_MODULO gm
JOIN MODULO m ON gm.IDMODULO_id = m.IDMODULO
WHERE gm.ACTIVO = 1
ORDER BY gm.IDGRUPO, m.ORDEN
GO

-- 5.6 Auditoría: Quién asignó qué y cuándo
SELECT 
    um.ASIGNADO_POR,
    COUNT(*) AS TOTAL_ASIGNACIONES,
    MIN(um.FECHA_ASIGNACION) AS PRIMERA_ASIGNACION,
    MAX(um.FECHA_ASIGNACION) AS ULTIMA_ASIGNACION,
    STRING_AGG(
        CONCAT(um.IDUSUARIO, ' → ', m.NOMBRE),
        '; '
    ) AS DETALLES
FROM USUARIO_MODULO um
JOIN MODULO m ON um.IDMODULO_id = m.IDMODULO
WHERE um.ASIGNADO_POR IS NOT NULL
GROUP BY um.ASIGNADO_POR
ORDER BY ULTIMA_ASIGNACION DESC
GO

-- ===========================================
-- 6. VALIDACIONES Y DIAGNÓSTICO
-- ===========================================

-- 6.1 Encontrar asignaciones a usuarios/módulos inexistentes
SELECT 'Usuario inexistente' AS TIPO, COUNT(*) AS CANTIDAD
FROM USUARIO_MODULO um
WHERE NOT EXISTS (SELECT 1 FROM USUARIO u WHERE u.IDUSUARIO = um.IDUSUARIO)

UNION ALL

SELECT 'Módulo inexistente', COUNT(*)
FROM USUARIO_MODULO um
WHERE NOT EXISTS (SELECT 1 FROM MODULO m WHERE m.IDMODULO = um.IDMODULO_id)

UNION ALL

SELECT 'Grupo inexistente', COUNT(*)
FROM GRUPO_MODULO gm
WHERE NOT EXISTS (SELECT 1 FROM TIPOUSUARIO t WHERE t.idTipoUsuario = gm.IDGRUPO)
GO

-- 6.2 Duplicados (nunca debería haber por UNIQUE constraint)
SELECT IDUSUARIO, IDMODULO_id, COUNT(*) AS DUPLICADOS
FROM USUARIO_MODULO
GROUP BY IDUSUARIO, IDMODULO_id
HAVING COUNT(*) > 1
GO

-- 6.3 Submódulos sin módulo padre
SELECT IDSUBMODULO, IDMODULO_id
FROM SUBMODULO
WHERE NOT EXISTS (SELECT 1 FROM MODULO m WHERE m.IDMODULO = IDMODULO_id)
GO

-- ===========================================
-- 7. MANTENIMIENTO
-- ===========================================

-- 7.1 Limpiar asignaciones inactivas de más de 90 días
DELETE FROM USUARIO_MODULO
WHERE ACTIVO = 0
AND FECHA_ACTUALIZACION < CONVERT(NVARCHAR(8), DATEADD(DAY, -90, GETDATE()), 112) + ' ' + CONVERT(NVARCHAR(8), DATEADD(DAY, -90, GETDATE()), 108)
GO

-- 7.2 Reindexar tablas para rendimiento
ALTER INDEX ALL ON USUARIO_MODULO REBUILD
ALTER INDEX ALL ON GRUPO_MODULO REBUILD
ALTER INDEX ALL ON MODULO REBUILD
GO

-- 7.3 Estadísticas de tabla
SELECT 
    'MODULO' AS TABLA,
    COUNT(*) AS REGISTROS,
    SUM(CASE WHEN ACTIVO = 1 THEN 1 ELSE 0 END) AS ACTIVOS
FROM MODULO

UNION ALL

SELECT 'USUARIO_MODULO', COUNT(*), SUM(CASE WHEN ACTIVO = 1 THEN 1 ELSE 0 END)
FROM USUARIO_MODULO

UNION ALL

SELECT 'GRUPO_MODULO', COUNT(*), SUM(CASE WHEN ACTIVO = 1 THEN 1 ELSE 0 END)
FROM GRUPO_MODULO
GO

-- ===========================================
-- NOTAS IMPORTANTES
-- ===========================================
/*

1. SIEMPRE USAR SOFT DELETE (ACTIVO = 0)
   - Preserva historial y auditoría
   - Evita errores de referencia
   - Permite recuperar datos si es necesario

2. PERMISOS EN JSON
   - Siempre es un array: ["read"], ["read","write"], etc.
   - Valores válidos: read, write, delete, admin
   - Se valida en frontend (componente AdminModulos.jsx)

3. ÍNDICES CREADOS AUTOMÁTICAMENTE
   - IDX_USUARIO_MODULO_USUARIO
   - IDX_USUARIO_MODULO_MODULO
   - IDX_GRUPO_MODULO_GRUPO
   - IDX_GRUPO_MODULO_MODULO
   Esto optimiza búsquedas

4. CAMPOS AUDITABLES
   - FECHA_ASIGNACION: Se establece al crear
   - FECHA_ACTUALIZACION: Se actualiza con cada cambio
   - ASIGNADO_POR: Quién hizo el cambio (admin, sistema, etc.)

5. CASCADAS
   - Si eliminas MODULO → automáticamente se desactivan:
     * SUBMODULO
     * USUARIO_MODULO
     * GRUPO_MODULO
   (A través de triggers si implementas después)

*/
