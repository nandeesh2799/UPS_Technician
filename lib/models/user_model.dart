import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String role;
  final String centerId;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    required this.centerId,
    required this.createdAt,
  });

  bool get isAdmin => role == AppConstants.roleAdmin;
  bool get isTechnician => role == AppConstants.roleTechnician;
  bool get isViewer => role == AppConstants.roleViewer;

  bool get canManageTechnicians => isAdmin;
  bool get canViewFinancials => isAdmin;
  bool get canManageInventory => isAdmin || isTechnician;
  bool get canEditSettings => isAdmin;
  bool get canAssignOrders => isAdmin;

  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      uid: documentId,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: data['role'] ?? 'technician',
      centerId: data['centerId'] ?? AppConstants.defaultCenterId,
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
      'email': email,
      'name': name,
      'role': role,
      'centerId': centerId,
      'createdAt': createdAt,
    };
  }
}
