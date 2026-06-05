import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Step5Warranty extends StatelessWidget {
  final bool hasWarranty;
  final DateTime? warrantyStart;
  final DateTime? warrantyEnd;
  final Function(bool) onHasWarrantyChanged;
  final Function(DateTime) onStartChanged;
  final Function(DateTime) onEndChanged;

  const Step5Warranty({
    super.key,
    required this.hasWarranty,
    required this.warrantyStart,
    required this.warrantyEnd,
    required this.onHasWarrantyChanged,
    required this.onStartChanged,
    required this.onEndChanged,
  });

  Widget _buildPresetChip(BuildContext context, String label) {
    final start = warrantyStart ?? DateTime.now();
    DateTime targetEnd;
    if (label == '3 Months') {
      targetEnd = DateTime(start.year, start.month + 3, start.day);
    } else if (label == '6 Months') {
      targetEnd = DateTime(start.year, start.month + 6, start.day);
    } else {
      targetEnd = DateTime(start.year + 1, start.month, start.day);
    }

    final isSelected = warrantyEnd != null && 
        warrantyEnd!.year == targetEnd.year && 
        warrantyEnd!.month == targetEnd.month && 
        warrantyEnd!.day == targetEnd.day;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: ChoiceChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              onEndChanged(targetEnd);
            }
          },
          selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.15),
          checkmarkColor: Theme.of(context).primaryColor,
          labelStyle: TextStyle(
            color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyMedium?.color,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Warranty Information', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Set warranty period for the provided service or parts.', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 24),
        SwitchListTile(
          title: const Text('Include Warranty'),
          value: hasWarranty,
          onChanged: onHasWarrantyChanged,
          contentPadding: EdgeInsets.zero,
        ),
        if (hasWarranty) ...[
          const SizedBox(height: 20),
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: warrantyStart ?? DateTime.now(),
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 3650)),
              );
              if (date != null) onStartChanged(date);
            },
            child: IgnorePointer(
              child: TextFormField(
                controller: TextEditingController(
                  text: warrantyStart == null ? '' : DateFormat('dd/MM/yyyy').format(warrantyStart!),
                ),
                decoration: const InputDecoration(
                  labelText: 'Warranty Starts',
                  prefixIcon: Icon(Icons.calendar_month),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Select Warranty Period:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPresetChip(context, '3 Months'),
              _buildPresetChip(context, '6 Months'),
              _buildPresetChip(context, '1 Year'),
            ],
          ),
          const SizedBox(height: 20),
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: warrantyEnd ?? (warrantyStart ?? DateTime.now()),
                firstDate: warrantyStart ?? DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 3650)),
              );
              if (date != null) onEndChanged(date);
            },
            child: IgnorePointer(
              child: TextFormField(
                controller: TextEditingController(
                  text: warrantyEnd == null ? '' : DateFormat('dd/MM/yyyy').format(warrantyEnd!),
                ),
                decoration: const InputDecoration(
                  labelText: 'Custom Warranty Ends',
                  prefixIcon: Icon(Icons.event_available),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
