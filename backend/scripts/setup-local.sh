#!/usr/bin/env bash
# Local setup: migrate/seed Laravel then print run commands.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "==> Backend migrate + seed"
cd "$ROOT/backend"
php artisan migrate:fresh --seed --no-interaction

echo ""
echo "Done. Run in two terminals:"
echo "  cd backend && php artisan serve"
echo "  cd mobile_app && flutter run"
echo ""
echo "Admin:  http://127.0.0.1:8000/admin"
echo "API:    http://127.0.0.1:8000/api/v1"
echo "Login:  admin@demo.com / password"
