import 'package:flutter/material.dart';
import '../../../models/part_model.dart';
import '../../../utils/formatters.dart';

class PartsUsedList extends StatelessWidget {
  final List<PartUsed> parts;

  const PartsUsedList({super.key, required this.parts});

  @override
  Widget build(BuildContext context) {
    if (parts.isEmpty) {
      return const Text('No parts used yet.', style: TextStyle(color: Colors.grey));
    }

    return Column(
      children: parts.map((p) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.memory, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text('${p.quantity}x @ ${Formatters.currency(p.unitPrice)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  Formatters.currency(p.totalPrice),
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }
}
