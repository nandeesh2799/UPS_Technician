import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../models/company_settings_model.dart';
import '../../utils/extensions.dart';

class InvoiceSettingsScreen extends StatefulWidget {
  const InvoiceSettingsScreen({super.key});

  @override
  State<InvoiceSettingsScreen> createState() => _InvoiceSettingsScreenState();
}

class _InvoiceSettingsScreenState extends State<InvoiceSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _prefixController;
  late TextEditingController _numberController;
  late TextEditingController _termsController;
  late TextEditingController _upiIdController;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>().settings;
    _prefixController = TextEditingController(text: settings.invoicePrefix);
    _numberController = TextEditingController(text: settings.nextInvoiceNumber.toString());
    _termsController = TextEditingController(text: settings.termsText);
    _upiIdController = TextEditingController(text: settings.upiId);
  }

  @override
  void dispose() {
    _prefixController.dispose();
    _numberController.dispose();
    _termsController.dispose();
    _upiIdController.dispose();
    super.dispose();
  }

  void _save() async {
    final capturedContext = context;
    if (_formKey.currentState!.validate()) {
      final current = capturedContext.read<SettingsProvider>().settings;
      final updated = CompanySettingsModel(
        name: current.name,
        address: current.address,
        phone: current.phone,
        email: current.email,
        gstNumber: current.gstNumber,
        logoUrl: current.logoUrl,
        invoicePrefix: _prefixController.text,
        nextInvoiceNumber: int.tryParse(_numberController.text) ?? current.nextInvoiceNumber,
        upiQrUrl: current.upiQrUrl,
        upiId: _upiIdController.text,
        googleReviewUrl: current.googleReviewUrl,
        termsText: _termsController.text,
        whatsappCountryCode: current.whatsappCountryCode,
        templateJobReceived: current.templateJobReceived,
        templateJobCompleted: current.templateJobCompleted,
        templateWarrantyReminder: current.templateWarrantyReminder,
        templatePaymentReminder: current.templatePaymentReminder,
        templateReviewPrompt: current.templateReviewPrompt,
      );
      
      await capturedContext.read<SettingsProvider>().updateSettings(updated);
      if (!capturedContext.mounted) return;
      capturedContext.showSuccessSnackBar('Invoice settings updated');
      Navigator.pop(capturedContext);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Invoice & Payment Settings')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _prefixController,
              decoration: const InputDecoration(labelText: 'Invoice Prefix (e.g. INV-)', border: OutlineInputBorder()),
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _numberController,
              decoration: const InputDecoration(labelText: 'Next Invoice Number', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              validator: (v) => (v == null || int.tryParse(v) == null) ? 'Enter a valid number' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _upiIdController,
              decoration: const InputDecoration(labelText: 'UPI ID (for payment links)', hintText: 'merchant@upi', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _termsController,
              decoration: const InputDecoration(labelText: 'Terms & Conditions', border: OutlineInputBorder()),
              maxLines: 5,
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _save, 
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Save Settings'),
            ),
          ],
        ),
      ),
    );
  }
}
