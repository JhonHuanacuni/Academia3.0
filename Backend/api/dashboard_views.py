from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt

from .dashboard_service import obtener_dashboard


@csrf_exempt
def dashboard_api(request):
    if request.method != 'GET':
        return JsonResponse({'error': 'Método no permitido'}, status=405)

    id_usuario = (
        request.GET.get('idusuario')
        or request.headers.get('X-IdUsuario')
    )
    if not id_usuario:
        return JsonResponse({'error': 'Indica idusuario.'}, status=400)

    try:
        data = obtener_dashboard(
            str(id_usuario).strip(),
            request.GET.get('fecha_desde'),
            request.GET.get('fecha_hasta'),
            request.GET.get('estado_estudiante', 'Activo'),
        )
        return JsonResponse({'data': data})
    except ValueError as exc:
        return JsonResponse({'error': str(exc)}, status=400)
    except Exception as exc:
        return JsonResponse({'error': str(exc)}, status=500)
