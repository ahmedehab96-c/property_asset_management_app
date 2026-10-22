<?php

namespace App\Services\Agent\Tools;

use App\Models\Payment;
use App\Models\User;
use App\Services\Agent\AgentTool;

class ListPaymentsTool extends AgentTool
{
    public function name(): string
    {
        return 'list_payments';
    }

    public function description(): string
    {
        return 'List rent payments with totals. status: pending, paid, or overdue (pending and past due date).';
    }

    public function parameters(): array
    {
        return [
            'type' => 'OBJECT',
            'properties' => [
                'status' => ['type' => 'STRING', 'enum' => ['pending', 'paid', 'overdue']],
                'limit' => self::limitSchema(),
            ],
        ];
    }

    public function rules(): array
    {
        return [
            'status' => ['nullable', 'string', 'in:pending,paid,overdue'],
            'limit' => ['nullable', 'integer', 'min:1', 'max:20'],
        ];
    }

    public function execute(array $arguments, User $user): array
    {
        $query = Payment::query()->with(['tenant', 'property']);

        // Same definition of "overdue" as PaymentController::overdue().
        match ($arguments['status'] ?? null) {
            'overdue' => $query->where('status', 'pending')->whereDate('due_date', '<', now()),
            null => null,
            default => $query->where('status', $arguments['status']),
        };

        $total = (clone $query)->count();
        $totalAmount = (float) (clone $query)->sum('amount');

        $items = $query->orderBy('due_date')->limit($this->limitArg($arguments))->get()
            ->map(fn (Payment $payment) => [
                'id' => $payment->id,
                'amount' => (float) $payment->amount,
                'due_date' => $payment->due_date?->toDateString(),
                'payment_date' => $payment->payment_date?->toDateString(),
                'status' => $payment->status,
                'tenant_name' => $payment->tenant?->localized('name'),
                'property_name' => $payment->property?->localized('name'),
            ])->all();

        return ['total_matches' => $total, 'total_amount_aed' => $totalAmount, 'payments' => $items];
    }
}
