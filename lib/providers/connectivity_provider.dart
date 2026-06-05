import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/connectivity_service.dart';

class ConnectivityProvider extends ChangeNotifier {
  final ConnectivityService _service = ConnectivityService();
  bool _isOffline = false;

  bool get isOffline => _isOffline;

  ConnectivityProvider() {
    _initConnectivity();
  }

  Future<void> _initConnectivity() async {
    _isOffline = !(await _service.hasConnection());
    notifyListeners();

    _service.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      bool offline = !results.contains(ConnectivityResult.mobile) && 
                     !results.contains(ConnectivityResult.wifi) && 
                     !results.contains(ConnectivityResult.ethernet);
      if (_isOffline != offline) {
        _isOffline = offline;
        notifyListeners();
      }
    });
  }
}
