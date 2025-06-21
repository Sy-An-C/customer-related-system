import 'package:flutter/material.dart';
import 'package:frontend/screens/book_comfirmation_screen.dart';
import 'package:frontend/models/service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/appointment_provider.dart';

class BookAppointmentScreen extends StatefulWidget {
  final Service service;

  const BookAppointmentScreen({required this.service, super.key});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final TextEditingController _notesController = TextEditingController();
  final List<TimeOfDay> _availableSlots = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _generateTimeSlots();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _generateTimeSlots() {
    _availableSlots.clear();
    const TimeOfDay start = TimeOfDay(hour: 9, minute: 0);
    const TimeOfDay end = TimeOfDay(hour: 17, minute: 0);

    final now = DateTime.now();
    final isToday =
        _selectedDate?.year == now.year &&
        _selectedDate?.month == now.month &&
        _selectedDate?.day == now.day;

    TimeOfDay current = start;
    while (current.hour < end.hour ||
        (current.hour == end.hour && current.minute <= end.minute)) {
      if (!isToday ||
          current.hour > now.hour ||
          (current.hour == now.hour && current.minute > now.minute)) {
        _availableSlots.add(current);
      }
      current = _addMinutesToTime(current, 30);
    }
  }

  TimeOfDay _addMinutesToTime(TimeOfDay time, int minutes) {
    final totalMinutes = time.hour * 60 + time.minute + minutes;
    return TimeOfDay(
      hour: (totalMinutes ~/ 60) % 24,
      minute: totalMinutes % 60,
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      selectableDayPredicate: (DateTime day) {
        return day.weekday != DateTime.saturday &&
            day.weekday != DateTime.sunday;
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedTime = null;
        _generateTimeSlots();
      });
    }
  }

  void _submitBooking(BuildContext context) async {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date and time')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
    
    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      final formattedTime = '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';
      
      final success = await appointmentProvider.bookAppointment(
        serviceId: widget.service.id,
        date: formattedDate,
        startTime: formattedTime,
        notes: _notesController.text.trim(),
      );
      
      if (!mounted) return;

      if (success) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BookingConfirmationScreen(
              service: widget.service,
              appointment: {
                'date': formattedDate,
                'start_time': formattedTime,
                'notes': _notesController.text.trim(),
              },
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking failed. Please try again.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking failed: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Book ${widget.service.name}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.medical_services, size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.service.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Duration: ${widget.service.duration} mins • \$${widget.service.price.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('Select Date'),
            ElevatedButton(
              onPressed: () => _selectDate(context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: Text(
                _selectedDate == null
                    ? 'Select Date'
                    : DateFormat.yMMMMEEEEd().format(_selectedDate!),
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('Available Time Slots'),
            if (_availableSlots.isEmpty) const Text('No available slots'),
            if (_availableSlots.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableSlots.map((slot) {
                  final isSelected = _selectedTime == slot;
                  return FilterChip(
                    label: Text(slot.format(context)),
                    selected: isSelected,
                    onSelected: (selected) =>
                        setState(() => _selectedTime = selected ? slot : null),
                    selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                    checkmarkColor: Theme.of(context).primaryColor,
                  );
                }).toList(),
              ),
            const SizedBox(height: 24),
            _buildSectionHeader('Additional Notes (Optional)'),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Any special requests or notes?',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed:
                    (_selectedDate == null ||
                        _selectedTime == null ||
                        _isLoading)
                    ? null
                    : () => _submitBooking(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  minimumSize: const Size(200, 50),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Text(
                        'Confirm Booking',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}