import json
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from .db_context import actor_from_request
from .justificacion_crud_service import (
    listar_justificaciones,
    obtener_justificacion,
    insertar_justificacion,
    actualizar_justificacion,
    eliminar_justificacion,
)


def _parse_body(request):
    try:
        return json.loads(request.body.decode('utf-8'))
    except Exception:
        return None


@csrf_exempt
def justificaciones_mantenedor(request, id_justificacion=None):
    if request.method == 'GET' and not id_justificacion:
        try:
            buscar = request.GET.get('buscar') or None
            id_tutor = request.GET.get('idTutor') or None
            id_plan = request.GET.get('idPlan') or None
            fecha_desde = request.GET.get('fechaDesde') or None
            fecha_hasta = request.GET.get('fechaHasta') or None
            pagina = int(request.GET.get('pagina', 1))
            tamanio = int(request.GET.get('tamanio', 10))
            data, total = listar_justificaciones(
                buscar,
                id_tutor,
                id_plan,
                fecha_desde,
                fecha_hasta,
                pagina,
                tamanio,
            )
            return JsonResponse({
                'data': data,
                'total': total,
                'pagina': pagina,
                'tamanioPagina': tamanio,
            })
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=500)

    if request.method == 'GET' and id_justificacion:
        try:
            row = obtener_justificacion(id_justificacion)
            if not row:
                return JsonResponse({'error': 'Justificación no encontrada'}, status=404)
            return JsonResponse({'data': row})
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=500)

    if request.method == 'POST' and not id_justificacion:
        payload = _parse_body(request)
        if not payload:
            return JsonResponse({'error': 'JSON inválido'}, status=400)
        try:
            ok, mensaje = insertar_justificacion(payload, actor_from_request(request, payload))
            status = 200 if ok else 400
            return JsonResponse({'ok': bool(ok), 'mensaje': mensaje}, status=status)
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=500)

    if request.method == 'PUT' and id_justificacion:
        payload = _parse_body(request)
        if not payload:
            return JsonResponse({'error': 'JSON inválido'}, status=400)
        try:
            ok, mensaje = actualizar_justificacion(id_justificacion, payload, actor_from_request(request, payload))
            status = 200 if ok else 400
            return JsonResponse({'ok': bool(ok), 'mensaje': mensaje}, status=status)
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=500)

    if request.method == 'DELETE' and id_justificacion:
        try:
            ok, mensaje = eliminar_justificacion(id_justificacion, actor_from_request(request))
            status = 200 if ok else 400
            return JsonResponse({'ok': bool(ok), 'mensaje': mensaje}, status=status)
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=500)

    return JsonResponse({'error': 'Método no permitido'}, status=405)
