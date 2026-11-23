# WordPress en Docker (IAW 0376 · RA2 y RA3)

Sitio WordPress desplegado con Docker Compose: nginx + PHP-FPM + MariaDB, más un
contenedor de usar y tirar con WP-CLI para administrarlo desde la terminal.
Proyecto del módulo Implantación de Aplicaciones Web (ASIR 2º).

## Requisitos

- Docker y el plugin Docker Compose (`docker compose version`)
- Git
- Puerto 8080 libre

## Arrancar desde cero

```bash
git clone https://github.com/adripasalbe/ra2-csm.git
cd ra2-csm
cp .env.example .env        # edita las contraseñas: nano .env
docker compose up -d
docker compose ps           # nginx, wordpress y db en marcha
```

La base de datos y el usuario los crea MariaDB sola en el primer arranque, a
partir de las variables `MYSQL_*` del `.env`. Hay que instalar WordPress:

```bash
./wp core install --url=http://localhost:8080 --title="Web en Docker" \
  --admin_user=admin --admin_password='UnaClaveFuerte' \
  --admin_email=tu@correo.com --skip-email
./wp rewrite structure '/%postname%/'
```

Abre `http://localhost:8080` y `http://localhost:8080/wp-admin/` (con `http://`
escrito a mano). Si `./wp` no tiene permiso de ejecución usa `bash wp ...`.

> No ejecutes `docker compose down -v`: borra los volúmenes (`wp_data`, `db_data`)
> y con ellos el sitio. Para parar usa `docker compose down`.

## WP-CLI

`./wp` es un atajo de `docker compose run --rm -T wpcli wp`. El servicio `wpcli`
comparte el volumen y las variables de WordPress, se ejecuta y se borra.

```bash
./wp user list
./wp plugin list
```

## Scripts

| Script | Qué hace |
|---|---|
| `scripts/practica1.sh` | Crea usuarios, el rol `revisor` y los plugins |
| `scripts/backup.sh` | Copia de la BD y de `wp-content` en `backups/` (conserva 7) |
| `scripts/restore.sh` | Restaura la copia más reciente (pide confirmación) |

```bash
bash scripts/backup.sh
bash scripts/restore.sh
```

## GitHub Codespaces (opcional)

El `docker-compose.yml` calcula `WP_HOME` y `WP_SITEURL` a partir de las
cabeceras `Host` y `X-Forwarded-Host`, así que funciona igual en local y en un
codespace. Pasos: crear el codespace sobre la rama, copiar `.env.example` a
`.env`, `docker compose up -d`, instalar WordPress y publicar el puerto 8080 como
público desde la pestaña PORTS. No se ha probado en este repositorio.

## Estructura
docker-compose.yml # nginx, wordpress, db y wpcli (perfil cli)
.env.example # plantilla de variables (el .env real no se sube)
wp # atajo para WP-CLI
nginx/default.conf # bloquea xmlrpc.php, try_files para permalinks
config/uploads.ini # límites de subida de PHP

datos/ # ficheros de entrada: contenidos_asir.xml, usuarios.csv
scripts/ # practica1.sh, backup.sh, restore.sh
docs/ # documentación (ver abajo)
backups/ # copias (ignorado por Git)
backups/ # copias (ignorado por Git)
exportaciones/ # WXR, CSV, JSON, SQL (ignorado por Git)
informes/ # informes de acceso (ignorado por Git)


## Documentación

- [docs/personalizacion.md](docs/personalizacion.md): contenidos, tema y PHP
- [docs/pruebas.md](docs/pruebas.md): pruebas, rendimiento y publicación

## Seguridad

- `xmlrpc.php` devuelve 403 en nginx.
- `DISALLOW_FILE_EDIT` activo: no se editan temas ni plugins desde el panel.
- Registro de usuarios cerrado y rol por defecto Suscriptor.
- `.env`, `backups/` y `exportaciones/` están en `.gitignore`: los volcados
  contienen correos y contraseñas cifradas (datos personales).
- Deducir la dirección de las cabeceras `Host` es solo para clase; en
  producción se fija un dominio con HTTPS (RA6).
