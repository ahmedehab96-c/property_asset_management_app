<?php

use App\Http\Controllers\AdminLocaleController;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return redirect('/admin');
});

Route::middleware('web')->group(function () {
    Route::get('/admin/locale/{locale}', AdminLocaleController::class)
        ->name('admin.locale.switch');
});

Route::get('/dashboard/{any?}', function () {
    $index = public_path('dashboard/index.html');

    abort_unless(file_exists($index), 404);

    return response()->file($index, ['Content-Type' => 'text/html']);
})->where('any', '.*')->name('dashboard.spa');
