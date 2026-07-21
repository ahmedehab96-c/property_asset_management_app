<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\App;
use Symfony\Component\HttpFoundation\Response;

class SetAdminLocale
{
    /** @var list<string> */
    private const LOCALES = ['en', 'ar'];

    public function handle(Request $request, Closure $next): Response
    {
        $locale = session('admin_locale');

        if (! is_string($locale) || ! in_array($locale, self::LOCALES, true)) {
            $userLocale = $request->user()?->locale;
            $locale = is_string($userLocale) && in_array($userLocale, self::LOCALES, true)
                ? $userLocale
                : config('app.locale', 'en');
        }

        App::setLocale($locale);

        return $next($request);
    }
}
