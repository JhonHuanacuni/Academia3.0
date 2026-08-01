# Frontend — Academia 3.0

SPA React + Vite. Documentación maestra: [`../README.md`](../README.md).

## Setup

```powershell
cd Frontend
npm install
npm run dev
```

El proxy en `vite.config.js` redirige `/api/*` a Django (`http://127.0.0.1:8000`).

## Estructura

| Ruta | Uso |
|------|-----|
| `src/App.jsx` | Login + layout + mapa `activePage` → componente |
| `src/components/mantenedor/` | UI reutilizable (tablas, formularios, modales) |
| `src/components/sidebar/` | Menú dinámico desde `/api/menu-usuario/` |
| `src/modules/{modulo}/` | Página + `*.config.js` por módulo de negocio |
| `src/hooks/useCrud.js` | Hook CRUD genérico |
| `src/styles/mantenedor.css` | Estilos globales del sistema |

## Añadir un módulo

1. Crear `src/modules/miModulo/MiModuloPage.jsx` y `miModulo.config.js`
2. Registrar la página en `App.jsx` (`pageContent`)
3. Mapear en backend `api/menu_config.py` y script SQL de submódulo si aplica

## UI

- Iconos: Font Awesome (`@fortawesome/react-fontawesome`)
- Color primario: `#6a42e5` (variables CSS en `mantenedor.css`)
- Tabs: clases `ui-tabs` / `ui-tab` — ver regla `.cursor/rules/ui-tabs.mdc`
