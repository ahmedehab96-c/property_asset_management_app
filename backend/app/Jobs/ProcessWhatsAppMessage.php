<?php

namespace App\Jobs;

use App\Models\AiConversation;
use App\Models\AiPendingAction;
use App\Models\User;
use App\Services\Agent\AgentActionException;
use App\Services\Agent\AgentService;
use App\Services\Agent\AgentUnavailableException;
use App\Services\WhatsAppService;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Support\Facades\RateLimiter;

/**
 * Answers one inbound WhatsApp message with the AI agent. Runs after the
 * webhook has already returned 200, so Meta never times out and retries.
 */
class ProcessWhatsAppMessage
{
    use Dispatchable;

    /**
     * @param  string  $from  sender wa_id (international number, digits only)
     * @param  string|null  $text  message text, or null for unsupported types
     * @param  string|null  $buttonId  reply-button id, e.g. "confirm:12"
     */
    public function __construct(
        public readonly string $from,
        public readonly ?string $text,
        public readonly ?string $buttonId = null,
    ) {}

    public function handle(AgentService $agent, WhatsAppService $whatsapp): void
    {
        $locale = $this->text !== null && ! preg_match('/\p{Arabic}/u', $this->text) && $this->buttonId === null ? 'en' : 'ar';
        $user = $this->findUser();

        if ($user === null) {
            $whatsapp->sendText($this->from, $locale === 'ar'
                ? 'هذا الرقم غير مرتبط بأي حساب. أضف رقم واتساب بصيغة دولية (مثل +9715…) في ملفك الشخصي داخل التطبيق ثم أعد المحاولة.'
                : 'This number is not linked to an account. Add your WhatsApp number in international format (e.g. +9715…) to your profile in the app, then try again.');

            return;
        }

        $locale = $this->buttonId !== null ? ($user->locale === 'en' ? 'en' : 'ar') : $locale;

        if (! $this->withinLimits($user)) {
            $whatsapp->sendText($this->from, $locale === 'ar'
                ? 'وصلت إلى الحد المسموح من الرسائل. حاول بعد قليل.'
                : 'You have reached the message limit. Please try again shortly.');

            return;
        }

        if ($this->buttonId !== null) {
            $this->resolveButton($agent, $whatsapp, $user, $locale);

            return;
        }

        if ($this->text === null || trim($this->text) === '') {
            $whatsapp->sendText($this->from, $locale === 'ar'
                ? 'أستطيع قراءة الرسائل النصية فقط حالياً.'
                : 'I can only read text messages for now.');

            return;
        }

        $conversation = AiConversation::query()->firstOrCreate(
            ['user_id' => $user->id, 'channel' => 'whatsapp'],
            ['title' => 'WhatsApp', 'locale' => $locale],
        );

        try {
            $result = $agent->reply($user, $conversation, mb_substr(trim($this->text), 0, 2000), $locale);
        } catch (AgentUnavailableException) {
            $whatsapp->sendText($this->from, $locale === 'ar'
                ? 'خدمة الذكاء الاصطناعي غير متاحة حالياً. حاول مرة أخرى.'
                : 'The AI service is unavailable right now. Please try again.');

            return;
        }

        $reply = $result['message']['content'];
        $pending = $result['pending_action'];

        if ($pending !== null) {
            $whatsapp->sendButtons($this->from, $reply, [
                "confirm:{$pending['id']}" => $locale === 'ar' ? 'تأكيد' : 'Confirm',
                "cancel:{$pending['id']}" => $locale === 'ar' ? 'إلغاء' : 'Cancel',
            ]);

            return;
        }

        $whatsapp->sendText($this->from, $reply);
    }

    private function resolveButton(AgentService $agent, WhatsAppService $whatsapp, User $user, string $locale): void
    {
        if (! preg_match('/^(confirm|cancel):(\d+)$/', (string) $this->buttonId, $match)) {
            return;
        }

        // Scoped to this user: a forged button id for someone else's action finds nothing.
        $action = AiPendingAction::query()->where('user_id', $user->id)->find((int) $match[2]);
        if ($action === null) {
            return;
        }

        try {
            $result = $match[1] === 'confirm' ? $agent->confirm($action, $locale) : $agent->cancel($action, $locale);
            $whatsapp->sendText($this->from, $result['message']['content']);
        } catch (AgentActionException $exception) {
            $whatsapp->sendText($this->from, match (true) {
                $exception->reason === 'expired' => $locale === 'ar' ? 'انتهت صلاحية هذا الإجراء. اطلبه من جديد.' : 'This action expired. Ask again.',
                str_starts_with($exception->reason, 'already_') => $locale === 'ar' ? 'تمت معالجة هذا الإجراء مسبقاً.' : 'This action was already handled.',
                default => $locale === 'ar' ? 'تعذّر تنفيذ الإجراء: البيانات لم تعد صالحة.' : 'Could not run the action: its data is no longer valid.',
            });
        }
    }

    /** Exact match on the full international number; partial matches are never accepted. */
    private function findUser(): ?User
    {
        $digits = preg_replace('/\D/', '', $this->from);
        if (strlen($digits) < 8) {
            return null;
        }

        return User::query()
            ->whereNotNull('phone')
            // Pre-filter ignoring common separators; the exact comparison happens below.
            ->whereRaw("REPLACE(REPLACE(REPLACE(phone, ' ', ''), '-', ''), '+', '') LIKE ?", ['%'.substr($digits, -7)])
            ->get()
            ->first(function (User $user) use ($digits) {
                $phone = preg_replace('/\D/', '', (string) $user->phone);

                return $phone === $digits || ltrim($phone, '0') === $digits;
            });
    }

    /** Same per-minute / per-day budget as the in-app agent. */
    private function withinLimits(User $user): bool
    {
        $key = 'ai-agent-wa:'.$user->id;
        $perMinute = (int) config('services.gemini.agent.per_minute', 10);
        $perDay = (int) config('services.gemini.agent.per_day', 200);

        if (RateLimiter::tooManyAttempts($key.':m', $perMinute) || RateLimiter::tooManyAttempts($key.':d', $perDay)) {
            return false;
        }

        RateLimiter::hit($key.':m', 60);
        RateLimiter::hit($key.':d', 86400);

        return true;
    }
}
