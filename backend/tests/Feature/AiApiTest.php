<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Http;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class AiApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_ai_status_requires_auth(): void
    {
        $this->getJson('/api/v1/ai/status')->assertUnauthorized();
    }

    public function test_ai_status_reports_gemini_configuration(): void
    {
        Sanctum::actingAs(User::factory()->create());

        config(['services.gemini.key' => 'test-key']);

        $this->getJson('/api/v1/ai/status')
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.configured', true)
            ->assertJsonPath('data.provider', 'gemini');
    }

    public function test_ai_chat_uses_fallback_when_gemini_not_configured(): void
    {
        Sanctum::actingAs(User::factory()->create());

        config(['services.gemini.key' => null]);

        $this->postJson('/api/v1/ai/chat', [
            'message' => 'اكتب عقد إيجار',
            'locale' => 'ar',
        ])->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.provider', 'fallback')
            ->assertJsonStructure(['data' => ['reply', 'configured']]);
    }

    public function test_ai_chat_uses_gemini_when_configured(): void
    {
        Sanctum::actingAs(User::factory()->create());

        config([
            'services.gemini.key' => 'test-key',
            'services.gemini.model' => 'gemini-2.0-flash',
            'services.gemini.base_url' => 'https://generativelanguage.googleapis.com/v1beta',
        ]);

        Http::fake([
            'generativelanguage.googleapis.com/*' => Http::response([
                'candidates' => [
                    [
                        'content' => [
                            'parts' => [
                                ['text' => 'مرحباً، كيف يمكنني مساعدتك في إدارة عقاراتك؟'],
                            ],
                        ],
                    ],
                ],
            ], 200),
        ]);

        $this->postJson('/api/v1/ai/chat', [
            'message' => 'مرحباً',
            'locale' => 'ar',
        ])->assertOk()
            ->assertJsonPath('data.provider', 'gemini')
            ->assertJsonPath('data.reply', 'مرحباً، كيف يمكنني مساعدتك في إدارة عقاراتك؟');
    }

    public function test_market_analysis_returns_structured_payload(): void
    {
        Sanctum::actingAs(User::factory()->create());

        config(['services.gemini.key' => null]);

        $this->postJson('/api/v1/ai/market-analysis', [
            'city' => 'Dubai',
            'property_type' => 'Apartment',
            'locale' => 'en',
        ])->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonStructure([
                'data' => [
                    'provider',
                    'avg_rent',
                    'min_rent',
                    'max_rent',
                    'recommendations',
                ],
            ]);
    }
}
