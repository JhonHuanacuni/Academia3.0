from django.db import models
from django.contrib.auth.models import User
from django.utils import timezone


def _current_date():
    return timezone.localtime().strftime('%Y%m%d')


def _current_time():
    return timezone.localtime().strftime('%H:%M:%S')


def _current_datetime():
    return f"{_current_date()} {_current_time()}"


class Cliente(models.Model):
    nombre = models.CharField(max_length=200)
    email = models.EmailField(unique=True)
    activo = models.BooleanField(default=True)
    creado_en = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'clientes'
        managed = False
        verbose_name = 'Cliente'
        verbose_name_plural = 'Clientes'

    def __str__(self):
        return self.nombre


class TipoPermiso(models.Model):
    """Tipos de permisos disponibles (read, write, delete, admin)"""
    IDPERMISO = models.CharField(max_length=50, primary_key=True)
    NOMBRE = models.CharField(max_length=100, unique=True)
    DESCRIPCION = models.CharField(max_length=255, blank=True, null=True)
    FECHA_CREACION = models.CharField(max_length=20, default=_current_datetime)

    class Meta:
        db_table = 'TIPO_PERMISO'
        managed = False
        verbose_name = 'Tipo de Permiso'
        verbose_name_plural = 'Tipos de Permisos'

    def __str__(self):
        return self.NOMBRE


class Modulo(models.Model):
    """Módulos principales del sistema"""
    IDMODULO = models.CharField(max_length=50, primary_key=True)
    NOMBRE = models.CharField(max_length=150, unique=True)
    DESCRIPCION = models.CharField(max_length=500, blank=True, null=True)
    ICONO = models.CharField(max_length=100, blank=True, null=True)
    ORDEN = models.IntegerField(default=0)
    ACTIVO = models.BooleanField(default=True)
    FECHA_CREACION = models.CharField(max_length=20, default=_current_datetime)
    FECHA_ACTUALIZACION = models.CharField(max_length=20, default=_current_datetime)

    class Meta:
        db_table = 'MODULO'
        managed = False
        verbose_name = 'Módulo'
        verbose_name_plural = 'Módulos'
        ordering = ['ORDEN', 'NOMBRE']

    def __str__(self):
        return self.NOMBRE


class Submodulo(models.Model):
    """Submódulos dentro de cada módulo principal"""
    IDSUBMODULO = models.CharField(max_length=50, primary_key=True)
    IDMODULO = models.ForeignKey(Modulo, on_delete=models.CASCADE, db_column='IDMODULO')
    NOMBRE = models.CharField(max_length=150)
    DESCRIPCION = models.CharField(max_length=500, blank=True, null=True)
    ICONO = models.CharField(max_length=100, blank=True, null=True)
    ORDEN = models.IntegerField(default=0)
    ACTIVO = models.BooleanField(default=True)
    FECHA_CREACION = models.CharField(max_length=20, default=_current_datetime)
    FECHA_ACTUALIZACION = models.CharField(max_length=20, default=_current_datetime)

    class Meta:
        db_table = 'SUBMODULO'
        managed = False
        verbose_name = 'Submódulo'
        verbose_name_plural = 'Submódulos'
        ordering = ['ORDEN', 'NOMBRE']

    def __str__(self):
        return f"{self.IDMODULO.NOMBRE} > {self.NOMBRE}"


class UsuarioModulo(models.Model):
    """Asignación de módulos a usuarios individuales"""
    IDUSUARIO_MODULO = models.CharField(max_length=50, primary_key=True)
    IDUSUARIO = models.CharField(max_length=50)  # Referencia a tabla USUARIO (no es Django User)
    IDMODULO = models.ForeignKey(Modulo, on_delete=models.CASCADE, db_column='IDMODULO')
    PERMISOS = models.JSONField(default=list)  # ['read', 'write', 'delete', 'admin']
    FECHA_ASIGNACION = models.CharField(max_length=20, default=_current_datetime)
    FECHA_ACTUALIZACION = models.CharField(max_length=20, default=_current_datetime)
    ASIGNADO_POR = models.CharField(max_length=50, blank=True, null=True)
    ACTIVO = models.BooleanField(default=True)

    class Meta:
        db_table = 'USUARIO_MODULO'
        managed = False
        verbose_name = 'Usuario-Módulo'
        verbose_name_plural = 'Usuarios-Módulos'
        unique_together = ('IDUSUARIO', 'IDMODULO')

    def __str__(self):
        return f"{self.IDUSUARIO} - {self.IDMODULO.NOMBRE}"


class GrupoModulo(models.Model):
    """Asignación de módulos a grupos/roles (admin, secretario, usuario)"""
    IDGRUPO_MODULO = models.CharField(max_length=50, primary_key=True)
    IDGRUPO = models.CharField(max_length=50)  # Referencia a TIPOUSUARIO.idTipoUsuario
    IDMODULO = models.ForeignKey(Modulo, on_delete=models.CASCADE, db_column='IDMODULO')
    PERMISOS = models.JSONField(default=list)  # ['read', 'write', 'delete', 'admin']
    FECHA_ASIGNACION = models.CharField(max_length=20, default=_current_datetime)
    FECHA_ACTUALIZACION = models.CharField(max_length=20, default=_current_datetime)
    ACTIVO = models.BooleanField(default=True)

    class Meta:
        db_table = 'GRUPO_MODULO'
        managed = False
        verbose_name = 'Grupo-Módulo'
        verbose_name_plural = 'Grupos-Módulos'
        unique_together = ('IDGRUPO', 'IDMODULO')

    def __str__(self):
        return f"Grupo {self.IDGRUPO} - {self.IDMODULO.NOMBRE}"
