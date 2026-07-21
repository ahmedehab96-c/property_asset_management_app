<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\MaintenanceRequest;
use App\Models\Property;
use App\Services\ImageAnalysisService;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class ImageAnalysisController extends Controller
{
    public function __construct(private readonly ImageAnalysisService $analyzer) {}

    public function analyze(Request $request): JsonResponse
    {
        $request->validate([
            'paths' => ['nullable', 'array'],
            'paths.*' => ['string'],
            'files' => ['nullable'],
            'files.*' => ['file', 'image', 'max:10240'],
        ]);

        $paths = array_values(array_filter($request->input('paths', [])));

        if ($request->hasFile('files')) {
            $files = $request->file('files');
            if (! is_array($files)) {
                $files = [$files];
            }
            foreach ($files as $file) {
                if (! $file) {
                    continue;
                }
                $paths[] = $file->storeAs(
                    'uploads/analysis/'.now()->format('Y/m'),
                    Str::uuid().'.'.$file->getClientOriginalExtension(),
                    'public'
                );
            }
        }

        if ($paths === []) {
            return ApiResponse::error('Provide image files or storage paths', 422);
        }

        $total = Property::query()->count();
        $occupied = Property::query()->where('status', 'occupied')->count();
        $portfolio = [
            'open_maintenance' => MaintenanceRequest::query()->where('status', 'in_progress')->count(),
            'occupancy_rate' => $total > 0 ? round(($occupied / $total) * 100, 1) : 0,
        ];

        $result = $this->analyzer->analyze($paths, $portfolio);
        $result['urls'] = array_map(
            fn (string $path) => Storage::disk('public')->url($path),
            $paths
        );

        return ApiResponse::success($result, 'Analysis complete');
    }
}
