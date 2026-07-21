<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class ResetPasswordTokenNotification extends Notification
{
    use Queueable;

    public function __construct(public readonly string $token) {}

    public function via(object $notifiable): array
    {
        return ['mail'];
    }

    public function toMail(object $notifiable): MailMessage
    {
        $name = $notifiable->name ?? 'User';

        return (new MailMessage)
            ->subject('Password reset')
            ->greeting("Hello {$name},")
            ->line('You requested a password reset. Use this token in the mobile app:')
            ->line("**{$this->token}**")
            ->line('This token expires in 60 minutes.')
            ->line('If you did not request a reset, you can ignore this email.');
    }
}
