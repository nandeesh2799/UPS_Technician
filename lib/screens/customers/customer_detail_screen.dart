import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/settings_provider.dart';
import '../../providers/order_provider.dart';
import '../../models/customer_model.dart';
import '../../utils/formatters.dart';
import '../../utils/extensions.dart';
import '../../services/whatsapp_service.dart';
import '../orders/widgets/order_card.dart';
import 'widgets/loyalty_score_ring.dart';
import 'widgets/segment_badge.dart';
import 'customer_form_screen.dart';

class CustomerDetailScreen extends StatelessWidget {
  final CustomerModel customer;

  const CustomerDetailScreen({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit), 
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CustomerFormScreen(customer: customer))),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeaderCard(context),
            const SizedBox(height: 16),
            _buildStatsRow(context),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final settings = Provider.of<SettingsProvider>(context, listen: false).settings;
                      WhatsAppService.sendMessage(
                        phone: customer.phone, 
                        message: 'Dear ${customer.name},\n\nGreetings from ${settings.name}. Please let us know how we can assist you today.\n\nBest regards,\n${settings.name}',
                        countryCode: settings.whatsappCountryCode,
                      );
                    },
                    icon: const Icon(Icons.chat),
                    label: const Text('WhatsApp'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final url = Uri.parse('tel:${customer.phone}');
                      try {
                        final success = await launchUrl(url, mode: LaunchMode.externalApplication);
                        if (!success && context.mounted) {
                          context.showErrorSnackBar('Could not launch dialer');
                        }
                      } catch (e) {
                        if (context.mounted) context.showErrorSnackBar('Could not launch dialer');
                      }
                    },
                    icon: const Icon(Icons.call),
                    label: const Text('Call'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Order History', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            Consumer<OrderProvider>(
              builder: (context, orderProvider, _) {
                final orders = orderProvider.orders.where((o) => o.customerId == customer.id).toList();
                if (orders.isEmpty) {
                  return const Center(child: Text('No orders found', style: TextStyle(color: Colors.grey)));
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: orders.length,
                  itemBuilder: (context, index) => OrderCard(order: orders[index]),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          LoyaltyScoreRing(score: customer.loyaltyScore),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(customer.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))),
                    SegmentBadge(segment: customer.segment),
                  ],
                ),
                const SizedBox(height: 8),
                Row(children: [const Icon(Icons.phone, size: 16, color: Colors.grey), const SizedBox(width: 4), Expanded(child: Text(customer.phone, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey)))]),
                const SizedBox(height: 4),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.location_on, size: 16, color: Colors.grey), const SizedBox(width: 4), Expanded(child: Text(customer.address, style: const TextStyle(color: Colors.grey)))]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Row(
      children: [
        _statBox(context, 'Total Orders', customer.totalOrders.toString(), Icons.shopping_bag),
        const SizedBox(width: 16),
        _statBox(context, 'Total Spend', Formatters.currency(customer.totalSpend), Icons.account_balance_wallet),
      ],
    );
  }

  Widget _statBox(BuildContext context, String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
