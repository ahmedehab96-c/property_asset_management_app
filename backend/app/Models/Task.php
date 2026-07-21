<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Task extends Model
{
    protected $fillable = [
        'assigned_to', 'property_id', 'title', 'description', 'status', 'priority', 'due_date',
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
            'title' => $this->title,
            'description' => $this->description,
            'status' => $this->status,
            'priority' => $this->priority,
            'due_date' => $this->due_date?->toDateString(),
            'assigned_to' => $this->assigned_to,
            'assignee_name' => $this->assignee?->name,
            'property_id' => $this->property_id,
            'property_name' => $this->property?->name,
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
