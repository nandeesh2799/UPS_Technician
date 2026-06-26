import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Step2Classification extends StatelessWidget {
  final String serviceType;
  final String status;
  final String priority;
  final DateTime serviceDate;
  final Function(String) onServiceTypeChanged;
  final Function(String) onStatusChanged;
  final Function(String) onPriorityChanged;
  final Function(DateTime) onDateChanged;

  const Step2Classification({
    super.key,
    required this.serviceType,
    required this.status,
    required this.priority,
    required this.serviceDate,
    required this.onServiceTypeChanged,
    required this.onStatusChanged,
    required this.onPriorityChanged,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Service Classification', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Categorize the type of job and its urgency.', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 24),
        DropdownButtonFormField<String>(
          initialValue: serviceType,
          decoration: const InputDecoration(labelText: 'Service Type', prefixIcon: Icon(Icons.category)),
          items: ['Installation', 'Repair', 'Maintenance'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
          onChanged: (v) => onServiceTypeChanged(v!),
        ),
        const SizedBox(height: 20),
        DropdownButtonFormField<String>(
          initialValue: status,
          decoration: const InputDecoration(labelText: 'Initial Status', prefixIcon: Icon(Icons.info_outline)),
          items: {
            'Pending',
            'In Progress',
            'Waiting for Parts',
            'Completed',
            'Delivered',
            'Picked Up',
            'Assigned',
            'Diagnosed',
            status,
          }.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: (v) => onStatusChanged(v!),
        ),
        const SizedBox(height: 20),
        DropdownButtonFormField<String>(
          initialValue: priority,
          decoration: const InputDecoration(labelText: 'Priority Level', prefixIcon: Icon(Icons.flag)),
          items: ['Low', 'Normal', 'Urgent'].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
          onChanged: (v) => onPriorityChanged(v!),
        ),
        const SizedBox(height: 20),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: serviceDate,
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
            );
            if (date != null) onDateChanged(date);
          },
          child: IgnorePointer(
            child: TextFormField(
              controller: TextEditingController(
                text: DateFormat('dd/MM/yyyy').format(serviceDate),
              ),
              decoration: const InputDecoration(
                labelText: 'Service Date',
                prefixIcon: Icon(Icons.calendar_today),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
