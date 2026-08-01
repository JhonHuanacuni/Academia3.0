"""
Post-procesa db_scripts_mysql/ corrigiendo patrones T-SQL que la conversión automática dejó mal.

Uso (desde Backend/):
  python scripts/fix_mysql_scripts.py
  python scripts/fix_mysql_scripts.py --file 22_06_2026/submodulos_admin.sql
"""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent
SCRIPTS_DIR = BASE_DIR / 'db_scripts_mysql'

# Misma lista que setup_mysql_db.py
ORDER = [
    '00_create_database.sql',
    '22_06_2026/esquema_completo.sql',
    '22_06_2026/modulos_admin.sql',
    '22_06_2026/submodulos_admin.sql',
    '22_06_2026/usp_usuario_crud.sql',
    '22_06_2026/usp_asistencia.sql',
    '29_06_2026/usp_aula_crud.sql',
    '29_06_2026/modulo_academico.sql',
    '06_07_2026/1.modulo_informes.sql',
    '06_07_2026/2.usp_asistencia_informe.sql',
    '06_07_2026/3.alter_usp_asistencia_informe_vence.sql',
    '06_07_2026/10.usp_asistencia_informe_vence_vigente.sql',
    '06_07_2026/4.usuario_columna_foto.sql',
    '06_07_2026/5.usp_usuario_foto.sql',
    '06_07_2026/6.membresia_alter_catalogos.sql',
    '06_07_2026/7.usp_membresia_crud.sql',
    '06_07_2026/8.usp_membresia_listar_activos.sql',
    '06_07_2026/9.usp_membresia_eliminar_roles.sql',
    '08_07_2026/1.usp_asistencia_informe_filtro_plan.sql',
    '08_07_2026/2.usp_asistencia_informe_filtro_estado.sql',
    '08_07_2026/3.usp_asistencia_informe_faltas_desde_membresia.sql',
    '11_07_2026/1.usuario_columnas_apoderado.sql',
    '11_07_2026/2.usp_usuario_apoderado.sql',
    '11_07_2026/3.remove_sub006_ver_membresias.sql',
    '11_07_2026/4.membresia_columna_comoentero.sql',
    '11_07_2026/5.usp_membresia_comoentero.sql',
    '11_07_2026/6.asesor_tabla.sql',
    '11_07_2026/7.usp_membresia_asesor.sql',
    '12_07_2026/1.usp_asesor_crud.sql',
    '12_07_2026/2.sub012_mantenedor_asesores.sql',
    '12_07_2026/3.usp_plan_crud.sql',
    '12_07_2026/4.sub013_mantenedor_planes.sql',
    '12_07_2026/5.plan_quitar_duracion_precio.sql',
    '12_07_2026/6.usp_membresia_estado_registro.sql',
    '12_07_2026/7.usp_usuario_listar_orden_tipo.sql',
    '12_07_2026/8.usp_pago_crud.sql',
    '12_07_2026/9.usp_pago_membresias_prefills.sql',
    '12_07_2026/10.comoentero_a_usuario.sql',
    '12_07_2026/11.usp_pago_obtener_actualizar_eliminar.sql',
    '12_07_2026/12.sub_academico_biblioteca_examenes_horario_clases.sql',
    '12_07_2026/13.modulo_mantenedores.sql',
    '14_07_2026/1.libro_fechassubida_libro_aula.sql',
    '14_07_2026/2.usp_libro_crud.sql',
    '14_07_2026/3.horario_tabla.sql',
    '14_07_2026/4.usp_horario_crud.sql',
    '16_07_2026/1.concepto_pago_extra_tabla.sql',
    '16_07_2026/2.usp_concepto_crud.sql',
    '16_07_2026/3.pago_extraordinario_tabla.sql',
    '16_07_2026/4.usp_pago_extraordinario_crud.sql',
    '16_07_2026/5.sub_pagos_extraordinarios_conceptos.sql',
    '16_07_2026/6.usp_concepto_insertar_auto.sql',
    '16_07_2026/7.concepto_fechas_vigencia.sql',
    '16_07_2026/8.pagoextra_sin_fechas_form.sql',
    '16_07_2026/9.pagoextra_deuda_conceptos_estudiante.sql',
    '16_07_2026/10.usp_membresia_listar_deuda.sql',
    '16_07_2026/11.plan_costo_mensual.sql',
    '16_07_2026/12.pago_membresias_costo_mensual.sql',
    '16_07_2026/13.categoria_materia_tablas.sql',
    '16_07_2026/14.usp_categoria_crud.sql',
    '16_07_2026/15.usp_materia_crud.sql',
    '16_07_2026/16.sub_categorias_materias.sql',
    '16_07_2026/17.materia_categoria_auto_seed.sql',
    '17_07_2026/1.examen_tablas_plantilla.sql',
    '17_07_2026/2.usp_examen_crud.sql',
    '17_07_2026/3.usp_examen_pregunta_img_alts.sql',
    '17_07_2026/4.usp_examen_estudiante.sql',
    '17_07_2026/5.menu_estudiante_examenes.sql',
    '26_07_2026/1.plan_dias_asistencia.sql',
    '26_07_2026/2.plan_catalogo_academia_vita.sql',
    '26_07_2026/3.aula_catalogo_academia_vita.sql',
    '26_07_2026/4.rename_membresia_asesor_a_mensualidad_tutor.sql',
    '26_07_2026/20.usp_asistencia_informe.sql',
    '26_07_2026/5.menu_mensualidad_tutor.sql',
    '26_07_2026/6.plan_turno.sql',
    '26_07_2026/7.plan_nombres_sin_turno.sql',
    '26_07_2026/8.asesor_registro_mensualidad.sql',
    '26_07_2026/9.menu_tutores_asesores.sql',
    '26_07_2026/10.tutor_codigo_tut.sql',
    '26_07_2026/11.quitar_mantenedor_asesor.sql',
    '26_07_2026/12.plan_hora_entrada_tardanza.sql',
    '26_07_2026/13.mantenedores_codigo_autogenerado.sql',
    '26_07_2026/14.justificacion.sql',
    '26_07_2026/15.usp_justificacion_actualizar.sql',
    '26_07_2026/16.usuario_estado_retirado.sql',
    '26_07_2026/17.mensualidad_filtro_deuda.sql',
    '26_07_2026/18.usp_usuario_resetear_contra.sql',
    '26_07_2026/19.usp_mensualidad_listar_pagos.sql',
    '29_07_2026/1.notas_importacion_tablas.sql',
    '29_07_2026/2.sub_academico_importar_notas.sql',
    '29_07_2026/3.notas_modulo_academico.sql',
    '29_07_2026/4.fix_sub026_importar_notas.sql',
    '30_07_2026/1.usp_mensualidad_listar_reciente.sql',
    '30_07_2026/2.auditoria_columnas_tablas.sql',
    '30_07_2026/3.auditoria_tabla.sql',
    '30_07_2026/4.usp_auditoria_crud.sql',
    '30_07_2026/5.triggers_auditoria.sql',
    '30_07_2026/6.sub_academico_auditoria.sql',
    '30_07_2026/7.modulos_admin_rol.sql',
    '31_07_2026/3.usp_usuario_eliminar_fisica.sql',
    '31_07_2026/4.usp_usuario_insertar_mensajes.sql',
    '31_07_2026/8.usp_examen_ranking_aula.sql',
]

SKIP_FIX = {
    '22_06_2026/modulos_admin.sql',
    '22_06_2026/esquema_completo.sql',
    '30_07_2026/3.auditoria_tabla.sql',
    '30_07_2026/5.triggers_auditoria.sql',
    '22_06_2026/submodulos_admin.sql',
    '22_06_2026/usp_asistencia.sql',
    '22_06_2026/usp_usuario_crud.sql',
    '29_06_2026/usp_aula_crud.sql',
    '29_06_2026/modulo_academico.sql',
    '06_07_2026/1.modulo_informes.sql',
    '12_07_2026/13.modulo_mantenedores.sql',
    '11_07_2026/6.asesor_tabla.sql',
    '17_07_2026/5.menu_estudiante_examenes.sql',
    '30_07_2026/6.sub_academico_auditoria.sql',
    '26_07_2026/4.rename_membresia_asesor_a_mensualidad_tutor.sql',
    '26_07_2026/20.usp_asistencia_informe.sql',
    '30_07_2026/2.auditoria_columnas_tablas.sql',
    '31_07_2026/3.usp_usuario_eliminar_fisica.sql',
    '06_07_2026/7.usp_membresia_crud.sql',
    '06_07_2026/2.usp_asistencia_informe.sql',
    '06_07_2026/3.alter_usp_asistencia_informe_vence.sql',
    '06_07_2026/10.usp_asistencia_informe_vence_vigente.sql',
    '08_07_2026/1.usp_asistencia_informe_filtro_plan.sql',
    '08_07_2026/2.usp_asistencia_informe_filtro_estado.sql',
    '08_07_2026/3.usp_asistencia_informe_faltas_desde_membresia.sql',
    '14_07_2026/2.usp_libro_crud.sql',
    '14_07_2026/4.usp_horario_crud.sql',
    '30_07_2026/7.modulos_admin_rol.sql',
    '17_07_2026/2.usp_examen_crud.sql',
    '17_07_2026/4.usp_examen_estudiante.sql',
    '31_07_2026/8.usp_examen_ranking_aula.sql',
}


def fix_types_and_functions(text: str) -> str:
    text = re.sub(
        r'CAST\s*\((CASE[\s\S]+?END)\s+AS\s+TINYINT\s*\(\s*1\s*\)\)',
        r'(\1)',
        text,
        flags=re.I,
    )
    text = re.sub(r'CAST\s*\(\s*1\s+AS\s+TINYINT\s*\(\s*1\s*\)\)', '1', text, flags=re.I)
    text = re.sub(r'CAST\s*\(\s*0\s+AS\s+TINYINT\s*\(\s*1\s*\)\)', '0', text, flags=re.I)
    text = re.sub(
        r"CONVERT\s*\(\s*(?:VARCHAR|NVARCHAR|CHAR)\s*\(\s*(?:8|36)\s*\)\s*,\s*NEWID\s*\(\s*\)\s*\)",
        'UUID()',
        text,
        flags=re.I,
    )
    text = re.sub(r'\bNEWID\s*\(\s*\)', 'UUID()', text, flags=re.I)
    text = re.sub(r'\bISNULL\s*\(', 'IFNULL(', text, flags=re.I)
    text = re.sub(r'\bGETDATE\s*\(\s*\)', 'NOW()', text, flags=re.I)
    text = re.sub(r'\bdbo\.fn_fecha_ddmmyyyy\s*\(\s*\)', 'fn_fecha_ddmmyyyy()', text, flags=re.I)
    text = re.sub(r'\bdbo\.', '', text, flags=re.I)
    text = re.sub(
        r"CONVERT\s*\(\s*CHAR\s*\(\s*8\s*\)\s*,\s*CAST\s*\(\s*SYSDATETIMEOFFSET\s*\(\s*\)\s*AT\s+TIME\s+ZONE\s+'[^']+'\s+AS\s+TIME\s*\)\s*,\s*108\s*\)",
        "TIME_FORMAT(CONVERT_TZ(NOW(), '+00:00', '-05:00'), '%H:%i:%s')",
        text,
        flags=re.I,
    )
    text = re.sub(
        r"CONVERT\s*\(\s*VARCHAR\s*\(\s*5\s*\)\s*,\s*([^,]+)\s*,\s*108\s*\)",
        r"TIME_FORMAT(\1, '%H:%i')",
        text,
        flags=re.I,
    )
    text = re.sub(
        r'CAST\s*\(([^)]+)\s+AS\s+VARCHAR\s*\(\s*(\d+)\s*\)\)',
        r'CAST(\1 AS CHAR(\2))',
        text,
        flags=re.I,
    )
    text = re.sub(r"\bN'", "'", text)
    text = re.sub(r'\[PLAN\]', '`PLAN`', text, flags=re.I)
    return text


def fix_string_concat(text: str) -> str:
    """Solo patrones seguros; evita tocar TRIM(x) = '' o comentarios."""
    text = re.sub(r"'%'\s*\+\s*(p_\w+|@\w+)\s*\+\s*'%'", r"CONCAT('%', \1, '%')", text)
    text = re.sub(
        r"'([^']*)'\s*\+\s*REPLACE\s*\(\s*CONVERT\s*\(",
        r"CONCAT('\1', REPLACE(CONVERT(",
        text,
        flags=re.I,
    )
    text = re.sub(
        r"'([^']*)'\s*\+\s*REPLACE\s*\(\s*UUID\s*\(\s*\)",
        r"CONCAT('\1', REPLACE(UUID()",
        text,
        flags=re.I,
    )
    text = re.sub(
        r"IFNULL\(([^,]+),\s*''\)\s*\+\s*CASE WHEN ([^T]+) THEN '\s*'\s*\+\s*(\w+\.\w+) ELSE '' END",
        r"CONCAT(IFNULL(\1, ''), CASE WHEN \2 THEN CONCAT(' ', \3) ELSE '' END)",
        text,
        flags=re.I,
    )
    return text


def fix_broken_trim(text: str) -> str:
    text = re.sub(r'TRIM\((p_\w+)\)\)', r'TRIM(\1)', text)
    text = re.sub(r'UPPER\(TRIM\((p_\w+)\)\)\)', r'UPPER(TRIM(\1))', text)
    text = re.sub(r"NULLIF\(TRIM\((p_\w+)\)\),\s*''\)", r"NULLIF(TRIM(\1), '')", text)
    return text


def fix_broken_comment_concat(text: str) -> str:
    text = re.sub(r'CONCAT\(([A-Z_]+),\s*([A-Z_]+)\)', r'\1 \2', text)
    text = re.sub(r'CONCAT\((CONCAT\([^)]+\)),\s*([^)]+)\)', r'\1 \2', text)
    return text


def fix_broken_usuario_nombre_concat(text: str) -> str:
    return text.replace(
        "CONCAT(IFNULL(u.NOMBRE, ''), CASE) WHEN u.APELLIDO IS NOT NULL THEN CONCAT(' ', u.APELLIDO) ELSE '' END",
        "CONCAT(IFNULL(u.NOMBRE, ''), CASE WHEN u.APELLIDO IS NOT NULL THEN CONCAT(' ', u.APELLIDO) ELSE '' END)",
    )


def fix_constraint_default(text: str) -> str:
    text = re.sub(
        r'NOT NULL CONSTRAINT \w+ DEFAULT\s*\(\s*1\s*\)',
        'NOT NULL DEFAULT 1',
        text,
        flags=re.I,
    )
    text = re.sub(
        r'NOT NULL CONSTRAINT \w+ DEFAULT\s+1',
        'NOT NULL DEFAULT 1',
        text,
        flags=re.I,
    )
    return text


def fix_sys_foreign_keys(text: str) -> str:
    def repl(m):
        fk = m.group(1)
        alter = m.group(2).strip().rstrip(';')
        alter_sql = alter.replace("'", "''")
        return (
            f"SET @fk_{fk} := (\n"
            f"    SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS\n"
            f"    WHERE CONSTRAINT_SCHEMA = DATABASE() AND CONSTRAINT_NAME = '{fk}'\n"
            f");\n"
            f"SET @sql_{fk} := IF(@fk_{fk} = 0, '{alter_sql}', 'SELECT 1');\n"
            f"PREPARE stmt FROM @sql_{fk}; EXECUTE stmt; DEALLOCATE PREPARE stmt;\n"
        )

    text = re.sub(
        r"IF NOT EXISTS\s*\(\s*SELECT 1 FROM sys\.foreign_keys WHERE name = '(\w+)'\s*\)\s*BEGIN\s*"
        r"(ALTER TABLE[\s\S]*?);\s*SELECT[^;]+;\s*",
        repl,
        text,
        flags=re.I,
    )
    return text


def fix_add_column_blocks(text: str) -> str:
    def repl(m):
        table, col, rest = m.group(1), m.group(2), m.group(3).strip().rstrip(';')
        sql = rest.replace("'", "''")
        return (
            f"SET @col_{table}_{col} := (\n"
            f"    SELECT COUNT(*) FROM information_schema.COLUMNS\n"
            f"    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = '{table}' AND COLUMN_NAME = '{col}'\n"
            f");\n"
            f"SET @sql_{table}_{col} := IF(@col_{table}_{col} = 0, '{sql}', 'SELECT 1');\n"
            f"PREPARE stmt FROM @sql_{table}_{col}; EXECUTE stmt; DEALLOCATE PREPARE stmt;\n"
        )

    text = re.sub(
        r"-- TODO MySQL: add column if missing on (\w+)\.(\w+)\s*\n\s*(ALTER TABLE[\s\S]*?);\s*SELECT[^;]+;\s*",
        repl,
        text,
        flags=re.I,
    )
    return text


def fix_if_not_exists_seed_insert(text: str) -> str:
    def repl(m):
        insert = m.group(2).strip().rstrip(';')
        insert = re.sub(r'^INSERT\s+INTO', 'INSERT IGNORE INTO', insert, count=1, flags=re.I)
        return insert + ';\n'

    text = re.sub(
        r"IF NOT EXISTS\s*\(SELECT 1 FROM (\w+)\)\s*BEGIN\s*(INSERT INTO[\s\S]*?);\s*SELECT[^;]+;\s*",
        repl,
        text,
        flags=re.I,
    )
    text = re.sub(
        r"IF NOT EXISTS\s*\(SELECT 1 FROM ASESOR WHERE IDASESOR = 'ASE001'\)\s*BEGIN\s*(INSERT INTO[\s\S]*?);\s*SELECT[^;]+;\s*",
        repl,
        text,
        flags=re.I,
    )
    text = re.sub(r'\bINSERT IGNORE INSERT INTO\b', 'INSERT IGNORE INTO', text, flags=re.I)
    return text


def fix_limit_offset(text: str) -> str:
    """MySQL no permite expresiones en OFFSET; usar @v_offset (variable de sesión)."""
    if 'OFFSET ((p_Pagina - 1) * p_TamanioPagina)' not in text:
        return text

    parts = re.split(r'(CREATE PROCEDURE[\s\S]*?END\$\$)', text)
    fixed_parts = []
    for part in parts:
        if (
            part.startswith('CREATE PROCEDURE')
            and 'OFFSET ((p_Pagina - 1) * p_TamanioPagina)' in part
        ):
            if 'SET @v_offset' not in part and 'SET v_offset' not in part:
                part = re.sub(
                    r'(IF p_TamanioPagina < 1 THEN SET p_TamanioPagina = \d+; END IF;\s*\n)',
                    r'\1    SET @v_offset = (p_Pagina - 1) * p_TamanioPagina;\n',
                    part,
                    count=1,
                )
            if 'SET @v_offset' not in part and 'SET v_offset' not in part:
                part = re.sub(
                    r'(main:\s*BEGIN\s*\n)',
                    r'\1    SET @v_offset = (p_Pagina - 1) * p_TamanioPagina;\n',
                    part,
                    count=1,
                )
            part = part.replace(
                'LIMIT p_TamanioPagina OFFSET ((p_Pagina - 1) * p_TamanioPagina)',
                'LIMIT p_TamanioPagina OFFSET @v_offset',
            )
            part = re.sub(r'^\s*DECLARE v_offset INT DEFAULT 0;\s*\n', '', part, flags=re.M)
            part = part.replace('SET v_offset =', 'SET @v_offset =')
            part = part.replace('OFFSET v_offset', 'OFFSET @v_offset')
        fixed_parts.append(part)
    return ''.join(fixed_parts)


def fix_sys_indexes_block(text: str) -> str:
    return re.sub(
        r"IF NOT EXISTS\s*\(\s*SELECT 1 FROM sys\.indexes[\s\S]*?\)\s*BEGIN\s*"
        r"CREATE UNIQUE INDEX[\s\S]*?WHERE[^;]+;\s*",
        "CREATE UNIQUE INDEX UQ_ASISTENCIA_USUARIO_FECHA ON ASISTENCIA(IDUSUARIO, FECHAREGISTRO);\n",
        text,
        flags=re.I,
    )


def fix_if_not_exists_insert(text: str) -> str:
    text = re.sub(
        r"IF NOT EXISTS\s*\(SELECT 1 FROM (\w+) WHERE[^\)]*\)\s*\n\s*INSERT INTO",
        r'INSERT IGNORE INTO',
        text,
        flags=re.I,
    )
    text = re.sub(
        r"IF NOT EXISTS\s*\(SELECT 1 FROM (\w+) WHERE[^\)]*\)\s+INSERT INTO",
        r'INSERT IGNORE INTO',
        text,
        flags=re.I,
    )
    return text


def fix_procedure_leave_main(text: str) -> str:
    """Cierra IF ... THEN antes de LEAVE main o del siguiente IF hermano."""
    text = re.sub(
        r'(LEAVE main;\s*\n)(\s*IF\s+)',
        r'\1    END IF;\n\n\2',
        text,
    )
    text = re.sub(
        r'(CASE WHEN [^\n]+ THEN 1 ELSE 0)\s*\n\s*\)',
        r'\1 END)',
        text,
    )
    text = re.sub(
        r'(CASE WHEN [^\n]+ THEN 1 ELSE 0)\s*\n\s*WHERE',
        r'\1 END\n    WHERE',
        text,
    )
    text = re.sub(r'\bEND;\s*\n\s*SELECT p_Resultado', 'END IF;\n\n    SELECT p_Resultado', text)
    return text


def fix_procedure_if_begin(text: str) -> str:
    """IF cond BEGIN -> IF cond THEN; END sueltos antes de otro IF/END$$ -> END IF;"""
    lines = text.splitlines()
    out = []
    in_proc = False
    i = 0
    while i < len(lines):
        line = lines[i]
        stripped = line.strip()
        if re.match(r'main:\s*BEGIN', stripped, re.I):
            in_proc = True
        if in_proc and re.match(r'END\s*\$\$', stripped, re.I):
            in_proc = False

        if in_proc:
            m = re.match(r'IF\s+(.+)$', stripped, re.I)
            if m and not re.search(r'\bTHEN\b', stripped, re.I):
                nxt = lines[i + 1].strip() if i + 1 < len(lines) else ''
                if nxt.upper() == 'BEGIN':
                    out.append(re.sub(r'IF\s+(.+)$', r'IF \1 THEN', line, flags=re.I))
                    i += 2
                    continue
            if stripped.upper() == 'BEGIN' and out and re.search(r'\bIF\b.*\bTHEN\b', out[-1], re.I):
                i += 1
                continue
            if stripped.upper() == 'END' and i + 1 < len(lines):
                nxt = lines[i + 1].strip()
                if nxt.upper().startswith('IF ') or nxt.upper().startswith('ELSE') or re.match(r'END\s*\$\$', nxt, re.I):
                    out.append(line.replace('END', 'END IF', 1) if stripped.upper() == 'END' else line)
                    i += 1
                    continue
            if stripped.upper() == 'ELSE':
                out.append('ELSE')
                i += 1
                if i < len(lines) and lines[i].strip().upper() == 'BEGIN':
                    i += 1
                continue

        out.append(line)
        i += 1
    return '\n'.join(out)


def fix_select_assignments(text: str) -> str:
    """SELECT @a = col, @b = col2 FROM -> SELECT col, col2 INTO v_a, v_b FROM (ya parcial en SPs)."""
    def repl(m):
        assigns = m.group(1)
        rest = m.group(2)
        cols, vars_ = [], []
        for part in assigns.split(','):
            part = part.strip()
            am = re.match(r'(@|p_)(\w+)\s*=\s*(.+)', part, re.I)
            if am:
                vars_.append(f'v_{am.group(2)}' if am.group(1) == '@' else f'p_{am.group(2)}')
                cols.append(am.group(3).strip())
        if not cols:
            return m.group(0)
        return f"SELECT {', '.join(cols)} INTO {', '.join(vars_)} {rest}"

    return re.sub(
        r'SELECT\s+((?:@|p_)\w+\s*=[^F][\s\S]*?)\s+(FROM\b[\s\S]*?;)',
        repl,
        text,
        flags=re.I,
    )


def fix_orphan_begin_after_todo(text: str) -> str:
    text = re.sub(
        r'(-- TODO MySQL:[^\n]*\n)BEGIN\s*\n',
        r'\1',
        text,
        flags=re.I,
    )
    return text


def fix_col_length_blocks(text: str) -> str:
    """Convierte bloques TODO COL_LENGTH a ALTER ignorando duplicados."""
    def repl(m):
        table, col = m.group(1), m.group(2)
        return f"-- add column {table}.{col} if missing\n"

    text = re.sub(
        r"-- TODO MySQL: add column if missing on (\w+)\.(\w+)\s*\n"
        r"(?:BEGIN\s*\n)?"
        r"(ALTER TABLE \1 ADD \2[^;]+;[\s\S]*?)(?=\n\n|\nIF |\nINSERT |\nSELECT |\nDROP |\Z)",
        repl,
        text,
        flags=re.I,
    )
    return text


def fix_raiserror_and_return(text: str) -> str:
    text = re.sub(
        r"RAISERROR\s*\(\s*'((?:[^']|'')*)'\s*,\s*16\s*,\s*1\s*\)\s*;\s*\n\s*RETURN\s*;",
        r"SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '\1';",
        text,
        flags=re.I,
    )
    text = re.sub(
        r"RAISERROR\s*\(\s*'((?:[^']|'')*)'\s*,\s*16\s*,\s*1\s*\)\s*;",
        r"SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '\1';",
        text,
        flags=re.I,
    )
    text = re.sub(r'\bRETURN\s*;', 'LEAVE main;', text, flags=re.I)
    return text


def fix_outer_apply(text: str) -> str:
    text = re.sub(r'\bOUTER APPLY\s*\(', 'LEFT JOIN LATERAL (', text, flags=re.I)
    text = re.sub(r'\bSELECT TOP 1\b', 'SELECT', text, flags=re.I)
    text = re.sub(r'\bSELECT TOP (\d+)\b', r'SELECT', text, flags=re.I)

    def lateral_limit(m):
        body = m.group(1).rstrip()
        alias = m.group(2)
        tail = m.group(3)
        if not re.search(r'\bLIMIT\s+\d+\s*$', body, re.I | re.M):
            body += '\n        LIMIT 1'
        if ' ON TRUE' not in m.group(0):
            return f'LEFT JOIN LATERAL ({body}\n    ) {alias} ON TRUE{tail}'
        return m.group(0)

    text = re.sub(
        r'LEFT JOIN LATERAL\s*\(([\s\S]*?)\)\s*(\w+)\s*(?:ON TRUE)?\s*(\n\s*LEFT JOIN|\n\s*INNER JOIN|\n\s*WHERE|\n\s*ORDER)',
        lateral_limit,
        text,
        flags=re.I,
    )
    return text


def fix_begin_try_catch(text: str) -> str:
    text = re.sub(r'\bBEGIN TRY\s*\n', '', text, flags=re.I)
    text = re.sub(r'\bEND TRY\s*\n', '', text, flags=re.I)
    text = re.sub(
        r'\bBEGIN CATCH[\s\S]*?\bEND CATCH\s*\n?',
        '',
        text,
        flags=re.I,
    )
    return text


def fix_exec_calls(text: str) -> str:
    text = re.sub(
        r"\bEXEC(?:UTE)?\s+(?:dbo\.)?usp_(\w+)\s+(?:@|p_)(\w+)\s*=\s*'([^']*)'",
        r"CALL usp_\1('\3')",
        text,
        flags=re.I,
    )
    text = re.sub(
        r"\bEXEC(?:UTE)?\s+(?:dbo\.)?usp_(\w+)\s+(?:@|p_)(\w+)\s*=\s*(\w+)",
        r"CALL usp_\1(\3)",
        text,
        flags=re.I,
    )
    text = re.sub(r'\bEXEC\s+sp_executesql\s+\w+\s*;', '', text, flags=re.I)
    text = re.sub(r'\bsp_executesql\b', 'PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt', text, flags=re.I)
    return text


def fix_object_id_and_col_length(text: str) -> str:
    text = re.sub(
        r"IF\s+OBJECT_ID\s*\(\s*QUOTENAME\s*\(\s*'dbo'\s*\)\s*\+\s*'\.'\s*\+\s*QUOTENAME\s*\(\s*(?:@|p_)(\w+)\s*\)\s*,\s*'U'\s*\)\s+IS\s+NULL",
        r"IF (SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = p_\1) = 0",
        text,
        flags=re.I,
    )
    text = re.sub(
        r"IF\s+OBJECT_ID\s*\(\s*'([^']+)'\s*,\s*'U'\s*\)\s+IS\s+NOT\s+NULL",
        r"IF (SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = '\1') > 0",
        text,
        flags=re.I,
    )
    text = re.sub(
        r"IF\s+OBJECT_ID\s*\(\s*'([^']+)'\s*,\s*'P'\s*\)\s+IS\s+NOT\s+NULL\s*\n\s*DROP PROCEDURE[^;]+;",
        r'DROP PROCEDURE IF EXISTS \1;',
        text,
        flags=re.I,
    )
    text = re.sub(
        r"IF\s+COL_LENGTH\s*\(\s*'([^']+)'\s*,\s*'([^']+)'\s*\)\s+IS\s+NOT\s+NULL",
        r"IF (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = '\1' AND COLUMN_NAME = '\2') > 0",
        text,
        flags=re.I,
    )
    text = re.sub(
        r"IF\s+COL_LENGTH\s*\(\s*'([^']+)'\s*,\s*'([^']+)'\s*\)\s+IS\s+NULL",
        r"IF (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = '\1' AND COLUMN_NAME = '\2') = 0",
        text,
        flags=re.I,
    )
    text = re.sub(
        r"IF\s+COL_LENGTH\s*\(\s*(?:@|p_)(\w+)\s*,\s*'([^']+)'\s*\)\s+IS\s+NULL",
        r"IF (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = p_\1 AND COLUMN_NAME = '\2') = 0",
        text,
        flags=re.I,
    )
    text = re.sub(r'\bQUOTENAME\s*\(\s*([^)]+)\s*\)', r'`\1`', text, flags=re.I)
    text = re.sub(r'\bOBJECT_ID\s*\([^)]+\)', '1', text, flags=re.I)
    return text


def fix_ltrim_rtrim(text: str) -> str:
    text = re.sub(r'\bLTRIM\s*\(\s*RTRIM\s*\(', 'TRIM(', text, flags=re.I)
    return text


def fix_isnull_string_plus(text: str) -> str:
    text = re.sub(
        r"IFNULL\(([^,]+),\s*''\)\s*\+\s*'\s*'\s*\+\s*IFNULL\(([^,]+),\s*''\)",
        r"CONCAT(IFNULL(\1, ''), ' ', IFNULL(\2, ''))",
        text,
        flags=re.I,
    )
    text = re.sub(
        r"IFNULL\(([^,]+),\s*''\)\s*\+\s*CASE WHEN",
        r"CONCAT(IFNULL(\1, ''), CASE WHEN",
        text,
        flags=re.I,
    )
    text = re.sub(
        r"LIKE\s+'%'\s*\+\s*(p_\w+|@\w+)\s*\+\s*'%'",
        r"LIKE CONCAT('%', \1, '%')",
        text,
        flags=re.I,
    )
    return text


def fix_broken_procedure_end(text: str) -> str:
    text = re.sub(
        r'END;\s*\n\s*SELECT\s+[^;]+;\s*\nEND\$\$',
        'END$$',
        text,
        flags=re.I,
    )
    text = re.sub(
        r"SELECT CONCAT\('([^']+)'\)\s*'\.';",
        r"SELECT CONCAT('\1', '.') AS info;",
        text,
    )
    text = re.sub(
        r"SET v_Sql = CONCAT\('([^']+)',\s*([^)]+)\)\s*\+\s*'([^']+)'",
        r"SET v_Sql = CONCAT('\1', \2, '\3'",
        text,
        flags=re.I,
    )
    text = re.sub(r'\bSET NOCOUNT ON\s*;\s*\n', '', text, flags=re.I)
    text = re.sub(r'\bPRINT\s+[^;]+;\s*\n', '', text, flags=re.I)
    text = re.sub(r'\bGO\s*\n', '\n', text, flags=re.I)
    return text


def fix_cross_apply(text: str) -> str:
    return re.sub(r'\bCROSS APPLY\s*\(', 'JOIN LATERAL (', text, flags=re.I)


def fix_sys_objects(text: str) -> str:
    text = re.sub(
        r"IF\s+EXISTS\s*\(\s*SELECT\s+1\s+FROM\s+sys\.(?:tables|objects)[^)]+\)\s*\n\s*DROP TABLE\s+(\w+)",
        r'DROP TABLE IF EXISTS \1',
        text,
        flags=re.I,
    )
    text = re.sub(
        r"IF\s+NOT EXISTS\s*\(\s*SELECT\s+1\s+FROM\s+sys\.tables\s+WHERE\s+name\s*=\s*'(\w+)'[^)]*\)\s*\n\s*CREATE TABLE",
        r'CREATE TABLE IF NOT EXISTS',
        text,
        flags=re.I,
    )
    return text


def fix_broken_concat_plus(text: str) -> str:
    text = re.sub(
        r"CONCAT\((IFNULL\([^)]+\)),\s*'\s*'\)\s*\+\s*(IFNULL\([^)]+\))",
        r"CONCAT(\1, ' ', \2)",
        text,
        flags=re.I,
    )
    text = re.sub(
        r"TRIM\(CONCAT\((IFNULL\([^)]+\),\s*'[^']*',\s*IFNULL\([^)]+\))\)\)\)",
        r"TRIM(CONCAT(\1))",
        text,
        flags=re.I,
    )
    text = re.sub(
        r"UPPER\(TRIM\(CONCAT\((IFNULL\([^)]+\),\s*'[^']*',\s*IFNULL\([^)]+\))\)\)\)\)",
        r"UPPER(TRIM(CONCAT(\1)))",
        text,
        flags=re.I,
    )
    text = re.sub(
        r"CAST\((v_\w+|p_\w+)\s+AS\s+CHAR\(\d+\)\)\)\s*\+\s*'\.'",
        r"CAST(\1 AS CHAR(20)), '.')",
        text,
        flags=re.I,
    )
    text = re.sub(
        r"CAST\((v_\w+|p_\w+)\s+AS\s+CHAR\(\d+\)\)\)\s*\+\s*'\.';",
        r"CAST(\1 AS CHAR(20)), '.');",
        text,
        flags=re.I,
    )
    text = re.sub(
        r"CAST\((v_\w+)\s+AS\s+CHAR\(\d+\)\)\)\s*\+\s*'\.'",
        r"CONCAT(CAST(\1 AS CHAR(20)), '.')",
        text,
        flags=re.I,
    )
    text = re.sub(r"CAST\(([^)]+)\s+AS\s+VARCHAR\s*\(\s*(\d+)\s*\)\)", r"CAST(\1 AS CHAR(\2))", text, flags=re.I)
    text = re.sub(
        r"CONCAT\('PAG', RIGHT\(CONCAT\('000000', CAST\(\(\s*IFNULL\(\(SELECT MAX\(CAST\(SUBSTRING\(IDPAG(?:O)?MEMBRESIA, 4, 10\) AS INT\)\)\)\s*FROM PAG(?:O)?MEMBRESIA WHERE IDPAG(?:O)?MEMBRESIA LIKE 'PAG%'\), 0\) \+ 1\s*\) AS CHAR\(10\)\), 6\)\)",
        r"CONCAT('PAG', LPAD(IFNULL((SELECT MAX(CAST(SUBSTRING(IDPAGOMEMBRESIA, 4, 10) AS UNSIGNED)) FROM PAGOMEMBRESIA WHERE IDPAGOMEMBRESIA LIKE 'PAG%'), 0) + 1, 6, '0'))",
        text,
        flags=re.I,
    )
    text = re.sub(
        r"CONCAT\('PAG', RIGHT\(CONCAT\('000000', CAST\(\(\s*IFNULL\(\(SELECT MAX\(CAST\(SUBSTRING\(IDPAGOMENSUALIDAD, 4, 10\) AS INT\)\)\)\s*FROM PAGOMENSUALIDAD WHERE IDPAGOMENSUALIDAD LIKE 'PAG%'\), 0\) \+ 1\s*\) AS CHAR\(10\)\), 6\)\)",
        r"CONCAT('PAG', LPAD(IFNULL((SELECT MAX(CAST(SUBSTRING(IDPAGOMENSUALIDAD, 4, 10) AS UNSIGNED)) FROM PAGOMENSUALIDAD WHERE IDPAGOMENSUALIDAD LIKE 'PAG%'), 0) + 1, 6, '0'))",
        text,
        flags=re.I,
    )
    return text


def fix_if_begin_set_oneline(text: str) -> str:
    """IF cond\\n    BEGIN SET ... LEAVE main; -> IF cond THEN SET ... LEAVE main; END IF;"""
    text = re.sub(
        r"IF ([^\n]+?)\n\s+BEGIN ((?:SET [^;]+;\s*)+LEAVE main;\s*)\n\s+END IF;",
        lambda m: f"IF {m.group(1).strip()} THEN\n        {m.group(2)}    END IF;",
        text,
        flags=re.M,
    )
    text = re.sub(
        r"IF ([^\n]+?)\n\s+BEGIN (SET [^;]+; LEAVE main;\s*)\n(?!\s*END IF;)",
        lambda m: f"IF {m.group(1).strip()} THEN\n        {m.group(2)}    END IF;\n",
        text,
        flags=re.M,
    )
    text = re.sub(
        r"IF ([^\n]+?)\n\s+BEGIN (SET [^;]+; SET [^;]+; LEAVE main;\s*)\n(?!\s*END IF;)",
        lambda m: f"IF {m.group(1).strip()} THEN\n        {m.group(2)}    END IF;\n",
        text,
        flags=re.M,
    )
    text = re.sub(
        r"IF ([^\n]+?)\n\s+BEGIN (SET [^;]+; SET [^;]+; SET [^;]+; LEAVE main;\s*)\n(?!\s*END IF;)",
        lambda m: f"IF {m.group(1).strip()} THEN\n        {m.group(2)}    END IF;\n",
        text,
        flags=re.M,
    )
    return text


def fix_declare_inside_if(text: str) -> str:
    """Mueve DECLARE sueltos dentro de IF al inicio del bloque main (heurística)."""
    def proc_repl(m):
        body = m.group(2)
        declares = re.findall(
            r"(?m)^\s*DECLARE (v_\w+ [^;]+;)",
            body,
        )
        if not declares:
            return m.group(0)
        seen = set()
        decl_lines = []
        for d in declares:
            if d not in seen:
                seen.add(d)
                decl_lines.append(f"    DECLARE {d}")
        for d in seen:
            body = re.sub(rf"(?m)^\s*DECLARE {re.escape(d)}\s*\n?", "", body)
        insert = "\n".join(decl_lines) + "\n"
        body = re.sub(r"(main:\s*BEGIN\s*\n)", r"\1" + insert, body, count=1)
        return m.group(1) + body + m.group(3)

    return re.sub(
        r"(CREATE PROCEDURE[\s\S]*?main:\s*BEGIN\s*\n)([\s\S]*?)(END\$\$)",
        proc_repl,
        text,
        flags=re.I,
    )


def fix_mem_id_generation(text: str) -> str:
    text = re.sub(
        r"SET p_Id = CONCAT\('MEM', RIGHT\(CONCAT\('000000', CAST\(v_Next AS CHAR\(10\)\)\), 6\)\);",
        "SET p_Id = CONCAT('MEM', LPAD(v_Next, 6, '0'));",
        text,
    )
    text = re.sub(
        r"DECLARE v_Next INT = IFNULL\(\(\s*SELECT MAX\(CAST\(SUBSTRING\(IDMEMBRESIA, 4, 10\) AS INT\)\)\s*FROM MEMBRESIA WHERE IDMEMBRESIA LIKE 'MEM%'\s*\), 0\) \+ 1;",
        "SET v_Next = IFNULL((SELECT MAX(CAST(SUBSTRING(IDMEMBRESIA, 4, 10) AS UNSIGNED)) FROM MEMBRESIA WHERE IDMEMBRESIA LIKE 'MEM%'), 0) + 1;",
        text,
        flags=re.I,
    )
    return text


def fix_pag_id_block(text: str) -> str:
    text = re.sub(
        r"DECLARE v_IdPago VARCHAR\(50\) = CONCAT\('PAG', RIGHT\(CONCAT\('000000', CAST\(\(\s*"
        r"IFNULL\(\(SELECT MAX\(CAST\(SUBSTRING\(IDPAGOMEMBRESIA, 4, 10\) AS INT\)\)\)\s*"
        r"FROM PAGOMEMBRESIA WHERE IDPAGOMEMBRESIA LIKE 'PAG%'\), 0\) \+ 1\s*"
        r"\) AS (?:VARCHAR|CHAR)\(10\)\), 6\)\);",
        "SET v_IdPago = CONCAT('PAG', LPAD(IFNULL((SELECT MAX(CAST(SUBSTRING(IDPAGOMEMBRESIA, 4, 10) AS UNSIGNED)) "
        "FROM PAGOMEMBRESIA WHERE IDPAGOMEMBRESIA LIKE 'PAG%'), 0) + 1, 6, '0'));",
        text,
        flags=re.I | re.S,
    )
    text = re.sub(
        r"DECLARE v_IdPago VARCHAR\(50\) = CONCAT\('PAG', RIGHT\(CONCAT\('000000', CAST\(\(\s*"
        r"IFNULL\(\(SELECT MAX\(CAST\(SUBSTRING\(IDPAGOMENSUALIDAD, 4, 10\) AS INT\)\)\)\s*"
        r"FROM PAGOMENSUALIDAD WHERE IDPAGOMENSUALIDAD LIKE 'PAG%'\), 0\) \+ 1\s*"
        r"\) AS (?:VARCHAR|CHAR)\(10\)\), 6\)\);",
        "SET v_IdPago = CONCAT('PAG', LPAD(IFNULL((SELECT MAX(CAST(SUBSTRING(IDPAGOMENSUALIDAD, 4, 10) AS UNSIGNED)) "
        "FROM PAGOMENSUALIDAD WHERE IDPAGOMENSUALIDAD LIKE 'PAG%'), 0) + 1, 6, '0'));",
        text,
        flags=re.I | re.S,
    )
    return text


def fix_file(content: str) -> str:
    content = fix_types_and_functions(content)
    content = fix_raiserror_and_return(content)
    content = fix_outer_apply(content)
    content = fix_cross_apply(content)
    content = fix_begin_try_catch(content)
    content = fix_object_id_and_col_length(content)
    content = fix_exec_calls(content)
    content = fix_ltrim_rtrim(content)
    content = fix_isnull_string_plus(content)
    content = fix_broken_concat_plus(content)
    content = fix_if_begin_set_oneline(content)
    content = fix_declare_inside_if(content)
    content = fix_mem_id_generation(content)
    content = fix_pag_id_block(content)
    content = fix_broken_procedure_end(content)
    content = fix_sys_objects(content)
    content = fix_broken_trim(content)
    content = fix_broken_comment_concat(content)
    content = fix_broken_usuario_nombre_concat(content)
    content = fix_string_concat(content)
    content = fix_constraint_default(content)
    content = fix_limit_offset(content)
    content = fix_sys_indexes_block(content)
    content = fix_sys_foreign_keys(content)
    content = fix_add_column_blocks(content)
    content = fix_if_not_exists_insert(content)
    content = fix_if_not_exists_seed_insert(content)
    content = fix_orphan_begin_after_todo(content)
    content = fix_procedure_leave_main(content)
    content = fix_procedure_if_begin(content)
    content = re.sub(r'\n{3,}', '\n\n', content)
    return content


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--file', help='Ruta relativa dentro de db_scripts_mysql/')
    parser.add_argument('--all', action='store_true', help='Procesar todos los .sql, no solo ORDER')
    args = parser.parse_args()

    if args.file:
        targets = [args.file.replace('\\', '/')]
    elif args.all:
        targets = [str(p.relative_to(SCRIPTS_DIR)).replace('\\', '/') for p in SCRIPTS_DIR.rglob('*.sql')]
    else:
        targets = ORDER

    changed = 0
    for rel in targets:
        if rel in SKIP_FIX:
            continue
        path = SCRIPTS_DIR / rel.replace('/', '\\' if '\\' in rel else '/')
        if not path.exists():
            print(f'  SKIP (no existe): {rel}', file=sys.stderr)
            continue
        original = path.read_text(encoding='utf-8')
        fixed = fix_file(original)
        if fixed != original:
            path.write_text(fixed, encoding='utf-8')
            changed += 1
            print(f'  fixed: {rel}')
    print(f'\nOK: {changed} archivo(s) actualizado(s).')


if __name__ == '__main__':
    main()
