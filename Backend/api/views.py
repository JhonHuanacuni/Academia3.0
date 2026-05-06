import json
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from .services import get_clientes, get_clientes_sp, validate_user


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
