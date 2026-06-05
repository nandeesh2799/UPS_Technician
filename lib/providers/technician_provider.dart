import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/technician_model.dart';
import '../services/firebase_service.dart';

class TechnicianProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  List<TechnicianModel> _technicians = [];
  bool _isLoading = true;
  StreamSubscription? _techSub;
  StreamSubscription? _authSub;

  List<TechnicianModel> get technicians => _technicians;
  bool get isLoading => _isLoading;

  TechnicianProvider() {
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _initStream();
      } else {
        _techSub?.cancel();
        _technicians = [];
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  void _initStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      _techSub?.cancel();
      _techSub = _firebaseService.getTechnicians().listen((list) {
        _technicians = list;
        _isLoading = false;
        notifyListeners();
      }, onError: (e) {
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _technicians = [];
    notifyListeners();
  }

  Future<void> addTechnician(TechnicianModel technician) async {
    await _firebaseService.addTechnician(technician);
    await _firebaseService.updateUserRole(technician.email, technician.role);
  }

  Future<void> updateTechnician(TechnicianModel technician) async {
    await _firebaseService.updateTechnician(technician);
    await _firebaseService.updateUserRole(technician.email, technician.role);
  }

  Future<void> deleteTechnician(String id) async {
    await _firebaseService.deleteTechnician(id);
  }

  @override
  void dispose() {
    _techSub?.cancel();
    _authSub?.cancel();
    super.dispose();
  }
}
