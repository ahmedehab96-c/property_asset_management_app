<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class MobileRequest extends Model
{
    protected $fillable = [
        'user_id', 'type', 'title', 'description', 'status', 'payload', 'attachments',
    ];

    protected function casts(): array
    {
        return [
            'payload' => 'array',
            'attachments' => 'array',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function toApiArray(): array
    {
        return [
            'id' => $this->id,
            'type' => $this->type,
            'title' => $this->title,
            'description' => $this->description,
            'status' => $this->status,
            'payload' => $this->payload,
            'attachments' => $this->attachments ?? [],
            'user_id' => $this->user_id,
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
