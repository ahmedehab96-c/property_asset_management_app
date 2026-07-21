# 🔗 دليل الربط مع Laravel / Laravel Integration Guide

## 📋 نظرة عامة / Overview

هذا الدليل يوضح كيفية ربط التطبيق المحمول (Flutter) والتطبيق الويب (React) مع Laravel Backend API.

This guide explains how to connect the Mobile App (Flutter) and Web App (React) with Laravel Backend API.

---

## ✅ ما تم إعداده / What Has Been Prepared

### 📱 التطبيق المحمول / Mobile App

#### ✅ الملفات المُنشأة / Created Files:
1. **`lib/config/api_config.dart`** - إعدادات API وجميع الـ endpoints
2. **`lib/services/api_service.dart`** - خدمة API الرئيسية مع معالجة الأخطاء والتحديث التلقائي للتوكن
3. **`lib/services/auth_service.dart`** - خدمة المصادقة
4. **`lib/models/api_response.dart`** - نموذج استجابة API القياسي
5. **`.env.example`** - مثال لملف البيئة

#### ✅ الحزم المضافة / Added Packages:
- `http: ^1.1.0` - للطلبات HTTP
- `dio: ^5.4.0` - مكتبة HTTP متقدمة
- `flutter_dotenv: ^5.1.0` - لإدارة متغيرات البيئة

### 🌐 التطبيق الويب / Web App

#### ✅ الملفات المُنشأة / Created Files:
1. **`src/services/api.js`** - خدمة API الرئيسية مع axios
2. **`src/services/authService.js`** - خدمة المصادقة
3. **`.env.example`** - مثال لملف البيئة

#### ✅ الحزم المضافة / Added Packages:
- `axios: ^1.6.0` - للطلبات HTTP

---

## 🚀 خطوات الإعداد / Setup Steps

### 1️⃣ إعداد التطبيق المحمول / Mobile App Setup

#### الخطوة 1: تثبيت الحزم / Install Packages
```bash
cd mobile_app
flutter pub get
```

#### الخطوة 2: إعداد ملف البيئة / Setup Environment File
```bash
# انسخ ملف المثال
cp .env.example .env

# عدّل ملف .env وأضف رابط Laravel API الخاص بك
# API_BASE_URL=http://your-laravel-api-url/api
```

#### الخطوة 3: إضافة ملف .env إلى gitignore
تأكد من أن ملف `.env` موجود في `.gitignore`:
```
.env
```

### 2️⃣ إعداد التطبيق الويب / Web App Setup

#### الخطوة 1: تثبيت الحزم / Install Packages
```bash
cd web_app
npm install
```

#### الخطوة 2: إعداد ملف البيئة / Setup Environment File
```bash
# انسخ ملف المثال
cp .env.example .env

# عدّل ملف .env وأضف رابط Laravel API الخاص بك
# REACT_APP_API_BASE_URL=http://your-laravel-api-url/api
```

---

## 📡 تنسيق استجابة API / API Response Format

### ✅ التنسيق القياسي / Standard Format

جميع استجابات Laravel API يجب أن تتبع هذا التنسيق:

All Laravel API responses should follow this format:

```json
{
  "success": true,
  "message": "Operation successful",
  "data": {
    // Response data here
  },
  "errors": null
}
```

### ❌ تنسيق الخطأ / Error Format

```json
{
  "success": false,
  "message": "Error message",
  "data": null,
  "errors": {
    "field": ["Error message"]
  }
}
```

---

## 🔐 المصادقة / Authentication

### 📱 التطبيق المحمول / Mobile App

#### استخدام خدمة المصادقة / Using Auth Service:

```dart
import 'package:property_asset_management_app/services/auth_service.dart';

final authService = AuthService();

// تسجيل الدخول / Login
final response = await authService.login(
  email: 'user@example.com',
  password: 'password123',
);

if (response.success) {
  // تم تسجيل الدخول بنجاح
  // Login successful
} else {
  // خطأ في تسجيل الدخول
  // Login failed
  print(response.message);
}
```

#### استخدام خدمة API العامة / Using General API Service:

```dart
import 'package:property_asset_management_app/services/api_service.dart';
import 'package:property_asset_management_app/config/api_config.dart';

final apiService = ApiService();

// GET request
final response = await apiService.get(ApiConfig.properties);

// POST request
final response = await apiService.post(
  ApiConfig.properties,
  data: {
    'name': 'Property Name',
    'address': 'Property Address',
  },
);

// Upload file
final response = await apiService.uploadFile(
  ApiConfig.uploadImage,
  '/path/to/image.jpg',
  fieldName: 'image',
);
```

### 🌐 التطبيق الويب / Web App

#### استخدام خدمة المصادقة / Using Auth Service:

```javascript
import { login, logout, getCurrentUser } from './services/authService';

// تسجيل الدخول / Login
const response = await login('user@example.com', 'password123');

if (response.success) {
  // تم تسجيل الدخول بنجاح
  // Login successful
} else {
  // خطأ في تسجيل الدخول
  // Login failed
  console.error(response.message);
}
```

#### استخدام خدمة API العامة / Using General API Service:

```javascript
import { get, post, uploadFile } from './services/api';
import { API_ENDPOINTS } from './config/apiEndpoints';

// GET request
const response = await get('/properties');

// POST request
const response = await post('/properties', {
  name: 'Property Name',
  address: 'Property Address',
});

// Upload file
const response = await uploadFile('/upload/image', file);
```

---

## 📋 قائمة API Endpoints / API Endpoints List

### 🔐 Authentication / المصادقة
- `POST /api/auth/login` - تسجيل الدخول
- `POST /api/auth/logout` - تسجيل الخروج
- `POST /api/auth/register` - التسجيل
- `POST /api/auth/refresh` - تحديث التوكن
- `GET /api/auth/user` - بيانات المستخدم الحالي
- `POST /api/auth/forgot-password` - نسيت كلمة المرور
- `POST /api/auth/reset-password` - إعادة تعيين كلمة المرور
- `POST /api/auth/verify-email` - التحقق من البريد الإلكتروني

### 🏢 Properties / العقارات
- `GET /api/properties` - الحصول على جميع العقارات
- `GET /api/properties/{id}` - الحصول على عقار محدد
- `POST /api/properties` - إضافة عقار جديد
- `PUT /api/properties/{id}` - تحديث عقار
- `DELETE /api/properties/{id}` - حذف عقار
- `GET /api/properties/{id}/stats` - إحصائيات العقار
- `GET /api/properties/{id}/financial` - البيانات المالية للعقار
- `GET /api/properties/search` - البحث في العقارات
- `GET /api/properties/filter` - تصفية العقارات

### 👥 Tenants / المستأجرين
- `GET /api/tenants` - الحصول على جميع المستأجرين
- `GET /api/tenants/{id}` - الحصول على مستأجر محدد
- `POST /api/tenants` - إضافة مستأجر جديد
- `PUT /api/tenants/{id}` - تحديث مستأجر
- `DELETE /api/tenants/{id}` - حذف مستأجر
- `GET /api/tenants/{id}/payments` - مدفوعات المستأجر
- `GET /api/tenants/{id}/contracts` - عقود المستأجر
- `GET /api/tenants/{id}/history` - سجل المستأجر

### 📄 Contracts / العقود
- `GET /api/contracts` - الحصول على جميع العقود
- `GET /api/contracts/{id}` - الحصول على عقد محدد
- `POST /api/contracts` - إضافة عقد جديد
- `PUT /api/contracts/{id}` - تحديث عقد
- `DELETE /api/contracts/{id}` - حذف عقد
- `GET /api/contracts/expiring` - العقود المنتهية
- `POST /api/contracts/{id}/renew` - تجديد عقد
- `GET /api/contracts/{id}/payments` - مدفوعات العقد
- `POST /api/contracts/{id}/extend` - تمديد عقد
- `POST /api/contracts/{id}/cancel` - إلغاء عقد

### 💰 Payments / المدفوعات
- `GET /api/payments` - الحصول على جميع المدفوعات
- `GET /api/payments/{id}` - الحصول على دفعة محددة
- `POST /api/payments` - إضافة دفعة جديدة
- `PUT /api/payments/{id}` - تحديث دفعة
- `DELETE /api/payments/{id}` - حذف دفعة
- `GET /api/payments/upcoming` - المدفوعات القادمة
- `GET /api/payments/overdue` - المدفوعات المتأخرة
- `GET /api/payments/statistics` - إحصائيات المدفوعات

### 📊 Reports / التقارير
- `GET /api/reports` - الحصول على جميع التقارير
- `GET /api/reports/{id}` - الحصول على تقرير محدد
- `POST /api/reports` - إنشاء تقرير جديد
- `GET /api/reports/financial` - التقارير المالية
- `GET /api/reports/tenant` - تقارير المستأجرين
- `GET /api/reports/property` - تقارير العقارات
- `GET /api/reports/contract` - تقارير العقود

### 🛠️ Services / الخدمات
- `GET /api/services` - الحصول على جميع الخدمات
- `GET /api/services/{id}` - الحصول على خدمة محددة
- `POST /api/services` - إنشاء طلب خدمة جديد
- `PUT /api/services/{id}` - تحديث خدمة
- `DELETE /api/services/{id}` - حذف خدمة
- `GET /api/services/maintenance` - طلبات الصيانة
- `GET /api/services/repair` - طلبات الإصلاح
- `GET /api/services/legal` - الاستشارات القانونية
- `GET /api/services/engineering` - الاستشارات الهندسية
- `POST /api/services/{id}/status` - تحديث حالة الخدمة

### 👤 Users / المستخدمين
- `GET /api/users` - الحصول على جميع المستخدمين
- `GET /api/users/{id}` - الحصول على مستخدم محدد
- `POST /api/users` - إضافة مستخدم جديد
- `PUT /api/users/{id}` - تحديث مستخدم
- `DELETE /api/users/{id}` - حذف مستخدم
- `GET /api/users/registration-requests` - طلبات التسجيل
- `POST /api/users/{id}/approve` - الموافقة على التسجيل
- `POST /api/users/{id}/reject` - رفض التسجيل
- `GET /api/users/{id}/profile` - ملف المستخدم
- `PUT /api/users/{id}/profile` - تحديث ملف المستخدم

### 📁 File Upload / رفع الملفات
- `POST /api/upload/image` - رفع صورة
- `POST /api/upload/document` - رفع مستند
- `POST /api/upload/multiple` - رفع ملفات متعددة
- `DELETE /api/upload/{id}` - حذف ملف مرفوع

### 🔔 Notifications / الإشعارات
- `GET /api/notifications` - الحصول على جميع الإشعارات
- `GET /api/notifications/unread` - الإشعارات غير المقروءة
- `POST /api/notifications/{id}/read` - تحديد إشعار كمقروء
- `POST /api/notifications/read-all` - تحديد الكل كمقروء
- `DELETE /api/notifications/{id}` - حذف إشعار

---

## 🔒 متطلبات الأمان / Security Requirements

### Laravel Backend يجب أن يدعم / Laravel Backend Must Support:

1. **CORS** - يجب تكوين CORS للسماح للتطبيق المحمول والويب
   - Configure CORS to allow mobile and web apps

2. **Rate Limiting** - تحديد معدل الطلبات
   - Implement rate limiting for API endpoints

3. **Token Authentication** - استخدام Laravel Sanctum
   - Use Laravel Sanctum for token-based authentication

4. **Input Validation** - التحقق من جميع المدخلات
   - Validate all inputs

5. **File Upload Security** - التحقق من نوع وحجم الملفات
   - Validate file types and sizes

---

## 📝 ملاحظات مهمة / Important Notes

### ✅ ما تم إعداده / What's Ready:
- ✅ جميع خدمات API جاهزة
- ✅ معالجة الأخطاء والتحديث التلقائي للتوكن
- ✅ دعم رفع الملفات
- ✅ جميع الـ endpoints محددة في `api_config.dart`
- ✅ ملفات البيئة جاهزة

### ⚠️ ما يجب على مبرمج Laravel فعله / What Laravel Developer Should Do:

1. **إنشاء Laravel API Project**
   ```bash
   composer create-project laravel/laravel property-api
   ```

2. **تثبيت Laravel Sanctum**
   ```bash
   composer require laravel/sanctum
   php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"
   php artisan migrate
   ```

3. **إعداد CORS**
   - تعديل `config/cors.php` للسماح للتطبيقين

4. **إنشاء Controllers و Routes**
   - إنشاء جميع الـ controllers المطلوبة
   - إضافة جميع الـ routes في `routes/api.php`

5. **إعداد قاعدة البيانات**
   - إنشاء migrations للجداول المطلوبة

6. **تطبيق تنسيق الاستجابة القياسي**
   - جميع الاستجابات يجب أن تتبع التنسيق المحدد أعلاه

---

## 🧪 الاختبار / Testing

### اختبار التطبيق المحمول / Test Mobile App:

```dart
// مثال على اختبار تسجيل الدخول
final authService = AuthService();
final response = await authService.login(
  email: 'test@example.com',
  password: 'password123',
);
print('Success: ${response.success}');
print('Message: ${response.message}');
```

### اختبار التطبيق الويب / Test Web App:

```javascript
// مثال على اختبار تسجيل الدخول
import { login } from './services/authService';

const response = await login('test@example.com', 'password123');
console.log('Success:', response.success);
console.log('Message:', response.message);
```

---

## 📞 الدعم / Support

إذا واجهت أي مشاكل في الربط، تأكد من:

If you encounter any issues, make sure:

1. ✅ ملف `.env` موجود ومُعد بشكل صحيح
2. ✅ Laravel API يعمل على الرابط المحدد
3. ✅ CORS مُعد بشكل صحيح في Laravel
4. ✅ جميع الـ endpoints تعمل بشكل صحيح

---

## 🎯 الخلاصة / Summary

التطبيق المحمول والويب جاهزان تماماً للربط مع Laravel. كل ما تحتاجه هو:

The mobile and web apps are fully ready for Laravel integration. All you need is:

1. ✅ تحديث ملف `.env` برابط Laravel API
2. ✅ إنشاء Laravel Backend API
3. ✅ تطبيق جميع الـ endpoints المطلوبة
4. ✅ اختبار الربط

**جاهز للربط! / Ready for Integration!** 🚀
