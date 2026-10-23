<?php

namespace Tests\Feature;

use App\Jobs\ProcessWhatsAppMessage;
use App\Models\AiConversation;
use App\Models\AiPendingAction;
use App\Models\MaintenanceRequest;
use App\Models\Property;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\Client\Request as HttpRequest;
use Illuminate\Support\Facades\Bus;
use Illuminate\Support\Facades\Http;
use Tests\TestCase;

class WhatsAppWebhookTest extends TestCase
{
    use RefreshDatabase;

    private const URL = '/api/v1/whatsapp/webhook';

    protected function setUp(): void
    {
        parent::setUp();

        config([
            'services.gemini.key' => 'test-key',
            'services.whatsapp.token' => 'wa-token',
            'services.whatsapp.phone_number_id' => '555',
            'services.whatsapp.app_secret' => 'secret',
            'services.whatsapp.verify_token' => 'verify-me',
        ]);
    }

    public function test_verification_handshake(): void
    {
        $this->get(self::URL.'?hub.mode=subscribe&hub.verify_token=verify-me&hub.challenge=42')
            ->assertOk()
            ->assertSeeText('42');

        $this->get(self::URL.'?hub.mode=subscribe&hub.verify_token=wrong&hub.challenge=42')
            ->assertForbidden();
    }

    public function test_webhook_is_disabled_until_configured(): void
    {
        config(['services.whatsapp.token' => null]);

        $this->get(self::URL.'?hub.mode=subscribe&hub.verify_token=verify-me&hub.challenge=1')->assertNotFound();
        $this->signedPost($this->textPayload('971500000001', 'hi'))->assertNotFound();
    }

    public function test_rejects_bad_signature(): void
    {
        Http::fake();

        $this->postJson(self::URL, $this->textPayload('971500000001', 'hi'), ['X-Hub-Signature-256' => 'sha256=forged'])
            ->assertForbidden();

        Http::assertNothingSent();
    }

    public function test_unknown_number_gets_refusal_and_no_data(): void
    {
        User::factory()->create(['phone' => '+971500000001']);
        Http::fake(['graph.facebook.com/*' => Http::response(['messages' => [['id' => 'x']]])]);

        // Same last 7 digits, different country code: must not match.
        $this->signedPost($this->textPayload('966500000001', 'كم عدد العقارات؟'))->assertOk();

        Http::assertSentCount(1);
        Http::assertSent(fn (HttpRequest $request) => str_contains($request->url(), 'graph.facebook.com')
            && $request['to'] === '966500000001'
            && str_contains($request['text']['body'], 'غير مرتبط'));
        $this->assertDatabaseCount('ai_conversations', 0);
    }

    public function test_registered_user_gets_agent_reply(): void
    {
        $user = User::factory()->create(['phone' => '+971 50 000 0001']);
        Property::query()->create(['name' => 'Marina Tower', 'status' => 'available']);

        Http::fake([
            'generativelanguage.googleapis.com/*' => Http::sequence()
                ->push($this->geminiCall('search_properties', ['status' => 'available']))
                ->push($this->geminiText('**Marina Tower** is available.')),
            'graph.facebook.com/*' => Http::response(['messages' => [['id' => 'x']]]),
        ]);

        $this->signedPost($this->textPayload('971500000001', 'Which properties are available?'))->assertOk();

        Http::assertSent(fn (HttpRequest $request) => str_contains($request->url(), 'graph.facebook.com/v23.0/555/messages')
            && $request->hasHeader('Authorization', 'Bearer wa-token')
            && $request['to'] === '971500000001'
            && $request['text']['body'] === '*Marina Tower* is available.');

        $conversation = AiConversation::query()->where('user_id', $user->id)->sole();
        $this->assertSame('whatsapp', $conversation->channel);
        $this->assertSame(2, $conversation->messages()->count());
    }

    public function test_redelivered_message_is_answered_once(): void
    {
        Bus::fake([ProcessWhatsAppMessage::class]);

        $payload = $this->textPayload('971500000001', 'hello', 'wamid.SAME');
        $this->signedPost($payload)->assertOk();
        $this->signedPost($payload)->assertOk();

        Bus::assertDispatchedAfterResponseTimes(ProcessWhatsAppMessage::class, 1);
    }

    public function test_write_needs_button_confirmation_and_runs_once(): void
    {
        $user = User::factory()->create(['phone' => '+971500000001']);
        $property = Property::query()->create(['name' => 'Palm Villa']);

        Http::fake([
            'generativelanguage.googleapis.com/*' => Http::response($this->geminiCall('create_maintenance_request', ['property_id' => $property->id, 'title' => 'تسريب مكيف'])),
            'graph.facebook.com/*' => Http::response([]),
        ]);

        $this->signedPost($this->textPayload('971500000001', 'افتح طلب صيانة تسريب مكيف'))->assertOk();

        $action = AiPendingAction::query()->where('user_id', $user->id)->sole();
        $this->assertSame(0, MaintenanceRequest::query()->count());

        Http::assertSent(fn (HttpRequest $request) => ($request['type'] ?? null) === 'interactive'
            && $request['interactive']['action']['buttons'][0]['reply']['id'] === "confirm:{$action->id}"
            && $request['interactive']['action']['buttons'][0]['reply']['title'] === 'تأكيد');

        $this->signedPost($this->buttonPayload('971500000001', "confirm:{$action->id}", 'wamid.B1'))->assertOk();
        $this->signedPost($this->buttonPayload('971500000001', "confirm:{$action->id}", 'wamid.B2'))->assertOk();

        $this->assertSame(1, MaintenanceRequest::query()->count());
        $this->assertSame('executed', $action->fresh()->status);
    }

    public function test_cannot_confirm_another_users_action(): void
    {
        $owner = User::factory()->create(['phone' => '+971500000001']);
        User::factory()->create(['phone' => '+971500000002']);
        $property = Property::query()->create(['name' => 'Palm Villa']);
        $conversation = AiConversation::query()->create(['user_id' => $owner->id, 'title' => 't']);
        $action = AiPendingAction::query()->create([
            'user_id' => $owner->id,
            'ai_conversation_id' => $conversation->id,
            'tool' => 'create_maintenance_request',
            'arguments' => ['property_id' => $property->id, 'title' => 'Leak'],
            'status' => 'pending',
            'expires_at' => now()->addMinutes(30),
        ]);
        Http::fake();

        $this->signedPost($this->buttonPayload('971500000002', "confirm:{$action->id}"))->assertOk();

        $this->assertSame('pending', $action->fresh()->status);
        $this->assertSame(0, MaintenanceRequest::query()->count());
    }

    public function test_non_text_messages_get_a_text_only_notice(): void
    {
        User::factory()->create(['phone' => '+971500000001']);
        Http::fake(['graph.facebook.com/*' => Http::response([])]);

        $payload = $this->textPayload('971500000001', '');
        $payload['entry'][0]['changes'][0]['value']['messages'][0] = ['id' => 'wamid.IMG', 'from' => '971500000001', 'type' => 'image'];

        $this->signedPost($payload)->assertOk();

        Http::assertSentCount(1);
        Http::assertSent(fn (HttpRequest $request) => str_contains($request['text']['body'], 'النصية فقط'));
    }

    private function signedPost(array $payload)
    {
        $body = json_encode($payload);

        return $this->call('POST', self::URL, [], [], [], [
            'CONTENT_TYPE' => 'application/json',
            'HTTP_ACCEPT' => 'application/json',
            'HTTP_X_HUB_SIGNATURE_256' => 'sha256='.hash_hmac('sha256', $body, 'secret'),
        ], $body);
    }

    private function textPayload(string $from, string $text, ?string $id = null): array
    {
        return $this->envelope(['id' => $id ?? 'wamid.'.uniqid(), 'from' => $from, 'type' => 'text', 'text' => ['body' => $text]]);
    }

    private function buttonPayload(string $from, string $buttonId, ?string $id = null): array
    {
        return $this->envelope([
            'id' => $id ?? 'wamid.'.uniqid(),
            'from' => $from,
            'type' => 'interactive',
            'interactive' => ['type' => 'button_reply', 'button_reply' => ['id' => $buttonId, 'title' => 'x']],
        ]);
    }

    private function envelope(array $message): array
    {
        return ['object' => 'whatsapp_business_account', 'entry' => [['changes' => [['field' => 'messages', 'value' => ['messages' => [$message]]]]]]];
    }

    private function geminiCall(string $name, array $args): array
    {
        return ['candidates' => [['content' => ['role' => 'model', 'parts' => [['functionCall' => ['name' => $name, 'args' => $args]]]]]]];
    }

    private function geminiText(string $text): array
    {
        return ['candidates' => [['content' => ['role' => 'model', 'parts' => [['text' => $text]]]]]];
    }
}
