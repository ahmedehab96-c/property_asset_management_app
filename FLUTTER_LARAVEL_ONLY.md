# المشروع: Flutter موبايل + Laravel ويب/API

## القرار المعماري

| قبل | بعد |
|-----|-----|
| Flutter Web لوحة أدمن | **Laravel Filament** في `backend/` على `/admin` |
| API خارج المستودع فقط | **`backend/`** — Laravel + Sanctum (`/api/v1`) |
| React / Flutter Web | محذوف — الموبايل Flutter فقط |

```
mobile_app/   → Flutter (iOS/Android)
backend/      → Laravel API + Filament admin
```

## التشغيل

### Laravel (API + أدمن ويب)

```bash
cd backend
composer install
php artisan migrate:fresh --seed
php artisan serve
```

| الرابط | الوصف |
|--------|--------|
| http://127.0.0.1:8000/admin | لوحة الأدمن Filament |
| http://127.0.0.1:8000/api/v1 | REST API للموبايل |

حسابات: `admin@demo.com` / `demo@demo.com` — `password`

### Flutter (موبايل)

```bash
cd mobile_app
cp .env.example .env
flutter pub get
flutter run
```

`.env`:
```
API_BASE_URL=http://127.0.0.1:8000/api/v1
```

## التصميم

- **ألوان:** أزرق `#2563EB` + تيل `#3D8B7A` + ذهبي `#C9A227`
- **موبايل:** `AmbientBackground` + `AppGradients` + `AppScaffold`
- **أدمن ويب:** ثيم Filament + `public/css/filament-estate.css` (خلفيات متدرجة)

## لوحة الأدمن (Filament)

Dashboard، Analytics (رسوم بيانية)، Properties، Tenants، Contracts، Owners، Users، Payments، Notifications،
Projects، Maintenance، Calendar، Tasks، Conversations، Mobile Requests، Reports.


## جودة الكود

```bash
cd mobile_app && flutter analyze
cd backend && php artisan test
```
