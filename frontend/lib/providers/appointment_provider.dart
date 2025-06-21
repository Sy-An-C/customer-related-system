import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/models/appointment.dart';
import 'package:frontend/services/api_service.dart';

class AppointmentProvider with ChangeNotifier {
  final List<Appointment> _appointments = [];
  final ApiService _apiService = ApiService();
  String? _error;

  List<Appointment> get appointments => _appointments;
  String? get error => _error;

  Future<void> loadAppointments() async {
    try {
      final response = await _apiService.get('appointments');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _appointments.clear();
        for (var item in data) {
          _appointments.add(Appointment.fromJson(item));
        }
        _error = null;
      } else {
        _error = 'Failed to load appointments';
      }
    } catch (e) {
      _error = 'Error: ${e.toString()}';
    }
    notifyListeners();
  }

  Future<bool> bookAppointment({
    required int serviceId,
    required String date,
    required String startTime,
    String? notes,
  }) async {
    try {
      final response = await _apiService.post('appointments', {
        'service_id': serviceId,
        'date': date,
        'start_time': startTime,
        'notes': notes,
      });

      if (response.statusCode == 201) {
        final newAppointment = Appointment.fromJson(jsonDecode(response.body));
        _appointments.add(newAppointment);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateAppointmentStatus(int id, String status) async {
    try {
      final response = await _apiService.put('appointments/$id/status', {
        'status': status,
      });

      if (response.statusCode == 200) {
        final index = _appointments.indexWhere((app) => app.id == id);
        if (index != -1) {
          _appointments[index] = _appointments[index].copyWith(status: status);
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}