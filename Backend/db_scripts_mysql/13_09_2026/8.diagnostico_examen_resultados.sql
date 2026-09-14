-- ============================================================================
-- 8. Diagnostico Resultados (ejecutar en phpMyAdmin, delimitador ;)
-- Sirve para ver SI hay intentos y por que el listado sale vacio.
-- ============================================================================

SELECT 'A) Examenes del modulo' AS paso;
SELECT IDEXAMEN, TITULO, VISIBLE, FECHAINICIO, FECHAFIN
FROM EXAMEN
ORDER BY TITULO;

SELECT 'B) Intentos por estado (0=en curso, 1=finalizado)' AS paso;
SELECT IFNULL(i.ESTADO, -1) AS ESTADO, COUNT(*) AS CANTIDAD
FROM INTENTO_EXAMEN i
GROUP BY IFNULL(i.ESTADO, -1);

SELECT 'C) Ultimos 50 intentos (esto es lo que deberia verse en Resultados)' AS paso;
SELECT
    i.IDINTENTOEXAMEN,
    i.IDEXAMEN,
    e.TITULO AS EXAMEN,
    i.IDUSUARIO,
    UPPER(TRIM(CONCAT(IFNULL(u.APELLIDO, ''), ' ', IFNULL(u.NOMBRE, '')))) AS ESTUDIANTE,
    IFNULL(i.ESTADO, 0) AS ESTADO,
    i.PUNTAJEOBTENIDO,
    i.FECHAINICIO,
    i.FECHAFIN
FROM INTENTO_EXAMEN i
INNER JOIN EXAMEN e ON e.IDEXAMEN = i.IDEXAMEN
LEFT JOIN USUARIO u ON u.IDUSUARIO = i.IDUSUARIO
ORDER BY i.IDINTENTOEXAMEN DESC
LIMIT 50;

SELECT 'D) Intentos huerfanos (examen o usuario inexistente)' AS paso;
SELECT i.IDINTENTOEXAMEN, i.IDEXAMEN, i.IDUSUARIO, i.ESTADO
FROM INTENTO_EXAMEN i
LEFT JOIN EXAMEN e ON e.IDEXAMEN = i.IDEXAMEN
LEFT JOIN USUARIO u ON u.IDUSUARIO = i.IDUSUARIO
WHERE e.IDEXAMEN IS NULL OR u.IDUSUARIO IS NULL;

SELECT 'E) Usuarios no estudiantes (para probar el SP)' AS paso;
SELECT
    IDUSUARIO,
    IDTIPOUSUARIO,
    DNI,
    EMAIL,
    UPPER(TRIM(CONCAT(IFNULL(APELLIDO, ''), ' ', IFNULL(NOMBRE, '')))) AS NOMBRE
FROM USUARIO
WHERE IDTIPOUSUARIO <> '1'
LIMIT 5;

-- Prueba el SP con el primer admin/docente (descomenta si quieres ver el listado del SP)
-- SET @idAdmin = (SELECT IDUSUARIO FROM USUARIO WHERE IDTIPOUSUARIO <> '1' LIMIT 1);
-- CALL usp_examen_resultados_listar(@idAdmin, NULL, NULL, NULL, 1, 50);

SELECT 'F) Si C sale vacio: nadie ha iniciado/rendido el examen todavia.' AS paso;
