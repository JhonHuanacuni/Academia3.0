from django.db import models
from django.utils import timezone


def _fecha_hoy():
    return timezone.localtime().strftime('%d%m%Y')


class Cliente(models.Model):
    nombre = models.CharField(max_length=200)
    email = models.EmailField(unique=True)
    activo = models.BooleanField(default=True)
    creado_en = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'clientes'
        managed = False

    def __str__(self):
        return self.nombre


class TipoUsuario(models.Model):
    IDTIPOUSUARIO = models.CharField(max_length=50, primary_key=True)
    DESCRIPCION = models.CharField(max_length=255)

    class Meta:
        db_table = 'TIPOUSUARIO'
        managed = False


class Usuario(models.Model):
    IDUSUARIO = models.CharField(max_length=50, primary_key=True)
    CONTRA = models.CharField(max_length=255)
    NOMBRE = models.CharField(max_length=100)
    APELLIDO = models.CharField(max_length=100)
    DNI = models.CharField(max_length=20)
    ESTADO = models.CharField(max_length=50, default='Activo')
    EMAIL = models.CharField(max_length=150)
    FOTO = models.TextField(blank=True, null=True)
    IDTIPOUSUARIO = models.ForeignKey(
        TipoUsuario, on_delete=models.DO_NOTHING, db_column='IDTIPOUSUARIO',
    )

    class Meta:
        db_table = 'USUARIO'
        managed = False


class TipoPermiso(models.Model):
    IDTIPOPERMISO = models.CharField(max_length=50, primary_key=True)
    DESCRIPCION = models.CharField(max_length=255)

    class Meta:
        db_table = 'TIPO_PERMISO'
        managed = False

    def __str__(self):
        return self.DESCRIPCION


class Modulo(models.Model):
    IDMODULO = models.CharField(max_length=50, primary_key=True)
    NOMBRE = models.CharField(max_length=100)
    DESCRIPCION = models.CharField(max_length=255, blank=True, null=True)
    ICONO = models.CharField(max_length=100, blank=True, null=True)
    ORDEN = models.IntegerField(blank=True, null=True)
    ACTIVO = models.BooleanField(default=True)
    FECHACREACION = models.CharField(max_length=8, blank=True, null=True)
    FECHAACTUALIZACION = models.CharField(max_length=8, blank=True, null=True)

    class Meta:
        db_table = 'MODULO'
        managed = False
        ordering = ['ORDEN', 'NOMBRE']

    def __str__(self):
        return self.NOMBRE


class Submodulo(models.Model):
    IDSUBMODULO = models.CharField(max_length=50, primary_key=True)
    NOMBRE = models.CharField(max_length=100)
    DESCRIPCION = models.CharField(max_length=255, blank=True, null=True)
    ICONO = models.CharField(max_length=100, blank=True, null=True)
    ORDEN = models.IntegerField(blank=True, null=True)
    ACTIVO = models.BooleanField(default=True)
    IDMODULO = models.ForeignKey(Modulo, on_delete=models.CASCADE, db_column='IDMODULO')

    class Meta:
        db_table = 'SUBMODULO'
        managed = False
        ordering = ['ORDEN', 'NOMBRE']

    def __str__(self):
        return f"{self.IDMODULO.NOMBRE} > {self.NOMBRE}"


class GrupoModulo(models.Model):
    IDGRUPOMODULO = models.CharField(max_length=50, primary_key=True)
    IDTIPOUSUARIO = models.CharField(max_length=50)
    IDMODULO = models.ForeignKey(Modulo, on_delete=models.CASCADE, db_column='IDMODULO')
    IDTIPOPERMISO = models.ForeignKey(TipoPermiso, on_delete=models.CASCADE, db_column='IDTIPOPERMISO')

    class Meta:
        db_table = 'GRUPO_MODULO'
        managed = False
        unique_together = ('IDTIPOUSUARIO', 'IDMODULO', 'IDTIPOPERMISO')


class UsuarioModulo(models.Model):
    IDUSUARIOMODULO = models.CharField(max_length=50, primary_key=True)
    IDUSUARIO = models.CharField(max_length=50)
    IDMODULO = models.ForeignKey(Modulo, on_delete=models.CASCADE, db_column='IDMODULO')
    IDTIPOPERMISO = models.ForeignKey(TipoPermiso, on_delete=models.CASCADE, db_column='IDTIPOPERMISO')

    class Meta:
        db_table = 'USUARIO_MODULO'
        managed = False
        unique_together = ('IDUSUARIO', 'IDMODULO', 'IDTIPOPERMISO')


class UsuarioModuloExcluido(models.Model):
    IDUSUARIOEXCLUIDO = models.CharField(max_length=50, primary_key=True)
    IDUSUARIO = models.CharField(max_length=50)
    IDMODULO = models.ForeignKey(Modulo, on_delete=models.CASCADE, db_column='IDMODULO')
    FECHAREGISTRO = models.CharField(max_length=8, blank=True, null=True)

    class Meta:
        db_table = 'USUARIO_MODULO_EXCLUIDO'
        managed = False
        unique_together = ('IDUSUARIO', 'IDMODULO')


class UsuarioSubmoduloExcluido(models.Model):
    IDUSUARIOEXCLSUB = models.CharField(max_length=50, primary_key=True)
    IDUSUARIO = models.CharField(max_length=50)
    IDSUBMODULO = models.ForeignKey(Submodulo, on_delete=models.CASCADE, db_column='IDSUBMODULO')
    FECHAREGISTRO = models.CharField(max_length=8, blank=True, null=True)

    class Meta:
        db_table = 'USUARIO_SUBMODULO_EXCLUIDO'
        managed = False
        unique_together = ('IDUSUARIO', 'IDSUBMODULO')


class GrupoSubmoduloExcluido(models.Model):
    IDGRUPOEXCLSUB = models.CharField(max_length=50, primary_key=True)
    IDTIPOUSUARIO = models.CharField(max_length=50)
    IDSUBMODULO = models.ForeignKey(Submodulo, on_delete=models.CASCADE, db_column='IDSUBMODULO')
    FECHAREGISTRO = models.CharField(max_length=8, blank=True, null=True)

    class Meta:
        db_table = 'GRUPO_SUBMODULO_EXCLUIDO'
        managed = False
        unique_together = ('IDTIPOUSUARIO', 'IDSUBMODULO')


class Aula(models.Model):
    IDAULA = models.CharField(max_length=50, primary_key=True)
    NOMBRE = models.CharField(max_length=100)
    DESCRIPCION = models.TextField(blank=True, null=True)
    CAPACIDAD = models.IntegerField(blank=True, null=True)
    ACTIVO = models.BooleanField(default=True)
    ENLACEVIRTUAL = models.CharField(max_length=255, blank=True, null=True)
    ENLACECUESTIONARIO = models.CharField(max_length=255, blank=True, null=True)
    IDTUTOR = models.CharField(max_length=50, blank=True, null=True)

    class Meta:
        db_table = 'AULA'
        managed = False


class Tutor(models.Model):
    IDTUTOR = models.CharField(max_length=50, primary_key=True)
    NOMBRE = models.CharField(max_length=150)
    ACTIVO = models.BooleanField(default=True)

    class Meta:
        db_table = 'TUTOR'
        managed = False


class Plan(models.Model):
    IDPLAN = models.CharField(max_length=50, primary_key=True)
    NOMBRE = models.CharField(max_length=100)
    DESCRIPCION = models.CharField(max_length=255, blank=True, null=True)
    COSTOMENSUAL = models.DecimalField(max_digits=10, decimal_places=2, blank=True, null=True)
    DIASASISTENCIA = models.PositiveSmallIntegerField(default=63)
    HORAENTRADA = models.TimeField(default='08:00:00')
    TIEMPOEXTRA = models.IntegerField(default=0)
    ACTIVO = models.BooleanField(default=True)

    class Meta:
        db_table = 'PLAN'
        managed = False


class Categoria(models.Model):
    IDCATEGORIA = models.CharField(max_length=50, primary_key=True)
    NOMBRE = models.CharField(max_length=100)
    PORCENTAJE = models.DecimalField(max_digits=5, decimal_places=2, blank=True, null=True)
    ORDEN = models.IntegerField(default=0)
    ACTIVO = models.BooleanField(default=True)

    class Meta:
        db_table = 'CATEGORIA'
        managed = False


class Materia(models.Model):
    IDMATERIA = models.CharField(max_length=50, primary_key=True)
    CODIGO = models.CharField(max_length=50, blank=True, null=True)
    NOMBRE = models.CharField(max_length=150)
    IDCATEGORIA = models.CharField(max_length=50, blank=True, null=True, db_column='IDCATEGORIA')
    ACTIVO = models.BooleanField(default=True)

    class Meta:
        db_table = 'MATERIA'
        managed = False


class Asistencia(models.Model):
    IDASISTENCIA = models.CharField(max_length=50, primary_key=True)
    FECHAREGISTRO = models.CharField(max_length=8, blank=True, null=True)
    HORAINICIO = models.CharField(max_length=8, blank=True, null=True)
    FECHAFINAL = models.CharField(max_length=8, blank=True, null=True)
    HORAFINAL = models.CharField(max_length=8, blank=True, null=True)
    ESTADO = models.CharField(max_length=50, blank=True, null=True)
    JUSTIFICADO = models.BooleanField(default=False)
    IDUSUARIO = models.CharField(max_length=50, db_column='IDUSUARIO')
    IDACTAASISTENCIA = models.CharField(max_length=50, blank=True, null=True, db_column='IDACTAASISTENCIA')

    class Meta:
        db_table = 'ASISTENCIA'
        managed = False
