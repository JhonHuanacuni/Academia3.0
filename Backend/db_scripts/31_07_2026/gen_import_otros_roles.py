import json
import os
from datetime import datetime

INPUT = r'c:\Users\USUARIO\Downloads\estudiantes.txt'
OUTPUT = os.path.join(os.path.dirname(__file__), '5.importar_usuarios_otros_roles.sql')

ROL_TIPO = {
    'SECRETARIO': ('2', 'Docente'),
    'ADMIN': ('3', 'Administrador'),
}


def sql_str(val):
    if val is None:
        return 'NULL'
    s = str(val).strip()
    if not s:
        return 'NULL'
    return "N'" + s.replace("'", "''") + "'"


def fmt_fecha(val):
    if not val:
        return 'NULL'
    s = str(val).strip()
    if not s:
        return 'NULL'
    for fmt in ('%Y-%m-%d', '%d/%m/%Y'):
        try:
            dt = datetime.strptime(s[:10], fmt)
            return sql_str(dt.strftime('%d%m%Y'))
        except ValueError:
            continue
    return 'NULL'


def norm_situacion(val):
    if not val:
        return 'NULL'
    v = str(val).strip().lower()
    if not v:
        return 'NULL'
    mapping = {'egresado': 'Egresado', 'estudiante': 'Estudiante'}
    return sql_str(mapping.get(v, str(val).strip().capitalize()))


def pick_colegio(s):
    return s.get('nombreColegio') or s.get('colegio')


def build_email_map(all_records, priority_roles=None):
    """Primer DNI conserva email; duplicados -> dni@import.
    Si priority_roles está definido, esos roles ceden el email a otros."""
    priority_roles = priority_roles or set()
    seen = {}
    result = {}

    def assign(s, force_alt=False):
        dni = (s.get('dni') or '').strip()
        email = (s.get('email') or '').strip()
        if not dni:
            return
        if force_alt or not email:
            result[dni] = email or f'{dni}@import.academia.local'
            if email:
                key = email.lower()
                if key not in seen:
                    seen[key] = dni
            return
        key = email.lower()
        if key not in seen:
            seen[key] = dni
            result[dni] = email
        else:
            result[dni] = f'{dni}@import.academia.local'

    # 1) Reservar emails usados por otros roles (estudiantes primero)
    for s in all_records:
        if s.get('rol') not in priority_roles:
            assign(s)

    # 2) Staff/admin: ceden si el email ya está tomado
    for s in all_records:
        if s.get('rol') in priority_roles:
            dni = (s.get('dni') or '').strip()
            email = (s.get('email') or '').strip()
            if not dni:
                continue
            if email and email.lower() in seen and seen[email.lower()] != dni:
                result[dni] = f'{dni}@import.academia.local'
            else:
                assign(s)

    return result


def render_insert(idx, total, s, id_tipo, email):
    dni = (s.get('dni') or '').strip()
    nombre = (s.get('nombres') or s.get('firstName') or '').strip()
    apellido = (s.get('apellidos') or s.get('lastName') or '').strip()
    tel = (s.get('telefono') or '').strip() or None
    tel_apod = (s.get('telefono_apoderado') or '').strip() or None
    direccion = (s.get('direccion') or '').strip() or None
    distrito = (s.get('distrito') or '').strip() if s.get('distrito') else None
    colegio = pick_colegio(s)
    if colegio:
        colegio = str(colegio).strip() or None
    grado = (s.get('grado') or '').strip() or None
    foto = (s.get('foto_perfil') or '').strip() or None
    fecha_nac = fmt_fecha(s.get('fecha_nacimiento'))
    situacion = norm_situacion(s.get('situacion_academica'))
    rol = s.get('rol', '')

    return [
        f'-- [{idx}/{total}] {rol} — {nombre} {apellido} (DNI {dni})',
        'DECLARE @R INT, @M NVARCHAR(200);',
        'EXEC dbo.usp_usuario_insertar',
        f'    @Id                 = {sql_str(dni)},',
        f'    @Contra             = {sql_str(dni)},',
        f'    @Nombre             = {sql_str(nombre)},',
        f'    @Apellido           = {sql_str(apellido)},',
        f'    @Dni                = {sql_str(dni)},',
        f'    @Email              = {sql_str(email)},',
        f"    @IdTipoUsuario      = N'{id_tipo}',",
        "    @Estado             = N'Activo',",
        f'    @FechaNacimiento    = {fecha_nac},',
        f'    @Direccion          = {sql_str(direccion)},',
        f'    @Distrito           = {sql_str(distrito)},',
        f'    @Colegio            = {sql_str(colegio)},',
        f'    @Grado              = {sql_str(grado)},',
        f'    @TelPersonal        = {sql_str(tel)},',
        f'    @TelApoderado       = {sql_str(tel_apod)},',
        '    @NombreApoderado    = NULL,',
        '    @Parentesco         = NULL,',
        f'    @SituacionAcademica = {situacion},',
        '    @ComoEntero         = NULL,',
        f'    @Foto               = {sql_str(foto)},',
        '    @Resultado          = @R OUTPUT,',
        '    @Mensaje            = @M OUTPUT;',
        f"IF @R = 1 PRINT 'OK DNI {dni}: ' + @M; ELSE PRINT 'ERROR DNI {dni}: ' + @M;",
        'GO',
        '',
    ]


def main():
    with open(INPUT, 'r', encoding='utf-8') as f:
        data = json.load(f)

    otros = [s for s in data if s.get('rol') in ROL_TIPO]
    otros.sort(key=lambda s: (s.get('rol', ''), (s.get('dni') or '').strip()))

    email_map = build_email_map(data, priority_roles=set(ROL_TIPO.keys()))

    secretarios = [s for s in otros if s.get('rol') == 'SECRETARIO']
    admins = [s for s in otros if s.get('rol') == 'ADMIN']

    lines = [
        '/* ============================================================================',
        '   IMPORTACIÓN USUARIOS — roles SECRETARIO y ADMIN',
        f'   Total registros: {len(otros)} ({len(secretarios)} secretarios + {len(admins)} admins)',
        "   Mapeo: SECRETARIO -> @IdTipoUsuario '2' (Docente)",
        "          ADMIN      -> @IdTipoUsuario '3' (Administrador)",
        '   Contraseña inicial: DNI',
        '   Emails duplicados en estudiantes.txt -> {dni}@import.academia.local',
        '   Ejecutar después de 1.importar_estudiantes.sql',
        '   Fecha: 31/07/2026',
        '   ============================================================================ */',
        '',
        'SET NOCOUNT ON;',
        'GO',
        '',
    ]

    for idx, s in enumerate(otros, start=1):
        dni = (s.get('dni') or '').strip()
        id_tipo, _ = ROL_TIPO[s['rol']]
        email = email_map.get(dni) or f'{dni}@import.academia.local'
        lines.extend(render_insert(idx, len(otros), s, id_tipo, email))

    with open(OUTPUT, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines))

    adjusted = [
        (s.get('dni'), s.get('email'), email_map.get((s.get('dni') or '').strip()))
        for s in otros
        if email_map.get((s.get('dni') or '').strip()) != (s.get('email') or '').strip()
    ]
    print(f'Generado: {OUTPUT}')
    print(f'Registros: {len(otros)}')
    print('Emails ajustados:', adjusted)


if __name__ == '__main__':
    main()
