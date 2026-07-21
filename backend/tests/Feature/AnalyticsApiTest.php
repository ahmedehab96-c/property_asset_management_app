<?php

namespace Tests\Feature;

use App\Models\Property;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class AnalyticsApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_overview_requires_authentication(): void
    {
        $this->getJson('/api/v1/analytics/overview')->assertUnauthorized();
    }

    public function test_overview_returns_portfolio_metrics(): void
    {
        Sanctum::actingAs(User::factory()->create());

        Property::query()->create([
            'name' => 'Test Apt',
            'type' => 'apartment',
            'location' => 'Dubai',
            'status' => 'occupied',
            'monthly_revenue' => 8500,
        ]);

        Property::query()->create([
            'name' => 'Empty Unit',
            'type' => 'apartment',
            'location' => 'Dubai',
            'status' => 'available',
            'monthly_revenue' => 0,
        ]);

        $response = $this->getJson('/api/v1/analytics/overview');

        $response->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.properties_count', 2)
            ->assertJsonPath('data.occupied_count', 1)
            ->assertJsonPath('data.available_count', 1)
            ->assertJsonPath('data.occupancy_rate', 50)
            ->assertJsonPath('data.monthly_revenue', 8500);
    }

    public function test_revenue_and_occupancy_endpoints(): void
    {
        Sanctum::actingAs(User::factory()->create());

        $this->getJson('/api/v1/analytics/revenue')
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonStructure(['data' => ['months', 'total']]);

        $this->getJson('/api/v1/analytics/occupancy')
            ->assertOk()
            ->assertJsonPath('success', true);
    }
}
