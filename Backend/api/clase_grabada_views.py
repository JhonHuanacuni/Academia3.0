import json
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from .db_context import actor_from_request
from .clase_grabada_crud_service import (
    listar_clases_grabadas,
    listar_materias_clase_grabada,
    obtener_clase_grabada,
    insertar_clase_grabada,
    actualizar_clase_grabada,
    eliminar_clase_grabada,
    listar_catalogos_clase_grabada,
)


def _parse_json_body(request):
    try:
        return json.loads(request.body.decode('utf-8'))
    except Exception:
        return None


def _payload_desde_request(request):
    body = _parse_json_body(request) or {}
    return {
        'IDAULA': (body.get('IDAULA') or '').strip(),
        'IDMATERIA': (body.get('IDMATERIA') or '').strip(),
        'ENLACE': (body.get('ENLACE') or '').strip(),
        'DETALLES': (body.get('DETALLES') or '').strip(),
        'ESTADO': (body.get('ESTADO') or 'Activo').strip() or 'Activo',
    }


@csrf_exempt
def clases_grabadas_catalogos(request):
    if request.method != 'GET':
        return JsonResponse({'error': 'Método no permitido'}, status=405)
    try:
        return JsonResponse({'data': listar_catalogos_clase_grabada()})
    except Exception as exc:
        return JsonResponse({'error': str(exc)}, status=500)


@csrf_exempt
def clases_grabadas_materias(request):
    if request.method != 'GET':
        return JsonResponse({'error': 'Método no permitido'}, status=405)
    try:
        id_aula = request.GET.get('idAula') or None
        id_usuario = request.GET.get('idusuario') or request.GET.get('idUsuario') or None
        data = listar_materias_clase_grabada(id_aula, id_usuario)
        total = sum(int(r.get('CANTIDAD') or 0) for r in data)
        return JsonResponse({'data': data, 'totalEnlaces': total})
    except Exception as exc:
        return JsonResponse({'error': str(exc)}, status=500)


@csrf_exempt
def clases_grabadas_mantenedor(request, id_clase=None):
    if request.method == 'GET' and not id_clase:
        try:
            buscar = request.GET.get('buscar') or None
            estado = request.GET.get('estado') or None
            id_materia = request.GET.get('idMateria') or None
            id_aula = request.GET.get('idAula') or None
            id_usuario = request.GET.get('idusuario') or request.GET.get('idUsuario') or None
            ordenar_por = request.GET.get('ordenarPor', 'FECHASUBIDA')
            direccion = request.GET.get('direccion', 'DESC')
            pagina = int(request.GET.get('pagina', 1))
            tamanio = int(request.GET.get('tamanio', 10))
            data, total = listar_clases_grabadas(
                buscar,
                estado,
                id_materia,
                id_aula,
                id_usuario,
                ordenar_por,
                direccion,
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

    if request.method == 'GET' and id_clase:
        try:
            row = obtener_clase_grabada(id_clase)
            if not row:
                return JsonResponse({'error': 'Registro no encontrado'}, status=404)
            return JsonResponse({'data': row})
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=500)

    if request.method == 'POST' and not id_clase:
        payload = _payload_desde_request(request)
        if not payload['IDAULA']:
            return JsonResponse({'ok': False, 'mensaje': 'Selecciona un salón.'}, status=400)
        if not payload['IDMATERIA']:
            return JsonResponse({'ok': False, 'mensaje': 'Selecciona una materia.'}, status=400)
        if not payload['ENLACE']:
            return JsonResponse({'ok': False, 'mensaje': 'Ingresa el enlace de la grabación.'}, status=400)
        if not payload['DETALLES']:
            return JsonResponse({'ok': False, 'mensaje': 'Ingresa los detalles.'}, status=400)
        try:
            id_gen, ok, mensaje = insertar_clase_grabada(payload, actor_from_request(request, payload))
            status = 200 if ok else 400
            return JsonResponse({
                'ok': bool(ok),
                'mensaje': mensaje,
                'data': {'IDCLASEGRABADA': id_gen} if ok else None,
            }, status=status)
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=500)

    if request.method == 'PUT' and id_clase:
        payload = _payload_desde_request(request)
        if not payload['IDAULA'] or not payload['IDMATERIA'] or not payload['ENLACE'] or not payload['DETALLES']:
            return JsonResponse({'ok': False, 'mensaje': 'Completa todos los campos obligatorios.'}, status=400)
        try:
            ok, mensaje = actualizar_clase_grabada(id_clase, payload, actor_from_request(request, payload))
            status = 200 if ok else 400
            return JsonResponse({'ok': bool(ok), 'mensaje': mensaje}, status=status)
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=500)

    if request.method == 'DELETE' and id_clase:
        try:
            ok, mensaje = eliminar_clase_grabada(id_clase, actor_from_request(request))
            status = 200 if ok else 400
            return JsonResponse({'ok': bool(ok), 'mensaje': mensaje}, status=status)
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=500)

    return JsonResponse({'error': 'Método no permitido'}, status=405)
