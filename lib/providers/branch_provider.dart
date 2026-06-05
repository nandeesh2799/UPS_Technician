import 'dart:async';
import 'package:flutter/material.dart';
import '../models/center_model.dart';
import '../services/firebase_service.dart';

class BranchProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  List<CenterModel> _branches = [];
  bool _isLoading = true;
  StreamSubscription? _branchSub;

  List<CenterModel> get branches => _branches;
  bool get isLoading => _isLoading;

  BranchProvider() {
    _initStream();
  }

  void _initStream() {
    _branchSub?.cancel();
    _branchSub = _firebaseService.getCenters().listen((list) {
      _branches = list;
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      print('Error listening to branches: $e');
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> addBranch(CenterModel center) async {
    await _firebaseService.addCenter(center);
  }

  Future<void> updateBranch(CenterModel center) async {
    await _firebaseService.updateCenter(center);
  }

  @override
  void dispose() {
    _branchSub?.cancel();
    super.dispose();
  }
}
