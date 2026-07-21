# Property Asset Management

منصة إدارة عقارات: **Flutter** (تطبيق موبايل) + **Laravel** (API + لوحة أدمن Filament).

## البنية

| المكون | المسار | الوصف |
|--------|--------|--------|
| **الموبايل** | [`mobile_app/`](mobile_app/) | Flutter — iOS / Android (مالك/مستأجر) |
| **الويب + API** | [`backend/`](backend/) | Laravel 13 + Sanctum + Filament 4 |

> لا يوجد Flutter Web. لوحة الأدمن على Laravel: `/admin`

## البدء السريع

### 1) الباكند (Laravel)

```bash
cd backend
composer install
cp .env.example .env   # إن لزم
php artisan key:generate
touch database/database.sqlite
php artisan migrate:fresh --seed
php artisan serve
```

- أدمن: http://127.0.0.1:8000/admin  
- API: http://127.0.0.1:8000/api/v1  
- حسابات تجريبية: `admin@demo.com` / `demo@demo.com` — كلمة المرور `password`

### 2) تطبيق الموبايل (Flutter)

```bash
cd mobile_app
cp .env.example .env   # API_BASE_URL=http://127.0.0.1:8000/api/v1
flutter pub get
flutter run
```

### بناء APK

```bash
cd mobile_app
flutter build apk --release
```

## الوثائق

- [`backend/README.md`](backend/README.md) — تشغيل Laravel وFilament
- [`FLUTTER_LARAVEL_ONLY.md`](FLUTTER_LARAVEL_ONLY.md) — المعمارية
- [`BACKEND_FIELDS.md`](BACKEND_FIELDS.md) — حقول API
- [`INTEGRATION_AUTH.md`](INTEGRATION_AUTH.md) — المصادقة
