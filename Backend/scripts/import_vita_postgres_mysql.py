"""
Importa USUARIO, MENSUALIDAD y PAGOMENSUALIDAD desde PostgreSQL (backup VITA)
hacia MySQL AcademiaDB.

Origen (PostgreSQL, base vita_backup):
  - public.users_usuario          -> USUARIO
  - public.membresias_membresia   -> MENSUALIDAD
  - public.membresias_pagomembresia -> PAGOMENSUALIDAD

Requisitos:
  pip install psycopg2-binary

Variables .env (MySQL, ya existentes):
  DB_HOST, DB_PORT, DB_USER, DB_PASSWORD, DB_NAME

Variables PostgreSQL (opcionales):
  PG_HOST=127.0.0.1
  PG_PORT=5432
  PG_USER=postgres
  PG_PASSWORD=123456
  PG_DATABASE=vita_backup

Uso (desde Backend/):
  python scripts/import_vita_postgres_mysql.py --dry-run
  python scripts/import_vita_postgres_mysql.py --only usuarios
  python scripts/import_vita_postgres_mysql.py --only mensualidades
  python scripts/import_vita_postgres_mysql.py --only pagos
  python scripts/import_vita_postgres_mysql.py --vigentes-only
"""
from __future__ import annotations

import argparse
import json
import os
import sys
from datetime import date, datetime
from decimal import Decimal
from pathlib import Path

import pymysql
from dotenv import load_dotenv

psycopg2 = None
psycopg2_extras = None

try:
    import psycopg2 as _pg_mod
    import psycopg2.extras as _pgx_mod
    psycopg2 = _pg_mod
    psycopg2_extras = _pgx_mod
except ImportError:
    pass

from import_mensualidades_faltantes_mysql import (
    PLAN_MAP,
    REGISTRADOR_FALLBACK,
    SALON_ID_MAP,
    build_observaciones,
    dedupe_vigentes,
    fmt_fecha_ddmmyyyy,
    is_vigente,
    load_db_state,
    map_plan,
    mensualidad_id,
    pago_id,
)
from setup_mysql_db import _connect

BASE = Path(__file__).resolve().parent.parent
EXPORT_DIR = BASE / 'data' / 'vita_export'


def _require_psycopg2():
    global psycopg2, psycopg2_extras
    if psycopg2 is None:
        try:
            import psycopg2 as _pg
            import psycopg2.extras as _pgx
            psycopg2 = _pg
            psycopg2_extras = _pgx
        except ImportError:
            print('ERROR: instala psycopg2-binary: pip install psycopg2-binary', file=sys.stderr)
            sys.exit(1)


def _row_to_json(row: dict) -> dict:
    out = {}
    for k, v in dict(row).items():
        if isinstance(v, datetime):
            out[k] = v.isoformat()
        elif isinstance(v, date):
            out[k] = v.isoformat()
        elif isinstance(v, Decimal):
            out[k] = float(v)
        else:
            out[k] = v
    return out


def export_json(export_dir: Path) -> None:
    _require_psycopg2()
    export_dir.mkdir(parents=True, exist_ok=True)
    pg = connect_pg()
    try:
        users = fetch_users(pg)
        membresias = fetch_membresias(pg)
        pagos = fetch_pagos(pg)
    finally:
        pg.close()

    (export_dir / 'usuarios.json').write_text(
        json.dumps([_row_to_json(u) for u in users], ensure_ascii=False, indent=2),
        encoding='utf-8',
    )
    (export_dir / 'mensualidades.json').write_text(
        json.dumps([_row_to_json(m) for m in membresias], ensure_ascii=False, indent=2),
        encoding='utf-8',
    )
    (export_dir / 'pagos.json').write_text(
        json.dumps([_row_to_json(p) for p in pagos], ensure_ascii=False, indent=2),
        encoding='utf-8',
    )
    print(f'Exportado en {export_dir}:')
    print(f'  usuarios={len(users)} mensualidades={len(membresias)} pagos={len(pagos)}')


def load_json_export(export_dir: Path) -> tuple[list[dict], list[dict], list[dict]]:
    users = json.loads((export_dir / 'usuarios.json').read_text(encoding='utf-8'))
    membresias = json.loads((export_dir / 'mensualidades.json').read_text(encoding='utf-8'))
    pagos = json.loads((export_dir / 'pagos.json').read_text(encoding='utf-8'))
    return users, membresias, pagos


def load_pg_data() -> tuple[list[dict], list[dict], list[dict]]:
    _require_psycopg2()
    pg = connect_pg()
    try:
        return fetch_users(pg), fetch_membresias(pg), fetch_pagos(pg)
    finally:
        pg.close()


ROL_MAP = {
    '1': '1',
    '2': '2',
    '3': '3',
    'ESTUDIANTE': '1',
    'USUARIO': '1',
    'DOCENTE': '2',
    'SECRETARIO': '3',
    'SECRETARIA': '3',
    'ADMIN': '3',
    'ADMINISTRADOR': '3',
    'ADMINISTRATIVO': '3',
}

USER_PARAM_TAIL = [
    'Nombre', 'Apellido', 'Dni', 'Email', 'IdTipoUsuario', 'Estado',
    'FechaNacimiento', 'Direccion', 'Distrito', 'Colegio', 'Grado',
    'TelPersonal', 'TelApoderado', 'NombreApoderado', 'Parentesco',
    'SituacionAcademica', 'ComoEntero', 'Foto',
]


def _fetch_out(cursor) -> tuple[int, str]:
    while cursor.nextset():
        pass
    cursor.execute('SELECT @r AS r, @m AS m')
    row = cursor.fetchone()
    return int(row[0] or 0), str(row[1] or '')


def _parse_date(val) -> date | None:
    if not val:
        return None
    if isinstance(val, date) and not isinstance(val, datetime):
        return val
    if isinstance(val, datetime):
        return val.date()
    return datetime.strptime(str(val)[:10], '%Y-%m-%d').date()


def _norm_salon_name(name) -> str:
    if not name:
        return ''
    s = str(name).strip().upper()
    for a, b in zip('ÓÁÉÍÚ', 'OAEIU'):
        s = s.replace(a, b)
    return s


def map_aula_row(salon_id, salon_nombre) -> str | None:
    if salon_id is not None and int(salon_id) in SALON_ID_MAP:
        return SALON_ID_MAP[int(salon_id)]
    name = _norm_salon_name(salon_nombre)
    from import_mensualidades_faltantes_mysql import SALON_NAME_MAP

    for k, v in SALON_NAME_MAP.items():
        if _norm_salon_name(k) == name:
            return v
    return None


def map_tipo_usuario(rol, is_staff=False, is_superuser=False) -> str:
    if is_superuser:
        return '3'
    if rol is not None:
        key = str(rol).strip().upper()
        if key in ROL_MAP:
            return ROL_MAP[key]
    if is_staff:
        return '2'
    return '1'


def map_estado_miembro(fecha_fin, fecha_cancelacion, today: date) -> int:
    if fecha_cancelacion:
        return 4
    fin = _parse_date(fecha_fin)
    if fin and fin < today:
        return 3
    return 2


def build_mem_obs(row: dict) -> str:
    base = {
        'id': row.get('id'),
        'asesor': row.get('asesor'),
        'tipo': row.get('tipo'),
    }
    obs = build_observaciones(base)
    extras = []
    if row.get('ciclo'):
        extras.append(f"Ciclo: {row['ciclo']}")
    if row.get('membresias'):
        extras.append(f"Membresias: {row['membresias']}")
    if row.get('tipo_pago'):
        extras.append(f"Tipo pago: {row['tipo_pago']}")
    if row.get('observaciones'):
        extras.append(str(row['observaciones']).strip())
    if extras:
        obs = f"{obs} | {' | '.join(extras)}"
    return obs


def verify_mysql_schema(cursor) -> None:
    required = ('USUARIO', 'MENSUALIDAD', 'PAGOMENSUALIDAD', 'PLAN', 'AULA')
    missing = []
    for table in required:
        cursor.execute(
            """
            SELECT COUNT(*) FROM information_schema.TABLES
            WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = %s
            """,
            (table,),
        )
        if cursor.fetchone()[0] == 0:
            missing.append(table)
    if missing:
        host = os.getenv('DB_HOST', '127.0.0.1')
        db = os.getenv('DB_NAME', 'AcademiaDB')
        print(
            f'ERROR: en {db}@{host} faltan tablas: {", ".join(missing)}',
            file=sys.stderr,
        )
        print(
            'Opciones:\n'
            '  1) Importar al servidor: en .env usa DB_HOST del servidor Linode '
            '(con scripts db_scripts_mysql ya aplicados).\n'
            '  2) MySQL local: ejecuta python scripts/setup_mysql_db.py antes del import.',
            file=sys.stderr,
        )
        sys.exit(1)


def connect_pg():
    host = os.getenv('PG_HOST', '127.0.0.1')
    port = int(os.getenv('PG_PORT', '5432'))
    user = os.getenv('PG_USER', 'postgres')
    password = os.getenv('PG_PASSWORD', '')
    db = os.getenv('PG_DATABASE', 'vita_backup')
    if not password:
        print('ERROR: define PG_PASSWORD en .env', file=sys.stderr)
        sys.exit(1)
    return psycopg2.connect(
        host=host, port=port, user=user, password=password, dbname=db,
    )


def fetch_users(pg) -> list[dict]:
    sql = """
        SELECT id, password, is_superuser, username, first_name, last_name,
               is_staff, is_active, rol, nombres, apellidos, dni, email,
               fecha_nacimiento, telefono, direccion, telefono_apoderado,
               distrito, colegio, grado, situacion_academica, nombre_colegio,
               foto_perfil, modo
        FROM public.users_usuario
        ORDER BY id
    """
    with pg.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
        cur.execute(sql)
        return list(cur.fetchall())


def fetch_membresias(pg) -> list[dict]:
    sql = """
        SELECT m.id, m.fecha_inicio, m.fecha_fin, m.monto_total, m.plan, m.tipo,
               m.tipo_pago, m.fecha_registro, m.observaciones, m.registrada_por_id,
               m.usuario_id, m.salon_id, m.ciclo, m.membresias, m.asesor,
               m.fecha_cancelacion,
               u.dni AS usuario_dni,
               s.nombre AS salon_nombre
        FROM public.membresias_membresia m
        LEFT JOIN public.users_usuario u ON u.id = m.usuario_id
        LEFT JOIN public.membresias_salon s ON s.id = m.salon_id
        ORDER BY m.id
    """
    with pg.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
        cur.execute(sql)
        return list(cur.fetchall())


def fetch_pagos(pg) -> list[dict]:
    sql = """
        SELECT p.id, p.fecha_pago, p.monto_pagado, p.observaciones,
               p.membresia_id, p.registrado_por_id,
               ru.dni AS registrado_dni
        FROM public.membresias_pagomembresia p
        LEFT JOIN public.users_usuario ru ON ru.id = p.registrado_por_id
        ORDER BY p.id
    """
    with pg.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
        cur.execute(sql)
        return list(cur.fetchall())


def build_id_to_dni(users: list[dict]) -> dict[int, str]:
    mapping = dict(REGISTRADOR_FALLBACK)
    for u in users:
        uid = u.get('id')
        dni = (u.get('dni') or u.get('username') or '').strip()
        if uid is not None and dni:
            mapping[int(uid)] = dni
    return mapping


def pick_email(row: dict, used: set[str]) -> str:
    dni = (row.get('dni') or row.get('username') or '').strip()
    email = (row.get('email') or '').strip()
    if not email:
        email = f'{dni}@import.academia.local'
    if email.lower() in used:
        email = f'{dni}@import.academia.local'
    used.add(email.lower())
    return email


def import_usuarios(cursor, users: list[dict], dry_run: bool) -> dict:
    stats = {'ok': 0, 'skip': 0, 'fail': 0}
    used_emails: set[str] = set()

    cursor.execute('SELECT LOWER(EMAIL) FROM USUARIO')
    used_emails.update(row[0] for row in cursor.fetchall() if row[0])

    for row in users:
        dni = (row.get('dni') or row.get('username') or '').strip()
        if not dni:
            stats['fail'] += 1
            print(f'  ERROR user id={row.get("id")}: sin DNI', file=sys.stderr)
            continue

        cursor.execute('SELECT 1 FROM USUARIO WHERE IDUSUARIO = %s LIMIT 1', (dni,))
        if cursor.fetchone():
            stats['skip'] += 1
            continue

        nombre = (row.get('nombres') or row.get('first_name') or '').strip() or 'SIN NOMBRE'
        apellido = (row.get('apellidos') or row.get('last_name') or '').strip() or 'SIN APELLIDO'
        tipo = map_tipo_usuario(row.get('rol'), row.get('is_staff'), row.get('is_superuser'))
        estado = 'Activo' if row.get('is_active', True) else 'Inactivo'
        email = pick_email(row, used_emails)
        contra = dni if tipo == '1' else (row.get('password') or dni)
        colegio = (row.get('colegio') or row.get('nombre_colegio') or '').strip() or None

        in_vals = [
            nombre, apellido, dni, email, tipo, estado,
            fmt_fecha_ddmmyyyy(row.get('fecha_nacimiento')),
            (row.get('direccion') or '').strip() or None,
            (row.get('distrito') or '').strip() or None,
            colegio,
            (row.get('grado') or '').strip() or None,
            (row.get('telefono') or '').strip() or None,
            (row.get('telefono_apoderado') or '').strip() or None,
            None, None,
            (row.get('situacion_academica') or '').strip() or None,
            (row.get('modo') or '').strip() or None,
            (row.get('foto_perfil') or '').strip() or None,
        ]

        if dry_run:
            stats['ok'] += 1
            continue

        cursor.execute('SET @uid = %s, @ucontra = %s, @r = 0, @m = ""', (dni, contra))
        ph = ', '.join(['%s'] * len(in_vals))
        cursor.execute(f'CALL usp_usuario_insertar(@uid, @ucontra, {ph}, @r, @m)', in_vals)
        r, msg = _fetch_out(cursor)
        if r == 1:
            stats['ok'] += 1
        else:
            stats['fail'] += 1
            print(f'  ERROR usuario {dni}: {msg}', file=sys.stderr)

    return stats


def insert_mensualidad(cursor, row: dict, today: date, id_to_dni: dict, state: dict) -> tuple[bool, str]:
    old_id = int(row['id'])
    mid = mensualidad_id(old_id)
    dni = (row.get('usuario_dni') or '').strip()
    if not dni:
        return False, 'sin DNI de estudiante'

    fi = fmt_fecha_ddmmyyyy(row.get('fecha_inicio'))
    ff = fmt_fecha_ddmmyyyy(row.get('fecha_fin'))
    if not fi or not ff:
        return False, 'fechas inválidas'

    try:
        plan = map_plan(row.get('plan'))
    except KeyError as exc:
        return False, str(exc)

    if plan not in state['plans']:
        return False, f'plan {plan} no existe en AcademiaDB'

    if dni not in state['all_users']:
        return False, f'estudiante {dni} no existe en USUARIO'

    aula = map_aula_row(row.get('salon_id'), row.get('salon_nombre'))
    reg = id_to_dni.get(int(row['registrada_por_id'])) if row.get('registrada_por_id') else None
    if reg and reg not in state['all_users']:
        reg = None

    estado_m = map_estado_miembro(row.get('fecha_fin'), row.get('fecha_cancelacion'), today)
    obs = build_mem_obs(row)
    monto = float(row.get('monto_total') or 0)
    fc = fmt_fecha_ddmmyyyy(row.get('fecha_cancelacion'))
    fr = fmt_fecha_ddmmyyyy(row.get('fecha_registro'))

    cursor.execute(
        """
        INSERT INTO MENSUALIDAD (
            IDMENSUALIDAD, FECHAINICIO, FECHAFIN, ESTADOMIEMBRO, MONTOTOTAL, OBSERVACIONES,
            FECHAREGISTRO, HORAREGISTRO, IDPLAN, IDAULA, IDTURNO, IDUSUARIO, REGISTRADOPOR,
            IDTUTOR, FECHACANCELACION, ESTADO
        )
        SELECT
            %s, %s, %s, %s, %s, %s,
            COALESCE(%s, fn_fecha_ddmmyyyy()), TIME_FORMAT(NOW(), '%%H:%%i:%%s'),
            %s, %s, p.IDTURNO, %s, %s,
            NULL, %s, 'Activo'
        FROM `PLAN` p WHERE p.IDPLAN = %s
        """,
        (mid, fi, ff, estado_m, monto, obs, fr, plan, aula, dni, reg, fc, plan),
    )
    return True, mid


def import_mensualidades(
    cursor,
    rows: list[dict],
    id_to_dni: dict,
    state: dict,
    today: date,
    dry_run: bool,
) -> dict:
    stats = {'ok': 0, 'skip': 0, 'fail': 0}
    for row in rows:
        mid = mensualidad_id(int(row['id']))
        if mid in state['mem_ids']:
            stats['skip'] += 1
            continue

        if dry_run:
            stats['ok'] += 1
            continue

        try:
            ok, msg = insert_mensualidad(cursor, row, today, id_to_dni, state)
            if ok:
                state['mem_ids'].add(mid)
                stats['ok'] += 1
            else:
                stats['fail'] += 1
                print(f'  ERROR {mid}: {msg}', file=sys.stderr)
        except pymysql.err.MySQLError as exc:
            stats['fail'] += 1
            detail = exc.args[1] if len(exc.args) > 1 else str(exc)
            print(f'  ERROR {mid}: {detail[:200]}', file=sys.stderr)

    return stats


def import_pagos(cursor, rows: list[dict], allowed_mem_ids: set[str], state: dict, dry_run: bool) -> dict:
    stats = {'ok': 0, 'skip': 0, 'fail': 0}
    for row in rows:
        if float(row.get('monto_pagado') or 0) <= 0:
            continue
        pid = pago_id(int(row['id']))
        mid = mensualidad_id(int(row['membresia_id']))
        if pid in state['pago_ids']:
            stats['skip'] += 1
            continue
        if mid not in allowed_mem_ids:
            stats['skip'] += 1
            continue

        reg = (row.get('registrado_dni') or '').strip() or None
        if reg and reg not in state['all_users']:
            reg = None

        if dry_run:
            stats['ok'] += 1
            continue

        try:
            cursor.execute(
                """
                INSERT INTO PAGOMENSUALIDAD (
                    IDPAGOMENSUALIDAD, MONTO, FECHAPAGO, HORAPAGO, OBSERVACIONES,
                    IDMENSUALIDAD, IDMETODOPAGO, IDUSUARIO
                ) VALUES (%s, %s, %s, '08:00:00', %s, %s, 'MPG001', %s)
                """,
                (
                    pid,
                    float(row.get('monto_pagado') or 0),
                    fmt_fecha_ddmmyyyy(row.get('fecha_pago')),
                    row.get('observaciones') or f"Import VITA pago #{row.get('id')}",
                    mid,
                    reg,
                ),
            )
            state['pago_ids'].add(pid)
            stats['ok'] += 1
        except pymysql.err.MySQLError as exc:
            stats['fail'] += 1
            detail = exc.args[1] if len(exc.args) > 1 else str(exc)
            print(f'  ERROR {pid}: {detail[:200]}', file=sys.stderr)

    return stats


def main():
    parser = argparse.ArgumentParser(description='Importar VITA (PostgreSQL) -> Academia (MySQL)')
    parser.add_argument('--dry-run', action='store_true')
    parser.add_argument('--only', choices=['usuarios', 'mensualidades', 'pagos'])
    parser.add_argument(
        '--export-json',
        action='store_true',
        help='Exporta PostgreSQL a data/vita_export/*.json (solo PC)',
    )
    parser.add_argument(
        '--from-json',
        type=Path,
        default=None,
        help='Importa desde JSON exportado (ideal en el servidor)',
    )
    parser.add_argument(
        '--vigentes-only',
        action='store_true',
        help='Solo mensualidades vigentes (sin cancelación y fecha_fin >= hoy)',
    )
    args = parser.parse_args()

    load_dotenv(BASE / '.env')

    if args.export_json:
        export_json(EXPORT_DIR)
        return

    mysql_password = os.getenv('DB_PASSWORD', '') or os.getenv('MYSQL_ROOT_PASSWORD', '')
    if not mysql_password:
        print('ERROR: DB_PASSWORD o MYSQL_ROOT_PASSWORD requerido.', file=sys.stderr)
        sys.exit(1)

    if args.from_json:
        export_dir = args.from_json
        if not export_dir.is_absolute():
            export_dir = BASE / export_dir
        if not (export_dir / 'mensualidades.json').exists():
            print(f'ERROR: no existe export en {export_dir}', file=sys.stderr)
            sys.exit(1)
        users, membresias, pagos = load_json_export(export_dir)
        source_label = f'JSON {export_dir}'
    else:
        users, membresias, pagos = load_pg_data()
        source_label = 'PostgreSQL'

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
        f'{source_label}: usuarios={len(users)} '
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
