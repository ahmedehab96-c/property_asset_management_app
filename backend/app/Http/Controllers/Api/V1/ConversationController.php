<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Conversation;
use App\Models\Message;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ConversationController extends Controller
{
    public function index(): JsonResponse
    {
        $items = Conversation::query()
            ->with(['owner', 'tenant'])
            ->latest('last_message_at')
            ->latest()
            ->get()
            ->map->toApiArray();

        return ApiResponse::success([
            'items' => $items,
            'data' => $items,
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'subject' => ['nullable', 'string', 'max:255'],
            'owner_id' => ['nullable', 'exists:owners,id'],
            'tenant_id' => ['nullable', 'exists:tenants,id'],
            'body' => ['nullable', 'string'],
        ]);

        $conversation = Conversation::query()->create([
            'subject' => $data['subject'] ?? 'Conversation',
            'owner_id' => $data['owner_id'] ?? null,
            'tenant_id' => $data['tenant_id'] ?? null,
            'last_message_at' => now(),
        ]);

        if (! empty($data['body'])) {
            Message::query()->create([
                'conversation_id' => $conversation->id,
                'user_id' => $request->user()->id,
                'body' => $data['body'],
                'is_from_admin' => (bool) $request->user()->is_admin,
            ]);
        }

        return ApiResponse::success($conversation->fresh(['owner', 'tenant'])->toApiArray(), 'Created', 201);
    }

    public function messages(Conversation $conversation): JsonResponse
    {
        $items = $conversation->messages()->with('user')->oldest()->get()->map->toApiArray();

        return ApiResponse::success($items);
    }

    public function storeMessage(Request $request, Conversation $conversation): JsonResponse
    {
        $data = $request->validate([
            'body' => ['required', 'string'],
        ]);

        $message = Message::query()->create([
            'conversation_id' => $conversation->id,
            'user_id' => $request->user()->id,
            'body' => $data['body'],
            'is_from_admin' => (bool) $request->user()->is_admin,
        ]);

        $conversation->update(['last_message_at' => now()]);

        return ApiResponse::success($message->load('user')->toApiArray(), 'Sent', 201);
    }
}
