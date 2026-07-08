"""Generación de carnet PDF — posiciones idénticas a Intranet_Vita CarnetService.java"""
import base64
import binascii
from io import BytesIO
from pathlib import Path

import qrcode
from django.conf import settings
from PIL import Image
from pypdf import PdfReader, PdfWriter
from reportlab.lib.colors import grey
from reportlab.lib.utils import ImageReader
from reportlab.pdfgen import canvas

# Diseño base: tarjeta 50mm x 85mm (proporciones sobre tamaño real del template)
POS = {
    'nombre_y': 38 / 85,
    'apellido_y': 34 / 85,
    'dni_y': 7 / 85,
    'qr_y': (11 - 0.65) / 85,
    'foto_y': 44.6 / 85,
    'qr_size': 20 / 50,
    'foto_size': 24.15 / 50,
    'qr_offset_x': 0.25 / 50,
    'foto_offset_x': 0.23 / 50,
}


def _template_path():
    base = Path(settings.BASE_DIR)
    candidates = [
        base / 'templates' / 'carnet' / 'template.pdf',
        base / 'media' / 'templates' / 'carnet' / 'template.pdf',
    ]
    for path in candidates:
        if path.exists():
            return path
    return None


def _media_qr_dir():
    path = Path(settings.MEDIA_ROOT) / 'qrcodes'
    path.mkdir(parents=True, exist_ok=True)
    return path


def generate_qr_png(dni: str) -> Path:
    """QR con contenido = DNI (texto plano), igual que Intranet."""
    out = _media_qr_dir() / f'qr_{dni}.png'
    img = qrcode.make(str(dni), box_size=8, border=2)
    img.save(out)
    return out


def _crop_qr_image(qr_path: Path) -> Image.Image:
    img = Image.open(qr_path).convert('RGB')
    mx = int(img.width * 0.09)
    my = int(img.height * 0.09)
    return img.crop((mx, my, img.width - mx, img.height - my))


def _foto_image_reader(usuario: dict):
    """FOTO (Base64 en BD) o FOTOPERFIL (ruta en media)."""
    foto_b64 = usuario.get('FOTO')
    if foto_b64:
        raw = str(foto_b64).strip()
        if raw.startswith('data:'):
            raw = raw.split(',', 1)[-1]
        try:
            data = base64.b64decode(raw, validate=True)
            if data:
                return ImageReader(BytesIO(data))
        except (binascii.Error, ValueError):
            pass

    foto_path_rel = usuario.get('FOTOPERFIL')
    if foto_path_rel:
        foto_path = Path(settings.MEDIA_ROOT) / foto_path_rel
        if foto_path.exists():
            return str(foto_path)

    return None


def _draw_foto(c, usuario: dict, page_width: float, page_height: float):
    foto_src = _foto_image_reader(usuario)
    if not foto_src:
        return
    foto_size = page_width * POS['foto_size']
    foto_x = (page_width - foto_size) / 2 - page_width * POS['foto_offset_x']
    foto_y = page_height * POS['foto_y']
    c.drawImage(foto_src, foto_x, foto_y, width=foto_size, height=foto_size, mask='auto')


def generate_carnet_pdf(usuario: dict) -> bytes:
    """
    usuario: dict con NOMBRE, APELLIDO, DNI, opcional FOTO (Base64) o FOTOPERFIL
    """
    dni = str(usuario.get('DNI') or '')
    qr_path = generate_qr_png(dni)
    template = _template_path()

    if not template:
        return _basic_carnet_pdf(usuario, qr_path)

    reader = PdfReader(str(template))
    page = reader.pages[0]
    page_width = float(page.mediabox.width)
    page_height = float(page.mediabox.height)

    overlay_buffer = BytesIO()
    c = canvas.Canvas(overlay_buffer, pagesize=(page_width, page_height))

    nombre_y = page_height * POS['nombre_y']
    apellido_y = page_height * POS['apellido_y']
    dni_y = page_height * POS['dni_y']
    qr_y = page_height * POS['qr_y']
    qr_size = page_width * POS['qr_size']
    qr_x = (page_width - qr_size) / 2 - page_width * POS['qr_offset_x']

    c.setFont('Helvetica-Bold', 10)
    if usuario.get('NOMBRE'):
        c.drawCentredString(page_width / 2, nombre_y, str(usuario['NOMBRE']).upper())
    if usuario.get('APELLIDO'):
        c.drawCentredString(page_width / 2, apellido_y, str(usuario['APELLIDO']).upper())

    c.setFont('Helvetica-Bold', 5)
    c.setFillColor(grey)
    if dni:
        c.drawCentredString(page_width / 2, dni_y, dni)
    c.setFillColor('black')

    if qr_path.exists():
        cropped = _crop_qr_image(qr_path)
        qr_buf = BytesIO()
        cropped.save(qr_buf, format='PNG')
        qr_buf.seek(0)
        c.drawImage(ImageReader(qr_buf), qr_x, qr_y, width=qr_size, height=qr_size, mask='auto')

    _draw_foto(c, usuario, page_width, page_height)

    c.save()
    overlay_buffer.seek(0)

    overlay_reader = PdfReader(overlay_buffer)
    writer = PdfWriter()
    base_page = reader.pages[0]
    base_page.merge_page(overlay_reader.pages[0])
    writer.add_page(base_page)

    out = BytesIO()
    writer.write(out)
    return out.getvalue()


def _basic_carnet_pdf(usuario: dict, qr_path: Path) -> bytes:
    buffer = BytesIO()
    # 50mm x 85mm ≈ 141.7 x 240.9 pt
    c = canvas.Canvas(buffer, pagesize=(141.7, 240.9))
    c.setFont('Helvetica-Bold', 10)
    y = 220
    if usuario.get('NOMBRE'):
        c.drawCentredString(70, y, str(usuario['NOMBRE']).upper())
        y -= 14
    if usuario.get('APELLIDO'):
        c.drawCentredString(70, y, str(usuario['APELLIDO']).upper())
        y -= 14
    if usuario.get('DNI'):
        c.setFont('Helvetica-Bold', 5)
        c.setFillColor(grey)
        c.drawCentredString(70, y, str(usuario['DNI']))
    if qr_path.exists():
        c.drawImage(str(qr_path), 42, 80, width=56, height=56, mask='auto')
    _draw_foto(c, usuario, 141.7, 240.9)
    c.save()
    return buffer.getvalue()
