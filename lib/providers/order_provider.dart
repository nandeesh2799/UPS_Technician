import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../models/payment_model.dart';
import '../services/firebase_service.dart';

class OrderProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  List<OrderModel> _orders = [];
  bool _isLoading = true;
  String? _error;
  StreamSubscription? _ordersSub;
  StreamSubscription? _authSub;

  // Pagination state
  DocumentSnapshot? _lastDoc;
  bool _hasMore = true;
  bool _isFetchingMore = false;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;
  bool get isFetchingMore => _isFetchingMore;

  // Filtered views (Local filtering on loaded data)
  List<OrderModel> get pendingOrders => _orders.where((o) => o.status == 'Pending').toList();
  List<OrderModel> get inProgressOrders => _orders.where((o) => o.status == 'In Progress' || o.status == 'Assigned').toList();
  List<OrderModel> get completedOrders => _orders.where((o) => o.status == 'Completed').toList();
  
  List<OrderModel> get expiringWarranties {
    final now = DateTime.now();
    return _orders.where((o) {
      if (!o.hasWarranty || o.warrantyEnd == null) return false;
      final difference = o.warrantyEnd!.difference(now).inDays;
      return difference >= 0 && difference <= 30;
    }).toList();
  }

  double get totalRevenue => _orders.fold(0.0, (total, order) {
        final amountPaid = order.paymentStatus == 'Paid' ? order.totalAmount : order.advancePayment;
        return total + amountPaid;
      });
  double get totalDues => _orders.where((o) => o.balanceAmount > 0).fold(0.0, (total, order) => total + order.balanceAmount);

  double get currentMonthRevenue {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    return _orders.where((o) => o.serviceDate.isAfter(thirtyDaysAgo)).fold(0.0, (total, order) {
      final amountPaid = order.paymentStatus == 'Paid' ? order.totalAmount : order.advancePayment;
      return total + amountPaid;
    });
  }

  double get previousMonthRevenue {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final sixtyDaysAgo = now.subtract(const Duration(days: 60));
    return _orders.where((o) => o.serviceDate.isAfter(sixtyDaysAgo) && o.serviceDate.isBefore(thirtyDaysAgo)).fold(0.0, (total, order) {
      final amountPaid = order.paymentStatus == 'Paid' ? order.totalAmount : order.advancePayment;
      return total + amountPaid;
    });
  }

  String get monthlyPerformancePercentage {
    final current = currentMonthRevenue;
    final previous = previousMonthRevenue;
    if (previous == 0.0) {
      if (current == 0.0) {
        return 'No revenue this month';
      }
      return 'First month with revenue!';
    }
    final change = ((current - previous) / previous) * 100;
    final direction = change >= 0 ? 'increase' : 'decrease';
    return '${change.abs().toStringAsFixed(0)}% $direction from last month';
  }

  bool? get isRevenueTrendUp {
    final current = currentMonthRevenue;
    final previous = previousMonthRevenue;
    if (previous == 0.0) {
      return current > 0.0 ? true : null;
    }
    if (current == previous) return null;
    return current > previous;
  }

  Map<DateTime, double> get revenueByDay {
    final Map<DateTime, double> revenueMap = {};
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    for (var order in _orders) {
      final amountPaid = order.paymentStatus == 'Paid' ? order.totalAmount : order.advancePayment;
      if (amountPaid > 0 && order.serviceDate.isAfter(thirtyDaysAgo)) {
        final date = DateTime(order.serviceDate.year, order.serviceDate.month, order.serviceDate.day);
        revenueMap[date] = (revenueMap[date] ?? 0) + amountPaid;
      }
    }
    return revenueMap;
  }

  Map<String, int> get orderStatusDistribution {
    final Map<String, int> dist = {};
    for (var order in _orders) {
      dist[order.status] = (dist[order.status] ?? 0) + 1;
    }
    return dist;
  }

  Map<String, int> get serviceTypeDistribution {
    final Map<String, int> dist = {};
    for (var order in _orders) {
      dist[order.serviceType] = (dist[order.serviceType] ?? 0) + 1;
    }
    return dist;
  }

  OrderProvider() {
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _initOrdersStream();
      } else {
        _ordersSub?.cancel();
        _orders = [];
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  void _initOrdersStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Keep real-time for the first page (20 items)
    try {
      _ordersSub?.cancel();
      _ordersSub = _firebaseService.getOrders().listen((orderList) {
        _orders = orderList;
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

  // Explicit pagination method (if we were to switch away from full stream)
  Future<void> fetchNextPage() async {
    if (!_hasMore || _isFetchingMore) return;
    _isFetchingMore = true;
    notifyListeners();

    try {
      final snapshot = await _firebaseService.getOrdersPage(startAfter: _lastDoc);
      if (snapshot.docs.length < 20) _hasMore = false;
      if (snapshot.docs.isNotEmpty) {
        _lastDoc = snapshot.docs.last;
        final newOrders = snapshot.docs.map((doc) => OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
        
        // Merge without duplicates
        for (var o in newOrders) {
          if (!_orders.any((existing) => existing.id == o.id)) {
            _orders.add(o);
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
    _ordersSub?.cancel();
    _authSub?.cancel();
    super.dispose();
  }

  void _handleError(dynamic e) {
    _error = e.toString();
    _isLoading = false;
    notifyListeners();
  }

  void clear() {
    _orders = [];
    _lastDoc = null;
    _hasMore = true;
    _error = null;
    notifyListeners();
  }

  Future<void> addOrder(OrderModel order) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await _firebaseService.addOrder(order);

    // Log payment if any amount was paid
    final paidAmount = order.paymentStatus == 'Paid' ? order.totalAmount : order.advancePayment;
    if (paidAmount > 0) {
      final payment = PaymentModel(
        id: 'PAY-${DateTime.now().millisecondsSinceEpoch}',
        orderId: order.id,
        customerId: order.customerId,
        customerName: order.customerName,
        amount: paidAmount,
        paymentMode: order.paymentMode,
        date: DateTime.now(),
      );
      await _firebaseService.addPayment(payment);
    }
  }

  Future<void> updateOrder(OrderModel order) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Find the old order in local state to calculate payment difference
    OrderModel? oldOrder;
    try {
      oldOrder = _orders.firstWhere((o) => o.id == order.id);
    } catch (_) {
      oldOrder = null;
    }

    await _firebaseService.updateOrder(order);

    double oldPaid = 0.0;
    if (oldOrder != null) {
      oldPaid = oldOrder.paymentStatus == 'Paid' ? oldOrder.totalAmount : oldOrder.advancePayment;
    }
    
    double newPaid = order.paymentStatus == 'Paid' ? order.totalAmount : order.advancePayment;
    
    if (newPaid > oldPaid) {
      final payment = PaymentModel(
        id: 'PAY-${DateTime.now().millisecondsSinceEpoch}',
        orderId: order.id,
        customerId: order.customerId,
        customerName: order.customerName,
        amount: newPaid - oldPaid,
        paymentMode: order.paymentMode,
        date: DateTime.now(),
      );
      await _firebaseService.addPayment(payment);
    }
  }

  Future<void> deleteOrder(String id) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await _firebaseService.deleteOrder(id);
  }
}
