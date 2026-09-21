<?php

namespace App\Models;

use App\Support\Localizable;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class MaintenanceRequest extends Model
{
    use Localizable;

    protected $fillable = [
        'order_number', 'property_id', 'tenant_id', 'owner_id', 'title', 'title_ar',
        'problem_type', 'problem_type_ar', 'description', 'description_ar', 'status', 'priority',
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
            'title' => $this->localized('title'),
            'title_ar' => $this->title_ar,
            'problem_type' => $this->localized('problem_type') ?? $this->localized('title'),
            'problem_type_ar' => $this->problem_type_ar,
            'problemType' => $this->localized('problem_type') ?? $this->localized('title'),
            'type' => $this->localized('problem_type') ?? $this->localized('title'),
            'description' => $this->localized('description'),
            'description_ar' => $this->description_ar,
            'status' => $this->status,
            'priority' => $this->priority,
            'property_id' => $this->property_id,
            'property_name' => $this->property?->localized('name'),
            'tenant_id' => $this->tenant_id,
            'owner_id' => $this->owner_id,
            'date' => $this->created_at?->toIso8601String(),
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
