import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class CustomerModel {
  final String id;
  final String name;
  final String phone;
  final String address;
  final String email;
  final int totalOrders;
  final double totalSpend;
  final DateTime createdAt;
  final DateTime lastOrderDate;

  CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    this.email = '',
    this.totalOrders = 0,
    this.totalSpend = 0.0,
    required this.createdAt,
    required this.lastOrderDate,
  });

  factory CustomerModel.fromMap(Map<String, dynamic> data, String documentId) {
    return CustomerModel(
      id: documentId,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      email: data['email'] ?? '',
      totalOrders: data['totalOrders'] ?? 0,
      totalSpend: (data['totalSpend'] ?? 0).toDouble(),
      createdAt: _toDateTime(data['createdAt']),
      lastOrderDate: _toDateTime(data['lastOrderDate']),
    );
  }

  static DateTime _toDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return DateTime.now();
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
      'email': email,
      'totalOrders': totalOrders,
      'totalSpend': totalSpend,
      'createdAt': createdAt,
      'lastOrderDate': lastOrderDate,
    };
  }

  int get loyaltyScore {
    int score = (totalOrders * 10) + (totalSpend ~/ 1000);
    int daysSinceLastOrder = DateTime.now().difference(lastOrderDate).inDays;
    if (daysSinceLastOrder <= 30) {
      score += 20;
    } else if (daysSinceLastOrder <= 90) {
      score += 10;
    }
    return min(100, score);
  }

  String get segment {
    if (totalOrders >= 5 || totalSpend >= 10000) {
      return 'VIP';
    } else if (totalOrders == 0) {
      return 'New';
    } else {
      return 'Regular';
    }
  }

  CustomerModel copyWith({
    String? name,
    String? phone,
    String? address,
    String? email,
    int? totalOrders,
    double? totalSpend,
    DateTime? lastOrderDate,
  }) {
    return CustomerModel(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      email: email ?? this.email,
      totalOrders: totalOrders ?? this.totalOrders,
      totalSpend: totalSpend ?? this.totalSpend,
      createdAt: createdAt,
      lastOrderDate: lastOrderDate ?? this.lastOrderDate,
    );
  }
}
