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
