import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'services/hive_service.dart';
import 'services/notification_service.dart';
import 'services/firebase_service.dart';
import 'utils/constants.dart';

import 'providers/auth_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/order_provider.dart';
import 'providers/customer_provider.dart';
import 'providers/technician_provider.dart';
import 'providers/parts_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/connectivity_provider.dart';
import 'providers/appointment_provider.dart';
import 'providers/branch_provider.dart';
import 'services/sync_service.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'utils/hive_adapters.dart';
import 'models/pending_operation_model.dart';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Set preferred orientation
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      debugPrint('Flutter Error: ${details.exception}');
    };
    
    // Step 1: Initialize Hive first, before anything else
    await Hive.initFlutter();
    
    // Step 2: Register all adapters before opening any box
    _registerHiveAdapters();
    
    // Step 3: Open all boxes with error handling
    await _openHiveBoxes();
    
    // Step 4: Initialize Firebase with error handling
    await _initFirebase();
    
    // Initialize essential local services
    try {
      await HiveService.init();
      await NotificationService.init();
      fb.FirebaseAuth.instance.authStateChanges().listen((user) async {
        if (user != null) {
          SyncService.instance.initialize();
          // Update FCM Token
          final token = await NotificationService.getToken();
          if (token != null) {
            await FirebaseService().updateFcmToken(token);
          }
        } else {
          SyncService.instance.dispose();
        }
      });
    } catch (e) {
      debugPrint('Local services initialization failed: $e');
    }

    // Step 5: Run app
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
          ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => NotificationProvider()),
          ChangeNotifierProvider(create: (_) => OrderProvider()),
          ChangeNotifierProvider(create: (_) => CustomerProvider()),
          ChangeNotifierProvider(create: (_) => PartsProvider()),
          ChangeNotifierProvider(create: (_) => TechnicianProvider()),
          ChangeNotifierProvider(create: (_) => AppointmentProvider()),
          ChangeNotifierProvider(create: (_) => BranchProvider()),
        ],
        child: const MyApp(),
      ),
    );
    
  }, (error, stack) {
    debugPrint('Uncaught error: $error');
    debugPrint('Stack: $stack');
  });
}

void _registerHiveAdapters() {
  if (!Hive.isAdapterRegistered(20)) {
    Hive.registerAdapter(DateTimeAdapter());
  }
  if (!Hive.isAdapterRegistered(21)) {
    Hive.registerAdapter(NullableDateTimeAdapter());
  }
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(PendingOperationModelAdapter());
  }
}

Future<void> _openHiveBoxes() async {
  final boxesToOpen = [
    AppConstants.settingsBox,
    AppConstants.pendingOperationsBox,
    'failed_operations',
  ];
  
  for (final boxName in boxesToOpen) {
    try {
      if (!Hive.isBoxOpen(boxName)) {
        if (boxName == AppConstants.pendingOperationsBox) {
          await Hive.openBox<PendingOperationModel>(boxName);
        } else {
          await Hive.openBox(boxName);
        }
      }
    } catch (e) {
      debugPrint('Failed to open Hive box $boxName: $e');
      // Delete corrupted box and recreate it
      try {
        await Hive.deleteBoxFromDisk(boxName);
        if (boxName == AppConstants.pendingOperationsBox) {
          await Hive.openBox<PendingOperationModel>(boxName);
        } else {
          await Hive.openBox(boxName);
        }
      } catch (e2) {
        debugPrint('Could not recover box $boxName: $e2');
        // Continue without this box — app must not crash
      }
    }
  }
}

Future<void> _initFirebase() async {
  try {
    await Firebase.initializeApp();
    
    // Suppress App Check warning in development
    if (kDebugMode) {
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.debug,
      );
    }
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }
}
