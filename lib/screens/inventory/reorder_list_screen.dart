import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/parts_provider.dart';
import '../../widgets/empty_state.dart';
import 'widgets/part_card.dart';

class ReorderListScreen extends StatelessWidget {
  const ReorderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reorder List'),
      ),
      body: Consumer<PartsProvider>(
        builder: (context, provider, child) {
          final lowStock = provider.lowStockParts;

          if (lowStock.isEmpty) {
            return const EmptyState(
              icon: Icons.check_circle,
              title: 'Stock is Healthy',
              subtitle: 'No parts are currently below their reorder threshold.',
            );
          }

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.red.withValues(alpha: 0.1),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${lowStock.length} items require immediate restocking.',
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: lowStock.length,
                  itemBuilder: (context, index) {
                    return PartCard(part: lowStock[index]);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
