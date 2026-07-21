<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Owner extends Model
{
    protected $fillable = [
        'user_id',
        'name',
        'email',
        'phone',
        'address',
        'wallet_balance',
        'join_date',
    ];

    protected function casts(): array
    {
        return [
            'wallet_balance' => 'decimal:2',
            'join_date' => 'date',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function properties(): HasMany
    {
        return $this->hasMany(Property::class);
    }

    public function contracts(): HasMany
    {
        return $this->hasMany(Contract::class);
    }

    public function toApiArray(): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'full_name' => $this->name,
            'email' => $this->email,
            'phone' => $this->phone,
            'mobile' => $this->phone,
            'address' => $this->address,
            'properties_count' => $this->properties()->count(),
            'total_revenue' => (float) $this->properties()->sum('monthly_revenue'),
            'balance' => (float) $this->wallet_balance,
            'wallet_balance' => (float) $this->wallet_balance,
            'join_date' => $this->join_date?->toDateString(),
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
