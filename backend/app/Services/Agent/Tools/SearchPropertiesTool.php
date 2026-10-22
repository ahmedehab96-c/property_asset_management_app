<?php

namespace App\Services\Agent\Tools;

use App\Models\Property;
use App\Models\User;
use App\Services\Agent\AgentTool;

class SearchPropertiesTool extends AgentTool
{
    public function name(): string
    {
        return 'search_properties';
    }

    public function description(): string
    {
        return 'Search properties by name or location, optionally filtered by status (e.g. available, occupied) or type (e.g. apartment, villa, office). Returns ids usable by other tools.';
    }

    public function parameters(): array
    {
        return [
            'type' => 'OBJECT',
            'properties' => [
                'query' => ['type' => 'STRING', 'description' => 'Text to match in name, location or address.'],
                'status' => ['type' => 'STRING'],
                'type' => ['type' => 'STRING'],
                'limit' => self::limitSchema(),
            ],
        ];
    }

    public function rules(): array
    {
        return [
            'query' => ['nullable', 'string', 'max:100'],
            'status' => ['nullable', 'string', 'max:30'],
            'type' => ['nullable', 'string', 'max:30'],
            'limit' => ['nullable', 'integer', 'min:1', 'max:20'],
        ];
    }

    public function execute(array $arguments, User $user): array
    {
        $query = Property::query();

        if (filled($arguments['query'] ?? null)) {
            $term = '%'.$arguments['query'].'%';
            $query->where(fn ($q) => $q
                ->where('name', 'like', $term)
                ->orWhere('name_ar', 'like', $term)
                ->orWhere('location', 'like', $term)
                ->orWhere('address', 'like', $term));
        }

        foreach (['status', 'type'] as $field) {
            if (filled($arguments[$field] ?? null)) {
                $query->where($field, $arguments[$field]);
            }
        }

        $total = (clone $query)->count();

        $items = $query->latest()->limit($this->limitArg($arguments))->get()
            ->map(fn (Property $property) => [
                'id' => $property->id,
                'name' => $property->localized('name'),
                'type' => $property->type,
                'location' => $property->localized('location'),
                'status' => $property->status,
                'monthly_revenue' => (float) $property->monthly_revenue,
            ])->all();

        return ['total_matches' => $total, 'properties' => $items];
    }
}
