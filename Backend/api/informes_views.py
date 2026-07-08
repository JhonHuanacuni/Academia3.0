from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt

from .informes_service import informe_asistencias, informe_asistencias_orm


@csrf_exempt
def informe_asistencias_api(request):
    if request.method != 'GET':
        return JsonResponse({'error': 'Método no permitido'}, status=405)

    fecha_desde = request.GET.get('fechaDesde') or request.GET.get('fecha_desde')
    fecha_hasta = request.GET.get('fechaHasta') or request.GET.get('fecha_hasta')
    buscar = request.GET.get('buscar')
    id_plan = request.GET.get('idPlan') or request.GET.get('id_plan')
    estado_usuario = request.GET.get('estado') or request.GET.get('estadoUsuario')

    try:
        try:
            data = informe_asistencias(fecha_desde, fecha_hasta, buscar, id_plan, estado_usuario)
        except Exception:
            data = informe_asistencias_orm(fecha_desde, fecha_hasta, buscar, id_plan, estado_usuario)
        return JsonResponse(data)
    except ValueError as exc:
        return JsonResponse({'error': str(exc)}, status=400)
    except Exception as exc:
        return JsonResponse({'error': str(exc)}, status=500)
