import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../providers/order_provider.dart';
import '../providers/customer_provider.dart';
import '../providers/parts_provider.dart';
import '../providers/technician_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/appointment_provider.dart';
import '../providers/settings_provider.dart';
import '../screens/auth/login_screen.dart';
import '../utils/constants.dart';
import '../models/pending_operation_model.dart';
import '../widgets/confirmation_dialog.dart';

class LogoutHelper {
  static Future<void> logout(BuildContext context) async {
    final confirmed = await showConfirmationDialog(
      context,
      title: 'Logout',
      message: 'Are you sure you want to logout? Any unsynced changes will be lost.',
      confirmText: 'Logout',
      confirmColor: Colors.red,
    );

    if (confirmed != true) return;

    try {
      if (!context.mounted) return;
      // Clear all provider state
      context.read<OrderProvider>().clear();
      context.read<CustomerProvider>().clear();
      context.read<PartsProvider>().clear();
      context.read<TechnicianProvider>().clear();
      context.read<NotificationProvider>().clear();
      context.read<SettingsProvider>().reset();
      context.read<AppointmentProvider>().clear();
      
      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();
      
      // Clear and close Hive boxes
      if (Hive.isBoxOpen(AppConstants.pendingOperationsBox)) {
        final pendingBox = Hive.box<PendingOperationModel>(AppConstants.pendingOperationsBox);
        await pendingBox.clear();
      }
      
      // We keep settingsBox (for theme/etc) but could clear user-specific settings if any
      // await Hive.box(AppConstants.settingsBox).clear(); 

      await Hive.close();
      
      // Re-open essential boxes (main.dart expects them to be open)
      // Actually, if we are going to LoginScreen, we might not need them immediately,
      // but if the user logs back in without restarting the app, they need to be open.
      // Better to re-open them here or ensure they are opened on login.
      if (!Hive.isBoxOpen(AppConstants.pendingOperationsBox)) {
        await Hive.openBox<PendingOperationModel>(AppConstants.pendingOperationsBox);
      }
      if (!Hive.isBoxOpen(AppConstants.settingsBox)) {
        await Hive.openBox(AppConstants.settingsBox);
      }
      
      // Navigate to login, removing all routes
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: $e')),
      );
    }
  }
}
