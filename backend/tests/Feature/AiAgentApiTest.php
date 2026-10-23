<?php

namespace Tests\Feature;

use App\Models\AiConversation;
use App\Models\AiPendingAction;
use App\Models\MaintenanceRequest;
use App\Models\Property;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\Client\Request as HttpRequest;
use Illuminate\Support\Facades\Http;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class AiAgentApiTest extends TestCase
{
    use RefreshDatabase;

    private const GEMINI = 'generativelanguage.googleapis.com/*';

    protected function setUp(): void
    {
        parent::setUp();
        config(['services.gemini.key' => 'test-key']);
    }

    public function test_agent_requires_auth(): void
    {
        $this->postJson('/api/v1/ai/agent/chat', ['message' => 'hi'])->assertUnauthorized();
        $this->getJson('/api/v1/ai/agent/conversations')->assertUnauthorized();
    }

    public function test_returns_503_when_gemini_not_configured_and_stores_nothing(): void
    {
        Sanctum::actingAs(User::factory()->create());
        config(['services.gemini.key' => null]);
        Http::fake();

        $this->postJson('/api/v1/ai/agent/chat', ['message' => 'hello', 'locale' => 'en'])
            ->assertStatus(503)
            ->assertJsonPath('success', false)
            ->assertJsonPath('errors.code', 'not_configured');

        Http::assertNothingSent();
        $this->assertDatabaseCount('ai_conversations', 0);
    }

    public function test_returns_503_when_provider_fails(): void
    {
        Sanctum::actingAs(User::factory()->create());
        Http::fake([self::GEMINI => Http::response(['error' => 'boom'], 500)]);

        $this->postJson('/api/v1/ai/agent/chat', ['message' => 'hello', 'locale' => 'en'])
            ->assertStatus(503)
            ->assertJsonPath('errors.code', 'provider_error');

        $this->assertDatabaseCount('ai_messages', 0);
    }

    public function test_read_tool_result_is_fed_back_to_the_model(): void
    {
        Sanctum::actingAs(User::factory()->create());
        Property::query()->create(['name' => 'Marina Tower', 'status' => 'available', 'monthly_revenue' => 9000]);

        Http::fakeSequence(self::GEMINI)
            ->push($this->functionCall('search_properties', ['query' => 'Marina'], 'call_1'))
            ->push($this->text('Marina Tower is available.'));

        $response = $this->postJson('/api/v1/ai/agent/chat', ['message' => 'Is Marina free?', 'locale' => 'en'])
            ->assertOk()
            ->assertJsonPath('data.message.content', 'Marina Tower is available.')
            ->assertJsonPath('data.message.actions.0.tool', 'search_properties')
            ->assertJsonPath('data.message.actions.0.status', 'completed')
            ->assertJsonPath('data.pending_action', null);

        Http::assertSentCount(2);
        Http::assertSent(function (HttpRequest $request) {
            $parts = data_get($request->data(), 'contents.2.parts.0.functionResponse');

            return $request->hasHeader('x-goog-api-key', 'test-key')
                && ($parts['id'] ?? null) === 'call_1'
                && ! str_contains($request->url(), 'key=')
                && ($parts['response']['properties'][0]['name'] ?? null) === 'Marina Tower';
        });

        $this->assertDatabaseCount('ai_messages', 2);
        $this->assertDatabaseHas('ai_conversations', ['id' => $response->json('data.conversation_id')]);
    }

    public function test_unknown_tools_and_invalid_arguments_are_rejected(): void
    {
        Sanctum::actingAs(User::factory()->create());

        Http::fakeSequence(self::GEMINI)
            ->push($this->functionCall('run_sql', ['sql' => 'DROP TABLE users']))
            ->push($this->functionCall('list_payments', ['status' => 'everything']))
            ->push($this->text('Sorry, I could not do that.'));

        $this->postJson('/api/v1/ai/agent/chat', ['message' => 'delete everything', 'locale' => 'en'])
            ->assertOk()
            ->assertJsonPath('data.message.actions.0.status', 'failed')
            ->assertJsonPath('data.message.actions.1.status', 'failed');

        Http::assertSent(fn (HttpRequest $request) => data_get($request->data(), 'contents.2.parts.0.functionResponse.response.error') === 'Unknown tool.');
        $this->assertDatabaseHas('users', ['id' => 1]);
    }

    public function test_write_tool_waits_for_confirmation_and_runs_once(): void
    {
        Sanctum::actingAs(User::factory()->create());
        $property = Property::query()->create(['name' => 'Palm Villa', 'status' => 'occupied']);

        Http::fakeSequence(self::GEMINI)
            ->push($this->functionCall('create_maintenance_request', ['property_id' => $property->id, 'title' => 'AC leaking', 'priority' => 'high']));

        $chat = $this->postJson('/api/v1/ai/agent/chat', ['message' => 'Open a ticket: AC leaking at Palm Villa', 'locale' => 'en'])
            ->assertOk()
            ->assertJsonPath('data.message.actions.0.status', 'pending_confirmation')
            ->assertJsonPath('data.pending_action.status', 'pending');

        Http::assertSentCount(1);
        $this->assertSame(0, MaintenanceRequest::query()->count());

        $actionId = $chat->json('data.pending_action.id');

        $this->postJson("/api/v1/ai/agent/actions/{$actionId}/confirm", ['locale' => 'en'])
            ->assertOk()
            ->assertJsonPath('data.status', 'executed')
            ->assertJsonPath('data.message.actions.0.status', 'completed');

        $this->assertDatabaseHas('maintenance_requests', ['property_id' => $property->id, 'title' => 'AC leaking', 'priority' => 'high']);

        $this->postJson("/api/v1/ai/agent/actions/{$actionId}/confirm", ['locale' => 'en'])
            ->assertStatus(409)
            ->assertJsonPath('errors.code', 'already_executed');

        $this->assertSame(1, MaintenanceRequest::query()->count());
    }

    public function test_cancel_and_expiry_never_create_records(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);
        $property = Property::query()->create(['name' => 'Palm Villa']);

        $cancelled = $this->pendingAction($user, $property->id);
        $this->postJson("/api/v1/ai/agent/actions/{$cancelled->id}/cancel", ['locale' => 'en'])
            ->assertOk()
            ->assertJsonPath('data.status', 'cancelled');

        $expired = $this->pendingAction($user, $property->id, now()->subMinute());
        $this->postJson("/api/v1/ai/agent/actions/{$expired->id}/confirm", ['locale' => 'en'])
            ->assertStatus(410)
            ->assertJsonPath('errors.code', 'expired');

        $this->assertSame('expired', $expired->fresh()->status);
        $this->assertSame(0, MaintenanceRequest::query()->count());
    }

    public function test_confirm_fails_safely_when_the_property_was_deleted(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);
        $property = Property::query()->create(['name' => 'Gone']);
        $action = $this->pendingAction($user, $property->id);
        $property->delete();

        $this->postJson("/api/v1/ai/agent/actions/{$action->id}/confirm")
            ->assertStatus(422)
            ->assertJsonPath('errors.code', 'invalid_arguments');

        $this->assertSame('failed', $action->fresh()->status);
    }

    public function test_users_cannot_reach_each_others_conversations_or_actions(): void
    {
        $owner = User::factory()->create();
        $property = Property::query()->create(['name' => 'Palm Villa']);
        $action = $this->pendingAction($owner, $property->id);
        $conversationId = $action->ai_conversation_id;

        Sanctum::actingAs(User::factory()->create());
        Http::fake();

        $this->getJson("/api/v1/ai/agent/conversations/{$conversationId}")->assertNotFound();
        $this->deleteJson("/api/v1/ai/agent/conversations/{$conversationId}")->assertNotFound();
        $this->postJson("/api/v1/ai/agent/actions/{$action->id}/confirm")->assertNotFound();
        $this->postJson('/api/v1/ai/agent/chat', ['message' => 'hi', 'conversation_id' => $conversationId])->assertNotFound();
        $this->getJson('/api/v1/ai/agent/conversations')->assertOk()->assertJsonCount(0, 'data');

        Http::assertNothingSent();
        $this->assertSame(0, MaintenanceRequest::query()->count());
        $this->assertSame('pending', $action->fresh()->status);
    }

    public function test_arabic_conversation_keeps_history_and_arabic_confirmation(): void
    {
        Sanctum::actingAs(User::factory()->create());
        $property = Property::query()->create(['name' => 'Palm Villa', 'name_ar' => 'فيلا النخلة']);

        Http::fakeSequence(self::GEMINI)
            ->push($this->text('أي عقار تقصد؟'))
            ->push($this->functionCall('create_maintenance_request', ['property_id' => $property->id, 'title' => 'تسريب مكيف']));

        $first = $this->postJson('/api/v1/ai/agent/chat', ['message' => 'افتح طلب صيانة للمكيف', 'locale' => 'ar'])
            ->assertOk()
            ->assertJsonPath('data.message.content', 'أي عقار تقصد؟');

        $second = $this->postJson('/api/v1/ai/agent/chat', [
            'message' => 'فيلا النخلة',
            'locale' => 'ar',
            'conversation_id' => $first->json('data.conversation_id'),
        ])->assertOk();

        $this->assertStringContainsString('فيلا النخلة', $second->json('data.pending_action.summary'));
        $this->assertStringContainsString('أحتاج تأكيدك', $second->json('data.message.content'));

        Http::assertSent(function (HttpRequest $request) {
            $contents = $request->data()['contents'];

            return count($contents) === 3
                && $contents[1]['role'] === 'model'
                && $contents[1]['parts'][0]['text'] === 'أي عقار تقصد؟'
                && str_contains($request->data()['systemInstruction']['parts'][0]['text'], 'default to Arabic');
        });

        $this->getJson('/api/v1/ai/agent/conversations/'.$first->json('data.conversation_id'))
            ->assertOk()
            ->assertJsonCount(4, 'data.messages')
            ->assertJsonCount(1, 'data.pending_actions');
    }

    public function test_message_length_is_limited(): void
    {
        Sanctum::actingAs(User::factory()->create());

        $this->postJson('/api/v1/ai/agent/chat', ['message' => str_repeat('a', 2001)])
            ->assertUnprocessable();
    }

    public function test_agent_is_rate_limited_per_user(): void
    {
        config(['services.gemini.agent.per_minute' => 2]);
        Sanctum::actingAs(User::factory()->create());
        Http::fake([self::GEMINI => Http::response($this->text('ok'))]);

        $this->postJson('/api/v1/ai/agent/chat', ['message' => 'a'])->assertOk();
        $this->postJson('/api/v1/ai/agent/chat', ['message' => 'b'])->assertOk();
        $this->postJson('/api/v1/ai/agent/chat', ['message' => 'c'])->assertStatus(429);
    }

    public function test_tool_loop_stops_at_max_steps(): void
    {
        config(['services.gemini.agent.max_steps' => 2]);
        Sanctum::actingAs(User::factory()->create());
        Http::fake([self::GEMINI => Http::response($this->functionCall('get_portfolio_summary', []))]);

        $this->postJson('/api/v1/ai/agent/chat', ['message' => 'loop', 'locale' => 'en'])
            ->assertOk()
            ->assertJsonPath('data.message.content', "I couldn't complete that request. Try rephrasing it more specifically.");

        Http::assertSentCount(2);
    }

    private function pendingAction(User $user, int $propertyId, $expiresAt = null): AiPendingAction
    {
        $conversation = AiConversation::query()->create(['user_id' => $user->id, 'title' => 't']);

        return AiPendingAction::query()->create([
            'user_id' => $user->id,
            'ai_conversation_id' => $conversation->id,
            'tool' => 'create_maintenance_request',
            'arguments' => ['property_id' => $propertyId, 'title' => 'Leak'],
            'expires_at' => $expiresAt ?? now()->addMinutes(30),
        ]);
    }

    private function functionCall(string $name, array $args, ?string $id = null): array
    {
        $call = array_filter(['id' => $id, 'name' => $name, 'args' => $args], fn ($value) => $value !== null);

        return ['candidates' => [['content' => ['role' => 'model', 'parts' => [['functionCall' => $call, 'thoughtSignature' => 'sig']]]]]];
    }

    private function text(string $text): array
    {
        return ['candidates' => [['content' => ['role' => 'model', 'parts' => [['text' => $text]]]]]];
    }
}
