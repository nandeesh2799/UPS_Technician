import 'package:flutter/material.dart';
import '../../../models/payment_model.dart';
import '../../../utils/formatters.dart';

class TransactionList extends StatelessWidget {
  final List<PaymentModel> payments;

  const TransactionList({super.key, required this.payments});

  @override
  Widget build(BuildContext context) {
    if (payments.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No transactions found.', style: TextStyle(color: Colors.grey))));
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: payments.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final pay = payments[index];
        IconData icon;
        Color color;

        switch (pay.paymentMode) {
          case 'UPI': icon = Icons.qr_code; color = Colors.green; break;
          case 'Card': icon = Icons.credit_card; color = Colors.orange; break;
          case 'Bank': icon = Icons.account_balance; color = Colors.purple; break;
          case 'Cash': default: icon = Icons.money; color = Colors.blue; break;
        }

        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color),
          ),
          title: Text(
            pay.customerName, 
            maxLines: 1, 
            overflow: TextOverflow.ellipsis, 
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text('${Formatters.date(pay.date)} • ${pay.paymentMode}\nRef: ${pay.referenceNumber.isEmpty ? "N/A" : pay.referenceNumber}'),
          isThreeLine: true,
          trailing: SizedBox(
            width: 80,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                Formatters.currency(pay.amount), 
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        );
      },
    );
  }
}
