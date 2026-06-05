import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentModel {
  final String id;
  final String orderId;
  final String customerId;
  final String customerName;
  final double amount;
  final String paymentMode; // Cash, UPI, Card, Bank
  final DateTime date;
  final String referenceNumber; // UPI Txn ID, etc.

  PaymentModel({
    required this.id,
    required this.orderId,
    required this.customerId,
    required this.customerName,
    required this.amount,
    required this.paymentMode,
    required this.date,
    this.referenceNumber = '',
  });

  factory PaymentModel.fromMap(Map<String, dynamic> data, String documentId) {
    return PaymentModel(
      id: documentId,
      orderId: data['orderId'] ?? '',
      customerId: data['customerId'] ?? '',
      customerName: data['customerName'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      paymentMode: data['paymentMode'] ?? 'Cash',
      date: _toDateTime(data['date']),
      referenceNumber: data['referenceNumber'] ?? '',
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
      'orderId': orderId,
      'customerId': customerId,
      'customerName': customerName,
      'amount': amount,
      'paymentMode': paymentMode,
      'date': date,
      'referenceNumber': referenceNumber,
    };
  }
}
