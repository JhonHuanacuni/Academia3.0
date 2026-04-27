from django.http import JsonResponse
from .services import get_clientes, get_clientes_sp


def status(request):
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
