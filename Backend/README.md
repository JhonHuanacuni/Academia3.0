# Django Backend

Este backend usa Django y expone una API simple para que el frontend React pueda consumirla.

## Pasos de configuración

1. Crear un entorno virtual:
   ```powershell
   cd Backend
   python -m venv venv
   .\venv\Scripts\activate
   ```
2. Instalar dependencias:
   ```powershell
   pip install -r requirements.txt
   ```
3. Crear el archivo de configuración:
   ```powershell
   copy .env.example .env
   ```
4. Editar `.env` con los datos de tu SQL Server:
   - `DB_ENGINE=mssql`
   - `DB_NAME`
   - `DB_USER`
   - `DB_PASSWORD`
   - `DB_HOST`
   - `DB_PORT`
   - `DB_DRIVER`
5. Ejecutar migraciones para crear tablas en SQL Server:
   ```powershell
   python manage.py migrate
   ```
6. Iniciar el servidor Django:
   ```powershell
   python manage.py runserver
   ```

## Estructura limpia y escalable

- `api/models.py` contiene los modelos que representan tablas en SQL Server.
- `api/services.py` encapsula la lógica de acceso a datos y la ejecución de stored procedures.
- `db_scripts/usp_get_clientes.sql` es un script de referencia para crear el stored procedure en SQL Server.

## Diferencia entre ORM y Stored Procedures

- `GET /api/clientes/` usa el ORM de Django. Esto significa que Django construye y ejecuta la consulta SQL automáticamente a partir del modelo `Cliente`.
- `GET /api/clientes-sp/` ejecuta directamente un stored procedure en SQL Server (`usp_get_clientes`) mediante un cursor SQL.

El endpoint ORM es útil para consultas sencillas y cuando quieres aprovechar validaciones, filtros y relaciones de Django.
El endpoint con SP es útil cuando la lógica ya está definida en el servidor de base de datos, cuando necesitas optimizaciones específicas o quieres usar procedimientos almacenados existentes.

## Migraciones y tablas en SQL Server

Si tus tablas ya las creas manualmente en SQL Server y quieres que Django solo las use, no necesitas ejecutar `manage.py migrate` para esas tablas específicas.
- En `api/models.py`, `Cliente` está marcado con `managed = False`, por lo que Django no intentará crear ni modificar la tabla `clientes`.
- Aún puedes usar `migrate` para otras tablas de Django o apps que sí quieras que Django controle.

## Conexión a la base de datos

La conexión a la base de datos está en `backend_project/settings.py`.
- Lee las variables desde el archivo `.env`.
- Si pones `DB_ENGINE=mssql` en `.env`, Django usa `mssql-django` y `pyodbc`.
- El driver y datos de conexión se configuran con:
  - `DB_NAME`
  - `DB_USER`
  - `DB_PASSWORD`
  - `DB_HOST`
  - `DB_PORT`
  - `DB_DRIVER`

Por eso no hay un archivo de conexión separado: Django usa `settings.py` como el lugar central para la configuración de la base de datos.

## Uso del directorio db_scripts

El archivo en `db_scripts/` no es obligatorio para la ejecución de Django.
Está ahí para:
- versionar el script del stored procedure en tu repositorio,
- facilitar la creación/actualización en SQL Server,
- compartir la definición del SP con otros desarrolladores.

En producción, si el SP ya está creado en SQL Server, no necesitas ejecutar ese archivo desde Django; es solo un script de referencia.

## Requisitos adicionales

- SQL Server instalado y accesible.
- Driver ODBC apropiado (`ODBC Driver 18 for SQL Server` o equivalente).
- `pyodbc` instalado para que `mssql-django` pueda conectar con SQL Server.

## API disponible

- `http://127.0.0.1:8000/api/status/`
- `http://127.0.0.1:8000/api/clientes/`
- `http://127.0.0.1:8000/api/clientes-sp/`

El frontend React está configurado para usar `/api` como proxy hacia este servidor.
