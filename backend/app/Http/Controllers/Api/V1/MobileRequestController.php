<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\MobileRequest;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class MobileRequestController extends Controller
{
    public function index(): JsonResponse
    {
        $items = MobileRequest::query()->latest()->get()->map->toApiArray();

        return ApiResponse::success($items);
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'type' => ['nullable', 'string', 'max:50'],
            'title' => ['nullable', 'string', 'max:255'],
            'description' => ['nullable', 'string'],
            'payload' => ['nullable', 'array'],
            'attachments' => ['nullable', 'array'],
        ]);

        $item = MobileRequest::query()->create([
            'user_id' => $request->user()->id,
            'type' => $data['type'] ?? 'service',
            'title' => $data['title'] ?? null,
            'description' => $data['description'] ?? null,
            'payload' => $data['payload'] ?? $request->except(['type', 'title', 'description', 'attachments']),
            'attachments' => $data['attachments'] ?? [],
            'status' => 'pending',
        ]);

        return ApiResponse::success($item->toApiArray(), 'Submitted', 201);
    }

    public function show(MobileRequest $mobileRequest): JsonResponse
    {
        return ApiResponse::success($mobileRequest->toApiArray());
    }

    public function update(Request $request, MobileRequest $mobileRequest): JsonResponse
    {
        $data = $request->validate([
            'type' => ['nullable', 'string', 'max:50'],
            'title' => ['nullable', 'string', 'max:255'],
            'description' => ['nullable', 'string'],
            'status' => ['nullable', 'string', 'max:50'],
            'payload' => ['nullable', 'array'],
            'attachments' => ['nullable', 'array'],
        ]);

        $mobileRequest->update($data);

        return ApiResponse::success($mobileRequest->fresh()->toApiArray(), 'Updated');
    }

    public function destroy(MobileRequest $mobileRequest): JsonResponse
    {
        $mobileRequest->delete();

        return ApiResponse::success(null, 'Deleted');
    }
}
