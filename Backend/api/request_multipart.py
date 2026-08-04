"""Utilidades para leer multipart en PUT/PATCH (Django solo llena POST/FILES en POST)."""


def multipart_post_files(request):
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
