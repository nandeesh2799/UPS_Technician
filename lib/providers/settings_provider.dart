import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/company_settings_model.dart';
import '../services/firebase_service.dart';
import '../services/hive_service.dart';

class SettingsProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  CompanySettingsModel _settings = CompanySettingsModel.defaultSettings();
  bool _isDarkMode = false;
  bool _isLoading = true;

  CompanySettingsModel get settings => _settings;
  bool get isDarkMode => false;
  bool get isLoading => _isLoading;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _isDarkMode = HiveService.getThemeMode();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        _settings = await _firebaseService.getSettings();
      } catch (e) {
        // Use defaults if offline/fails
      }
    }
    _isLoading = false;
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    HiveService.setThemeMode(_isDarkMode);
    notifyListeners();
  }

  Future<void> updateSettings(CompanySettingsModel newSettings) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    _settings = newSettings;
    notifyListeners();
    await _firebaseService.updateSettings(newSettings);
  }

  void reset() {
    _settings = CompanySettingsModel.defaultSettings();
    notifyListeners();
  }
}
