<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Task;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class TaskController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = Task::query()->with(['assignee', 'property'])->latest();

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
            'assigned_to' => ['nullable', 'exists:users,id'],
            'property_id' => ['nullable', 'exists:properties,id'],
            'title' => ['required', 'string', 'max:255'],
            'description' => ['nullable', 'string'],
            'status' => ['nullable', 'string', 'max:50'],
            'priority' => ['nullable', 'string', 'max:50'],
            'due_date' => ['nullable', 'date'],
        ]);

        $task = Task::query()->create($data);

        return ApiResponse::success($task->load(['assignee', 'property'])->toApiArray(), 'Created', 201);
    }

    public function show(Task $task): JsonResponse
    {
        return ApiResponse::success($task->load(['assignee', 'property'])->toApiArray());
    }

    public function update(Request $request, Task $task): JsonResponse
    {
        $data = $request->validate([
            'assigned_to' => ['nullable', 'exists:users,id'],
            'property_id' => ['nullable', 'exists:properties,id'],
            'title' => ['sometimes', 'string', 'max:255'],
            'description' => ['nullable', 'string'],
            'status' => ['nullable', 'string', 'max:50'],
            'priority' => ['nullable', 'string', 'max:50'],
            'due_date' => ['nullable', 'date'],
        ]);

        $task->update($data);

        return ApiResponse::success($task->fresh(['assignee', 'property'])->toApiArray(), 'Updated');
    }

    public function updateStatus(Request $request, Task $task): JsonResponse
    {
        $data = $request->validate([
            'status' => ['required', 'string', 'max:50'],
        ]);

        $task->update(['status' => $data['status']]);

        return ApiResponse::success($task->fresh()->toApiArray(), 'Status updated');
    }

    public function destroy(Task $task): JsonResponse
    {
        $task->delete();

        return ApiResponse::success(null, 'Deleted');
    }
}
