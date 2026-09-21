<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\AppNotification;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $items = AppNotification::query()
            ->where('user_id', $request->user()->id)
            ->latest()
            ->paginate((int) $request->input('per_page', 30));

        return ApiResponse::paginated($items);
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'user_id' => ['required', 'exists:users,id'],
            'title' => ['required', 'string', 'max:255'],
            'title_ar' => ['nullable', 'string', 'max:255'],
            'message' => ['nullable', 'string'],
            'message_ar' => ['nullable', 'string'],
            'type' => ['nullable', 'string', 'max:50'],
            'read_at' => ['nullable', 'date'],
        ]);

        $notification = AppNotification::query()->create($data);

        return ApiResponse::success($notification->toApiArray(), 'Notification created', 201);
    }

    public function show(AppNotification $notification): JsonResponse
    {
        return ApiResponse::success($notification->toApiArray());
    }

    public function update(Request $request, AppNotification $notification): JsonResponse
    {
        $data = $request->validate([
            'user_id' => ['sometimes', 'exists:users,id'],
            'title' => ['sometimes', 'string', 'max:255'],
            'title_ar' => ['nullable', 'string', 'max:255'],
            'message' => ['nullable', 'string'],
            'message_ar' => ['nullable', 'string'],
            'type' => ['nullable', 'string', 'max:50'],
            'read_at' => ['nullable', 'date'],
        ]);

        $notification->update($data);

        return ApiResponse::success($notification->fresh()->toApiArray(), 'Notification updated');
    }

    public function unread(Request $request): JsonResponse
    {
        $items = AppNotification::query()
            ->where('user_id', $request->user()->id)
            ->whereNull('read_at')
            ->latest()
            ->get()
            ->map->toApiArray();

        return ApiResponse::success($items);
    }

    public function markRead(Request $request, int $id): JsonResponse
    {
        $notification = AppNotification::query()
            ->where('user_id', $request->user()->id)
            ->whereKey($id)
            ->firstOrFail();

        $notification->update(['read_at' => now()]);

        return ApiResponse::success($notification->toApiArray(), 'Marked as read');
    }

    public function markAllRead(Request $request): JsonResponse
    {
        AppNotification::query()
            ->where('user_id', $request->user()->id)
            ->whereNull('read_at')
            ->update(['read_at' => now()]);

        return ApiResponse::success(null, 'All marked as read');
    }

    public function destroy(Request $request, int $id): JsonResponse
    {
        AppNotification::query()
            ->where('user_id', $request->user()->id)
            ->whereKey($id)
            ->delete();

        return ApiResponse::success(null, 'Notification deleted');
    }
}
