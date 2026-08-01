"""
Importa todos los scripts de db_scripts_mysql/ en orden.
Uso (desde Backend/ con venv activo):
  python scripts/setup_mysql_db.py
  python scripts/setup_mysql_db.py --skip-import
  set MYSQL_ROOT_PASSWORD=tu_clave && python scripts/setup_mysql_db.py

Lee DB_* del .env; si DB_PASSWORD está vacío, usa MYSQL_ROOT_PASSWORD del entorno.
"""
import argparse
import os
import re
import sys
from pathlib import Path

import pymysql
from dotenv import load_dotenv

BASE_DIR = Path(__file__).resolve().parent.parent
SCRIPTS_DIR = BASE_DIR / 'db_scripts_mysql'

ORDER = [
    '00_create_database.sql',
    '22_06_2026/esquema_completo.sql',
    '22_06_2026/modulos_admin.sql',
    '22_06_2026/submodulos_admin.sql',
    '22_06_2026/usp_usuario_crud.sql',
    '22_06_2026/usp_asistencia.sql',
    '29_06_2026/usp_aula_crud.sql',
    '29_06_2026/modulo_academico.sql',
    '06_07_2026/1.modulo_informes.sql',
    '06_07_2026/2.usp_asistencia_informe.sql',
    '06_07_2026/3.alter_usp_asistencia_informe_vence.sql',
    '06_07_2026/10.usp_asistencia_informe_vence_vigente.sql',
    '06_07_2026/4.usuario_columna_foto.sql',
    '06_07_2026/5.usp_usuario_foto.sql',
    '06_07_2026/6.membresia_alter_catalogos.sql',
    '06_07_2026/7.usp_membresia_crud.sql',
    '06_07_2026/8.usp_membresia_listar_activos.sql',
    '06_07_2026/9.usp_membresia_eliminar_roles.sql',
    '08_07_2026/1.usp_asistencia_informe_filtro_plan.sql',
    '08_07_2026/2.usp_asistencia_informe_filtro_estado.sql',
    '08_07_2026/3.usp_asistencia_informe_faltas_desde_membresia.sql',
    '11_07_2026/1.usuario_columnas_apoderado.sql',
    '11_07_2026/2.usp_usuario_apoderado.sql',
    '11_07_2026/3.remove_sub006_ver_membresias.sql',
    '11_07_2026/4.membresia_columna_comoentero.sql',
    '11_07_2026/5.usp_membresia_comoentero.sql',
    '11_07_2026/6.asesor_tabla.sql',
    '11_07_2026/7.usp_membresia_asesor.sql',
    '12_07_2026/1.usp_asesor_crud.sql',
    '12_07_2026/2.sub012_mantenedor_asesores.sql',
    '12_07_2026/3.usp_plan_crud.sql',
    '12_07_2026/4.sub013_mantenedor_planes.sql',
    '12_07_2026/5.plan_quitar_duracion_precio.sql',
    '12_07_2026/6.usp_membresia_estado_registro.sql',
    '12_07_2026/7.usp_usuario_listar_orden_tipo.sql',
    '12_07_2026/8.usp_pago_crud.sql',
    '12_07_2026/9.usp_pago_membresias_prefills.sql',
    '12_07_2026/10.comoentero_a_usuario.sql',
    '12_07_2026/11.usp_pago_obtener_actualizar_eliminar.sql',
    '12_07_2026/12.sub_academico_biblioteca_examenes_horario_clases.sql',
    '12_07_2026/13.modulo_mantenedores.sql',
    '14_07_2026/1.libro_fechassubida_libro_aula.sql',
    '14_07_2026/2.usp_libro_crud.sql',
    '14_07_2026/3.horario_tabla.sql',
    '14_07_2026/4.usp_horario_crud.sql',
    '16_07_2026/1.concepto_pago_extra_tabla.sql',
    '16_07_2026/2.usp_concepto_crud.sql',
    '16_07_2026/3.pago_extraordinario_tabla.sql',
    '16_07_2026/4.usp_pago_extraordinario_crud.sql',
    '16_07_2026/5.sub_pagos_extraordinarios_conceptos.sql',
    '16_07_2026/6.usp_concepto_insertar_auto.sql',
    '16_07_2026/7.concepto_fechas_vigencia.sql',
    '16_07_2026/8.pagoextra_sin_fechas_form.sql',
    '16_07_2026/9.pagoextra_deuda_conceptos_estudiante.sql',
    '16_07_2026/10.usp_membresia_listar_deuda.sql',
    '16_07_2026/11.plan_costo_mensual.sql',
    '16_07_2026/12.pago_membresias_costo_mensual.sql',
    '16_07_2026/13.categoria_materia_tablas.sql',
    '16_07_2026/14.usp_categoria_crud.sql',
    '16_07_2026/15.usp_materia_crud.sql',
    '16_07_2026/16.sub_categorias_materias.sql',
    '16_07_2026/17.materia_categoria_auto_seed.sql',
    '17_07_2026/1.examen_tablas_plantilla.sql',
    '17_07_2026/2.usp_examen_crud.sql',
    '17_07_2026/3.usp_examen_pregunta_img_alts.sql',
    '17_07_2026/4.usp_examen_estudiante.sql',
    '17_07_2026/5.menu_estudiante_examenes.sql',
    '26_07_2026/1.plan_dias_asistencia.sql',
    '26_07_2026/2.plan_catalogo_academia_vita.sql',
    '26_07_2026/3.aula_catalogo_academia_vita.sql',
    '26_07_2026/4.rename_membresia_asesor_a_mensualidad_tutor.sql',
    '26_07_2026/20.usp_asistencia_informe.sql',
    '26_07_2026/5.menu_mensualidad_tutor.sql',
    '26_07_2026/6.plan_turno.sql',
    '26_07_2026/7.plan_nombres_sin_turno.sql',
    '26_07_2026/8.asesor_registro_mensualidad.sql',
    '26_07_2026/9.menu_tutores_asesores.sql',
    '26_07_2026/10.tutor_codigo_tut.sql',
    '26_07_2026/11.quitar_mantenedor_asesor.sql',
    '26_07_2026/12.plan_hora_entrada_tardanza.sql',
    '26_07_2026/13.mantenedores_codigo_autogenerado.sql',
    '26_07_2026/14.justificacion.sql',
    '26_07_2026/15.usp_justificacion_actualizar.sql',
    '26_07_2026/16.usuario_estado_retirado.sql',
    '26_07_2026/17.mensualidad_filtro_deuda.sql',
    '26_07_2026/18.usp_usuario_resetear_contra.sql',
    '26_07_2026/19.usp_mensualidad_listar_pagos.sql',
    '29_07_2026/1.notas_importacion_tablas.sql',
    '29_07_2026/2.sub_academico_importar_notas.sql',
    '29_07_2026/3.notas_modulo_academico.sql',
    '29_07_2026/4.fix_sub026_importar_notas.sql',
    '30_07_2026/1.usp_mensualidad_listar_reciente.sql',
    '30_07_2026/2.auditoria_columnas_tablas.sql',
    '30_07_2026/3.auditoria_tabla.sql',
    '30_07_2026/4.usp_auditoria_crud.sql',
    '30_07_2026/5.triggers_auditoria.sql',
    '30_07_2026/6.sub_academico_auditoria.sql',
    '30_07_2026/7.modulos_admin_rol.sql',
    '31_07_2026/3.usp_usuario_eliminar_fisica.sql',
    '31_07_2026/4.usp_usuario_insertar_mensajes.sql',
    '31_07_2026/8.usp_examen_ranking_aula.sql',
]


def _split_on_semicolon(sql: str) -> list[str]:
    """Divide por ; respetando strings entre comillas simples."""
    parts: list[str] = []
    buf: list[str] = []
    in_str = False
    i = 0
    while i < len(sql):
        ch = sql[i]
        if ch == "'" and not in_str:
            in_str = True
            buf.append(ch)
        elif ch == "'" and in_str:
            buf.append(ch)
            if i + 1 < len(sql) and sql[i + 1] == "'":
                buf.append("'")
                i += 1
            else:
                in_str = False
        elif ch == ';' and not in_str:
            stmt = ''.join(buf).strip()
            if stmt:
                parts.append(stmt)
            buf = []
        else:
            buf.append(ch)
        i += 1
    tail = ''.join(buf).strip()
    if tail:
        parts.append(tail)
    return parts


def split_sql(content: str):
    content = re.sub(r'/\*.*?\*/', '', content, flags=re.DOTALL)
    lines = content.splitlines()
    chunks: list[str] = []
    buf: list[str] = []
    delimiter = ';'

    for line in lines:
        stripped = line.strip()
        if stripped.upper().startswith('DELIMITER '):
            if buf:
                block = '\n'.join(buf)
                if delimiter == ';':
                    chunks.extend(_split_on_semicolon(block))
                else:
                    chunks.append(block)
                buf = []
            delimiter = stripped.split(None, 1)[1]
            continue
        buf.append(line)
        if stripped.endswith(delimiter):
            block = '\n'.join(buf).rstrip()
            if delimiter != ';':
                block = block[: -len(delimiter)].rstrip()
            buf = []
            if block.strip():
                if delimiter == ';':
                    chunks.extend(_split_on_semicolon(block))
                else:
                    chunks.append(block)
    if buf:
        tail = '\n'.join(buf).strip()
        if tail:
            if delimiter == ';':
                chunks.extend(_split_on_semicolon(tail))
            else:
                chunks.append(tail)
    return chunks


def _strip_leading_comments(sql: str) -> str:
    """Quita líneas vacías y comentarios -- al inicio (no descartar CREATE tras un --)."""
    lines = sql.splitlines()
    while lines:
        stripped = lines[0].strip()
        if not stripped or stripped.startswith('--'):
            lines.pop(0)
            continue
        break
    return '\n'.join(lines).strip()


def run_file(cursor, path: Path):
    sql = path.read_text(encoding='utf-8')
    for n, stmt in enumerate(split_sql(sql), start=1):
        s = _strip_leading_comments(stmt.strip())
        if not s:
            continue
        if re.match(r'USE\s+', s, re.I):
            continue
        if re.match(r'CREATE\s+DATABASE\b', s, re.I):
            continue
        try:
            cursor.execute(s)
        except pymysql.err.ProgrammingError as exc:
            preview = s.splitlines()[0][:80] if s else ''
            print(f'ERROR en {path.name} stmt #{n} ({preview}): {exc.args[1][:200]}', file=sys.stderr)
            raise
        except pymysql.err.OperationalError as exc:
            # Índice/columna ya existe en reimport parcial
            if exc.args[0] in (1060, 1061, 1826):
                continue
            preview = s.splitlines()[0][:80] if s else ''
            print(f'ERROR en {path.name} stmt #{n} ({preview}): {exc.args[1][:200]}', file=sys.stderr)
            raise


def _connect(host, port, user, password, database=None):
    return pymysql.connect(
        host=host, port=port, user=user, password=password,
        database=database, charset='utf8mb4', autocommit=True,
    )


def _db_ready(cursor, db_name):
    cursor.execute(
        'SELECT COUNT(*) FROM information_schema.TABLES '
        'WHERE TABLE_SCHEMA = %s AND TABLE_NAME = %s',
        [db_name, 'USUARIO'],
    )
    return cursor.fetchone()[0] > 0


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--skip-import', action='store_true', help='Solo verificar conexión')
    parser.add_argument('--force', action='store_true', help='Importar aunque ya existan tablas')
    args = parser.parse_args()

    load_dotenv(BASE_DIR / '.env')
    host = os.getenv('DB_HOST', '127.0.0.1')
    port = int(os.getenv('DB_PORT', '3306'))
    user = os.getenv('DB_USER', 'root')
    password = os.getenv('DB_PASSWORD', '') or os.getenv('MYSQL_ROOT_PASSWORD', '')
    db_name = os.getenv('DB_NAME', 'AcademiaDB')

    if not password:
        print(
            'ERROR: Define DB_PASSWORD en Backend/.env o MYSQL_ROOT_PASSWORD en el entorno.',
            file=sys.stderr,
        )
        sys.exit(1)

    print(f'Conectando a MySQL {user}@{host}:{port} ...')
    conn = _connect(host, port, user, password)
    try:
        with conn.cursor() as cur:
            cur.execute(
                f'CREATE DATABASE IF NOT EXISTS `{db_name}` '
                f'CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci'
            )
            conn.select_db(db_name)

            if args.skip_import:
                if _db_ready(cur, db_name):
                    print(f'OK: {db_name} ya tiene tablas (USUARIO).')
                else:
                    print(f'AVISO: {db_name} sin tablas; ejecuta sin --skip-import.', file=sys.stderr)
                    sys.exit(1)
                return

            if _db_ready(cur, db_name) and not args.force:
                print(f'AVISO: {db_name} ya tiene datos; omitiendo importación.')
                print('Usa --force para reimportar (destructivo).')
                print(f'OK: {db_name} lista.')
                return

            for rel in ORDER:
                path = SCRIPTS_DIR / rel.replace('/', os.sep)
                if not path.exists():
                    print(f'FALTA: {path}', file=sys.stderr)
                    sys.exit(1)
                print(f'>>> {rel}')
                run_file(cur, path)
        print(f'OK: {db_name} lista.')
    finally:
        conn.close()


if __name__ == '__main__':
    main()
