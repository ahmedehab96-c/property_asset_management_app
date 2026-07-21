# الحقول الموحدة بين الباكند والويب والموبايل

هذا الملف مرجع واحد لحقول الطلبات والاستجابات حسب **API_DOCUMENTATION.md** واتفاقية **Laravel (snake_case)**.

---

## المصادقة (Auth)

| الإرسال (للباكند) | الوصف |
|-------------------|--------|
| `name` | الاسم الكامل |
| `email` | البريد |
| `password` | كلمة المرور |
| `password_confirmation` | تأكيد كلمة المرور |
| `phone` أو `mobile` | اختياري |
| `locale` | `ar` أو `en` |
| `language` | `ar` أو `en` |

الهيدر: `Accept-Language: ar` أو `en`.

---

## العقارات (Properties)

**الاستجابة:** يدعم الويب/الموبايل كلاً من `name`/`title`, `location`/`address`, `monthlyRevenue`/`monthly_revenue`, `tenantName`/`tenant_name`.

**الإرسال (إنشاء/تحديث):** `name`, `type`, `location`, `address`, `status`, `area`, `monthly_revenue`, `owner_id`, `description`.

---

## المستأجرون (Tenants)

**الاستجابة:** `name`/`full_name`, `phone`/`mobile`, `property_name`/`property`, `rent_amount`/`rentAmount`, `contract_end`/`contractEnd`, `payment_status`/`paymentStatus`.

**الإرسال:** `name`, `email`, `phone`, `mobile`, `property_id`, `status`, `rent_amount`, `address`.

---

## العقود (Contracts)

**الاستجابة:** `contract_number`/`contractNumber`, `property_name`/`property`, `tenant_name`/`tenant`, `owner_name`/`owner`, `start_date`, `end_date`, `monthly_rent`/`monthlyRent`, `deposit`, `status`.

**الإرسال:** `property_id`, `tenant_id`, `owner_id`, `start_date`, `end_date`, `monthly_rent`, `deposit`, `status`.

---

## الملاك (Owners)

**الاستجابة:** `name`/`full_name`, `phone`/`mobile`, `properties_count`/`propertiesCount`, `total_revenue`/`totalRevenue`, `balance`/`wallet_balance`, `join_date`/`join_date`, `created_at`.

**الإرسال:** `name`, `full_name`, `email`, `phone`, `address`.

---

## المدفوعات والتحويلات (Payments / Transfers)

**Payment:** `tenant_name`/`tenant_name`, `property_name`/`property`, `due_date`, `amount`, `status`, `payment_date`.

**Transfer:** `owner_name`/`owner_name`, `request_date`, `amount`, `bank_account`, `status`.

---

## المستخدمون (Users)

**الاستجابة:** `name`/`full_name`, `role`/`role_name`, `role_type`/`roleType`, `is_admin`/`isAdmin`, `created_at`/`created_date`.

---

## الإشعارات (Notifications)

**الاستجابة:** `message`/`body`/`title`, `type`, `created_at`/`time`, `read_at`/`unread`.

---

Flutter يستخدم **`mobile_app/lib/utils/api_response_mappers.dart`** و**`mobile_app/lib/utils/owner_api_mappers.dart`** لقراءة الاستجابات (snake_case و camelCase) ولتحويل البيانات المرسلة للباكند عند الحاجة.

لوحة الأدمن على الويب: **Laravel Filament** في `backend/` (`/admin`) — ليس Flutter Web.
