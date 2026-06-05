import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/empty_state.dart';
import '../orders/widgets/order_card.dart';

class MyWorkloadScreen extends StatelessWidget {
  const MyWorkloadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userUid = context.read<AuthProvider>().user?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('My Workload')),
      body: Consumer<OrderProvider>(
        builder: (context, provider, child) {
          final myOrders = provider.orders.where((o) => o.technicianId == userUid && o.status != 'Completed').toList();

          if (myOrders.isEmpty) {
            return const EmptyState(
              icon: Icons.coffee,
              title: 'All caught up!',
              subtitle: 'You have no active orders assigned to you right now.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: myOrders.length,
            itemBuilder: (context, index) {
              return OrderCard(order: myOrders[index]);
            },
          );
        },
      ),
    );
  }
}
