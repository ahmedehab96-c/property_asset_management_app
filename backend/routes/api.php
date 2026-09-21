<?php

use App\Http\Controllers\Api\V1\AiController;
use App\Http\Controllers\Api\V1\ImageAnalysisController;
use App\Http\Controllers\Api\V1\AnalyticsController;
use App\Http\Controllers\Api\V1\AuthController;
use App\Http\Controllers\Api\V1\CalendarEventController;
use App\Http\Controllers\Api\V1\ContractController;
use App\Http\Controllers\Api\V1\ConversationController;
use App\Http\Controllers\Api\V1\DashboardController;
use App\Http\Controllers\Api\V1\MaintenanceRequestController;
use App\Http\Controllers\Api\V1\MobileRequestController;
use App\Http\Controllers\Api\V1\NotificationController;
use App\Http\Controllers\Api\V1\OwnerController;
use App\Http\Controllers\Api\V1\PaymentController;
use App\Http\Controllers\Api\V1\ProjectController;
use App\Http\Controllers\Api\V1\PropertyController;
use App\Http\Controllers\Api\V1\ReportController;
use App\Http\Controllers\Api\V1\TaskController;
use App\Http\Controllers\Api\V1\TenantController;
use App\Http\Controllers\Api\V1\UploadController;
use App\Http\Controllers\Api\V1\UserController;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function () {
    Route::prefix('auth')->group(function () {
        Route::post('login', [AuthController::class, 'login']);
        Route::post('register', [AuthController::class, 'register']);
        Route::post('forgot-password', [AuthController::class, 'forgotPassword']);
        Route::post('reset-password', [AuthController::class, 'resetPassword']);
        Route::post('verify-email', [AuthController::class, 'verifyEmail'])->middleware('auth:sanctum');

        Route::middleware('auth:sanctum')->group(function () {
            Route::get('user', [AuthController::class, 'user']);
            Route::post('logout', [AuthController::class, 'logout']);
            Route::post('refresh', [AuthController::class, 'refresh']);
            Route::post('change-password', [AuthController::class, 'changePassword']);
            Route::post('email/resend-verification', [AuthController::class, 'resendVerification']);
            Route::put('two-factor', [AuthController::class, 'updateTwoFactor']);
        });
    });

    Route::middleware('auth:sanctum')->group(function () {
        Route::get('dashboard/metrics', [DashboardController::class, 'metrics']);
        Route::get('dashboard/activities', [DashboardController::class, 'activities']);
        Route::get('dashboard/financial-flow', [DashboardController::class, 'financialFlow']);
        Route::get('dashboard/alerts', [DashboardController::class, 'alerts']);
        Route::get('dashboard/quick-stats', [DashboardController::class, 'quickStats']);

        Route::get('analytics/overview', [AnalyticsController::class, 'overview']);
        Route::get('analytics/revenue', [AnalyticsController::class, 'revenue']);
        Route::get('analytics/occupancy', [AnalyticsController::class, 'occupancy']);
        Route::get('analytics/operations', [AnalyticsController::class, 'operations']);
        Route::post('analytics/image-analysis', [ImageAnalysisController::class, 'analyze']);

        Route::prefix('ai')->group(function () {
            Route::get('status', [AiController::class, 'status']);
            Route::post('chat', [AiController::class, 'chat']);
            Route::post('market-analysis', [AiController::class, 'marketAnalysis']);
            Route::post('tenant-analysis', [AiController::class, 'tenantAnalysis']);
            Route::post('financial-predictions', [AiController::class, 'financialPredictions']);
        });

        Route::get('properties/search', [PropertyController::class, 'search']);
        Route::get('properties/filter', [PropertyController::class, 'filter']);
        Route::apiResource('properties', PropertyController::class);
        Route::get('properties/{property}/stats', [PropertyController::class, 'stats']);
        Route::get('properties/{property}/financial', [PropertyController::class, 'financial']);

        Route::apiResource('tenants', TenantController::class);
        Route::get('tenants/{tenant}/payments', [TenantController::class, 'payments']);
        Route::get('tenants/{tenant}/contracts', [TenantController::class, 'contracts']);
        Route::get('tenants/{tenant}/history', [TenantController::class, 'history']);

        Route::get('contracts/expiring', [ContractController::class, 'expiring']);
        Route::apiResource('contracts', ContractController::class);
        Route::post('contracts/{contract}/renew', [ContractController::class, 'renew']);
        Route::post('contracts/{contract}/extend', [ContractController::class, 'extend']);
        Route::post('contracts/{contract}/cancel', [ContractController::class, 'cancel']);
        Route::get('contracts/{contract}/payments', [ContractController::class, 'payments']);

        Route::apiResource('owners', OwnerController::class);
        Route::get('owners/{owner}/properties', [OwnerController::class, 'properties']);
        Route::get('owners/{owner}/financial', [OwnerController::class, 'financial']);

        Route::get('payments/upcoming', [PaymentController::class, 'upcoming']);
        Route::get('payments/overdue', [PaymentController::class, 'overdue']);
        Route::get('payments/statistics', [PaymentController::class, 'statistics']);
        Route::get('financial/summary', [PaymentController::class, 'summary']);
        Route::apiResource('payments', PaymentController::class);

        Route::get('users/registration-requests', [UserController::class, 'registrationRequests']);
        Route::apiResource('users', UserController::class);
        Route::post('users/{user}/approve', [UserController::class, 'approve']);
        Route::post('users/{user}/reject', [UserController::class, 'reject']);
        Route::get('users/{user}/profile', [UserController::class, 'profile']);

        Route::get('notifications', [NotificationController::class, 'index']);
        Route::get('notifications/unread', [NotificationController::class, 'unread']);
        Route::post('notifications', [NotificationController::class, 'store']);
        Route::post('notifications/{id}/read', [NotificationController::class, 'markRead']);
        Route::post('notifications/read-all', [NotificationController::class, 'markAllRead']);
        Route::get('notifications/{notification}', [NotificationController::class, 'show']);
        Route::put('notifications/{notification}', [NotificationController::class, 'update']);
        Route::delete('notifications/{id}', [NotificationController::class, 'destroy']);

        Route::get('maintenance-requests', [MaintenanceRequestController::class, 'index']);
        Route::post('maintenance-requests', [MaintenanceRequestController::class, 'store']);
        Route::get('maintenance-requests/{maintenanceRequest}', [MaintenanceRequestController::class, 'show']);
        Route::put('maintenance-requests/{maintenanceRequest}', [MaintenanceRequestController::class, 'update']);
        Route::delete('maintenance-requests/{maintenanceRequest}', [MaintenanceRequestController::class, 'destroy']);

        Route::get('calendar/events', [CalendarEventController::class, 'index']);
        Route::get('calendar/events/upcoming', [CalendarEventController::class, 'upcoming']);
        Route::post('calendar/events', [CalendarEventController::class, 'store']);
        Route::get('calendar/events/{calendarEvent}', [CalendarEventController::class, 'show']);
        Route::put('calendar/events/{calendarEvent}', [CalendarEventController::class, 'update']);
        Route::delete('calendar/events/{calendarEvent}', [CalendarEventController::class, 'destroy']);

        Route::apiResource('projects', ProjectController::class);
        Route::apiResource('tasks', TaskController::class);
        Route::post('tasks/{task}/status', [TaskController::class, 'updateStatus']);

        Route::get('conversations', [ConversationController::class, 'index']);
        Route::post('conversations', [ConversationController::class, 'store']);
        Route::get('conversations/{conversation}/messages', [ConversationController::class, 'messages']);
        Route::post('conversations/{conversation}/messages', [ConversationController::class, 'storeMessage']);
        Route::get('conversations/{conversation}', [ConversationController::class, 'show']);
        Route::put('conversations/{conversation}', [ConversationController::class, 'update']);
        Route::delete('conversations/{conversation}', [ConversationController::class, 'destroy']);

        Route::get('reports', [ReportController::class, 'index']);
        Route::get('reports/financial', [ReportController::class, 'financial']);
        Route::get('reports/tenant', [ReportController::class, 'tenant']);
        Route::get('reports/property', [ReportController::class, 'property']);
        Route::get('reports/contract', [ReportController::class, 'contract']);
        Route::post('reports', [ReportController::class, 'store']);
        Route::get('reports/{report}', [ReportController::class, 'show']);
        Route::put('reports/{report}', [ReportController::class, 'update']);
        Route::delete('reports/{report}', [ReportController::class, 'destroy']);

        Route::get('mobile-requests', [MobileRequestController::class, 'index']);
        Route::post('mobile-requests', [MobileRequestController::class, 'store']);
        Route::get('mobile-requests/{mobileRequest}', [MobileRequestController::class, 'show']);
        Route::put('mobile-requests/{mobileRequest}', [MobileRequestController::class, 'update']);
        Route::delete('mobile-requests/{mobileRequest}', [MobileRequestController::class, 'destroy']);

        Route::post('upload/multiple', [UploadController::class, 'multiple']);
        Route::post('upload/image', [UploadController::class, 'image']);
        Route::post('upload/document', [UploadController::class, 'document']);
    });
});
