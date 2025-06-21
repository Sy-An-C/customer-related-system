<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Appointment;
use Illuminate\Support\Facades\Validator;

class AppointmentController extends Controller
{
    public function index(Request $request)
    {
        return $request->user()->appointments()->with('service')->get();
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'service_id' => 'required|exists:services,id',
            'date' => 'required|date|after_or_equal:today',
            'start_time' => 'required|date_format:H:i',
            'notes' => 'nullable|string'
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        // Check if time slot is available
        $existingAppointment = Appointment::where('date', $request->date)
            ->where('start_time', $request->start_time)
            ->exists();

        if ($existingAppointment) {
            return response()->json([
                'message' => 'This time slot is already booked'
            ], 409);
        }

        $appointment = Appointment::create([
            'user_id' => $request->user()->id,
            'service_id' => $request->service_id,
            'date' => $request->date,
            'start_time' => $request->start_time,
            'notes' => $request->notes,
            'status' => 'pending'
        ]);

        return response()->json($appointment->load('service'), 201);
    }

    public function updateStatus(Request $request, Appointment $appointment)
    {
        if ($appointment->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $request->validate([
            'status' => 'required|in:confirmed,cancelled'
        ]);

        $appointment->update(['status' => $request->status]);

        return response()->json($appointment);
    }
}
