import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../models/order_model.dart';
import '../../../providers/order_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../services/storage_service.dart';
import '../order_detail_screen.dart';

import 'step1_customer_intake.dart';
import 'step2_classification.dart';
import 'step3_diagnostics.dart';
import 'step4_financial.dart';
import 'step5_warranty.dart';
import 'step6_review.dart';

class OrderWizardScreen extends StatefulWidget {
  final OrderModel? order;
  const OrderWizardScreen({super.key, this.order});

  @override
  State<OrderWizardScreen> createState() => _OrderWizardScreenState();
}

class _OrderWizardScreenState extends State<OrderWizardScreen> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 5; // Updated to 5 steps including review
  bool _isLoading = false;
  final StorageService _storageService = StorageService();

  // Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController(text: '+91');
  final _addressController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _problemController = TextEditingController();
  final _remarksController = TextEditingController();
  final _totalCostController = TextEditingController(text: '0');
  final _advanceController = TextEditingController(text: '0');

  // State vars
  String _serviceType = 'Repair';
  String _status = 'Pending';
  String _priority = 'Normal';
  DateTime _serviceDate = DateTime.now();
  String _paymentStatus = 'Unpaid';
  String _paymentMode = 'Cash';
  String _balanceAmount = '0.00';
  bool _hasWarranty = false;
  DateTime? _warrantyStart;
  DateTime? _warrantyEnd;
  List<String> _photoUrls = [];

  @override
  void initState() {
    super.initState();
    if (widget.order != null) {
      _nameController.text = widget.order!.customerName;
      _phoneController.text = widget.order!.phone;
      _addressController.text = widget.order!.address;
      _brandController.text = widget.order!.upsBrand;
      _modelController.text = widget.order!.upsModel;
      _problemController.text = widget.order!.problemDescription;
      _remarksController.text = widget.order!.technicianRemarks;
      _totalCostController.text = widget.order!.serviceCost.toString();
      _advanceController.text = widget.order!.advancePayment.toString();
      
      _serviceType = widget.order!.serviceType;
      _status = widget.order!.status;
      _priority = widget.order!.priority;
      _serviceDate = widget.order!.serviceDate;
      _paymentStatus = widget.order!.paymentStatus;
      _paymentMode = widget.order!.paymentMode;
      _hasWarranty = widget.order!.hasWarranty;
      _warrantyStart = widget.order!.warrantyStart;
      _warrantyEnd = widget.order!.warrantyEnd;
      _photoUrls = List<String>.from(widget.order!.photos);
    }

    _totalCostController.addListener(_calcBalance);
    _advanceController.addListener(_calcBalance);
    _calcBalance();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _problemController.dispose();
    _remarksController.dispose();
    _totalCostController.dispose();
    _advanceController.dispose();
    super.dispose();
  }

  void _calcBalance() {
    double total = double.tryParse(_totalCostController.text) ?? 0;
    double adv = double.tryParse(_advanceController.text) ?? 0;
    
    setState(() {
      if (_paymentStatus == 'Paid') {
        _balanceAmount = '0.00';
      } else {
        if (adv == 0) {
          _paymentStatus = 'Unpaid';
          _balanceAmount = total.toStringAsFixed(2);
        } else if (adv < total) {
          _paymentStatus = 'Partial';
          _balanceAmount = (total - adv).toStringAsFixed(2);
        } else {
          _paymentStatus = 'Paid';
          _balanceAmount = '0.00';
        }
      }
    });
  }

  Future<void> _uploadPhoto(File file) async {
    final capturedContext = context;
    setState(() => _isLoading = true);
    try {
      final url = await _storageService.uploadImage(file, 'temp_orders');
      if (!capturedContext.mounted) return;
      setState(() {
        _photoUrls.add(url);
      });
    } catch (e) {
      if (!capturedContext.mounted) return;
      ScaffoldMessenger.of(capturedContext).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _next() {
    if (_currentStep == 0 && !_formKey.currentState!.validate()) return;
    
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOutCubic);
    } else {
      _save();
    }
  }

  Future<void> _save() async {
    final capturedContext = context;
    setState(() => _isLoading = true);
    double total = double.tryParse(_totalCostController.text) ?? 0;
    
    final order = OrderModel(
      id: widget.order?.id ?? 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      customerId: widget.order?.customerId ?? 'CUST-${DateTime.now().millisecondsSinceEpoch}',
      customerName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      upsBrand: _brandController.text.trim(),
      upsModel: _modelController.text.trim(),
      problemDescription: _problemController.text.trim(),
      serviceType: _serviceType,
      status: _status,
      priority: _priority,
      serviceCost: total,
      advancePayment: double.tryParse(_advanceController.text) ?? 0,
      balanceAmount: double.tryParse(_balanceAmount) ?? 0,
      paymentStatus: _paymentStatus,
      paymentMode: _paymentMode,
      applyGst: false,
      gstAmount: 0.0,
      totalAmount: total,
      serviceDate: _serviceDate,
      hasWarranty: _hasWarranty,
      warrantyStart: _hasWarranty ? _warrantyStart : null,
      warrantyEnd: _hasWarranty ? _warrantyEnd : null,
      createdAt: widget.order?.createdAt ?? DateTime.now(),
      photos: _photoUrls,
    );

    try {
      if (widget.order == null) {
        await capturedContext.read<OrderProvider>().addOrder(order);
      } else {
        await capturedContext.read<OrderProvider>().updateOrder(order);
      }
      if (!capturedContext.mounted) return;
      Navigator.pushReplacement(capturedContext, MaterialPageRoute(builder: (_) => OrderDetailScreen(order: order)));
    } catch (e) {
      if (!capturedContext.mounted) return;
      ScaffoldMessenger.of(capturedContext).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.order == null ? 'Create Order' : 'Edit Order'),
        centerTitle: true,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : Column(
            children: [
              _buildProgressHeader(),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (i) => setState(() => _currentStep = i),
                    children: [
                      // Step 1: Customer
                      _buildStep(
                        title: 'Customer Details',
                        subtitle: 'Basic contact information',
                        child: Step1CustomerIntake(
                          nameController: _nameController, 
                          phoneController: _phoneController, 
                          addressController: _addressController
                        ),
                      ),
                      // Step 2: Service (Consolidated)
                      _buildStep(
                        title: 'Service & UPS Specs',
                        subtitle: 'Problem and device details',
                        child: Column(
                          children: [
                            Step2Classification(
                              serviceType: _serviceType, 
                              status: _status, 
                              priority: _priority, 
                              serviceDate: _serviceDate, 
                              onServiceTypeChanged: (v) => setState(() => _serviceType=v), 
                              onStatusChanged: (v) => setState(() => _status=v), 
                              onPriorityChanged: (v) => setState(() => _priority=v), 
                              onDateChanged: (d) => setState(() => _serviceDate=d)
                            ),
                            const SizedBox(height: 24),
                            Step3Diagnostics(
                              brandController: _brandController, 
                              modelController: _modelController, 
                              problemController: _problemController, 
                              remarksController: _remarksController,
                              photos: _photoUrls,
                              onPhotoAdded: _uploadPhoto,
                            ),
                          ],
                        ),
                      ),
                      // Step 3: Payment
                      _buildStep(
                        title: 'Payment Details',
                        subtitle: 'Cost and advance payment',
                        child: Step4Financial(
                          totalCostController: _totalCostController, 
                          advanceController: _advanceController, 
                          balanceAmount: _balanceAmount, 
                          paymentStatus: _paymentStatus, 
                          paymentMode: _paymentMode, 
                          onPaymentStatusChanged: (v) {
                             setState(() {
                               _paymentStatus = v;
                               if (v == 'Paid') {
                                 _balanceAmount = '0.00';
                               } else if (v == 'Unpaid') {
                                 double total = double.tryParse(_totalCostController.text) ?? 0;
                                 _balanceAmount = total.toStringAsFixed(2);
                               } else {
                                 double total = double.tryParse(_totalCostController.text) ?? 0;
                                 double adv = double.tryParse(_advanceController.text) ?? 0;
                                 _balanceAmount = (total - adv).toStringAsFixed(2);
                               }
                             });
                           }, 
                          onPaymentModeChanged: (v) => setState(() => _paymentMode=v), 
                        ),
                      ),
                      // Step 4: Warranty
                      _buildStep(
                        title: 'Warranty Status',
                        subtitle: 'Set warranty periods',
                        child: Step5Warranty(
                          hasWarranty: _hasWarranty, 
                          warrantyStart: _warrantyStart, 
                          warrantyEnd: _warrantyEnd, 
                          onHasWarrantyChanged: (v) => setState(() => _hasWarranty=v), 
                          onStartChanged: (d) => setState(() => _warrantyStart=d), 
                          onEndChanged: (d) => setState(() => _warrantyEnd=d)
                        ),
                      ),
                      // Step 5: Review
                      _buildStep(
                        title: 'Review Order',
                        subtitle: 'Verify all details before saving',
                        child: Step6Review(
                          data: {
                          'name': _nameController.text,
                          'phone': _phoneController.text,
                          'serviceType': _serviceType,
                          'status': _status,
                          'priority': _priority,
                          'brand': _brandController.text,
                          'model': _modelController.text,
                          'total': _totalCostController.text,
                          'advance': _advanceController.text,
                          'balance': _balanceAmount,
                          'paymentStatus': _paymentStatus,
                          'paymentMode': _paymentMode,
                          'photos': _photoUrls,
                          },                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _buildBottomActionNav(),
            ],
          ),
    );
  }

  Widget _buildStep({required String title, required String subtitle, required Widget child}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.dark)),
          const SizedBox(height: 4),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
          const SizedBox(height: 32),
          child,
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.05, end: 0);
  }

  Widget _buildProgressHeader() {
    final stepTitles = ['Customer', 'Service', 'Payment', 'Warranty', 'Review'];
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      child: Column(
        children: [
          Row(
            children: List.generate(_totalSteps, (i) {
              final isActive = i <= _currentStep;
              final isLast = i == _totalSteps - 1;
              return Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.primary : Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(
                            color: isActive ? Colors.white : Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: i < _currentStep ? AppColors.primary : Colors.grey.shade200,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_totalSteps, (i) {
              return Expanded(
                child: Center(
                  child: Text(
                    stepTitles[i],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: i == _currentStep ? FontWeight.bold : FontWeight.normal,
                      color: i == _currentStep ? AppColors.primary : Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionNav() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _pageController.previousPage(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOutCubic,
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Previous'),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _next,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(_currentStep == _totalSteps - 1 ? 'Complete Setup' : 'Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
