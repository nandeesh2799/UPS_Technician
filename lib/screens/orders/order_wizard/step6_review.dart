import 'package:flutter/material.dart';

class Step6Review extends StatelessWidget {
  final Map<String, dynamic> data;

  const Step6Review({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Review Order', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Please verify the details before creating the order.', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              _buildSection(context, 'Customer', [
                _row('Name', data['name']),
                _row('Phone', data['phone']),
              ]),
              const Divider(height: 1),
              _buildSection(context, 'Service Details', [
                _row('Type', data['serviceType']),
                _row('Status', data['status']),
                _row('Priority', data['priority']),
                _row('Brand/Model', '${data['brand']} / ${data['model']}'),
              ]),
              const Divider(height: 1),
              _buildSection(context, 'Financials', [
                _row('Total', '₹${data['total']}'),
                _row('Advance', '₹${data['advance']}'),
                _row('Balance', '₹${data['balance']}', isBold: true),
                _row('Payment', '${data['paymentStatus']} via ${data['paymentMode']}'),
              ]),
              const Divider(height: 1),
              _buildSection(context, 'Attachments', [
                _row('Photos', '${(data['photos'] as List?)?.length ?? 0} uploaded'),
              ]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 2,
            child: Text(label, style: const TextStyle(color: Colors.grey), overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 16),
          Flexible(
            flex: 3,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                value,
                textAlign: TextAlign.end,
                maxLines: 1,
                style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
