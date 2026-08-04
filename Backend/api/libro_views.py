import json
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from .db_context import actor_from_request
from django.utils import timezone

from .libro_crud_service import (
    listar_libros,
    obtener_libro,
    insertar_libro,
    actualizar_libro,
    eliminar_libro,
    listar_catalogos_biblioteca,
    guardar_pdf,
    guardar_portada,
    borrar_archivos_libro,
)
from .request_multipart import multipart_post_files


def _parse_json_body(request):
    try:
        return json.loads(request.body.decode('utf-8'))
    except Exception:
        return None


def _fecha_hoy_db():
    now = timezone.localtime()
    return now.strftime('%d%m%Y')


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


def _payload_desde_request(request):
    """Acepta JSON o multipart (FormData)."""
    content_type = (request.content_type or '').lower()
    if 'multipart/form-data' in content_type or request.FILES:
        data, files = multipart_post_files(request)
        return {
            'TITULO': (data.get('TITULO') or '').strip(),
            'DESCRIPCION': (data.get('DESCRIPCION') or '').strip() or None,
            'ESTADO': (data.get('ESTADO') or 'Activo').strip() or 'Activo',
            'AULAS_CSV': _aulas_csv(data.get('AULAS') or data.get('aulas')),
            'archivo': files.get('archivo') or files.get('ARCHIVO'),
            'portada': files.get('portada') or files.get('PORTADA'),
        }

    body = _parse_json_body(request) or {}
    return {
        'TITULO': (body.get('TITULO') or '').strip(),
        'DESCRIPCION': (body.get('DESCRIPCION') or '').strip() or None,
        'ESTADO': (body.get('ESTADO') or 'Activo').strip() or 'Activo',
        'AULAS_CSV': _aulas_csv(body.get('AULAS') or body.get('aulas')),
        'URLCONTENIDO': body.get('URLCONTENIDO'),
        'IMGPORTADA': body.get('IMGPORTADA'),
        'archivo': None,
        'portada': None,
    }


@csrf_exempt
def libros_catalogos(request):
    if request.method != 'GET':
        return JsonResponse({'error': 'Método no permitido'}, status=405)
    try:
        return JsonResponse({'data': listar_catalogos_biblioteca()})
    except Exception as exc:
        return JsonResponse({'error': str(exc)}, status=500)


@csrf_exempt
def libros_mantenedor(request, id_libro=None):
    if request.method == 'GET' and not id_libro:
        try:
            buscar = request.GET.get('buscar') or None
            estado = request.GET.get('estado') or None
            ordenar_por = request.GET.get('ordenarPor', 'FECHASUBIDA')
            direccion = request.GET.get('direccion', 'DESC')
            pagina = int(request.GET.get('pagina', 1))
            tamanio = int(request.GET.get('tamanio', 10))
            data, total = listar_libros(
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

    if request.method == 'GET' and id_libro:
        try:
            row = obtener_libro(id_libro)
            if not row:
                return JsonResponse({'error': 'Documento no encontrado'}, status=404)
            return JsonResponse({'data': row})
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=500)

    if request.method == 'POST' and not id_libro:
        payload = _payload_desde_request(request)
        archivo = payload.pop('archivo', None)
        portada = payload.pop('portada', None)

        if not payload.get('TITULO'):
            return JsonResponse({'ok': False, 'mensaje': 'Ingresa el título del documento.'}, status=400)
        if not archivo:
            return JsonResponse({'ok': False, 'mensaje': 'Debes seleccionar un archivo PDF.'}, status=400)

        name = (archivo.name or '').lower()
        if not name.endswith('.pdf'):
            return JsonResponse({'ok': False, 'mensaje': 'El archivo debe ser un PDF.'}, status=400)

        # Reservar ID temporal para carpeta; el SP asigna el ID final numérico.
        # Guardamos primero con ID provisional y luego renombramos si hace falta.
        try:
            # Insertar con rutas provisionales tras conocer ID del SP:
            # 1) insertar con placeholder, 2) guardar archivos con ID real, 3) actualizar rutas.
            temp_payload = {
                **payload,
                'URLCONTENIDO': 'pending',
                'IMGPORTADA': None,
                'FECHASUBIDA': _fecha_hoy_db(),
            }
            ok, mensaje, id_gen = insertar_libro(temp_payload, actor_from_request(request, temp_payload if isinstance(temp_payload, dict) else None))
            if not ok or not id_gen:
                return JsonResponse({'ok': False, 'mensaje': mensaje or 'No se pudo registrar.'}, status=400)

            url_pdf = guardar_pdf(id_gen, archivo)
            url_portada = guardar_portada(id_gen, portada) if portada else None

            ok2, mensaje2 = actualizar_libro(id_gen, {
                'TITULO': payload['TITULO'],
                'DESCRIPCION': payload.get('DESCRIPCION'),
                'ESTADO': payload.get('ESTADO', 'Activo'),
                'AULAS_CSV': payload.get('AULAS_CSV') or '',
                'URLCONTENIDO': url_pdf,
                'IMGPORTADA': url_portada,
            }, actor_from_request(request, payload))
            if not ok2:
                borrar_archivos_libro(id_gen)
                eliminar_libro(id_gen, actor_from_request(request))
                return JsonResponse({'ok': False, 'mensaje': mensaje2}, status=400)

            return JsonResponse({
                'ok': True,
                'mensaje': mensaje,
                'data': {'IDLIBRO': id_gen},
            })
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=500)

    if request.method == 'PUT' and id_libro:
        payload = _payload_desde_request(request)
        archivo = payload.pop('archivo', None)
        portada = payload.pop('portada', None)

        if not payload.get('TITULO'):
            return JsonResponse({'ok': False, 'mensaje': 'Ingresa el título del documento.'}, status=400)

        try:
            actual = obtener_libro(id_libro)
            if not actual:
                return JsonResponse({'ok': False, 'mensaje': 'El documento no existe.'}, status=404)

            url_pdf = actual.get('URLCONTENIDO')
            url_portada = actual.get('IMGPORTADA')

            if archivo:
                name = (archivo.name or '').lower()
                if not name.endswith('.pdf'):
                    return JsonResponse({'ok': False, 'mensaje': 'El archivo debe ser un PDF.'}, status=400)
                url_pdf = guardar_pdf(id_libro, archivo)

            if portada:
                url_portada = guardar_portada(id_libro, portada)

            ok, mensaje = actualizar_libro(id_libro, {
                'TITULO': payload['TITULO'],
                'DESCRIPCION': payload.get('DESCRIPCION'),
                'ESTADO': payload.get('ESTADO', 'Activo'),
                'AULAS_CSV': payload.get('AULAS_CSV') if payload.get('AULAS_CSV') is not None else '',
                'URLCONTENIDO': url_pdf,
                'IMGPORTADA': url_portada,
            }, actor_from_request(request, payload))
            status = 200 if ok else 400
            return JsonResponse({'ok': bool(ok), 'mensaje': mensaje}, status=status)
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=500)

    if request.method == 'DELETE' and id_libro:
        try:
            ok, mensaje = eliminar_libro(id_libro, actor_from_request(request))
            if ok:
                borrar_archivos_libro(id_libro)
            status = 200 if ok else 400
            return JsonResponse({'ok': bool(ok), 'mensaje': mensaje}, status=status)
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=500)

    return JsonResponse({'error': 'Método no permitido'}, status=405)
