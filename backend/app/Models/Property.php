<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Property extends Model
{
    protected $fillable = [
        'owner_id',
        'name',
        'type',
        'location',
        'address',
        'status',
        'area',
        'monthly_revenue',
        'description',
        'latitude',
        'longitude',
    ];

    protected function casts(): array
    {
        return [
            'area' => 'decimal:2',
            'monthly_revenue' => 'decimal:2',
            'latitude' => 'decimal:7',
            'longitude' => 'decimal:7',
        ];
    }

    public function owner(): BelongsTo
    {
        return $this->belongsTo(Owner::class);
    }

    public function tenants(): HasMany
    {
        return $this->hasMany(Tenant::class);
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
        $tenant = $this->tenants()->where('status', 'active')->first();

        return [
            'id' => $this->id,
            'name' => $this->name,
            'title' => $this->name,
            'type' => $this->type,
            'location' => $this->location,
            'address' => $this->address ?? $this->location,
            'status' => $this->status,
            'area' => $this->area !== null ? (float) $this->area : null,
            'monthly_revenue' => (float) $this->monthly_revenue,
            'monthlyRevenue' => (float) $this->monthly_revenue,
            'owner_id' => $this->owner_id,
            'owner_name' => $this->owner?->name,
            'tenant_name' => $tenant?->name,
            'tenantName' => $tenant?->name,
            'description' => $this->description,
            'latitude' => $this->latitude !== null ? (float) $this->latitude : null,
            'longitude' => $this->longitude !== null ? (float) $this->longitude : null,
            'lat' => $this->latitude !== null ? (float) $this->latitude : null,
            'lng' => $this->longitude !== null ? (float) $this->longitude : null,
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
