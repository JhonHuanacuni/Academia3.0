import json
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.db.models import Q
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from .services import get_clientes, get_clientes_sp, validate_user
from .models import Modulo, Submodulo, UsuarioModulo, GrupoModulo
from .serializers import (
    ModuloSerializer, SubmoduloSerializer, UsuarioModuloSerializer,
    GrupoModuloSerializer, ModuloSimpleSerializer
)


def status_api(request):
    return JsonResponse({
        'message': 'Django backend conectado',
        'status': 'ok',
    })


def clientes(request):
    return JsonResponse({'clientes': get_clientes()})


def clientes_sp(request):
    try:
        data = get_clientes_sp()
    except Exception as exc:
        return JsonResponse({'error': str(exc)}, status=500)
    return JsonResponse({'clientes': data})


@csrf_exempt
def login(request):
    if request.method != 'POST':
        return JsonResponse({'error': 'Method not allowed'}, status=405)

    try:
        payload = json.loads(request.body.decode('utf-8'))
    except Exception:
        return JsonResponse({'error': 'JSON inválido'}, status=400)

    username = payload.get('username')
    password = payload.get('password')

    if not username or not password:
        return JsonResponse({'error': 'username y password son requeridos'}, status=400)

    try:
        valid, role = validate_user(username, password)
    except Exception as exc:
        return JsonResponse({'error': str(exc)}, status=500)

    return JsonResponse({'valid': valid, 'role': role})


# ============================================
# ViewSets para Gestión de Módulos
# ============================================

class ModuloViewSet(viewsets.ReadOnlyModelViewSet):
    """ViewSet para Módulos - Solo lectura"""
    queryset = Modulo.objects.filter(ACTIVO=True).order_by('ORDEN')
    serializer_class = ModuloSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        # Filtrar módulos activos
        return Modulo.objects.filter(ACTIVO=True).order_by('ORDEN')


class SubmoduloViewSet(viewsets.ReadOnlyModelViewSet):
    """ViewSet para Submódulos"""
    queryset = Submodulo.objects.filter(ACTIVO=True).order_by('ORDEN')
    serializer_class = SubmoduloSerializer
    permission_classes = [IsAuthenticated]


class UsuarioModuloViewSet(viewsets.ModelViewSet):
    """ViewSet para Asignación de Módulos a Usuarios"""
    queryset = UsuarioModulo.objects.filter(ACTIVO=True)
    serializer_class = UsuarioModuloSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        # Los usuarios normales solo ven sus propios módulos
        # Los admins ven todos
        user = self.request.user
        # Aquí necesitarías verificar si el usuario es admin
        # Por ahora retornamos todos (ajusta según tu lógica de permisos)
        return UsuarioModulo.objects.filter(ACTIVO=True)


class GrupoModuloViewSet(viewsets.ModelViewSet):
    """ViewSet para Asignación de Módulos a Grupos"""
    queryset = GrupoModulo.objects.filter(ACTIVO=True)
    serializer_class = GrupoModuloSerializer
    permission_classes = [IsAuthenticated]


# ============================================
# Vistas personalizadas para Admin de Módulos
# ============================================

@csrf_exempt
def modulos_disponibles(request):
    """
    GET: Retorna lista de módulos disponibles con submódulos
    Usado en el panel de admin para mostrar módulos sin asignar
    """
    if request.method != 'GET':
        return JsonResponse({'error': 'Método no permitido'}, status=405)

    try:
        modulos = Modulo.objects.filter(ACTIVO=True).values(
            'IDMODULO', 'NOMBRE', 'DESCRIPCION', 'ICONO', 'ORDEN'
        ).order_by('ORDEN')

        modulos_list = list(modulos)
        
        # Agregar submódulos a cada módulo
        for mod in modulos_list:
            submodulos = Submodulo.objects.filter(
                IDMODULO_id=mod['IDMODULO'], ACTIVO=True
            ).values('IDSUBMODULO', 'NOMBRE', 'ICONO', 'ORDEN').order_by('ORDEN')
            mod['submodulos'] = list(submodulos)

        return JsonResponse({
            'success': True,
            'modulos': modulos_list
        })
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)


@csrf_exempt
def modulos_asignados_usuario(request):
    """
    GET: Retorna módulos asignados a un usuario específico
    POST: Asigna/desasigna módulos a un usuario
    """
    if request.method == 'GET':
        idusuario = request.GET.get('idusuario')
        if not idusuario:
            return JsonResponse({'error': 'idusuario es requerido'}, status=400)

        try:
            asignados = UsuarioModulo.objects.filter(
                IDUSUARIO=idusuario, ACTIVO=True
            ).values(
                'IDUSUARIO_MODULO', 'IDMODULO_id', 'IDMODULO__NOMBRE',
                'IDMODULO__ICONO', 'PERMISOS'
            ).order_by('IDMODULO__NOMBRE')

            return JsonResponse({
                'success': True,
                'asignados': list(asignados)
            })
        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)

    elif request.method == 'POST':
        try:
            payload = json.loads(request.body.decode('utf-8'))
        except Exception:
            return JsonResponse({'error': 'JSON inválido'}, status=400)

        idusuario = payload.get('idusuario')
        idmodulo = payload.get('idmodulo')
        accion = payload.get('accion')  # 'asignar' o 'desasignar'
        permisos = payload.get('permisos', ['read'])

        if not idusuario or not idmodulo or not accion:
            return JsonResponse({'error': 'Faltan parámetros requeridos'}, status=400)

        try:
            if accion == 'asignar':
                # Verificar que el módulo existe
                modulo = Modulo.objects.get(IDMODULO=idmodulo, ACTIVO=True)
                
                # Generar ID único
                import uuid
                idusuario_modulo = f"USR_MOD_{uuid.uuid4().hex[:12].upper()}"
                
                # Crear asignación
                UsuarioModulo.objects.create(
                    IDUSUARIO_MODULO=idusuario_modulo,
                    IDUSUARIO=idusuario,
                    IDMODULO=modulo,
                    PERMISOS=permisos,
                    ASIGNADO_POR=request.user.username if request.user.is_authenticated else 'SISTEMA'
                )
                return JsonResponse({'success': True, 'message': 'Módulo asignado'})

            elif accion == 'desasignar':
                # Desactivar asignación (soft delete)
                UsuarioModulo.objects.filter(
                    IDUSUARIO=idusuario,
                    IDMODULO_id=idmodulo
                ).update(ACTIVO=False)
                return JsonResponse({'success': True, 'message': 'Módulo desasignado'})

        except Modulo.DoesNotExist:
            return JsonResponse({'error': 'Módulo no encontrado'}, status=404)
        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)

    return JsonResponse({'error': 'Método no permitido'}, status=405)

