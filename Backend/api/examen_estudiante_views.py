import json
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt

from . import examen_estudiante_service as svc


def _parse_json_body(request):
    try:
        return json.loads(request.body.decode('utf-8'))
    except Exception:
        return None


def _idusuario(request, body=None):
    body = body or {}
    return (
        (request.GET.get('idusuario') or request.GET.get('idUsuario') or '')
        or (body.get('IDUSUARIO') or body.get('idusuario') or body.get('idUsuario') or '')
        or (request.POST.get('IDUSUARIO') or request.POST.get('idusuario') or '')
    ).strip()


@csrf_exempt
def examenes_estudiante_listar(request):
    if request.method != 'GET':
        return JsonResponse({'ok': False, 'mensaje': 'Método no permitido'}, status=405)
    idusuario = _idusuario(request)
    if not idusuario:
        return JsonResponse({'ok': False, 'mensaje': 'Falta idusuario'}, status=400)
    try:
        data = svc.listar_examenes_estudiante(idusuario)
        return JsonResponse({'ok': True, 'data': data})
    except Exception as exc:
        return JsonResponse({'ok': False, 'mensaje': str(exc)}, status=500)


@csrf_exempt
def examenes_estudiante_iniciar(request, id_examen):
    if request.method != 'POST':
        return JsonResponse({'ok': False, 'mensaje': 'Método no permitido'}, status=405)
    body = _parse_json_body(request) or {}
    idusuario = _idusuario(request, body)
    if not idusuario:
        return JsonResponse({'ok': False, 'mensaje': 'Falta idusuario'}, status=400)
    try:
        ok, mensaje, id_intento = svc.iniciar_intento(id_examen, idusuario)
        status = 200 if ok else 400
        return JsonResponse(
            {'ok': bool(ok), 'mensaje': mensaje, 'idIntento': id_intento},
            status=status,
        )
    except Exception as exc:
        return JsonResponse({'ok': False, 'mensaje': str(exc)}, status=500)


@csrf_exempt
def examenes_estudiante_intento(request, id_intento):
    if request.method != 'GET':
        return JsonResponse({'ok': False, 'mensaje': 'Método no permitido'}, status=405)
    idusuario = _idusuario(request)
    if not idusuario:
        return JsonResponse({'ok': False, 'mensaje': 'Falta idusuario'}, status=400)
    try:
        data = svc.estado_intento(id_intento, idusuario)
        if data is None:
            return JsonResponse({'ok': False, 'mensaje': 'Intento no encontrado'}, status=404)
        if not data.get('ok'):
            return JsonResponse({'ok': False, 'mensaje': data.get('mensaje')}, status=400)
        return JsonResponse({
            'ok': True,
            'intento': data['intento'],
            'respondidas': data['respondidas'],
            'pregunta': data['pregunta'],
        })
    except Exception as exc:
        return JsonResponse({'ok': False, 'mensaje': str(exc)}, status=500)


@csrf_exempt
def examenes_estudiante_responder(request, id_intento):
    if request.method != 'POST':
        return JsonResponse({'ok': False, 'mensaje': 'Método no permitido'}, status=405)
    body = _parse_json_body(request) or {}
    idusuario = _idusuario(request, body)
    id_pregunta = (body.get('IDPREGUNTA') or body.get('idpregunta') or '').strip()
    id_alternativa = (body.get('IDALTERNATIVA') or body.get('idalternativa') or '').strip()
    if not idusuario or not id_pregunta or not id_alternativa:
        return JsonResponse(
            {'ok': False, 'mensaje': 'Faltan idusuario, pregunta o alternativa'},
            status=400,
        )
    try:
        ok, mensaje, extras = svc.responder_intento(
            id_intento, idusuario, id_pregunta, id_alternativa
        )
        status = 200 if ok else 400
        return JsonResponse(
            {
                'ok': bool(ok),
                'mensaje': mensaje,
                'ordenSiguiente': extras.get('ordenSiguiente'),
                'esUltima': extras.get('esUltima'),
                'tiempoAgotado': extras.get('tiempoAgotado'),
            },
            status=status,
        )
    except Exception as exc:
        return JsonResponse({'ok': False, 'mensaje': str(exc)}, status=500)


@csrf_exempt
def examenes_estudiante_finalizar(request, id_intento):
    if request.method != 'POST':
        return JsonResponse({'ok': False, 'mensaje': 'Método no permitido'}, status=405)
    body = _parse_json_body(request) or {}
    idusuario = _idusuario(request, body)
    if not idusuario:
        return JsonResponse({'ok': False, 'mensaje': 'Falta idusuario'}, status=400)
    try:
        ok, mensaje, resumen = svc.finalizar_intento(id_intento, idusuario)
        status = 200 if ok else 400
        return JsonResponse(
            {'ok': bool(ok), 'mensaje': mensaje, 'resultado': resumen},
            status=status,
        )
    except Exception as exc:
        return JsonResponse({'ok': False, 'mensaje': str(exc)}, status=500)
