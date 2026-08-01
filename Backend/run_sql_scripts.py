"""Ejecuta scripts SQL divididos por GO usando la conexión Django."""
import os
import re
import sys
from pathlib import Path

import django

BASE_DIR = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(BASE_DIR))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend_project.settings')
django.setup()

from django.db import connection


def split_batches(sql_text: str):
    batches = []
    current = []
    for line in sql_text.splitlines():
        if re.match(r'^\s*GO\s*(--.*)?$', line, re.I):
            batch = '\n'.join(current).strip()
            if batch:
                batches.append(batch)
            current = []
        else:
            current.append(line)
    tail = '\n'.join(current).strip()
    if tail:
        batches.append(tail)
    return batches


def run_script(path: Path):
    print(f'\n=== {path.name} ===')
    sql = path.read_text(encoding='utf-8')
    batches = split_batches(sql)
    with connection.cursor() as cursor:
        for i, batch in enumerate(batches, 1):
            try:
                cursor.execute(batch)
                while cursor.nextset():
                    pass
                print(f'  Lote {i}/{len(batches)} OK')
            except Exception as exc:
                print(f'  Lote {i}/{len(batches)} ERROR: {exc}')
                raise


def main():
    script_dir = BASE_DIR / 'db_scripts' / '31_07_2026'
    order_file = script_dir / 'ORDEN_EJECUCION.txt'
    files = []
    if order_file.exists():
        for line in order_file.read_text(encoding='utf-8').splitlines():
            name = line.strip()
            if name and not name.startswith('#'):
                files.append(script_dir / name)
    else:
        files = sorted(script_dir.glob('*.sql'))

    for path in files:
        if path.exists():
            run_script(path)
        else:
            print(f'No encontrado: {path}')

    print('\nTodos los scripts de auditoría ejecutados.')


if __name__ == '__main__':
    main()
