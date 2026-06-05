class TechnicianModel {
  final String id;
  final String uid; // Firebase Auth UID
  final String name;
  final String phone;
  final String email;
  final String role; // admin, technician, viewer
  final bool isActive;
  final int ordersCompleted;
  final double avgRating;

  TechnicianModel({
    required this.id,
    required this.uid,
    required this.name,
    required this.phone,
    required this.email,
    required this.role,
    this.isActive = true,
    this.ordersCompleted = 0,
    this.avgRating = 0.0,
  });

  factory TechnicianModel.fromMap(Map<String, dynamic> data, String documentId) {
    return TechnicianModel(
      id: documentId,
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'technician',
      isActive: data['isActive'] ?? true,
      ordersCompleted: data['ordersCompleted'] ?? 0,
      avgRating: (data['avgRating'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'phone': phone,
      'email': email,
      'role': role,
      'isActive': isActive,
      'ordersCompleted': ordersCompleted,
      'avgRating': avgRating,
    };
  }
}
