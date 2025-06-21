import 'package:flutter/material.dart';
import '../models/service.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final Service service;
  final Map<String, dynamic> appointment;

  const BookingConfirmationScreen({
    required this.service,
    required this.appointment,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Confirmed'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Icon(
                Icons.check_circle,
                color: Theme.of(context).primaryColor,
                size: 80,
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'Appointment Booked!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 32),
            _buildDetailRow('Service', service.name),
            _buildDetailRow('Date', appointment['date']),
            _buildDetailRow('Time', appointment['start_time']),
            if (appointment['notes']?.isNotEmpty ?? false)
              _buildDetailRow('Notes', appointment['notes']),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                ),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}