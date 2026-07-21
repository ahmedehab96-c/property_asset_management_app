<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class ImageAnalysisApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_image_analysis_requires_auth(): void
    {
        $this->postJson('/api/v1/analytics/image-analysis')->assertUnauthorized();
    }

    public function test_analyzes_uploaded_image_with_local_heuristics(): void
    {
        Storage::fake('public');
        Sanctum::actingAs(User::factory()->create());

        $file = UploadedFile::fake()->image('unit.jpg', 1600, 1200);

        $response = $this->post('/api/v1/analytics/image-analysis', [
            'files' => [$file],
        ], [
            'Accept' => 'application/json',
        ]);

        $response->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.provider', 'local_heuristics')
            ->assertJsonStructure([
                'data' => [
                    'overall',
                    'findings',
                    'meta',
                    'urls',
                ],
            ]);

        $this->assertNotEmpty($response->json('data.findings'));
    }
}
