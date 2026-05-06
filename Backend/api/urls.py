from django.urls import path
from . import views

urlpatterns = [
    path('status/', views.status, name='status'),
    path('clientes/', views.clientes, name='clientes'),
    path('clientes-sp/', views.clientes_sp, name='clientes_sp'),
    path('login/', views.login, name='login'),
]
