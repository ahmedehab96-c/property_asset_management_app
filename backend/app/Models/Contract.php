<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Contract extends Model
{
    protected $fillable = [
        'contract_number',
        'property_id',
        'tenant_id',
        'owner_id',
        'start_date',
        'end_date',
        'monthly_rent',
        'deposit',
        'status',
    ];

    protected function casts(): array
    {
        return [
            'start_date' => 'date',
            'end_date' => 'date',
            'monthly_rent' => 'decimal:2',
            'deposit' => 'decimal:2',
        ];
    }

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

    public function payments(): HasMany
    {
        return $this->hasMany(Payment::class);
    }

    public function toApiArray(): array
    {
        return [
            'id' => $this->id,
            'contract_number' => $this->contract_number,
            'contractNumber' => $this->contract_number,
            'property_id' => $this->property_id,
            'tenant_id' => $this->tenant_id,
            'owner_id' => $this->owner_id,
            'property_name' => $this->property?->localized('name'),
            'property' => $this->property?->localized('name'),
            'tenant_name' => $this->tenant?->localized('name'),
            'tenant' => $this->tenant?->localized('name'),
            'owner_name' => $this->owner?->localized('name'),
            'owner' => $this->owner?->localized('name'),
            'start_date' => $this->start_date?->toDateString(),
            'end_date' => $this->end_date?->toDateString(),
            'monthly_rent' => (float) $this->monthly_rent,
            'monthlyRent' => (float) $this->monthly_rent,
            'deposit' => (float) $this->deposit,
            'status' => $this->status,
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
