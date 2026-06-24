from rest_framework import serializers
from .models import Modulo, Submodulo, UsuarioModulo, GrupoModulo, TipoPermiso


class TipoPermisoSerializer(serializers.ModelSerializer):
    class Meta:
        model = TipoPermiso
        fields = ['IDPERMISO', 'NOMBRE', 'DESCRIPCION']


class SubmoduloSerializer(serializers.ModelSerializer):
    class Meta:
        model = Submodulo
        fields = ['IDSUBMODULO', 'NOMBRE', 'DESCRIPCION', 'ICONO', 'ORDEN', 'ACTIVO']


class ModuloSerializer(serializers.ModelSerializer):
    submodulos = SubmoduloSerializer(source='submodulo_set', many=True, read_only=True)

    class Meta:
        model = Modulo
        fields = ['IDMODULO', 'NOMBRE', 'DESCRIPCION', 'ICONO', 'ORDEN', 'ACTIVO', 'submodulos']


class ModuloSimpleSerializer(serializers.ModelSerializer):
    """Serializer simplificado para listas de módulos"""
    class Meta:
        model = Modulo
        fields = ['IDMODULO', 'NOMBRE', 'DESCRIPCION', 'ICONO', 'ORDEN']


class UsuarioModuloSerializer(serializers.ModelSerializer):
    modulo_detail = ModuloSimpleSerializer(source='IDMODULO', read_only=True)

    class Meta:
        model = UsuarioModulo
        fields = ['IDUSUARIO_MODULO', 'IDUSUARIO', 'IDMODULO', 'modulo_detail', 'PERMISOS', 'ACTIVO']


class GrupoModuloSerializer(serializers.ModelSerializer):
    modulo_detail = ModuloSimpleSerializer(source='IDMODULO', read_only=True)

    class Meta:
        model = GrupoModulo
        fields = ['IDGRUPO_MODULO', 'IDGRUPO', 'IDMODULO', 'modulo_detail', 'PERMISOS', 'ACTIVO']
