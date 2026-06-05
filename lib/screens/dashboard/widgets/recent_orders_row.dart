import 'package:flutter/material.dart';
import '../../../models/order_model.dart';
import '../../orders/widgets/order_card.dart';

class RecentOrdersRow extends StatelessWidget {
  final List<OrderModel> orders;

  const RecentOrdersRow({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const Center(child: Text('No recent orders', style: TextStyle(color: Colors.grey)));
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        cacheExtent: 1000,
        itemCount: orders.length > 5 ? 5 : orders.length,
        itemBuilder: (context, index) {
          return Container(
            width: 300,
            margin: const EdgeInsets.only(right: 16),
            child: OrderCard(order: orders[index], isCompact: true),
          );
        },
      ),
    );
  }
}
