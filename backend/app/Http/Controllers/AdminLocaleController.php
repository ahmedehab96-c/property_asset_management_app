<?php

namespace App\Http\Controllers;

use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;

class AdminLocaleController extends Controller
{
    /** @var list<string> */
    private const LOCALES = ['en', 'ar'];

    public function __invoke(Request $request, string $locale): RedirectResponse
    {
        abort_unless(in_array($locale, self::LOCALES, true), 404);

        session(['admin_locale' => $locale]);

        if ($request->user()) {
            $request->user()->forceFill(['locale' => $locale])->save();
        }

        return redirect()->back(fallback: url('/admin'));
    }
}
