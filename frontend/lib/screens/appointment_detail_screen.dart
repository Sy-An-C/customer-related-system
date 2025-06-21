import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/appointment.dart';
import '../../providers/appointment_provider.dart';

class AppointmentDetailScreen extends StatelessWidget {
  final Appointment appointment;

  const AppointmentDetailScreen({required this.appointment, super.key});

  @override
  Widget build(BuildContext context) {
    final durationInHours = (appointment.service.duration / 60).toStringAsFixed(
      1,
    );
    final formattedTime = _formatTime(context, appointment.startTime);
    final formattedEndTime = appointment.getFormattedEndTime(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _navigateToEditScreen(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildServiceCard(context),
            const SizedBox(height: 24),
            _buildDetailSection(
              icon: Icons.calendar_today,
              title: 'Date & Time',
              children: [
                _buildDetailRow('Date', appointment.formattedDate),
                _buildDetailRow('Time', '$formattedTime - $formattedEndTime'),
                _buildDetailRow('Duration', '$durationInHours hours'),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailSection(
              icon: Icons.info_outline,
              title: 'Appointment Info',
              children: [
                _buildDetailRow(
                  'Status',
                  appointment.status.toUpperCase(),
                  statusColor: _getStatusColor(appointment.status),
                ),
                if (appointment.notes?.isNotEmpty ?? false)
                  _buildDetailRow('Notes', appointment.notes!),
              ],
            ),
            const SizedBox(height: 32),
            if (appointment.status == 'pending') _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.medical_services, size: 40, color: Colors.blue),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appointment.service.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${appointment.service.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.blue),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? statusColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: statusColor ?? Colors.black,
                fontWeight: statusColor != null ? FontWeight.bold : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.check_circle, size: 20),
            label: const Text('CONFIRM'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () => _updateStatus(context, 'confirmed'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.cancel, size: 20),
            label: const Text('CANCEL'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () => _updateStatus(context, 'cancelled'),
          ),
        ),
      ],
    );
  }

  Future<void> _updateStatus(BuildContext context, String status) async {
    final scaffold = ScaffoldMessenger.of(context);
    try {
      final provider = Provider.of<AppointmentProvider>(context, listen: false);
      final success = await provider.updateAppointmentStatus(
        appointment.id,
        status,
      );

      if (!context.mounted) return;

      if (success) {
        Navigator.pop(context);
        scaffold.showSnackBar(
          SnackBar(
            content: Text('Appointment ${status.toUpperCase()}'),
            backgroundColor: status == 'confirmed' ? Colors.green : Colors.red,
          ),
        );
      } else {
        scaffold.showSnackBar(
          const SnackBar(
            content: Text('Failed to update status'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        scaffold.showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToEditScreen(BuildContext context) {
    // TODO: Implement edit screen navigation
    // Navigator.push(context, MaterialPageRoute(
    //   builder: (context) => EditAppointmentScreen(appointment: appointment),
    // ));
  }

  String _formatTime(BuildContext context, String time) {
    try {
      final dateTime = DateTime.parse('2000-01-01 $time');
      return TimeOfDay.fromDateTime(dateTime).format(context);
    } catch (e) {
      return time;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }
}
