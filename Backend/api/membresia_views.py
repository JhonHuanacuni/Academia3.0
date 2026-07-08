import json
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from .membresia_crud_service import (
    listar_membresias,
    obtener_membresia,
    insertar_membresia,
    actualizar_membresia,
    eliminar_membresia,
    buscar_estudiantes,
    listar_catalogos,
)


def _parse_body(request):
    try:
        return json.loads(request.body.decode('utf-8'))
    except Exception:
        return None


@csrf_exempt
def membresias_catalogos(request):
    if request.method != 'GET':
        return JsonResponse({'error': 'Método no permitido'}, status=405)
    try:
        return JsonResponse({'data': listar_catalogos()})
    except Exception as exc:
        return JsonResponse({'error': str(exc)}, status=500)


@csrf_exempt
def membresias_estudiantes(request):
    if request.method != 'GET':
        return JsonResponse({'error': 'Método no permitido'}, status=405)
    try:
        buscar = request.GET.get('buscar') or None
        return JsonResponse({'data': buscar_estudiantes(buscar)})
    except Exception as exc:
        return JsonResponse({'error': str(exc)}, status=500)


@csrf_exempt
def membresias_mantenedor(request, id_membresia=None):
    if request.method == 'GET' and not id_membresia:
        try:
            buscar = request.GET.get('buscar') or None
            estado = request.GET.get('estado') or None
            ordenar_por = request.GET.get('ordenarPor', 'FECHAREGISTRO')
            direccion = request.GET.get('direccion', 'DESC')
            pagina = int(request.GET.get('pagina', 1))
            tamanio = int(request.GET.get('tamanio', 10))
            data, total = listar_membresias(
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

    if request.method == 'GET' and id_membresia:
        try:
            row = obtener_membresia(id_membresia)
            if not row:
                return JsonResponse({'error': 'Membresía no encontrada'}, status=404)
            return JsonResponse({'data': row})
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=500)

    if request.method == 'POST' and not id_membresia:
        payload = _parse_body(request)
        if not payload:
            return JsonResponse({'error': 'JSON inválido'}, status=400)
        try:
            ok, mensaje = insertar_membresia(payload)
            status = 200 if ok else 400
            return JsonResponse({'ok': bool(ok), 'mensaje': mensaje}, status=status)
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=500)

    if request.method == 'PUT' and id_membresia:
        payload = _parse_body(request)
        if not payload:
            return JsonResponse({'error': 'JSON inválido'}, status=400)
        try:
            ok, mensaje = actualizar_membresia(id_membresia, payload)
            status = 200 if ok else 400
            return JsonResponse({'ok': bool(ok), 'mensaje': mensaje}, status=status)
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=500)

    if request.method == 'DELETE' and id_membresia:
        try:
            id_usuario = request.GET.get('idusuario') or None
            ok, mensaje = eliminar_membresia(id_membresia, id_usuario)
            status = 200 if ok else 400
            return JsonResponse({'ok': bool(ok), 'mensaje': mensaje}, status=status)
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=500)

    return JsonResponse({'error': 'Método no permitido'}, status=405)
