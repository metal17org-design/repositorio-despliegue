# Repositorio base de despliegue

Este repositorio es el que hice para el Taller Evaluativo Avanzado del modulo de Administrador de Servidores (IBES). La idea es tener todo el despliegue de una aplicacion web en un solo lugar, con scripts, para no tener que configurar el servidor a mano y evitar errores.

## Estructura de carpetas

- `cronjob/` : tareas programadas. Aqui esta `dump-and-save-db.sh`, que hace el backup de la base de datos.
- `envs/` : archivos de configuracion de cada entorno (desarrollo, prueba y produccion).
- `nginx/` : configuracion del servidor web y proxy inverso (`app.miempresa.local.conf`).
- `scripts/` : scripts del despliegue. Aqui esta `deploy.sh`.
- `docker-compose.yml` : define los contenedores de la aplicacion y la base de datos.

## Como usarlo

1. Clonar el repositorio en el servidor:

```
git clone <url-del-repositorio> /opt/repositorio-despliegue
cd /opt/repositorio-despliegue
```

2. Dar permisos de ejecucion a los scripts:

```
chmod +x scripts/deploy.sh cronjob/dump-and-save-db.sh
```

3. Desplegar la aplicacion (por defecto usa production):

```
./scripts/deploy.sh production
```

4. Copiar la configuracion de nginx y activarla:

```
sudo cp nginx/app.miempresa.local.conf /etc/nginx/conf.d/
sudo nginx -t
sudo systemctl reload nginx
```

5. Programar el backup con cron (todos los dias a las 2 am):

```
crontab -e
0 2 * * * /opt/repositorio-despliegue/cronjob/dump-and-save-db.sh >> /var/log/backup-db.log 2>&1
```

## Instalar certificado SSL con Certbot (Let's Encrypt)

Estos son los pasos para poner HTTPS en el servidor (Ubuntu/Debian con nginx):

1. Instalar certbot y el plugin de nginx:

```
sudo apt update
sudo apt install certbot python3-certbot-nginx
```

2. Revisar que el puerto 80 y el 443 esten abiertos en el firewall:

```
sudo ufw allow 'Nginx Full'
```

3. Pedir el certificado para el dominio:

```
sudo certbot --nginx -d tu-dominio.com
```

Certbot pregunta un correo y si acepto los terminos. Despues modifica solo la configuracion de nginx para usar HTTPS y redirigir el trafico del puerto 80.

4. Probar que la renovacion automatica funciona (los certificados duran 90 dias):

```
sudo certbot renew --dry-run
```

5. Abrir el sitio con https:// y revisar que salga el candado.

Nota: Let's Encrypt no da certificados para dominios que terminan en `.local` como `app.miempresa.local`, porque no son dominios publicos. Para que Certbot funcione se necesita un dominio real que apunte a la IP publica del servidor. Dentro de la red de la empresa se podria usar un certificado interno.

## Active Directory

Los usuarios que administran los servidores estan en la OU `DevOps_Team` del dominio, en el grupo `Administradores_Web`.
