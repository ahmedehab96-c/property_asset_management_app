<?php

namespace App\Services;

use Illuminate\Http\Client\ConnectionException;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

/** Thin client for the WhatsApp Cloud API (Meta Graph). */
class WhatsAppService
{
    public function isConfigured(): bool
    {
        foreach (['token', 'phone_number_id', 'app_secret', 'verify_token'] as $key) {
            if (blank(config("services.whatsapp.{$key}"))) {
                return false;
            }
        }

        return true;
    }

    /** Checks Meta's X-Hub-Signature-256 header against the raw request body. */
    public function hasValidSignature(string $payload, ?string $header): bool
    {
        if ($header === null || ! str_starts_with($header, 'sha256=')) {
            return false;
        }

        $expected = 'sha256='.hash_hmac('sha256', $payload, (string) config('services.whatsapp.app_secret'));

        return hash_equals($expected, $header);
    }

    public function sendText(string $to, string $text): bool
    {
        return $this->send($to, [
            'type' => 'text',
            'text' => ['preview_url' => false, 'body' => mb_substr($this->format($text), 0, 4096)],
        ]);
    }

    /**
     * @param  array<string, string>  $buttons  id => title (max 3, titles max 20 chars)
     */
    public function sendButtons(string $to, string $text, array $buttons): bool
    {
        $rows = [];
        foreach (array_slice($buttons, 0, 3, true) as $id => $title) {
            $rows[] = ['type' => 'reply', 'reply' => ['id' => (string) $id, 'title' => mb_substr($title, 0, 20)]];
        }

        return $this->send($to, [
            'type' => 'interactive',
            'interactive' => [
                'type' => 'button',
                'body' => ['text' => mb_substr($this->format($text), 0, 1024)],
                'action' => ['buttons' => $rows],
            ],
        ]);
    }

    /**
     * @param  array<string, mixed>  $message
     */
    private function send(string $to, array $message): bool
    {
        $url = sprintf(
            'https://graph.facebook.com/%s/%s/messages',
            config('services.whatsapp.graph_version', 'v23.0'),
            config('services.whatsapp.phone_number_id'),
        );

        try {
            $response = Http::timeout(20)
                ->withToken((string) config('services.whatsapp.token'))
                ->post($url, ['messaging_product' => 'whatsapp', 'to' => $to] + $message);
        } catch (ConnectionException $exception) {
            Log::warning('WhatsApp send failed', ['error' => $exception->getMessage()]);

            return false;
        }

        if (! $response->successful()) {
            Log::warning('WhatsApp API error', ['status' => $response->status(), 'code' => $response->json('error.code')]);

            return false;
        }

        return true;
    }

    /** WhatsApp bold is *text*, not Markdown's **text**. */
    private function format(string $text): string
    {
        return str_replace('**', '*', $text);
    }
}
