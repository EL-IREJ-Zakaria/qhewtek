#!/bin/sh
set -eu

mkdir -p /var/www/backend/uploads/menu
chown -R www-data:www-data /var/www/backend/uploads

exec "$@"
