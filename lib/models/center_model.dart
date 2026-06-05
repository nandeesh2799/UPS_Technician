import 'package:cloud_firestore/cloud_firestore.dart';

class CenterModel {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String email;
  final DateTime createdAt;

  CenterModel({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.createdAt,
  });

  factory CenterModel.fromMap(Map<String, dynamic> data, String documentId) {
    return CenterModel(
      id: documentId,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
      'createdAt': createdAt,
    };
  }
}
