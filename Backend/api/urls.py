from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views
from . import usuario_views
from . import asistencia_views
from . import aula_views
from . import informes_views
from . import membresia_views

# Router para ViewSets
router = DefaultRouter()
router.register(r'modulos', views.ModuloViewSet, basename='modulo')
router.register(r'submodulos', views.SubmoduloViewSet, basename='submodulo')
router.register(r'usuario-modulos', views.UsuarioModuloViewSet, basename='usuario-modulo')
router.register(r'grupo-modulos', views.GrupoModuloViewSet, basename='grupo-modulo')

urlpatterns = [
    # URLs originales
    path('status/', views.status_api, name='status'),
    path('clientes/', views.clientes, name='clientes'),
    path('clientes-sp/', views.clientes_sp, name='clientes_sp'),
    path('login/', views.login, name='login'),
    path('usuarios-activos/', views.usuarios_activos, name='usuarios_activos'),
    path('tipos-usuario/', usuario_views.tipos_usuario, name='tipos_usuario'),
    path('usuarios/', usuario_views.usuarios_mantenedor, name='usuarios_mantenedor'),
    path('usuarios/<str:id_usuario>/', usuario_views.usuarios_mantenedor, name='usuarios_mantenedor_detail'),
    path('usuarios/<str:id_usuario>/carnet/', asistencia_views.usuario_carnet, name='usuario_carnet'),
    path('asistencias/', asistencia_views.asistencias_api, name='asistencias_api'),
    path('aulas/', aula_views.aulas_mantenedor, name='aulas_mantenedor'),
    path('aulas/<str:id_aula>/', aula_views.aulas_mantenedor, name='aulas_mantenedor_detail'),
    path('informes/asistencias/', informes_views.informe_asistencias_api, name='informe_asistencias_api'),
    path('membresias/catalogos/', membresia_views.membresias_catalogos, name='membresias_catalogos'),
    path('membresias/estudiantes/', membresia_views.membresias_estudiantes, name='membresias_estudiantes'),
    path('membresias/', membresia_views.membresias_mantenedor, name='membresias_mantenedor'),
    path('membresias/<str:id_membresia>/', membresia_views.membresias_mantenedor, name='membresias_mantenedor_detail'),
    path('menu-usuario/', views.menu_usuario, name='menu_usuario'),
    
    # URLs de módulos - Admin
    path('modulos-disponibles/', views.modulos_disponibles, name='modulos_disponibles'),
    path('modulos-asignados-usuario/', views.modulos_asignados_usuario, name='modulos_asignados_usuario'),
    path('submodulos-modulo-usuario/', views.submodulos_modulo_usuario, name='submodulos_modulo_usuario'),
    
    # Router DRF
    path('', include(router.urls)),
]
