<?php

namespace App\Filament\Widgets;

use App\Models\Contract;
use App\Models\Owner;
use App\Models\Payment;
use App\Models\Property;
use App\Models\Tenant;
use Filament\Widgets\StatsOverviewWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class EstateStatsOverview extends StatsOverviewWidget
{
    protected function getStats(): array
    {
        $occupied = Property::query()->where('status', 'occupied')->count();
        $total = Property::query()->count();
        $occupancy = $total > 0 ? round(($occupied / $total) * 100, 1) : 0;

        return [
            Stat::make(__('admin.widgets.properties'), (string) $total)
                ->description(__('admin.widgets.total_managed_units'))
                ->descriptionIcon('heroicon-m-building-office-2')
                ->color('primary'),
            Stat::make(__('admin.widgets.tenants'), (string) Tenant::query()->count())
                ->description(__('admin.widgets.active_portfolio'))
                ->descriptionIcon('heroicon-m-users')
                ->color('success'),
            Stat::make(__('admin.widgets.contracts'), (string) Contract::query()->count())
                ->description(__('admin.widgets.all_agreements'))
                ->descriptionIcon('heroicon-m-document-text')
                ->color('info'),
            Stat::make(__('admin.widgets.owners'), (string) Owner::query()->count())
                ->description(__('admin.widgets.partners'))
                ->descriptionIcon('heroicon-m-user-group')
                ->color('warning'),
            Stat::make(__('admin.widgets.monthly_revenue'), number_format((float) Property::query()->sum('monthly_revenue'), 0).' AED')
                ->description(__('admin.widgets.portfolio_income'))
                ->descriptionIcon('heroicon-m-banknotes')
                ->color('success'),
            Stat::make(__('admin.widgets.occupancy'), $occupancy.'%')
                ->description(__('admin.widgets.occupied_units'))
                ->descriptionIcon('heroicon-m-chart-bar')
                ->color('primary'),
            Stat::make(__('admin.widgets.pending_payments'), (string) Payment::query()->where('status', 'pending')->count())
                ->description(__('admin.widgets.awaiting_collection'))
                ->descriptionIcon('heroicon-m-clock')
                ->color('danger'),
        ];
    }
}
