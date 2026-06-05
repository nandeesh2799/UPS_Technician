import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateRangePickerWidget extends StatelessWidget {
  final DateTimeRange? initialRange;
  final Function(DateTimeRange) onRangeSelected;

  const DateRangePickerWidget({
    super.key,
    this.initialRange,
    required this.onRangeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final range = initialRange ?? DateTimeRange(start: DateTime.now().subtract(const Duration(days: 7)), end: DateTime.now());
    final df = DateFormat('dd MMM');

    return InkWell(
      onTap: () async {
        final newRange = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          initialDateRange: range,
        );
        if (newRange != null) {
          onRangeSelected(newRange);
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today, size: 16, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(
              '${df.format(range.start)} - ${df.format(range.end)}',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
