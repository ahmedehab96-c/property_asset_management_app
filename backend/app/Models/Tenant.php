<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Tenant extends Model
{
    protected $fillable = [
        'user_id',
        'property_id',
        'name',
        'email',
        'phone',
        'address',
        'status',
        'rent_amount',
    ];

    protected function casts(): array
    {
        return [
            'rent_amount' => 'decimal:2',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function property(): BelongsTo
    {
        return $this->belongsTo(Property::class);
    }

    public function contracts(): HasMany
    {
        return $this->hasMany(Contract::class);
    }

    public function payments(): HasMany
    {
        return $this->hasMany(Payment::class);
    }

    public function toApiArray(): array
    {
        $activeContract = $this->contracts()->where('status', 'active')->latest('end_date')->first();
        $latestPayment = $this->payments()->latest('due_date')->first();

        return [
            'id' => $this->id,
            'name' => $this->name,
            'full_name' => $this->name,
            'email' => $this->email,
            'phone' => $this->phone,
            'mobile' => $this->phone,
            'address' => $this->address,
            'status' => $this->status,
            'property_id' => $this->property_id,
            'property_name' => $this->property?->name,
            'property' => $this->property?->name,
            'rent_amount' => (float) $this->rent_amount,
            'rentAmount' => (float) $this->rent_amount,
            'contract_end' => $activeContract?->end_date?->toDateString(),
            'contractEnd' => $activeContract?->end_date?->toDateString(),
            'payment_status' => $latestPayment?->status,
            'paymentStatus' => $latestPayment?->status,
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
