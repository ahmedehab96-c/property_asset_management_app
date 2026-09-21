<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\CalendarEvent;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CalendarEventController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = CalendarEvent::query()->with('property')->orderBy('date');

        $month = $request->integer('month');
        $year = $request->integer('year');
        if ($month > 0 && $year > 0) {
            $query->whereMonth('date', $month)->whereYear('date', $year);
        }

        $items = $query->get()->map->toApiArray();

        return ApiResponse::success([
            'items' => $items,
            'data' => $items,
        ]);
    }

    public function upcoming(): JsonResponse
    {
        $items = CalendarEvent::query()
            ->with('property')
            ->whereDate('date', '>=', now())
            ->orderBy('date')
            ->limit(30)
            ->get()
            ->map->toApiArray();

        return ApiResponse::success($items);
    }

    public function show(CalendarEvent $calendarEvent): JsonResponse
    {
        return ApiResponse::success($calendarEvent->load('property')->toApiArray());
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'property_id' => ['nullable', 'exists:properties,id'],
            'owner_id' => ['nullable', 'exists:owners,id'],
            'title' => ['required', 'string', 'max:255'],
            'title_ar' => ['nullable', 'string', 'max:255'],
            'type' => ['nullable', 'string', 'max:50'],
            'date' => ['required', 'date'],
            'time' => ['nullable', 'string', 'max:20'],
            'amount' => ['nullable', 'numeric'],
            'notes' => ['nullable', 'string'],
        ]);

        $event = CalendarEvent::query()->create($data);

        return ApiResponse::success($event->load('property')->toApiArray(), 'Created', 201);
    }

    public function update(Request $request, CalendarEvent $calendarEvent): JsonResponse
    {
        $data = $request->validate([
            'property_id' => ['nullable', 'exists:properties,id'],
            'owner_id' => ['nullable', 'exists:owners,id'],
            'title' => ['sometimes', 'string', 'max:255'],
            'title_ar' => ['nullable', 'string', 'max:255'],
            'type' => ['nullable', 'string', 'max:50'],
            'date' => ['sometimes', 'date'],
            'time' => ['nullable', 'string', 'max:20'],
            'amount' => ['nullable', 'numeric'],
            'notes' => ['nullable', 'string'],
        ]);

        $calendarEvent->update($data);

        return ApiResponse::success($calendarEvent->fresh('property')->toApiArray(), 'Updated');
    }

    public function destroy(CalendarEvent $calendarEvent): JsonResponse
    {
        $calendarEvent->delete();

        return ApiResponse::success(null, 'Deleted');
    }
}
