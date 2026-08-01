# Academia 3.0 — Contexto del proyecto

Documento maestro para que una IA (o un desarrollador nuevo) entienda **qué existe hoy**, **cómo está armado** y **qué falta por hacer**. Actualizar este archivo cuando cambie el alcance del proyecto.

---

## 1. Resumen ejecutivo

**Academia 3.0** es la reescritura moderna del sistema de gestión de **Academia VITA** (instituto / academia de preparación). Reemplaza Academia 2.0 con:

- **Frontend:** React 19 + Vite 8
- **Backend:** Django 5 + Django REST Framework
- **Base de datos:** SQL Server (esquema DB-first vía scripts SQL, modelos Django `managed = False`)
- **Patrón de referencia:** `D:\Startup\Restaurante` (menú dinámico, módulos, permisos)

### Estado actual (julio 2026)

El sistema ya tiene **módulos funcionales** conectados a API y stored procedures: usuarios, asistencias, justificaciones, mensualidades, pagos, pagos extraordinarios, planes, aulas, tutores, biblioteca, horarios, exámenes (admin + estudiante), informes de asistencias y mantenedores académicos (categorías, materias, conceptos).

El **sidebar es dinámico**: consume `GET /api/menu-usuario/?idusuario=…` según permisos en BD. Las pantallas de mantenimiento siguen un patrón común reutilizable (`DataTable`, `FormPage`, `Toolbar`, etc.).

### Decisión de arquitectura (confirmada)

**Mantener Django** — ORM + stored procedures (`connection.cursor()`), sin migraciones Django para tablas de negocio.

---

## 2. Estructura del repositorio

```
Academia3.0/
├── README.md                         ← Este archivo (contexto maestro)
├── Backend/
│   ├── backend_project/              ← settings, urls, wsgi
│   ├── api/                          ← models, views, *_crud_service.py, menu_config.py, urls.py
│   ├── db_scripts/                   ← Scripts SQL por fecha (fuente de verdad del esquema)
│   │   ├── 22_06_2026/               ← Esquema base + módulos admin
│   │   ├── 06_07_2026/ … 17_07_2026/ ← Incrementales por feature
│   │   └── 26_07_2026/               ← Último lote (mensualidad, justificación, planes, etc.)
│   ├── media/                        ← Archivos subidos (exámenes, horarios, biblioteca)
│   └── manage.py
└── Frontend/
    ├── src/
    │   ├── App.jsx                   ← Router por estado (no react-router)
    │   ├── components/
    │   │   ├── admin/                ← AdminModulos
    │   │   ├── layout/, navbar/, sidebar/
    │   │   └── mantenedor/           ← DataTable, FormPage, FormModal, Toolbar, …
    │   ├── modules/                  ← Una carpeta por módulo de negocio
    │   │   ├── usuario/, mensualidad/, pago/, asistencia/, informes/, examen/, …
    │   │   └── *.config.js           ← columnas, campos, entidad API
    │   ├── hooks/useCrud.js
    │   ├── styles/mantenedor.css     ← Estilos compartidos + tabs UI
    │   └── utils/
    └── vite.config.js                ← Proxy /api → Django :8000
```

---

## 3. Stack tecnológico

| Capa | Tecnología | Notas |
|------|------------|-------|
| Frontend | React 19 + Vite 8 | React Compiler habilitado |
| Iconos | Font Awesome | `@fortawesome/react-fontawesome` |
| Backend | Django 5 + DRF | Endpoints custom + algunos ViewSets |
| BD | SQL Server | `mssql-django` + `pyodbc` |
| Docs API | drf-spectacular | `/api/docs/` |

**No hay:** react-router, Redux, TypeScript, tests automatizados, CI/CD.

---

## 4. Cómo ejecutar localmente

### Backend

```powershell
cd Backend
python -m venv venv
.\venv\Scripts\Activate.ps1
pip install -r requirements.txt
copy .env.example .env
# Editar .env con credenciales SQL Server
python manage.py runserver
```

Servidor: `http://127.0.0.1:8000`

### Frontend

```powershell
cd Frontend
npm install
npm run dev
```

Vite proxyea `/api/*` hacia Django.

### SQL Server — orden de scripts

**BD nueva (recomendado):**

1. `Backend/db_scripts/22_06_2026/esquema_completo.sql` — esquema base (**destructivo**)
2. Scripts de `22_06_2026/ORDEN_EJECUCION.txt` (modulos_admin, usuario CRUD, asistencia, …)
3. Carpetas incrementales **en orden cronológico**, respetando el `ORDEN_EJECUCION.txt` de cada una:
   - `29_06_2026`, `06_07_2026`, `08_07_2026`, `11_07_2026`, `12_07_2026`, `14_07_2026`, `16_07_2026`, `17_07_2026`, **`26_07_2026`**

**Último lote (`26_07_2026/ORDEN_EJECUCION.txt`):**

| # | Script | Descripción |
|---|--------|-------------|
| 1–3 | plan_dias_asistencia, plan_catalogo, aula_catalogo | Días de asistencia por plan, catálogos |
| 4–5 | rename mensualidad/tutor, menu_mensualidad_tutor | Renombre membresía → mensualidad |
| 6–8 | plan_turno, plan_nombres, asesor_registro_mensualidad | Turnos y registro de mensualidad |
| 9–10 | menu_tutores_asesores, tutor_codigo_tut | Menú y códigos tutor |
| 12–13 | plan_hora_entrada_tardanza, mantenedores_codigo_autogenerado | Tardanza e IDs autogenerados |
| 14–15 | justificacion, usp_justificacion_actualizar | Módulo justificaciones + editar |
| 16 | usuario_estado_retirado | Estado Retirado (antes Inactivo) |
| 17 | mensualidad_filtro_deuda | Filtro por deuda en listado mensualidades |
| 18 | usp_usuario_resetear_contra | Restablecer contraseña al DNI |
| 19 | usp_mensualidad_listar_pagos | Pagos de una mensualidad (modal) |

**Usuarios de prueba** (tras esquema base):

| IDUSUARIO | CONTRA | Rol |
|-----------|--------|-----|
| 1 | 1234 | estudiante |
| 2 | 1234 | docente |
| 3 | 1234 | administrador |

---

## 5. Base de datos — convenciones

- Tablas y columnas en **MAYÚSCULAS** (`IDUSUARIO`, `MENSUALIDAD`, …)
- IDs de negocio: `NVARCHAR(50)` con prefijos (`MOD`, `SUB`, `PLN`, `MEN`, …)
- Fechas en BD: `NVARCHAR` formato `YYYYMMDD` o `YYYYMMDD HH:MM:SS`
- Modelos Django: **`managed = False`** — Django no altera tablas
- Lógica compleja: **stored procedures** en `db_scripts/`, llamados desde `*_crud_service.py`

### Roles (`usp_validate_user`)

| IDTIPOUSUARIO | Rol API / frontend |
|---------------|-------------------|
| 1 | `estudiante` (legacy: `usuario`) |
| 2 | `docente` (legacy: `secretario`) |
| 3 | `administrador` (legacy: `admin`) |

### Menú dinámico

Tablas: `MODULO`, `SUBMODULO`, `GRUPO_MODULO`, `USUARIO_MODULO`, exclusiones por usuario.  
Mapeo módulo → página React: `Backend/api/menu_config.py` (`MODULO_PAGE_MAP`, `SUBMODULO_PAGE_MAP`).

---

## 6. Backend — API

Base: `/api/` — Swagger: `/api/docs/`

### Endpoints principales (implementados)

| Área | Rutas |
|------|-------|
| Auth | `POST /api/login/` |
| Menú | `GET /api/menu-usuario/?idusuario=` |
| Usuarios | `GET/POST /api/usuarios/`, `GET/PUT/DELETE /api/usuarios/{id}/`, `POST …/reset-contra/` |
| Asistencias | `GET/POST /api/asistencias/` |
| Justificaciones | `GET/POST /api/justificaciones/`, `GET/PUT/DELETE /api/justificaciones/{id}/` |
| Mensualidades | `GET/POST /api/mensualidades/`, `GET/PUT/DELETE …/{id}/`, `GET …/{id}/pagos/` |
| Pagos | `GET/POST /api/pagos/`, `GET/PUT/DELETE /api/pagos/{id}/`, prefills por estudiante |
| Pagos extra | `GET/POST /api/pagos-extraordinarios/`, conceptos por estudiante |
| Planes, aulas, tutores | CRUD en `/api/planes/`, `/api/aulas/`, `/api/tutores/` |
| Biblioteca, horarios | CRUD en `/api/libros/`, `/api/horarios/` |
| Conceptos, categorías, materias | CRUD mantenedores |
| Exámenes | CRUD admin + flujo estudiante (`/api/examenes/estudiante/…`) |
| Informes | `GET /api/informes/asistencias/` |
| Admin módulos | `/api/modulos-disponibles/`, `/api/modulos-asignados-usuario/`, submódulos |

Lista completa: `Backend/api/urls.py`.

### Autenticación

- Login valida contra SQL Server; **no hay JWT/sesión Django** en producción.
- Frontend guarda en `localStorage`: `isAuthenticated`, `role`, `idusuario`, `activePage`.
- Endpoints usan `@csrf_exempt`; el rol no se revalida en cada request.

---

## 7. Frontend

### Navegación

Sin react-router. `App.jsx` mapea `activePage` → componente (`pageContent`). El sidebar carga menú desde API según `idusuario`.

### Patrón mantenedor

Cada módulo CRUD suele tener:

- `{Modulo}Page.jsx` — listado + formulario full-page o modal
- `{modulo}.config.js` — columnas, campos, `entidad` (nombre API), `pk`
- `useCrud` hook — listar, paginar, buscar, filtros, insertar, actualizar, eliminar
- Componentes compartidos: `PageHeader`, `Toolbar`, `DataTable`, `Pagination`, `FormPage`, `FormModal`, `ConfirmDialog`, `Toast`

Estilos: `Frontend/src/styles/mantenedor.css` (incluye tabs UI canónicos — ver `.cursor/rules/ui-tabs.mdc`).

### Módulos frontend (`App.jsx`)

| Página | Componente | Notas |
|--------|------------|-------|
| `usuarios` | UsuarioPage | WhatsApp, restablecer contraseña, carnet |
| `mensualidades` | MensualidadPage | Filtro deuda; modal ver pagos |
| `pagos` | PagoPage | Abono / nueva mensualidad |
| `pagos-extraordinarios` | PagoExtraPage | |
| `asistencias-marcar` | AsistenciaMarcarPage | QR / DNI |
| `asistencias-listado` | AsistenciaListadoPage | |
| `asistencias-justificacion` | JustificacionPage | Crear, ver, editar |
| `informes-asistencias` | InformeAsistenciasPage | Filtros, export Excel |
| `mantenedores-*` | Plan, Aula, Tutor, Concepto, Categoría, Materia | |
| `academico-*` | Biblioteca, Horario, Exámenes, Importar notas | |
| `examenes` | ExamenPage / ExamenEstudiantePage | Según rol |
| `admin-modulos` | AdminModulos | Asignación módulos/submódulos |

### UI

- Marca: **ACADEMIA VITA**
- Color primario: `#6a42e5` (`--color-primary` en `mantenedor.css`)
- Fuente base: 15px

---

## 8. Mensualidades — ver pagos (última feature)

En el listado de mensualidades, acción **Ver pagos** (icono recibo) abre un modal con el historial de pagos de esa mensualidad.

| Capa | Archivo / endpoint |
|------|-------------------|
| SQL | `26_07_2026/19.usp_mensualidad_listar_pagos.sql` |
| Backend | `GET /api/mensualidades/{id}/pagos/` → `listar_pagos_mensualidad()` |
| Frontend | `MensualidadPagosModal.jsx`, acción `onVerPagos` en `DataTable` |

El modal reutiliza estilos del sistema (`pago-abono-info`, `mantenedor-card`, `data-table`).

---

## 9. Qué está hecho vs qué falta

### ✅ Hecho

- [x] Login, menú dinámico por usuario, admin de módulos/submódulos
- [x] Mantenedor usuarios (CRUD, foto, carnet, QR, WhatsApp, reset contraseña)
- [x] Asistencias: marcar, listado, informe con filtros y export Excel
- [x] Justificaciones: crear, listar, editar
- [x] Mensualidades: CRUD, filtro por deuda, modal pagos
- [x] Pagos y pagos extraordinarios
- [x] Planes (turno, días asistencia, hora tardanza), aulas, tutores
- [x] Biblioteca, horarios, exámenes (admin + estudiante)
- [x] Mantenedores: conceptos, categorías, materias
- [x] Patrón mantenedor frontend reutilizable
- [x] Scripts SQL incrementales versionados por fecha

### ❌ Pendiente / parcial

- [ ] Autenticación real en API (JWT o sesión); hoy confía en `localStorage`
- [ ] Módulo **Notas** — placeholder
- [ ] Módulo **Clases** (`academico-clases`) — placeholder
- [ ] Dashboard con métricas reales
- [ ] Tests automatizados y CI/CD
- [ ] Limpiar endpoints demo (`/api/clientes/`, `clientes-sp`)
- [ ] TypeScript / react-router (opcional, no planificado)

---

## 10. Convenciones de código

### Backend

- Servicios CRUD: `{entidad}_crud_service.py` + `{entidad}_views.py`
- SPs nuevos en `db_scripts/DD_MM_YYYY/` + entrada en `ORDEN_EJECUCION.txt`
- URLs kebab-case; rutas específicas **antes** de rutas con `{id}/` (ej. `…/pagos/` antes de `…/{id}/`)

### Frontend

- Config por módulo: `{modulo}.config.js`
- CSS de módulo junto al componente; estilos globales en `mantenedor.css`
- Tabs: usar clases `ui-tabs` / `ui-tab` (regla en `.cursor/rules/ui-tabs.mdc`)

### SQL

- Scripts idempotentes cuando sea posible; documentar dependencias en `ORDEN_EJECUCION.txt`

---

## 11. Problemas conocidos

1. **Sin auth en API:** cualquier cliente puede llamar endpoints si conoce la URL.
2. **ViewSets DRF** (`/api/modulos/`, etc.) requieren `IsAuthenticated` — el SPA no envía token → 403.
3. **Docs auxiliares** en raíz (`IMPLEMENTACION_MODULOS.md`, …) pueden estar desactualizados — **este README tiene prioridad**.
4. Ejecutar scripts SQL fuera de orden puede romper FKs o SPs obsoletos.

---

## 12. Historial de decisiones

| Fecha | Decisión |
|-------|----------|
| 2026-05 | Inicio Academia 3.0 — Django + React + SQL Server |
| 2026-06 | Esquema base, menú dinámico, patrón Restaurante |
| 2026-07 | Mantenedores CRUD, mensualidades/pagos, exámenes, informes |
| 2026-07-26 | Renombre membresía→mensualidad; justificaciones; filtro deuda; modal pagos mensualidad; usuario Retirado; reset contraseña |

---

*Última actualización: 2026-07-27 — Incluye modal de pagos por mensualidad y lote de scripts `26_07_2026`.*
