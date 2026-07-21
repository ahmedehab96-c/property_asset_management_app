<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Notifications\ResetPasswordTokenNotification;
use App\Notifications\VerifyEmailCodeNotification;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function login(Request $request): JsonResponse
    {
        $credentials = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required', 'string'],
            'locale' => ['nullable', 'string', 'max:5'],
            'language' => ['nullable', 'string', 'max:5'],
        ]);

        $user = User::query()->where('email', $credentials['email'])->first();

        if (! $user || ! Hash::check($credentials['password'], $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['Invalid credentials.'],
            ]);
        }

        $locale = $credentials['locale'] ?? $credentials['language'] ?? $user->locale;
        if ($locale) {
            $user->forceFill(['locale' => $locale])->save();
        }

        $token = $user->createToken('mobile')->plainTextToken;

        return ApiResponse::success([
            'token' => $token,
            'refresh_token' => $token,
            'user' => $user->toApiArray(),
        ], 'Logged in successfully');
    }

    public function register(Request $request): JsonResponse
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'max:255', 'unique:users,email'],
            'password' => ['required', 'string', 'min:6', 'confirmed'],
            'phone' => ['nullable', 'string', 'max:50'],
            'mobile' => ['nullable', 'string', 'max:50'],
            'locale' => ['nullable', 'string', 'max:5'],
            'language' => ['nullable', 'string', 'max:5'],
        ]);

        $user = User::query()->create([
            'name' => $data['name'],
            'email' => $data['email'],
            'password' => $data['password'],
            'phone' => $data['phone'] ?? $data['mobile'] ?? null,
            'role' => 'owner',
            'is_admin' => false,
            'locale' => $data['locale'] ?? $data['language'] ?? 'ar',
            'status' => 'active',
        ]);

        $code = $this->issueEmailVerificationCode($user);
        $user->notify(new VerifyEmailCodeNotification($code));

        $token = $user->createToken('mobile')->plainTextToken;

        $payload = [
            'token' => $token,
            'refresh_token' => $token,
            'user' => $user->toApiArray(),
        ];

        if ($this->exposeDevSecrets()) {
            $payload['verification_code'] = $code;
        }

        return ApiResponse::success($payload, 'Registered successfully', 201);
    }

    public function user(Request $request): JsonResponse
    {
        return ApiResponse::success($request->user()->toApiArray());
    }

    public function logout(Request $request): JsonResponse
    {
        $request->user()?->currentAccessToken()?->delete();

        return ApiResponse::success(null, 'Logged out successfully');
    }

    public function refresh(Request $request): JsonResponse
    {
        $user = $request->user();
        $request->user()->currentAccessToken()?->delete();
        $token = $user->createToken('mobile')->plainTextToken;

        return ApiResponse::success([
            'token' => $token,
            'refresh_token' => $token,
            'user' => $user->toApiArray(),
        ], 'Token refreshed');
    }

    public function changePassword(Request $request): JsonResponse
    {
        $data = $request->validate([
            'current_password' => ['required', 'string'],
            'password' => ['required', 'string', 'min:6', 'confirmed'],
        ]);

        $user = $request->user();

        if (! Hash::check($data['current_password'], $user->password)) {
            return ApiResponse::error('Current password is incorrect', 422);
        }

        $user->forceFill(['password' => $data['password']])->save();

        return ApiResponse::success(null, 'Password changed');
    }

    public function forgotPassword(Request $request): JsonResponse
    {
        $data = $request->validate(['email' => ['required', 'email']]);

        $user = User::query()->where('email', $data['email'])->first();
        $payload = [];

        if ($user) {
            $plain = Str::random(64);
            DB::table('password_reset_tokens')->updateOrInsert(
                ['email' => $user->email],
                [
                    'token' => Hash::make($plain),
                    'created_at' => now(),
                ]
            );

            $user->notify(new ResetPasswordTokenNotification($plain));

            if ($this->exposeDevSecrets()) {
                $payload['reset_token'] = $plain;
                $payload['email'] = $user->email;
            }
        }

        return ApiResponse::success(
            $payload ?: null,
            'If the email exists, a reset link will be sent'
        );
    }

    public function resetPassword(Request $request): JsonResponse
    {
        $data = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required', 'string', 'min:6', 'confirmed'],
            'token' => ['required', 'string'],
        ]);

        $row = DB::table('password_reset_tokens')->where('email', $data['email'])->first();

        if (! $row || ! Hash::check($data['token'], $row->token)) {
            throw ValidationException::withMessages([
                'token' => ['Invalid or expired reset token.'],
            ]);
        }

        if ($row->created_at && now()->diffInMinutes(\Illuminate\Support\Carbon::parse($row->created_at)) > 60) {
            DB::table('password_reset_tokens')->where('email', $data['email'])->delete();
            throw ValidationException::withMessages([
                'token' => ['Invalid or expired reset token.'],
            ]);
        }

        $user = User::query()->where('email', $data['email'])->first();
        if (! $user) {
            throw ValidationException::withMessages([
                'email' => ['User not found.'],
            ]);
        }

        $user->forceFill(['password' => $data['password']])->save();
        DB::table('password_reset_tokens')->where('email', $data['email'])->delete();
        $user->tokens()->delete();

        return ApiResponse::success(null, 'Password reset successfully');
    }

    public function verifyEmail(Request $request): JsonResponse
    {
        $data = $request->validate([
            'token' => ['required', 'string', 'min:4', 'max:12'],
            'email' => ['nullable', 'email'],
        ]);

        $user = $request->user();
        if (! $user && ! empty($data['email'])) {
            $user = User::query()->where('email', $data['email'])->first();
        }

        if (! $user) {
            return ApiResponse::error('Unauthenticated', 401);
        }

        $cached = Cache::get($this->verificationCacheKey($user));
        if (! $cached || ! hash_equals((string) $cached, (string) $data['token'])) {
            throw ValidationException::withMessages([
                'token' => ['Invalid verification code.'],
            ]);
        }

        $user->forceFill(['email_verified_at' => now()])->save();
        Cache::forget($this->verificationCacheKey($user));

        return ApiResponse::success($user->toApiArray(), 'Email verified');
    }

    public function resendVerification(Request $request): JsonResponse
    {
        $user = $request->user();
        if ($user->email_verified_at) {
            return ApiResponse::success(null, 'Email already verified');
        }

        $code = $this->issueEmailVerificationCode($user);
        $user->notify(new VerifyEmailCodeNotification($code));
        $payload = null;
        if ($this->exposeDevSecrets()) {
            $payload = ['verification_code' => $code];
        }

        return ApiResponse::success($payload, 'Verification code sent');
    }

    public function updateTwoFactor(Request $request): JsonResponse
    {
        $data = $request->validate([
            'enabled' => ['required', 'boolean'],
        ]);

        $user = $request->user();
        $user->forceFill(['two_factor_enabled' => $data['enabled']])->save();

        return ApiResponse::success([
            'two_factor_enabled' => (bool) $user->two_factor_enabled,
            'user' => $user->toApiArray(),
        ], $data['enabled'] ? 'Two-factor enabled' : 'Two-factor disabled');
    }

    private function issueEmailVerificationCode(User $user): string
    {
        $code = (string) random_int(100000, 999999);
        Cache::put($this->verificationCacheKey($user), $code, now()->addMinutes(30));

        return $code;
    }

    private function verificationCacheKey(User $user): string
    {
        return 'email_verify:'.$user->id;
    }

    private function exposeDevSecrets(): bool
    {
        return app()->environment(['local', 'testing']);
    }
}
