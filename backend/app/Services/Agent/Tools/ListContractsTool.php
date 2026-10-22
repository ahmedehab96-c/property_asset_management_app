<?php

namespace App\Services\Agent\Tools;

use App\Models\Contract;
use App\Models\User;
use App\Services\Agent\AgentTool;

class ListContractsTool extends AgentTool
{
    public function name(): string
    {
        return 'list_contracts';
    }

    public function description(): string
    {
        return 'List lease contracts, optionally by status (e.g. active) or those ending within N days. Includes property, tenant, dates and monthly rent (AED).';
    }

    public function parameters(): array
    {
        return [
            'type' => 'OBJECT',
            'properties' => [
                'status' => ['type' => 'STRING'],
                'expiring_within_days' => ['type' => 'INTEGER', 'description' => 'Only contracts whose end date is between today and today + N days (1-365).'],
                'limit' => self::limitSchema(),
            ],
        ];
    }

    public function rules(): array
    {
        return [
            'status' => ['nullable', 'string', 'max:30'],
            'expiring_within_days' => ['nullable', 'integer', 'min:1', 'max:365'],
            'limit' => ['nullable', 'integer', 'min:1', 'max:20'],
        ];
    }

    public function execute(array $arguments, User $user): array
    {
        $query = Contract::query()->with(['property', 'tenant']);

        if (filled($arguments['status'] ?? null)) {
            $query->where('status', $arguments['status']);
        }

        if (filled($arguments['expiring_within_days'] ?? null)) {
            $query->whereBetween('end_date', [now()->toDateString(), now()->addDays((int) $arguments['expiring_within_days'])->toDateString()]);
        }

        $total = (clone $query)->count();

        $items = $query->orderBy('end_date')->limit($this->limitArg($arguments))->get()
            ->map(fn (Contract $contract) => [
                'id' => $contract->id,
                'contract_number' => $contract->contract_number,
                'property_name' => $contract->property?->localized('name'),
                'tenant_name' => $contract->tenant?->localized('name'),
                'start_date' => $contract->start_date?->toDateString(),
                'end_date' => $contract->end_date?->toDateString(),
                'monthly_rent' => (float) $contract->monthly_rent,
                'status' => $contract->status,
            ])->all();

        return ['total_matches' => $total, 'contracts' => $items];
    }
}
