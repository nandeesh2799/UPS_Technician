import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  final String id;
  final String customerId;
  final String customerName;
  final String phone;
  final DateTime appointmentDate;
  final String serviceType;
  final String status; // Pending, Confirmed, Completed, Cancelled
  final String notes;
  final String? technicianId;
  final DateTime createdAt;

  AppointmentModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.phone,
    required this.appointmentDate,
    required this.serviceType,
    required this.status,
    this.notes = '',
    this.technicianId,
    required this.createdAt,
  });

  factory AppointmentModel.fromMap(Map<String, dynamic> data, String documentId) {
    return AppointmentModel(
      id: documentId,
      customerId: data['customerId'] ?? '',
      customerName: data['customerName'] ?? '',
      phone: data['phone'] ?? '',
      appointmentDate: _toDateTime(data['appointmentDate']),
      serviceType: data['serviceType'] ?? 'General Service',
      status: data['status'] ?? 'Pending',
      notes: data['notes'] ?? '',
      technicianId: data['technicianId'],
      createdAt: _toDateTime(data['createdAt']),
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
      'customerId': customerId,
      'customerName': customerName,
      'phone': phone,
      'appointmentDate': appointmentDate,
      'serviceType': serviceType,
      'status': status,
      'notes': notes,
      'technicianId': technicianId,
      'createdAt': createdAt,
    };
  }

  AppointmentModel copyWith({
    String? status,
    String? notes,
    String? technicianId,
    DateTime? appointmentDate,
  }) {
    return AppointmentModel(
      id: id,
      customerId: customerId,
      customerName: customerName,
      phone: phone,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      serviceType: serviceType,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      technicianId: technicianId ?? this.technicianId,
      createdAt: createdAt,
    );
  }
}
