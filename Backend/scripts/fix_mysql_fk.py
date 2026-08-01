"""Corrige FOREIGN KEY T-SQL → MySQL en db_scripts_mysql/."""
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent / 'db_scripts_mysql'


def fix_fk(text: str) -> str:
    text = re.sub(
        r'(\n\s+)(\w+)\s+((?:VARCHAR|CHAR|INT|LONGTEXT|DECIMAL|TINYINT)[^\n;]+?)\s+NOT NULL\s*\n\s+'
        r'FOREIGN KEY REFERENCES (`?\w+`?)\((\w+)\)',
        r'\1\2 \3 NOT NULL,\n\1FOREIGN KEY (\2) REFERENCES \4(\5)',
        text,
        flags=re.I,
    )
    text = re.sub(
        r'(\w+)\s+((?:VARCHAR|CHAR|INT|LONGTEXT|DECIMAL|TINYINT)[^,\n]+?)\s+NOT NULL\s+'
        r'FOREIGN KEY REFERENCES (`?\w+`?)\((\w+)\)',
        r'\1 \2 NOT NULL,\n    FOREIGN KEY (\1) REFERENCES \3(\4)',
        text,
        flags=re.I,
    )
    text = re.sub(
        r'(\w+)\s+((?:VARCHAR|CHAR|INT|LONGTEXT|DECIMAL|TINYINT)[^,\n]+?)\s+NULL\s+'
        r'FOREIGN KEY REFERENCES (`?\w+`?)\((\w+)\)',
        r'\1 \2 NULL,\n    FOREIGN KEY (\1) REFERENCES \3(\4)',
        text,
        flags=re.I,
    )
    return text


def main():
    count = 0
    for path in ROOT.rglob('*.sql'):
        original = path.read_text(encoding='utf-8')
        fixed = fix_fk(original)
        if fixed != original:
            path.write_text(fixed, encoding='utf-8')
            count += 1
    print(f'OK: {count} archivo(s) corregidos.')


if __name__ == '__main__':
    main()
