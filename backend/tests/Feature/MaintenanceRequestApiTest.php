<?php

namespace Tests\Feature;

use App\Models\MaintenanceRequest;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class MaintenanceRequestApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_index_requires_authentication(): void
    {
        $this->getJson('/api/v1/maintenance-requests')->assertUnauthorized();
    }

    public function test_can_create_and_list_maintenance_requests(): void
    {
        Sanctum::actingAs(User::factory()->create());

        $create = $this->postJson('/api/v1/maintenance-requests', [
            'title' => 'AC not cooling',
            'problem_type' => 'hvac',
            'description' => 'Unit 12 needs service',
            'priority' => 'high',
            'status' => 'open',
        ]);

        $create->assertCreated()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.title', 'AC not cooling')
            ->assertJsonStructure(['data' => ['id', 'order_number', 'title']]);

        $this->assertDatabaseHas('maintenance_requests', [
            'title' => 'AC not cooling',
            'problem_type' => 'hvac',
        ]);

        $list = $this->getJson('/api/v1/maintenance-requests');

        $list->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.meta.total', 1);
    }

    public function test_can_show_existing_request(): void
    {
        Sanctum::actingAs(User::factory()->create());

        $item = MaintenanceRequest::query()->create([
            'order_number' => 'MR-TEST01',
            'title' => 'Leak',
            'problem_type' => 'plumbing',
            'status' => 'open',
            'priority' => 'medium',
        ]);

        $this->getJson("/api/v1/maintenance-requests/{$item->id}")
            ->assertOk()
            ->assertJsonPath('data.id', $item->id)
            ->assertJsonPath('data.title', 'Leak');
    }
}
