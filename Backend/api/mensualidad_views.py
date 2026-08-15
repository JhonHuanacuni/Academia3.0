import json
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from .db_context import actor_from_request
from .mensualidad_crud_service import (
    listar_mensualidades,
    obtener_mensualidad,
    insertar_mensualidad,
    actualizar_mensualidad,
    eliminar_mensualidad,
    buscar_estudiantes,
    listar_catalogos,
    listar_mensualidades_estudiante,
    listar_pagos_mensualidad,
    listar_cuotas,
)


def _parse_body(request):
    try:
        return json.loads(request.body.decode('utf-8'))
    except Exception:
        return None


@csrf_exempt
def mensualidades_catalogos(request):
    if request.method != 'GET':
        return JsonResponse({'error': 'Método no permitido'}, status=405)
    try:
        id_registrador = request.GET.get('idusuario') or None
        return JsonResponse({'data': listar_catalogos(id_registrador)})
    except Exception as exc:
        return JsonResponse({'error': str(exc)}, status=500)


@csrf_exempt
def mensualidades_estudiantes(request):
    if request.method != 'GET':
        return JsonResponse({'error': 'Método no permitido'}, status=405)
    try:
        buscar = request.GET.get('buscar') or None
        return JsonResponse({'data': buscar_estudiantes(buscar)})
    except Exception as exc:
        return JsonResponse({'error': str(exc)}, status=500)


@csrf_exempt
def mensualidades_mantenedor(request, id_mensualidad=None):
    if request.method == 'GET' and not id_mensualidad:
        try:
            buscar = request.GET.get('buscar') or None
            deuda = request.GET.get('deuda') or request.GET.get('estado') or None
            ordenar_por = request.GET.get('ordenarPor', 'FECHAREGISTRO')
            direccion = request.GET.get('direccion', 'DESC')
            pagina = int(request.GET.get('pagina', 1))
            tamanio = int(request.GET.get('tamanio', 10))
            data, total = listar_mensualidades(
                buscar, deuda, ordenar_por, direccion, pagina, tamanio,
            )
            return JsonResponse({
                'data': data,
                'total': total,
                'pagina': pagina,
                'tamanioPagina': tamanio,
            })
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=500)

    if request.method == 'GET' and id_mensualidad:
        try:
            row = obtener_mensualidad(id_mensualidad)
            if not row:
                return JsonResponse({'error': 'Mensualidad no encontrada'}, status=404)
            return JsonResponse({'data': row})
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=500)

    if request.method == 'POST' and not id_mensualidad:
        payload = _parse_body(request)
        if not payload:
            return JsonResponse({'error': 'JSON inválido'}, status=400)
        try:
            ok, mensaje = insertar_mensualidad(payload, actor_from_request(request, payload))
            status = 200 if ok else 400
            return JsonResponse({'ok': bool(ok), 'mensaje': mensaje}, status=status)
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=500)

    if request.method == 'PUT' and id_mensualidad:
        payload = _parse_body(request)
        if not payload:
            return JsonResponse({'error': 'JSON inválido'}, status=400)
        try:
            ok, mensaje = actualizar_mensualidad(id_mensualidad, payload, actor_from_request(request, payload))
            status = 200 if ok else 400
            return JsonResponse({'ok': bool(ok), 'mensaje': mensaje}, status=status)
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=500)

    if request.method == 'DELETE' and id_mensualidad:
        try:
            id_usuario = request.GET.get('idusuario') or None
            ok, mensaje = eliminar_mensualidad(id_mensualidad, actor_from_request(request) or id_usuario)
            status = 200 if ok else 400
            return JsonResponse({'ok': bool(ok), 'mensaje': mensaje}, status=status)
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=500)

    return JsonResponse({'error': 'Método no permitido'}, status=405)


@csrf_exempt
def mensualidades_por_estudiante(request, id_usuario):
    if request.method != 'GET':
        return JsonResponse({'error': 'Método no permitido'}, status=405)
    try:
        return JsonResponse({'data': listar_mensualidades_estudiante(id_usuario)})
    except Exception as exc:
        return JsonResponse({'error': str(exc)}, status=500)


@csrf_exempt
def mensualidad_pagos(request, id_mensualidad):
    if request.method != 'GET':
        return JsonResponse({'error': 'Método no permitido'}, status=405)
    try:
        return JsonResponse({'data': listar_pagos_mensualidad(id_mensualidad)})
    except Exception as exc:
        return JsonResponse({'error': str(exc)}, status=500)


@csrf_exempt
def mensualidad_cuotas(request, id_mensualidad):
    if request.method != 'GET':
        return JsonResponse({'error': 'Método no permitido'}, status=405)
    try:
        return JsonResponse({'data': listar_cuotas(id_mensualidad)})
    except Exception as exc:
        return JsonResponse({'error': str(exc)}, status=500)
