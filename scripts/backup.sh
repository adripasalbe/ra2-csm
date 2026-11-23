#!/bin/bash
# Copia de seguridad: base de datos + wp-content. Conserva las 7 más recientes.
set -euo pipefail
cd "$(dirname "$0")/.."

mkdir -p backups
TS=$(date +%Y%m%d_%H%M%S)
F_DB="backups/db_${TS}.sql.gz"
F_WP="backups/wpcontent_${TS}.tar.gz"

fail() { echo "ERROR: $1"; rm -f "$F_DB" "$F_WP"; exit 1; }

# 1. Comprobar que los servicios están en marcha
for s in db wordpress; do
  docker compose ps --status running --services | grep -qx "$s" \
    || fail "el servicio $s no está en marcha"
done

# 2. Volcar la base de datos (las variables se leen dentro del contenedor)
docker compose exec -T db sh -c 'exec mariadb-dump --single-transaction \
  -u"$WP_DB_USER" -p"$WP_DB_PASSWORD" "$WP_DB_NAME"' | gzip > "$F_DB" \
  || fail "falló el volcado de la base de datos"

# 3. Empaquetar wp-content
docker compose exec -T wordpress tar -czf - -C /var/www/html wp-content > "$F_WP" \
  || fail "falló el empaquetado de wp-content"

# 4. Verificar
gzip -t "$F_DB" || fail "el volcado SQL está corrupto"
[ "$(zcat "$F_DB" | grep -c 'CREATE TABLE')" -gt 0 ] || fail "el volcado no contiene tablas"
tar -tzf "$F_WP" > /dev/null || fail "el tar de wp-content está corrupto"

# 5. Rotar: conservar solo las 7 más recientes de cada tipo
ls -1t backups/db_*.sql.gz 2>/dev/null | tail -n +8 | xargs -r rm -f
ls -1t backups/wpcontent_*.tar.gz 2>/dev/null | tail -n +8 | xargs -r rm -f

echo "OK: $F_DB ($(du -h "$F_DB" | cut -f1))"
echo "OK: $F_WP ($(du -h "$F_WP" | cut -f1))"
