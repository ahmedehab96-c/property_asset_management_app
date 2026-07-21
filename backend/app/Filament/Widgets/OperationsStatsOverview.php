<?php

namespace App\Filament\Widgets;

use App\Models\CalendarEvent;
use App\Models\MaintenanceRequest;
use App\Models\MobileRequest;
use App\Models\Project;
use App\Models\Task;
use Filament\Widgets\StatsOverviewWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class OperationsStatsOverview extends StatsOverviewWidget
{
    public function getHeading(): ?string
    {
        return __('admin.widgets.operations');
    }

    protected function getStats(): array
    {
        return [
            Stat::make(__('admin.widgets.open_maintenance'), (string) MaintenanceRequest::query()->where('status', 'in_progress')->count())
                ->description(__('admin.widgets.in_progress'))
                ->color('warning'),
            Stat::make(__('admin.widgets.active_projects'), (string) Project::query()->where('status', 'under_construction')->count())
                ->description(__('admin.widgets.under_construction'))
                ->color('primary'),
            Stat::make(__('admin.widgets.pending_tasks'), (string) Task::query()->where('status', 'pending')->count())
                ->description(__('admin.widgets.needs_attention'))
                ->color('danger'),
            Stat::make(__('admin.widgets.upcoming_events'), (string) CalendarEvent::query()->whereDate('date', '>=', now())->count())
                ->description(__('admin.widgets.from_today'))
                ->color('info'),
            Stat::make(__('admin.widgets.mobile_requests'), (string) MobileRequest::query()->where('status', 'pending')->count())
                ->description(__('admin.widgets.awaiting_review'))
                ->color('success'),
        ];
    }
}
