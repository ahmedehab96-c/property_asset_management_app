<?php

namespace App\Filament\Widgets;

use App\Models\Property;
use Filament\Widgets\ChartWidget;

class OccupancyChartWidget extends ChartWidget
{
    public function getHeading(): ?string
    {
        return __('admin.widgets.occupancy_by_status');
    }

    protected ?string $maxHeight = '280px';

    protected int|string|array $columnSpan = 1;

    protected function getType(): string
    {
        return 'doughnut';
    }

    protected function getData(): array
    {
        $byStatus = Property::query()
            ->selectRaw('status, COUNT(*) as total')
            ->groupBy('status')
            ->pluck('total', 'status');

        $labels = [];
        $values = [];
        $colors = [
            'occupied' => '#3D8B7A',
            'available' => '#C9A227',
            'under_construction' => '#2563EB',
            'maintenance' => '#B87333',
        ];
        $bg = [];

        foreach ($byStatus as $status => $total) {
            $labels[] = str_replace('_', ' ', (string) $status);
            $values[] = (int) $total;
            $bg[] = $colors[$status] ?? '#4A6FA5';
        }

        if ($values === []) {
            $labels = ['No data'];
            $values = [1];
            $bg = ['#64748B'];
        }

        return [
            'datasets' => [
                [
                    'data' => $values,
                    'backgroundColor' => $bg,
                ],
            ],
            'labels' => $labels,
        ];
    }
}
