# Mobile App Status

Flutter **موبايل فقط** (iOS / Android). لوحة الأدمن على Laravel Filament في `../backend`.

## مكتمل

- مصادقة Laravel Sanctum (`AuthService` + Bearer) مع تحقق بريد و2FA وإعادة كلمة المرور
- عقارات / عقود / مستأجرين / مدفوعات / إشعارات عبر API
- صيانة / تقويم / مشاريع / تقارير / طلبات الجوال / رفع ملفات
- لوحة التحكم وتحليل السوق عبر `GET /analytics/overview`
- تحليل المستأجر والصور مرتبطان بالـ API (رفع + image-analysis + mobile requests + analytics)
- إشعارات بريد للتحقق وإعادة كلمة المرور (`MAIL_MAILER=log` محلياً / SMTP للإنتاج)
- محادثات مع إرسال رسائل
- خلفية موحّدة: `AmbientBackground` + `AppScaffold`
- ربط محلي: `API_BASE_URL=http://127.0.0.1:8000/api/v1`

## تشغيل

```bash
# Terminal 1 — Laravel
cd ../backend && php artisan serve

# Terminal 2 — Flutter
cp .env.example .env
flutter pub get
flutter run
```

حسابات: `demo@demo.com` / `admin@demo.com` — `password`

## Android emulator

استخدم `http://10.0.2.2:8000/api/v1` بدل `127.0.0.1` في `.env`.
