import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/part_model.dart';
import '../services/firebase_service.dart';

class PartsProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  List<PartModel> _parts = [];
  bool _isLoading = true;
  StreamSubscription? _partsSub;
  StreamSubscription? _authSub;

  List<PartModel> get parts => _parts;
  bool get isLoading => _isLoading;
  
  List<PartModel> get lowStockParts => _parts.where((p) => p.isLowStock).toList();

  PartsProvider() {
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _initStream();
      } else {
        _partsSub?.cancel();
        _parts = [];
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  void _initStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      _partsSub?.cancel();
      _partsSub = _firebaseService.getParts().listen((list) {
        _parts = list;
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

  @override
  void dispose() {
    _partsSub?.cancel();
    _authSub?.cancel();
    super.dispose();
  }

  void clear() {
    _parts = [];
    notifyListeners();
  }

  Future<void> addPart(PartModel part) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await _firebaseService.addPart(part);
  }

  Future<void> updatePart(PartModel part) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await _firebaseService.updatePart(part);
  }

  Future<void> deletePart(String id) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await _firebaseService.deletePart(id);
  }
}
