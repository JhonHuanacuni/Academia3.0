import json
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from .db_context import actor_from_request

from .examen_crud_service import (
    listar_examenes,
    obtener_examen,
    obtener_pregunta,
    distribucion_examen,
    insertar_examen,
    actualizar_examen,
    eliminar_examen,
    guardar_pregunta,
    listar_catalogos_examen,
    guardar_imagen_pregunta,
    guardar_imagen_alternativa,
    borrar_archivos_examen,
)

IMAGE_EXTS = ('.jpg', '.jpeg', '.png', '.webp', '.gif')


def _parse_json_body(request):
    try:
        return json.loads(request.body.decode('utf-8'))
    except Exception:
        return None


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


def _bool(val, default=True):
    if val is None:
        return default
    if isinstance(val, bool):
        return val
    s = str(val).strip().lower()
    if s in ('1', 'true', 'si', 'sí', 'yes', 'on'):
        return True
    if s in ('0', 'false', 'no', 'off'):
        return False
    return default


def _payload_examen(request):
    content_type = (request.content_type or '').lower()
    if 'multipart/form-data' in content_type or request.FILES:
        data = request.POST
        return {
            'TITULO': (data.get('TITULO') or '').strip(),
            'DESCRIPCION': data.get('DESCRIPCION'),
            'TIPO': int(data.get('TIPO') or 40),
            'DURACIONMIN': int(data.get('DURACIONMIN') or 120),
            'FECHAINICIO': (data.get('FECHAINICIO') or '').strip() or None,
            'FECHAFIN': (data.get('FECHAFIN') or '').strip() or None,
            'HORAINICIO': (data.get('HORAINICIO') or '').strip() or None,
            'HORAFIN': (data.get('HORAFIN') or '').strip() or None,
            'VISIBLE': _bool(data.get('VISIBLE'), True),
            'TODASLASULA': _bool(data.get('TODASLASULA'), True),
            'IDUSUARIO': (data.get('IDUSUARIO') or '').strip(),
            'AULAS_CSV': _aulas_csv(data.get('AULAS') or data.get('aulas')),
        }

    body = _parse_json_body(request) or {}
    return {
        'TITULO': (body.get('TITULO') or '').strip(),
        'DESCRIPCION': body.get('DESCRIPCION'),
        'TIPO': int(body.get('TIPO') or 40),
        'DURACIONMIN': int(body.get('DURACIONMIN') or 120),
        'FECHAINICIO': (body.get('FECHAINICIO') or '').strip() or None,
        'FECHAFIN': (body.get('FECHAFIN') or '').strip() or None,
        'HORAINICIO': (body.get('HORAINICIO') or '').strip() or None,
        'HORAFIN': (body.get('HORAFIN') or '').strip() or None,
        'VISIBLE': _bool(body.get('VISIBLE'), True),
        'TODASLASULA': _bool(body.get('TODASLASULA'), True),
        'IDUSUARIO': (body.get('IDUSUARIO') or '').strip(),
        'AULAS_CSV': _aulas_csv(body.get('AULAS') or body.get('aulas')),
    }


def _es_imagen(name: str) -> bool:
    n = (name or '').lower()
    return any(n.endswith(ext) for ext in IMAGE_EXTS)


@csrf_exempt
def examenes_catalogos(request):
    if request.method != 'GET':
        return JsonResponse({'error': 'Método no permitido'}, status=405)
    try:
        return JsonResponse({'data': listar_catalogos_examen()})
    except Exception as exc:
        return JsonResponse({'error': str(exc)}, status=500)


@csrf_exempt
def examenes_distribucion(request):
    if request.method != 'GET':
        return JsonResponse({'error': 'Método no permitido'}, status=405)
    try:
        tipo = request.GET.get('tipo')
        id_examen = request.GET.get('idExamen') or None
        tipo_int = int(tipo) if tipo else None
        data = distribucion_examen(tipo=tipo_int, id_examen=id_examen)
        return JsonResponse({'data': data})
    except Exception as exc:
        return JsonResponse({'error': str(exc)}, status=500)


@csrf_exempt
def examenes_mantenedor(request, id_examen=None):
    if request.method == 'GET' and not id_examen:
        try:
            buscar = request.GET.get('buscar') or None
            ordenar_por = request.GET.get('ordenarPor', 'FECHAINICIO')
            direccion = request.GET.get('direccion', 'DESC')
            pagina = int(request.GET.get('pagina', 1))
            tamanio = int(request.GET.get('tamanio', 10))
            data, total = listar_examenes(
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

    if request.method == 'GET' and id_examen:
        try:
            row = obtener_examen(id_examen)
            if not row:
                return JsonResponse({'error': 'Examen no encontrado'}, status=404)
            return JsonResponse({'data': row})
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=500)

    if request.method == 'POST' and not id_examen:
        try:
            payload = _payload_examen(request)
            if not payload.get('IDUSUARIO'):
                return JsonResponse({'ok': False, 'mensaje': 'Usuario no identificado.'}, status=400)
            ok, mensaje, nuevo_id = insertar_examen(payload, actor_from_request(request, payload))
            status = 200 if ok else 400
            return JsonResponse(
                {'ok': bool(ok), 'mensaje': mensaje, 'id': nuevo_id},
                status=status,
            )
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=500)

    if request.method == 'PUT' and id_examen:
        try:
            payload = _payload_examen(request)
            ok, mensaje = actualizar_examen(id_examen, payload, actor_from_request(request, payload))
            status = 200 if ok else 400
            return JsonResponse({'ok': bool(ok), 'mensaje': mensaje}, status=status)
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=500)

    if request.method == 'DELETE' and id_examen:
        try:
            ok, mensaje = eliminar_examen(id_examen, actor_from_request(request))
            if ok:
                borrar_archivos_examen(id_examen)
            status = 200 if ok else 400
            return JsonResponse({'ok': bool(ok), 'mensaje': mensaje}, status=status)
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=500)

    return JsonResponse({'error': 'Método no permitido'}, status=405)


def _multipart_post_files(request):
    """Django no llena POST/FILES en PUT multipart; parsear manualmente."""
    content_type = (request.content_type or '').lower()
    if request.method == 'POST' and ('multipart/form-data' in content_type or request.FILES):
        return request.POST, request.FILES
    if 'multipart/form-data' in content_type:
        try:
            from django.http.multipartparser import MultiPartParser
            parser = MultiPartParser(request.META, request, request.upload_handlers)
            data, files = parser.parse()
            return data, files
        except Exception:
            pass
    return request.POST, request.FILES


def _payload_pregunta(request, id_examen, id_pregunta):
    content_type = (request.content_type or '').lower()
    is_multipart = 'multipart/form-data' in content_type

    if is_multipart:
        data, files = _multipart_post_files(request)
        if not list(data.keys()) and not files:
            return None, 'No se recibieron los datos de la pregunta (multipart vacío).'

        payload = {
            'DESCRIPCION': data.get('DESCRIPCION'),
            'ALT1': data.get('ALT1') or '',
            'ALT2': data.get('ALT2') or '',
            'ALT3': data.get('ALT3') or '',
            'ALT4': data.get('ALT4') or '',
            'ALT5': data.get('ALT5') or '',
            'CORRECTA_ORDEN': int(data.get('CORRECTA_ORDEN') or 1),
            'QUITAR_IMAGEN': _bool(data.get('QUITAR_IMAGEN'), False),
            'IMAGEURL': None,
            'IMG_ALT1': None,
            'IMG_ALT2': None,
            'IMG_ALT3': None,
            'IMG_ALT4': None,
            'IMG_ALT5': None,
            'QUITAR_IMG_ALT1': _bool(data.get('QUITAR_IMG_ALT1'), False),
            'QUITAR_IMG_ALT2': _bool(data.get('QUITAR_IMG_ALT2'), False),
            'QUITAR_IMG_ALT3': _bool(data.get('QUITAR_IMG_ALT3'), False),
            'QUITAR_IMG_ALT4': _bool(data.get('QUITAR_IMG_ALT4'), False),
            'QUITAR_IMG_ALT5': _bool(data.get('QUITAR_IMG_ALT5'), False),
        }

        imagen = files.get('imagen') or files.get('IMAGEN') or files.get('archivo')
        err = None
        if imagen and _es_imagen(imagen.name):
            if imagen.size and imagen.size > 2 * 1024 * 1024:
                err = 'La imagen de la pregunta no debe superar 2 MB.'
            else:
                payload['IMAGEURL'] = guardar_imagen_pregunta(id_examen, id_pregunta, imagen)
                payload['QUITAR_IMAGEN'] = False

        for i in range(1, 6):
            f = files.get(f'imagen_alt{i}') or files.get(f'IMAGEN_ALT{i}')
            if f and _es_imagen(f.name):
                if f.size and f.size > 2 * 1024 * 1024:
                    err = f'La imagen de la alternativa {i} no debe superar 2 MB.'
                    break
                payload[f'IMG_ALT{i}'] = guardar_imagen_alternativa(
                    id_examen, id_pregunta, i, f,
                )
                payload[f'QUITAR_IMG_ALT{i}'] = False

        return payload, err

    body = _parse_json_body(request) or {}
    if not body:
        return None, 'No se recibieron los datos de la pregunta.'
    return {
        'DESCRIPCION': body.get('DESCRIPCION'),
        'ALT1': body.get('ALT1') or '',
        'ALT2': body.get('ALT2') or '',
        'ALT3': body.get('ALT3') or '',
        'ALT4': body.get('ALT4') or '',
        'ALT5': body.get('ALT5') or '',
        'CORRECTA_ORDEN': int(body.get('CORRECTA_ORDEN') or 1),
        'QUITAR_IMAGEN': _bool(body.get('QUITAR_IMAGEN'), False),
        'IMAGEURL': body.get('IMAGEURL'),
        'IMG_ALT1': body.get('IMG_ALT1'),
        'IMG_ALT2': body.get('IMG_ALT2'),
        'IMG_ALT3': body.get('IMG_ALT3'),
        'IMG_ALT4': body.get('IMG_ALT4'),
        'IMG_ALT5': body.get('IMG_ALT5'),
        'QUITAR_IMG_ALT1': _bool(body.get('QUITAR_IMG_ALT1'), False),
        'QUITAR_IMG_ALT2': _bool(body.get('QUITAR_IMG_ALT2'), False),
        'QUITAR_IMG_ALT3': _bool(body.get('QUITAR_IMG_ALT3'), False),
        'QUITAR_IMG_ALT4': _bool(body.get('QUITAR_IMG_ALT4'), False),
        'QUITAR_IMG_ALT5': _bool(body.get('QUITAR_IMG_ALT5'), False),
    }, None


@csrf_exempt
def examenes_pregunta(request, id_examen, id_pregunta):
    if request.method == 'GET':
        try:
            row = obtener_pregunta(id_examen, id_pregunta)
            if not row:
                return JsonResponse({'error': 'Pregunta no encontrada'}, status=404)
            return JsonResponse({'data': row})
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=500)

    if request.method in ('PUT', 'POST'):
        try:
            payload, err = _payload_pregunta(request, id_examen, id_pregunta)
            if err:
                return JsonResponse({'ok': False, 'mensaje': err}, status=400)
            if payload is None:
                return JsonResponse({'ok': False, 'mensaje': 'Payload inválido.'}, status=400)
            ok, mensaje = guardar_pregunta(id_examen, id_pregunta, payload, actor_from_request(request, payload))
            status = 200 if ok else 400
            data = obtener_pregunta(id_examen, id_pregunta) if ok else None
            return JsonResponse(
                {'ok': bool(ok), 'mensaje': mensaje, 'data': data},
                status=status,
            )
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=500)

    return JsonResponse({'error': 'Método no permitido'}, status=405)
