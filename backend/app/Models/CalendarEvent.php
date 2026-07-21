<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class CalendarEvent extends Model
{
    protected $fillable = [
        'property_id', 'owner_id', 'title', 'type', 'date', 'time', 'amount', 'notes',
    ];

    protected function casts(): array
    {
        return [
            'date' => 'date',
            'amount' => 'decimal:2',
        ];
    }

    public function property(): BelongsTo
    {
        return $this->belongsTo(Property::class);
    }

    public function owner(): BelongsTo
    {
        return $this->belongsTo(Owner::class);
    }

    public function toApiArray(): array
    {
        return [
            'id' => $this->id,
            'title' => $this->title,
            'name' => $this->title,
            'type' => $this->type,
            'date' => $this->date?->toDateString(),
            'start_at' => $this->date?->toDateString(),
            'time' => $this->time ?? '09:00',
            'start_time' => $this->time ?? '09:00',
            'amount' => $this->amount !== null ? (float) $this->amount : null,
            'property_id' => $this->property_id,
            'property_name' => $this->property?->name,
            'property' => $this->property?->name,
            'notes' => $this->notes,
        ];
    }
}
