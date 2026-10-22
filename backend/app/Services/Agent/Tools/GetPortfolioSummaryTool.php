<?php

namespace App\Services\Agent\Tools;

use App\Models\User;
use App\Services\Agent\AgentTool;
use App\Services\PortfolioContextService;
use Illuminate\Support\Arr;

class GetPortfolioSummaryTool extends AgentTool
{
    public function __construct(private readonly PortfolioContextService $portfolio) {}

    public function name(): string
    {
        return 'get_portfolio_summary';
    }

    public function description(): string
    {
        return 'Portfolio totals: property counts by status, occupancy rate, tenants, active contracts, monthly revenue, paid/pending payment totals (AED), open maintenance.';
    }

    public function execute(array $arguments, User $user): array
    {
        return Arr::except($this->portfolio->build(), ['properties']);
    }
}
