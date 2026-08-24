"""
Vacía estudiantes + mensualidades + pagos e importa TODO el dump VITA.

Origen (PostgreSQL custom dump):
  users_usuario            -> USUARIO
  membresias_membresia     -> MENSUALIDAD
  membresias_pagomembresia -> PAGOMENSUALIDAD

Las mensualidades importadas NO generan cuotas (solo las nuevas del sistema).

Uso (desde Backend/, venv activo, túnel MySQL si aplica):
  python scripts/import_vita_dump_completo.py --dry-run
  python scripts/import_vita_dump_completo.py --wipe
"""
from __future__ import annotations

import argparse
import os
import subprocess
import sys
from datetime import date, datetime
from pathlib import Path

import pymysql
from dotenv import load_dotenv

from import_mensualidades_faltantes_mysql import (
    REGISTRADOR_FALLBACK,
    fmt_fecha_ddmmyyyy,
    map_plan,
    mensualidad_id,
    pago_id,
)
from import_vita_postgres_mysql import (
    map_aula_row,
    map_tipo_usuario,
    pick_email,
)
from setup_mysql_db import _connect

BASE = Path(__file__).resolve().parent.parent
DATA_DIR = BASE / 'data'
DEFAULT_DUMP = Path(r'C:\Users\USUARIO\Downloads\vita_bd_backup.dump')
PG_RESTORE = Path(r'C:\Program Files\PostgreSQL\16\bin\pg_restore.exe')
TABLES = (
    'users_usuario',
    'membresias_membresia',
    'membresias_pagomembresia',
    'membresias_salon',
)
WIPE_FULL = (
    'PAGOMENSUALIDAD',
    'MENSUALIDAD_CUOTA',
    'NOTIFICACIONMENSUALIDAD',
    'MENSUALIDAD',
)


def _unescape_copy(value: str):
    if value == r'\N':
        return None
    out = []
    i = 0
    n = len(value)
    while i < n:
        ch = value[i]
        if ch != '\\' or i + 1 >= n:
            out.append(ch)
            i += 1
            continue
        nxt = value[i + 1]
        mapping = {'\\': '\\', 'b': '\b', 'f': '\f', 'n': '\n', 'r': '\r', 't': '\t', 'v': '\v'}
        if nxt in mapping:
            out.append(mapping[nxt])
            i += 2
            continue
        if nxt in '01234567':
            j = i + 1
            octal = []
            while j < n and value[j] in '01234567' and len(octal) < 3:
                octal.append(value[j])
                j += 1
            out.append(chr(int(''.join(octal), 8)))
            i = j
            continue
        out.append(nxt)
        i += 2
    return ''.join(out)


def parse_copy_file(path: Path) -> dict[str, list[dict]]:
    tables: dict[str, list[dict]] = {t: [] for t in TABLES}
    current = None
    columns: list[str] = []
    with path.open('r', encoding='utf-8', errors='replace') as fh:
        for raw in fh:
            line = raw.rstrip('\n')
            if line.startswith('\\'):
                if line.startswith('\\restrict') or line.startswith('\\unrestrict'):
                    continue
                if line == '\\.' :
                    current = None
                    columns = []
                continue
            if line.startswith('COPY '):
                # COPY public.users_usuario (id, password, ...) FROM stdin;
                name = line.split()[1].split('.')[-1]
                cols_part = line[line.find('(') + 1: line.rfind(')')]
                columns = [c.strip() for c in cols_part.split(',')]
                current = name if name in tables else None
                continue
            if current is None or not line:
                continue
            fields = [_unescape_copy(p) for p in line.split('\t')]
            if len(fields) != len(columns):
                print(f'  WARN {current}: {len(fields)} campos vs {len(columns)} columnas', file=sys.stderr)
                continue
            tables[current].append(dict(zip(columns, fields)))
    return tables


def extract_from_dump(dump: Path, out_sql: Path) -> None:
    if not PG_RESTORE.exists():
        print(f'ERROR: no está pg_restore en {PG_RESTORE}', file=sys.stderr)
        sys.exit(1)
    if not dump.exists():
        print(f'ERROR: no existe el dump: {dump}', file=sys.stderr)
        sys.exit(1)
    out_sql.parent.mkdir(parents=True, exist_ok=True)
    args = [str(PG_RESTORE), '-a', '-n', 'public', '-f', str(out_sql)]
    for t in TABLES:
        args.extend(['-t', t])
    args.append(str(dump))
    subprocess.check_call(args)


def table_exists(cursor, name: str) -> bool:
    cursor.execute(
        """
        SELECT COUNT(*) FROM information_schema.TABLES
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = %s
        """,
        (name,),
    )
    return int(cursor.fetchone()[0] or 0) > 0


def table_columns(cursor, name: str) -> set[str]:
    cursor.execute(
        """
        SELECT COLUMN_NAME FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = %s
        """,
        (name,),
    )
    return {r[0] for r in cursor.fetchall()}


def fks_to(cursor, ref_table: str, ref_col: str) -> list[tuple[str, str]]:
    cursor.execute(
        """
        SELECT TABLE_NAME, COLUMN_NAME
        FROM information_schema.KEY_COLUMN_USAGE
        WHERE TABLE_SCHEMA = DATABASE()
          AND REFERENCED_TABLE_NAME = %s
          AND REFERENCED_COLUMN_NAME = %s
        """,
        (ref_table, ref_col),
    )
    return [(r[0], r[1]) for r in cursor.fetchall()]


def _delete_in_chunks(cursor, table: str, column: str, ids: list[str]) -> int:
    if not ids or not table_exists(cursor, table):
        return 0
    total = 0
    for i in range(0, len(ids), 400):
        chunk = ids[i:i + 400]
        marcas = ','.join(['%s'] * len(chunk))
        cursor.execute(
            f'DELETE FROM `{table}` WHERE `{column}` IN ({marcas})',
            chunk,
        )
        total += cursor.rowcount or 0
    return total


def wipe_estudiantes(cursor) -> None:
    print('>>> VACIANDO pagos, mensualidades y estudiantes')
    cursor.execute('SET FOREIGN_KEY_CHECKS = 0')
    try:
        for table in WIPE_FULL:
            if table_exists(cursor, table):
                cursor.execute(f'DELETE FROM `{table}`')
                print(f'    {table}: {cursor.rowcount} filas')

        for table, col in fks_to(cursor, 'MENSUALIDAD', 'IDMENSUALIDAD'):
            if table in WIPE_FULL:
                continue
            if table_exists(cursor, table):
                cursor.execute(f'DELETE FROM `{table}`')
                print(f'    {table} (FK mensualidad): {cursor.rowcount} filas')

        cursor.execute("SELECT IDUSUARIO FROM USUARIO WHERE IDTIPOUSUARIO = '1'")
        student_ids = [r[0] for r in cursor.fetchall()]
        print(f'    estudiantes a eliminar: {len(student_ids)}')
        for table, col in fks_to(cursor, 'USUARIO', 'IDUSUARIO'):
            if table == 'USUARIO':
                continue
            n = _delete_in_chunks(cursor, table, col, student_ids)
            if n:
                print(f'    {table}.{col}: {n} filas')
        cursor.execute("DELETE FROM USUARIO WHERE IDTIPOUSUARIO = '1'")
        print(f'    USUARIO estudiantes: {cursor.rowcount} filas')
    finally:
        cursor.execute('SET FOREIGN_KEY_CHECKS = 1')


def _parse_dt(val) -> datetime | None:
    if not val:
        return None
    s = str(val).strip().replace('T', ' ')
    if s.endswith('+00'):
        s = s + ':00'
    if s.endswith('Z'):
        s = s[:-1] + '+00:00'
    try:
        return datetime.fromisoformat(s)
    except ValueError:
        pass
    for fmt in ('%Y-%m-%d %H:%M:%S.%f', '%Y-%m-%d %H:%M:%S', '%Y-%m-%d'):
        try:
            return datetime.strptime(s[:26], fmt)
        except ValueError:
            continue
    return None


def _hora(val) -> str:
    dt = _parse_dt(val)
    if dt:
        return dt.strftime('%H:%M:%S')
    return '08:00:00'


def map_plan_safe(plan: str, plans: set[str], warnings: list[str]) -> str:
    pid = None
    try:
        pid = map_plan(plan)
    except KeyError:
        pid = None
    if pid and pid in plans:
        return pid
    fallback = 'PLN001' if 'PLN001' in plans else next(iter(sorted(plans)))
    warnings.append(f'plan "{plan}" -> {fallback}')
    return fallback


def usuario_key(row: dict) -> str:
    dni = (row.get('dni') or '').strip()
    username = (row.get('username') or '').strip()
    if dni:
        return dni
    if username:
        return username[:50]
    return f"IMP{int(row['id']):06d}"


def insert_dict(cursor, table: str, data: dict, allowed: set[str]) -> None:
    payload = {k: v for k, v in data.items() if k in allowed}
    cols = ', '.join(f'`{c}`' for c in payload)
    ph = ', '.join(['%s'] * len(payload))
    cursor.execute(f'INSERT INTO `{table}` ({cols}) VALUES ({ph})', list(payload.values()))


def import_usuarios(cursor, users: list[dict], cols: set[str], dry_run: bool) -> dict:
    stats = {'ok': 0, 'skip': 0, 'fail': 0}
    used_emails: set[str] = set()
    cursor.execute('SELECT LOWER(EMAIL) FROM USUARIO')
    used_emails.update(r[0] for r in cursor.fetchall() if r[0])
    hoy = date.today().strftime('%d%m%Y')

    for row in users:
        dni = usuario_key(row)
        cursor.execute(
            'SELECT 1 FROM USUARIO WHERE IDUSUARIO = %s OR DNI = %s LIMIT 1',
            (dni, dni),
        )
        if cursor.fetchone():
            stats['skip'] += 1
            continue

        tipo = map_tipo_usuario(row.get('rol'), boolish(row.get('is_staff')), boolish(row.get('is_superuser')))
        activo = str(row.get('is_active') or 't').lower() in ('t', 'true', '1')
        estado = 'Activo' if activo else 'Retirado'
        email = pick_email(row, used_emails)
        contra = dni if tipo == '1' else (dni or '12345678')
        payload = {
            'IDUSUARIO': dni,
            'CONTRA': contra,
            'NOMBRE': (row.get('nombres') or row.get('first_name') or '').strip() or 'SIN NOMBRE',
            'APELLIDO': (row.get('apellidos') or row.get('last_name') or '').strip() or 'SIN APELLIDO',
            'DNI': (row.get('dni') or dni)[:20],
            'EMAIL': email[:150],
            'IDTIPOUSUARIO': tipo,
            'ESTADO': estado,
            'FECHANACIMIENTO': fmt_fecha_ddmmyyyy(row.get('fecha_nacimiento')),
            'DIRECCION': (row.get('direccion') or '').strip() or None,
            'DISTRITO': (row.get('distrito') or '').strip() or None,
            'COLEGIO': (row.get('colegio') or row.get('nombre_colegio') or '').strip() or None,
            'GRADO': (row.get('grado') or '').strip() or None,
            'TELPERSONAL': (row.get('telefono') or '').strip() or None,
            'TELAPODERADO': (row.get('telefono_apoderado') or '').strip() or None,
            'SITUACIONACADEMICA': (row.get('situacion_academica') or '').strip() or None,
            'COMOENTERO': (row.get('modo') or '').strip() or None,
            'FOTO': (row.get('foto_perfil') or '').strip() or None,
            'FECHAACTIVO': hoy,
        }
        if dry_run:
            stats['ok'] += 1
            continue
        try:
            insert_dict(cursor, 'USUARIO', payload, cols)
            stats['ok'] += 1
        except pymysql.err.MySQLError as exc:
            stats['fail'] += 1
            detail = exc.args[1] if len(exc.args) > 1 else str(exc)
            print(f'  ERROR usuario {dni}: {detail[:200]}', file=sys.stderr)
    return stats


def import_mensualidades(cursor, rows, id_to_dni, state, cols, dry_run, warnings) -> dict:
    stats = {'ok': 0, 'fail': 0}
    today = date.today()
    for row in rows:
        mid = mensualidad_id(int(row['id']))
        uid_old = row.get('usuario_id')
        dni = id_to_dni.get(int(uid_old)) if uid_old else None
        if not dni:
            stats['fail'] += 1
            print(f'  ERROR {mid}: sin estudiante (usuario_id={uid_old})', file=sys.stderr)
            continue
        if dni not in state['all_users']:
            stats['fail'] += 1
            print(f'  ERROR {mid}: estudiante {dni} no está en USUARIO', file=sys.stderr)
            continue

        fi = fmt_fecha_ddmmyyyy(row.get('fecha_inicio')) or today.strftime('%d%m%Y')
        ff = fmt_fecha_ddmmyyyy(row.get('fecha_fin')) or today.strftime('%d%m%Y')
        plan = map_plan_safe(row.get('plan') or '', state['plans'], warnings)
        aula = None
        if row.get('salon_id'):
            aula = map_aula_row(int(row['salon_id']), row.get('salon_nombre'))
        if aula and aula not in state.get('aulas', set()):
            aula = None
        reg = None
        if row.get('registrada_por_id'):
            reg = id_to_dni.get(int(row['registrada_por_id']))
            if reg and reg not in state['all_users']:
                reg = None
        fin = fmt_fecha_ddmmyyyy(row.get('fecha_fin'))
        cancel = row.get('fecha_cancelacion')
        estado_m = 3 if (fin and datetime.strptime(fin, '%d%m%Y').date() < today) else 2
        fr_dt = _parse_dt(row.get('fecha_registro'))
        fr = fr_dt.strftime('%d%m%Y') if fr_dt else today.strftime('%d%m%Y')
        obs_parts = [f"Import VITA membresia #{row.get('id')}"]
        for label, key in (('Asesor', 'asesor'), ('Tipo', 'tipo'), ('Tipo pago', 'tipo_pago'), ('Ciclo', 'ciclo')):
            val = row.get(key)
            if val:
                obs_parts.append(f'{label}: {val}')
        if row.get('observaciones'):
            obs_parts.append(str(row['observaciones']).strip())
        payload = {
            'IDMENSUALIDAD': mid,
            'FECHAINICIO': fi,
            'FECHAFIN': ff,
            'ESTADOMIEMBRO': estado_m,
            'MONTOTOTAL': float(row.get('monto_total') or 0),
            'OBSERVACIONES': ' | '.join(obs_parts),
            'FECHAREGISTRO': fr,
            'HORAREGISTRO': _hora(row.get('fecha_registro')),
            'IDPLAN': plan,
            'IDAULA': aula,
            'IDTURNO': state['plan_turno'].get(plan),
            'IDUSUARIO': dni,
            'REGISTRADOPOR': reg,
            'IDTUTOR': None,
            'FECHACANCELACION': fmt_fecha_ddmmyyyy(cancel),
            'ESTADO': 'Activo',
            'TUTORLEGACY': (row.get('asesor') or '').strip() or None,
            'TIPOMENSUALIDAD': (row.get('tipo') or '').strip() or None,
        }
        if dry_run:
            stats['ok'] += 1
            continue
        try:
            insert_dict(cursor, 'MENSUALIDAD', payload, cols)
            state['mem_ids'].add(mid)
            stats['ok'] += 1
        except pymysql.err.MySQLError as exc:
            stats['fail'] += 1
            detail = exc.args[1] if len(exc.args) > 1 else str(exc)
            print(f'  ERROR {mid}: {detail[:220]}', file=sys.stderr)
    return stats


def import_pagos(cursor, rows, id_to_dni, state, cols, dry_run) -> dict:
    stats = {'ok': 0, 'fail': 0, 'skip': 0}
    metodo = 'MPG001' if 'MPG001' in state.get('metodos', {'MPG001'}) else next(iter(state.get('metodos') or ['MPG001']))
    for row in rows:
        pid = pago_id(int(row['id']))
        mid = mensualidad_id(int(row['membresia_id']))
        if mid not in state['mem_ids']:
            stats['fail'] += 1
            print(f'  ERROR {pid}: mensualidad {mid} no existe', file=sys.stderr)
            continue
        fp = fmt_fecha_ddmmyyyy(row.get('fecha_pago')) or date.today().strftime('%d%m%Y')
        reg = None
        if row.get('registrado_por_id'):
            reg = id_to_dni.get(int(row['registrado_por_id']))
            if reg and reg not in state['all_users']:
                reg = None
        payload = {
            'IDPAGOMENSUALIDAD': pid,
            'MONTO': float(row.get('monto_pagado') or 0),
            'MORA': 0,
            'FECHAPAGO': fp,
            'HORAPAGO': '08:00:00',
            'OBSERVACIONES': (row.get('observaciones') or f"Import VITA pago #{row.get('id')}"),
            'IDMENSUALIDAD': mid,
            'IDMETODOPAGO': metodo,
            'IDUSUARIO': reg,
            'IDCUOTA': None,
        }
        if dry_run:
            stats['ok'] += 1
            continue
        try:
            insert_dict(cursor, 'PAGOMENSUALIDAD', payload, cols)
            stats['ok'] += 1
        except pymysql.err.MySQLError as exc:
            stats['fail'] += 1
            detail = exc.args[1] if len(exc.args) > 1 else str(exc)
            print(f'  ERROR {pid}: {detail[:220]}', file=sys.stderr)
    return stats


def load_state(cursor) -> dict:
    cursor.execute('SELECT IDMENSUALIDAD FROM MENSUALIDAD')
    mem_ids = {r[0] for r in cursor.fetchall()}
    cursor.execute('SELECT IDUSUARIO FROM USUARIO')
    all_users = {r[0] for r in cursor.fetchall()}
    cursor.execute('SELECT IDPLAN, IDTURNO FROM `PLAN`')
    plan_rows = cursor.fetchall()
    plans = {r[0] for r in plan_rows}
    plan_turno = {r[0]: r[1] for r in plan_rows}
    aulas = set()
    if table_exists(cursor, 'AULA'):
        cursor.execute('SELECT IDAULA FROM AULA')
        aulas = {r[0] for r in cursor.fetchall()}
    metodos = set()
    if table_exists(cursor, 'METODO_PAGO'):
        cursor.execute('SELECT IDMETODOPAGO FROM METODO_PAGO')
        metodos = {r[0] for r in cursor.fetchall()}
    return {
        'mem_ids': mem_ids,
        'all_users': all_users,
        'plans': plans,
        'plan_turno': plan_turno,
        'aulas': aulas,
        'metodos': metodos,
    }


def boolish(val) -> bool:
    return str(val or '').strip().lower() in ('t', 'true', '1', 'yes')


def sql_str(val) -> str:
    if val is None or val == '':
        return 'NULL'
    s = str(val).replace('\\', '\\\\').replace("'", "''")
    return f"'{s}'"


def sql_num(val) -> str:
    if val is None or val == '':
        return '0'
    return f'{float(val):.2f}'


def export_navicat_sql(path: Path, users, membresias, pagos, salones, id_to_dni) -> None:
    today = date.today()
    lines = [
        '-- Import VITA -> AcademiaDB (USUARIO, MENSUALIDAD, PAGOMENSUALIDAD)',
        '-- No genera cuotas. Ejecutar en Navicat sobre AcademiaDB.',
        'USE `AcademiaDB`;',
        'SET NAMES utf8mb4;',
        'SET FOREIGN_KEY_CHECKS = 0;',
        '',
        'DELETE FROM PAGOMENSUALIDAD;',
        'DELETE FROM MENSUALIDAD_CUOTA;',
        'DELETE FROM NOTIFICACIONMENSUALIDAD;',
        'DELETE FROM MENSUALIDAD;',
        "DELETE a FROM ASISTENCIA a INNER JOIN USUARIO u ON u.IDUSUARIO = a.IDUSUARIO AND u.IDTIPOUSUARIO = '1';",
        "DELETE j FROM JUSTIFICACION j INNER JOIN USUARIO u ON u.IDUSUARIO = j.IDUSUARIO AND u.IDTIPOUSUARIO = '1';",
        "DELETE p FROM PAGOEXTRAORDINARIO p INNER JOIN USUARIO u ON u.IDUSUARIO = p.IDUSUARIO AND u.IDTIPOUSUARIO = '1';",
        "DELETE um FROM USUARIO_MODULO um INNER JOIN USUARIO u ON u.IDUSUARIO = um.IDUSUARIO AND u.IDTIPOUSUARIO = '1';",
        "DELETE FROM USUARIO WHERE IDTIPOUSUARIO = '1';",
        '',
        '-- USUARIO',
    ]
    used_emails: set[str] = set()
    for row in users:
        dni = usuario_key(row)
        tipo = map_tipo_usuario(row.get('rol'), boolish(row.get('is_staff')), boolish(row.get('is_superuser')))
        estado = 'Activo' if boolish(row.get('is_active')) else 'Retirado'
        email = pick_email(row, used_emails)
        nombre = (row.get('nombres') or row.get('first_name') or '').strip() or 'SIN NOMBRE'
        apellido = (row.get('apellidos') or row.get('last_name') or '').strip() or 'SIN APELLIDO'
        colegio = (row.get('colegio') or row.get('nombre_colegio') or '').strip() or None
        lines.append(
            'INSERT IGNORE INTO USUARIO ('
            'IDUSUARIO, CONTRA, NOMBRE, APELLIDO, DNI, EMAIL, IDTIPOUSUARIO, ESTADO, '
            'FECHANACIMIENTO, DIRECCION, DISTRITO, COLEGIO, GRADO, TELPERSONAL, TELAPODERADO, '
            'SITUACIONACADEMICA, COMOENTERO, FECHAACTIVO, FOTO'
            ') VALUES ('
            f'{sql_str(dni)}, {sql_str(dni)}, {sql_str(nombre)}, {sql_str(apellido)}, '
            f'{sql_str((row.get("dni") or dni)[:20])}, {sql_str(email[:150])}, {sql_str(tipo)}, {sql_str(estado)}, '
            f'{sql_str(fmt_fecha_ddmmyyyy(row.get("fecha_nacimiento")))}, '
            f'{sql_str((row.get("direccion") or "").strip() or None)}, '
            f'{sql_str((row.get("distrito") or "").strip() or None)}, '
            f'{sql_str(colegio)}, {sql_str((row.get("grado") or "").strip() or None)}, '
            f'{sql_str((row.get("telefono") or "").strip() or None)}, '
            f'{sql_str((row.get("telefono_apoderado") or "").strip() or None)}, '
            f'{sql_str((row.get("situacion_academica") or "").strip() or None)}, '
            f'{sql_str((row.get("modo") or "").strip() or None)}, '
            f'{sql_str(today.strftime("%d%m%Y"))}, '
            f'{sql_str((row.get("foto_perfil") or "").strip() or None)}'
            ');'
        )

    lines += ['', '-- MENSUALIDAD (sin cuotas)']
    for row in membresias:
        mid = mensualidad_id(int(row['id']))
        dni = id_to_dni.get(int(row['usuario_id'])) if row.get('usuario_id') else None
        if not dni:
            continue
        try:
            plan = map_plan(row.get('plan') or '')
        except KeyError:
            plan = 'PLN001'
        aula = None
        if row.get('salon_id'):
            aula = map_aula_row(int(row['salon_id']), (salones.get(int(row['salon_id'])) or {}).get('nombre'))
        reg = id_to_dni.get(int(row['registrada_por_id'])) if row.get('registrada_por_id') else None
        fi = fmt_fecha_ddmmyyyy(row.get('fecha_inicio')) or today.strftime('%d%m%Y')
        ff = fmt_fecha_ddmmyyyy(row.get('fecha_fin')) or today.strftime('%d%m%Y')
        estado_m = 3 if datetime.strptime(ff, '%d%m%Y').date() < today else 2
        fr_dt = _parse_dt(row.get('fecha_registro'))
        fr = fr_dt.strftime('%d%m%Y') if fr_dt else today.strftime('%d%m%Y')
        obs_parts = [f"Import VITA membresia #{row.get('id')}"]
        for label, key in (('Asesor', 'asesor'), ('Tipo', 'tipo'), ('Tipo pago', 'tipo_pago'), ('Ciclo', 'ciclo')):
            if row.get(key):
                obs_parts.append(f'{label}: {row.get(key)}')
        if row.get('observaciones'):
            obs_parts.append(str(row['observaciones']).strip())
        lines.append(
            'INSERT INTO MENSUALIDAD ('
            'IDMENSUALIDAD, FECHAINICIO, FECHAFIN, ESTADOMIEMBRO, MONTOTOTAL, OBSERVACIONES, '
            'FECHAREGISTRO, HORAREGISTRO, IDPLAN, IDAULA, IDTURNO, IDUSUARIO, REGISTRADOPOR, '
            'IDTUTOR, FECHACANCELACION, ESTADO, TUTORLEGACY, TIPOMENSUALIDAD'
            ') SELECT '
            f'{sql_str(mid)}, {sql_str(fi)}, {sql_str(ff)}, {estado_m}, {sql_num(row.get("monto_total"))}, '
            f'{sql_str(" | ".join(obs_parts))}, {sql_str(fr)}, {sql_str(_hora(row.get("fecha_registro")))}, '
            f'{sql_str(plan)}, {sql_str(aula)}, p.IDTURNO, {sql_str(dni)}, {sql_str(reg)}, '
            f'NULL, {sql_str(fmt_fecha_ddmmyyyy(row.get("fecha_cancelacion")))}, '
            f"'Activo', {sql_str((row.get('asesor') or '').strip() or None)}, "
            f'{sql_str((row.get("tipo") or "").strip() or None)} '
            f'FROM `PLAN` p WHERE p.IDPLAN = {sql_str(plan)};'
        )

    lines += ['', '-- PAGOMENSUALIDAD']
    for row in pagos:
        pid = pago_id(int(row['id']))
        mid = mensualidad_id(int(row['membresia_id']))
        fp = fmt_fecha_ddmmyyyy(row.get('fecha_pago')) or today.strftime('%d%m%Y')
        reg = id_to_dni.get(int(row['registrado_por_id'])) if row.get('registrado_por_id') else None
        obs = row.get('observaciones') or f"Import VITA pago #{row.get('id')}"
        lines.append(
            'INSERT INTO PAGOMENSUALIDAD ('
            'IDPAGOMENSUALIDAD, MONTO, MORA, FECHAPAGO, HORAPAGO, OBSERVACIONES, '
            'IDMENSUALIDAD, IDMETODOPAGO, IDUSUARIO, IDCUOTA'
            ') VALUES ('
            f'{sql_str(pid)}, {sql_num(row.get("monto_pagado"))}, 0, {sql_str(fp)}, \'08:00:00\', '
            f'{sql_str(obs)}, {sql_str(mid)}, \'MPG001\', {sql_str(reg)}, NULL);'
        )

    lines += [
        '',
        'SET FOREIGN_KEY_CHECKS = 1;',
        'SELECT COUNT(*) AS usuarios FROM USUARIO;',
        'SELECT COUNT(*) AS mensualidades FROM MENSUALIDAD;',
        'SELECT COUNT(*) AS pagos FROM PAGOMENSUALIDAD;',
        'SELECT COUNT(*) AS cuotas FROM MENSUALIDAD_CUOTA;',
    ]
    path.write_text('\n'.join(lines) + '\n', encoding='utf-8')
    print(f'SQL Navicat: {path} ({path.stat().st_size} bytes, {len(lines)} sentencias)')


def main():
    parser = argparse.ArgumentParser(description='Importar dump VITA completo a AcademiaDB')
    parser.add_argument('--dump', type=Path, default=DEFAULT_DUMP)
    parser.add_argument('--dry-run', action='store_true')
    parser.add_argument('--wipe', action='store_true', help='Vacía estudiantes, mensualidades y pagos antes de importar')
    parser.add_argument('--extract-only', action='store_true')
    parser.add_argument('--stats-only', action='store_true', help='Solo lee el dump, no conecta a MySQL')
    parser.add_argument('--port', type=int, default=None, help='Override DB_PORT del .env')
    parser.add_argument('--skip-extract', action='store_true', help='Usa data/vita_data.sql si ya existe')
    parser.add_argument('--export-sql', action='store_true', help='Genera SQL para Navicat y no conecta a MySQL')
    args = parser.parse_args()

    load_dotenv(BASE / '.env')
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    data_sql = DATA_DIR / 'vita_data.sql'
    if not (args.skip_extract and data_sql.exists()):
        extract_from_dump(args.dump, data_sql)
    tables = parse_copy_file(data_sql)
    users = tables['users_usuario']
    membresias = tables['membresias_membresia']
    pagos = tables['membresias_pagomembresia']
    salones = {int(s['id']): s for s in tables['membresias_salon'] if s.get('id')}

    print(
        f'Dump: usuarios={len(users)} membresias={len(membresias)} '
        f'pagos={len(pagos)} salones={len(salones)}'
    )

    id_to_dni = dict(REGISTRADOR_FALLBACK)
    for u in users:
        id_to_dni[int(u['id'])] = usuario_key(u)

    sin_dni = [u for u in users if not (u.get('dni') or '').strip()]
    roles = {}
    activos = {'Activo': 0, 'Retirado': 0}
    for u in users:
        rol = (u.get('rol') or '?').strip() or '?'
        roles[rol] = roles.get(rol, 0) + 1
        if boolish(u.get('is_active')):
            activos['Activo'] += 1
        else:
            activos['Retirado'] += 1
    planes = {}
    mem_sin_user = 0
    for m in membresias:
        p = (m.get('plan') or '').strip()
        planes[p] = planes.get(p, 0) + 1
        uid = m.get('usuario_id')
        if not uid or int(uid) not in id_to_dni:
            mem_sin_user += 1
    pag_sin_mem = 0
    mem_ids = {int(m['id']) for m in membresias if m.get('id')}
    for p in pagos:
        mid = p.get('membresia_id')
        if not mid or int(mid) not in mem_ids:
            pag_sin_mem += 1
    print(f'Usuarios sin DNI (se usará username): {len(sin_dni)}')
    print(f'Roles: {roles}')
    print(f'Estados origen: {activos}')
    print(f'Membresías sin usuario: {mem_sin_user}')
    print(f'Pagos sin membresía: {pag_sin_mem}')
    print('Planes en dump:')
    for name, n in sorted(planes.items(), key=lambda x: (-x[1], x[0])):
        try:
            mapped = map_plan(name)
        except KeyError:
            mapped = 'SIN MAPEO'
        print(f'    {n:4d}  {name}  -> {mapped}')
    if args.extract_only or args.stats_only:
        if args.extract_only:
            print(f'Extraído en {data_sql}')
        return

    if args.export_sql:
        out = DATA_DIR / 'vita_import_navicat.sql'
        export_navicat_sql(out, users, membresias, pagos, salones, id_to_dni)
        return

    id_to_dni = dict(REGISTRADOR_FALLBACK)
    for u in users:
        id_to_dni[int(u['id'])] = usuario_key(u)
        u['is_staff'] = 't' if boolish(u.get('is_staff')) else 'f'
        u['is_superuser'] = 't' if boolish(u.get('is_superuser')) else 'f'
        u['is_active'] = 't' if boolish(u.get('is_active')) else 'f'

    for m in membresias:
        sid = m.get('salon_id')
        if sid and int(sid) in salones:
            m['salon_nombre'] = salones[int(sid)].get('nombre')
        uid = m.get('usuario_id')
        m['usuario_dni'] = id_to_dni.get(int(uid)) if uid else None

    mysql_password = os.getenv('DB_PASSWORD', '') or os.getenv('MYSQL_ROOT_PASSWORD', '')
    if not mysql_password:
        print('ERROR: DB_PASSWORD requerido en .env', file=sys.stderr)
        sys.exit(1)

    conn = _connect(
        os.getenv('DB_HOST', '127.0.0.1'),
        int(args.port or os.getenv('DB_PORT', '3306')),
        os.getenv('DB_USER', 'root'),
        mysql_password,
        os.getenv('DB_NAME', 'AcademiaDB'),
    )
    conn.autocommit(False)
    try:
        with conn.cursor() as cur:
            if args.wipe and not args.dry_run:
                wipe_estudiantes(cur)
                conn.commit()

            state = load_state(cur)
            user_cols = table_columns(cur, 'USUARIO')
            mem_cols = table_columns(cur, 'MENSUALIDAD')
            pago_cols = table_columns(cur, 'PAGOMENSUALIDAD')
            warnings: list[str] = []

            print('>>> USUARIO')
            stats_u = import_usuarios(cur, users, user_cols, args.dry_run)
            print(f'    ok={stats_u["ok"]} skip={stats_u["skip"]} fail={stats_u["fail"]}')
            if not args.dry_run:
                conn.commit()
                state = load_state(cur)

            print('>>> MENSUALIDAD (sin generar cuotas)')
            stats_m = import_mensualidades(
                cur, membresias, id_to_dni, state, mem_cols, args.dry_run, warnings,
            )
            print(f'    ok={stats_m["ok"]} fail={stats_m["fail"]}')
            if not args.dry_run:
                conn.commit()
                state = load_state(cur)

            print('>>> PAGOMENSUALIDAD')
            stats_p = import_pagos(cur, pagos, id_to_dni, state, pago_cols, args.dry_run)
            print(f'    ok={stats_p["ok"]} fail={stats_p["fail"]}')
            if not args.dry_run:
                conn.commit()

            if warnings:
                uniq = sorted(set(warnings))
                print(f'Planes sin mapeo exacto ({len(uniq)}), se usó fallback:')
                for w in uniq[:30]:
                    print(f'    {w}')

            if not args.dry_run:
                cur.execute("SELECT COUNT(*) FROM USUARIO WHERE IDTIPOUSUARIO='1'")
                u = cur.fetchone()[0]
                cur.execute('SELECT COUNT(*) FROM MENSUALIDAD')
                m = cur.fetchone()[0]
                cur.execute('SELECT COUNT(*) FROM PAGOMENSUALIDAD')
                p = cur.fetchone()[0]
                cur.execute('SELECT COUNT(*) FROM MENSUALIDAD_CUOTA')
                c = cur.fetchone()[0]
                print(f'BD final: estudiantes={u} mensualidades={m} pagos={p} cuotas={c}')
            else:
                print('Dry-run: no se escribió en MySQL.')
    except Exception:
        conn.rollback()
        raise
    finally:
        conn.close()


if __name__ == '__main__':
    main()
