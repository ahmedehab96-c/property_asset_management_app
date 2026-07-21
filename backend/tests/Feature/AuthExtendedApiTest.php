<?php

namespace Tests\Feature;

use App\Models\User;
use App\Notifications\ResetPasswordTokenNotification;
use App\Notifications\VerifyEmailCodeNotification;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Notification;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class AuthExtendedApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_register_returns_verification_code_in_testing(): void
    {
        Notification::fake();

        $response = $this->postJson('/api/v1/auth/register', [
            'name' => 'New Owner',
            'email' => 'owner@example.com',
            'password' => 'password',
            'password_confirmation' => 'password',
        ]);

        $response->assertCreated()
            ->assertJsonPath('success', true)
            ->assertJsonStructure(['data' => ['token', 'verification_code', 'user']]);

        $code = $response->json('data.verification_code');
        $this->assertNotEmpty($code);

        Notification::assertSentTo(
            User::query()->where('email', 'owner@example.com')->first(),
            VerifyEmailCodeNotification::class,
            fn (VerifyEmailCodeNotification $n) => $n->code === $code
        );

        Sanctum::actingAs(User::query()->where('email', 'owner@example.com')->first());

        $this->postJson('/api/v1/auth/verify-email', ['token' => $code])
            ->assertOk()
            ->assertJsonPath('success', true);

        $this->assertNotNull(
            User::query()->where('email', 'owner@example.com')->value('email_verified_at')
        );
    }

    public function test_resend_verification_issues_new_code(): void
    {
        Notification::fake();

        $user = User::factory()->create(['email_verified_at' => null]);
        Sanctum::actingAs($user);

        $response = $this->postJson('/api/v1/auth/email/resend-verification');

        $response->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonStructure(['data' => ['verification_code']]);

        $this->assertEquals(
            $response->json('data.verification_code'),
            Cache::get('email_verify:'.$user->id)
        );

        Notification::assertSentTo($user, VerifyEmailCodeNotification::class);
    }

    public function test_forgot_and_reset_password_flow(): void
    {
        Notification::fake();

        $user = User::factory()->create([
            'email' => 'reset@example.com',
            'password' => 'password',
        ]);

        $forgot = $this->postJson('/api/v1/auth/forgot-password', [
            'email' => 'reset@example.com',
        ]);

        $forgot->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonStructure(['data' => ['reset_token']]);

        $token = $forgot->json('data.reset_token');

        Notification::assertSentTo(
            $user,
            ResetPasswordTokenNotification::class,
            fn (ResetPasswordTokenNotification $n) => $n->token === $token
        );

        $this->postJson('/api/v1/auth/reset-password', [
            'email' => 'reset@example.com',
            'token' => $token,
            'password' => 'new-password',
            'password_confirmation' => 'new-password',
        ])->assertOk();

        $this->postJson('/api/v1/auth/login', [
            'email' => 'reset@example.com',
            'password' => 'password',
        ])->assertStatus(422);

        $this->postJson('/api/v1/auth/login', [
            'email' => 'reset@example.com',
            'password' => 'new-password',
        ])->assertOk()->assertJsonPath('success', true);
    }

    public function test_two_factor_toggle(): void
    {
        $user = User::factory()->create(['two_factor_enabled' => false]);
        Sanctum::actingAs($user);

        $this->putJson('/api/v1/auth/two-factor', ['enabled' => true])
            ->assertOk()
            ->assertJsonPath('data.two_factor_enabled', true);

        $this->assertTrue((bool) $user->fresh()->two_factor_enabled);
    }
}
