<?php

namespace App\Services;

use Illuminate\Http\Client\ConnectionException;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class GeminiService
{
    public function isConfigured(): bool
    {
        $key = config('services.gemini.key');

        return is_string($key) && trim($key) !== '';
    }

    /**
     * @param  list<array{role: string, parts: list<array<string, mixed>>}>  $contents
     */
    public function generate(
        array $contents,
        ?string $systemInstruction = null,
        ?array $generationConfig = null,
    ): ?string {
        if (! $this->isConfigured() || $contents === []) {
            return null;
        }

        $payload = ['contents' => $contents];

        if ($systemInstruction !== null && trim($systemInstruction) !== '') {
            $payload['systemInstruction'] = [
                'parts' => [['text' => $systemInstruction]],
            ];
        }

        if ($generationConfig !== null) {
            $payload['generationConfig'] = $generationConfig;
        }

        $url = sprintf(
            '%s/models/%s:generateContent?key=%s',
            $this->baseUrl(),
            $this->model(),
            urlencode((string) config('services.gemini.key'))
        );

        try {
            $response = Http::timeout(60)->post($url, $payload);
        } catch (ConnectionException $exception) {
            Log::warning('Gemini connection failed', ['error' => $exception->getMessage()]);

            return null;
        }

        if (! $response->successful()) {
            Log::warning('Gemini API error', [
                'status' => $response->status(),
                'body' => $response->body(),
            ]);

            return null;
        }

        $text = data_get($response->json(), 'candidates.0.content.parts.0.text');

        return is_string($text) && trim($text) !== '' ? trim($text) : null;
    }

    /**
     * @param  list<array{role: string, content: string}>  $history
     */
    public function chat(string $systemInstruction, string $message, array $history = []): ?string
    {
        $contents = [];

        foreach ($history as $item) {
            if (! is_array($item)) {
                continue;
            }

            $role = ($item['role'] ?? '') === 'assistant' ? 'model' : 'user';
            $content = trim((string) ($item['content'] ?? ''));
            if ($content === '') {
                continue;
            }

            $contents[] = [
                'role' => $role,
                'parts' => [['text' => $content]],
            ];
        }

        $contents[] = [
            'role' => 'user',
            'parts' => [['text' => $message]],
        ];

        return $this->generate($contents, $systemInstruction, [
            'temperature' => (float) config('services.gemini.temperature', 0.7),
        ]);
    }

    /**
     * @param  list<array{mime_type: string, data: string}>  $images
     * @return array<string, mixed>|null
     */
    public function analyzeImages(string $prompt, array $images): ?array
    {
        if ($images === []) {
            return null;
        }

        $parts = [['text' => $prompt]];

        foreach ($images as $image) {
            $parts[] = [
                'inline_data' => [
                    'mime_type' => $image['mime_type'],
                    'data' => $image['data'],
                ],
            ];
        }

        $raw = $this->generate(
            [['role' => 'user', 'parts' => $parts]],
            null,
            [
                'temperature' => 0.2,
                'responseMimeType' => 'application/json',
            ]
        );

        if ($raw === null) {
            return null;
        }

        $decoded = json_decode($raw, true);

        return is_array($decoded) ? $decoded : null;
    }

    /**
     * @return array<string, mixed>|null
     */
    public function jsonPrompt(string $systemInstruction, string $userPrompt): ?array
    {
        $raw = $this->generate(
            [['role' => 'user', 'parts' => [['text' => $userPrompt]]]],
            $systemInstruction,
            [
                'temperature' => 0.4,
                'responseMimeType' => 'application/json',
            ]
        );

        if ($raw === null) {
            return null;
        }

        $decoded = json_decode($raw, true);

        return is_array($decoded) ? $decoded : null;
    }

    private function model(): string
    {
        return (string) config('services.gemini.model', 'gemini-2.0-flash');
    }

    private function baseUrl(): string
    {
        return rtrim((string) config('services.gemini.base_url', 'https://generativelanguage.googleapis.com/v1beta'), '/');
    }
}
