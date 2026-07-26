import json
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from .tutor_crud_service import (
    listar_tutores,
    obtener_tutor,
    insertar_tutor,
    actualizar_tutor,
    eliminar_tutor,
)


def _parse_body(request):
    try:
        return json.loads(request.body.decode('utf-8'))
    except Exception:
        return None


@csrf_exempt
def tutores_mantenedor(request, id_tutor=None):
    if request.method == 'GET' and not id_tutor:
        try:
            buscar = request.GET.get('buscar') or None
            estado = request.GET.get('estado') or None
            ordenar_por = request.GET.get('ordenarPor', 'NOMBRE')
            direccion = request.GET.get('direccion', 'ASC')
            pagina = int(request.GET.get('pagina', 1))
            tamanio = int(request.GET.get('tamanio', 10))
            data, total = listar_tutores(
                buscar, estado, ordenar_por, direccion, pagina, tamanio,
            )
            return JsonResponse({
                'data': data,
                'total': total,
                'pagina': pagina,
                'tamanioPagina': tamanio,
            })
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=500)

    if request.method == 'GET' and id_tutor:
        try:
            row = obtener_tutor(id_tutor)
            if not row:
                return JsonResponse({'error': 'Tutor no encontrado'}, status=404)
            return JsonResponse({'data': row})
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=500)

    if request.method == 'POST' and not id_tutor:
        payload = _parse_body(request)
        if not payload:
            return JsonResponse({'error': 'JSON inválido'}, status=400)
        try:
            ok, mensaje = insertar_tutor(payload)
            status = 200 if ok else 400
            return JsonResponse({'ok': bool(ok), 'mensaje': mensaje}, status=status)
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=500)

    if request.method == 'PUT' and id_tutor:
        payload = _parse_body(request)
        if not payload:
            return JsonResponse({'error': 'JSON inválido'}, status=400)
        try:
            ok, mensaje = actualizar_tutor(id_tutor, payload)
            status = 200 if ok else 400
            return JsonResponse({'ok': bool(ok), 'mensaje': mensaje}, status=status)
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=500)

    if request.method == 'DELETE' and id_tutor:
        try:
            ok, mensaje = eliminar_tutor(id_tutor)
            status = 200 if ok else 400
            return JsonResponse({'ok': bool(ok), 'mensaje': mensaje}, status=status)
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=500)

    return JsonResponse({'error': 'Método no permitido'}, status=405)
