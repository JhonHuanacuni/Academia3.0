import json
import os
from datetime import datetime

INPUT = r'c:\Users\USUARIO\Downloads\estudiantes.txt'
OUTPUT = os.path.join(os.path.dirname(__file__), '1.importar_estudiantes.sql')


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
    mapping = {'egresado': 'Egresado', 'estudiante': 'Estudiante'}
    return sql_str(mapping.get(v, str(val).strip().capitalize()))


def pick_colegio(s):
    return s.get('nombreColegio') or s.get('colegio')


def main():
    with open(INPUT, 'r', encoding='utf-8') as f:
        data = json.load(f)

    estudiantes = [s for s in data if s.get('rol') == 'USUARIO']
    estudiantes.sort(key=lambda s: (s.get('dni') or '').strip())

    email_seen = {}
    email_assignments = []
    for s in estudiantes:
        dni = (s.get('dni') or '').strip()
        email = (s.get('email') or '').strip()
        key = email.lower()
        if key not in email_seen:
            email_seen[key] = dni
            final_email = email
        else:
            final_email = f'{dni}@import.academia.local'
        email_assignments.append(final_email)

    lines = [
        '/* ============================================================================',
        '   IMPORTACIÓN ESTUDIANTES — desde estudiantes.txt',
        f'   Total registros: {len(estudiantes)} (rol USUARIO)',
        "   Ejecutar con usp_usuario_insertar (@IdTipoUsuario = '1' Estudiante)",
        '   Contraseña inicial: DNI',
        '   Emails duplicados en origen -> {dni}@import.academia.local',
        '   Fecha: 31/07/2026',
        '   ============================================================================ */',
        '',
        'SET NOCOUNT ON;',
        'GO',
        '',
        'DECLARE @R INT, @M NVARCHAR(200);',
        'DECLARE @Ok INT = 0, @Fail INT = 0;',
        '',
    ]

    for idx, s in enumerate(estudiantes):
        dni = (s.get('dni') or '').strip()
        nombre = (s.get('nombres') or s.get('firstName') or '').strip()
        apellido = (s.get('apellidos') or s.get('lastName') or '').strip()
        email = email_assignments[idx]
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

        lines.extend([
            f'-- [{idx + 1}/{len(estudiantes)}] {nombre} {apellido} (DNI {dni})',
            'DECLARE @R INT, @M NVARCHAR(200);',
            'EXEC dbo.usp_usuario_insertar',
            f'    @Id                 = {sql_str(dni)},',
            f'    @Contra             = {sql_str(dni)},',
            f'    @Nombre             = {sql_str(nombre)},',
            f'    @Apellido           = {sql_str(apellido)},',
            f'    @Dni                = {sql_str(dni)},',
            f'    @Email              = {sql_str(email)},',
            "    @IdTipoUsuario      = N'1',",
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
        ])

    with open(OUTPUT, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines))

    dup_count = sum(
        1 for i, s in enumerate(estudiantes)
        if email_assignments[i] != (s.get('email') or '').strip()
    )
    print(f'Generado: {OUTPUT}')
    print(f'Estudiantes: {len(estudiantes)}')
    print(f'Emails ajustados por duplicado: {dup_count}')


if __name__ == '__main__':
    main()
