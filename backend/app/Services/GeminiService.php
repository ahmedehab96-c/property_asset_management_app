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

        $json = $this->post($payload);
        if ($json === null) {
            return null;
        }

        $text = data_get($json, 'candidates.0.content.parts.0.text');

        return is_string($text) && trim($text) !== '' ? trim($text) : null;
    }

    /**
     * One function-calling turn. Returns the first candidate's content parts
     * (text and/or functionCall entries), or null when the provider fails.
     *
     * @param  list<array{role: string, parts: list<array<string, mixed>>}>  $contents
     * @param  list<array<string, mixed>>  $functionDeclarations
     * @return list<array<string, mixed>>|null
     */
    public function generateWithTools(
        array $contents,
        string $systemInstruction,
        array $functionDeclarations,
        array $generationConfig = [],
    ): ?array {
        if (! $this->isConfigured() || $contents === []) {
            return null;
        }

        $payload = [
            'contents' => $contents,
            'systemInstruction' => ['parts' => [['text' => $systemInstruction]]],
            'tools' => [['functionDeclarations' => $functionDeclarations]],
        ];

        if ($generationConfig !== []) {
            $payload['generationConfig'] = $generationConfig;
        }

        $parts = data_get($this->post($payload), 'candidates.0.content.parts');

        return is_array($parts) && $parts !== [] ? array_values($parts) : null;
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

    /**
     * @param  array<string, mixed>  $payload
     * @return array<string, mixed>|null
     */
    private function post(array $payload): ?array
    {
        $url = sprintf('%s/models/%s:generateContent', $this->baseUrl(), $this->model());

        try {
            // Key goes in a header, not the query string, so it never lands in logged URLs.
            $response = Http::timeout((int) config('services.gemini.timeout', 60))
                ->withHeaders(['x-goog-api-key' => (string) config('services.gemini.key')])
                ->post($url, $payload);
        } catch (ConnectionException $exception) {
            Log::warning('Gemini connection failed', ['error' => $exception->getMessage()]);

            return null;
        }

        if (! $response->successful()) {
            // Body is not logged: it can echo user content back.
            Log::warning('Gemini API error', ['status' => $response->status()]);

            return null;
        }

        $json = $response->json();

        return is_array($json) ? $json : null;
    }

    private function model(): string
    {
        return (string) config('services.gemini.model', 'gemini-3.1-flash-lite');
    }

    private function baseUrl(): string
    {
        return rtrim((string) config('services.gemini.base_url', 'https://generativelanguage.googleapis.com/v1beta'), '/');
    }
}
