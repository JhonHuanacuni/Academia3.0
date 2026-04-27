from django.db import connection
from .models import Cliente


def get_clientes():
    return list(Cliente.objects.filter(activo=True).values('id', 'nombre', 'email', 'activo', 'creado_en'))


def get_clientes_sp():
    with connection.cursor() as cursor:
        cursor.execute('EXEC usp_get_clientes')
        columns = [column[0] for column in cursor.description]
        return [dict(zip(columns, row)) for row in cursor.fetchall()]
