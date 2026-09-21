<?php

namespace Database\Seeders;

use App\Models\AppNotification;
use App\Models\CalendarEvent;
use App\Models\Contract;
use App\Models\Conversation;
use App\Models\MaintenanceRequest;
use App\Models\Message;
use App\Models\Owner;
use App\Models\Payment;
use App\Models\Project;
use App\Models\Property;
use App\Models\Report;
use App\Models\Task;
use App\Models\Tenant;
use App\Models\User;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $admin = User::query()->updateOrCreate(
            ['email' => 'admin@demo.com'],
            [
                'name' => 'Admin User',
                'password' => 'password',
                'phone' => '+971500000001',
                'role' => 'admin',
                'is_admin' => true,
                'locale' => 'ar',
                'status' => 'active',
                'email_verified_at' => now(),
            ]
        );

        // --- Owners -------------------------------------------------------

        $ownerUser = User::query()->updateOrCreate(
            ['email' => 'demo@demo.com'],
            [
                'name' => 'Demo Owner',
                'password' => 'password',
                'phone' => '+971500000002',
                'role' => 'owner',
                'is_admin' => false,
                'locale' => 'ar',
                'status' => 'active',
                'email_verified_at' => now(),
            ]
        );

        $owner = Owner::query()->updateOrCreate(
            ['email' => 'demo@demo.com'],
            [
                'user_id' => $ownerUser->id,
                'name' => 'Khalid Al Mansoori',
                'name_ar' => 'خالد المنصوري',
                'phone' => '+971500000002',
                'address' => 'Dubai Marina',
                'address_ar' => 'دبي مارينا',
                'wallet_balance' => 12500,
                'join_date' => now()->subYear()->toDateString(),
            ]
        );

        $ownerTwo = Owner::query()->updateOrCreate(
            ['email' => 'sara.owner@demo.com'],
            [
                'name' => 'Sara Al Farsi',
                'name_ar' => 'سارة الفارسي',
                'phone' => '+971500000010',
                'address' => 'Downtown Dubai',
                'address_ar' => 'وسط مدينة دبي',
                'wallet_balance' => 8300,
                'join_date' => now()->subMonths(6)->toDateString(),
            ]
        );

        // --- Properties -----------------------------------------------------

        $property = Property::query()->updateOrCreate(
            ['name' => 'Marina View Apartment', 'owner_id' => $owner->id],
            [
                'name_ar' => 'شقة مطلة على المارينا',
                'type' => 'apartment',
                'location' => 'Dubai Marina',
                'location_ar' => 'دبي مارينا',
                'address' => 'Marina Walk, Tower 3',
                'address_ar' => 'ممشى المارينا، برج 3',
                'status' => 'occupied',
                'area' => 120,
                'monthly_revenue' => 8500,
                'description' => 'Sea-view 2BR apartment managed by the platform.',
                'description_ar' => 'شقة غرفتي نوم بإطلالة بحرية تُدار عبر المنصة.',
                'latitude' => 25.0805,
                'longitude' => 55.1403,
            ]
        );

        $officeProperty = Property::query()->updateOrCreate(
            ['name' => 'Business Bay Office', 'owner_id' => $owner->id],
            [
                'name_ar' => 'مكتب الخليج التجاري',
                'type' => 'office',
                'location' => 'Business Bay',
                'location_ar' => 'الخليج التجاري',
                'address' => 'Bay Square Building 5',
                'address_ar' => 'مبنى باي سكوير 5',
                'status' => 'available',
                'area' => 90,
                'monthly_revenue' => 12000,
                'description' => 'Ready office unit with parking.',
                'description_ar' => 'وحدة مكتبية جاهزة مع موقف سيارات.',
                'latitude' => 25.1850,
                'longitude' => 55.2720,
            ]
        );

        $palmProperty = Property::query()->updateOrCreate(
            ['name' => 'Palm Residences Phase 2', 'owner_id' => $owner->id],
            [
                'name_ar' => 'مساكن النخلة - المرحلة الثانية',
                'type' => 'project',
                'location' => 'Palm Jumeirah',
                'location_ar' => 'نخلة جميرا',
                'address' => 'Palm Crescent',
                'address_ar' => 'بلوك النخلة',
                'status' => 'under_construction',
                'area' => 2400,
                'monthly_revenue' => 0,
                'description' => 'Residential project under construction.',
                'description_ar' => 'مشروع سكني قيد الإنشاء.',
                'latitude' => 25.1124,
                'longitude' => 55.1390,
            ]
        );

        $villaProperty = Property::query()->updateOrCreate(
            ['name' => 'Emirates Hills Villa', 'owner_id' => $ownerTwo->id],
            [
                'name_ar' => 'فيلا مروج الإمارات',
                'type' => 'villa',
                'location' => 'Emirates Hills',
                'location_ar' => 'مروج الإمارات',
                'address' => 'Street 4, Villa 12',
                'address_ar' => 'شارع 4، فيلا 12',
                'status' => 'occupied',
                'area' => 650,
                'monthly_revenue' => 22000,
                'description' => '5BR villa with private garden and pool.',
                'description_ar' => 'فيلا 5 غرف نوم مع حديقة خاصة ومسبح.',
                'latitude' => 25.0657,
                'longitude' => 55.1713,
            ]
        );

        $studioProperty = Property::query()->updateOrCreate(
            ['name' => 'JLT Studio', 'owner_id' => $ownerTwo->id],
            [
                'name_ar' => 'استوديو أبراج بحيرة الجميرا',
                'type' => 'apartment',
                'location' => 'Jumeirah Lake Towers',
                'location_ar' => 'أبراج بحيرة الجميرا',
                'address' => 'Cluster P, Tower 1',
                'address_ar' => 'مجمع P، برج 1',
                'status' => 'available',
                'area' => 45,
                'monthly_revenue' => 3800,
                'description' => 'Compact studio near the metro.',
                'description_ar' => 'استوديو مدمج بالقرب من المترو.',
                'latitude' => 25.0693,
                'longitude' => 55.1417,
            ]
        );

        // --- Tenants ----------------------------------------------------------

        $tenant = Tenant::query()->updateOrCreate(
            ['email' => 'tenant@demo.com'],
            [
                'property_id' => $property->id,
                'name' => 'Ahmed Al Zaabi',
                'name_ar' => 'أحمد الزعابي',
                'phone' => '+971500000003',
                'address' => 'Dubai Marina',
                'address_ar' => 'دبي مارينا',
                'status' => 'active',
                'rent_amount' => 8500,
            ]
        );

        $tenantTwo = Tenant::query()->updateOrCreate(
            ['email' => 'layla.tenant@demo.com'],
            [
                'property_id' => $villaProperty->id,
                'name' => 'Layla Hassan',
                'name_ar' => 'ليلى حسن',
                'phone' => '+971500000004',
                'address' => 'Emirates Hills',
                'address_ar' => 'مروج الإمارات',
                'status' => 'active',
                'rent_amount' => 22000,
            ]
        );

        $tenantThree = Tenant::query()->updateOrCreate(
            ['email' => 'omar.tenant@demo.com'],
            [
                'property_id' => $studioProperty->id,
                'name' => 'Omar Suleiman',
                'name_ar' => 'عمر سليمان',
                'phone' => '+971500000005',
                'address' => 'Jumeirah Lake Towers',
                'address_ar' => 'أبراج بحيرة الجميرا',
                'status' => 'pending',
                'rent_amount' => 3800,
            ]
        );

        // --- Contracts ----------------------------------------------------------

        $contract = Contract::query()->updateOrCreate(
            ['contract_number' => 'CNT-DEMO-001'],
            [
                'property_id' => $property->id,
                'tenant_id' => $tenant->id,
                'owner_id' => $owner->id,
                'start_date' => now()->subMonths(3)->toDateString(),
                'end_date' => now()->addMonths(9)->toDateString(),
                'monthly_rent' => 8500,
                'deposit' => 17000,
                'status' => 'active',
            ]
        );

        $contractTwo = Contract::query()->updateOrCreate(
            ['contract_number' => 'CNT-DEMO-002'],
            [
                'property_id' => $villaProperty->id,
                'tenant_id' => $tenantTwo->id,
                'owner_id' => $ownerTwo->id,
                'start_date' => now()->subMonths(1)->toDateString(),
                'end_date' => now()->addMonths(11)->toDateString(),
                'monthly_rent' => 22000,
                'deposit' => 44000,
                'status' => 'active',
            ]
        );

        // --- Payments ----------------------------------------------------------

        Payment::query()->updateOrCreate(
            [
                'tenant_id' => $tenant->id,
                'contract_id' => $contract->id,
                'status' => 'paid',
            ],
            [
                'property_id' => $property->id,
                'amount' => 8500,
                'due_date' => now()->startOfMonth()->toDateString(),
                'payment_date' => now()->subDays(2)->toDateString(),
                'method' => 'bank_transfer',
            ]
        );

        Payment::query()->updateOrCreate(
            [
                'tenant_id' => $tenant->id,
                'contract_id' => $contract->id,
                'status' => 'pending',
            ],
            [
                'property_id' => $property->id,
                'amount' => 8500,
                'due_date' => now()->addMonth()->startOfMonth()->toDateString(),
                'method' => 'bank_transfer',
            ]
        );

        Payment::query()->updateOrCreate(
            [
                'tenant_id' => $tenantTwo->id,
                'contract_id' => $contractTwo->id,
                'status' => 'paid',
            ],
            [
                'property_id' => $villaProperty->id,
                'amount' => 22000,
                'due_date' => now()->startOfMonth()->toDateString(),
                'payment_date' => now()->subDays(5)->toDateString(),
                'method' => 'cheque',
            ]
        );

        Payment::query()->updateOrCreate(
            [
                'tenant_id' => $tenantTwo->id,
                'contract_id' => $contractTwo->id,
                'status' => 'pending',
            ],
            [
                'property_id' => $villaProperty->id,
                'amount' => 22000,
                'due_date' => now()->addMonth()->startOfMonth()->toDateString(),
                'method' => 'cheque',
            ]
        );

        // --- Notifications ----------------------------------------------------------

        AppNotification::query()->updateOrCreate(
            [
                'user_id' => $admin->id,
                'title' => 'Welcome to Property Admin',
            ],
            [
                'title_ar' => 'مرحبًا بك في إدارة الممتلكات',
                'message' => 'Laravel admin and API are ready.',
                'message_ar' => 'لوحة الإدارة وواجهة البرمجة جاهزتان للاستخدام.',
                'type' => 'info',
            ]
        );

        AppNotification::query()->updateOrCreate(
            [
                'user_id' => $ownerUser->id,
                'title' => 'Rent received',
            ],
            [
                'title_ar' => 'تم استلام الإيجار',
                'message' => 'Payment for Marina View Apartment was marked as paid.',
                'message_ar' => 'تم تسجيل دفعة شقة مطلة على المارينا كمدفوعة.',
                'type' => 'payment',
            ]
        );

        AppNotification::query()->updateOrCreate(
            [
                'user_id' => $admin->id,
                'title' => 'New maintenance request',
            ],
            [
                'title_ar' => 'طلب صيانة جديد',
                'message' => 'A new AC repair request was submitted for Marina View Apartment.',
                'message_ar' => 'تم تقديم طلب صيانة مكيّف جديد لشقة مطلة على المارينا.',
                'type' => 'maintenance',
            ]
        );

        // --- Projects ----------------------------------------------------------

        Project::query()->updateOrCreate(
            ['name' => 'Palm Residences Phase 2', 'owner_id' => $owner->id],
            [
                'name_ar' => 'مساكن النخلة - المرحلة الثانية',
                'property_id' => $palmProperty->id,
                'location' => 'Palm Jumeirah',
                'location_ar' => 'نخلة جميرا',
                'status' => 'under_construction',
                'progress' => 62,
                'budget' => 2500000,
                'paid_amount' => 1550000,
                'start_date' => now()->subMonths(8)->toDateString(),
                'end_date' => now()->addMonths(6)->toDateString(),
                'description' => 'Residential tower project.',
                'description_ar' => 'مشروع برج سكني.',
            ]
        );

        Project::query()->updateOrCreate(
            ['name' => 'JLT Studio Renovation', 'owner_id' => $ownerTwo->id],
            [
                'name_ar' => 'تجديد استوديو أبراج بحيرة الجميرا',
                'property_id' => $studioProperty->id,
                'location' => 'Jumeirah Lake Towers',
                'location_ar' => 'أبراج بحيرة الجميرا',
                'status' => 'under_construction',
                'progress' => 10,
                'budget' => 45000,
                'paid_amount' => 5000,
                'start_date' => now()->addDays(10)->toDateString(),
                'end_date' => now()->addMonths(2)->toDateString(),
                'description' => 'Full interior renovation before re-listing.',
                'description_ar' => 'تجديد داخلي كامل قبل إعادة الطرح للإيجار.',
            ]
        );

        // --- Maintenance requests ----------------------------------------------------------

        MaintenanceRequest::query()->updateOrCreate(
            ['order_number' => 'MR-12045'],
            [
                'property_id' => $property->id,
                'tenant_id' => $tenant->id,
                'owner_id' => $owner->id,
                'title' => 'AC Repair',
                'title_ar' => 'إصلاح المكيف',
                'problem_type' => 'AC Repair',
                'problem_type_ar' => 'إصلاح المكيف',
                'description' => 'Unit not cooling properly.',
                'description_ar' => 'الوحدة لا تبرّد بشكل جيد.',
                'status' => 'in_progress',
                'priority' => 'high',
            ]
        );

        MaintenanceRequest::query()->updateOrCreate(
            ['order_number' => 'MR-11987'],
            [
                'property_id' => $property->id,
                'tenant_id' => $tenant->id,
                'owner_id' => $owner->id,
                'title' => 'Kitchen Sink Leak',
                'title_ar' => 'تسريب حوض المطبخ',
                'problem_type' => 'Plumbing',
                'problem_type_ar' => 'سباكة',
                'description' => 'Water leaking under the kitchen sink.',
                'description_ar' => 'تسريب مياه أسفل حوض المطبخ.',
                'status' => 'completed',
                'priority' => 'medium',
            ]
        );

        MaintenanceRequest::query()->updateOrCreate(
            ['order_number' => 'MR-12110'],
            [
                'property_id' => $villaProperty->id,
                'tenant_id' => $tenantTwo->id,
                'owner_id' => $ownerTwo->id,
                'title' => 'Pool Pump Not Working',
                'title_ar' => 'مضخة المسبح لا تعمل',
                'problem_type' => 'Pool Maintenance',
                'problem_type_ar' => 'صيانة المسبح',
                'description' => 'Pool pump makes noise and stops after a few minutes.',
                'description_ar' => 'مضخة المسبح تصدر صوتًا وتتوقف بعد دقائق قليلة.',
                'status' => 'pending',
                'priority' => 'medium',
            ]
        );

        // --- Calendar events ----------------------------------------------------------

        CalendarEvent::query()->updateOrCreate(
            [
                'title' => 'Rent due — Marina View',
                'property_id' => $property->id,
            ],
            [
                'title_ar' => 'استحقاق الإيجار — شقة المارينا',
                'date' => now()->addDays(5)->toDateString(),
                'owner_id' => $owner->id,
                'type' => 'payment',
                'time' => '09:00',
                'amount' => 8500,
            ]
        );

        CalendarEvent::query()->updateOrCreate(
            [
                'title' => 'Maintenance visit',
                'property_id' => $property->id,
            ],
            [
                'title_ar' => 'زيارة صيانة',
                'date' => now()->addDays(2)->toDateString(),
                'owner_id' => $owner->id,
                'type' => 'maintenance',
                'time' => '11:30',
            ]
        );

        CalendarEvent::query()->updateOrCreate(
            [
                'title' => 'Contract renewal — Emirates Hills Villa',
                'property_id' => $villaProperty->id,
            ],
            [
                'title_ar' => 'تجديد عقد — فيلا مروج الإمارات',
                'date' => now()->addDays(20)->toDateString(),
                'owner_id' => $ownerTwo->id,
                'type' => 'contract',
                'time' => '10:00',
            ]
        );

        CalendarEvent::query()->updateOrCreate(
            [
                'title' => 'Site inspection — Palm Residences',
                'property_id' => $palmProperty->id,
            ],
            [
                'title_ar' => 'معاينة الموقع — مساكن النخلة',
                'date' => now()->addDays(3)->toDateString(),
                'owner_id' => $owner->id,
                'type' => 'inspection',
                'time' => '08:30',
            ]
        );

        // --- Tasks ----------------------------------------------------------

        Task::query()->updateOrCreate(
            ['title' => 'Inspect Palm Residences site'],
            [
                'title_ar' => 'معاينة موقع مساكن النخلة',
                'assigned_to' => $admin->id,
                'property_id' => $palmProperty->id,
                'status' => 'pending',
                'priority' => 'high',
                'due_date' => now()->addDays(3)->toDateString(),
                'description' => 'Weekly site inspection.',
                'description_ar' => 'معاينة أسبوعية للموقع.',
            ]
        );

        Task::query()->updateOrCreate(
            ['title' => 'Follow up on JLT Studio listing'],
            [
                'title_ar' => 'متابعة إعلان استوديو أبراج بحيرة الجميرا',
                'assigned_to' => $admin->id,
                'property_id' => $studioProperty->id,
                'status' => 'in_progress',
                'priority' => 'medium',
                'due_date' => now()->addDays(7)->toDateString(),
                'description' => 'Confirm renovation timeline with the owner before re-listing.',
                'description_ar' => 'تأكيد الجدول الزمني للتجديد مع المالك قبل إعادة الطرح.',
            ]
        );

        Task::query()->updateOrCreate(
            ['title' => 'Collect pending payment — Layla Hassan'],
            [
                'title_ar' => 'تحصيل دفعة مستحقة — ليلى حسن',
                'assigned_to' => $admin->id,
                'property_id' => $villaProperty->id,
                'status' => 'pending',
                'priority' => 'high',
                'due_date' => now()->addDays(1)->toDateString(),
                'description' => 'Reminder call for next month rent.',
                'description_ar' => 'مكالمة تذكير بإيجار الشهر القادم.',
            ]
        );

        // --- Conversations ----------------------------------------------------------

        $conversation = Conversation::query()->updateOrCreate(
            [
                'owner_id' => $owner->id,
                'tenant_id' => $tenant->id,
                'subject' => 'Lease renewal discussion',
            ],
            [
                'subject_ar' => 'نقاش تجديد عقد الإيجار',
                'last_message_at' => now(),
            ]
        );

        Message::query()->updateOrCreate(
            [
                'conversation_id' => $conversation->id,
                'body' => 'Hello, can we discuss renewing the contract?',
            ],
            [
                'user_id' => $ownerUser->id,
                'is_from_admin' => false,
            ]
        );

        $conversationTwo = Conversation::query()->updateOrCreate(
            [
                'owner_id' => $ownerTwo->id,
                'tenant_id' => $tenantTwo->id,
                'subject' => 'Pool maintenance schedule',
            ],
            [
                'subject_ar' => 'جدول صيانة المسبح',
                'last_message_at' => now()->subHours(3),
            ]
        );

        Message::query()->updateOrCreate(
            [
                'conversation_id' => $conversationTwo->id,
                'body' => 'When will the maintenance team arrive for the pool pump?',
            ],
            [
                'user_id' => $admin->id,
                'is_from_admin' => true,
            ]
        );

        // --- Reports ----------------------------------------------------------

        Report::query()->updateOrCreate(
            ['title' => 'Q2 Financial Summary', 'type' => 'financial'],
            [
                'title_ar' => 'الملخص المالي للربع الثاني',
                'owner_id' => $owner->id,
                'amount' => 8500,
                'meta' => ['period' => 'Q2'],
            ]
        );

        Report::query()->updateOrCreate(
            ['title' => 'Palm Residences Progress', 'type' => 'project'],
            [
                'title_ar' => 'تقدّم مشروع مساكن النخلة',
                'owner_id' => $owner->id,
                'amount' => 2500000,
                'meta' => [
                    'progress' => 62,
                    'location' => 'Palm Jumeirah',
                    'total_cost' => 2500000,
                    'paid_amount' => 1550000,
                    'start_date' => now()->subMonths(8)->toDateString(),
                    'end_date' => now()->addMonths(6)->toDateString(),
                ],
            ]
        );

        Report::query()->updateOrCreate(
            ['title' => 'Emirates Hills Villa Occupancy', 'type' => 'property'],
            [
                'title_ar' => 'إشغال فيلا مروج الإمارات',
                'owner_id' => $ownerTwo->id,
                'property_id' => $villaProperty->id,
                'amount' => 22000,
                'meta' => ['occupancy_rate' => 100],
            ]
        );
    }
}
