<?php

namespace App\Models;

use App\Support\Localizable;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Project extends Model
{
    use Localizable;

    protected $fillable = [
        'owner_id', 'property_id', 'name', 'name_ar', 'location', 'location_ar', 'status', 'progress',
        'budget', 'paid_amount', 'start_date', 'end_date', 'description', 'description_ar',
    ];

    protected function casts(): array
    {
        return [
            'progress' => 'decimal:2',
            'budget' => 'decimal:2',
            'paid_amount' => 'decimal:2',
            'start_date' => 'date',
            'end_date' => 'date',
        ];
    }

    public function owner(): BelongsTo
    {
        return $this->belongsTo(Owner::class);
    }

    public function property(): BelongsTo
    {
        return $this->belongsTo(Property::class);
    }

    public function toApiArray(): array
    {
        $budget = (float) $this->budget;
        $paid = (float) $this->paid_amount;
        $remaining = max(0, $budget - $paid);

        return [
            'id' => $this->id,
            'name' => $this->localized('name'),
            'name_ar' => $this->name_ar,
            'title' => $this->localized('name'),
            'location' => $this->localized('location'),
            'location_ar' => $this->location_ar,
            'address' => $this->localized('location'),
            'status' => $this->status,
            'type' => 'project',
            'progress' => (float) $this->progress,
            'completion_rate' => (float) $this->progress,
            'budget' => $budget,
            'total_cost' => $budget,
            'paid_amount' => $paid,
            'remaining_amount' => $remaining,
            'start_date' => $this->start_date?->toDateString(),
            'end_date' => $this->end_date?->toDateString(),
            'expected_date' => $this->end_date?->toDateString(),
            'description' => $this->localized('description'),
            'description_ar' => $this->description_ar,
            'owner_id' => $this->owner_id,
            'property_id' => $this->property_id,
        ];
    }
}
