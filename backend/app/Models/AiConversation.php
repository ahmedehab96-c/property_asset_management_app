<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class AiConversation extends Model
{
    protected $fillable = ['user_id', 'title', 'locale', 'channel'];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function messages(): HasMany
    {
        return $this->hasMany(AiMessage::class);
    }

    public function toApiArray(): array
    {
        return [
            'id' => $this->id,
            'title' => $this->title,
            'locale' => $this->locale,
            'channel' => $this->channel,
            'updated_at' => $this->updated_at?->toIso8601String(),
        ];
    }
}
