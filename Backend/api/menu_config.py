# Módulos que se muestran como un solo enlace (sin desplegar submódulos)
MODULOS_MENU_DIRECTO = frozenset({
    'MOD001',  # Dashboard
    'MOD002',  # Usuarios (solo listado; alta vía + Nuevo)
    'MOD008',  # Administración de módulos
})

# Módulos que un administrador (tipo 3) no puede perder nunca
MODULOS_PROTEGIDOS_ADMIN = frozenset({
    'MOD001',  # Dashboard — siempre visible
    'MOD008',  # Administración de módulos — evita bloqueo del panel
})

MODULO_PAGE_MAP = {
    'MOD001': 'dashboard',
    'MOD002': 'usuarios',
    'MOD003': 'asistencias',
    'MOD004': 'mensualidades',
    'MOD005': 'biblioteca',
    'MOD006': 'examenes',
    'MOD008': 'admin-modulos',
    'MOD009': 'academico',
    'MOD010': 'informes',
    'MOD011': 'mantenedores',
}

SUBMODULO_PAGE_MAP = {
    'SUB002': 'usuarios',
    'SUB003': 'asistencias-marcar',
    'SUB004': 'asistencias-listado',
    'SUB025': 'asistencias-justificacion',
    'SUB005': 'mensualidades',
    # SUB006 (Ver mensualidades) desactivado — listado vía SUB005 + Nuevo
    'SUB007': 'pagos',
    'SUB009': 'admin-modulos',
    'SUB010': 'mantenedores-aulas',
    'SUB011': 'informes-asistencias',
    'SUB012': 'mantenedores-tutores',
    'SUB013': 'mantenedores-planes',
    'SUB014': 'academico-biblioteca',
    'SUB015': 'academico-examenes',
    'SUB016': 'academico-horario',
    'SUB017': 'academico-clases',
    'SUB026': 'academico-notas',
    'SUB027': 'academico-auditoria',
    'SUB018': 'pagos-extraordinarios',
    'SUB019': 'mantenedores-conceptos',
    'SUB022': 'mantenedores-categorias',
    'SUB023': 'mantenedores-materias',
}

ROLE_TO_TIPOUSUARIO = {
    'estudiante': '1',
    'docente': '2',
    'trabajador': '2',
    'administrador': '3',
    # compatibilidad legacy
    'usuario': '1',
    'secretario': '2',
    'admin': '3',
}
