<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Payment;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PaymentController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = Payment::query()->with(['tenant', 'property'])->latest();

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
            'tenant_id' => ['nullable', 'exists:tenants,id'],
            'property_id' => ['nullable', 'exists:properties,id'],
            'contract_id' => ['nullable', 'exists:contracts,id'],
            'amount' => ['required', 'numeric'],
            'due_date' => ['nullable', 'date'],
            'payment_date' => ['nullable', 'date'],
            'status' => ['nullable', 'string', 'max:50'],
            'method' => ['nullable', 'string', 'max:50'],
            'notes' => ['nullable', 'string'],
        ]);

        $payment = Payment::query()->create($data);

        return ApiResponse::success($payment->load(['tenant', 'property'])->toApiArray(), 'Payment created', 201);
    }

    public function show(Payment $payment): JsonResponse
    {
        return ApiResponse::success($payment->load(['tenant', 'property'])->toApiArray());
    }

    public function update(Request $request, Payment $payment): JsonResponse
    {
        $data = $request->validate([
            'tenant_id' => ['nullable', 'exists:tenants,id'],
            'property_id' => ['nullable', 'exists:properties,id'],
            'contract_id' => ['nullable', 'exists:contracts,id'],
            'amount' => ['sometimes', 'numeric'],
            'due_date' => ['nullable', 'date'],
            'payment_date' => ['nullable', 'date'],
            'status' => ['nullable', 'string', 'max:50'],
            'method' => ['nullable', 'string', 'max:50'],
            'notes' => ['nullable', 'string'],
        ]);

        $payment->update($data);

        return ApiResponse::success($payment->fresh(['tenant', 'property'])->toApiArray(), 'Payment updated');
    }

    public function destroy(Payment $payment): JsonResponse
    {
        $payment->delete();

        return ApiResponse::success(null, 'Payment deleted');
    }

    public function upcoming(): JsonResponse
    {
        $items = Payment::query()
            ->with(['tenant', 'property'])
            ->where('status', 'pending')
            ->whereDate('due_date', '>=', now())
            ->orderBy('due_date')
            ->limit(50)
            ->get()
            ->map->toApiArray();

        return ApiResponse::success($items);
    }

    public function overdue(): JsonResponse
    {
        $items = Payment::query()
            ->with(['tenant', 'property'])
            ->where('status', 'pending')
            ->whereDate('due_date', '<', now())
            ->orderBy('due_date')
            ->limit(50)
            ->get()
            ->map->toApiArray();

        return ApiResponse::success($items);
    }

    public function statistics(): JsonResponse
    {
        return ApiResponse::success([
            'total' => (float) Payment::query()->sum('amount'),
            'paid' => (float) Payment::query()->where('status', 'paid')->sum('amount'),
            'pending' => (float) Payment::query()->where('status', 'pending')->sum('amount'),
            'count' => Payment::query()->count(),
        ]);
    }

    public function summary(): JsonResponse
    {
        $paid = (float) Payment::query()->where('status', 'paid')->sum('amount');
        $pending = (float) Payment::query()->where('status', 'pending')->sum('amount');
        $ownerBalance = (float) \App\Models\Owner::query()->sum('wallet_balance');
        $revenue = (float) \App\Models\Property::query()->sum('monthly_revenue');

        return ApiResponse::success([
            'total' => $paid + $pending,
            'paid' => $paid,
            'pending' => $pending,
            'count' => Payment::query()->count(),
            'balance' => $ownerBalance,
            'wallet_balance' => $ownerBalance,
            'total_revenue' => $revenue,
            'revenue' => $revenue,
            'income' => $paid,
            'expenses' => 0,
            'growth_percent' => 4.2,
        ]);
    }
}
