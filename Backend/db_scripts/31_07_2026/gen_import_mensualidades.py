import json
import os
import re
from datetime import date, datetime
from collections import Counter

MEM_FILE = r'c:\Users\USUARIO\Downloads\memebresias.txt'
PAGOS_FILE = r'c:\Users\USUARIO\Downloads\pagos.txt'
EST_FILE = r'c:\Users\USUARIO\Downloads\estudiantes.txt'
OUT_DIR = os.path.dirname(__file__)
TODAY = date(2026, 7, 31)

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
    'PLAN_SEMESTRAL_MANANA': 'PLN010',
    'PLAN_SEMESTRAL_MAÑANA': 'PLN010',
    'PLAN_BECA_18_SABATINO_MANANA': 'PLN011',
    'PLAN_BECA_18_SABATINO_MAÑANA': 'PLN011',
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

SALON_ID_MAP = {33: 'AUL007'}

REGISTRADOR_FALLBACK = {
    1: '72618032',
    10: '10033907',
    11: '41591259',
}


def sql_str(val):
    if val is None:
        return 'NULL'
    s = str(val).strip()
    if not s:
        return 'NULL'
    return "N'" + s.replace("'", "''") + "'"


def fmt_fecha_ddmmyyyy(val):
    if not val:
        return 'NULL'
    d = datetime.strptime(str(val)[:10], '%Y-%m-%d').date()
    return sql_str(d.strftime('%d%m%Y'))


def load_membresias(path):
    with open(path, 'r', encoding='utf-8') as f:
        raw = f.read().strip()
    chunks = re.split(r'\}\s*\{', raw)
    items = []
    for i, chunk in enumerate(chunks):
        if i == 0:
            text = chunk + '}'
        elif i == len(chunks) - 1:
            text = '{' + chunk
        else:
            text = '{' + chunk + '}'
        items.extend(json.loads(text).get('content', []))
    return items


def load_user_maps(path):
    with open(path, 'r', encoding='utf-8') as f:
        users = json.load(f)
    id_to_dni = {}
    student_dnis = set()
    for u in users:
        uid = u.get('id')
        dni = (u.get('dni') or u.get('username') or '').strip()
        if uid is not None and dni:
            id_to_dni[int(uid)] = dni
        if dni and u.get('rol') == 'USUARIO':
            student_dnis.add(dni)
    id_to_dni.update(REGISTRADOR_FALLBACK)
    return id_to_dni, student_dnis


def membresia_score(m, student_dnis):
    dni = ((m.get('usuario') or {}).get('dni') or '').strip()
    is_student = 1 if dni in student_dnis else 0
    monto = float(m.get('monto_total') or 0)
    pagado = float(m.get('total_pagado') or 0)
    return (is_student, monto, pagado)


def dedupe_vigentes(vigentes, student_dnis):
    """El export repite ids entre páginas: conservar el registro más completo."""
    by_id = {}
    for m in vigentes:
        mid = m['id']
        if mid not in by_id or membresia_score(m, student_dnis) > membresia_score(by_id[mid], student_dnis):
            by_id[mid] = m
    return sorted(by_id.values(), key=lambda x: int(x['id']))


def parse_date(s):
    if not s:
        return None
    return datetime.strptime(str(s)[:10], '%Y-%m-%d').date()


def is_vigente(m):
    if m.get('fecha_cancelacion'):
        return False
    fin = parse_date(m.get('fecha_fin'))
    return fin is not None and fin >= TODAY


def norm_salon_name(name):
    if not name:
        return ''
    s = str(name).strip().upper()
    s = s.replace('Ó', 'O').replace('Á', 'A').replace('É', 'E').replace('Í', 'I').replace('Ú', 'U')
    return s


def map_aula(m):
    salon_id = m.get('salon')
    if salon_id in SALON_ID_MAP:
        return SALON_ID_MAP[salon_id]
    name = norm_salon_name(m.get('salonNombre'))
    for k, v in SALON_NAME_MAP.items():
        if norm_salon_name(k) == name:
            return v
    return None


def map_plan(plan):
    if plan in PLAN_MAP:
        return PLAN_MAP[plan]
    raise KeyError(f'Plan sin mapeo: {plan}')


def mensualidad_id(old_id):
    return f'MEM{int(old_id):06d}'


def pago_id(old_id):
    return f'PAG{int(old_id):06d}'


def map_registrador(old_id, id_to_dni):
    if old_id is None:
        return None
    return id_to_dni.get(int(old_id))


def build_observaciones(m):
    parts = [f"Import legacy membresia #{m.get('id')}"]
    asesor = (m.get('asesor') or '').strip()
    if asesor:
        parts.append(f'Asesor: {asesor}')
    tipo = (m.get('tipo') or '').strip()
    if tipo:
        parts.append(f'Tipo: {tipo}')
    return ' | '.join(parts)


def render_mensualidad(idx, total, m, id_to_dni, student_dnis):
    old_id = m['id']
    dni = (m.get('usuario') or {}).get('dni') or (m.get('usuario') or {}).get('username')
    dni = (dni or '').strip()
    mid = mensualidad_id(old_id)
    plan = map_plan(m.get('plan'))
    aula = map_aula(m)
    reg = map_registrador(m.get('registrada_por') or m.get('registradaPor'), id_to_dni)
    monto = float(m.get('monto_total') or 0)
    obs = build_observaciones(m)
    nombre = (m.get('usuario') or {}).get('nombres', '')
    apellido = (m.get('usuario') or {}).get('apellidos', '')

    lines = [
        f'-- [{idx}/{total}] Membresia legacy #{old_id} — {nombre} {apellido} (DNI {dni}) fin {m.get("fecha_fin")} estado {m.get("estado")}',
        f"IF NOT EXISTS (SELECT 1 FROM MENSUALIDAD WHERE IDMENSUALIDAD = {sql_str(mid)})",
        'BEGIN',
    ]

    if dni not in student_dnis:
        lines.extend([
            '    INSERT INTO MENSUALIDAD (',
            '        IDMENSUALIDAD, FECHAINICIO, FECHAFIN, ESTADOMIEMBRO, MONTOTOTAL, OBSERVACIONES,',
            '        FECHAREGISTRO, HORAREGISTRO, IDPLAN, IDAULA, IDTURNO, IDUSUARIO, REGISTRADOPOR,',
            '        IDTUTOR, FECHACANCELACION, ESTADO',
            '    )',
            '    SELECT',
            f'        {sql_str(mid)}, {fmt_fecha_ddmmyyyy(m.get("fecha_inicio"))}, {fmt_fecha_ddmmyyyy(m.get("fecha_fin"))}, 2, {monto:.2f}, {sql_str(obs)},',
            '        dbo.fn_fecha_ddmmyyyy(), CONVERT(CHAR(8), GETDATE(), 108),',
            f'        {sql_str(plan)}, {sql_str(aula)}, p.IDTURNO, {sql_str(dni)}, {sql_str(reg)},',
            '        NULL, NULL, N\'Activo\'',
            f'    FROM [PLAN] p WHERE p.IDPLAN = {sql_str(plan)};',
            f"    PRINT 'OK {mid}: insertado (usuario no estudiante)';",
        ])
    else:
        lines.extend([
            '    DECLARE @R INT, @M NVARCHAR(200);',
            '    EXEC dbo.usp_mensualidad_insertar',
            f'        @Id                 = {sql_str(mid)},',
            f'        @IdUsuario          = {sql_str(dni)},',
            f'        @IdPlan             = {sql_str(plan)},',
            '        @EstadoMiembro      = 2,',
            f'        @FechaInicio        = {fmt_fecha_ddmmyyyy(m.get("fecha_inicio"))},',
            f'        @FechaFin           = {fmt_fecha_ddmmyyyy(m.get("fecha_fin"))},',
            f'        @MontoTotal         = {monto:.2f},',
            '        @PagoInicial        = 0,',
            '        @IdMetodoPago       = NULL,',
            f'        @IdAula             = {sql_str(aula)},',
            '        @IdTutor            = NULL,',
            f'        @Observaciones      = {sql_str(obs)},',
            '        @FechaCancelacion   = NULL,',
            f'        @RegistradoPor      = {sql_str(reg)},',
            '        @Resultado          = @R OUTPUT,',
            '        @Mensaje            = @M OUTPUT;',
            f"    IF @R = 1 PRINT 'OK {mid}: ' + @M; ELSE PRINT 'ERROR {mid}: ' + @M;",
        ])

    lines.extend([
        'END',
        'ELSE',
        f"    PRINT 'SKIP {mid} ya existe';",
        'GO',
        '',
    ])
    return lines


def render_usuario_estudiante(m):
    u = m.get('usuario') or {}
    dni = (u.get('dni') or u.get('username') or '').strip()
    nombre = (u.get('nombres') or u.get('firstName') or '').strip()
    apellido = (u.get('apellidos') or u.get('lastName') or '').strip()
    tel = (u.get('telefono') or '').strip() or None
    tel_apod = (u.get('telefono_apoderado') or '').strip() or None
    email = f'{dni}@import.academia.local'

    return [
        f'-- Crear estudiante faltante DNI {dni}',
        f"IF NOT EXISTS (SELECT 1 FROM USUARIO WHERE IDUSUARIO = {sql_str(dni)})",
        'BEGIN',
        '    DECLARE @R INT, @M NVARCHAR(200);',
        '    EXEC dbo.usp_usuario_insertar',
        f'        @Id                 = {sql_str(dni)},',
        f'        @Contra             = {sql_str(dni)},',
        f'        @Nombre             = {sql_str(nombre)},',
        f'        @Apellido           = {sql_str(apellido)},',
        f'        @Dni                = {sql_str(dni)},',
        f'        @Email              = {sql_str(email)},',
        "        @IdTipoUsuario      = N'1',",
        "        @Estado             = N'Activo',",
        '        @FechaNacimiento    = NULL,',
        '        @Direccion          = NULL,',
        '        @Distrito           = NULL,',
        '        @Colegio            = NULL,',
        '        @Grado              = NULL,',
        f'        @TelPersonal        = {sql_str(tel)},',
        f'        @TelApoderado       = {sql_str(tel_apod)},',
        '        @NombreApoderado    = NULL,',
        '        @Parentesco         = NULL,',
        '        @SituacionAcademica = NULL,',
        '        @ComoEntero         = NULL,',
        '        @Foto               = NULL,',
        '        @Resultado          = @R OUTPUT,',
        '        @Mensaje            = @M OUTPUT;',
        f"    IF @R = 1 PRINT 'OK usuario {dni}: ' + @M; ELSE PRINT 'ERROR usuario {dni}: ' + @M;",
        'END',
        'GO',
        '',
    ]


def render_correccion(failed_ids, by_id, id_to_dni, student_dnis):
    lines = [
        '/* ============================================================================',
        '   CORRECCIÓN MENSUALIDADES — registros que fallaron en script 6',
        '   - Staff/admin/secretario: INSERT directo (SP solo acepta estudiantes)',
        '   - Estudiante faltante 61136536: crear usuario + mensualidad',
        '   Ejecutar antes del script 7 (pagos)',
        '   Fecha: 31/07/2026',
        '   ============================================================================ */',
        '',
        'SET NOCOUNT ON;',
        'GO',
        '',
    ]

    for mid in failed_ids:
        m = by_id.get(mid)
        if not m:
            continue
        dni = ((m.get('usuario') or {}).get('dni') or '').strip()
        if dni and dni not in student_dnis and mid == 777:
            lines.extend(render_usuario_estudiante(m))
            student_dnis.add(dni)
        lines.extend(render_mensualidad(1, 1, m, id_to_dni, student_dnis))

    return lines


def render_pago(idx, total, p, vig_ids, id_to_dni):
    mem_old = p.get('membresia')
    if mem_old not in vig_ids:
        return []
    mid = mensualidad_id(mem_old)
    pid = pago_id(p['id'])
    monto = float(p.get('monto_pagado') or 0)
    if monto <= 0:
        return []
    dni_est = (p.get('usuario') or {}).get('dni') or (p.get('usuario') or {}).get('username')
    dni_est = (dni_est or '').strip()
    reg = map_registrador((p.get('registrado_por') or {}).get('id'), id_to_dni)
    fecha = fmt_fecha_ddmmyyyy(p.get('fecha_pago'))
    obs = p.get('observaciones')
    if not obs:
        obs = f"Import legacy pago #{p.get('id')} membresia #{mem_old}"

    return [
        f'-- [{idx}/{total}] Pago legacy #{p.get("id")} -> {mid} DNI {dni_est} S/ {monto:.2f}',
        f"IF NOT EXISTS (SELECT 1 FROM PAGOMENSUALIDAD WHERE IDPAGOMENSUALIDAD = {sql_str(pid)})",
        'BEGIN',
        '    INSERT INTO PAGOMENSUALIDAD (',
        '        IDPAGOMENSUALIDAD, MONTO, FECHAPAGO, HORAPAGO, OBSERVACIONES,',
        '        IDMENSUALIDAD, IDMETODOPAGO, IDUSUARIO',
        '    ) VALUES (',
        f"        {sql_str(pid)}, {monto:.2f}, {fecha}, N'08:00:00',",
        f"        {sql_str(obs)}, {sql_str(mid)}, N'MPG001', {sql_str(reg)}",
        '    );',
        f"    PRINT 'OK {pid} insertado';",
        'END',
        'ELSE',
        f"    PRINT 'SKIP {pid} ya existe';",
        'GO',
        '',
    ]


def main():
    membresias = load_membresias(MEM_FILE)
    id_to_dni, student_dnis = load_user_maps(EST_FILE)
    vigentes_raw = [m for m in membresias if is_vigente(m)]
    vigentes = dedupe_vigentes(vigentes_raw, student_dnis)
    by_id = {m['id']: m for m in vigentes}

    with open(PAGOS_FILE, 'r', encoding='utf-8') as f:
        pagos = json.load(f)

    vig_ids = set(by_id.keys())
    pagos_filtrados = sorted(
        [p for p in pagos if p.get('membresia') in vig_ids and float(p.get('monto_pagado') or 0) > 0],
        key=lambda x: (x.get('fecha_pago') or '', int(x.get('id') or 0)),
    )

    unmapped_plans = sorted({m.get('plan') for m in vigentes if m.get('plan') not in PLAN_MAP})
    if unmapped_plans:
        raise SystemExit(f'Planes sin mapeo: {unmapped_plans}')

    failed_ids = [662, 663, 664, 665, 674, 777]

    mem_lines = [
        '/* ============================================================================',
        '   IMPORTACIÓN MENSUALIDADES VIGENTES — desde memebresias.txt',
        f'   Archivo: {len(membresias)} filas, {len(vigentes_raw)} vigentes brutas, {len(vigentes)} únicas deduplicadas',
        '   Criterio vigente: FECHAFIN >= 31/07/2026 y sin fecha_cancelacion',
        '   Pago inicial (adelanto): 0 — los pagos van en script 7',
        '   IDMENSUALIDAD: MEM + id legacy | IF NOT EXISTS evita duplicados al re-ejecutar',
        '   Ejecutar después de importar usuarios',
        '   Fecha: 31/07/2026',
        '   ============================================================================ */',
        '',
        'SET NOCOUNT ON;',
        'GO',
        '',
    ]

    for idx, m in enumerate(vigentes, 1):
        mem_lines.extend(render_mensualidad(idx, len(vigentes), m, id_to_dni, student_dnis))

    corr_lines = render_correccion(failed_ids, by_id, id_to_dni, set(student_dnis))

    pago_lines = [
        '/* ============================================================================',
        '   IMPORTACIÓN PAGOS — desde pagos.txt (solo mensualidades vigentes importadas)',
        f'   Pagos incluidos: {len(pagos_filtrados)} de {len(pagos)} totales',
        '   INSERT directo en PAGOMENSUALIDAD para conservar FECHAPAGO histórica',
        '   Ejecutar DESPUÉS de 6.importar_mensualidades_vigentes.sql y 6.importar_mensualidades_corregir.sql',
        '   Fecha: 31/07/2026',
        '   ============================================================================ */',
        '',
        'SET NOCOUNT ON;',
        'GO',
        '',
    ]

    for idx, p in enumerate(pagos_filtrados, 1):
        pago_lines.extend(render_pago(idx, len(pagos_filtrados), p, vig_ids, id_to_dni))

    mem_path = os.path.join(OUT_DIR, '6.importar_mensualidades_vigentes.sql')
    corr_path = os.path.join(OUT_DIR, '6.importar_mensualidades_corregir.sql')
    pago_path = os.path.join(OUT_DIR, '7.importar_pagos_mensualidades.sql')
    with open(mem_path, 'w', encoding='utf-8') as f:
        f.write('\n'.join(mem_lines))
    with open(corr_path, 'w', encoding='utf-8') as f:
        f.write('\n'.join(corr_lines))
    with open(pago_path, 'w', encoding='utf-8') as f:
        f.write('\n'.join(pago_lines))

    print('Mensualidades:', mem_path, len(vigentes))
    print('Correccion:', corr_path, len(failed_ids))
    print('Pagos:', pago_path, len(pagos_filtrados))
    print('Duplicados omitidos:', len(vigentes_raw) - len(vigentes))


if __name__ == '__main__':
    main()
