import json
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from .db_context import actor_from_request
from django.utils import timezone

from .horario_crud_service import (
    listar_horarios,
    obtener_horario,
    insertar_horario,
    actualizar_horario,
    eliminar_horario,
    listar_catalogos_horario,
    guardar_imagen,
    borrar_archivos_horario,
)
from .request_multipart import multipart_post_files

IMAGE_EXTS = ('.jpg', '.jpeg', '.png', '.webp', '.gif')


def _id_usuario_request(request):
    return (
        request.GET.get('idusuario')
        or request.GET.get('idUsuario')
        or request.headers.get('X-IdUsuario')
        or None
    )


def _parse_json_body(request):
    try:
        return json.loads(request.body.decode('utf-8'))
    except Exception:
        return None


def _fecha_hoy_db():
    return timezone.localtime().strftime('%d%m%Y')


def _aulas_csv(raw):
    if raw is None:
        return None
    if isinstance(raw, list):
        return ','.join(str(x).strip() for x in raw if str(x).strip())
    text = str(raw).strip()
    if not text:
        return ''
    if text.startswith('['):
        try:
            arr = json.loads(text)
            if isinstance(arr, list):
                return ','.join(str(x).strip() for x in arr if str(x).strip())
        except Exception:
            pass
    return text


def _es_imagen(name: str) -> bool:
    n = (name or '').lower()
    return any(n.endswith(ext) for ext in IMAGE_EXTS)


def _payload_desde_request(request):
    content_type = (request.content_type or '').lower()
    if 'multipart/form-data' in content_type or request.FILES:
        data, files = multipart_post_files(request)
        return {
            'TITULO': (data.get('TITULO') or '').strip(),
            'DESCRIPCION': (data.get('DESCRIPCION') or '').strip() or None,
            'ESTADO': (data.get('ESTADO') or 'Activo').strip() or 'Activo',
            'AULAS_CSV': _aulas_csv(data.get('AULAS') or data.get('aulas')),
            'imagen': (
                files.get('imagen')
                or files.get('IMAGEN')
                or files.get('archivo')
            ),
        }

    body = _parse_json_body(request) or {}
    return {
        'TITULO': (body.get('TITULO') or '').strip(),
        'DESCRIPCION': (body.get('DESCRIPCION') or '').strip() or None,
        'ESTADO': (body.get('ESTADO') or 'Activo').strip() or 'Activo',
        'AULAS_CSV': _aulas_csv(body.get('AULAS') or body.get('aulas')),
        'URLIMAGEN': body.get('URLIMAGEN'),
        'imagen': None,
    }


@csrf_exempt
def horarios_catalogos(request):
    if request.method != 'GET':
        return JsonResponse({'error': 'Método no permitido'}, status=405)
    try:
        return JsonResponse({'data': listar_catalogos_horario()})
    except Exception as exc:
        return JsonResponse({'error': str(exc)}, status=500)


@csrf_exempt
def horarios_mantenedor(request, id_horario=None):
    if request.method == 'GET' and not id_horario:
        try:
            buscar = request.GET.get('buscar') or None
            estado = request.GET.get('estado') or None
            id_usuario = _id_usuario_request(request)
            ordenar_por = request.GET.get('ordenarPor', 'FECHASUBIDA')
            direccion = request.GET.get('direccion', 'DESC')
            pagina = int(request.GET.get('pagina', 1))
            tamanio = int(request.GET.get('tamanio', 10))
            data, total = listar_horarios(
                buscar, estado, id_usuario, ordenar_por, direccion, pagina, tamanio,
            )
            return JsonResponse({
                'data': data,
                'total': total,
                'pagina': pagina,
                'tamanioPagina': tamanio,
            })
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=500)

    if request.method == 'GET' and id_horario:
        try:
            row = obtener_horario(id_horario, _id_usuario_request(request))
            if not row:
                return JsonResponse({'error': 'Horario no encontrado'}, status=404)
            return JsonResponse({'data': row})
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=500)

    if request.method == 'POST' and not id_horario:
        payload = _payload_desde_request(request)
        imagen = payload.pop('imagen', None)

        if not payload.get('TITULO'):
            return JsonResponse({'ok': False, 'mensaje': 'Ingresa el título del horario.'}, status=400)
        if not imagen:
            return JsonResponse({'ok': False, 'mensaje': 'Debes seleccionar una imagen.'}, status=400)
        if not _es_imagen(imagen.name or ''):
            return JsonResponse({
                'ok': False,
                'mensaje': 'La imagen debe ser JPG, PNG, WEBP o GIF.',
            }, status=400)

        try:
            temp_payload = {
                **payload,
                'URLIMAGEN': 'pending',
                'FECHASUBIDA': _fecha_hoy_db(),
            }
            ok, mensaje, id_gen = insertar_horario(temp_payload, actor_from_request(request, temp_payload if isinstance(temp_payload, dict) else None))
            if not ok or not id_gen:
                return JsonResponse({'ok': False, 'mensaje': mensaje or 'No se pudo registrar.'}, status=400)

            url_img = guardar_imagen(id_gen, imagen)
            ok2, mensaje2 = actualizar_horario(id_gen, {
                'TITULO': payload['TITULO'],
                'DESCRIPCION': payload.get('DESCRIPCION'),
                'ESTADO': payload.get('ESTADO', 'Activo'),
                'AULAS_CSV': payload.get('AULAS_CSV') or '',
                'URLIMAGEN': url_img,
            }, actor_from_request(request, payload))
            if not ok2:
                borrar_archivos_horario(id_gen)
                eliminar_horario(id_gen, actor_from_request(request))
                return JsonResponse({'ok': False, 'mensaje': mensaje2}, status=400)

            return JsonResponse({
                'ok': True,
                'mensaje': mensaje,
                'data': {'IDHORARIO': id_gen},
            })
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=500)

    if request.method == 'PUT' and id_horario:
        payload = _payload_desde_request(request)
        imagen = payload.pop('imagen', None)

        if not payload.get('TITULO'):
            return JsonResponse({'ok': False, 'mensaje': 'Ingresa el título del horario.'}, status=400)

        try:
            actual = obtener_horario(id_horario)
            if not actual:
                return JsonResponse({'ok': False, 'mensaje': 'El horario no existe.'}, status=404)

            url_img = actual.get('URLIMAGEN')
            if imagen:
                if not _es_imagen(imagen.name or ''):
                    return JsonResponse({
                        'ok': False,
                        'mensaje': 'La imagen debe ser JPG, PNG, WEBP o GIF.',
                    }, status=400)
                url_img = guardar_imagen(id_horario, imagen)

            ok, mensaje = actualizar_horario(id_horario, {
                'TITULO': payload['TITULO'],
                'DESCRIPCION': payload.get('DESCRIPCION'),
                'ESTADO': payload.get('ESTADO', 'Activo'),
                'AULAS_CSV': payload.get('AULAS_CSV') if payload.get('AULAS_CSV') is not None else '',
                'URLIMAGEN': url_img,
            }, actor_from_request(request, payload))
            status = 200 if ok else 400
            return JsonResponse({'ok': bool(ok), 'mensaje': mensaje}, status=status)
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=500)

    if request.method == 'DELETE' and id_horario:
        try:
            ok, mensaje = eliminar_horario(id_horario, actor_from_request(request))
            if ok:
                borrar_archivos_horario(id_horario)
            status = 200 if ok else 400
            return JsonResponse({'ok': bool(ok), 'mensaje': mensaje}, status=status)
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=500)

    return JsonResponse({'error': 'Método no permitido'}, status=405)
