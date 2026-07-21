<?php

namespace Tests\Feature;

use App\Models\Conversation;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class ConversationApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_can_create_conversation_and_send_message(): void
    {
        Sanctum::actingAs(User::factory()->create());

        $create = $this->postJson('/api/v1/conversations', [
            'subject' => 'Rent inquiry',
            'body' => 'Hello, is the unit available?',
        ]);

        $create->assertCreated()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.subject', 'Rent inquiry');

        $id = $create->json('data.id');
        $this->assertNotNull($id);

        $send = $this->postJson("/api/v1/conversations/{$id}/messages", [
            'body' => 'Following up on availability',
        ]);

        $send->assertCreated()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.body', 'Following up on availability');

        $this->getJson("/api/v1/conversations/{$id}/messages")
            ->assertOk()
            ->assertJsonPath('success', true);

        $this->assertDatabaseHas('messages', [
            'conversation_id' => $id,
            'body' => 'Following up on availability',
        ]);
    }

    public function test_messages_require_authentication(): void
    {
        $conversation = Conversation::query()->create([
            'subject' => 'Private',
            'last_message_at' => now(),
        ]);

        $this->postJson("/api/v1/conversations/{$conversation->id}/messages", [
            'body' => 'Nope',
        ])->assertUnauthorized();
    }
}
