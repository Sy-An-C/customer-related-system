<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\ServiceController;
use App\Http\Controllers\AppointmentController;

Route::get('/', function () {
    return view('welcome');
});

Route::resource('services', ServiceController::class)->middleware('auth');
Route::resource('appointments', AppointmentController::class)->middleware('auth');