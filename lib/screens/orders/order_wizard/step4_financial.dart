import 'package:flutter/material.dart';
import '../../../../utils/validators.dart';

class Step4Financial extends StatelessWidget {
  final TextEditingController totalCostController;
  final TextEditingController advanceController;
  final String balanceAmount;
  final String paymentStatus;
  final String paymentMode;
  final Function(String) onPaymentStatusChanged;
  final Function(String) onPaymentModeChanged;

  const Step4Financial({
    super.key,
    required this.totalCostController,
    required this.advanceController,
    required this.balanceAmount,
    required this.paymentStatus,
    required this.paymentMode,
    required this.onPaymentStatusChanged,
    required this.onPaymentModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Financial Details', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Record charges and advance payments.', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 24),
        TextFormField(
          controller: totalCostController,
          decoration: const InputDecoration(labelText: 'Total Service Charge (₹)', prefixIcon: Icon(Icons.currency_rupee)),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: advanceController,
          decoration: const InputDecoration(labelText: 'Advance Payment (₹)', prefixIcon: Icon(Icons.payments)),
          keyboardType: TextInputType.number,
          validator: Validators.amount,
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Balance Amount:', 
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '₹$balanceAmount', 
                    style: TextStyle(
                      fontSize: 20, 
                      fontWeight: FontWeight.bold, 
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: paymentStatus,
                decoration: const InputDecoration(labelText: 'Status'),
                items: ['Paid', 'Partial', 'Unpaid'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => onPaymentStatusChanged(v!),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: paymentMode,
                decoration: const InputDecoration(labelText: 'Mode'),
                items: ['Cash', 'UPI'].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                onChanged: (v) => onPaymentModeChanged(v!),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
