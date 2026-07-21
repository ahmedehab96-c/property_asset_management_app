<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class MaintenanceRequest extends Model
{
    protected $fillable = [
        'order_number', 'property_id', 'tenant_id', 'owner_id', 'title',
        'problem_type', 'description', 'status', 'priority',
    ];

    public function property(): BelongsTo
    {
        return $this->belongsTo(Property::class);
    }

    public function tenant(): BelongsTo
    {
        return $this->belongsTo(Tenant::class);
    }

    public function owner(): BelongsTo
    {
        return $this->belongsTo(Owner::class);
    }

    public function toApiArray(): array
    {
        return [
            'id' => $this->id,
            'order_number' => $this->order_number,
            'orderNumber' => $this->order_number,
            'title' => $this->title,
            'problem_type' => $this->problem_type ?? $this->title,
            'problemType' => $this->problem_type ?? $this->title,
            'type' => $this->problem_type ?? $this->title,
            'description' => $this->description,
            'status' => $this->status,
            'priority' => $this->priority,
            'property_id' => $this->property_id,
            'property_name' => $this->property?->name,
            'tenant_id' => $this->tenant_id,
            'owner_id' => $this->owner_id,
            'date' => $this->created_at?->toIso8601String(),
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
