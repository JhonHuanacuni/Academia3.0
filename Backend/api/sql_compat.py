"""SQL crudo compatible MySQL / SQL Server."""

from django.db import connection


def is_mysql():
    return connection.vendor == 'mysql'


def isnull(expr, default="''"):
    if is_mysql():
        return f'IFNULL({expr}, {default})'
    return f'ISNULL({expr}, {default})'


def len_expr(col):
    return f'CHAR_LENGTH({col})' if is_mysql() else f'LEN({col})'


def ym_from_fechapago():
    if is_mysql():
        return "CONCAT(SUBSTRING(p.FECHAPAGO, 5, 4), SUBSTRING(p.FECHAPAGO, 3, 2))"
    return "SUBSTRING(p.FECHAPAGO, 5, 4) + SUBSTRING(p.FECHAPAGO, 3, 2)"


def plan_table():
    return '`PLAN`' if is_mysql() else '[PLAN]'


def concat_nombre_usuario(alias='u'):
    if is_mysql():
        return (
            f"UPPER(TRIM(CONCAT(IFNULL({alias}.APELLIDO, ''), "
            f"' ', IFNULL({alias}.NOMBRE, ''))))"
        )
    return (
        f"UPPER(LTRIM(RTRIM("
        f"ISNULL({alias}.APELLIDO, '') + ' ' + ISNULL({alias}.NOMBRE, '')"
        f")))"
    )
