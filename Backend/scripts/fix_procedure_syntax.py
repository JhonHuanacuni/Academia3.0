"""
Corrige patrones rotos comunes en procedures MySQL del ORDER.

Uso (desde Backend/):
  python scripts/fix_procedure_syntax.py
"""
from __future__ import annotations

import re
from pathlib import Path

from fix_mysql_scripts import ORDER, SKIP_FIX

BASE = Path(__file__).resolve().parent.parent
SCRIPTS = BASE / 'db_scripts_mysql'


def fix_v_offset_local(text: str) -> str:
    """Paginación en SP: variable local v_offset (DECLARE), no @v_offset de sesión.

    MySQL rechaza OFFSET @v_offset dentro de CREATE PROCEDURE; la local sí funciona
    si el procedure se ejecuta como un solo statement (split_sql + DELIMITER $$).
    """
    text = text.replace('SET @v_offset =', 'SET v_offset =')
    text = text.replace('OFFSET @v_offset', 'OFFSET v_offset')

    def proc_fix(m):
        body = m.group(0)
        if 'SET v_offset' in body and 'DECLARE v_offset' not in body:
            body = re.sub(
                r'(main:\s*BEGIN\s*\n)',
                r'\1    DECLARE v_offset INT DEFAULT 0;\n',
                body,
                count=1,
            )
        return body

    return re.sub(
        r'CREATE PROCEDURE[\s\S]*?END\$\$',
        proc_fix,
        text,
        flags=re.I,
    )


def fix_end_semicolon_before_end_dollar(text: str) -> str:
    text = re.sub(
        r'\nEND;\s*\n(?:\s*SELECT[^\n]+;\s*\n)?END\$\$',
        '\nEND$$',
        text,
        flags=re.I,
    )
    return text


def fix_leave_main_before_dml(text: str) -> str:
    """IF ... LEAVE main; sin END IF antes de INSERT/UPDATE/DELETE."""
    for dml in ('INSERT INTO', 'UPDATE ', 'DELETE FROM'):
        text = re.sub(
            rf'(IF [^\n]+ THEN\s*\n(?:[^\n]*\n)*?\s*LEAVE main;\s*\n)(\s*{dml})',
            r'\1    END IF;\n\n\2',
            text,
            flags=re.I,
        )
    return text


def fix_broken_foto_case(text: str) -> str:
    return re.sub(
        r'(CASE WHEN p_ActualizarFoto = 1 THEN p_Foto ELSE FOTO)\s*\n(\s*WHERE)',
        r'\1 END\n\2',
        text,
        flags=re.I,
    )


def fix_trailing_select_in_proc(text: str) -> str:
    """Quita SELECT sueltos antes de END$$ dentro del procedure."""
    def proc_fix(m):
        body = m.group(0)
        body = re.sub(
            r'\n\s*SELECT p_TotalRegistros AS TotalRegistros\s*\nEND\$\$',
            '\nEND$$',
            body,
        )
        body = re.sub(
            r'\n\s*SELECT p_Resultado AS Resultado, p_Mensaje AS Mensaje\s*\nEND\$\$',
            '\nEND$$',
            body,
        )
        return body

    return re.sub(
        r'CREATE PROCEDURE[\s\S]*?END\$\$',
        proc_fix,
        text,
        flags=re.I,
    )


def fix_missing_trim_paren(text: str) -> str:
    """TRIM(CONCAT(...))) AS -> TRIM(CONCAT(...)))) AS"""
    text = re.sub(
        r"(TRIM\(CONCAT\(IFNULL\([^)]+\),\s*'[^']*',\s*IFNULL\([^)]+\),\s*''\)\))\) AS",
        r"\1)) AS",
        text,
    )
    text = re.sub(
        r"(UPPER\(TRIM\(CONCAT\(IFNULL\([^)]+\),\s*'[^']*',\s*IFNULL\([^)]+\),\s*''\)\))\) AS",
        r"\1)) AS",
        text,
    )
    return text


def fix_if_begin_to_then(text: str) -> str:
    """IF cond BEGIN -> IF cond THEN (T-SQL residual)."""
    return re.sub(
        r'(IF\s+(?:NOT\s+)?EXISTS\s*\([^)]+\))\s*\n\s*BEGIN\b',
        r'\1 THEN',
        text,
        flags=re.I,
    )


def fix_begin_set_to_then(text: str) -> str:
    """BEGIN SET p_Resultado -> THEN SET p_Resultado."""
    return re.sub(
        r'\bBEGIN\s+SET\s+p_',
        'THEN SET p_',
        text,
        flags=re.I,
    )


def fix_len_to_char_length(text: str) -> str:
    return re.sub(r'\bLEN\(', 'CHAR_LENGTH(', text, flags=re.I)


def fix_leave_missing_end_if(text: str) -> str:
    """LEAVE main; sin END IF antes de SELECT/INSERT (bloque IF colgado)."""
    return re.sub(
        r'(LEAVE main;\s*\n)(\s*(?:SELECT|INSERT|UPDATE|DELETE))',
        r'\1    END IF;\n\n\2',
        text,
        flags=re.I,
    )


def fix_file(content: str) -> str:
    content = fix_v_offset_local(content)
    content = fix_end_semicolon_before_end_dollar(content)
    content = fix_leave_main_before_dml(content)
    content = fix_broken_foto_case(content)
    content = fix_trailing_select_in_proc(content)
    content = fix_missing_trim_paren(content)
    content = fix_if_begin_to_then(content)
    content = fix_begin_set_to_then(content)
    content = fix_len_to_char_length(content)
    content = fix_leave_missing_end_if(content)
    return content


def main():
    changed = 0
    for rel in ORDER:
        path = SCRIPTS / rel.replace('/', '\\')
        if not path.exists():
            continue
        original = path.read_text(encoding='utf-8')
        fixed = fix_v_offset_local(original)
        if rel not in SKIP_FIX:
            fixed = fix_file(fixed)
        elif fixed == original:
            continue
        if fixed != original:
            path.write_text(fixed, encoding='utf-8')
            changed += 1
            print(f'  fixed: {rel}')
    print(f'\nOK: {changed} archivo(s).')


if __name__ == '__main__':
    main()
