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
