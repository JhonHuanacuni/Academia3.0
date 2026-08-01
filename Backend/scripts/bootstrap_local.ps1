# Bootstrap local Academia 3.0 (MySQL + Django)
# Usa las mismas credenciales que Restaurante (Backend/.env) si existen.
# Uso: cd Backend && .\scripts\bootstrap_local.ps1

$ErrorActionPreference = "Stop"
$Backend = Split-Path $PSScriptRoot -Parent
$RestauranteEnv = "D:\Startup\Restaurante\Backend\.env"
Set-Location $Backend

if (-not (Test-Path ".\venv\Scripts\python.exe")) {
    Write-Host "Creando venv en Backend\venv ..."
    python -m venv venv
}

Write-Host "Instalando dependencias Python ..."
.\venv\Scripts\pip.exe install -r requirements.txt -q

$envFile = Join-Path $Backend ".env"
$pwd = $env:MYSQL_ROOT_PASSWORD

if (-not $pwd -and (Test-Path $RestauranteEnv)) {
    $line = Get-Content $RestauranteEnv | Where-Object { $_ -match '^DB_PASSWORD=' } | Select-Object -First 1
    if ($line) { $pwd = ($line -split '=', 2)[1].Trim() }
}

if (-not $pwd) { $pwd = "123456789" }

if (-not (Test-Path $envFile)) {
    $content = @"
SECRET_KEY=django-insecure-change-me
DEBUG=True
DB_ENGINE=mysql
DB_NAME=AcademiaDB
DB_USER=root
DB_PASSWORD=$pwd
DB_HOST=127.0.0.1
DB_PORT=3306
"@
    Set-Content -Path $envFile -Value $content -Encoding UTF8
    Write-Host ".env creado (MySQL root, misma clave que Restaurante)."
} else {
    Write-Host ".env ya existe — se mantiene."
}

$env:MYSQL_ROOT_PASSWORD = $pwd
$env:DB_PASSWORD = $pwd

Write-Host "Importando esquema MySQL (db_scripts_mysql) ..."
.\venv\Scripts\python.exe scripts\setup_mysql_db.py
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host ""
Write-Host "Backend listo. Inicia con: .\venv\Scripts\python.exe manage.py runserver"
Write-Host "Frontend (otra terminal): cd ..\Frontend && npm run dev"
