import 'package:cloud_firestore/cloud_firestore.dart';

class CommunicationLogModel {
  final String id;
  final String orderId;
  final String customerId;
  final String method; // WhatsApp, SMS, Call
  final String message;
  final DateTime timestamp;
  final bool isSuccess;

  CommunicationLogModel({
    required this.id,
    required this.orderId,
    required this.customerId,
    required this.method,
    required this.message,
    required this.timestamp,
    this.isSuccess = true,
  });

  factory CommunicationLogModel.fromMap(Map<String, dynamic> data, String documentId) {
    return CommunicationLogModel(
      id: documentId,
      orderId: data['orderId'] ?? '',
      customerId: data['customerId'] ?? '',
      method: data['method'] ?? 'WhatsApp',
      message: data['message'] ?? '',
      timestamp: _toDateTime(data['timestamp']),
      isSuccess: data['isSuccess'] ?? true,
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
      'method': method,
      'message': message,
      'timestamp': timestamp,
      'isSuccess': isSuccess,
    };
  }
}
