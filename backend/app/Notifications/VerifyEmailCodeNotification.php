<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class VerifyEmailCodeNotification extends Notification
{
    use Queueable;

    public function __construct(public readonly string $code) {}

    public function via(object $notifiable): array
    {
        return ['mail'];
    }

    public function toMail(object $notifiable): MailMessage
    {
        $name = $notifiable->name ?? 'User';

        return (new MailMessage)
            ->subject('Email verification code')
            ->greeting("Hello {$name},")
            ->line('Use this code to verify your email address:')
            ->line("**{$this->code}**")
            ->line('This code expires in 30 minutes.')
            ->line('If you did not create an account, you can ignore this email.');
    }
}
