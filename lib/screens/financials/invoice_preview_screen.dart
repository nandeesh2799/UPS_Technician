import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order_model.dart';
import '../../providers/settings_provider.dart';
import '../../services/pdf_service.dart';

class InvoicePreviewScreen extends StatelessWidget {
  final OrderModel order;

  const InvoicePreviewScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Preview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () async {
              final settings = context.read<SettingsProvider>().settings;
              await PdfService.generateAndShareInvoice(order, settings);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.picture_as_pdf, size: 80, color: Colors.red),
            const SizedBox(height: 24),
            Text('Invoice Ready for Order ${order.id}', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            const Text('Tap the share icon above to generate PDF\nand send it via WhatsApp or Email.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () async {
                final settings = context.read<SettingsProvider>().settings;
                await PdfService.generateAndShareInvoice(order, settings);
              },
              icon: const Icon(Icons.share),
              label: const Text('Generate & Share'),
            ),
          ],
        ),
      ),
    );
  }
}
