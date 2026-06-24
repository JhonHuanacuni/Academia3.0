-- ========================================
-- SCRIPT: Verificar Instalación de Módulos
-- Fecha: 2026-05-09
-- Descripción: Valida que todas las tablas y datos existan correctamente
-- ========================================

-- 1. Verificar existencia de tablas
PRINT '=== VERIFICACIÓN DE TABLAS ==='
GO

IF OBJECT_ID('MODULO', 'U') IS NOT NULL
    PRINT '✓ Tabla MODULO existe'
ELSE
    PRINT '✗ FALTA: Tabla MODULO'
GO

IF OBJECT_ID('SUBMODULO', 'U') IS NOT NULL
    PRINT '✓ Tabla SUBMODULO existe'
ELSE
    PRINT '✗ FALTA: Tabla SUBMODULO'
GO

IF OBJECT_ID('TIPO_PERMISO', 'U') IS NOT NULL
    PRINT '✓ Tabla TIPO_PERMISO existe'
ELSE
    PRINT '✗ FALTA: Tabla TIPO_PERMISO'
GO

IF OBJECT_ID('USUARIO_MODULO', 'U') IS NOT NULL
    PRINT '✓ Tabla USUARIO_MODULO existe'
ELSE
    PRINT '✗ FALTA: Tabla USUARIO_MODULO'
GO

IF OBJECT_ID('GRUPO_MODULO', 'U') IS NOT NULL
    PRINT '✓ Tabla GRUPO_MODULO existe'
ELSE
    PRINT '✗ FALTA: Tabla GRUPO_MODULO'
GO

-- 2. Contar registros
PRINT ''
PRINT '=== CONTEO DE REGISTROS ==='
GO

DECLARE @countModulo INT, @countSubmodulo INT, @countPermiso INT
DECLARE @countUsuarioModulo INT, @countGrupoModulo INT

SELECT @countModulo = COUNT(*) FROM MODULO WHERE ACTIVO = 1
SELECT @countSubmodulo = COUNT(*) FROM SUBMODULO WHERE ACTIVO = 1
SELECT @countPermiso = COUNT(*) FROM TIPO_PERMISO
SELECT @countUsuarioModulo = COUNT(*) FROM USUARIO_MODULO WHERE ACTIVO = 1
SELECT @countGrupoModulo = COUNT(*) FROM GRUPO_MODULO WHERE ACTIVO = 1

PRINT 'Módulos activos: ' + CAST(@countModulo AS VARCHAR(10))
PRINT 'Submódulos activos: ' + CAST(@countSubmodulo AS VARCHAR(10))
PRINT 'Tipos de permiso: ' + CAST(@countPermiso AS VARCHAR(10))
PRINT 'Asignaciones usuario-módulo: ' + CAST(@countUsuarioModulo AS VARCHAR(10))
PRINT 'Asignaciones grupo-módulo: ' + CAST(@countGrupoModulo AS VARCHAR(10))
GO

-- 3. Listar módulos
PRINT ''
PRINT '=== MÓDULOS DISPONIBLES ==='
GO

SELECT 
    IDMODULO,
    NOMBRE,
    DESCRIPCION,
    ORDEN,
    ACTIVO,
    FECHA_CREACION
FROM MODULO
WHERE ACTIVO = 1
ORDER BY ORDEN
GO

-- 4. Listar permisos
PRINT ''
PRINT '=== TIPOS DE PERMISO ==='
GO

SELECT IDPERMISO, NOMBRE, DESCRIPCION
FROM TIPO_PERMISO
ORDER BY IDPERMISO
GO

-- 5. Listar asignaciones por grupo (ejemplo: admin = '3')
PRINT ''
PRINT '=== PERMISOS GRUPO ADMIN (IDGRUPO=3) ==='
GO

SELECT 
    gm.IDGRUPO_MODULO,
    gm.IDGRUPO,
    m.NOMBRE AS MODULO,
    gm.PERMISOS,
    gm.ACTIVO,
    gm.FECHA_ASIGNACION
FROM GRUPO_MODULO gm
JOIN MODULO m ON gm.IDMODULO = m.IDMODULO
WHERE gm.IDGRUPO = '3' AND gm.ACTIVO = 1
ORDER BY m.NOMBRE
GO

-- 6. Ejemplo: Ver asignaciones a un usuario
PRINT ''
PRINT '=== EJEMPLO: MÓDULOS ASIGNADOS A USUARIO ==='
PRINT 'Nota: Reemplaza admin con el IDUSUARIO deseado'
GO

SELECT 
    um.IDUSUARIO_MODULO,
    um.IDUSUARIO,
    m.NOMBRE AS MODULO,
    um.PERMISOS,
    um.ASIGNADO_POR,
    um.FECHA_ASIGNACION,
    um.ACTIVO
FROM USUARIO_MODULO um
JOIN MODULO m ON um.IDMODULO = m.IDMODULO
WHERE um.IDUSUARIO = 'admin' AND um.ACTIVO = 1
ORDER BY m.NOMBRE
GO

-- 7. Verificar integridad (foreign keys)
PRINT ''
PRINT '=== VERIFICACIÓN DE INTEGRIDAD ==='
GO

-- Submódulos con módulos inválidos
SELECT COUNT(*) AS [Submódulos con IDMODULO inválido]
FROM SUBMODULO s
WHERE NOT EXISTS (SELECT 1 FROM MODULO m WHERE m.IDMODULO = s.IDMODULO_id)
GO

-- Usuario_Modulo con módulos inválidos
SELECT COUNT(*) AS [Asignaciones con IDMODULO inválido]
FROM USUARIO_MODULO um
WHERE NOT EXISTS (SELECT 1 FROM MODULO m WHERE m.IDMODULO = um.IDMODULO_id)
GO

-- Grupo_Modulo con módulos inválidos
SELECT COUNT(*) AS [Permisos grupo con IDMODULO inválido]
FROM GRUPO_MODULO gm
WHERE NOT EXISTS (SELECT 1 FROM MODULO m WHERE m.IDMODULO = gm.IDMODULO_id)
GO

PRINT ''
PRINT '=== VERIFICACIÓN COMPLETADA ==='
GO
