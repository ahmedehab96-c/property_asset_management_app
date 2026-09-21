<?php

namespace App\Models;

use App\Support\Localizable;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Task extends Model
{
    use Localizable;

    protected $fillable = [
        'assigned_to', 'property_id', 'title', 'title_ar', 'description', 'description_ar',
        'status', 'priority', 'due_date',
    ];

    protected function casts(): array
    {
        return ['due_date' => 'date'];
    }

    public function assignee(): BelongsTo
    {
        return $this->belongsTo(User::class, 'assigned_to');
    }

    public function property(): BelongsTo
    {
        return $this->belongsTo(Property::class);
    }

    public function toApiArray(): array
    {
        return [
            'id' => $this->id,
            'title' => $this->localized('title'),
            'title_ar' => $this->title_ar,
            'description' => $this->localized('description'),
            'description_ar' => $this->description_ar,
            'status' => $this->status,
            'priority' => $this->priority,
            'due_date' => $this->due_date?->toDateString(),
            'assigned_to' => $this->assigned_to,
            'assignee_name' => $this->assignee?->name,
            'property_id' => $this->property_id,
            'property_name' => $this->property?->localized('name'),
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
