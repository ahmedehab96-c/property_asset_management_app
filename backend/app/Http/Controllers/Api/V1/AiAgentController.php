<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\AiConversation;
use App\Models\AiPendingAction;
use App\Services\Agent\AgentActionException;
use App\Services\Agent\AgentService;
use App\Services\Agent\AgentUnavailableException;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/** Every lookup is scoped to the signed-in user; another user's ids return 404. */
class AiAgentController extends Controller
{
    public function __construct(private readonly AgentService $agent) {}

    public function chat(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'message' => ['required', 'string', 'max:2000'],
            'locale' => ['nullable', 'string', 'in:ar,en'],
            'conversation_id' => ['nullable', 'integer'],
        ]);

        $locale = $validated['locale'] ?? 'ar';
        $conversation = isset($validated['conversation_id'])
            ? $this->conversation($request, $validated['conversation_id'])
            : null;

        try {
            $result = $this->agent->reply($request->user(), $conversation, $validated['message'], $locale);
        } catch (AgentUnavailableException $exception) {
            $message = $exception->reason === 'not_configured'
                ? ($locale === 'ar' ? 'المساعد الذكي غير مفعّل على الخادم.' : 'The AI agent is not configured on the server.')
                : ($locale === 'ar' ? 'خدمة الذكاء الاصطناعي غير متاحة حالياً. حاول مرة أخرى.' : 'The AI service is unavailable right now. Please try again.');

            return ApiResponse::error($message, 503, ['code' => $exception->reason]);
        }

        return ApiResponse::success($result);
    }

    public function conversations(Request $request): JsonResponse
    {
        $items = AiConversation::query()
            ->where('user_id', $request->user()->id)
            ->latest('updated_at')
            ->limit(50)
            ->get()
            ->map->toApiArray();

        return ApiResponse::success($items);
    }

    public function show(Request $request, int $conversation): JsonResponse
    {
        $model = $this->conversation($request, $conversation);

        $pending = AiPendingAction::query()
            ->where('ai_conversation_id', $model->id)
            ->where('status', 'pending')
            ->get()
            ->map(fn (AiPendingAction $action) => $this->agent->pendingArray($action));

        return ApiResponse::success([
            'conversation' => $model->toApiArray(),
            'messages' => $model->messages()->orderBy('id')->limit(200)->get()->map->toApiArray(),
            'pending_actions' => $pending,
        ]);
    }

    public function destroy(Request $request, int $conversation): JsonResponse
    {
        $this->conversation($request, $conversation)->delete();

        return ApiResponse::success(null, 'Deleted');
    }

    public function confirm(Request $request, int $action): JsonResponse
    {
        return $this->resolveAction($request, $action, fn (AiPendingAction $model, string $locale) => $this->agent->confirm($model, $locale));
    }

    public function cancel(Request $request, int $action): JsonResponse
    {
        return $this->resolveAction($request, $action, fn (AiPendingAction $model, string $locale) => $this->agent->cancel($model, $locale));
    }

    private function resolveAction(Request $request, int $action, callable $handler): JsonResponse
    {
        $locale = $request->validate(['locale' => ['nullable', 'string', 'in:ar,en']])['locale'] ?? 'ar';

        $model = AiPendingAction::query()
            ->where('user_id', $request->user()->id)
            ->findOrFail($action);

        try {
            return ApiResponse::success($handler($model, $locale));
        } catch (AgentActionException $exception) {
            return ApiResponse::error(match (true) {
                $exception->reason === 'expired' => $locale === 'ar' ? 'انتهت صلاحية هذا الإجراء. اطلبه من جديد.' : 'This action expired. Ask again.',
                str_starts_with($exception->reason, 'already_') => $locale === 'ar' ? 'تمت معالجة هذا الإجراء مسبقاً.' : 'This action was already handled.',
                default => $locale === 'ar' ? 'تعذّر تنفيذ الإجراء: البيانات لم تعد صالحة.' : 'Could not run the action: its data is no longer valid.',
            }, $exception->status, ['code' => $exception->reason]);
        }
    }

    private function conversation(Request $request, int $id): AiConversation
    {
        return AiConversation::query()
            ->where('user_id', $request->user()->id)
            ->findOrFail($id);
    }
}
