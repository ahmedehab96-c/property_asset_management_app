<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Project;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ProjectController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = Project::query()->with(['owner', 'property'])->latest();

        if ($status = $request->string('status')->toString()) {
            $query->where('status', $status);
        }

        $items = $query->paginate((int) $request->input('per_page', 20));

        return ApiResponse::success([
            'items' => $items->getCollection()->map->toApiArray()->values(),
            'data' => $items->getCollection()->map->toApiArray()->values(),
            'meta' => [
                'current_page' => $items->currentPage(),
                'last_page' => $items->lastPage(),
                'total' => $items->total(),
            ],
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'owner_id' => ['nullable', 'exists:owners,id'],
            'property_id' => ['nullable', 'exists:properties,id'],
            'name' => ['required', 'string', 'max:255'],
            'location' => ['nullable', 'string', 'max:255'],
            'status' => ['nullable', 'string', 'max:50'],
            'progress' => ['nullable', 'numeric'],
            'budget' => ['nullable', 'numeric'],
            'paid_amount' => ['nullable', 'numeric'],
            'start_date' => ['nullable', 'date'],
            'end_date' => ['nullable', 'date'],
            'description' => ['nullable', 'string'],
        ]);

        $project = Project::query()->create($data);

        return ApiResponse::success($project->toApiArray(), 'Created', 201);
    }

    public function show(Project $project): JsonResponse
    {
        return ApiResponse::success($project->load(['owner', 'property'])->toApiArray());
    }

    public function update(Request $request, Project $project): JsonResponse
    {
        $data = $request->validate([
            'owner_id' => ['nullable', 'exists:owners,id'],
            'property_id' => ['nullable', 'exists:properties,id'],
            'name' => ['sometimes', 'string', 'max:255'],
            'location' => ['nullable', 'string', 'max:255'],
            'status' => ['nullable', 'string', 'max:50'],
            'progress' => ['nullable', 'numeric'],
            'budget' => ['nullable', 'numeric'],
            'paid_amount' => ['nullable', 'numeric'],
            'start_date' => ['nullable', 'date'],
            'end_date' => ['nullable', 'date'],
            'description' => ['nullable', 'string'],
        ]);

        $project->update($data);

        return ApiResponse::success($project->fresh()->toApiArray(), 'Updated');
    }

    public function destroy(Project $project): JsonResponse
    {
        $project->delete();

        return ApiResponse::success(null, 'Deleted');
    }
}
