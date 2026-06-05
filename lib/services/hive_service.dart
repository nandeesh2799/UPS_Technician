import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../utils/constants.dart';
import '../models/pending_operation_model.dart';

class HiveService {
  static Future<void> init() async {
    // Initialization moved to main.dart as per user instructions
  }

  // Settings
  static Future<void> saveSetting(String key, dynamic value) async {
    if (Hive.isBoxOpen(AppConstants.settingsBox)) {
      await Hive.box(AppConstants.settingsBox).put(key, value);
    } else {
      debugPrint('Hive box ${AppConstants.settingsBox} is not open');
    }
  }

  static dynamic getSetting(String key, {dynamic defaultValue}) {
    if (Hive.isBoxOpen(AppConstants.settingsBox)) {
      return Hive.box(AppConstants.settingsBox).get(key, defaultValue: defaultValue);
    }
    return defaultValue;
  }

  static bool getThemeMode() {
    return getSetting('isDarkMode', defaultValue: false);
  }

  static Future<void> setThemeMode(bool isDark) async {
    await saveSetting('isDarkMode', isDark);
  }

  // Pending Operations
  static Future<void> addPendingOperation(PendingOperationModel op) async {
    if (Hive.isBoxOpen(AppConstants.pendingOperationsBox)) {
      await Hive.box<PendingOperationModel>(AppConstants.pendingOperationsBox).add(op);
    } else {
      debugPrint('Hive box ${AppConstants.pendingOperationsBox} is not open');
    }
  }

  static List<PendingOperationModel> getPendingOperations() {
    if (Hive.isBoxOpen(AppConstants.pendingOperationsBox)) {
      return Hive.box<PendingOperationModel>(AppConstants.pendingOperationsBox).values.toList()..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    }
    return [];
  }

  static Future<void> clearPendingOperation(dynamic key) async {
    if (Hive.isBoxOpen(AppConstants.pendingOperationsBox)) {
      await Hive.box<PendingOperationModel>(AppConstants.pendingOperationsBox).delete(key);
    } else {
      debugPrint('Hive box ${AppConstants.pendingOperationsBox} is not open');
    }
  }
}
