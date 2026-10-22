<?php

namespace App\Services\Agent\Tools;

use App\Models\MaintenanceRequest;
use App\Models\Property;
use App\Models\User;
use App\Services\Agent\AgentTool;
use Illuminate\Support\Str;

/** The agent's only write. Never runs from the model directly — see AgentService::confirm(). */
class CreateMaintenanceRequestTool extends AgentTool
{
    public function name(): string
    {
        return 'create_maintenance_request';
    }

    public function description(): string
    {
        return 'Propose a new maintenance request for a property. Use search_properties first to get the property_id. The user must confirm in the app before it is created.';
    }

    public function parameters(): array
    {
        return [
            'type' => 'OBJECT',
            'properties' => [
                'property_id' => ['type' => 'INTEGER'],
                'title' => ['type' => 'STRING', 'description' => 'Short summary of the problem.'],
                'description' => ['type' => 'STRING'],
                'priority' => ['type' => 'STRING', 'enum' => ['low', 'medium', 'high']],
            ],
            'required' => ['property_id', 'title'],
        ];
    }

    public function rules(): array
    {
        return [
            'property_id' => ['required', 'integer', 'exists:properties,id'],
            'title' => ['required', 'string', 'max:255'],
            'description' => ['nullable', 'string', 'max:2000'],
            'priority' => ['nullable', 'string', 'in:low,medium,high'],
        ];
    }

    public function requiresConfirmation(): bool
    {
        return true;
    }

    public function describe(array $arguments, string $locale): string
    {
        $property = Property::query()->find($arguments['property_id']);
        $name = $property?->localized('name') ?? '#'.$arguments['property_id'];
        $priority = $arguments['priority'] ?? 'medium';

        return $locale === 'ar'
            ? "إنشاء طلب صيانة «{$arguments['title']}» للعقار {$name} (الأولوية: {$priority})"
            : "Create maintenance request \"{$arguments['title']}\" for {$name} (priority: {$priority})";
    }

    public function execute(array $arguments, User $user): array
    {
        // Mirrors MaintenanceRequestController::store().
        $item = MaintenanceRequest::query()->create([
            'property_id' => $arguments['property_id'],
            'title' => $arguments['title'],
            'description' => $arguments['description'] ?? null,
            'priority' => $arguments['priority'] ?? 'medium',
            'order_number' => 'MR-'.strtoupper(Str::random(6)),
        ]);

        return ['id' => $item->id, 'order_number' => $item->order_number];
    }
}
