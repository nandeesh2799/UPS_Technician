import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../models/company_settings_model.dart';
import '../../utils/extensions.dart';

class TemplateEditorScreen extends StatefulWidget {
  const TemplateEditorScreen({super.key});

  @override
  State<TemplateEditorScreen> createState() => _TemplateEditorScreenState();
}

class _TemplateEditorScreenState extends State<TemplateEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _receivedController;
  late TextEditingController _completedController;
  late TextEditingController _warrantyController;
  late TextEditingController _paymentController;
  late TextEditingController _reviewController;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>().settings;
    _receivedController = TextEditingController(text: settings.templateJobReceived);
    _completedController = TextEditingController(text: settings.templateJobCompleted);
    _warrantyController = TextEditingController(text: settings.templateWarrantyReminder);
    _paymentController = TextEditingController(text: settings.templatePaymentReminder);
    _reviewController = TextEditingController(text: settings.templateReviewPrompt);
  }

  @override
  void dispose() {
    _receivedController.dispose();
    _completedController.dispose();
    _warrantyController.dispose();
    _paymentController.dispose();
    _reviewController.dispose();
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
        invoicePrefix: current.invoicePrefix,
        nextInvoiceNumber: current.nextInvoiceNumber,
        upiQrUrl: current.upiQrUrl,
        upiId: current.upiId,
        googleReviewUrl: current.googleReviewUrl,
        termsText: current.termsText,
        whatsappCountryCode: current.whatsappCountryCode,
        templateJobReceived: _receivedController.text,
        templateJobCompleted: _completedController.text,
        templateWarrantyReminder: _warrantyController.text,
        templatePaymentReminder: _paymentController.text,
        templateReviewPrompt: _reviewController.text,
      );
      
      await capturedContext.read<SettingsProvider>().updateSettings(updated);
      if (!capturedContext.mounted) return;
      capturedContext.showSuccessSnackBar('Templates updated successfully');
      Navigator.pop(capturedContext);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Communication Templates')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Available Placeholders: {name}, {brand}, {id}, {total}, {advance}, {balance}, {date}, {center_name}, {link}', 
              style: TextStyle(color: Colors.grey, fontSize: 11)),
            const SizedBox(height: 24),
            _buildField('Job Received', _receivedController),
            const SizedBox(height: 16),
            _buildField('Job Completed', _completedController),
            const SizedBox(height: 16),
            _buildField('Warranty Reminder', _warrantyController),
            const SizedBox(height: 16),
            _buildField('Payment Reminder', _paymentController),
            const SizedBox(height: 16),
            _buildField('Google Review Prompt', _reviewController),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _save, 
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Save Templates'),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                final defaults = CompanySettingsModel.defaultSettings();
                setState(() {
                  _receivedController.text = defaults.templateJobReceived;
                  _completedController.text = defaults.templateJobCompleted;
                  _warrantyController.text = defaults.templateWarrantyReminder;
                  _paymentController.text = defaults.templatePaymentReminder;
                  _reviewController.text = defaults.templateReviewPrompt;
                });
                if (mounted) {
                  context.showSuccessSnackBar('Loaded default templates. Click Save Templates to apply.');
                }
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                side: BorderSide(color: Theme.of(context).primaryColor),
              ),
              child: const Text('Reset to Default Templates'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        alignLabelWithHint: true,
      ),
      maxLines: 4,
      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
    );
  }
}
