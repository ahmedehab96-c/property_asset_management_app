<?php

namespace App\Services;

use App\Models\Contract;
use App\Models\MaintenanceRequest;
use App\Models\Payment;
use App\Models\Property;
use App\Models\Tenant;

class PortfolioContextService
{
    /**
     * @return array<string, mixed>
     */
    public function build(): array
    {
        $total = Property::query()->count();
        $occupied = Property::query()->where('status', 'occupied')->count();
        $available = Property::query()->where('status', 'available')->count();
        $monthlyRevenue = (float) Property::query()->sum('monthly_revenue');

        $properties = Property::query()
            ->select(['id', 'name', 'type', 'location', 'status', 'monthly_revenue'])
            ->latest()
            ->limit(12)
            ->get()
            ->map(fn (Property $property) => [
                'id' => $property->id,
                'name' => $property->name,
                'type' => $property->type,
                'location' => $property->location,
                'status' => $property->status,
                'monthly_revenue' => (float) $property->monthly_revenue,
            ])
            ->values()
            ->all();

        return [
            'properties_count' => $total,
            'occupied_count' => $occupied,
            'available_count' => $available,
            'occupancy_rate' => $total > 0 ? round(($occupied / $total) * 100, 1) : 0,
            'tenants_count' => Tenant::query()->count(),
            'active_contracts' => Contract::query()->where('status', 'active')->count(),
            'monthly_revenue' => $monthlyRevenue,
            'payments_paid' => (float) Payment::query()->where('status', 'paid')->sum('amount'),
            'payments_pending' => (float) Payment::query()->where('status', 'pending')->sum('amount'),
            'open_maintenance' => MaintenanceRequest::query()->where('status', 'in_progress')->count(),
            'properties' => $properties,
        ];
    }
}
