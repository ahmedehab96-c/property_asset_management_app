<?php

namespace App\Models;

use App\Support\Localizable;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Conversation extends Model
{
    use Localizable;

    protected $fillable = [
        'subject', 'subject_ar', 'owner_id', 'tenant_id', 'last_message_at',
    ];

    protected function casts(): array
    {
        return ['last_message_at' => 'datetime'];
    }

    public function owner(): BelongsTo
    {
        return $this->belongsTo(Owner::class);
    }

    public function tenant(): BelongsTo
    {
        return $this->belongsTo(Tenant::class);
    }

    public function messages(): HasMany
    {
        return $this->hasMany(Message::class);
    }

    public function toApiArray(): array
    {
        $last = $this->messages()->latest()->first();

        return [
            'id' => $this->id,
            'subject' => $this->localized('subject'),
            'subject_ar' => $this->subject_ar,
            'owner_id' => $this->owner_id,
            'tenant_id' => $this->tenant_id,
            'owner_name' => $this->owner?->localized('name'),
            'tenant_name' => $this->tenant?->localized('name'),
            'last_message' => $last?->body,
            'last_message_at' => ($this->last_message_at ?? $last?->created_at)?->toIso8601String(),
        ];
    }
}
