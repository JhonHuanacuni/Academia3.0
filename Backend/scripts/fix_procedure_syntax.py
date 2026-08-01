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


def fix_v_offset_session(text: str) -> str:
    """Usa @v_offset (variable de sesión) en lugar de DECLARE v_offset.

    Si split_sql parte mal un procedure, SET v_offset fuera del SP falla con
    "Unknown system variable 'v_offset'"; @v_offset funciona en cualquier contexto.
    """
    text = re.sub(r'^\s*DECLARE v_offset INT DEFAULT 0;\s*\n', '', text, flags=re.M)
    text = text.replace('SET v_offset =', 'SET @v_offset =')
    text = text.replace('OFFSET v_offset', 'OFFSET @v_offset')
    return text


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


def fix_file(content: str) -> str:
    content = fix_v_offset_session(content)
    content = fix_end_semicolon_before_end_dollar(content)
    content = fix_leave_main_before_dml(content)
    content = fix_broken_foto_case(content)
    content = fix_trailing_select_in_proc(content)
    content = fix_missing_trim_paren(content)
    return content


def main():
    changed = 0
    for rel in ORDER:
        path = SCRIPTS / rel.replace('/', '\\')
        if not path.exists():
            continue
        original = path.read_text(encoding='utf-8')
        fixed = fix_v_offset_session(original)
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
