import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case 'Pending':
        bgColor = Colors.orange.withValues(alpha: 0.1);
        textColor = Colors.orange.shade800;
        break;
      case 'In Progress':
      case 'Assigned':
        bgColor = Colors.blue.withValues(alpha: 0.1);
        textColor = Colors.blue.shade800;
        break;
      case 'Waiting for Parts':
        bgColor = Colors.purple.withValues(alpha: 0.1);
        textColor = Colors.purple.shade800;
        break;
      case 'Completed':
      case 'Delivered':
        bgColor = Colors.green.withValues(alpha: 0.1);
        textColor = Colors.green.shade800;
        break;
      case 'Cancelled':
        bgColor = Colors.red.withValues(alpha: 0.1);
        textColor = Colors.red.shade800;
        break;
      default:
        bgColor = Colors.grey.withValues(alpha: 0.1);
        textColor = Colors.grey.shade800;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withValues(alpha: 0.2)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: textColor, 
          fontSize: 10, 
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
