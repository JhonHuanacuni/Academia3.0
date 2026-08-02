"""
Importa mensualidades vigentes faltantes y sus pagos desde JSON exportado del sistema legacy.

Solo inserta registros que no existen (por IDMENSUALIDAD / IDPAGOMENSUALIDAD o por
usuario+fechas duplicadas). Pensado para re-ejecutar sin crear duplicados.

Uso (desde Backend/ con venv y .env):
  venv/bin/python scripts/import_mensualidades_faltantes_mysql.py
  venv/bin/python scripts/import_mensualidades_faltantes_mysql.py --dry-run
  venv/bin/python scripts/import_mensualidades_faltantes_mysql.py --only pagos
"""
from __future__ import annotations

import argparse
import json
import os
import re
import sys
from datetime import date, datetime
from decimal import Decimal
from pathlib import Path

import pymysql
from dotenv import load_dotenv

from setup_mysql_db import _connect

BASE = Path(__file__).resolve().parent.parent
DATA_DIR = BASE / 'data'

PLAN_MAP = {
    'PLAN_ANUAL_1_MANANA': 'PLN001',
    'PLAN_ANUAL_1_MAÑANA': 'PLN001',
    'PLAN_ANUAL_2_TARDE': 'PLN002',
    'PLAN_ANUAL_3_MANANA': 'PLN003',
    'PLAN_ANUAL_3_MAÑANA': 'PLN003',
    'PLAN_ANUAL_VIRTUAL_MANANA': 'PLN004',
    'PLAN_ANUAL_VIRTUAL_MAÑANA': 'PLN004',
    'PLAN_ESCOLAR_1_INTERDIARIO_MANANA': 'PLN005',
    'PLAN_ESCOLAR_1_INTERDIARIO_MAÑANA': 'PLN005',
    'PLAN_ESCOLAR_2_INTERDIARIO_TARDE': 'PLN006',
    'PLAN_SABATINO_1_MANANA': 'PLN007',
    'PLAN_SABATINO_1_MAÑANA': 'PLN007',
    'PLAN_BECA_18_MANANA': 'PLN008',
    'PLAN_BECA_18_MAÑANA': 'PLN008',
    'CICLO_BECA_18_2026': 'PLN008',
    'PLAN_SEMI_ANUAL_MANANA': 'PLN009',
    'PLAN_SEMI_ANUAL_MAÑANA': 'PLN009',
    'CICLO_CERO_2026': 'PLN009',
    'PLAN_SEMESTRAL_MANANA': 'PLN010',
    'PLAN_SEMESTRAL_MAÑANA': 'PLN010',
    'PLAN_BECA_18_SABATINO_MANANA': 'PLN011',
    'PLAN_BECA_18_SABATINO_MAÑANA': 'PLN011',
    'CICLO_VERANO_2026': 'PLN009',
}

SALON_NAME_MAP = {
    'PERSONAL VITA-ESTACIÓN': 'AUL007',
    'PERSONAL VITA-ESTACION': 'AUL007',
    'CICLO ANUAL 1 - 2026': 'AUL008',
    'CICLO ANUAL 2 - 2026': 'AUL009',
    'CICLO ANUAL 3 - 2026': 'AUL010',
    'CICLO ANUAL 4 - 2026': 'AUL011',
    'CICLO SABATINO - 2026': 'AUL002',
    'CICLO SABATINO JR - 2026': 'AUL003',
    'CICLO ESCOLAR DIARIO': 'AUL004',
    'CICLO BECA 18': 'AUL005',
    'DOCENTES': 'AUL006',
    'CICLO SEMIANUAL 1 - 2026': 'AUL001',
    'CICLO ESCOLAR INTERDIARIO': 'AUL012',
}

SALON_ID_MAP = {
    22: 'AUL008',
    23: 'AUL001',
    25: 'AUL009',
    32: 'AUL010',
    34: 'AUL011',
    26: 'AUL002',
    27: 'AUL003',
    33: 'AUL007',
    29: 'AUL012',
    30: 'AUL005',
    31: 'AUL006',
}

REGISTRADOR_FALLBACK = {
    1: '72618032',
    10: '10033907',
    11: '41591259',
}

MENS_PARAM_ORDER = [
    'IdUsuario', 'IdPlan', 'EstadoMiembro', 'FechaInicio', 'FechaFin',
    'MontoTotal', 'PagoInicial', 'IdMetodoPago', 'IdAula', 'IdTutor',
    'Observaciones', 'FechaCancelacion', 'RegistradoPor',
]


def load_membresias(path: Path) -> list[dict]:
    raw = path.read_text(encoding='utf-8').strip()
    chunks = re.split(r'\}\s*\{', raw)
    items: list[dict] = []
    for i, chunk in enumerate(chunks):
        if i == 0:
            text = chunk + '}'
        elif i == len(chunks) - 1:
            text = '{' + chunk
        else:
            text = '{' + chunk + '}'
        items.extend(json.loads(text).get('content', []))
    return items


def parse_date(val) -> date | None:
    if not val:
        return None
    return datetime.strptime(str(val)[:10], '%Y-%m-%d').date()


def fmt_fecha_ddmmyyyy(val) -> str | None:
    d = parse_date(val)
    return d.strftime('%d%m%Y') if d else None


def is_vigente(m: dict, today: date) -> bool:
    if m.get('fecha_cancelacion'):
        return False
    fin = parse_date(m.get('fecha_fin'))
    return fin is not None and fin >= today


def membresia_score(m: dict) -> tuple:
    monto = float(m.get('monto_total') or 0)
    pagado = float(m.get('total_pagado') or 0)
    return (monto, pagado)


def dedupe_vigentes(vigentes: list[dict]) -> list[dict]:
    by_id: dict[int, dict] = {}
    for m in vigentes:
        mid = int(m['id'])
        if mid not in by_id or membresia_score(m) > membresia_score(by_id[mid]):
            by_id[mid] = m
    return sorted(by_id.values(), key=lambda x: int(x['id']))


def norm_salon_name(name) -> str:
    if not name:
        return ''
    s = str(name).strip().upper()
    for a, b in zip('ÓÁÉÍÚ', 'OAEIU'):
        s = s.replace(a, b)
    return s


def map_aula(m: dict) -> str | None:
    salon_id = m.get('salon')
    if salon_id in SALON_ID_MAP:
        return SALON_ID_MAP[salon_id]
    name = norm_salon_name(m.get('salonNombre'))
    for k, v in SALON_NAME_MAP.items():
        if norm_salon_name(k) == name:
            return v
    return None


def map_plan(plan: str) -> str:
    if plan not in PLAN_MAP:
        raise KeyError(f'Plan sin mapeo: {plan}')
    return PLAN_MAP[plan]


def mensualidad_id(old_id: int) -> str:
    return f'MEM{int(old_id):06d}'


def pago_id(old_id: int) -> str:
    return f'PAG{int(old_id):06d}'


def map_registrador(old_id, id_to_dni: dict[int, str]) -> str | None:
    if old_id is None:
        return None
    return id_to_dni.get(int(old_id))


def build_observaciones(m: dict) -> str:
    parts = [f"Import legacy membresia #{m.get('id')}"]
    asesor = (m.get('asesor') or '').strip()
    if asesor:
        parts.append(f'Asesor: {asesor}')
    tipo = (m.get('tipo') or '').strip()
    if tipo:
        parts.append(f'Tipo: {tipo}')
    return ' | '.join(parts)


def load_db_state(cursor) -> dict:
    cursor.execute('SELECT IDMENSUALIDAD FROM MENSUALIDAD')
    mem_ids = {row[0] for row in cursor.fetchall()}

    cursor.execute(
        "SELECT IDUSUARIO, FECHAINICIO, FECHAFIN FROM MENSUALIDAD WHERE ESTADO = 'Activo'"
    )
    mem_combo = {(row[0], row[1], row[2]) for row in cursor.fetchall()}

    cursor.execute('SELECT IDPAGOMENSUALIDAD FROM PAGOMENSUALIDAD')
    pago_ids = {row[0] for row in cursor.fetchall()}

    cursor.execute("SELECT IDUSUARIO FROM USUARIO WHERE IDTIPOUSUARIO = '1'")
    students = {row[0] for row in cursor.fetchall()}

    cursor.execute('SELECT IDUSUARIO FROM USUARIO')
    all_users = {row[0] for row in cursor.fetchall()}

    cursor.execute('SELECT IDPLAN FROM `PLAN`')
    plans = {row[0] for row in cursor.fetchall()}

    return {
        'mem_ids': mem_ids,
        'mem_combo': mem_combo,
        'pago_ids': pago_ids,
        'students': students,
        'all_users': all_users,
        'plans': plans,
    }


def _fetch_out(cursor) -> tuple[int, str]:
    while cursor.nextset():
        pass
    cursor.execute('SELECT @r AS r, @m AS m')
    row = cursor.fetchone()
    return int(row[0] or 0), str(row[1] or '')


def ensure_usuario(cursor, m: dict, dry_run: bool) -> tuple[bool, str]:
    u = m.get('usuario') or {}
    dni = (u.get('dni') or u.get('username') or '').strip()
    if not dni:
        return False, 'sin DNI'
    cursor.execute('SELECT 1 FROM USUARIO WHERE IDUSUARIO = %s LIMIT 1', (dni,))
    if cursor.fetchone():
        return True, 'ok'

    nombre = (u.get('nombres') or u.get('firstName') or '').strip()
    apellido = (u.get('apellidos') or u.get('lastName') or '').strip()
    tel = (u.get('telefono') or '').strip() or None
    tel_apod = (u.get('telefono_apoderado') or '').strip() or None
    email = f'{dni}@import.academia.local'

    if dry_run:
        return True, 'dry-run crear usuario'

    in_vals = [
        nombre, apellido, dni, email, '1', 'Activo',
        None, None, None, None, None, tel, tel_apod,
        None, None, None, None, None,
    ]
    cursor.execute('SET @uid = %s, @ucontra = %s, @r = 0, @m = ""', (dni, dni))
    ph = ', '.join(['%s'] * len(in_vals))
    cursor.execute(f'CALL usp_usuario_insertar(@uid, @ucontra, {ph}, @r, @m)', in_vals)
    r, msg = _fetch_out(cursor)
    return r == 1, msg


def insert_mensualidad_direct(cursor, mid: str, m: dict, dni: str, plan: str, aula: str | None, reg: str | None):
    monto = float(m.get('monto_total') or 0)
    obs = build_observaciones(m)
    fi = fmt_fecha_ddmmyyyy(m.get('fecha_inicio'))
    ff = fmt_fecha_ddmmyyyy(m.get('fecha_fin'))
    cursor.execute(
        """
        INSERT INTO MENSUALIDAD (
            IDMENSUALIDAD, FECHAINICIO, FECHAFIN, ESTADOMIEMBRO, MONTOTOTAL, OBSERVACIONES,
            FECHAREGISTRO, HORAREGISTRO, IDPLAN, IDAULA, IDTURNO, IDUSUARIO, REGISTRADOPOR,
            IDTUTOR, FECHACANCELACION, ESTADO
        )
        SELECT
            %s, %s, %s, 2, %s, %s,
            fn_fecha_ddmmyyyy(), TIME_FORMAT(NOW(), '%%H:%%i:%%s'),
            %s, %s, p.IDTURNO, %s, %s,
            NULL, NULL, 'Activo'
        FROM `PLAN` p WHERE p.IDPLAN = %s
        """,
        (mid, fi, ff, monto, obs, plan, aula, dni, reg, plan),
    )


def call_mensualidad_insertar(cursor, mid: str, m: dict, dni: str, plan: str, aula: str | None, reg: str | None):
    in_vals = [
        dni, plan, 2,
        fmt_fecha_ddmmyyyy(m.get('fecha_inicio')),
        fmt_fecha_ddmmyyyy(m.get('fecha_fin')),
        float(m.get('monto_total') or 0),
        0, None, aula, None,
        build_observaciones(m), None, reg,
    ]
    cursor.execute('SET @id = %s, @r = 0, @m = ""', (mid,))
    ph = ', '.join(['%s'] * len(in_vals))
    cursor.execute(f'CALL usp_mensualidad_insertar(@id, {ph}, @r, @m)', in_vals)
    return _fetch_out(cursor)


def import_mensualidades(cursor, vigentes: list[dict], state: dict, id_to_dni: dict, dry_run: bool) -> dict:
    stats = {'ok': 0, 'skip': 0, 'fail': 0, 'user_created': 0}
    for m in vigentes:
        old_id = int(m['id'])
        mid = mensualidad_id(old_id)
        u = m.get('usuario') or {}
        dni = (u.get('dni') or u.get('username') or '').strip()
        fi = fmt_fecha_ddmmyyyy(m.get('fecha_inicio'))
        ff = fmt_fecha_ddmmyyyy(m.get('fecha_fin'))

        if mid in state['mem_ids']:
            stats['skip'] += 1
            continue
        if dni and (dni, fi, ff) in state['mem_combo']:
            stats['skip'] += 1
            print(f'  SKIP {mid} duplicado por usuario/fechas ({dni})')
            continue

        try:
            plan = map_plan(m.get('plan'))
        except KeyError as exc:
            stats['fail'] += 1
            print(f'  ERROR {mid}: {exc}', file=sys.stderr)
            continue

        if plan not in state['plans']:
            stats['fail'] += 1
            print(f'  ERROR {mid}: plan {plan} no existe en BD', file=sys.stderr)
            continue

        aula = map_aula(m)
        reg = map_registrador(m.get('registrada_por') or m.get('registradaPor'), id_to_dni)

        if not dni:
            stats['fail'] += 1
            print(f'  ERROR {mid}: sin DNI de estudiante', file=sys.stderr)
            continue

        if dni not in state['all_users']:
            ok_user, msg_user = ensure_usuario(cursor, m, dry_run)
            if not ok_user:
                stats['fail'] += 1
                print(f'  ERROR {mid}: no se pudo crear usuario {dni}: {msg_user}', file=sys.stderr)
                continue
            stats['user_created'] += 1
            state['all_users'].add(dni)
            state['students'].add(dni)

        if dry_run:
            stats['ok'] += 1
            continue

        try:
            if dni in state['students']:
                r, msg = call_mensualidad_insertar(cursor, mid, m, dni, plan, aula, reg)
                if r != 1:
                    stats['fail'] += 1
                    print(f'  ERROR {mid} SP: {msg}', file=sys.stderr)
                    continue
            else:
                insert_mensualidad_direct(cursor, mid, m, dni, plan, aula, reg)

            state['mem_ids'].add(mid)
            state['mem_combo'].add((dni, fi, ff))
            stats['ok'] += 1
            nombre = f"{u.get('nombres', '')} {u.get('apellidos', '')}".strip()
            print(f'  OK {mid} {nombre} ({dni})')
        except pymysql.err.MySQLError as exc:
            stats['fail'] += 1
            msg = exc.args[1] if len(exc.args) > 1 else str(exc)
            print(f'  ERROR {mid}: {msg[:200]}', file=sys.stderr)

    return stats


def import_pagos(cursor, pagos: list[dict], vig_ids: set[int], state: dict, id_to_dni: dict, dry_run: bool) -> dict:
    stats = {'ok': 0, 'skip': 0, 'fail': 0}
    filtrados = sorted(
        [
            p for p in pagos
            if p.get('membresia') in vig_ids and float(p.get('monto_pagado') or 0) > 0
        ],
        key=lambda x: (x.get('fecha_pago') or '', int(x.get('id') or 0)),
    )

    for p in filtrados:
        pid = pago_id(int(p['id']))
        mid = mensualidad_id(int(p['membresia']))
        monto = float(p.get('monto_pagado') or 0)

        if pid in state['pago_ids']:
            stats['skip'] += 1
            continue
        if mid not in state['mem_ids']:
            stats['skip'] += 1
            continue

        reg = map_registrador((p.get('registrado_por') or {}).get('id'), id_to_dni)
        fecha = fmt_fecha_ddmmyyyy(p.get('fecha_pago'))
        obs = p.get('observaciones') or f"Import legacy pago #{p.get('id')} membresia #{p.get('membresia')}"

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
                (pid, monto, fecha, obs, mid, reg),
            )
            state['pago_ids'].add(pid)
            stats['ok'] += 1
        except pymysql.err.MySQLError as exc:
            stats['fail'] += 1
            msg = exc.args[1] if len(exc.args) > 1 else str(exc)
            print(f'  ERROR pago {pid}: {msg[:200]}', file=sys.stderr)

    return stats


def build_id_to_dni(vigentes: list[dict]) -> dict[int, str]:
    mapping = dict(REGISTRADOR_FALLBACK)
    for m in vigentes:
        u = m.get('usuario') or {}
        uid = u.get('id')
        dni = (u.get('dni') or u.get('username') or '').strip()
        if uid is not None and dni:
            mapping[int(uid)] = dni
    return mapping


def main():
    parser = argparse.ArgumentParser(description='Importar mensualidades vigentes faltantes')
    parser.add_argument('--mensualidades', type=Path, default=DATA_DIR / 'mensualidades_ultimo.txt')
    parser.add_argument('--pagos', type=Path, default=DATA_DIR / 'pagos.txt')
    parser.add_argument('--dry-run', action='store_true')
    parser.add_argument('--only', choices=['mensualidades', 'pagos'])
    args = parser.parse_args()

    if not args.mensualidades.exists():
        print(f'ERROR: no existe {args.mensualidades}', file=sys.stderr)
        sys.exit(1)
    if not args.pagos.exists():
        print(f'ERROR: no existe {args.pagos}', file=sys.stderr)
        sys.exit(1)

    today = date.today()
    membresias = load_membresias(args.mensualidades)
    vigentes = dedupe_vigentes([m for m in membresias if is_vigente(m, today)])
    vig_ids = {int(m['id']) for m in vigentes}
    id_to_dni = build_id_to_dni(vigentes)
    pagos = json.loads(args.pagos.read_text(encoding='utf-8'))

    print(f'Archivo: {len(membresias)} filas | vigentes únicas: {len(vigentes)} | hoy: {today.isoformat()}')

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
            state = load_db_state(cur)
            print(
                f'BD actual: mensualidades={len(state["mem_ids"])} '
                f'pagos={len(state["pago_ids"])} estudiantes={len(state["students"])}'
            )

            if args.only != 'pagos':
                print('>>> Mensualidades faltantes')
                stats_m = import_mensualidades(cur, vigentes, state, id_to_dni, args.dry_run)
                print(
                    f'    ok={stats_m["ok"]} skip={stats_m["skip"]} fail={stats_m["fail"]} '
                    f'usuarios_creados={stats_m["user_created"]}'
                )
                if not args.dry_run:
                    conn.commit()

            if args.only != 'mensualidades':
                state = load_db_state(cur)
                print('>>> Pagos faltantes (solo membresías vigentes en BD)')
                stats_p = import_pagos(cur, pagos, vig_ids, state, id_to_dni, args.dry_run)
                print(f'    ok={stats_p["ok"]} skip={stats_p["skip"]} fail={stats_p["fail"]}')
                if not args.dry_run:
                    conn.commit()

            if not args.dry_run:
                cur.execute('SELECT COUNT(*) FROM MENSUALIDAD')
                total_m = cur.fetchone()[0]
                cur.execute('SELECT COUNT(*) FROM PAGOMENSUALIDAD')
                total_p = cur.fetchone()[0]
                print(f'Total BD: mensualidades={total_m} pagos={total_p}')
    finally:
        conn.close()


if __name__ == '__main__':
    main()
