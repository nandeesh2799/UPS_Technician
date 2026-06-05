import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../models/order_model.dart';

class PaymentModeChart extends StatelessWidget {
  final List<OrderModel> orders;
  const PaymentModeChart({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    double cashAmount = 0.0;
    double upiAmount = 0.0;

    for (var order in orders) {
      final amountPaid = order.paymentStatus == 'Paid' ? order.totalAmount : order.advancePayment;
      if (order.paymentMode == 'Cash') {
        cashAmount += amountPaid;
      } else if (order.paymentMode == 'UPI') {
        upiAmount += amountPaid;
      }
    }

    final total = cashAmount + upiAmount;
    final upiPercent = total > 0 ? (upiAmount / total) * 100 : 0.0;
    final cashPercent = total > 0 ? (cashAmount / total) * 100 : 0.0;

    final List<PieChartSectionData> sections = [];
    if (total == 0.0) {
      sections.add(PieChartSectionData(
        color: Colors.grey.shade300,
        value: 100,
        title: '0%',
        radius: 40,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      ));
    } else {
      if (upiAmount > 0) {
        sections.add(PieChartSectionData(
          color: Colors.green,
          value: upiAmount,
          title: '${upiPercent.toStringAsFixed(0)}%',
          radius: 40,
          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
        ));
      }
      if (cashAmount > 0) {
        sections.add(PieChartSectionData(
          color: Colors.blue,
          value: cashAmount,
          title: '${cashPercent.toStringAsFixed(0)}%',
          radius: 40,
          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
        ));
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payment Modes', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: sections,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _legend(context, 'UPI', Colors.green),
              _legend(context, 'Cash', Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legend(BuildContext context, String title, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(title, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
