import json

from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt

from .db_context import actor_from_request
from .informe_consulta_crud_service import (
    CANALES,
    RESULTADOS,
    actualizar_informe_consulta,
    eliminar_informe_consulta,
    insertar_informe_consulta,
    listar_informes_consulta,
    obtener_informe_consulta,
)


def _parse_body(request):
    try:
        return json.loads(request.body.decode('utf-8'))
    except Exception:
        return None


@csrf_exempt
def informes_consulta_catalogos(request):
    if request.method != 'GET':
        return JsonResponse({'error': 'Método no permitido'}, status=405)
    return JsonResponse({
        'data': {
            'resultados': [{'value': k, 'label': v} for k, v in RESULTADOS.items()],
            'canales': [{'value': k, 'label': v} for k, v in CANALES.items()],
        }
    })


@csrf_exempt
def informes_consulta_mantenedor(request, id_informe=None):
    if request.method == 'GET' and not id_informe:
        try:
            data, total = listar_informes_consulta(
                buscar=request.GET.get('buscar') or None,
                resultado=request.GET.get('resultado') or None,
                canal=request.GET.get('canal') or None,
                anio=request.GET.get('anio') or None,
                mes=request.GET.get('mes') or None,
                ordenar_por=request.GET.get('ordenarPor', 'FECHA'),
                direccion=request.GET.get('direccion', 'DESC'),
                pagina=int(request.GET.get('pagina', 1)),
                tamanio=int(request.GET.get('tamanio', 10)),
            )
            return JsonResponse({
                'data': data,
                'total': total,
                'pagina': int(request.GET.get('pagina', 1)),
                'tamanioPagina': int(request.GET.get('tamanio', 10)),
            })
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=500)

    if request.method == 'GET' and id_informe:
        try:
            row = obtener_informe_consulta(id_informe)
            if not row:
                return JsonResponse({'error': 'Informe no encontrado'}, status=404)
            return JsonResponse({'data': row})
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=500)

    if request.method == 'POST' and not id_informe:
        payload = _parse_body(request)
        if not payload:
            return JsonResponse({'error': 'JSON inválido'}, status=400)
        try:
            ok, mensaje = insertar_informe_consulta(payload, actor_from_request(request, payload))
            return JsonResponse({'ok': bool(ok), 'mensaje': mensaje}, status=200 if ok else 400)
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=500)

    if request.method == 'PUT' and id_informe:
        payload = _parse_body(request)
        if not payload:
            return JsonResponse({'error': 'JSON inválido'}, status=400)
        try:
            ok, mensaje = actualizar_informe_consulta(
                id_informe, payload, actor_from_request(request, payload),
            )
            return JsonResponse({'ok': bool(ok), 'mensaje': mensaje}, status=200 if ok else 400)
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=500)

    if request.method == 'DELETE' and id_informe:
        try:
            ok, mensaje = eliminar_informe_consulta(id_informe, actor_from_request(request))
            return JsonResponse({'ok': bool(ok), 'mensaje': mensaje}, status=200 if ok else 400)
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=500)

    return JsonResponse({'error': 'Método no permitido'}, status=405)
