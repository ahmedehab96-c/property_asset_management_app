<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Contract;
use App\Models\MaintenanceRequest;
use App\Models\Payment;
use App\Models\Property;
use App\Models\Tenant;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Carbon;

class AnalyticsController extends Controller
{
    public function overview(): JsonResponse
    {
        $total = Property::query()->count();
        $occupied = Property::query()->where('status', 'occupied')->count();
        $available = Property::query()->where('status', 'available')->count();
        $underConstruction = Property::query()->where('status', 'under_construction')->count();
        $monthlyRevenue = (float) Property::query()->sum('monthly_revenue');
        $paid = (float) Payment::query()->where('status', 'paid')->sum('amount');
        $pending = (float) Payment::query()->where('status', 'pending')->sum('amount');

        return ApiResponse::success([
            'properties_count' => $total,
            'occupied_count' => $occupied,
            'available_count' => $available,
            'under_construction_count' => $underConstruction,
            'occupancy_rate' => $total > 0 ? round(($occupied / $total) * 100, 1) : 0,
            'tenants_count' => Tenant::query()->count(),
            'active_contracts' => Contract::query()->where('status', 'active')->count(),
            'monthly_revenue' => $monthlyRevenue,
            'payments_paid' => $paid,
            'payments_pending' => $pending,
            'open_maintenance' => MaintenanceRequest::query()->where('status', 'in_progress')->count(),
        ]);
    }

    public function revenue(): JsonResponse
    {
        $months = [];
        for ($i = 5; $i >= 0; $i--) {
            $date = now()->subMonths($i);
            $paid = (float) Payment::query()
                ->where('status', 'paid')
                ->whereMonth('payment_date', $date->month)
                ->whereYear('payment_date', $date->year)
                ->sum('amount');

            // Fallback: use due_date month when payment_date is null.
            if ($paid <= 0) {
                $paid = (float) Payment::query()
                    ->where('status', 'paid')
                    ->whereMonth('due_date', $date->month)
                    ->whereYear('due_date', $date->year)
                    ->sum('amount');
            }

            $months[] = [
                'month' => $date->format('Y-m'),
                'label' => $date->translatedFormat('M Y'),
                'amount' => $paid > 0 ? $paid : (float) Property::query()->sum('monthly_revenue'),
            ];
        }

        return ApiResponse::success([
            'months' => $months,
            'total' => collect($months)->sum('amount'),
        ]);
    }

    public function occupancy(): JsonResponse
    {
        $byStatus = Property::query()
            ->selectRaw('status, COUNT(*) as total')
            ->groupBy('status')
            ->pluck('total', 'status');

        $total = max(1, Property::query()->count());

        return ApiResponse::success([
            'by_status' => $byStatus,
            'occupancy_rate' => round(((int) ($byStatus['occupied'] ?? 0) / $total) * 100, 1),
            'vacancy_rate' => round(((int) ($byStatus['available'] ?? 0) / $total) * 100, 1),
            'as_of' => Carbon::now()->toIso8601String(),
        ]);
    }
}
