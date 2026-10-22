<?php

namespace App\Providers;

use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        // Caps AI spend per user: a burst limit plus a daily ceiling.
        RateLimiter::for('ai-agent', function (Request $request) {
            $key = 'ai-agent:'.($request->user()?->id ?: $request->ip());

            return [
                Limit::perMinute((int) config('services.gemini.agent.per_minute', 10))->by($key.':m'),
                Limit::perDay((int) config('services.gemini.agent.per_day', 200))->by($key.':d'),
            ];
        });
    }
}
