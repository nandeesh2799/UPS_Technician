import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/customer_model.dart';
import '../services/firebase_service.dart';

class CustomerProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  List<CustomerModel> _customers = [];
  bool _isLoading = true;
  String? _error;
  StreamSubscription? _customersSub;
  StreamSubscription? _authSub;

  // Pagination state
  DocumentSnapshot? _lastDoc;
  bool _hasMore = true;
  bool _isFetchingMore = false;

  List<CustomerModel> get customers => _customers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;
  bool get isFetchingMore => _isFetchingMore;

  CustomerProvider() {
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _initCustomersStream();
      } else {
        _customersSub?.cancel();
        _customers = [];
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  void _initCustomersStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      _customersSub?.cancel();
      _customersSub = _firebaseService.getCustomers().listen((customerList) {
        _customers = customerList;
        _isLoading = false;
        _error = null;
        _hasMore = false;
        notifyListeners();
      }, onError: (e) {
        _handleError(e);
      });
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> fetchNextPage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    if (!_hasMore || _isFetchingMore) return;
    _isFetchingMore = true;
    notifyListeners();

    try {
      final snapshot = await _firebaseService.getCustomersPage(startAfter: _lastDoc);
      if (snapshot.docs.length < 20) _hasMore = false;
      if (snapshot.docs.isNotEmpty) {
        _lastDoc = snapshot.docs.last;
        final newItems = snapshot.docs.map((doc) => CustomerModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
        
        for (var item in newItems) {
          if (!_customers.any((existing) => existing.id == item.id)) {
            _customers.add(item);
          }
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isFetchingMore = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _customersSub?.cancel();
    _authSub?.cancel();
    super.dispose();
  }

  void _handleError(dynamic e) {
    _error = e.toString();
    _isLoading = false;
    notifyListeners();
  }

  void clear() {
    _customers = [];
    _lastDoc = null;
    _hasMore = true;
    _error = null;
    notifyListeners();
  }

  Future<void> addCustomer(CustomerModel customer) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await _firebaseService.addCustomer(customer);
  }

  Future<void> updateCustomer(CustomerModel customer) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await _firebaseService.updateCustomer(customer);
  }
}
