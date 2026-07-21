<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class UserController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = User::query()->latest();

        if ($search = $request->string('search')->toString()) {
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                    ->orWhere('email', 'like', "%{$search}%");
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
            'full_name' => ['nullable', 'string', 'max:255'],
            'email' => ['required', 'email', 'unique:users,email'],
            'password' => ['required', 'string', 'min:6'],
            'phone' => ['nullable', 'string', 'max:50'],
            'role' => ['nullable', 'string', 'max:50'],
            'is_admin' => ['nullable', 'boolean'],
            'locale' => ['nullable', 'string', 'max:5'],
            'status' => ['nullable', 'string', 'max:50'],
            'address' => ['nullable', 'string', 'max:255'],
        ]);

        $data['name'] = $data['name'] ?? $data['full_name'];
        unset($data['full_name']);
        $data['role'] ??= 'owner';
        $data['is_admin'] ??= $data['role'] === 'admin';

        $user = User::query()->create($data);

        return ApiResponse::success($user->toApiArray(), 'User created', 201);
    }

    public function show(User $user): JsonResponse
    {
        return ApiResponse::success($user->toApiArray());
    }

    public function update(Request $request, User $user): JsonResponse
    {
        $data = $request->validate([
            'name' => ['sometimes', 'string', 'max:255'],
            'full_name' => ['nullable', 'string', 'max:255'],
            'email' => ['sometimes', 'email', 'unique:users,email,'.$user->id],
            'password' => ['nullable', 'string', 'min:6'],
            'phone' => ['nullable', 'string', 'max:50'],
            'role' => ['nullable', 'string', 'max:50'],
            'is_admin' => ['nullable', 'boolean'],
            'locale' => ['nullable', 'string', 'max:5'],
            'status' => ['nullable', 'string', 'max:50'],
            'address' => ['nullable', 'string', 'max:255'],
        ]);

        if (isset($data['full_name']) && ! isset($data['name'])) {
            $data['name'] = $data['full_name'];
        }
        unset($data['full_name']);

        if (empty($data['password'])) {
            unset($data['password']);
        }

        $user->update($data);

        return ApiResponse::success($user->fresh()->toApiArray(), 'User updated');
    }

    public function destroy(User $user): JsonResponse
    {
        $user->delete();

        return ApiResponse::success(null, 'User deleted');
    }

    public function profile(User $user): JsonResponse
    {
        return ApiResponse::success($user->toApiArray());
    }

    public function registrationRequests(): JsonResponse
    {
        $items = User::query()->where('status', 'pending')->latest()->get()->map->toApiArray();

        return ApiResponse::success($items);
    }

    public function approve(User $user): JsonResponse
    {
        $user->update(['status' => 'active']);

        return ApiResponse::success($user->toApiArray(), 'User approved');
    }

    public function reject(User $user): JsonResponse
    {
        $user->update(['status' => 'rejected']);

        return ApiResponse::success($user->toApiArray(), 'User rejected');
    }
}
