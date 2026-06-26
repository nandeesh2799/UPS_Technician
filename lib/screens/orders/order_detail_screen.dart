import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/order_model.dart';
import '../../providers/settings_provider.dart';
import '../../providers/order_provider.dart';
import '../../utils/formatters.dart';
import '../../utils/extensions.dart';
import '../../services/whatsapp_service.dart';
import '../../services/pdf_service.dart';
import '../../services/storage_service.dart';
import 'package:share_plus/share_plus.dart';
import '../../utils/upi_helper.dart';

import 'widgets/order_timeline.dart';
import 'widgets/status_chip.dart';
import 'widgets/priority_tag.dart';
import 'widgets/notes_thread.dart';
import 'widgets/photos_grid.dart';
import 'widgets/parts_used_list.dart';
import 'order_wizard/order_wizard_screen.dart';

class OrderDetailScreen extends StatefulWidget {
  final OrderModel order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  bool _isUpdating = false;
  bool _isGeneratingPdf = false;
  final StorageService _storageService = StorageService();

  Future<void> _updateStatus(OrderModel order, String newStatus) async {
    final capturedContext = context;
    setState(() => _isUpdating = true);
    try {
      final updatedOrder = order.copyWith(status: newStatus);
      await capturedContext.read<OrderProvider>().updateOrder(updatedOrder);
      if (!capturedContext.mounted) return;
      capturedContext.showSuccessSnackBar('Order marked as $newStatus');
    } catch (e) {
      if (!capturedContext.mounted) return;
      capturedContext.showErrorSnackBar('Failed to update status');
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Future<void> _generateInvoice(OrderModel order) async {
    final capturedContext = context;
    setState(() => _isGeneratingPdf = true);
    try {
      final settings = capturedContext.read<SettingsProvider>().settings;
      await PdfService.generateAndShareInvoice(order, settings);
      if (!capturedContext.mounted) return;
    } catch (e) {
      if (!capturedContext.mounted) return;
      capturedContext.showErrorSnackBar('Failed to generate PDF');
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  Future<void> _uploadPhoto(OrderModel order, File file) async {
    final capturedContext = context;
    setState(() => _isUpdating = true);
    try {
      final url = await _storageService.uploadImage(file, 'orders/${order.id}');
      if (!capturedContext.mounted) return;
      final updatedPhotos = List<String>.from(order.photos)..add(url);
      final updatedOrder = order.copyWith(photos: updatedPhotos);
      
      await capturedContext.read<OrderProvider>().updateOrder(updatedOrder);
      if (!capturedContext.mounted) return;
      capturedContext.showSuccessSnackBar('Photo added successfully');
    } catch (e) {
      if (!capturedContext.mounted) return;
      capturedContext.showErrorSnackBar('Upload failed: $e');
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Future<void> _deletePhoto(OrderModel order, int index) async {
    final capturedContext = context;
    setState(() => _isUpdating = true);
    try {
      final url = order.photos[index];
      await _storageService.deleteImage(url);
      
      final updatedPhotos = List<String>.from(order.photos)..removeAt(index);
      final updatedOrder = order.copyWith(photos: updatedPhotos);
      
      if (!capturedContext.mounted) return;
      await capturedContext.read<OrderProvider>().updateOrder(updatedOrder);
      if (!capturedContext.mounted) return;
      capturedContext.showSuccessSnackBar('Photo deleted successfully');
    } catch (e) {
      if (!capturedContext.mounted) return;
      capturedContext.showErrorSnackBar('Failed to delete photo');
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }



  void _generateUpiLink(OrderModel order) {
    final capturedContext = context;
    final settings = capturedContext.read<SettingsProvider>().settings;
    if (settings.upiId.isEmpty) {
      capturedContext.showErrorSnackBar('UPI ID not set in settings');
      return;
    }

    if (order.balanceAmount <= 0) {
      capturedContext.showInfoSnackBar('No balance due for this order');
      return;
    }

    final upiLink = UpiHelper.generateUpiLink(
      upiId: settings.upiId,
      payeeName: settings.name,
      amount: order.balanceAmount,
      transactionNote: 'Payment for Order ${order.id}',
    );

    final message = "==========================\n"
        "*${settings.name}*\n"
        "UPI PAYMENT REQUEST\n"
        "==========================\n"
        "Order ID  : ${order.id}\n"
        "Customer  : ${order.customerName}\n"
        "--------------------------\n"
        "AMOUNT TO PAY:\n"
        "*₹${order.balanceAmount.toStringAsFixed(2)}*\n"
        "--------------------------\n"
        "Dear ${order.customerName},\n\n"
        "Please pay the outstanding balance for your UPS service using the UPI link below:\n\n"
        "DIRECT UPI LINK:\n"
        "$upiLink\n\n"
        "Thank you for your business!\n"
        "==========================";

    Share.share(message);
  }

  void _shareReviewLink(OrderModel order) {
    final capturedContext = context;
    final settings = capturedContext.read<SettingsProvider>().settings;
    if (settings.googleReviewUrl.isEmpty) {
      capturedContext.showErrorSnackBar('Google Review URL not set in settings');
      return;
    }

    final template = settings.templateReviewPrompt.isNotEmpty
        ? settings.templateReviewPrompt
        : "==========================\n*{center_name}*\nFEEDBACK & REVIEW\n==========================\nDear {name},\n\nThank you for choosing {center_name}. We hope you are satisfied with our service.\n\nPlease take a moment to leave us a review here:\n{link}\n\nYour feedback helps us improve and serve you better!\n===========================";

    final message = WhatsAppService.formatTemplate(template, {
      'name': order.customerName,
      'center_name': settings.name,
      'link': settings.googleReviewUrl,
    });

    WhatsAppService.sendMessage(
      phone: order.phone, 
      message: message,
      countryCode: settings.whatsappCountryCode,
    );
  }

  Future<void> _logPickup(OrderModel order) async {
    final capturedContext = context;
    final date = await showDatePicker(
      context: capturedContext,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );
    if (date == null) return;
    if (!capturedContext.mounted) return;

    setState(() => _isUpdating = true);
    try {
      final updatedOrder = order.copyWith(
        status: 'Picked Up',
        pickupDate: date,
      );
      await capturedContext.read<OrderProvider>().updateOrder(updatedOrder);
      if (!capturedContext.mounted) return;
      capturedContext.showSuccessSnackBar('Pickup logged');
    } catch (e) {
      if (!capturedContext.mounted) return;
      capturedContext.showErrorSnackBar('Failed to log pickup');
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Future<void> _logDelivery(OrderModel order) async {
    final capturedContext = context;
    final date = await showDatePicker(
      context: capturedContext,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );
    if (date == null) return;
    if (!capturedContext.mounted) return;

    setState(() => _isUpdating = true);
    try {
      final updatedOrder = order.copyWith(
        status: 'Delivered',
        deliveryDate: date,
      );
      await capturedContext.read<OrderProvider>().updateOrder(updatedOrder);
      if (!capturedContext.mounted) return;
      capturedContext.showSuccessSnackBar('Delivery logged');
    } catch (e) {
      if (!capturedContext.mounted) return;
      capturedContext.showErrorSnackBar('Failed to log delivery');
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Future<void> _deleteOrder(BuildContext context, OrderModel order) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Order'),
          content: Text('Are you sure you want to delete order ${order.id}? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      if (!context.mounted) return;
      setState(() => _isUpdating = true);
      try {
        await context.read<OrderProvider>().deleteOrder(order.id);
        navigator.pop(); // Go back to the list
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Order deleted successfully'),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
      } catch (e) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Failed to delete order: $e'),
            backgroundColor: const Color(0xFFC62828),
          ),
        );
      } finally {
        if (mounted) setState(() => _isUpdating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Selector<OrderProvider, OrderModel>(
      selector: (context, provider) => provider.orders.firstWhere(
        (o) => o.id == widget.order.id, 
        orElse: () => widget.order
      ),
      builder: (context, order, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Order ${order.id}'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrderWizardScreen(order: order))),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () => _deleteOrder(context, order),
              ),
            ],
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OrderTimeline(currentStatus: order.status),
                    const SizedBox(height: 24),
                    _buildCustomerCard(context, order),
                    const SizedBox(height: 16),
                    _buildDeviceCard(context, order),
                    const SizedBox(height: 16),
                    _buildFinancialCard(context, order),
                    const SizedBox(height: 16),
                    _buildPartsCard(context, order),
                    const SizedBox(height: 16),
                    _buildWarrantyCard(context, order),
                    const SizedBox(height: 16),
                    _buildNotesCard(context, order),
                    const SizedBox(height: 16),

                    _buildPhotosCard(context, order),
                    const SizedBox(height: 80), // Padding for FAB
                  ],
                ),
              ),
              if (_isUpdating || _isGeneratingPdf)
                const Center(child: CircularProgressIndicator()),
            ],
          ),
          floatingActionButton: SpeedDial(
            heroTag: 'order_detail_speed_dial',
            icon: Icons.flash_on,
            activeIcon: Icons.close,
            spacing: 3,
            childPadding: const EdgeInsets.all(5),
            spaceBetweenChildren: 4,
            children: [
              SpeedDialChild(
                child: const Icon(Icons.delivery_dining),
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                label: 'Log Delivery',
                onTap: () => _logDelivery(order),
              ),
              SpeedDialChild(
                child: const Icon(Icons.local_shipping),
                backgroundColor: Colors.blueGrey,
                foregroundColor: Colors.white,
                label: 'Log Pickup',
                onTap: () => _logPickup(order),
              ),
              SpeedDialChild(
                child: const Icon(Icons.payment),
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                label: 'Share UPI Link',
                onTap: () => _generateUpiLink(order),
              ),
              SpeedDialChild(
                child: const Icon(Icons.rate_review),
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                label: 'Request Review',
                onTap: () => _shareReviewLink(order),
              ),

              SpeedDialChild(
                child: const Icon(Icons.check),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                label: 'Mark Complete',
                onTap: () => _updateStatus(order, 'Completed'),
              ),
              SpeedDialChild(
                child: const Icon(Icons.picture_as_pdf),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                label: 'Generate Invoice',
                onTap: () => _generateInvoice(order),
              ),
              SpeedDialChild(
                child: const Icon(Icons.chat),
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                label: 'WhatsApp Update',
                onTap: () {
                  final capturedContext = context;
                  final settings = Provider.of<SettingsProvider>(capturedContext, listen: false).settings;
                  
                  String message;
                  if (order.status == 'Completed') {
                    final template = settings.templateJobCompleted.isNotEmpty
                        ? settings.templateJobCompleted
                        : "==========================\n*{center_name}*\nTAX INVOICE / WORK COMPLETED\n==========================\nOrder ID  : {id}\nBrand     : {brand}\n--------------------------\nDear {name},\n\nYour {brand} UPS repair is complete and ready for collection.\n\nSUMMARY:\n• Total Amount  : ₹{total}\n• Advance Paid  : ₹{advance}\n• BALANCE DUE   : ₹{balance}\n==========================\nPlease collect your device at your convenience.\n\nThank you for your business!\n===========================";
                    message = WhatsAppService.formatTemplate(template, {
                      'name': order.customerName,
                      'brand': order.upsBrand,
                      'id': order.id,
                      'total': order.totalAmount.toStringAsFixed(2),
                      'advance': order.advancePayment.toStringAsFixed(2),
                      'balance': order.balanceAmount.toStringAsFixed(2),
                      'center_name': settings.name,
                    });
                  } else if (order.status == 'Pending') {
                    final template = settings.templateJobReceived.isNotEmpty
                        ? settings.templateJobReceived
                        : "==========================\n*{center_name}*\nJOB INTAKE CONFIRMATION\n==========================\nOrder ID  : {id}\nBrand     : {brand}\nStatus    : Received\n--------------------------\nDear {name},\n\nYour {brand} UPS has been successfully received.\n\nWe will inspect the device and update you with diagnostic details shortly.\n\nThank you for choosing us!\n===========================";
                    message = WhatsAppService.formatTemplate(template, {
                      'name': order.customerName,
                      'brand': order.upsBrand,
                      'id': order.id,
                      'center_name': settings.name,
                    });
                  } else {
                    message = "Dear ${order.customerName},\n\nThis is an update from ${settings.name} regarding your ${order.upsBrand} UPS (Order ID: ${order.id}).\n\nThe current status of your order is: *${order.status}*.\n\nWe will keep you informed of further updates.\n\nBest regards,\n${settings.name}";
                  }

                  WhatsAppService.sendMessage(
                    phone: order.phone, 
                    message: message,
                    countryCode: settings.whatsappCountryCode,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCustomerCard(BuildContext context, OrderModel order) {
    return _buildCard(context, 'Customer Details', [
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1), child: Icon(Icons.person, color: Theme.of(context).primaryColor)),
        title: Text(order.customerName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${order.phone}\n${order.address}', maxLines: 3, overflow: TextOverflow.ellipsis),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.call, color: Colors.green), 
              onPressed: () async {
                final capturedContext = context;
                final url = Uri.parse('tel:${order.phone}');
                try {
                  final success = await launchUrl(url, mode: LaunchMode.externalApplication);
                  if (!success && capturedContext.mounted) {
                    capturedContext.showErrorSnackBar('Could not launch dialer');
                  }
                } catch (e) {
                  if (capturedContext.mounted) capturedContext.showErrorSnackBar('Could not launch dialer');
                }
              }
            ),
            IconButton(
              icon: const Icon(Icons.message, color: Colors.teal), 
              onPressed: () async {
                final capturedContext = context;
                final url = Uri.parse('sms:${order.phone}');
                try {
                  final success = await launchUrl(url, mode: LaunchMode.externalApplication);
                  if (!success && capturedContext.mounted) {
                    capturedContext.showErrorSnackBar('Could not launch SMS');
                  }
                } catch (e) {
                  if (capturedContext.mounted) capturedContext.showErrorSnackBar('Could not launch SMS');
                }
              }
            ),
            IconButton(
              icon: const Icon(Icons.directions, color: Colors.blue), 
              tooltip: 'Navigate to customer location',
              onPressed: () async {
                final capturedContext = context;
                final encodedAddress = Uri.encodeComponent(order.address);
                final googleMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encodedAddress');
                final appleMapsUrl = Uri.parse('https://maps.apple.com/?q=$encodedAddress');
                
                try {
                  if (await canLaunchUrl(googleMapsUrl)) {
                    await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
                  } else if (await canLaunchUrl(appleMapsUrl)) {
                    await launchUrl(appleMapsUrl, mode: LaunchMode.externalApplication);
                  } else {
                    if (capturedContext.mounted) {
                      capturedContext.showErrorSnackBar('Could not launch maps navigation');
                    }
                  }
                } catch (e) {
                  if (capturedContext.mounted) {
                    capturedContext.showErrorSnackBar('Could not launch maps navigation');
                  }
                }
              }
            ),
          ],
        ),
      ),
    ]);
  }

  Widget _buildDeviceCard(BuildContext context, OrderModel order) {
    return _buildCard(context, 'Device & Issue', [
      _row('Brand / Model', '${order.upsBrand} / ${order.upsModel}', isBold: true),
      const SizedBox(height: 8),
      _row('Service Type', order.serviceType),
      const SizedBox(height: 8),
      _row('Priority', '', child: PriorityTag(priority: order.priority)),
      const SizedBox(height: 8),
      _row('Status', '', child: StatusChip(status: order.status)),
      const SizedBox(height: 8),
      const Text('Reported Problem:', style: TextStyle(color: Colors.grey, fontSize: 12)),
      const SizedBox(height: 4),
      Text(order.problemDescription, style: const TextStyle(fontWeight: FontWeight.w500)),
    ]);
  }

  Widget _buildFinancialCard(BuildContext context, OrderModel order) {
    return _buildCard(context, 'Financials', [
      _row('Total Amount', Formatters.currency(order.totalAmount), isBold: true),
      _row('Advance Paid', Formatters.currency(order.advancePayment)),
      _row('Balance Due', Formatters.currency(order.balanceAmount), isBold: true, valueColor: Theme.of(context).primaryColor),
      const Divider(),
      _row('Payment Mode', order.paymentMode),
      _row('Payment Status', order.paymentStatus),
    ]);
  }

  Widget _buildPartsCard(BuildContext context, OrderModel order) {
    return _buildCard(context, 'Parts Used', [
      PartsUsedList(parts: order.partsUsed),
    ]);
  }

  Widget _buildWarrantyCard(BuildContext context, OrderModel order) {
    if (!order.hasWarranty || order.warrantyStart == null || order.warrantyEnd == null) {
      return _buildCard(context, 'Warranty', [const Text('No warranty provided.')]);
    }
    
    final daysRemaining = order.warrantyEnd!.difference(DateTime.now()).inDays;
    Color color = Colors.green;
    if (daysRemaining < 0) {
      color = Colors.red;
    } else if (daysRemaining <= 30) {
      color = Colors.orange;
    }

    return _buildCard(context, 'Warranty', [
      _row('Start Date', Formatters.date(order.warrantyStart!)),
      _row('End Date', Formatters.date(order.warrantyEnd!)),
      const SizedBox(height: 8),
      Text(
        daysRemaining < 0 ? 'Expired' : '$daysRemaining days remaining',
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    ]);
  }

  Widget _buildNotesCard(BuildContext context, OrderModel order) {
    return _buildCard(context, 'Internal Notes', [
      NotesThread(notes: order.technicianNotes),
    ]);
  }

  Widget _buildPhotosCard(BuildContext context, OrderModel order) {
    return _buildCard(context, 'Photos', [
      PhotosGrid(
        photos: order.photos,
        isEditable: true,
        onPhotoAdded: (file) => _uploadPhoto(order, file),
        onPhotoDeleted: (index) => _deletePhoto(order, index),
      ),
    ]);
  }



  Widget _buildCard(BuildContext context, String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade500,
              letterSpacing: 1.2,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool isBold = false, Color? valueColor, Widget? child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 2,
            child: Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13), overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 8),
          if (child != null) child else Flexible(
            flex: 3,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                value, 
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w500, 
                  color: valueColor,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
