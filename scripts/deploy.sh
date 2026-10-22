#!/bin/bash
# Script de despliegue
# Descarga la ultima version del codigo y reinicia los servicios con Docker.
# Uso: ./scripts/deploy.sh [entorno]   (development, test o production)

set -e

ENTORNO=${1:-production}
export ENTORNO
RUTA_PROYECTO="$(cd "$(dirname "$0")/.." && pwd)"
ARCHIVO_ENV="$RUTA_PROYECTO/envs/.env.$ENTORNO"

cd "$RUTA_PROYECTO"

# revisar que exista el archivo del entorno
if [ ! -f "$ARCHIVO_ENV" ]; then
    echo "Error: no existe el archivo $ARCHIVO_ENV"
    exit 1
fi

echo "== Desplegando entorno: $ENTORNO =="

echo "-> Bajando la ultima version del codigo"
git pull origin main

echo "-> Construyendo las imagenes"
docker compose --env-file "$ARCHIVO_ENV" build

echo "-> Reiniciando los contenedores"
docker compose --env-file "$ARCHIVO_ENV" up -d

echo "-> Borrando imagenes que ya no se usan"
docker image prune -f

echo "-> Contenedores en ejecucion:"
docker compose ps

echo "== Despliegue terminado =="
