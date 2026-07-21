<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Contract;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class ContractController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = Contract::query()->with(['property', 'tenant', 'owner'])->latest();

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
            'property_id' => ['required', 'exists:properties,id'],
            'tenant_id' => ['required', 'exists:tenants,id'],
            'owner_id' => ['nullable', 'exists:owners,id'],
            'start_date' => ['required', 'date'],
            'end_date' => ['required', 'date', 'after:start_date'],
            'monthly_rent' => ['nullable', 'numeric'],
            'deposit' => ['nullable', 'numeric'],
            'status' => ['nullable', 'string', 'max:50'],
            'contract_number' => ['nullable', 'string', 'max:100', 'unique:contracts,contract_number'],
        ]);

        $data['contract_number'] ??= 'CNT-'.strtoupper(Str::random(8));

        $contract = Contract::query()->create($data);

        return ApiResponse::success(
            $contract->load(['property', 'tenant', 'owner'])->toApiArray(),
            'Contract created',
            201
        );
    }

    public function show(Contract $contract): JsonResponse
    {
        return ApiResponse::success($contract->load(['property', 'tenant', 'owner'])->toApiArray());
    }

    public function update(Request $request, Contract $contract): JsonResponse
    {
        $data = $request->validate([
            'property_id' => ['sometimes', 'exists:properties,id'],
            'tenant_id' => ['sometimes', 'exists:tenants,id'],
            'owner_id' => ['nullable', 'exists:owners,id'],
            'start_date' => ['sometimes', 'date'],
            'end_date' => ['sometimes', 'date'],
            'monthly_rent' => ['nullable', 'numeric'],
            'deposit' => ['nullable', 'numeric'],
            'status' => ['nullable', 'string', 'max:50'],
        ]);

        $contract->update($data);

        return ApiResponse::success(
            $contract->fresh(['property', 'tenant', 'owner'])->toApiArray(),
            'Contract updated'
        );
    }

    public function destroy(Contract $contract): JsonResponse
    {
        $contract->delete();

        return ApiResponse::success(null, 'Contract deleted');
    }

    public function expiring(): JsonResponse
    {
        $items = Contract::query()
            ->with(['property', 'tenant', 'owner'])
            ->where('status', 'active')
            ->whereDate('end_date', '<=', now()->addDays(60))
            ->orderBy('end_date')
            ->get()
            ->map->toApiArray();

        return ApiResponse::success($items);
    }

    public function renew(Contract $contract): JsonResponse
    {
        $contract->update([
            'end_date' => $contract->end_date?->copy()->addYear(),
            'status' => 'active',
        ]);

        return ApiResponse::success($contract->fresh(['property', 'tenant', 'owner'])->toApiArray(), 'Contract renewed');
    }

    public function extend(Request $request, Contract $contract): JsonResponse
    {
        $data = $request->validate([
            'months' => ['nullable', 'integer', 'min:1'],
            'end_date' => ['nullable', 'date'],
        ]);

        if (! empty($data['end_date'])) {
            $contract->update(['end_date' => $data['end_date']]);
        } else {
            $months = (int) ($data['months'] ?? 12);
            $contract->update(['end_date' => $contract->end_date?->copy()->addMonths($months)]);
        }

        return ApiResponse::success($contract->fresh(['property', 'tenant', 'owner'])->toApiArray(), 'Contract extended');
    }

    public function cancel(Contract $contract): JsonResponse
    {
        $contract->update(['status' => 'cancelled']);

        return ApiResponse::success($contract->fresh(['property', 'tenant', 'owner'])->toApiArray(), 'Contract cancelled');
    }

    public function payments(Contract $contract): JsonResponse
    {
        return ApiResponse::success($contract->payments()->latest()->get()->map->toApiArray());
    }
}
