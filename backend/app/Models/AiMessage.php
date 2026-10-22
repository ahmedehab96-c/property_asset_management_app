<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class AiMessage extends Model
{
    protected $fillable = ['ai_conversation_id', 'role', 'content', 'meta'];

    protected function casts(): array
    {
        return ['meta' => 'array'];
    }

    public function conversation(): BelongsTo
    {
        return $this->belongsTo(AiConversation::class, 'ai_conversation_id');
    }

    public function toApiArray(): array
    {
        return [
            'id' => $this->id,
            'role' => $this->role,
            'content' => $this->content,
            'actions' => $this->meta['actions'] ?? [],
            'pending_action_id' => $this->meta['pending_action_id'] ?? null,
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
