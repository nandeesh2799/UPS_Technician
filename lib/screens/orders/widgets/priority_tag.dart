import 'package:flutter/material.dart';

class PriorityTag extends StatelessWidget {
  final String priority;

  const PriorityTag({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (priority) {
      case 'Urgent':
        color = Colors.red;
        icon = Icons.priority_high;
        break;
      case 'Low':
        color = Colors.green;
        icon = Icons.low_priority;
        break;
      case 'Normal':
      default:
        color = Colors.amber.shade700;
        icon = Icons.horizontal_rule;
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          priority,
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
