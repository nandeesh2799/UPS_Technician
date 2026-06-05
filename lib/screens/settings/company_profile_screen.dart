import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/settings_provider.dart';
import '../../models/company_settings_model.dart';
import '../../utils/validators.dart';
import '../../services/storage_service.dart';

class CompanyProfileScreen extends StatefulWidget {
  const CompanyProfileScreen({super.key});

  @override
  State<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _googleReviewController;
  late TextEditingController _upiIdController;

  String _logoUrl = '';
  bool _isUploadingLogo = false;
  final StorageService _storageService = StorageService();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>().settings;
    _nameController = TextEditingController(text: settings.name);
    _addressController = TextEditingController(text: settings.address);
    _phoneController = TextEditingController(text: settings.phone);
    _emailController = TextEditingController(text: settings.email);
    _googleReviewController = TextEditingController(text: settings.googleReviewUrl);
    _upiIdController = TextEditingController(text: settings.upiId);
    _logoUrl = settings.logoUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _googleReviewController.dispose();
    _upiIdController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadLogo() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 70,
    );

    if (image == null) return;

    setState(() => _isUploadingLogo = true);
    try {
      final url = await _storageService.uploadImage(File(image.path), 'company_logo');
      setState(() {
        _logoUrl = url;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logo uploaded successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload logo: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingLogo = false);
      }
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final current = context.read<SettingsProvider>().settings;
      final updated = CompanySettingsModel(
        name: _nameController.text,
        address: _addressController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        gstNumber: '',
        logoUrl: _logoUrl,
        invoicePrefix: current.invoicePrefix,
        nextInvoiceNumber: current.nextInvoiceNumber,
        upiQrUrl: current.upiQrUrl,
        upiId: _upiIdController.text,
        googleReviewUrl: _googleReviewController.text,
        termsText: current.termsText,
        whatsappCountryCode: '+91',
        templateJobReceived: current.templateJobReceived,
        templateJobCompleted: current.templateJobCompleted,
        templateWarrantyReminder: current.templateWarrantyReminder,
        templatePaymentReminder: current.templatePaymentReminder,
        templateReviewPrompt: current.templateReviewPrompt,
      );
      context.read<SettingsProvider>().updateSettings(updated);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Profile'),
        actions: [IconButton(icon: const Icon(Icons.check), onPressed: _save)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      backgroundImage: _logoUrl.isNotEmpty ? CachedNetworkImageProvider(_logoUrl) : null,
                      child: _logoUrl.isEmpty
                          ? Icon(Icons.business, size: 50, color: Theme.of(context).primaryColor)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        radius: 18,
                        child: _isUploadingLogo
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : IconButton(
                                icon: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                                onPressed: _pickAndUploadLogo,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _nameController, 
                decoration: const InputDecoration(labelText: 'Company Name'),
                validator: Validators.required,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController, 
                decoration: const InputDecoration(labelText: 'Phone Number'),
                validator: Validators.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController, 
                decoration: const InputDecoration(labelText: 'Email Address'),
                validator: Validators.email,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _upiIdController, 
                decoration: const InputDecoration(labelText: 'UPI ID (for payments)', hintText: 'merchant@upi'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _googleReviewController, 
                decoration: const InputDecoration(labelText: 'Google Review URL'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController, 
                decoration: const InputDecoration(labelText: 'Complete Address'), 
                maxLines: 3,
                validator: Validators.required,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
