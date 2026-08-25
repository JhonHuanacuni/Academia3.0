import json
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from .db_context import actor_from_request
from .menu_config import ROLE_TO_TIPOUSUARIO
from .mensaje_crud_service import (
    listar_mensajes,
    obtener_mensaje,
    insertar_mensaje,
    actualizar_mensaje,
    eliminar_mensaje,
    listar_mensajes_vigentes,
)


def _parse_body(request):
    try:
        return json.loads(request.body.decode('utf-8'))
    except Exception:
        return None


def _tipo_desde_request(request):
    tipo = request.GET.get('idtipousuario') or request.headers.get('X-IdTipoUsuario')
    if tipo:
        return str(tipo).strip()
    role = (request.GET.get('role') or request.headers.get('X-Role') or '').strip().lower()
    return ROLE_TO_TIPOUSUARIO.get(role, '1')


@csrf_exempt
def mensajes_vigentes(request):
    if request.method != 'GET':
        return JsonResponse({'error': 'Método no permitido'}, status=405)
    try:
        data = listar_mensajes_vigentes(_tipo_desde_request(request))
        return JsonResponse({'data': data or [], 'total': len(data or [])})
    except Exception as exc:
        return JsonResponse({'error': str(exc)}, status=500)


@csrf_exempt
def mensajes_mantenedor(request, id_mensaje=None):
    if request.method == 'GET' and not id_mensaje:
        try:
            buscar = request.GET.get('buscar') or None
            estado = request.GET.get('estado') or None
            destinatario = request.GET.get('destinatario') or None
            ordenar_por = request.GET.get('ordenarPor', 'FECHACREACION')
            direccion = request.GET.get('direccion', 'DESC')
            pagina = int(request.GET.get('pagina', 1))
            tamanio = int(request.GET.get('tamanio', 10))
            data, total = listar_mensajes(
                buscar, estado, destinatario, ordenar_por, direccion, pagina, tamanio,
            )
            return JsonResponse({
                'data': data,
                'total': total,
                'pagina': pagina,
                'tamanioPagina': tamanio,
            })
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=500)

    if request.method == 'GET' and id_mensaje:
        try:
            row = obtener_mensaje(id_mensaje)
            if not row:
                return JsonResponse({'error': 'Mensaje no encontrado'}, status=404)
            return JsonResponse({'data': row})
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=500)

    if request.method == 'POST' and not id_mensaje:
        payload = _parse_body(request)
        if not payload:
            return JsonResponse({'error': 'JSON inválido'}, status=400)
        try:
            ok, mensaje = insertar_mensaje(payload, actor_from_request(request, payload))
            status = 200 if ok else 400
            return JsonResponse({'ok': bool(ok), 'mensaje': mensaje}, status=status)
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=500)

    if request.method == 'PUT' and id_mensaje:
        payload = _parse_body(request)
        if not payload:
            return JsonResponse({'error': 'JSON inválido'}, status=400)
        try:
            ok, mensaje = actualizar_mensaje(
                id_mensaje, payload, actor_from_request(request, payload),
            )
            status = 200 if ok else 400
            return JsonResponse({'ok': bool(ok), 'mensaje': mensaje}, status=status)
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=500)

    if request.method == 'DELETE' and id_mensaje:
        try:
            ok, mensaje = eliminar_mensaje(id_mensaje, actor_from_request(request))
            status = 200 if ok else 400
            return JsonResponse({'ok': bool(ok), 'mensaje': mensaje}, status=status)
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=500)

    return JsonResponse({'error': 'Método no permitido'}, status=405)
