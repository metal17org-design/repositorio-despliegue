#!/bin/bash
# Script de backup de la base de datos
# Hace una copia de seguridad, la comprime y borra las copias viejas.
# Para que corra solo todos los dias a las 2 am se agrega con "crontab -e":
# 0 2 * * * /opt/repositorio-despliegue/cronjob/dump-and-save-db.sh >> /var/log/backup-db.log 2>&1

# si algun comando falla, el script se detiene
set -e

# cargar las variables del entorno de produccion
RUTA_SCRIPT="$(cd "$(dirname "$0")" && pwd)"
source "$RUTA_SCRIPT/../envs/.env.production"

CARPETA_BACKUP="/var/backups/db"
FECHA=$(date +%Y-%m-%d_%H-%M-%S)
ARCHIVO="$CARPETA_BACKUP/${DB_NAME}_$FECHA.sql.gz"
DIAS_GUARDAR=7

# crear la carpeta si no existe
mkdir -p "$CARPETA_BACKUP"

echo "[$(date)] Empezando backup de la base $DB_NAME"

# sacar el dump desde el contenedor de la base de datos y comprimirlo
docker exec "$DB_CONTAINER" mysqldump -u"$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" | gzip > "$ARCHIVO"

echo "[$(date)] Backup guardado en $ARCHIVO"

# borrar los backups con mas de 7 dias
find "$CARPETA_BACKUP" -name "*.sql.gz" -mtime +$DIAS_GUARDAR -delete
echo "[$(date)] Backups viejos borrados (mas de $DIAS_GUARDAR dias)"
