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
    '29_06_2026/modulo_academico.sql',
    '06_07_2026/1.modulo_informes.sql',
    '12_07_2026/13.modulo_mantenedores.sql',
    '11_07_2026/6.asesor_tabla.sql',
    '17_07_2026/5.menu_estudiante_examenes.sql',
    '30_07_2026/6.sub_academico_auditoria.sql',
    '26_07_2026/4.rename_membresia_asesor_a_mensualidad_tutor.sql',
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
    """MySQL no permite expresiones en OFFSET; usar variable v_offset."""
    if 'OFFSET ((p_Pagina - 1) * p_TamanioPagina)' not in text:
        return text

    parts = re.split(r'(CREATE PROCEDURE[\s\S]*?END\$\$)', text)
    fixed_parts = []
    for part in parts:
        if (
            part.startswith('CREATE PROCEDURE')
            and 'OFFSET ((p_Pagina - 1) * p_TamanioPagina)' in part
        ):
            if 'DECLARE v_offset' not in part:
                part = re.sub(
                    r'(main:\s*BEGIN\s*\n)',
                    r'\1    DECLARE v_offset INT DEFAULT 0;\n',
                    part,
                    count=1,
                )
            if 'SET v_offset' not in part:
                part = re.sub(
                    r'(IF p_TamanioPagina < 1 THEN SET p_TamanioPagina = \d+; END IF;\s*\n)',
                    r'\1    SET v_offset = (p_Pagina - 1) * p_TamanioPagina;\n',
                    part,
                    count=1,
                )
            if 'SET v_offset' not in part:
                part = re.sub(
                    r'(main:\s*BEGIN\s*\n(?:\s*DECLARE v_offset[^\n]+\n)?)',
                    r'\1    SET v_offset = (p_Pagina - 1) * p_TamanioPagina;\n',
                    part,
                    count=1,
                )
            part = part.replace(
                'LIMIT p_TamanioPagina OFFSET ((p_Pagina - 1) * p_TamanioPagina)',
                'LIMIT p_TamanioPagina OFFSET v_offset',
            )
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


def fix_file(content: str) -> str:
    content = fix_types_and_functions(content)
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
