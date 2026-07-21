<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class UploadController extends Controller
{
    public function multiple(Request $request): JsonResponse
    {
        $request->validate([
            'files' => ['required'],
            'files.*' => ['file', 'max:10240'],
        ]);

        $urls = [];
        $files = $request->file('files');
        if (! is_array($files)) {
            $files = [$files];
        }

        foreach ($files as $file) {
            if (! $file) {
                continue;
            }
            $path = $file->storeAs(
                'uploads/'.now()->format('Y/m'),
                Str::uuid().'.'.$file->getClientOriginalExtension(),
                'public'
            );
            $urls[] = [
                'url' => Storage::disk('public')->url($path),
                'path' => $path,
            ];
        }

        return ApiResponse::success([
            'files' => $urls,
            'urls' => array_column($urls, 'url'),
        ], 'Uploaded');
    }

    public function image(Request $request): JsonResponse
    {
        $request->validate(['file' => ['required', 'file', 'image', 'max:10240']]);
        $path = $request->file('file')->store('uploads/images', 'public');

        return ApiResponse::success([
            'url' => Storage::disk('public')->url($path),
            'path' => $path,
        ], 'Uploaded');
    }

    public function document(Request $request): JsonResponse
    {
        $request->validate(['file' => ['required', 'file', 'max:20480']]);
        $path = $request->file('file')->store('uploads/documents', 'public');

        return ApiResponse::success([
            'url' => Storage::disk('public')->url($path),
            'path' => $path,
        ], 'Uploaded');
    }
}
