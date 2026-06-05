import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/settings_provider.dart';
import '../../utils/formatters.dart';
import '../../services/whatsapp_service.dart';
import '../../widgets/empty_state.dart';

class OutstandingDuesScreen extends StatelessWidget {
  const OutstandingDuesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Outstanding Dues'),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, provider, child) {
          final dueOrders = provider.orders.where((o) => o.balanceAmount > 0).toList()
            ..sort((a, b) => b.balanceAmount.compareTo(a.balanceAmount)); // Sort amount desc

          if (dueOrders.isEmpty) {
            return const EmptyState(icon: Icons.check_circle_outline, title: 'All Clear!', subtitle: 'No outstanding dues from any customer.');
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: dueOrders.length,
            itemBuilder: (context, index) {
              final order = dueOrders[index];
              final daysOverdue = DateTime.now().difference(order.serviceDate).inDays;
              Color daysColor = daysOverdue > 30 ? Colors.red : (daysOverdue > 15 ? Colors.orange : Colors.grey);

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              order.customerName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                Formatters.currency(order.balanceAmount), 
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold, 
                                  fontSize: 18, 
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Order ID: ${order.id} • Total: ${Formatters.currency(order.totalAmount)}', style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text('$daysOverdue days overdue', style: TextStyle(color: daysColor, fontWeight: FontWeight.bold, fontSize: 12)),
                      const Divider(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            final settings = Provider.of<SettingsProvider>(context, listen: false).settings;
                            final template = settings.templatePaymentReminder.isNotEmpty
                                ? settings.templatePaymentReminder
                                : "==========================\n*{center_name}*\nOUTSTANDING DUE STATEMENT\n==========================\nJob ID  : {id}\nCustomer: {name}\n--------------------------\nCURRENT OUTSTANDING DUE:\n*₹{balance}*\n--------------------------\nDear {name},\n\nThis is a formal notification regarding the outstanding balance for your service order.\n\nKindly facilitate payment at your earliest convenience.\n\nThank you for your cooperation.\n==========================\nPOWERED BY UPS SERVICE MANAGER";
                            final message = WhatsAppService.formatTemplate(template, {
                              'name': order.customerName,
                              'id': order.id,
                              'balance': order.balanceAmount.toStringAsFixed(2),
                              'center_name': settings.name,
                            });
                            WhatsAppService.sendMessage(
                              phone: order.phone, 
                              message: message,
                              countryCode: settings.whatsappCountryCode,
                            );
                          },
                          icon: const Icon(Icons.chat, color: Colors.teal),
                          label: const Text('Send WhatsApp Reminder'),
                        ),
                      ),                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
