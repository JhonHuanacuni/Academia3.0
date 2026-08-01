# Backend — Academia 3.0

API Django para el frontend React. La documentación maestra del proyecto está en [`../README.md`](../README.md).

## Setup rápido (MySQL local — recomendado)

```powershell
cd Backend
.\scripts\bootstrap_local.ps1
.\venv\Scripts\python.exe manage.py runserver
```

O manualmente:

```powershell
cd Backend
python -m venv venv
.\venv\Scripts\pip.exe install -r requirements.txt
copy .env.example .env
python scripts\setup_mysql_db.py
.\venv\Scripts\python.exe manage.py runserver
```

## Despliegue Linode

Ver `deploy/CONTEXTO_DESPLIEGUE.txt` y plantillas en `deploy/`:

| Recurso | Valor |
|---------|-------|
| Subdominio | `academia.usercodex.com` |
| BD | `AcademiaDB` |
| Código servidor | `/home/usercodex/academia_src` |
| Frontend dist | `/home/usercodex/academia_front` |
| Gunicorn | servicio `gunicorn-academia`, puerto `8003` |

Scripts MySQL: `db_scripts_mysql/` → `python scripts/setup_mysql_db.py`

## Setup legacy (SQL Server)

```powershell
# DB_ENGINE=mssql en .env — ver db_scripts/ por fecha
```

## Estructura

| Carpeta / archivo | Uso |
|-------------------|-----|
| `api/models.py` | Modelos `managed = False` ↔ tablas SQL Server |
| `api/*_crud_service.py` | Lógica de negocio + llamadas a SPs |
| `api/*_views.py` | Endpoints HTTP |
| `api/menu_config.py` | Mapa módulo/submódulo → página frontend |
| `api/urls.py` | Rutas `/api/…` |
| `db_scripts/` | Scripts SQL por fecha; ver `ORDEN_EJECUCION.txt` en cada carpeta |

## Scripts SQL

1. BD nueva: `db_scripts/22_06_2026/esquema_completo.sql` + orden en `22_06_2026/ORDEN_EJECUCION.txt`
2. Luego carpetas incrementales en orden cronológico hasta `26_07_2026/`

**No uses `manage.py migrate`** para tablas de negocio — el esquema lo definen los scripts SQL.

## API

- Swagger: `http://127.0.0.1:8000/api/docs/`
- Health: `GET /api/status/`
- Login: `POST /api/login/` — body `{ "username", "password" }`

Endpoints por módulo: ver `api/urls.py` y el README raíz.

## Conexión BD

Variables en `.env` → `backend_project/settings.py`:

- `DB_ENGINE=mssql`
- `DB_NAME`, `DB_USER`, `DB_PASSWORD`, `DB_HOST`, `DB_PORT`, `DB_DRIVER`
- `DB_TRUSTED_CONNECTION=true` para auth Windows (opcional)

Requiere **ODBC Driver 18 for SQL Server** (o equivalente) y `pyodbc`.
