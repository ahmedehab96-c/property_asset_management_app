# Property Asset Management

منصة إدارة عقارات: **Flutter** (تطبيق موبايل) + **Laravel** (API + لوحة أدمن Filament).

## البنية

| المكون | المسار | الوصف |
|--------|--------|--------|
| **الموبايل** | [`mobile_app/`](mobile_app/) | Flutter — iOS / Android (مالك/مستأجر) |
| **الويب + API** | [`backend/`](backend/) | Laravel 13 + Sanctum + Filament 4 |
| **لوحة الأدمن (React)** | [`admin-dashboard/`](admin-dashboard/) | React + Vite — تتقدم كجزء من Laravel على `/dashboard` |

> لوحة الأدمن الأصلية (Filament) لسه شغالة على `/admin`. لوحة الـ React الجديدة على `/dashboard` بتغطي نفس الأقسام وبتكلم نفس الـ API.

## جرّبه مباشرة (Try it live)

### 🖥️ لوحة الأدمن (الويب)
1. افتح الرابط: https://property-asset-mgmt-api.onrender.com/dashboard/
2. سجّل الدخول بحساب الأدمن التجريبي — البريد: `admin@demo.com` — كلمة المرور: `password`
3. ملاحظة: أول طلب بعد فترة خمول قد يأخذ 30-60 ثانية (استضافة مجانية).

### 📱 تطبيق الموبايل
1. شغّله محلياً (قسم [البدء السريع](#2-تطبيق-الموبايل-flutter) تحت) — لا يوجد APK جاهز للتحميل حالياً.
2. بشاشة الدخول اضغط زر "تعبئة بيانات تجريبية" (Fill demo)، أو أدخل يدوياً — البريد: `demo@demo.com` — كلمة المرور: `password` (حساب مالك/مستأجر).

> نفس حسابات التجربة (`admin@demo.com` و`demo@demo.com`، كلمة المرور `password` للاثنين) مُجهّزة تلقائياً عبر الـ seeder — تقدر تعيد توليدها محلياً بـ `php artisan db:seed`.

---

### 🖥️ Admin dashboard (web)
1. Open: https://property-asset-mgmt-api.onrender.com/dashboard/
2. Log in with the demo admin account — email: `admin@demo.com` — password: `password`
3. Note: the first request after idle may take 30-60s to wake up (free-tier hosting).

### 📱 Mobile app
1. Run it locally (see [Quick start](#2-تطبيق-الموبايل-flutter) below) — no pre-built APK is published yet.
2. On the login screen tap "Fill demo", or enter manually — email: `demo@demo.com` — password: `password` (owner/tenant account).

> Both demo accounts (`admin@demo.com` and `demo@demo.com`, password `password` for both) are seeded automatically — regenerate them locally with `php artisan db:seed`.

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

### 3) لوحة الأدمن (React) — تطوير محلي

```bash
cd admin-dashboard
npm install
cp .env.example .env   # VITE_API_URL=http://127.0.0.1:8000
npm run dev
```

للنشر، `npm run build` بيطلع مباشرة في `backend/public/dashboard` وبيتقدم من نفس سيرفر Laravel على `/dashboard` — تفاصيل في [`admin-dashboard/README.md`](admin-dashboard/README.md).

## Docker

صورة واحدة بتبني React أولاً ثم تشغّل Laravel (API + `/admin` Filament + `/dashboard` React) على Apache:

```bash
docker compose up --build
```

- التطبيق: http://localhost:8080 (يعيد التوجيه لـ `/admin`)
- لوحة الـ React: http://localhost:8080/dashboard
- بيانات SQLite وملفات الـ storage محفوظة في named volumes (`sqlite-db`, `storage`) — أول تشغيل بينسخ قاعدة البيانات التجريبية الموجودة في الريبو تلقائيًا، وبعدين يشغّل الميجريشنز الناقصة (`RUN_MIGRATIONS=true` في [`docker-compose.yml`](docker-compose.yml)).
- عايز تغيّر إعدادات الإنتاج (قاعدة بيانات حقيقية، `APP_KEY`، مفاتيح Gemini...) عدّل قسم `environment:` في `docker-compose.yml` أو مرّرها كمتغيرات بيئة بدلاً منه.

> **ملاحظة**: الصورة اتبنت ومراجعتها يدويًا لكن ما اتعملهاش build/run فعلي في هذه البيئة (مفيش Docker متاح هنا) — لو واجهت أي مشكلة في `docker compose up --build` قولّي التفاصيل.

## الوثائق

- [`backend/README.md`](backend/README.md) — تشغيل Laravel وFilament
- [`FLUTTER_LARAVEL_ONLY.md`](FLUTTER_LARAVEL_ONLY.md) — المعمارية
- [`BACKEND_FIELDS.md`](BACKEND_FIELDS.md) — حقول API
- [`INTEGRATION_AUTH.md`](INTEGRATION_AUTH.md) — المصادقة
