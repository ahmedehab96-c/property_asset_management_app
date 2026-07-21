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

    public function show(Report $report): JsonResponse
    {
        return ApiResponse::success($report->load(['owner', 'property'])->toApiArray());
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
