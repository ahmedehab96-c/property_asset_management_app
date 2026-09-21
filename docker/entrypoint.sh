#!/bin/sh
set -e

cd /var/www/html

if [ ! -f .env ] && [ -f .env.example ]; then
    cp .env.example .env
fi

if [ -f .env ] && ! grep -q "^APP_KEY=.\+" .env; then
    php artisan key:generate --force
fi

# Prefer platform-provided public URL (Render exposes RENDER_EXTERNAL_URL).
if [ -n "${RENDER_EXTERNAL_URL:-}" ]; then
    if grep -q '^APP_URL=' .env; then
        sed -i "s#^APP_URL=.*#APP_URL=${RENDER_EXTERNAL_URL}#" .env
    else
        echo "APP_URL=${RENDER_EXTERNAL_URL}" >> .env
    fi
fi

mkdir -p database
touch database/database.sqlite
chown www-data:www-data database/database.sqlite
chmod 664 database/database.sqlite

php artisan config:cache
php artisan route:cache
php artisan view:cache

if [ "$RUN_MIGRATIONS" = "true" ]; then
    php artisan migrate --force

    if [ "${SEED_ON_START:-false}" = "true" ]; then
        php artisan db:seed --force
    else
        COUNT="$(php artisan tinker --execute='echo \App\Models\User::count();' 2>/dev/null | tail -1)"
        if [ "$COUNT" = "0" ]; then
            php artisan db:seed --force
        fi
    fi
fi

exec "$@"
