"""
Importa USUARIO / MENSUALIDAD / PAGOMENSUALIDAD desde data/vita_export/*.json
hacia MySQL AcademiaDB. No requiere PostgreSQL ni psycopg2.

Uso en el servidor:
  cd ~/academia_src/Backend && source venv/bin/activate
  python3 scripts/import_vita_json_mysql.py --only mensualidades
  python3 scripts/import_vita_json_mysql.py --only pagos
"""
from __future__ import annotations

import argparse
import sys
from datetime import date
from pathlib import Path

# Reutiliza la lógica de mapeo/import (sin tocar PostgreSQL)
from import_vita_postgres_mysql import (  # noqa: E402
    BASE,
    build_id_to_dni,
    dedupe_vigentes,
    import_mensualidades,
    import_pagos,
    import_usuarios,
    is_vigente,
    load_db_state,
    load_json_export,
    verify_mysql_schema,
)
from setup_mysql_db import _connect  # noqa: E402


def main():
    parser = argparse.ArgumentParser(description='Importar VITA JSON -> Academia MySQL')
    parser.add_argument('--dry-run', action='store_true')
    parser.add_argument('--only', choices=['usuarios', 'mensualidades', 'pagos'])
    parser.add_argument(
        '--json-dir',
        type=Path,
        default=BASE / 'data' / 'vita_export',
        help='Carpeta con usuarios.json, mensualidades.json, pagos.json',
    )
    parser.add_argument('--vigentes-only', action='store_true')
    args = parser.parse_args()

    from dotenv import load_dotenv
    import os

    load_dotenv(BASE / '.env')
    mysql_password = os.getenv('DB_PASSWORD', '') or os.getenv('MYSQL_ROOT_PASSWORD', '')
    if not mysql_password:
        print('ERROR: DB_PASSWORD requerido en .env', file=sys.stderr)
        sys.exit(1)

    export_dir = args.json_dir if args.json_dir.is_absolute() else BASE / args.json_dir
    if not (export_dir / 'mensualidades.json').exists():
        print(f'ERROR: no existe {export_dir / "mensualidades.json"}', file=sys.stderr)
        sys.exit(1)

    users, membresias, pagos = load_json_export(export_dir)
    today = date.today()
    id_to_dni = build_id_to_dni(users)

    if args.vigentes_only:
        legacy = [
            {
                'id': r['id'],
                'fecha_inicio': r['fecha_inicio'],
                'fecha_fin': r['fecha_fin'],
                'fecha_cancelacion': r['fecha_cancelacion'],
                'monto_total': r['monto_total'],
                'total_pagado': 0,
            }
            for r in membresias
        ]
        vig_ids = {int(m['id']) for m in dedupe_vigentes([m for m in legacy if is_vigente(m, today)])}
        membresias = [r for r in membresias if int(r['id']) in vig_ids]
        pagos = [p for p in pagos if int(p['membresia_id']) in vig_ids]

    print(
        f'JSON {export_dir}: usuarios={len(users)} '
        f'membresias={len(membresias)} pagos={len(pagos)}'
    )

    conn = _connect(
        os.getenv('DB_HOST', '127.0.0.1'),
        int(os.getenv('DB_PORT', '3306')),
        os.getenv('DB_USER', 'root'),
        mysql_password,
        os.getenv('DB_NAME', 'AcademiaDB'),
    )
    try:
        with conn.cursor() as cur:
            verify_mysql_schema(cur)
            state = load_db_state(cur)

            if args.only in (None, 'usuarios'):
                print('>>> USUARIO')
                stats_u = import_usuarios(cur, users, args.dry_run)
                print(f'    ok={stats_u["ok"]} skip={stats_u["skip"]} fail={stats_u["fail"]}')
                if not args.dry_run:
                    conn.commit()
                state = load_db_state(cur)

            allowed_mem_ids = set(state['mem_ids'])

            if args.only in (None, 'mensualidades'):
                print('>>> MENSUALIDAD')
                stats_m = import_mensualidades(cur, membresias, id_to_dni, state, today, args.dry_run)
                print(f'    ok={stats_m["ok"]} skip={stats_m["skip"]} fail={stats_m["fail"]}')
                if not args.dry_run:
                    conn.commit()
                allowed_mem_ids = set(load_db_state(cur)['mem_ids'])

            if args.only in (None, 'pagos'):
                state = load_db_state(cur)
                print('>>> PAGOMENSUALIDAD')
                stats_p = import_pagos(cur, pagos, allowed_mem_ids, state, args.dry_run)
                print(f'    ok={stats_p["ok"]} skip={stats_p["skip"]} fail={stats_p["fail"]}')
                if not args.dry_run:
                    conn.commit()

            if not args.dry_run:
                cur.execute('SELECT COUNT(*) FROM USUARIO')
                u = cur.fetchone()[0]
                cur.execute('SELECT COUNT(*) FROM MENSUALIDAD')
                m = cur.fetchone()[0]
                cur.execute('SELECT COUNT(*) FROM PAGOMENSUALIDAD')
                p = cur.fetchone()[0]
                print(f'BD final: usuarios={u} mensualidades={m} pagos={p}')
    finally:
        conn.close()


if __name__ == '__main__':
    main()
