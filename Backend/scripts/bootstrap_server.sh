#!/usr/bin/env bash
# Bootstrap en el servidor Linode (Ubuntu 24.04)
# Uso (como usercodex, dentro de academia_src/Backend):
#   chmod +x scripts/bootstrap_server.sh
#   ./scripts/bootstrap_server.sh
#
# Requiere: .env ya creado (copiar desde deploy/env.production.example)

set -euo pipefail

BACKEND="$(cd "$(dirname "$0")/.." && pwd)"
cd "$BACKEND"

if [[ ! -f .env ]]; then
  echo "ERROR: Crea Backend/.env antes (ver deploy/env.production.example)" >&2
  exit 1
fi

if ! dpkg -s python3.12-venv >/dev/null 2>&1; then
  echo "Instalando python3.12-venv ..."
  sudo apt-get update -qq
  sudo apt-get install -y python3.12-venv
fi

if [[ ! -x venv/bin/python ]]; then
  echo "Creando venv ..."
  python3 -m venv venv
fi

echo "Instalando dependencias ..."
venv/bin/pip install -r requirements.txt -q

echo "Importando BD MySQL ..."
sudo mysql -e "SET GLOBAL log_bin_trust_function_creators = 1;" 2>/dev/null || true
venv/bin/python scripts/fix_procedure_syntax.py 2>/dev/null || true
venv/bin/python scripts/setup_mysql_db.py "$@"

echo "Estáticos Django ..."
venv/bin/python manage.py collectstatic --noinput

echo ""
echo "OK. Reinicia Gunicorn: sudo systemctl restart gunicorn-academia"
