<?php

namespace App\Filament\Widgets;

use App\Models\Payment;
use App\Models\Property;
use Filament\Widgets\ChartWidget;

class RevenueChartWidget extends ChartWidget
{
    public function getHeading(): ?string
    {
        return __('admin.widgets.revenue_last_6_months');
    }

    protected ?string $maxHeight = '280px';

    protected int|string|array $columnSpan = 1;

    protected function getType(): string
    {
        return 'line';
    }

    protected function getData(): array
    {
        $labels = [];
        $values = [];

        for ($i = 5; $i >= 0; $i--) {
            $date = now()->subMonths($i);
            $labels[] = $date->format('M Y');

            $paid = (float) Payment::query()
                ->where('status', 'paid')
                ->where(function ($q) use ($date) {
                    $q->where(function ($inner) use ($date) {
                        $inner->whereMonth('payment_date', $date->month)
                            ->whereYear('payment_date', $date->year);
                    })->orWhere(function ($inner) use ($date) {
                        $inner->whereNull('payment_date')
                            ->whereMonth('due_date', $date->month)
                            ->whereYear('due_date', $date->year);
                    });
                })
                ->sum('amount');

            if ($paid <= 0) {
                $paid = (float) Property::query()->sum('monthly_revenue');
            }

            $values[] = $paid;
        }

        return [
            'datasets' => [
                [
                    'label' => 'AED',
                    'data' => $values,
                    'borderColor' => '#2563EB',
                    'backgroundColor' => 'rgba(37, 99, 235, 0.2)',
                    'tension' => 0.35,
                    'fill' => true,
                ],
            ],
            'labels' => $labels,
        ];
    }
}
