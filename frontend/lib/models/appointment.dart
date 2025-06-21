import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'service.dart';

class Appointment {
  final int id;
  final int userId;
  final int serviceId;
  final DateTime date;
  final String startTime;
  final String status;
  final String? notes;
  final Service service;

  Appointment({
    required this.id,
    required this.userId,
    required this.serviceId,
    required this.date,
    required this.startTime,
    required this.status,
    this.notes,
    required this.service,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      userId: json['user_id'],
      serviceId: json['service_id'],
      date: DateTime.parse(json['date']),
      startTime: json['start_time'],
      status: json['status'],
      notes: json['notes'],
      service: Service.fromJson(json['service']),
    );
  }

  String get formattedDate => DateFormat.yMMMd().format(date);

  String getFormattedEndTime(BuildContext context) {
    try {
      final start = TimeOfDay(
        hour: int.parse(startTime.split(':')[0]),
        minute: int.parse(startTime.split(':')[1]),
      );
      
      final totalMinutes = start.hour * 60 + start.minute + service.duration;
      final endHour = totalMinutes ~/ 60;
      final endMinute = totalMinutes % 60;
      final end = TimeOfDay(hour: endHour, minute: endMinute);
      
      return end.format(context);
    } catch (e) {
      return 'Invalid Time';
    }
  }

  Appointment copyWith({
    int? id,
    int? userId,
    int? serviceId,
    DateTime? date,
    String? startTime,
    String? status,
    String? notes,
    Service? service,
  }) {
    return Appointment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      serviceId: serviceId ?? this.serviceId,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      service: service ?? this.service,
    );
  }
}