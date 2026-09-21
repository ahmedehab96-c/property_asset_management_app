<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Property;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PropertyController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = Property::query()->with('owner')->latest();

        if ($search = $request->string('search')->toString()) {
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                    ->orWhere('location', 'like', "%{$search}%")
                    ->orWhere('address', 'like', "%{$search}%");
            });
        }

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
            'name' => ['required', 'string', 'max:255'],
            'name_ar' => ['nullable', 'string', 'max:255'],
            'type' => ['nullable', 'string', 'max:100'],
            'location' => ['nullable', 'string', 'max:255'],
            'location_ar' => ['nullable', 'string', 'max:255'],
            'address' => ['nullable', 'string', 'max:255'],
            'address_ar' => ['nullable', 'string', 'max:255'],
            'status' => ['nullable', 'string', 'max:50'],
            'area' => ['nullable', 'numeric'],
            'monthly_revenue' => ['nullable', 'numeric'],
            'owner_id' => ['nullable', 'exists:owners,id'],
            'description' => ['nullable', 'string'],
            'description_ar' => ['nullable', 'string'],
        ]);

        $property = Property::query()->create($data);

        return ApiResponse::success($property->load('owner')->toApiArray(), 'Property created', 201);
    }

    public function show(Property $property): JsonResponse
    {
        return ApiResponse::success($property->load('owner')->toApiArray());
    }

    public function update(Request $request, Property $property): JsonResponse
    {
        $data = $request->validate([
            'name' => ['sometimes', 'string', 'max:255'],
            'name_ar' => ['nullable', 'string', 'max:255'],
            'type' => ['nullable', 'string', 'max:100'],
            'location' => ['nullable', 'string', 'max:255'],
            'location_ar' => ['nullable', 'string', 'max:255'],
            'address' => ['nullable', 'string', 'max:255'],
            'address_ar' => ['nullable', 'string', 'max:255'],
            'status' => ['nullable', 'string', 'max:50'],
            'area' => ['nullable', 'numeric'],
            'monthly_revenue' => ['nullable', 'numeric'],
            'owner_id' => ['nullable', 'exists:owners,id'],
            'description' => ['nullable', 'string'],
            'description_ar' => ['nullable', 'string'],
        ]);

        $property->update($data);

        return ApiResponse::success($property->fresh('owner')->toApiArray(), 'Property updated');
    }

    public function destroy(Property $property): JsonResponse
    {
        $property->delete();

        return ApiResponse::success(null, 'Property deleted');
    }

    public function stats(Property $property): JsonResponse
    {
        return ApiResponse::success([
            'property' => $property->toApiArray(),
            'contracts_count' => $property->contracts()->count(),
            'tenants_count' => $property->tenants()->count(),
            'payments_total' => (float) $property->payments()->sum('amount'),
        ]);
    }

    public function financial(Property $property): JsonResponse
    {
        return ApiResponse::success([
            'monthly_revenue' => (float) $property->monthly_revenue,
            'payments_paid' => (float) $property->payments()->where('status', 'paid')->sum('amount'),
            'payments_pending' => (float) $property->payments()->where('status', 'pending')->sum('amount'),
        ]);
    }

    public function search(Request $request): JsonResponse
    {
        return $this->index($request);
    }

    public function filter(Request $request): JsonResponse
    {
        return $this->index($request);
    }
}
