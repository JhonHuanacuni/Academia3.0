from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views
from . import usuario_views
from . import asistencia_views
from . import aula_views
from . import tutor_views
from . import plan_views
from . import informes_views
from . import mensualidad_views
from . import pago_views
from . import libro_views
from . import horario_views
from . import concepto_views
from . import pago_extra_views
from . import categoria_views
from . import materia_views
from . import examen_views
from . import examen_estudiante_views
from . import justificacion_views
from . import nota_import_views
from . import auditoria_views
from . import dashboard_views

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
    path('usuarios/<str:id_usuario>/qr/', asistencia_views.usuario_qr, name='usuario_qr'),
    path('usuarios/<str:id_usuario>/carnet/', asistencia_views.usuario_carnet, name='usuario_carnet'),
    path('usuarios/<str:id_usuario>/reset-contra/', usuario_views.usuario_resetear_contra, name='usuario_resetear_contra'),
    path('asistencias/', asistencia_views.asistencias_api, name='asistencias_api'),
    path('justificaciones/', justificacion_views.justificaciones_mantenedor, name='justificaciones_mantenedor'),
    path('justificaciones/<str:id_justificacion>/', justificacion_views.justificaciones_mantenedor, name='justificaciones_mantenedor_detail'),
    path('aulas/', aula_views.aulas_mantenedor, name='aulas_mantenedor'),
    path('aulas/<str:id_aula>/', aula_views.aulas_mantenedor, name='aulas_mantenedor_detail'),
    path('tutores/', tutor_views.tutores_mantenedor, name='tutores_mantenedor'),
    path('tutores/<str:id_tutor>/', tutor_views.tutores_mantenedor, name='tutores_mantenedor_detail'),
    path('planes/catalogos/', plan_views.planes_catalogos, name='planes_catalogos'),
    path('planes/', plan_views.planes_mantenedor, name='planes_mantenedor'),
    path('planes/<str:id_plan>/', plan_views.planes_mantenedor, name='planes_mantenedor_detail'),
    path('informes/asistencias/', informes_views.informe_asistencias_api, name='informe_asistencias_api'),
    path('dashboard/', dashboard_views.dashboard_api, name='dashboard_api'),
    path('mensualidades/catalogos/', mensualidad_views.mensualidades_catalogos, name='mensualidades_catalogos'),
    path('mensualidades/estudiantes/', mensualidad_views.mensualidades_estudiantes, name='mensualidades_estudiantes'),
    path('mensualidades/', mensualidad_views.mensualidades_mantenedor, name='mensualidades_mantenedor'),
    path('mensualidades/estudiante/<str:id_usuario>/', mensualidad_views.mensualidades_por_estudiante, name='mensualidades_por_estudiante'),
    path('mensualidades/<str:id_mensualidad>/pagos/', mensualidad_views.mensualidad_pagos, name='mensualidad_pagos'),
    path('mensualidades/<str:id_mensualidad>/', mensualidad_views.mensualidades_mantenedor, name='mensualidades_mantenedor_detail'),
    path('pagos/catalogos/', pago_views.pagos_catalogos, name='pagos_catalogos'),
    path('pagos/estudiante/<str:id_usuario>/mensualidades/', pago_views.pagos_mensualidades_estudiante, name='pagos_mensualidades_estudiante'),
    path('pagos/', pago_views.pagos_mantenedor, name='pagos_mantenedor'),
    path('pagos/<str:id_pago>/', pago_views.pagos_mantenedor, name='pagos_mantenedor_detail'),
    path('libros/catalogos/', libro_views.libros_catalogos, name='libros_catalogos'),
    path('libros/', libro_views.libros_mantenedor, name='libros_mantenedor'),
    path('libros/<str:id_libro>/', libro_views.libros_mantenedor, name='libros_mantenedor_detail'),
    path('horarios/catalogos/', horario_views.horarios_catalogos, name='horarios_catalogos'),
    path('horarios/', horario_views.horarios_mantenedor, name='horarios_mantenedor'),
    path('horarios/<str:id_horario>/', horario_views.horarios_mantenedor, name='horarios_mantenedor_detail'),
    path('conceptos/', concepto_views.conceptos_mantenedor, name='conceptos_mantenedor'),
    path('conceptos/<str:id_concepto>/', concepto_views.conceptos_mantenedor, name='conceptos_mantenedor_detail'),
    path('pagos-extraordinarios/catalogos/', pago_extra_views.pagos_extra_catalogos, name='pagos_extra_catalogos'),
    path(
        'pagos-extraordinarios/estudiante/<str:id_usuario>/conceptos/',
        pago_extra_views.pagos_extra_conceptos_estudiante,
        name='pagos_extra_conceptos_estudiante',
    ),
    path('pagos-extraordinarios/', pago_extra_views.pagos_extra_mantenedor, name='pagos_extra_mantenedor'),
    path('pagos-extraordinarios/<str:id_pago>/', pago_extra_views.pagos_extra_mantenedor, name='pagos_extra_mantenedor_detail'),
    path('categorias/', categoria_views.categorias_mantenedor, name='categorias_mantenedor'),
    path('categorias/<str:id_categoria>/', categoria_views.categorias_mantenedor, name='categorias_mantenedor_detail'),
    path('materias/catalogos/', materia_views.materias_catalogos, name='materias_catalogos'),
    path('materias/', materia_views.materias_mantenedor, name='materias_mantenedor'),
    path('materias/<str:id_materia>/', materia_views.materias_mantenedor, name='materias_mantenedor_detail'),
    path('examenes/catalogos/', examen_views.examenes_catalogos, name='examenes_catalogos'),
    path('examenes/distribucion/', examen_views.examenes_distribucion, name='examenes_distribucion'),
    path(
        'examenes/estudiante/',
        examen_estudiante_views.examenes_estudiante_listar,
        name='examenes_estudiante_listar',
    ),
    path(
        'examenes/estudiante/<str:id_examen>/iniciar/',
        examen_estudiante_views.examenes_estudiante_iniciar,
        name='examenes_estudiante_iniciar',
    ),
    path(
        'examenes/estudiante/intento/<str:id_intento>/',
        examen_estudiante_views.examenes_estudiante_intento,
        name='examenes_estudiante_intento',
    ),
    path(
        'examenes/estudiante/intento/<str:id_intento>/responder/',
        examen_estudiante_views.examenes_estudiante_responder,
        name='examenes_estudiante_responder',
    ),
    path(
        'examenes/estudiante/intento/<str:id_intento>/finalizar/',
        examen_estudiante_views.examenes_estudiante_finalizar,
        name='examenes_estudiante_finalizar',
    ),
    path('examenes/', examen_views.examenes_mantenedor, name='examenes_mantenedor'),
    path('examenes/<str:id_examen>/', examen_views.examenes_mantenedor, name='examenes_mantenedor_detail'),
    path(
        'examenes/<str:id_examen>/preguntas/<str:id_pregunta>/',
        examen_views.examenes_pregunta,
        name='examenes_pregunta',
    ),
    path('notas-importacion/catalogos/', nota_import_views.notas_importacion_catalogos, name='notas_importacion_catalogos'),
    path('notas-importacion/importar/', nota_import_views.notas_importacion_importar, name='notas_importacion_importar'),
    path('notas-importacion/', nota_import_views.notas_importacion_mantenedor, name='notas_importacion_mantenedor'),
    path('notas-importacion/<int:id_importacion>/', nota_import_views.notas_importacion_mantenedor, name='notas_importacion_mantenedor_detail'),
    path('auditoria/catalogos/', auditoria_views.auditoria_mantenedor, {'id_auditoria': 'catalogos'}),
    path('auditoria/', auditoria_views.auditoria_mantenedor, name='auditoria_mantenedor'),
    path('auditoria/<str:id_auditoria>/', auditoria_views.auditoria_mantenedor, name='auditoria_mantenedor_detail'),
    path('menu-usuario/', views.menu_usuario, name='menu_usuario'),
    
    # URLs de módulos - Admin
    path('modulos-disponibles/', views.modulos_disponibles, name='modulos_disponibles'),
    path('modulos-asignados-usuario/', views.modulos_asignados_usuario, name='modulos_asignados_usuario'),
    path('modulos-asignados-rol/', views.modulos_asignados_rol, name='modulos_asignados_rol'),
    path('submodulos-modulo-usuario/', views.submodulos_modulo_usuario, name='submodulos_modulo_usuario'),
    path('submodulos-modulo-rol/', views.submodulos_modulo_rol, name='submodulos_modulo_rol'),
    
    # Router DRF
    path('', include(router.urls)),
]
