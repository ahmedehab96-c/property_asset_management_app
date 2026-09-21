<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\App;
use Symfony\Component\HttpFoundation\Response;

/** Honors the Accept-Language header sent by the mobile app and admin dashboard. */
class SetApiLocale
{
    /** @var list<string> */
    private const LOCALES = ['en', 'ar'];

    public function handle(Request $request, Closure $next): Response
    {
        $code = strtolower(substr((string) $request->header('Accept-Language', ''), 0, 2));
        $locale = in_array($code, self::LOCALES, true) ? $code : config('app.locale', 'en');

        App::setLocale($locale);

        return $next($request);
    }
}
