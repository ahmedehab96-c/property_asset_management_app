<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Contract;
use App\Models\Owner;
use App\Models\Payment;
use App\Models\Property;
use App\Models\Tenant;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;

class DashboardController extends Controller
{
    public function metrics(): JsonResponse
    {
        $occupied = Property::query()->where('status', 'occupied')->count();
        $total = Property::query()->count();

        return ApiResponse::success([
            'properties_count' => $total,
            'tenants_count' => Tenant::query()->count(),
            'contracts_count' => Contract::query()->count(),
            'owners_count' => Owner::query()->count(),
            'monthly_revenue' => (float) Property::query()->sum('monthly_revenue'),
            'occupancy_rate' => $total > 0 ? round(($occupied / $total) * 100, 1) : 0,
            'pending_payments' => Payment::query()->where('status', 'pending')->count(),
        ]);
    }

    public function activities(): JsonResponse
    {
        $items = collect()
            ->merge(Payment::query()->latest()->limit(5)->get()->map(fn (Payment $p) => [
                'type' => 'payment',
                'title' => 'Payment #'.$p->id,
                'amount' => (float) $p->amount,
                'status' => $p->status,
                'created_at' => $p->created_at?->toIso8601String(),
            ]))
            ->merge(Contract::query()->latest()->limit(5)->get()->map(fn (Contract $c) => [
                'type' => 'contract',
                'title' => $c->contract_number,
                'status' => $c->status,
                'created_at' => $c->created_at?->toIso8601String(),
            ]))
            ->sortByDesc('created_at')
            ->values()
            ->take(10);

        return ApiResponse::success($items);
    }

    public function financialFlow(): JsonResponse
    {
        $paid = (float) Payment::query()->where('status', 'paid')->sum('amount');
        $pending = (float) Payment::query()->where('status', 'pending')->sum('amount');

        return ApiResponse::success([
            'income' => $paid,
            'pending' => $pending,
            'expenses' => 0,
            'net' => $paid,
        ]);
    }

    public function alerts(): JsonResponse
    {
        $expiring = Contract::query()
            ->where('status', 'active')
            ->whereDate('end_date', '<=', now()->addDays(30))
            ->with(['property', 'tenant'])
            ->limit(10)
            ->get()
            ->map(fn (Contract $c) => [
                'type' => 'contract_expiring',
                'message' => 'Contract '.$c->contract_number.' expires soon',
                'contract' => $c->toApiArray(),
            ]);

        return ApiResponse::success($expiring);
    }

    public function quickStats(): JsonResponse
    {
        return $this->metrics();
    }
}
