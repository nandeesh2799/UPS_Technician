import 'package:cloud_firestore/cloud_firestore.dart';
import 'part_model.dart';

class OrderModel {
  final String id;
  final String customerId;
  final String customerName;
  final String phone;
  final String address;
  final String upsBrand;
  final String upsModel;
  final String problemDescription;
  final String serviceType;
  final String status;
  final String priority;
  final String? technicianId;
  final double serviceCost;
  final double advancePayment;
  final double balanceAmount;
  final String paymentStatus;
  final String paymentMode;
  final bool applyGst;
  final double gstAmount;
  final double totalAmount;
  final DateTime serviceDate;
  final DateTime? warrantyStart;
  final DateTime? warrantyEnd;
  final bool hasWarranty;
  final String technicianNotes;
  final String technicianRemarks;
  final DateTime createdAt;
  final List<PartUsed> partsUsed;
  final List<String> photos;
  final String? customerSignature;
  final double? customerRating;
  final String? customerFeedback;
  final DateTime? pickupDate;
  final DateTime? deliveryDate;

  OrderModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.phone,
    required this.address,
    required this.upsBrand,
    required this.upsModel,
    required this.problemDescription,
    required this.serviceType,
    required this.status,
    this.priority = 'Normal',
    this.technicianId,
    required this.serviceCost,
    this.advancePayment = 0.0,
    required double balanceAmount,
    required this.paymentStatus,
    this.paymentMode = 'Cash',
    this.applyGst = false,
    this.gstAmount = 0.0,
    required this.totalAmount,
    required this.serviceDate,
    this.warrantyStart,
    this.warrantyEnd,
    this.hasWarranty = false,
    this.technicianNotes = '',
    this.technicianRemarks = '',
    required this.createdAt,
    this.partsUsed = const [],
    this.photos = const [],
    this.customerSignature,
    this.customerRating,
    this.customerFeedback,
    this.pickupDate,
    this.deliveryDate,
  }) : balanceAmount = paymentStatus.toLowerCase() == 'paid' ? 0.0 : balanceAmount;

  factory OrderModel.fromMap(Map<String, dynamic> data, String documentId) {
    return OrderModel(
      id: documentId,
      customerId: data['customerId'] ?? '',
      customerName: data['customerName'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      upsBrand: data['upsBrand'] ?? '',
      upsModel: data['upsModel'] ?? '',
      problemDescription: data['problemDescription'] ?? '',
      serviceType: data['serviceType'] ?? 'Repair',
      status: data['status'] ?? 'Pending',
      priority: data['priority'] ?? 'Normal',
      technicianId: data['technicianId'],
      serviceCost: (data['serviceCost'] ?? 0).toDouble(),
      advancePayment: (data['advancePayment'] ?? 0).toDouble(),
      balanceAmount: (data['balanceAmount'] ?? 0).toDouble(),
      paymentStatus: data['paymentStatus'] ?? 'Unpaid',
      paymentMode: data['paymentMode'] ?? 'Cash',
      applyGst: data['applyGst'] ?? false,
      gstAmount: (data['gstAmount'] ?? 0).toDouble(),
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      serviceDate: _toDateTime(data['serviceDate']),
      warrantyStart: _toNullableDateTime(data['warrantyStart']),
      warrantyEnd: _toNullableDateTime(data['warrantyEnd']),
      hasWarranty: data['hasWarranty'] ?? false,
      technicianNotes: data['technicianNotes'] ?? '',
      technicianRemarks: data['technicianRemarks'] ?? '',
      createdAt: _toDateTime(data['createdAt']),
      partsUsed: (data['partsUsed'] as List<dynamic>?)?.map((p) => PartUsed.fromMap(p)).toList() ?? [],
      photos: (data['photos'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      customerSignature: data['customerSignature'],
      customerRating: (data['customerRating'] as num?)?.toDouble(),
      customerFeedback: data['customerFeedback'],
      pickupDate: _toNullableDateTime(data['pickupDate']),
      deliveryDate: _toNullableDateTime(data['deliveryDate']),
    );
  }

  static DateTime _toDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return DateTime.now();
  }

  static DateTime? _toNullableDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'phone': phone,
      'address': address,
      'upsBrand': upsBrand,
      'upsModel': upsModel,
      'problemDescription': problemDescription,
      'serviceType': serviceType,
      'status': status,
      'priority': priority,
      'technicianId': technicianId,
      'serviceCost': serviceCost,
      'advancePayment': advancePayment,
      'balanceAmount': balanceAmount,
      'paymentStatus': paymentStatus,
      'paymentMode': paymentMode,
      'applyGst': applyGst,
      'gstAmount': gstAmount,
      'totalAmount': totalAmount,
      'serviceDate': serviceDate,
      'warrantyStart': warrantyStart,
      'warrantyEnd': warrantyEnd,
      'hasWarranty': hasWarranty,
      'technicianNotes': technicianNotes,
      'technicianRemarks': technicianRemarks,
      'createdAt': createdAt,
      'partsUsed': partsUsed.map((p) => p.toMap()).toList(),
      'photos': photos,
      'customerSignature': customerSignature,
      'customerRating': customerRating,
      'customerFeedback': customerFeedback,
      'pickupDate': pickupDate,
      'deliveryDate': deliveryDate,
    };
  }

  OrderModel copyWith({
    String? customerName,
    String? phone,
    String? address,
    String? upsBrand,
    String? upsModel,
    String? problemDescription,
    String? serviceType,
    String? status,
    String? priority,
    String? technicianId,
    double? serviceCost,
    double? advancePayment,
    double? balanceAmount,
    String? paymentStatus,
    String? paymentMode,
    bool? applyGst,
    double? gstAmount,
    double? totalAmount,
    DateTime? serviceDate,
    DateTime? warrantyStart,
    DateTime? warrantyEnd,
    bool? hasWarranty,
    String? technicianNotes,
    String? technicianRemarks,
    List<PartUsed>? partsUsed,
    List<String>? photos,
    String? customerSignature,
    double? customerRating,
    String? customerFeedback,
    DateTime? pickupDate,
    DateTime? deliveryDate,
  }) {
    return OrderModel(
      id: id,
      customerId: customerId,
      customerName: customerName ?? this.customerName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      upsBrand: upsBrand ?? this.upsBrand,
      upsModel: upsModel ?? this.upsModel,
      problemDescription: problemDescription ?? this.problemDescription,
      serviceType: serviceType ?? this.serviceType,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      technicianId: technicianId ?? this.technicianId,
      serviceCost: serviceCost ?? this.serviceCost,
      advancePayment: advancePayment ?? this.advancePayment,
      balanceAmount: balanceAmount ?? this.balanceAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMode: paymentMode ?? this.paymentMode,
      applyGst: applyGst ?? this.applyGst,
      gstAmount: gstAmount ?? this.gstAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      serviceDate: serviceDate ?? this.serviceDate,
      warrantyStart: warrantyStart ?? this.warrantyStart,
      warrantyEnd: warrantyEnd ?? this.warrantyEnd,
      hasWarranty: hasWarranty ?? this.hasWarranty,
      technicianNotes: technicianNotes ?? this.technicianNotes,
      technicianRemarks: technicianRemarks ?? this.technicianRemarks,
      createdAt: createdAt,
      partsUsed: partsUsed ?? this.partsUsed,
      photos: photos ?? this.photos,
      customerSignature: customerSignature ?? this.customerSignature,
      customerRating: customerRating ?? this.customerRating,
      customerFeedback: customerFeedback ?? this.customerFeedback,
      pickupDate: pickupDate ?? this.pickupDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
    );
  }
}
