import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../providers/appointment_provider.dart';
import '../../models/appointment_model.dart';
import '../../utils/extensions.dart';

class AppointmentListScreen extends StatelessWidget {
  const AppointmentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments'),
      ),
      body: Consumer<AppointmentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.appointments.isEmpty) {
            return const Center(child: Text('No appointments scheduled.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.appointments.length,
            itemBuilder: (context, index) {
              final appointment = provider.appointments[index];
              return _AppointmentCard(appointment: appointment);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAppointmentDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddAppointmentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _AddAppointmentDialog(),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;

  const _AppointmentCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM dd, yyyy - hh:mm a').format(appointment.appointmentDate);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(appointment.customerName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$dateStr\n${appointment.serviceType}', maxLines: 2, overflow: TextOverflow.ellipsis),
        isThreeLine: true,
        trailing: _StatusBadge(status: appointment.status),
        onTap: () {
          // Show details or edit
        },
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'Confirmed': color = Colors.blue; break;
      case 'Completed': color = Colors.green; break;
      case 'Cancelled': color = Colors.red; break;
      default: color = Colors.orange; // Pending
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _AddAppointmentDialog extends StatefulWidget {
  const _AddAppointmentDialog();

  @override
  State<_AddAppointmentDialog> createState() => _AddAppointmentDialogState();
}

class _AddAppointmentDialogState extends State<_AddAppointmentDialog> {
  final _formKey = GlobalKey<FormState>();
  String _customerName = '';
  String _phone = '';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _serviceType = 'Repair';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Schedule Appointment'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Customer Name'),
                onSaved: (val) => _customerName = val ?? '',
                validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                onSaved: (val) => _phone = val ?? '',
                validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date & Time'),
                subtitle: Text(DateFormat('MMM dd, yyyy - hh:mm a').format(_selectedDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null && context.mounted) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_selectedDate),
                    );
                    if (time != null) {
                      setState(() {
                        _selectedDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                      });
                    }
                  }
                },
              ),
              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _serviceType,
                decoration: const InputDecoration(labelText: 'Service Type'),
                items: ['Repair', 'Installation', 'AMC Visit', 'Battery Replacement']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (val) => setState(() => _serviceType = val!),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              final appointment = AppointmentModel(
                id: const Uuid().v4(),
                customerId: 'new', // Logic for existing customer could be added
                customerName: _customerName,
                phone: _phone,
                appointmentDate: _selectedDate,
                serviceType: _serviceType,
                status: 'Pending',
                createdAt: DateTime.now(),
              );
              final provider = context.read<AppointmentProvider>();
              await provider.addAppointment(appointment);
              if (!context.mounted) return;
              Navigator.pop(context);
              context.showSuccessSnackBar('Appointment scheduled');
            }
          },
          child: const Text('Schedule'),
        ),
      ],
    );
  }
}
