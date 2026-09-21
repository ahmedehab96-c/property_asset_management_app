<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Report;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ReportController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = Report::query()->with(['owner', 'property'])->latest();

        if ($type = $request->string('type')->toString()) {
            $query->where('type', 'like', "%{$type}%");
        }

        $items = $query->paginate((int) $request->input('per_page', 20));

        return ApiResponse::paginated($items);
    }

    public function show(Report $report): JsonResponse
    {
        return ApiResponse::success($report->load(['owner', 'property'])->toApiArray());
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'title' => ['required', 'string', 'max:255'],
            'title_ar' => ['nullable', 'string', 'max:255'],
            'type' => ['nullable', 'string', 'max:100'],
            'owner_id' => ['nullable', 'exists:owners,id'],
            'property_id' => ['nullable', 'exists:properties,id'],
            'amount' => ['nullable', 'numeric'],
            'meta' => ['nullable', 'array'],
        ]);

        $data['type'] = $data['type'] ?? 'financial';

        $report = Report::query()->create($data);

        return ApiResponse::success($report->load(['owner', 'property'])->toApiArray(), 'Report created', 201);
    }

    public function update(Request $request, Report $report): JsonResponse
    {
        $data = $request->validate([
            'title' => ['sometimes', 'string', 'max:255'],
            'title_ar' => ['nullable', 'string', 'max:255'],
            'type' => ['nullable', 'string', 'max:100'],
            'owner_id' => ['nullable', 'exists:owners,id'],
            'property_id' => ['nullable', 'exists:properties,id'],
            'amount' => ['nullable', 'numeric'],
            'meta' => ['nullable', 'array'],
        ]);

        $report->update($data);

        return ApiResponse::success($report->fresh(['owner', 'property'])->toApiArray(), 'Report updated');
    }

    public function destroy(Report $report): JsonResponse
    {
        $report->delete();

        return ApiResponse::success(null, 'Report deleted');
    }

    public function financial(): JsonResponse
    {
        return $this->typed('financial');
    }

    public function tenant(): JsonResponse
    {
        return $this->typed('tenant');
    }

    public function property(): JsonResponse
    {
        return $this->typed('property');
    }

    public function contract(): JsonResponse
    {
        return $this->typed('contract');
    }

    private function typed(string $type): JsonResponse
    {
        $items = Report::query()->where('type', $type)->latest()->get()->map->toApiArray();

        return ApiResponse::success($items);
    }
}
