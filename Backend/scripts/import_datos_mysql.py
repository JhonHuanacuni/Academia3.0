"""
Importa usuarios, mensualidades y pagos desde db_scripts_mysql/31_07_2026/
Los .sql originales usan sintaxis T-SQL (EXEC @Param=...); este script llama
los procedimientos MySQL vía PyMySQL.

Uso (desde Backend/ con venv y .env configurado):
  venv/bin/python scripts/import_datos_mysql.py
  venv/bin/python scripts/import_datos_mysql.py --dry-run
  venv/bin/python scripts/import_datos_mysql.py --only usuarios
  venv/bin/python scripts/import_datos_mysql.py --from mensualidades
"""
from __future__ import annotations

import argparse
import os
import re
import sys
from pathlib import Path

import pymysql
from dotenv import load_dotenv

from setup_mysql_db import SCRIPTS_DIR, _connect

IMPORT_DIR = SCRIPTS_DIR / '31_07_2026'

IMPORT_ORDER = [
    ('usuarios', '1.importar_estudiantes.sql'),
    ('usuarios', '2.importar_estudiantes_corregir_email.sql'),
    ('usuarios', '5.importar_usuarios_otros_roles.sql'),
    ('mensualidades', '6.importar_mensualidades_vigentes.sql'),
    ('mensualidades', '6.importar_mensualidades_corregir.sql'),
    ('pagos', '7.importar_pagos_mensualidades.sql'),
]

USER_PARAM_ORDER = [
    'Id', 'Contra', 'Nombre', 'Apellido', 'Dni', 'Email', 'IdTipoUsuario', 'Estado',
    'FechaNacimiento', 'Direccion', 'Distrito', 'Colegio', 'Grado',
    'TelPersonal', 'TelApoderado', 'NombreApoderado', 'Parentesco',
    'SituacionAcademica', 'ComoEntero', 'Foto',
]

MENS_PARAM_ORDER = [
    'Id', 'IdUsuario', 'IdPlan', 'EstadoMiembro', 'FechaInicio', 'FechaFin',
    'MontoTotal', 'PagoInicial', 'IdMetodoPago', 'IdAula', 'IdTutor',
    'Observaciones', 'FechaCancelacion', 'RegistradoPor',
]

EXEC_BLOCK_RE = re.compile(
    r'EXEC\s+(?:dbo\.)?(usp_usuario_insertar|usp_mensualidad_insertar)\s+(.*?)(?=;\s*(?:IF\b|DECLARE\b|--|\Z))',
    re.DOTALL | re.IGNORECASE,
)
PARAM_RE = re.compile(
    r'@(\w+)\s*=\s*(N?(?:\'(?:\'\'|[^\'])*\'|NULL|\d+(?:\.\d+)?))',
    re.IGNORECASE,
)
IF_NOT_EXISTS_MENS_RE = re.compile(
    r"IF NOT EXISTS \(SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'([^']+)'\)",
    re.IGNORECASE,
)
IF_NOT_EXISTS_PAGO_RE = re.compile(
    r"IF NOT EXISTS \(SELECT 1 FROM PAGOMENSUALIDAD WHERE IDPAGOMENSUALIDAD = N'([^']+)'\)",
    re.IGNORECASE,
)
IF_NOT_EXISTS_MENS_INSERT_RE = re.compile(
    r"IF NOT EXISTS \(SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = N'([^']+)'\)\s*BEGIN\s*(INSERT INTO MENSUALIDAD.*?FROM\s+\[?PLAN\]?\s+p WHERE.*?;)",
    re.DOTALL | re.IGNORECASE,
)
IF_NOT_EXISTS_USER_RE = re.compile(
    r"IF NOT EXISTS \(SELECT 1 FROM USUARIO WHERE IDUSUARIO = N'([^']+)'\)",
    re.IGNORECASE,
)
INSERT_PAGO_RE = re.compile(
    r"INSERT INTO PAGOMENSUALIDAD\s*\([^)]+\)\s*VALUES\s*\([^;]+\);",
    re.DOTALL | re.IGNORECASE,
)


def _tsql_to_mysql_literal(raw: str) -> str:
    s = raw.strip()
    if s.upper() == 'NULL':
        return 'NULL'
    if s.startswith('N') and len(s) > 1:
        s = s[1:]
    return s


def _parse_params(block: str) -> dict[str, str]:
    return {m.group(1): m.group(2) for m in PARAM_RE.finditer(block)}


def _param_python_value(raw: str | None):
    if raw is None:
        return None
    lit = _tsql_to_mysql_literal(raw)
    if lit.upper() == 'NULL':
        return None
    if lit.startswith("'") and lit.endswith("'"):
        return lit[1:-1].replace("''", "'")
    if re.match(r'^-?\d+(?:\.\d+)?$', lit):
        return float(lit) if '.' in lit else int(lit)
    return lit


def _fetch_out(cursor) -> tuple[int, str]:
    while cursor.nextset():
        pass
    cursor.execute('SELECT @r AS r, @m AS m')
    row = cursor.fetchone()
    return int(row[0] or 0), str(row[1] or '')


def _exists(cursor, table: str, col: str, val: str) -> bool:
    cursor.execute(f'SELECT 1 FROM `{table}` WHERE `{col}` = %s LIMIT 1', (val,))
    return cursor.fetchone() is not None


def call_usuario_insertar(cursor, params: dict[str, str], dry_run: bool) -> tuple[int, str]:
    if dry_run:
        return 1, 'dry-run'
    uid = _param_python_value(params.get('Id'))
    ucontra = _param_python_value(params.get('Contra'))
    in_vals = [_param_python_value(params.get(p)) for p in USER_PARAM_ORDER[2:]]
    cursor.execute('SET @uid = %s, @ucontra = %s, @r = 0, @m = ""', (uid, ucontra))
    ph = ', '.join(['%s'] * len(in_vals))
    cursor.execute(f'CALL usp_usuario_insertar(@uid, @ucontra, {ph}, @r, @m)', in_vals)
    r, m = _fetch_out(cursor)
    if r != 1 and 'ya existe' in m.lower():
        dni = _param_python_value(params.get('Dni'))
        email = _param_python_value(params.get('Email'))
        if dni:
            cursor.execute('SELECT EMAIL FROM USUARIO WHERE DNI = %s LIMIT 1', (dni,))
            row = cursor.fetchone()
            if row:
                if email and row[0] != email:
                    cursor.execute('UPDATE USUARIO SET EMAIL = %s WHERE DNI = %s', (email, dni))
                return 1, 'ya existía (omitido)'
    return r, m


def call_mensualidad_insertar(cursor, params: dict[str, str], dry_run: bool) -> tuple[int, str]:
    if dry_run:
        return 1, 'dry-run'
    mid = _param_python_value(params.get('Id'))
    in_vals = [_param_python_value(params.get(p)) for p in MENS_PARAM_ORDER[1:]]
    cursor.execute('SET @id = %s, @r = 0, @m = ""', (mid,))
    ph = ', '.join(['%s'] * len(in_vals))
    cursor.execute(f'CALL usp_mensualidad_insertar(@id, {ph}, @r, @m)', in_vals)
    return _fetch_out(cursor)


def _normalize_mysql_sql(sql: str) -> str:
    sql = sql.replace('[PLAN]', '`PLAN`')
    sql = re.sub(r"\bN'", "'", sql)
    sql = re.sub(r'\bBEGIN\b', '', sql, flags=re.IGNORECASE)
    return sql.strip()


def process_usuario_file(cursor, path: Path, dry_run: bool, stats: dict) -> None:
    text = path.read_text(encoding='utf-8')
    for match in EXEC_BLOCK_RE.finditer(text):
        proc = match.group(1).lower()
        if proc != 'usp_usuario_insertar':
            continue
        params = _parse_params(match.group(2))
        dni = _tsql_to_mysql_literal(params.get('Dni', "''")).strip("'")
        r, m = call_usuario_insertar(cursor, params, dry_run)
        if r == 1:
            stats['ok'] += 1
        else:
            stats['fail'] += 1
            print(f'  ERROR usuario DNI {dni}: {m}', file=sys.stderr)


def process_mensualidades_file(cursor, path: Path, dry_run: bool, stats: dict) -> None:
    text = path.read_text(encoding='utf-8')

    for match in IF_NOT_EXISTS_MENS_INSERT_RE.finditer(text):
        mid, insert_sql = match.group(1), match.group(2)
        if _exists(cursor, 'MENSUALIDAD', 'IDMENSUALIDAD', mid):
            stats['skip'] += 1
            continue
        uid_match = re.search(r"N'(\d+)',\s*N'72618032'", insert_sql)
        if uid_match and not _exists(cursor, 'USUARIO', 'IDUSUARIO', uid_match.group(1)):
            stats['skip'] += 1
            continue
        sql = _normalize_mysql_sql(insert_sql)
        if dry_run:
            stats['ok'] += 1
            continue
        try:
            cursor.execute(sql)
            stats['ok'] += 1
        except pymysql.err.MySQLError as exc:
            stats['fail'] += 1
            msg = exc.args[1] if len(exc.args) > 1 else str(exc)
            print(f'  ERROR mensualidad {mid} (INSERT): {msg[:200]}', file=sys.stderr)

    parts = re.split(r'(?=IF NOT EXISTS \(SELECT 1 FROM MENSUALIDAD)', text, flags=re.IGNORECASE)
    for part in parts:
        guard = IF_NOT_EXISTS_MENS_RE.search(part)
        exec_match = re.search(
            r'EXEC\s+(?:dbo\.)?usp_mensualidad_insertar\s+(.*?)(?=;\s*(?:IF\b|DECLARE\b|--|\Z))',
            part,
            re.DOTALL | re.IGNORECASE,
        )
        if not exec_match:
            user_guard = IF_NOT_EXISTS_USER_RE.search(part)
            user_exec = re.search(
                r'EXEC\s+(?:dbo\.)?usp_usuario_insertar\s+(.*?)(?=;\s*(?:IF\b|DECLARE\b|--|\Z))',
                part,
                re.DOTALL | re.IGNORECASE,
            )
            if user_guard and user_exec:
                uid = user_guard.group(1)
                if not _exists(cursor, 'USUARIO', 'IDUSUARIO', uid):
                    params = _parse_params(user_exec.group(1))
                    r, m = call_usuario_insertar(cursor, params, dry_run)
                    if r == 1:
                        stats['ok'] += 1
                    else:
                        stats['fail'] += 1
                        print(f'  ERROR usuario {uid}: {m}', file=sys.stderr)
            continue

        mid = guard.group(1) if guard else _parse_params(exec_match.group(1)).get('Id', '').strip("N'")
        if mid and _exists(cursor, 'MENSUALIDAD', 'IDMENSUALIDAD', mid.strip("'")):
            stats['skip'] += 1
            continue
        params = _parse_params(exec_match.group(1))
        r, m = call_mensualidad_insertar(cursor, params, dry_run)
        if r == 1:
            stats['ok'] += 1
        else:
            stats['fail'] += 1
            print(f'  ERROR mensualidad {mid}: {m}', file=sys.stderr)


def process_pagos_file(cursor, path: Path, dry_run: bool, stats: dict) -> None:
    text = path.read_text(encoding='utf-8')
    blocks = re.split(r'(?=IF NOT EXISTS \(SELECT 1 FROM PAGOMENSUALIDAD)', text, flags=re.IGNORECASE)
    for block in blocks:
        guard = IF_NOT_EXISTS_PAGO_RE.search(block)
        insert_match = INSERT_PAGO_RE.search(block)
        if not guard or not insert_match:
            continue
        pid = guard.group(1)
        if _exists(cursor, 'PAGOMENSUALIDAD', 'IDPAGOMENSUALIDAD', pid):
            stats['skip'] += 1
            continue
        sql = _normalize_mysql_sql(insert_match.group(0))
        if dry_run:
            stats['ok'] += 1
            continue
        try:
            cursor.execute(sql)
            stats['ok'] += 1
        except pymysql.err.MySQLError as exc:
            stats['fail'] += 1
            msg = exc.args[1] if len(exc.args) > 1 else str(exc)
            print(f'  ERROR pago {pid}: {msg[:200]}', file=sys.stderr)


def run_import(cursor, *, dry_run: bool, only: str | None, from_step: str | None) -> None:
    steps = IMPORT_ORDER
    if only:
        steps = [(g, f) for g, f in steps if g == only]
    if from_step:
        names = [g for g, _ in IMPORT_ORDER]
        if from_step not in names:
            print(f'ERROR: --from debe ser uno de: {", ".join(dict.fromkeys(names))}', file=sys.stderr)
            sys.exit(1)
        idx = next(i for i, (g, _) in enumerate(IMPORT_ORDER) if g == from_step)
        steps = IMPORT_ORDER[idx:]

    totals = {'ok': 0, 'fail': 0, 'skip': 0}
    for group, filename in steps:
        path = IMPORT_DIR / filename
        if not path.exists():
            print(f'FALTA: {path}', file=sys.stderr)
            sys.exit(1)
        print(f'>>> {filename} ({group})')
        stats = {'ok': 0, 'fail': 0, 'skip': 0}
        if group == 'usuarios':
            process_usuario_file(cursor, path, dry_run, stats)
        elif group == 'mensualidades':
            process_mensualidades_file(cursor, path, dry_run, stats)
        elif group == 'pagos':
            process_pagos_file(cursor, path, dry_run, stats)
        print(f'    ok={stats["ok"]} skip={stats["skip"]} fail={stats["fail"]}')
        for k in totals:
            totals[k] += stats[k]

    print(f'\nTotal: ok={totals["ok"]} skip={totals["skip"]} fail={totals["fail"]}')
    if totals['fail']:
        sys.exit(1)


def main():
    parser = argparse.ArgumentParser(description='Importar usuarios, mensualidades y pagos a MySQL')
    parser.add_argument('--dry-run', action='store_true', help='Contar operaciones sin escribir')
    parser.add_argument('--only', choices=['usuarios', 'mensualidades', 'pagos'])
    parser.add_argument('--from', dest='from_step', choices=['usuarios', 'mensualidades', 'pagos'])
    args = parser.parse_args()

    base = Path(__file__).resolve().parent.parent
    load_dotenv(base / '.env')
    host = os.getenv('DB_HOST', '127.0.0.1')
    port = int(os.getenv('DB_PORT', '3306'))
    user = os.getenv('DB_USER', 'root')
    password = os.getenv('DB_PASSWORD', '') or os.getenv('MYSQL_ROOT_PASSWORD', '')
    db_name = os.getenv('DB_NAME', 'AcademiaDB')

    if not password:
        print('ERROR: DB_PASSWORD o MYSQL_ROOT_PASSWORD requerido.', file=sys.stderr)
        sys.exit(1)

    conn = _connect(host, port, user, password, db_name)
    try:
        with conn.cursor() as cur:
            cur.execute('SELECT COUNT(*) FROM USUARIO')
            before = cur.fetchone()[0]
            print(f'Usuarios antes: {before}')
            run_import(cur, dry_run=args.dry_run, only=args.only, from_step=args.from_step)
            cur.execute('SELECT COUNT(*) FROM USUARIO')
            after_users = cur.fetchone()[0]
            cur.execute('SELECT COUNT(*) FROM MENSUALIDAD')
            after_mens = cur.fetchone()[0]
            cur.execute('SELECT COUNT(*) FROM PAGOMENSUALIDAD')
            after_pagos = cur.fetchone()[0]
            print(f'Usuarios: {after_users} | Mensualidades: {after_mens} | Pagos: {after_pagos}')
    finally:
        conn.close()


if __name__ == '__main__':
    main()
