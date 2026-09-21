<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\AiAssistantService;
use App\Services\PortfolioContextService;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AiController extends Controller
{
    public function __construct(
        private readonly AiAssistantService $assistant,
        private readonly PortfolioContextService $portfolio,
    ) {}

    public function status(): JsonResponse
    {
        return ApiResponse::success($this->assistant->status());
    }

    public function chat(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'message' => ['required', 'string', 'max:8000'],
            'locale' => ['nullable', 'string', 'in:ar,en'],
            'history' => ['nullable', 'array', 'max:20'],
            'history.*.role' => ['required_with:history', 'in:user,assistant'],
            'history.*.content' => ['required_with:history', 'string', 'max:8000'],
            'include_portfolio' => ['nullable', 'boolean'],
        ]);

        $result = $this->assistant->chat(
            message: $validated['message'],
            history: $validated['history'] ?? [],
            locale: $validated['locale'] ?? 'ar',
            includePortfolio: (bool) ($validated['include_portfolio'] ?? true),
        );

        return ApiResponse::success($result);
    }

    public function marketAnalysis(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'city' => ['required', 'string', 'max:120'],
            'property_type' => ['required', 'string', 'max:120'],
            'locale' => ['nullable', 'string', 'in:ar,en'],
        ]);

        $result = $this->assistant->marketAnalysis(
            city: $validated['city'],
            propertyType: $validated['property_type'],
            portfolio: $this->portfolio->build(),
            locale: $validated['locale'] ?? 'ar',
        );

        return ApiResponse::success($result, 'Market analysis complete');
    }

    public function tenantAnalysis(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => ['nullable', 'string', 'max:120'],
            'phone' => ['nullable', 'string', 'max:40'],
            'income' => ['nullable', 'numeric', 'min:0'],
            'employment' => ['nullable', 'string', 'max:80'],
            'has_previous_rentals' => ['nullable', 'boolean'],
            'locale' => ['nullable', 'string', 'in:ar,en'],
        ]);

        $result = $this->assistant->tenantAnalysis(
            input: $validated,
            portfolio: $this->portfolio->build(),
            locale: $validated['locale'] ?? 'ar',
        );

        return ApiResponse::success($result, 'Tenant analysis complete');
    }

    public function financialPredictions(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'period' => ['nullable', 'string', 'in:three,six,twelve'],
            'locale' => ['nullable', 'string', 'in:ar,en'],
        ]);

        $result = $this->assistant->financialPredictions(
            period: $validated['period'] ?? 'three',
            portfolio: $this->portfolio->build(),
            locale: $validated['locale'] ?? 'ar',
        );

        return ApiResponse::success($result, 'Financial predictions complete');
    }
}
