import json
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from .auditoria_service import listar_auditoria, obtener_auditoria, listar_tablas_auditoria


@csrf_exempt
def auditoria_mantenedor(request, id_auditoria=None):
    if request.method == 'GET' and not id_auditoria:
        try:
            buscar = request.GET.get('buscar') or None
            tabla = request.GET.get('tabla') or None
            accion = request.GET.get('accion') or None
            id_usuario = request.GET.get('idUsuario') or None
            fecha_desde = request.GET.get('fechaDesde') or None
            fecha_hasta = request.GET.get('fechaHasta') or None
            ordenar_por = request.GET.get('ordenarPor', 'FECHA')
            direccion = request.GET.get('direccion', 'DESC')
            pagina = int(request.GET.get('pagina', 1))
            tamanio = int(request.GET.get('tamanio', 10))
            data, total = listar_auditoria(
                buscar, tabla, accion, id_usuario,
                fecha_desde, fecha_hasta,
                ordenar_por, direccion, pagina, tamanio,
            )
            return JsonResponse({
                'data': data,
                'total': total,
                'pagina': pagina,
                'tamanioPagina': tamanio,
            })
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=500)

    if request.method == 'GET' and id_auditoria == 'catalogos':
        try:
            tablas = listar_tablas_auditoria()
            return JsonResponse({
                'tablas': [r.get('TABLA') for r in tablas if r.get('TABLA')],
                'acciones': ['INSERT', 'UPDATE', 'DELETE'],
            })
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=500)

    if request.method == 'GET' and id_auditoria:
        try:
            row = obtener_auditoria(id_auditoria)
            if not row:
                return JsonResponse({'error': 'Registro no encontrado'}, status=404)
            return JsonResponse({'data': row})
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=500)

    return JsonResponse({'error': 'Método no permitido'}, status=405)
