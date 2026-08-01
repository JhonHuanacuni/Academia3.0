"""
Valida todos los scripts del ORDER ejecutándolos contra MySQL.
Lista TODOS los errores sin detenerse en el primero (modo --continue).

Uso (desde Backend/ con venv y MySQL corriendo):
  venv/bin/python scripts/validate_mysql_scripts.py
  venv/bin/python scripts/validate_mysql_scripts.py --from 06_07_2026/5.usp_usuario_foto.sql
"""
from __future__ import annotations

import argparse
import os
import sys
from pathlib import Path

import pymysql
from dotenv import load_dotenv

from setup_mysql_db import ORDER, SCRIPTS_DIR, split_sql, _strip_leading_comments, _connect
from install_auditoria_triggers import install_auditoria_triggers


def validate_file(cursor, rel: str, path: Path) -> list[str]:
    import re

    if rel == '30_07_2026/5.triggers_auditoria.sql':
        errors = []
        try:
            install_auditoria_triggers(cursor)
        except pymysql.err.MySQLError as exc:
            msg = exc.args[1] if len(exc.args) > 1 else str(exc)
            errors.append(f'  install_auditoria_triggers: {msg[:300]}')
        return errors

    errors = []
    sql = path.read_text(encoding='utf-8')
    for i, stmt in enumerate(split_sql(sql)):
        s = _strip_leading_comments(stmt.strip())
        if not s:
            continue
        if re.match(r'USE\s+', s, re.I):
            continue
        if re.match(r'CREATE\s+DATABASE\b', s, re.I):
            continue
        try:
            cursor.execute(s)
        except pymysql.err.MySQLError as exc:
            msg = exc.args[1] if len(exc.args) > 1 else str(exc)
            errors.append(f'  stmt #{i + 1}: {msg[:300]}')
    return errors


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--from', dest='from_file', help='Empezar desde este archivo del ORDER')
    parser.add_argument('--stop', action='store_true', help='Detener en el primer error')
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

    order = ORDER
    if args.from_file:
        rel = args.from_file.replace('\\', '/')
        if rel not in order:
            print(f'ERROR: {rel} no está en ORDER', file=sys.stderr)
            sys.exit(1)
        order = order[order.index(rel):]

    conn = _connect(host, port, user, password, db_name)
    failed = []
    try:
        with conn.cursor() as cur:
            try:
                cur.execute('SET GLOBAL log_bin_trust_function_creators = 1')
            except pymysql.err.OperationalError as exc:
                if exc.args[0] != 1227:
                    raise
                print(
                    'Aviso: sin privilegio SUPER; omitiendo log_bin_trust_function_creators',
                    file=sys.stderr,
                )
            for rel in order:
                path = SCRIPTS_DIR / rel.replace('/', os.sep)
                if not path.exists():
                    failed.append((rel, ['archivo no existe']))
                    if args.stop:
                        break
                    continue
                print(f'>>> {rel}')
                errs = validate_file(cur, rel, path)
                if errs:
                    failed.append((rel, errs))
                    print('\n'.join(errs), file=sys.stderr)
                    if args.stop:
                        break
    finally:
        conn.close()

    if failed:
        print(f'\nFALLARON {len(failed)} archivo(s):', file=sys.stderr)
        for rel, errs in failed:
            print(f'  {rel} ({len(errs)} error(es))', file=sys.stderr)
        sys.exit(1)
    print(f'\nOK: {len(order)} archivo(s) validados.')


if __name__ == '__main__':
    main()
