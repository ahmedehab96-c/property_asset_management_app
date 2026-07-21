# تجربة التسجيل وتسجيل الدخول — Flutter موبايل مع Laravel

## الهدف
تطبيق الهاتف جاهز للتجربة مع باكند Laravel المحلي للمصادقة ثم باقي الـ API.

## 1) الباكند

```bash
cd backend
php artisan migrate:fresh --seed
php artisan serve
```

Base URL: `http://127.0.0.1:8000/api/v1`

## 2) تطبيق الهاتف

في `mobile_app/.env`:
```env
API_BASE_URL=http://127.0.0.1:8000/api/v1
```

```bash
cd mobile_app
flutter pub get
flutter run
```

## 3) نقاط المصادقة

| الطريقة | المسار | الوصف |
|--------|--------|--------|
| POST | `/api/v1/auth/login` | `{ "email", "password" }` |
| POST | `/api/v1/auth/register` | `{ "name", "email", "password", "password_confirmation", "phone?" }` |
| GET  | `/api/v1/auth/user` | Bearer token |
| POST | `/api/v1/auth/logout` | تسجيل الخروج |

**الاستجابة:**
```json
{
  "success": true,
  "message": "...",
  "data": {
    "token": "xxx",
    "user": { "id", "name", "email", "role", "is_admin" }
  }
}
```

## 4) لوحة الأدمن (ويب)

http://127.0.0.1:8000/admin — Filament (ليس Flutter Web)

| الحساب | كلمة المرور |
|--------|-------------|
| admin@demo.com | password |
| demo@demo.com | password |
