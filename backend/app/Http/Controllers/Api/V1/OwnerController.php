<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Owner;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class OwnerController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = Owner::query()->latest();

        if ($search = $request->string('search')->toString()) {
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                    ->orWhere('email', 'like', "%{$search}%")
                    ->orWhere('phone', 'like', "%{$search}%");
            });
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
            'name' => ['required_without:full_name', 'nullable', 'string', 'max:255'],
            'name_ar' => ['nullable', 'string', 'max:255'],
            'full_name' => ['nullable', 'string', 'max:255'],
            'email' => ['nullable', 'email', 'max:255'],
            'phone' => ['nullable', 'string', 'max:50'],
            'address' => ['nullable', 'string', 'max:255'],
            'address_ar' => ['nullable', 'string', 'max:255'],
            'wallet_balance' => ['nullable', 'numeric'],
            'join_date' => ['nullable', 'date'],
            'user_id' => ['nullable', 'exists:users,id'],
        ]);

        $data['name'] = $data['name'] ?? $data['full_name'];
        unset($data['full_name']);
        $data['join_date'] ??= now()->toDateString();

        $owner = Owner::query()->create($data);

        return ApiResponse::success($owner->toApiArray(), 'Owner created', 201);
    }

    public function show(Owner $owner): JsonResponse
    {
        return ApiResponse::success($owner->toApiArray());
    }

    public function update(Request $request, Owner $owner): JsonResponse
    {
        $data = $request->validate([
            'name' => ['sometimes', 'string', 'max:255'],
            'name_ar' => ['nullable', 'string', 'max:255'],
            'full_name' => ['nullable', 'string', 'max:255'],
            'email' => ['nullable', 'email', 'max:255'],
            'phone' => ['nullable', 'string', 'max:50'],
            'address' => ['nullable', 'string', 'max:255'],
            'address_ar' => ['nullable', 'string', 'max:255'],
            'wallet_balance' => ['nullable', 'numeric'],
            'join_date' => ['nullable', 'date'],
        ]);

        if (isset($data['full_name']) && ! isset($data['name'])) {
            $data['name'] = $data['full_name'];
        }
        unset($data['full_name']);

        $owner->update($data);

        return ApiResponse::success($owner->fresh()->toApiArray(), 'Owner updated');
    }

    public function destroy(Owner $owner): JsonResponse
    {
        $owner->delete();

        return ApiResponse::success(null, 'Owner deleted');
    }

    public function properties(Owner $owner): JsonResponse
    {
        return ApiResponse::success($owner->properties()->latest()->get()->map->toApiArray());
    }

    public function financial(Owner $owner): JsonResponse
    {
        return ApiResponse::success([
            'wallet_balance' => (float) $owner->wallet_balance,
            'balance' => (float) $owner->wallet_balance,
            'monthly_revenue' => (float) $owner->properties()->sum('monthly_revenue'),
            'total_revenue' => (float) $owner->properties()->sum('monthly_revenue'),
            'revenue' => (float) $owner->properties()->sum('monthly_revenue'),
            'expenses' => 0,
            'properties_count' => $owner->properties()->count(),
            'growth_percent' => 3.5,
        ]);
    }
}
