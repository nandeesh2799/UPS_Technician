import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/appointment_model.dart';
import '../services/firebase_service.dart';

class AppointmentProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  List<AppointmentModel> _appointments = [];
  bool _isLoading = true;
  String? _error;
  StreamSubscription? _sub;
  StreamSubscription? _authSub;

  List<AppointmentModel> get appointments => _appointments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<AppointmentModel> get todayAppointments {
    final now = DateTime.now();
    return _appointments.where((a) {
      return a.appointmentDate.year == now.year &&
             a.appointmentDate.month == now.month &&
             a.appointmentDate.day == now.day;
    }).toList();
  }

  List<AppointmentModel> get upcomingAppointments {
    final now = DateTime.now();
    return _appointments.where((a) => a.appointmentDate.isAfter(now)).toList();
  }

  AppointmentProvider() {
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _initStream();
      } else {
        _sub?.cancel();
        _appointments = [];
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  void _initStream() {
    _isLoading = true;
    notifyListeners();

    _sub?.cancel();
    _sub = _firebaseService.getAppointments().listen((list) {
      _appointments = list;
      _isLoading = false;
      _error = null;
      notifyListeners();
    }, onError: (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> addAppointment(AppointmentModel appointment) async {
    await _firebaseService.addAppointment(appointment);
  }

  Future<void> updateAppointment(AppointmentModel appointment) async {
    await _firebaseService.updateAppointment(appointment);
  }

  Future<void> deleteAppointment(String id) async {
    await _firebaseService.deleteAppointment(id);
  }

  void clear() {
    _appointments = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _authSub?.cancel();
    super.dispose();
  }
}
