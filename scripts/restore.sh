#!/bin/bash
# Restaura una copia. Sin argumentos usa la más reciente.
# Uso: bash scripts/restore.sh [backups/db_X.sql.gz backups/wpcontent_X.tar.gz]
set -euo pipefail
cd "$(dirname "$0")/.."

F_DB="${1:-$(ls -1t backups/db_*.sql.gz 2>/dev/null | head -1)}"
F_WP="${2:-$(ls -1t backups/wpcontent_*.tar.gz 2>/dev/null | head -1)}"
[ -f "$F_DB" ] && [ -f "$F_WP" ] || { echo "ERROR: no hay copias que restaurar"; exit 1; }

echo "Se va a SOBRESCRIBIR la base de datos y wp-content con:"
echo "  $F_DB"
echo "  $F_WP"
read -r -p "¿Continuar? (escribe si): " R
[ "$R" = "si" ] || { echo "Cancelado."; exit 0; }

gzip -t "$F_DB"
tar -tzf "$F_WP" > /dev/null

gunzip -c "$F_DB" | docker compose exec -T db sh -c \
  'exec mariadb -u"$WP_DB_USER" -p"$WP_DB_PASSWORD" "$WP_DB_NAME"'
docker compose exec -T wordpress tar -xzf - -C /var/www/html < "$F_WP"

./wp cache flush 2>/dev/null | grep -v Container || true
echo "OK: restauración completada"
