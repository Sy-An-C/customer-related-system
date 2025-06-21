import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/models/appointment.dart';
import 'package:frontend/screens/appointment_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/appointment_provider.dart';

class AppointmentListScreen extends StatefulWidget {
  const AppointmentListScreen({super.key});

  @override
  State<AppointmentListScreen> createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    final provider = Provider.of<AppointmentProvider>(context, listen: false);
    await provider.loadAppointments();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appointments = Provider.of<AppointmentProvider>(context).appointments;

    return Scaffold(
      appBar: AppBar(title: const Text('My Appointments')),
      body: RefreshIndicator(
        onRefresh: _loadAppointments,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : appointments.isEmpty
            ? const Center(child: Text('No appointments found'))
            : ListView.builder(
                itemCount: appointments.length,
                itemBuilder: (context, index) =>
                    AppointmentCard(appointment: appointments[index]),
              ),
      ),
    );
  }
}

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;

  const AppointmentCard({required this.appointment, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(appointment.service.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat.yMMMd().format(appointment.date)),
            Text('${appointment.startTime} - ${_calculateEndTime(context)}'),
            Chip(
              label: Text(
                appointment.status.toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: _getStatusColor(),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AppointmentDetailScreen(appointment: appointment),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (appointment.status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default: // pending
        return Colors.orange;
    }
  }

  String _calculateEndTime(BuildContext context) {
    try {
      final startDateTime = DateTime.parse(
        '2000-01-01 ${appointment.startTime}',
      );
      final endDateTime = startDateTime.add(
        Duration(minutes: appointment.service.duration),
      );
      final endTime = TimeOfDay.fromDateTime(endDateTime);
      return endTime.format(context);
    } catch (e) {
      return 'Invalid';
    }
  }
}
