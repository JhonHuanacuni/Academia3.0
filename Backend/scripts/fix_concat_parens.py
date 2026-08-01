"""Corrige paréntesis faltantes en expresiones TRIM/UPPER/CONCAT."""
from pathlib import Path

REPLACEMENTS = [
    (
        "UPPER(TRIM(CONCAT(IFNULL(u.APELLIDO, ''), ' ', IFNULL(u.NOMBRE, ''))) AS ESTUDIANTE_NOMBRE",
        "UPPER(TRIM(CONCAT(IFNULL(u.APELLIDO, ''), ' ', IFNULL(u.NOMBRE, '')))) AS ESTUDIANTE_NOMBRE",
    ),
    (
        "UPPER(TRIM(CONCAT(IFNULL(reg.APELLIDO, ''), ' ', IFNULL(reg.NOMBRE, ''))) AS ESTUDIANTE_NOMBRE",
        "UPPER(TRIM(CONCAT(IFNULL(reg.APELLIDO, ''), ' ', IFNULL(reg.NOMBRE, '')))) AS ESTUDIANTE_NOMBRE",
    ),
    (
        "TRIM(CONCAT(IFNULL(reg.NOMBRE, ''), ' ', IFNULL(reg.APELLIDO, ''))) AS REGISTRADOR_NOMBRE",
        "TRIM(CONCAT(IFNULL(reg.NOMBRE, ''), ' ', IFNULL(reg.APELLIDO, ''))) AS REGISTRADOR_NOMBRE",
    ),
    (
        "TRIM(CONCAT(IFNULL(u.NOMBRE, ''), ' ', IFNULL(u.APELLIDO, ''))) AS USUARIO_NOMBRE",
        "TRIM(CONCAT(IFNULL(u.NOMBRE, ''), ' ', IFNULL(u.APELLIDO, ''))) AS USUARIO_NOMBRE",
    ),
    (
        "UPPER(TRIM(CONCAT(IFNULL(u.APELLIDO, ''), ' ', IFNULL(u.NOMBRE, ''))) AS NOMBRE_COMPLETO",
        "UPPER(TRIM(CONCAT(IFNULL(u.APELLIDO, ''), ' ', IFNULL(u.NOMBRE, '')))) AS NOMBRE_COMPLETO",
    ),
]

root = Path(__file__).resolve().parent.parent / 'db_scripts_mysql'
for path in root.rglob('*.sql'):
    text = path.read_text(encoding='utf-8')
    new = text
    for old, repl in REPLACEMENTS:
        new = new.replace(old, repl)
    if new != text:
        path.write_text(new, encoding='utf-8')
        print('fixed', path.relative_to(root.parent))
