#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."

# Usuarios (sin --user_pass, WP genera una contraseña aleatoria y la muestra)
./wp user create coord.web coord.web@example.com --role=editor
./wp user create profe.redes profe.redes@example.com --role=author
./wp user create alumna.fct alumna.fct@example.com --role=contributor
./wp user create familia.garcia familia.garcia@example.com --role=subscriber

# Rol a medida
./wp role create revisor "Revisor" --clone=editor
./wp cap remove revisor delete_posts delete_others_posts delete_published_posts \
  delete_private_posts delete_pages delete_others_pages delete_published_pages \
  delete_private_pages manage_categories
./wp user create revisor.fp revisor.fp@example.com --role=revisor

# Registro cerrado
./wp option update users_can_register 0
./wp option update default_role subscriber

# Plugins
./wp plugin delete akismet hello || true
./wp plugin install contact-form-7 flamingo simple-history cookie-law-info --activate

# Comprobaciones
./wp user list --fields=user_login,roles
./wp cap list revisor | grep delete || echo "OK: revisor sin capacidades delete_*"
./wp plugin list --fields=name,status
