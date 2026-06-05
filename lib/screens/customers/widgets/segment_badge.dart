import 'package:flutter/material.dart';

class SegmentBadge extends StatelessWidget {
  final String segment;

  const SegmentBadge({super.key, required this.segment});

  @override
  Widget build(BuildContext context) {
    Color color;
    if (segment == 'VIP') {
      color = Colors.amber.shade700;
    } else if (segment == 'New') {
      color = Colors.green;
    } else {
      color = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        segment,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
