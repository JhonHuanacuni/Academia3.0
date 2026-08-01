import json

from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt

from .nota_import_service import (
    eliminar_importacion,
    importar_notas,
    listar_aulas_activas,
    listar_importaciones,
    obtener_importacion,
)
from .db_context import actor_from_request


def _parse_body(request):
    try:
        return json.loads(request.body.decode('utf-8'))
    except Exception:
        return None


@csrf_exempt
def notas_importacion_catalogos(request):
    if request.method != 'GET':
        return JsonResponse({'error': 'Método no permitido'}, status=405)
    try:
        return JsonResponse({'data': {'aulas': listar_aulas_activas()}})
    except Exception as exc:
        return JsonResponse({'error': str(exc)}, status=500)


@csrf_exempt
def notas_importacion_importar(request):
    if request.method != 'POST':
        return JsonResponse({'error': 'Método no permitido'}, status=405)
    payload = _parse_body(request)
    if not payload:
        return JsonResponse({'error': 'JSON inválido'}, status=400)
    id_usuario = request.GET.get('idusuario') or payload.get('idusuario')
    try:
        result = importar_notas(payload, id_usuario)
        return JsonResponse(result)
    except ValueError as exc:
        return JsonResponse({'error': str(exc), 'created': 0}, status=400)
    except Exception as exc:
        return JsonResponse({'error': str(exc), 'created': 0}, status=500)


@csrf_exempt
def notas_importacion_mantenedor(request, id_importacion=None):
    if request.method == 'GET' and not id_importacion:
        try:
            buscar = request.GET.get('buscar') or None
            tipo = request.GET.get('tipo') or None
            ordenar_por = request.GET.get('ordenarPor', 'FECHA_EXAMEN')
            direccion = request.GET.get('direccion', 'DESC')
            pagina = int(request.GET.get('pagina', 1))
            tamanio = int(request.GET.get('tamanio', 10))
            data, total = listar_importaciones(
                buscar, tipo, ordenar_por, direccion, pagina, tamanio,
            )
            return JsonResponse({
                'data': data,
                'total': total,
                'pagina': pagina,
                'tamanioPagina': tamanio,
            })
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=500)

    if request.method == 'GET' and id_importacion:
        try:
            row = obtener_importacion(id_importacion)
            if not row:
                return JsonResponse({'error': 'Importación no encontrada'}, status=404)
            return JsonResponse({'data': row})
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=500)

    if request.method == 'DELETE' and id_importacion:
        try:
            ok, mensaje = eliminar_importacion(id_importacion, actor_from_request(request))
            status = 200 if ok else 400
            return JsonResponse({'ok': bool(ok), 'mensaje': mensaje}, status=status)
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=500)

    return JsonResponse({'error': 'Método no permitido'}, status=405)
