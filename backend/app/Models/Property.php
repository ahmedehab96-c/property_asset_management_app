<?php

namespace App\Models;

use App\Support\Localizable;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Property extends Model
{
    use Localizable;

    protected $fillable = [
        'owner_id',
        'name',
        'name_ar',
        'type',
        'location',
        'location_ar',
        'address',
        'address_ar',
        'status',
        'area',
        'monthly_revenue',
        'description',
        'description_ar',
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
            'name' => $this->localized('name'),
            'name_ar' => $this->name_ar,
            'title' => $this->localized('name'),
            'type' => $this->type,
            'location' => $this->localized('location'),
            'location_ar' => $this->location_ar,
            'address' => $this->localized('address') ?? $this->localized('location'),
            'address_ar' => $this->address_ar,
            'status' => $this->status,
            'area' => $this->area !== null ? (float) $this->area : null,
            'monthly_revenue' => (float) $this->monthly_revenue,
            'monthlyRevenue' => (float) $this->monthly_revenue,
            'owner_id' => $this->owner_id,
            'owner_name' => $this->owner?->localized('name'),
            'tenant_name' => $tenant?->localized('name'),
            'tenantName' => $tenant?->localized('name'),
            'description' => $this->localized('description'),
            'description_ar' => $this->description_ar,
            'latitude' => $this->latitude !== null ? (float) $this->latitude : null,
            'longitude' => $this->longitude !== null ? (float) $this->longitude : null,
            'lat' => $this->latitude !== null ? (float) $this->latitude : null,
            'lng' => $this->longitude !== null ? (float) $this->longitude : null,
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
