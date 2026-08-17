import json
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from .db_context import actor_from_request
from .pago_crud_service import (
    listar_pagos,
    mensualidades_estudiante,
    insertar_abono,
    obtener_pago,
    actualizar_pago,
    eliminar_pago,
    listar_metodos_pago,
)
from .mensualidad_crud_service import insertar_mensualidad, listar_catalogos


def _parse_body(request):
    try:
        return json.loads(request.body.decode('utf-8'))
    except Exception:
        return None


@csrf_exempt
def pagos_catalogos(request):
    if request.method != 'GET':
        return JsonResponse({'error': 'Método no permitido'}, status=405)
    try:
        cats = listar_catalogos()
        return JsonResponse({
            'data': {
                'planes': cats.get('planes') or [],
                'aulas': cats.get('aulas') or [],
                'tutores': cats.get('tutores') or [],
                'metodosPago': listar_metodos_pago() or cats.get('metodosPago') or [],
            }
        })
    except Exception as exc:
        return JsonResponse({'error': str(exc)}, status=500)


@csrf_exempt
def pagos_mensualidades_estudiante(request, id_usuario):
    if request.method != 'GET':
        return JsonResponse({'error': 'Método no permitido'}, status=405)
    try:
        return JsonResponse({'data': mensualidades_estudiante(id_usuario)})
    except Exception as exc:
        return JsonResponse({'error': str(exc)}, status=500)


@csrf_exempt
def pagos_mantenedor(request, id_pago=None):
    if request.method == 'GET' and not id_pago:
        try:
            buscar = request.GET.get('buscar') or None
            ordenar_por = request.GET.get('ordenarPor', 'FECHAPAGO')
            direccion = request.GET.get('direccion', 'DESC')
            pagina = int(request.GET.get('pagina', 1))
            tamanio = int(request.GET.get('tamanio', 10))
            data, total = listar_pagos(
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
            row = obtener_pago(id_pago)
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
            tipo = (payload.get('TIPO') or 'abono').lower()
            if tipo == 'nueva_mensualidad':
                body = {
                    'IDUSUARIO': payload.get('IDUSUARIO'),
                    'IDPLAN': payload.get('IDPLAN'),
                    'ESTADOMIEMBRO': payload.get('ESTADOMIEMBRO') or 2,
                    'FECHAINICIO': payload.get('FECHAINICIO'),
                    'FECHAFIN': payload.get('FECHAFIN'),
                    'MONTOTOTAL': payload.get('MONTOTOTAL'),
                    'PAGOINICIAL': payload.get('MONTO') or payload.get('PAGOINICIAL'),
                    'IDMETODOPAGO': payload.get('IDMETODOPAGO'),
                    'IDAULA': payload.get('IDAULA'),
                    'IDTUTOR': payload.get('IDTUTOR'),
                    'OBSERVACIONES': payload.get('OBSERVACIONES'),
                    'REGISTRADOPOR': payload.get('REGISTRADOPOR'),
                }
                ok, mensaje = insertar_mensualidad(body, actor_from_request(request, body))
            else:
                body = {
                    'IDMENSUALIDAD': payload.get('IDMENSUALIDAD'),
                    'IDCUOTA': payload.get('IDCUOTA'),
                    'MONTO': payload.get('MONTO'),
                    'MONTO_CUOTA': payload.get('MONTO_CUOTA'),
                    'MORA': payload.get('MORA'),
                    'IDMETODOPAGO': payload.get('IDMETODOPAGO'),
                    'OBSERVACIONES': payload.get('OBSERVACIONES'),
                    'REGISTRADOPOR': payload.get('REGISTRADOPOR'),
                }
                ok, mensaje = insertar_abono(body, actor_from_request(request, body))
            status = 200 if ok else 400
            return JsonResponse({'ok': bool(ok), 'mensaje': mensaje}, status=status)
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=500)

    if request.method == 'PUT' and id_pago:
        payload = _parse_body(request)
        if not payload:
            return JsonResponse({'error': 'JSON inválido'}, status=400)
        try:
            ok, mensaje = actualizar_pago(id_pago, payload, actor_from_request(request, payload))
            status = 200 if ok else 400
            return JsonResponse({'ok': bool(ok), 'mensaje': mensaje}, status=status)
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=500)

    if request.method == 'DELETE' and id_pago:
        try:
            ok, mensaje = eliminar_pago(id_pago, actor_from_request(request))
            status = 200 if ok else 400
            return JsonResponse({'ok': bool(ok), 'mensaje': mensaje}, status=status)
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=500)

    return JsonResponse({'error': 'Método no permitido'}, status=405)
