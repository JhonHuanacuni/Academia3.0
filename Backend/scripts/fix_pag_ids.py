"""Corrige generación de ID PAG rotos en db_scripts_mysql/."""
import re
from pathlib import Path

SCRIPTS = Path(__file__).resolve().parent.parent / 'db_scripts_mysql'

PATTERN = re.compile(
    r"CONCAT\('PAG', RIGHT\(CONCAT\('000000', CAST\(\(\s*"
    r"IFNULL\(\(SELECT MAX\(CAST\(SUBSTRING\((IDPAGO\w+), 4, 10\) AS INT\)\)\)\s*"
    r"FROM \2 WHERE \2 LIKE 'PAG%'\), 0\) \+ 1\s*"
    r"\) AS (?:VARCHAR|CHAR)\(10\)\), 6\)\)",
    re.I | re.S,
)


def repl(m):
    col = m.group(1)
    tbl = m.group(2)
    return (
        f"CONCAT('PAG', LPAD(IFNULL((SELECT MAX(CAST(SUBSTRING({col}, 4, 10) AS UNSIGNED)) "
        f"FROM {tbl} WHERE {tbl} LIKE 'PAG%'), 0) + 1, 6, '0'))"
    )


for path in SCRIPTS.rglob('*.sql'):
    text = path.read_text(encoding='utf-8')
    fixed = PATTERN.sub(repl, text)
    if fixed != text:
        path.write_text(fixed, encoding='utf-8')
        print('fixed', path.relative_to(SCRIPTS.parent))
