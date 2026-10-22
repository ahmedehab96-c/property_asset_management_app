<?php

namespace App\Services\Agent\Tools;

use App\Models\Tenant;
use App\Models\User;
use App\Services\Agent\AgentTool;

/** Contact details (phone, email) are deliberately left out of what reaches the model. */
class SearchTenantsTool extends AgentTool
{
    public function name(): string
    {
        return 'search_tenants';
    }

    public function description(): string
    {
        return 'Search tenants by name, optionally filtered by status (e.g. active). Returns tenant id, status, rent amount and their property.';
    }

    public function parameters(): array
    {
        return [
            'type' => 'OBJECT',
            'properties' => [
                'query' => ['type' => 'STRING', 'description' => 'Text to match in the tenant name.'],
                'status' => ['type' => 'STRING'],
                'limit' => self::limitSchema(),
            ],
        ];
    }

    public function rules(): array
    {
        return [
            'query' => ['nullable', 'string', 'max:100'],
            'status' => ['nullable', 'string', 'max:30'],
            'limit' => ['nullable', 'integer', 'min:1', 'max:20'],
        ];
    }

    public function execute(array $arguments, User $user): array
    {
        $query = Tenant::query()->with('property');

        if (filled($arguments['query'] ?? null)) {
            $term = '%'.$arguments['query'].'%';
            $query->where(fn ($q) => $q->where('name', 'like', $term)->orWhere('name_ar', 'like', $term));
        }

        if (filled($arguments['status'] ?? null)) {
            $query->where('status', $arguments['status']);
        }

        $total = (clone $query)->count();

        $items = $query->latest()->limit($this->limitArg($arguments))->get()
            ->map(fn (Tenant $tenant) => [
                'id' => $tenant->id,
                'name' => $tenant->localized('name'),
                'status' => $tenant->status,
                'rent_amount' => (float) $tenant->rent_amount,
                'property_id' => $tenant->property_id,
                'property_name' => $tenant->property?->localized('name'),
            ])->all();

        return ['total_matches' => $total, 'tenants' => $items];
    }
}
