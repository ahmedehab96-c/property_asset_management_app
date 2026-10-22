<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/** A write the agent proposed; it only runs after the user confirms it. */
class AiPendingAction extends Model
{
    protected $fillable = ['user_id', 'ai_conversation_id', 'tool', 'arguments', 'status', 'result', 'expires_at'];

    protected function casts(): array
    {
        return [
            'arguments' => 'array',
            'result' => 'array',
            'expires_at' => 'datetime',
        ];
    }

    public function conversation(): BelongsTo
    {
        return $this->belongsTo(AiConversation::class, 'ai_conversation_id');
    }

    public function isExpired(): bool
    {
        return $this->expires_at->isPast();
    }
}
