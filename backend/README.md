# Property Asset Management — Laravel Backend

API + Filament admin panel for the property platform.

## Stack

- Laravel 13
- Sanctum (Bearer tokens for Flutter)
- Filament 4 admin at `/admin`
- SQLite by default (switch to MySQL via `.env`)

## Quick start

```bash
cd backend
composer install --ignore-platform-req=ext-intl
cp .env.example .env   # if needed
php artisan key:generate
touch database/database.sqlite
php artisan migrate:fresh --seed
php artisan serve
```

> إذا ظهر خطأ `ext-intl` عند التثبيت: `composer install --ignore-platform-req=ext-intl`  
> أو ثبّت الامتداد عبر Homebrew: `brew install php` (intl عادة مضمّن) / فعّله في `php.ini`.

- **Admin web:** http://127.0.0.1:8000/admin
- **API base:** http://127.0.0.1:8000/api/v1

### Demo accounts

| Email | Password | Role |
|-------|----------|------|
| `admin@demo.com` | `password` | Admin (Filament + API) |
| `demo@demo.com` | `password` | Owner (API / mobile) |

## Main API routes

- `POST /api/v1/auth/login`
- `POST /api/v1/auth/register`
- `GET  /api/v1/auth/user` (Bearer)
- CRUD: `/properties`, `/tenants`, `/contracts`, `/owners`, `/users`, `/payments`
- Dashboard: `/dashboard/metrics`, `/dashboard/activities`, …
- Analytics: `/analytics/overview`, `/analytics/revenue`, `/analytics/occupancy`
- Image analysis: `POST /analytics/image-analysis` (local heuristics; optional OpenAI Vision via `OPENAI_API_KEY`)
- Operations: `/maintenance-requests`, `/projects`, `/tasks`, `/conversations`, …
- Notifications: `/notifications`

### Email (SMTP)

Default in `.env.example` is `MAIL_MAILER=log` (writes to `storage/logs`).  
For production, set SMTP variables (see comments in `.env.example`).

Verification codes and password-reset tokens are emailed via:
- `VerifyEmailCodeNotification`
- `ResetPasswordTokenNotification`

In `local` / `testing`, the API still returns `verification_code` / `reset_token` in the JSON body for easier mobile testing.

Response shape:

```json
{ "success": true, "message": "...", "data": { } }
```

## Tests

```bash
php artisan test
```

Feature coverage includes Auth (login, verify-email, reset password, 2FA), Analytics overview, and Maintenance requests.
