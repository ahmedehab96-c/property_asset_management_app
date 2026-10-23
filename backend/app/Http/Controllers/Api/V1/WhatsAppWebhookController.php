<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Jobs\ProcessWhatsAppMessage;
use App\Services\WhatsAppService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Cache;

/** Public endpoint called by Meta. Authenticated by the app-secret signature, not by Sanctum. */
class WhatsAppWebhookController extends Controller
{
    public function __construct(private readonly WhatsAppService $whatsapp) {}

    /** One-time subscription handshake from the Meta dashboard. */
    public function verify(Request $request): Response
    {
        abort_unless($this->whatsapp->isConfigured(), 404);

        $valid = $request->query('hub_mode') === 'subscribe'
            && hash_equals((string) config('services.whatsapp.verify_token'), (string) $request->query('hub_verify_token'));

        abort_unless($valid, 403);

        return response((string) $request->query('hub_challenge'), 200, ['Content-Type' => 'text/plain']);
    }

    public function receive(Request $request): JsonResponse
    {
        abort_unless($this->whatsapp->isConfigured(), 404);
        abort_unless($this->whatsapp->hasValidSignature($request->getContent(), $request->header('X-Hub-Signature-256')), 403);

        foreach ((array) $request->input('entry', []) as $entry) {
            foreach ((array) ($entry['changes'] ?? []) as $change) {
                foreach ((array) data_get($change, 'value.messages', []) as $message) {
                    $this->handle((array) $message);
                }
            }
        }

        return response()->json(['received' => true]);
    }

    /**
     * @param  array<string, mixed>  $message
     */
    private function handle(array $message): void
    {
        $id = (string) ($message['id'] ?? '');
        $from = (string) ($message['from'] ?? '');

        // Meta redelivers on slow or failed responses; answer each message once.
        if ($id === '' || $from === '' || ! Cache::add('wa-msg:'.$id, true, now()->addDay())) {
            return;
        }

        $type = $message['type'] ?? null;

        ProcessWhatsAppMessage::dispatch(
            $from,
            $type === 'text' ? (string) data_get($message, 'text.body', '') : null,
            $type === 'interactive' ? data_get($message, 'interactive.button_reply.id') : null,
        )->afterResponse();
    }
}
