<?php

namespace App\Filament\Pages;

use App\Filament\Widgets\OccupancyChartWidget;
use App\Filament\Widgets\OperationsStatsOverview;
use App\Filament\Widgets\RevenueChartWidget;
use BackedEnum;
use Filament\Pages\Page;
use Filament\Support\Icons\Heroicon;

class Analytics extends Page
{
    protected string $view = 'filament.pages.analytics';

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedChartBar;

    protected static ?int $navigationSort = 2;

    public static function getNavigationLabel(): string
    {
        return __('admin.nav.analytics');
    }

    public function getTitle(): string
    {
        return __('admin.nav.analytics');
    }

    /**
     * @return array<class-string>
     */
    public function getHeaderWidgets(): array
    {
        return [
            OperationsStatsOverview::class,
            RevenueChartWidget::class,
            OccupancyChartWidget::class,
        ];
    }

    public function getHeaderWidgetsColumns(): int|array
    {
        return [
            'md' => 2,
            'xl' => 2,
        ];
    }
}
