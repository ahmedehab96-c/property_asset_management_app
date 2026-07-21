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
                'name' => 'Demo Owner',
                'phone' => '+971500000002',
                'address' => 'Dubai Marina',
                'wallet_balance' => 12500,
                'join_date' => now()->subYear()->toDateString(),
            ]
        );

        $property = Property::query()->updateOrCreate(
            ['name' => 'Marina View Apartment', 'owner_id' => $owner->id],
            [
                'type' => 'apartment',
                'location' => 'Dubai Marina',
                'address' => 'Marina Walk, Tower 3',
                'status' => 'occupied',
                'area' => 120,
                'monthly_revenue' => 8500,
                'description' => 'Sea-view 2BR apartment managed by the platform.',
                'latitude' => 25.0805,
                'longitude' => 55.1403,
            ]
        );

        Property::query()->updateOrCreate(
            ['name' => 'Business Bay Office', 'owner_id' => $owner->id],
            [
                'type' => 'office',
                'location' => 'Business Bay',
                'address' => 'Bay Square Building 5',
                'status' => 'available',
                'area' => 90,
                'monthly_revenue' => 12000,
                'description' => 'Ready office unit with parking.',
                'latitude' => 25.1850,
                'longitude' => 55.2720,
            ]
        );

        Property::query()->updateOrCreate(
            ['name' => 'Palm Residences Phase 2', 'owner_id' => $owner->id],
            [
                'type' => 'project',
                'location' => 'Palm Jumeirah',
                'address' => 'Palm Crescent',
                'status' => 'under_construction',
                'area' => 2400,
                'monthly_revenue' => 0,
                'description' => 'Residential project under construction.',
                'latitude' => 25.1124,
                'longitude' => 55.1390,
            ]
        );

        $tenant = Tenant::query()->updateOrCreate(
            ['email' => 'tenant@demo.com'],
            [
                'property_id' => $property->id,
                'name' => 'Ahmed Tenant',
                'phone' => '+971500000003',
                'address' => 'Dubai Marina',
                'status' => 'active',
                'rent_amount' => 8500,
            ]
        );

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

        Payment::query()->updateOrCreate(
            [
                'tenant_id' => $tenant->id,
                'contract_id' => $contract->id,
                'due_date' => now()->startOfMonth()->toDateString(),
            ],
            [
                'property_id' => $property->id,
                'amount' => 8500,
                'payment_date' => now()->subDays(2)->toDateString(),
                'status' => 'paid',
                'method' => 'bank_transfer',
            ]
        );

        Payment::query()->updateOrCreate(
            [
                'tenant_id' => $tenant->id,
                'contract_id' => $contract->id,
                'due_date' => now()->addMonth()->startOfMonth()->toDateString(),
            ],
            [
                'property_id' => $property->id,
                'amount' => 8500,
                'status' => 'pending',
                'method' => 'bank_transfer',
            ]
        );

        AppNotification::query()->updateOrCreate(
            [
                'user_id' => $admin->id,
                'title' => 'Welcome to Property Admin',
            ],
            [
                'message' => 'Laravel admin and API are ready.',
                'type' => 'info',
            ]
        );

        AppNotification::query()->updateOrCreate(
            [
                'user_id' => $ownerUser->id,
                'title' => 'Rent received',
            ],
            [
                'message' => 'Payment for Marina View Apartment was marked as paid.',
                'type' => 'payment',
            ]
        );

        Project::query()->updateOrCreate(
            ['name' => 'Palm Residences Phase 2', 'owner_id' => $owner->id],
            [
                'location' => 'Palm Jumeirah',
                'status' => 'under_construction',
                'progress' => 62,
                'budget' => 2500000,
                'paid_amount' => 1550000,
                'start_date' => now()->subMonths(8)->toDateString(),
                'end_date' => now()->addMonths(6)->toDateString(),
                'description' => 'Residential tower project.',
            ]
        );

        MaintenanceRequest::query()->updateOrCreate(
            ['order_number' => 'MR-12045'],
            [
                'property_id' => $property->id,
                'tenant_id' => $tenant->id,
                'owner_id' => $owner->id,
                'title' => 'AC Repair',
                'problem_type' => 'AC Repair',
                'description' => 'Unit not cooling properly.',
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
                'problem_type' => 'Plumbing',
                'status' => 'completed',
                'priority' => 'medium',
            ]
        );

        CalendarEvent::query()->updateOrCreate(
            [
                'title' => 'Rent due — Marina View',
                'date' => now()->addDays(5)->toDateString(),
            ],
            [
                'property_id' => $property->id,
                'owner_id' => $owner->id,
                'type' => 'payment',
                'time' => '09:00',
                'amount' => 8500,
            ]
        );

        CalendarEvent::query()->updateOrCreate(
            [
                'title' => 'Maintenance visit',
                'date' => now()->addDays(2)->toDateString(),
            ],
            [
                'property_id' => $property->id,
                'owner_id' => $owner->id,
                'type' => 'maintenance',
                'time' => '11:30',
            ]
        );

        Task::query()->updateOrCreate(
            ['title' => 'Inspect Palm Residences site'],
            [
                'assigned_to' => $admin->id,
                'status' => 'pending',
                'priority' => 'high',
                'due_date' => now()->addDays(3)->toDateString(),
                'description' => 'Weekly site inspection.',
            ]
        );

        $conversation = Conversation::query()->updateOrCreate(
            [
                'owner_id' => $owner->id,
                'tenant_id' => $tenant->id,
                'subject' => 'Lease renewal discussion',
            ],
            ['last_message_at' => now()]
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

        Report::query()->updateOrCreate(
            ['title' => 'Q2 Financial Summary', 'type' => 'financial'],
            [
                'owner_id' => $owner->id,
                'amount' => 8500,
                'meta' => ['period' => 'Q2'],
            ]
        );

        Report::query()->updateOrCreate(
            ['title' => 'Palm Residences Progress', 'type' => 'project'],
            [
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
    }
}
