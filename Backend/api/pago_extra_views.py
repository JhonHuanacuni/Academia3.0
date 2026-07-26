import json
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from .pago_extra_crud_service import (
    listar_pagos_extra,
    obtener_pago_extra,
    insertar_pago_extra,
    actualizar_pago_extra,
    eliminar_pago_extra,
    listar_catalogos_pago_extra,
    conceptos_estudiante,
)


def _parse_body(request):
    try:
        return json.loads(request.body.decode('utf-8'))
    except Exception:
        return None


@csrf_exempt
def pagos_extra_catalogos(request):
    if request.method != 'GET':
        return JsonResponse({'error': 'Método no permitido'}, status=405)
    try:
        return JsonResponse({'data': listar_catalogos_pago_extra()})
    except Exception as exc:
        return JsonResponse({'error': str(exc)}, status=500)


@csrf_exempt
def pagos_extra_conceptos_estudiante(request, id_usuario):
    if request.method != 'GET':
        return JsonResponse({'error': 'Método no permitido'}, status=405)
    try:
        return JsonResponse({'data': conceptos_estudiante(id_usuario)})
    except Exception as exc:
        return JsonResponse({'error': str(exc)}, status=500)


@csrf_exempt
def pagos_extra_mantenedor(request, id_pago=None):
    if request.method == 'GET' and not id_pago:
        try:
            buscar = request.GET.get('buscar') or None
            ordenar_por = request.GET.get('ordenarPor', 'FECHAPAGO')
            direccion = request.GET.get('direccion', 'DESC')
            pagina = int(request.GET.get('pagina', 1))
            tamanio = int(request.GET.get('tamanio', 10))
            data, total = listar_pagos_extra(
                buscar, ordenar_por, direccion, pagina, tamanio,
            )
            return JsonResponse({
                'data': data,
                'total': total,
                'pagina': pagina,
                'tamanioPagina': tamanio,
            })
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=500)

    if request.method == 'GET' and id_pago:
        try:
            row = obtener_pago_extra(id_pago)
            if not row:
                return JsonResponse({'error': 'Pago no encontrado'}, status=404)
            return JsonResponse({'data': row})
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=500)

    if request.method == 'POST' and not id_pago:
        payload = _parse_body(request)
        if not payload:
            return JsonResponse({'error': 'JSON inválido'}, status=400)
        try:
            ok, mensaje, id_gen = insertar_pago_extra(payload)
            status = 200 if ok else 400
            body = {'ok': bool(ok), 'mensaje': mensaje}
            if id_gen:
                body['data'] = {'IDPAGOEXTRA': id_gen}
            return JsonResponse(body, status=status)
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=500)

    if request.method == 'PUT' and id_pago:
        payload = _parse_body(request)
        if not payload:
            return JsonResponse({'error': 'JSON inválido'}, status=400)
        try:
            ok, mensaje = actualizar_pago_extra(id_pago, payload)
            status = 200 if ok else 400
            return JsonResponse({'ok': bool(ok), 'mensaje': mensaje}, status=status)
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=500)

    if request.method == 'DELETE' and id_pago:
        try:
            ok, mensaje = eliminar_pago_extra(id_pago)
            status = 200 if ok else 400
            return JsonResponse({'ok': bool(ok), 'mensaje': mensaje}, status=status)
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=500)

    return JsonResponse({'error': 'Método no permitido'}, status=405)
