import json
from django.http import HttpResponse, JsonResponse
from django.views.decorators.csrf import csrf_exempt
from .asistencia_service import (
    marcar_asistencia_por_dni,
    marcar_asistencia_orm,
    listar_asistencias,
    listar_asistencias_orm,
    respuesta_marcar,
    obtener_usuario_por_dni,
)
from .carnet_service import generate_carnet_pdf
from .usuario_crud_service import obtener_usuario


@csrf_exempt
def asistencias_api(request):
    if request.method == 'GET':
        fecha = request.GET.get('fecha')
        buscar = request.GET.get('buscar')
        pagina = int(request.GET.get('pagina', 1))
        tamanio = int(request.GET.get('tamanio', 50))
        try:
            data, total = listar_asistencias(fecha, buscar, pagina, tamanio)
        except Exception:
            data, total = listar_asistencias_orm(fecha, buscar)
        return JsonResponse({
            'data': data,
            'total': total,
            'pagina': pagina,
            'tamanioPagina': tamanio,
        })

    if request.method == 'POST':
        try:
            payload = json.loads(request.body.decode('utf-8'))
        except Exception:
            return JsonResponse({'error': 'JSON inválido'}, status=400)

        dni = payload.get('dni')
        id_registrador = payload.get('idRegistrador') or payload.get('registrado_por')

        try:
            ok, mensaje, _, row = marcar_asistencia_por_dni(dni, id_registrador)
        except Exception:
            ok, mensaje, _, row = marcar_asistencia_orm(dni, id_registrador)

        if ok != 1:
            is_dup = 'ya tiene' in (mensaje or '').lower() or 'registrada' in (mensaje or '').lower()
            body = {
                'error': 'Asistencia ya registrada' if is_dup else 'Error al registrar',
                'detail': mensaje,
            }
            if is_dup:
                body['type'] = 'duplicate_attendance'
            user = obtener_usuario_por_dni(dni) if dni else None
            if user:
                body['nombres'] = user.get('NOMBRE')
                body['apellidos'] = user.get('APELLIDO')
                body['dni'] = user.get('DNI')
                foto = user.get('FOTOPERFIL')
                if foto:
                    body['fotoUrl'] = f'/media/{foto}'
            return JsonResponse(body, status=400)

        return JsonResponse(respuesta_marcar(row), status=201)

    return JsonResponse({'error': 'Método no permitido'}, status=405)


@csrf_exempt
def usuario_carnet(request, id_usuario):
    if request.method != 'GET':
        return JsonResponse({'error': 'Método no permitido'}, status=405)
    try:
        user = obtener_usuario(id_usuario)
        if not user:
            return JsonResponse({'error': 'Usuario no encontrado'}, status=404)
        pdf_bytes = generate_carnet_pdf(user)
        dni = user.get('DNI') or id_usuario
        response = HttpResponse(pdf_bytes, content_type='application/pdf')
        response['Content-Disposition'] = f'attachment; filename="carnet_{dni}.pdf"'
        return response
    except Exception as exc:
        return JsonResponse({'error': str(exc)}, status=500)
