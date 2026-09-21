<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\MaintenanceRequest;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class MaintenanceRequestController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = MaintenanceRequest::query()->with(['property', 'tenant'])->latest();

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
            'property_id' => ['nullable', 'exists:properties,id'],
            'tenant_id' => ['nullable', 'exists:tenants,id'],
            'owner_id' => ['nullable', 'exists:owners,id'],
            'title' => ['required', 'string', 'max:255'],
            'title_ar' => ['nullable', 'string', 'max:255'],
            'problem_type' => ['nullable', 'string', 'max:100'],
            'problem_type_ar' => ['nullable', 'string', 'max:100'],
            'description' => ['nullable', 'string'],
            'description_ar' => ['nullable', 'string'],
            'status' => ['nullable', 'string', 'max:50'],
            'priority' => ['nullable', 'string', 'max:50'],
        ]);

        $data['order_number'] = 'MR-'.strtoupper(Str::random(6));
        $item = MaintenanceRequest::query()->create($data);

        return ApiResponse::success($item->load('property')->toApiArray(), 'Created', 201);
    }

    public function show(MaintenanceRequest $maintenanceRequest): JsonResponse
    {
        return ApiResponse::success($maintenanceRequest->load('property')->toApiArray());
    }

    public function update(Request $request, MaintenanceRequest $maintenanceRequest): JsonResponse
    {
        $data = $request->validate([
            'property_id' => ['nullable', 'exists:properties,id'],
            'tenant_id' => ['nullable', 'exists:tenants,id'],
            'owner_id' => ['nullable', 'exists:owners,id'],
            'title' => ['sometimes', 'string', 'max:255'],
            'title_ar' => ['nullable', 'string', 'max:255'],
            'problem_type' => ['nullable', 'string', 'max:100'],
            'problem_type_ar' => ['nullable', 'string', 'max:100'],
            'description' => ['nullable', 'string'],
            'description_ar' => ['nullable', 'string'],
            'status' => ['nullable', 'string', 'max:50'],
            'priority' => ['nullable', 'string', 'max:50'],
        ]);

        $maintenanceRequest->update($data);

        return ApiResponse::success($maintenanceRequest->fresh('property')->toApiArray(), 'Updated');
    }

    public function destroy(MaintenanceRequest $maintenanceRequest): JsonResponse
    {
        $maintenanceRequest->delete();

        return ApiResponse::success(null, 'Deleted');
    }
}
