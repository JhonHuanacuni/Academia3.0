from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt

from . import examen_resultados_service as svc


def _idusuario(request):
    return (
        request.GET.get('idusuario')
        or request.GET.get('idUsuario')
        or request.headers.get('X-Id-Usuario')
        or ''
    ).strip()


@csrf_exempt
def resultados_catalogos(request):
    if request.method != 'GET':
        return JsonResponse({'ok': False, 'mensaje': 'Método no permitido'}, status=405)
    idusuario = _idusuario(request)
    if not idusuario:
        return JsonResponse({'ok': False, 'mensaje': 'Falta idusuario'}, status=400)
    try:
        data = svc.catalogos_resultados(idusuario)
        return JsonResponse({'ok': True, 'data': data})
    except Exception as exc:
        return JsonResponse({'ok': False, 'mensaje': str(exc)}, status=500)


@csrf_exempt
def resultados_listar(request):
    if request.method != 'GET':
        return JsonResponse({'ok': False, 'mensaje': 'Método no permitido'}, status=405)
    idusuario = _idusuario(request)
    if not idusuario:
        return JsonResponse({'ok': False, 'mensaje': 'Falta idusuario'}, status=400)
    try:
        data = svc.listar_resultados(
            idusuario,
            buscar=request.GET.get('buscar'),
            id_examen=request.GET.get('idExamen') or request.GET.get('id_examen'),
            id_aula=request.GET.get('idAula') or request.GET.get('id_aula'),
            pagina=request.GET.get('pagina') or 1,
            tamanio=request.GET.get('tamanio') or request.GET.get('tamanioPagina') or 20,
        )
        return JsonResponse({'ok': True, **data})
    except ValueError as exc:
        return JsonResponse({'ok': False, 'mensaje': str(exc)}, status=400)
    except Exception as exc:
        return JsonResponse({'ok': False, 'mensaje': str(exc)}, status=500)


@csrf_exempt
def resultados_detalle(request, id_intento):
    if request.method != 'GET':
        return JsonResponse({'ok': False, 'mensaje': 'Método no permitido'}, status=405)
    idusuario = _idusuario(request)
    if not idusuario:
        return JsonResponse({'ok': False, 'mensaje': 'Falta idusuario'}, status=400)
    try:
        data = svc.detalle_resultado(id_intento, idusuario)
        if data is None:
            return JsonResponse({'ok': False, 'mensaje': 'Resultado no encontrado'}, status=404)
        return JsonResponse({'ok': True, **data})
    except PermissionError as exc:
        return JsonResponse({'ok': False, 'mensaje': str(exc)}, status=403)
    except ValueError as exc:
        return JsonResponse({'ok': False, 'mensaje': str(exc)}, status=400)
    except Exception as exc:
        return JsonResponse({'ok': False, 'mensaje': str(exc)}, status=500)
