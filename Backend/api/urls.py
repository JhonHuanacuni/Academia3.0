from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

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
    
    # URLs de módulos - Admin
    path('modulos-disponibles/', views.modulos_disponibles, name='modulos_disponibles'),
    path('modulos-asignados-usuario/', views.modulos_asignados_usuario, name='modulos_asignados_usuario'),
    
    # Router DRF
    path('', include(router.urls)),
]
