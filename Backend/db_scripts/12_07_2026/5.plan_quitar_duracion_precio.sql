/* ============================================================================
   PLAN: quitar DURACIONDIAS y PRECIO
   Esos valores se registran en MEMBRESIA (fechas + MONTOTOTAL).
   Ejecutar después de 3.usp_plan_crud.sql
   Fecha: 12/07/2026
   ============================================================================ */

IF COL_LENGTH('PLAN', 'DURACIONDIAS') IS NOT NULL
BEGIN
    ALTER TABLE [PLAN] DROP COLUMN DURACIONDIAS;
    PRINT 'Columna PLAN.DURACIONDIAS eliminada.';
END
ELSE
    PRINT 'Columna PLAN.DURACIONDIAS ya no existe.';
GO

IF COL_LENGTH('PLAN', 'PRECIO') IS NOT NULL
BEGIN
    ALTER TABLE [PLAN] DROP COLUMN PRECIO;
    PRINT 'Columna PLAN.PRECIO eliminada.';
END
ELSE
    PRINT 'Columna PLAN.PRECIO ya no existe.';
GO
