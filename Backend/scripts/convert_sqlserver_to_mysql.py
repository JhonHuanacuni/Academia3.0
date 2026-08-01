"""
Convierte scripts T-SQL (SQL Server) de db_scripts/ a MySQL 8 en db_scripts_mysql/.

Uso (desde Backend/):
  python scripts/convert_sqlserver_to_mysql.py
  python scripts/convert_sqlserver_to_mysql.py --file 22_06_2026/esquema_completo.sql
"""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent
SRC_DIR = BASE_DIR / 'db_scripts'
DST_DIR = BASE_DIR / 'db_scripts_mysql'

RESERVED_TABLES = {'PLAN', 'ORDER', 'GROUP', 'USER', 'CHECK'}

SKIP_FILES = {
    'ejemplos_uso.sql',
    'modulos_verify.sql',
}

TYPE_MAP = [
    (re.compile(r'\bNVARCHAR\s*\(\s*MAX\s*\)', re.I), 'LONGTEXT'),
    (re.compile(r'\bNVARCHAR\s*\(\s*(\d+)\s*\)', re.I), r'VARCHAR(\1)'),
    (re.compile(r'\bVARCHAR\s*\(\s*MAX\s*\)', re.I), 'LONGTEXT'),
    (re.compile(r'\bSYSNAME\b', re.I), 'VARCHAR(128)'),
    (re.compile(r'\bBIT\b', re.I), 'TINYINT(1)'),
    (re.compile(r'\bDATETIME2\b', re.I), 'DATETIME'),
    (re.compile(r'\bUNIQUEIDENTIFIER\b', re.I), 'CHAR(36)'),
]

PROC_START = re.compile(
    r'CREATE\s+(?:OR\s+ALTER\s+)?PROCEDURE\s+(?:dbo\.)?(?P<name>\w+)\s*',
    re.I,
)
FUNC_START = re.compile(
    r'CREATE\s+(?:OR\s+ALTER\s+)?FUNCTION\s+(?:dbo\.)?(?P<name>\w+)\s*',
    re.I,
)
PARAM_LINE = re.compile(
    r'^\s*@(?P<name>\w+)\s+(?P<type>[\w\(\),\s]+?)(?:\s*=\s*[^,]+)?(?:\s+OUTPUT)?\s*,?\s*$',
    re.I,
)


def convert_types(text: str) -> str:
    for pattern, repl in TYPE_MAP:
        text = pattern.sub(repl, text)
    return text


def strip_server_directives(text: str) -> str:
    lines = []
    for line in text.splitlines():
        s = line.strip().upper()
        if s in {
            'GO',
            'SET NOCOUNT ON;',
            'SET NOCOUNT ON',
            'SET QUOTED_IDENTIFIER ON;',
            'SET QUOTED_IDENTIFIER ON',
            'SET ANSI_NULLS ON;',
            'SET ANSI_NULLS ON',
        }:
            continue
        if s.startswith('SET QUOTED_IDENTIFIER') or s.startswith('SET ANSI_NULLS'):
            continue
        lines.append(line)
    return '\n'.join(lines)


def quote_reserved_identifiers(text: str) -> str:
    for word in RESERVED_TABLES:
        text = re.sub(
            rf'\bDROP\s+TABLE\s+IF\s+EXISTS\s+{word}\b',
            f'DROP TABLE IF EXISTS `{word}`',
            text,
            flags=re.I,
        )
        text = re.sub(
            rf'\bCREATE\s+TABLE\s+{word}\s*\(',
            f'CREATE TABLE `{word}` (',
            text,
            flags=re.I,
        )
        text = re.sub(
            rf'\bREFERENCES\s+{word}\s*\(',
            f'REFERENCES `{word}`(',
            text,
            flags=re.I,
        )
        text = re.sub(
            rf'\bFOREIGN\s+KEY\s*\(\s*[^)]+\)\s+REFERENCES\s+{word}\b',
            lambda m: m.group(0).replace(word, f'`{word}`'),
            text,
            flags=re.I,
        )
    text = re.sub(r'\b\[PLAN\]', '`PLAN`', text, flags=re.I)
    return text


def convert_string_plus(text: str) -> str:
    """Convierte concatenación con + en SET/assignments."""
    return re.sub(
        r"=\s*'([^']*)'\s*\+\s*RIGHT\s*\(",
        r"= CONCAT('\1', RIGHT(",
        text,
        flags=re.I,
    )


def convert_object_id_drops(text: str) -> str:
    text = re.sub(
        r"IF\s+OBJECT_ID\s*\(\s*'(?:dbo\.)?(?P<name>\w+)'\s*,\s*'P'\s*\)\s+IS\s+NOT\s+NULL\s+"
        r"DROP\s+PROCEDURE\s+(?:dbo\.)?\w+\s*;?",
        r'DROP PROCEDURE IF EXISTS \g<name>;',
        text,
        flags=re.I,
    )
    text = re.sub(
        r"IF\s+OBJECT_ID\s*\(\s*'(?:dbo\.)?(?P<name>\w+)'\s*,\s*'FN'\s*\)\s+IS\s+NOT\s+NULL\s+"
        r"DROP\s+FUNCTION\s+(?:dbo\.)?\w+\s*;?",
        r'DROP FUNCTION IF EXISTS \g<name>;',
        text,
        flags=re.I,
    )
    text = re.sub(
        r"IF\s+OBJECT_ID\s*\(\s*'(?P<name>\w+)'\s*,\s*'U'\s*\)\s+IS\s+NULL\s+BEGIN",
        r'-- IF NOT EXISTS table \g<name>',
        text,
        flags=re.I,
    )
    text = re.sub(
        r"IF\s+COL_LENGTH\s*\(\s*'(?P<table>[^']+)'\s*,\s*'(?P<col>[^']+)'\s*\)\s+IS\s+NULL",
        r"-- TODO MySQL: add column if missing on \g<table>.\g<col>",
        text,
        flags=re.I,
    )
    return text


def convert_functions_and_calls(text: str) -> str:
    text = re.sub(r'\bdbo\.fn_fecha_ddmmyyyy\s*\(\s*\)', 'fn_fecha_ddmmyyyy()', text, flags=re.I)
    text = re.sub(r'\bdbo\.', '', text, flags=re.I)
    text = re.sub(r'\bISNULL\s*\(', 'IFNULL(', text, flags=re.I)
    text = re.sub(r'\bGETDATE\s*\(\s*\)', 'NOW()', text, flags=re.I)
    text = re.sub(
        r"CONVERT\s*\(\s*CHAR\s*\(\s*8\s*\)\s*,\s*GETDATE\s*\(\s*\)\s*,\s*108\s*\)",
        "TIME_FORMAT(NOW(), '%H:%i:%s')",
        text,
        flags=re.I,
    )
    text = re.sub(
        r"CONVERT\s*\(\s*CHAR\s*\(\s*8\s*\)\s*,\s*NOW\s*\(\s*\)\s*,\s*108\s*\)",
        "TIME_FORMAT(NOW(), '%H:%i:%s')",
        text,
        flags=re.I,
    )
    text = re.sub(r'\bTRY_CAST\s*\(', 'CAST(', text, flags=re.I)
    text = re.sub(r'\bLTRIM\s*\(\s*RTRIM\s*\(', 'TRIM(', text, flags=re.I)
    text = re.sub(r'\bLTRIM\s*\(\s*TRIM\s*\(', 'TRIM(', text, flags=re.I)
    text = re.sub(r'\bPRINT\s+', "SELECT ", text, flags=re.I)
    text = re.sub(r'\bCAST\s*\(\s*1\s+AS\s+TINYINT\s*\(\s*1\s*\)\s*\)', '1', text, flags=re.I)
    text = re.sub(r'\bCAST\s*\(\s*0\s+AS\s+TINYINT\s*\(\s*1\s*\)\s*\)', '0', text, flags=re.I)
    text = re.sub(r'\bCAST\s*\(\s*1\s+AS\s+BIT\s*\)', '1', text, flags=re.I)
    text = re.sub(r'\bCAST\s*\(\s*0\s+AS\s+BIT\s*\)', '0', text, flags=re.I)
    return text


def convert_string_concat(text: str) -> str:
    def repl_like(m):
        var = m.group(1)
        return f"CONCAT('%', {var}, '%')"

    text = re.sub(r"'%'\s*\+\s*(@\w+)\s*\+\s*'%'", repl_like, text)
    text = re.sub(r"'%'\s*\+\s*(p_\w+)\s*\+\s*'%'", repl_like, text)

    def repl_plus(m):
        parts = [p.strip() for p in m.group(0).split('+')]
        if len(parts) >= 2 and all(
            p.startswith("'") or p.startswith('@') or p.startswith('p_') or p.startswith('IFNULL')
            for p in parts
        ):
            return 'CONCAT(' + ', '.join(parts) + ')'
        return m.group(0)

    text = re.sub(
        r"(?:'[^']*'|@\w+|p_\w+|IFNULL\([^)]+\))\s*(?:\+\s*(?:'[^']*'|@\w+|p_\w+|IFNULL\([^)]+\)))+",
        repl_plus,
        text,
    )
    return text


def convert_pagination(text: str) -> str:
    return re.sub(
        r'OFFSET\s*\(\s*(@\w+|p_\w+)\s*-\s*1\s*\)\s*\*\s*(@\w+|p_\w+)\s+ROWS\s+'
        r'FETCH\s+NEXT\s+(@\w+|p_\w+)\s+ROWS\s+ONLY',
        r'LIMIT \3 OFFSET ((\1 - 1) * \2)',
        text,
        flags=re.I,
    )


def convert_check_constraints(text: str) -> str:
    text = re.sub(
        r'\s+CHECK\s*\([^)]*LIKE\s*\'[^\']+\'\)',
        '',
        text,
        flags=re.I,
    )
    return text


def convert_table_exists_blocks(text: str) -> str:
    """IF OBJECT_ID('T','U') IS NULL BEGIN CREATE TABLE ... END → CREATE TABLE IF NOT EXISTS"""
    text = re.sub(
        r"IF\s+OBJECT_ID\s*\(\s*'(\w+)'\s*,\s*'U'\s*\)\s+IS\s+NULL\s+BEGIN",
        r'-- create if missing \1',
        text,
        flags=re.I,
    )
    text = re.sub(
        r'\bCREATE\s+TABLE\s+(?!IF\s+NOT\s+EXISTS)(\w+)',
        r'CREATE TABLE IF NOT EXISTS \1',
        text,
        flags=re.I,
    )
    text = re.sub(
        r'\bCREATE\s+TABLE\s+IF\s+NOT\s+EXISTS\s+`PLAN`',
        'CREATE TABLE IF NOT EXISTS `PLAN`',
        text,
    )
    text = re.sub(r'\bELSE\s+SELECT\s+[^;]+;', '', text, flags=re.I)
    text = re.sub(r'\bEND\s*$', '', text, flags=re.I | re.M)
    return text


def convert_sp_rename(text: str) -> str:
    m = re.search(
        r"EXEC\s+sp_rename\s+'(?:dbo\.)?(?P<old>\w+)'\s*,\s*'(?P<new>\w+)'",
        text,
        flags=re.I,
    )
    if m:
        return re.sub(
            r"EXEC\s+sp_rename\s+'(?:dbo\.)?\w+'\s*,\s*'\w+'(?:\s*,\s*'COLUMN')?\s*;?",
            f"RENAME TABLE `{m.group('old')}` TO `{m.group('new')}`;",
            text,
            flags=re.I,
        )
    m2 = re.search(
        r"EXEC\s+sp_rename\s+'(?:dbo\.)?(?P<table>\w+)\.(?P<col>[^']+)'\s*,\s*'(?P<newcol>[^']+)'",
        text,
        flags=re.I,
    )
    if m2:
        return re.sub(
            r"EXEC\s+sp_rename\s+'(?:dbo\.)?\w+\.[^']+'\s*,\s*'[^']+'\s*,\s*'COLUMN'\s*;?",
            f"ALTER TABLE `{m2.group('table')}` RENAME COLUMN `{m2.group('col')}` TO `{m2.group('newcol')}`;",
            text,
            flags=re.I,
        )
    return text


def post_process_body(body: str) -> str:
    """Ajustes de sintaxis T-SQL → MySQL en cuerpos de SP."""
    body = re.sub(
        r'SELECT\s+((?:p_|@)\w+)\s*=\s*(.+?)\s*(?=;|\n)',
        r'SELECT \2 INTO \1',
        body,
        flags=re.I,
    )
    body = re.sub(
        r'IF\s+([^;\n]+?)\s+SET\s+([^;]+);',
        r'IF \1 THEN SET \2; END IF;',
        body,
        flags=re.I,
    )
    body = re.sub(
        r'BEGIN\s+SET\s+([^;]+);\s+SET\s+([^;]+);\s+LEAVE\s+main;',
        r'BEGIN SET \1; SET \2; LEAVE main; END',
        body,
        flags=re.I,
    )
    body = re.sub(
        r'BEGIN\s+SET\s+([^;]+);\s+LEAVE\s+main;',
        r'BEGIN SET \1; LEAVE main; END',
        body,
        flags=re.I,
    )
    locals_found = re.findall(r'DECLARE\s+(@\w+)', body, flags=re.I)
    for loc in locals_found:
        vname = 'v_' + loc[1:]
        body = re.sub(rf'DECLARE\s+{re.escape(loc)}\b', f'DECLARE {vname}', body, flags=re.I)
        body = re.sub(rf'{re.escape(loc)}\b', vname, body)
    return body


def split_procedure_blocks(batch: str) -> list[str]:
    """Separa un batch en bloques DDL/DML y bloques CREATE PROCEDURE."""
    parts = re.split(
        r'(?=(?:DROP\s+PROCEDURE\s+IF\s+EXISTS|IF\s+OBJECT_ID.*DROP\s+PROCEDURE|CREATE\s+PROCEDURE))',
        batch,
        flags=re.I,
    )
    return [p.strip() for p in parts if p.strip()]


def parse_procedure_params(header: str) -> tuple[list[str], list[str], str]:
    """Return (in_params, out_params, mysql_signature)."""
    in_params: list[str] = []
    out_params: list[str] = []
    lines = []
    for raw in header.splitlines():
        line = raw.strip().rstrip(',')
        if not line or line.upper() in {'AS', 'BEGIN'}:
            continue
        m = PARAM_LINE.match(line + ('' if line.endswith(',') else ''))
        if not m and line.startswith('@'):
            m = re.match(
                r'@(?P<name>\w+)\s+(?P<type>[\w\(\),\s]+?)(?:\s*=\s*.+)?(?:\s+OUTPUT)?',
                line,
                re.I,
            )
        if not m:
            continue
        name = m.group('name')
        typ = convert_types(m.group('type').strip())
        is_out = 'OUTPUT' in line.upper()
        pname = f'p_{name}'
        if is_out:
            out_params.append(name)
            in_params.append(f'OUT {pname} {typ}')
        else:
            in_params.append(f'IN {pname} {typ}')
        lines.append((name, pname, is_out))
    sig = ',\n    '.join(in_params)
    return [x[1] for x in lines if not x[2]], [x[1] for x in lines if x[2]], sig


def convert_procedure_block(block: str) -> str:
    m = PROC_START.search(block)
    if not m:
        return block

    name = m.group('name')
    rest = block[m.end():]
    as_idx = re.search(r'\bAS\b', rest, re.I)
    if not as_idx:
        return block
    header = rest[: as_idx.start()]
    body = rest[as_idx.end():]
    body = re.sub(r'\s*END\s*;\s*$', '', body.strip(), flags=re.I)
    body = re.sub(r'^\s*BEGIN\s*', '', body, flags=re.I)
    _in_names, out_names, sig = parse_procedure_params(header)

    for orig in re.findall(r'@(\w+)', header):
        body = re.sub(rf'@{orig}\b', f'p_{orig}', body)

    body = post_process_body(body)
    body = re.sub(r'\bRETURN\s*;', 'LEAVE main;', body, flags=re.I)
    body = re.sub(r'\bRETURN\b', 'LEAVE main', body, flags=re.I)

    if out_names:
        selects = ', '.join(f'{p} AS {p[2:]}' for p in out_names)
        if not re.search(r'SELECT\s+.*\bResultado\b', body, re.I):
            body = body.rstrip() + f'\n    SELECT {selects}'

    sig_part = f'(\n    {sig}\n)' if sig else '()'
    drop = f'DROP PROCEDURE IF EXISTS {name};\n\n'
    proc = (
        f'{drop}DELIMITER $$\n\n'
        f'CREATE PROCEDURE {name}{sig_part}\n'
        f'main: BEGIN\n{body.strip()}\nEND$$\n\nDELIMITER ;'
    )
    return proc


def convert_function_block(block: str) -> str:
    m = FUNC_START.search(block)
    if not m:
        return block

    name = m.group('name')
    block = re.sub(
        rf"CREATE\s+FUNCTION\s+(?:dbo\.)?{name}\s*\(\s*\)",
        f'CREATE FUNCTION {name}()',
        block,
        flags=re.I,
    )
    block = re.sub(r'\bRETURNS\s+CHAR\s*\(\s*8\s*\)', 'RETURNS CHAR(8)', block, flags=re.I)
    block = re.sub(
        r'\bRETURN\s*\(\s*([\s\S]+?)\s*\)\s*;',
        r'RETURN \1;',
        block,
        flags=re.I,
    )
    block = re.sub(
        rf'CREATE\s+FUNCTION\s+{name}',
        f'DROP FUNCTION IF EXISTS {name};\n\nDELIMITER $$\n\nCREATE FUNCTION {name}',
        block,
        count=1,
        flags=re.I,
    )
    if 'DELIMITER $$' in block and not block.rstrip().endswith('DELIMITER ;'):
        block = re.sub(r'\bEND\s*;', 'END$$', block, count=1, flags=re.I)
        block = block.rstrip() + '\n\nDELIMITER ;\n'
    return block


def split_batches(content: str) -> list[str]:
    parts = re.split(r'^\s*GO\s*$', content, flags=re.I | re.M)
    return [p.strip() for p in parts if p.strip()]


def convert_batch(batch: str) -> str:
    batch = convert_object_id_drops(batch)
    batch = convert_sp_rename(batch)
    batch = convert_types(batch)
    batch = convert_functions_and_calls(batch)
    batch = convert_check_constraints(batch)
    batch = convert_table_exists_blocks(batch)
    batch = convert_string_concat(batch)
    batch = convert_string_plus(batch)
    batch = convert_pagination(batch)
    batch = quote_reserved_identifiers(batch)

    if not PROC_START.search(batch) and not FUNC_START.search(batch):
        return batch.strip()

    chunks = split_procedure_blocks(batch)
    out_parts = []
    for chunk in chunks:
        if PROC_START.search(chunk):
            out_parts.append(convert_procedure_block(chunk))
        elif FUNC_START.search(chunk):
            out_parts.append(convert_function_block(chunk))
        else:
            out_parts.append(chunk.strip())
    return '\n\n'.join(out_parts).strip()


def convert_file_content(content: str, rel_path: str) -> str:
    content = strip_server_directives(content)
    header = (
        f'-- Convertido automáticamente desde db_scripts/{rel_path.replace(chr(92), "/")}\n'
        f'-- MySQL 8 — Academia 3.0\n\n'
        f'USE `AcademiaDB`;\n\n'
    )
    batches = split_batches(content)
    converted = [convert_batch(b) for b in batches]
    body = '\n\n'.join(converted)
    body = re.sub(r'\n{3,}', '\n\n', body)
    return header + body + '\n'


def iter_source_files(single: str | None = None):
    if single:
        yield Path(single)
        return
    for path in sorted(SRC_DIR.rglob('*.sql')):
        if path.name in SKIP_FILES:
            continue
        yield path


def convert_all(single: str | None = None) -> int:
    DST_DIR.mkdir(parents=True, exist_ok=True)
    count = 0
    for src in iter_source_files(single):
        rel = src.relative_to(SRC_DIR)
        dst = DST_DIR / rel
        dst.parent.mkdir(parents=True, exist_ok=True)
        out = convert_file_content(src.read_text(encoding='utf-8'), str(rel))
        dst.write_text(out, encoding='utf-8')
        count += 1
        print(f'  {rel}')
    return count


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--file', help='Ruta relativa dentro de db_scripts/')
    args = parser.parse_args()

    print(f'Origen:  {SRC_DIR}')
    print(f'Destino: {DST_DIR}')
    n = convert_all(args.file)
    print(f'\nOK: {n} archivo(s) convertido(s).')
    print('Revisa manualmente: triggers_auditoria.sql, scripts con sp_executesql, importaciones.')


if __name__ == '__main__':
    main()
