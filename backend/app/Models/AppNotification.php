<?php

namespace App\Models;

use App\Support\Localizable;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class AppNotification extends Model
{
    use Localizable;

    protected $table = 'notifications';

    protected $fillable = [
        'user_id',
        'title',
        'title_ar',
        'message',
        'message_ar',
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
            'title' => $this->localized('title'),
            'title_ar' => $this->title_ar,
            'message' => $this->localized('message'),
            'message_ar' => $this->message_ar,
            'body' => $this->localized('message'),
            'type' => $this->type,
            'read_at' => $this->read_at?->toIso8601String(),
            'unread' => $this->read_at === null,
            'created_at' => $this->created_at?->toIso8601String(),
            'time' => $this->created_at?->toIso8601String(),
        ];
    }
}
