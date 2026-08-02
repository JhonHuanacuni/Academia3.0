"""
Importa usuarios retirados desde JSON (legacy Academia 2.0).
Estado: Retirado | Rol: Estudiante (IdTipoUsuario = 1)

Uso (desde Backend/ con venv y .env):
  venv/bin/python scripts/import_retirados_mysql.py
  venv/bin/python scripts/import_retirados_mysql.py --file data/retirados.txt
  venv/bin/python scripts/import_retirados_mysql.py --dry-run
"""
from __future__ import annotations

import argparse
import json
import os
import sys
from datetime import datetime
from pathlib import Path

from dotenv import load_dotenv

from import_datos_mysql import USER_PARAM_ORDER, call_usuario_insertar
from setup_mysql_db import _connect

BASE = Path(__file__).resolve().parent.parent
DEFAULT_INPUT = BASE / 'data' / 'retirados.txt'


def _pick_colegio(record: dict):
    val = record.get('nombreColegio') or record.get('colegio')
    if val is None:
        return None
    s = str(val).strip()
    return s or None


def _fmt_fecha(val) -> str | None:
    if not val:
        return None
    s = str(val).strip()
    if not s:
        return None
    for fmt in ('%Y-%m-%d', '%d/%m/%Y'):
        try:
            return datetime.strptime(s[:10], fmt).strftime('%d%m%Y')
        except ValueError:
            continue
    return None


def _norm_situacion(val) -> str | None:
    if not val:
        return None
    v = str(val).strip().lower()
    mapping = {'egresado': 'Egresado', 'estudiante': 'Estudiante'}
    return mapping.get(v, str(val).strip().capitalize())


def _assign_emails(records: list[dict]) -> list[str]:
    seen: dict[str, str] = {}
    out: list[str] = []
    for s in records:
        dni = (s.get('dni') or s.get('username') or '').strip()
        email = (s.get('email') or '').strip()
        key = email.lower()
        if not email:
            final = f'{dni}@import.academia.local'
        elif key not in seen:
            seen[key] = dni
            final = email
        else:
            final = f'{dni}@import.academia.local'
        out.append(final)
    return out


def _build_params(record: dict, email: str) -> dict[str, str]:
    dni = (record.get('dni') or record.get('username') or '').strip()
    nombre = (record.get('nombres') or record.get('firstName') or '').strip()
    apellido = (record.get('apellidos') or record.get('lastName') or '').strip()
    tel = (record.get('telefono') or '').strip() or None
    tel_apod = (record.get('telefono_apoderado') or '').strip() or None
    direccion = (record.get('direccion') or '').strip() or None
    distrito = (record.get('distrito') or '').strip() if record.get('distrito') else None
    colegio = _pick_colegio(record)
    grado = (record.get('grado') or '').strip() or None
    foto = (record.get('foto_perfil') or '').strip() or None
    fecha_nac = _fmt_fecha(record.get('fecha_nacimiento'))
    situacion = _norm_situacion(record.get('situacion_academica'))
    apoderado = (record.get('descripcion') or '').strip() or None

    def sval(v):
        return 'NULL' if v is None else f"N'{str(v).replace(chr(39), chr(39)+chr(39))}'"

    return {
        'Id': sval(dni),
        'Contra': sval(dni),
        'Nombre': sval(nombre),
        'Apellido': sval(apellido),
        'Dni': sval(dni),
        'Email': sval(email),
        'IdTipoUsuario': "N'1'",
        'Estado': "N'Retirado'",
        'FechaNacimiento': sval(fecha_nac) if fecha_nac else 'NULL',
        'Direccion': sval(direccion),
        'Distrito': sval(distrito),
        'Colegio': sval(colegio),
        'Grado': sval(grado),
        'TelPersonal': sval(tel),
        'TelApoderado': sval(tel_apod),
        'NombreApoderado': sval(apoderado),
        'Parentesco': 'NULL',
        'SituacionAcademica': sval(situacion),
        'ComoEntero': 'NULL',
        'Foto': sval(foto),
    }


def _marcar_retirado(cursor, dni: str, dry_run: bool) -> str:
    """Si ya existe, pasa a Retirado; si ya está Retirado, omitir."""
    if dry_run:
        return 'skip'
    cursor.execute(
        "SELECT IDUSUARIO, ESTADO FROM USUARIO WHERE DNI = %s OR IDUSUARIO = %s LIMIT 1",
        (dni, dni),
    )
    row = cursor.fetchone()
    if not row:
        return 'missing'
    if row[1] == 'Retirado':
        return 'skip'
    cursor.execute(
        "UPDATE USUARIO SET ESTADO = 'Retirado' WHERE IDUSUARIO = %s",
        (row[0],),
    )
    return 'updated'


def _upsert_retirado(cursor, params: dict[str, str], dni: str, dry_run: bool) -> tuple[str, str]:
    if dry_run:
        return 'ok', 'dry-run'
    cursor.execute(
        "SELECT IDUSUARIO, ESTADO FROM USUARIO WHERE DNI = %s OR IDUSUARIO = %s LIMIT 1",
        (dni, dni),
    )
    row = cursor.fetchone()
    if row:
        if row[1] == 'Retirado':
            return 'skip', 'ya retirado'
        cursor.execute(
            "UPDATE USUARIO SET ESTADO = 'Retirado' WHERE IDUSUARIO = %s",
            (row[0],),
        )
        return 'updated', 'marcado retirado'

    r, m = call_usuario_insertar(cursor, params, dry_run)
    if r == 1:
        return 'ok', m
    if 'ya existe' in m.lower() or 'retirado' in m.lower():
        action, msg = _marcar_retirado(cursor, dni, dry_run), m
        if action == 'missing':
            return 'fail', m
        return action, msg
    return 'fail', m


def import_retirados(cursor, path: Path, dry_run: bool) -> dict[str, int]:
    data = json.loads(path.read_text(encoding='utf-8'))
    records = [r for r in data if (r.get('rol') or 'USUARIO') == 'USUARIO']
    records.sort(key=lambda r: (r.get('dni') or r.get('username') or '').strip())
    emails = _assign_emails(records)

    stats = {'ok': 0, 'updated': 0, 'skip': 0, 'fail': 0}

    for record, email in zip(records, emails):
        dni = (record.get('dni') or record.get('username') or '').strip()
        if not dni:
            stats['fail'] += 1
            print(f'  ERROR: registro sin DNI id={record.get("id")}', file=sys.stderr)
            continue

        params = _build_params(record, email)
        action, m = _upsert_retirado(cursor, params, dni, dry_run)
        if action in stats:
            stats[action] += 1
        else:
            stats['fail'] += 1
            print(f'  ERROR DNI {dni}: {m}', file=sys.stderr)

    return stats


def main():
    parser = argparse.ArgumentParser(description='Importar usuarios retirados a MySQL')
    parser.add_argument('--file', type=Path, default=DEFAULT_INPUT, help='JSON retirados.txt')
    parser.add_argument('--dry-run', action='store_true')
    args = parser.parse_args()

    if not args.file.exists():
        print(f'ERROR: no existe {args.file}', file=sys.stderr)
        sys.exit(1)

    load_dotenv(BASE / '.env')
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
            cur.execute("SELECT COUNT(*) FROM USUARIO WHERE ESTADO = 'Retirado'")
            before = cur.fetchone()[0]
            print(f'Retirados antes: {before}')
            print(f'>>> {args.file}')
            stats = import_retirados(cur, args.file, args.dry_run)
            print(
                f"ok={stats['ok']} updated={stats['updated']} "
                f"skip={stats['skip']} fail={stats['fail']}"
            )
            cur.execute("SELECT COUNT(*) FROM USUARIO WHERE ESTADO = 'Retirado'")
            after = cur.fetchone()[0]
            print(f'Retirados después: {after}')
            if stats['fail']:
                sys.exit(1)
    finally:
        conn.close()


if __name__ == '__main__':
    main()
