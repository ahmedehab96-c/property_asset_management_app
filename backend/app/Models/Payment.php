<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Payment extends Model
{
    protected $fillable = [
        'tenant_id',
        'property_id',
        'contract_id',
        'amount',
        'due_date',
        'payment_date',
        'status',
        'method',
        'notes',
    ];

    protected function casts(): array
    {
        return [
            'amount' => 'decimal:2',
            'due_date' => 'date',
            'payment_date' => 'date',
        ];
    }

    public function tenant(): BelongsTo
    {
        return $this->belongsTo(Tenant::class);
    }

    public function property(): BelongsTo
    {
        return $this->belongsTo(Property::class);
    }

    public function contract(): BelongsTo
    {
        return $this->belongsTo(Contract::class);
    }

    public function toApiArray(): array
    {
        return [
            'id' => $this->id,
            'tenant_id' => $this->tenant_id,
            'property_id' => $this->property_id,
            'contract_id' => $this->contract_id,
            'tenant_name' => $this->tenant?->name,
            'property_name' => $this->property?->name,
            'property' => $this->property?->name,
            'amount' => (float) $this->amount,
            'due_date' => $this->due_date?->toDateString(),
            'payment_date' => $this->payment_date?->toDateString(),
            'status' => $this->status,
            'method' => $this->method,
            'notes' => $this->notes,
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
