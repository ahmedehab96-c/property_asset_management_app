<?php

namespace App\Services\Agent\Tools;

use App\Models\MaintenanceRequest;
use App\Models\User;
use App\Services\Agent\AgentTool;

class ListMaintenanceRequestsTool extends AgentTool
{
    public function name(): string
    {
        return 'list_maintenance_requests';
    }

    public function description(): string
    {
        return 'List maintenance requests, optionally by status (e.g. in_progress, completed) or priority (low, medium, high), optionally for one property id.';
    }

    public function parameters(): array
    {
        return [
            'type' => 'OBJECT',
            'properties' => [
                'status' => ['type' => 'STRING', 'description' => 'English status code as stored, e.g. in_progress, completed. Never translate it.'],
                'priority' => ['type' => 'STRING', 'description' => 'English code: low, medium or high.'],
                'property_id' => ['type' => 'INTEGER'],
                'limit' => self::limitSchema(),
            ],
        ];
    }

    public function rules(): array
    {
        return [
            'status' => ['nullable', 'string', 'max:30'],
            'priority' => ['nullable', 'string', 'max:30'],
            'property_id' => ['nullable', 'integer'],
            'limit' => ['nullable', 'integer', 'min:1', 'max:20'],
        ];
    }

    public function execute(array $arguments, User $user): array
    {
        $query = MaintenanceRequest::query()->with('property');

        foreach (['status', 'priority', 'property_id'] as $field) {
            if (filled($arguments[$field] ?? null)) {
                $query->where($field, $arguments[$field]);
            }
        }

        $total = (clone $query)->count();

        $items = $query->latest()->limit($this->limitArg($arguments))->get()
            ->map(fn (MaintenanceRequest $item) => [
                'id' => $item->id,
                'order_number' => $item->order_number,
                'title' => $item->localized('title'),
                'status' => $item->status,
                'priority' => $item->priority,
                'property_name' => $item->property?->localized('name'),
                'created_at' => $item->created_at?->toDateString(),
            ])->all();

        return ['total_matches' => $total, 'maintenance_requests' => $items];
    }
}
