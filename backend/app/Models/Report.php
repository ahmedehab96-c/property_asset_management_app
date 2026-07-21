<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Report extends Model
{
    protected $fillable = [
        'title', 'type', 'owner_id', 'property_id', 'amount', 'meta',
    ];

    protected function casts(): array
    {
        return [
            'amount' => 'decimal:2',
            'meta' => 'array',
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
        return array_merge([
            'id' => $this->id,
            'title' => $this->title,
            'name' => $this->title,
            'type' => $this->type,
            'amount' => $this->amount !== null ? (float) $this->amount : null,
            'owner_id' => $this->owner_id,
            'property_id' => $this->property_id,
            'property_name' => $this->property?->name,
            'created_at' => $this->created_at?->toIso8601String(),
        ], $this->meta ?? []);
    }
}
