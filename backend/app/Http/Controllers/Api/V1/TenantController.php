<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Tenant;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class TenantController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = Tenant::query()->with('property')->latest();

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
            'name' => ['required', 'string', 'max:255'],
            'name_ar' => ['nullable', 'string', 'max:255'],
            'email' => ['nullable', 'email', 'max:255'],
            'phone' => ['nullable', 'string', 'max:50'],
            'mobile' => ['nullable', 'string', 'max:50'],
            'property_id' => ['nullable', 'exists:properties,id'],
            'status' => ['nullable', 'string', 'max:50'],
            'rent_amount' => ['nullable', 'numeric'],
            'address' => ['nullable', 'string', 'max:255'],
            'address_ar' => ['nullable', 'string', 'max:255'],
        ]);

        $data['phone'] = $data['phone'] ?? $data['mobile'] ?? null;
        unset($data['mobile']);

        $tenant = Tenant::query()->create($data);

        return ApiResponse::success($tenant->load('property')->toApiArray(), 'Tenant created', 201);
    }

    public function show(Tenant $tenant): JsonResponse
    {
        return ApiResponse::success($tenant->load('property')->toApiArray());
    }

    public function update(Request $request, Tenant $tenant): JsonResponse
    {
        $data = $request->validate([
            'name' => ['sometimes', 'string', 'max:255'],
            'name_ar' => ['nullable', 'string', 'max:255'],
            'email' => ['nullable', 'email', 'max:255'],
            'phone' => ['nullable', 'string', 'max:50'],
            'mobile' => ['nullable', 'string', 'max:50'],
            'property_id' => ['nullable', 'exists:properties,id'],
            'status' => ['nullable', 'string', 'max:50'],
            'rent_amount' => ['nullable', 'numeric'],
            'address' => ['nullable', 'string', 'max:255'],
            'address_ar' => ['nullable', 'string', 'max:255'],
        ]);

        if (isset($data['mobile']) && ! isset($data['phone'])) {
            $data['phone'] = $data['mobile'];
        }
        unset($data['mobile']);

        $tenant->update($data);

        return ApiResponse::success($tenant->fresh('property')->toApiArray(), 'Tenant updated');
    }

    public function destroy(Tenant $tenant): JsonResponse
    {
        $tenant->delete();

        return ApiResponse::success(null, 'Tenant deleted');
    }

    public function payments(Tenant $tenant): JsonResponse
    {
        $items = $tenant->payments()->latest()->get()->map->toApiArray();

        return ApiResponse::success($items);
    }

    public function contracts(Tenant $tenant): JsonResponse
    {
        $items = $tenant->contracts()->with(['property', 'owner'])->latest()->get()->map->toApiArray();

        return ApiResponse::success($items);
    }

    public function history(Tenant $tenant): JsonResponse
    {
        return ApiResponse::success([
            'tenant' => $tenant->toApiArray(),
            'contracts' => $tenant->contracts()->latest()->get()->map->toApiArray(),
            'payments' => $tenant->payments()->latest()->get()->map->toApiArray(),
        ]);
    }
}
