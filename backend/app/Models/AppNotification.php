<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class AppNotification extends Model
{
    protected $table = 'notifications';

    protected $fillable = [
        'user_id',
        'title',
        'message',
        'type',
        'read_at',
    ];

    protected function casts(): array
    {
        return [
            'read_at' => 'datetime',
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
            'title' => $this->title,
            'message' => $this->message,
            'body' => $this->message,
            'type' => $this->type,
            'read_at' => $this->read_at?->toIso8601String(),
            'unread' => $this->read_at === null,
            'created_at' => $this->created_at?->toIso8601String(),
            'time' => $this->created_at?->toIso8601String(),
        ];
    }
}
