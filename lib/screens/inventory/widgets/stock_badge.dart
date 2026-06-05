import 'package:flutter/material.dart';

class StockBadge extends StatelessWidget {
  final int qty;
  final int threshold;

  const StockBadge({super.key, required this.qty, required this.threshold});

  @override
  Widget build(BuildContext context) {
    bool isLow = qty <= threshold;
    Color color = isLow ? Colors.red : Colors.green;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isLow ? Icons.warning_amber_rounded : Icons.inventory_2, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            '$qty in stock',
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
