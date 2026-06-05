class PartModel {
  final String id;
  final String name;
  final String partNumber;
  final String category; // Batteries, Circuits, Connectors, Cables, Other
  final String hsnCode;
  final double costPrice;
  final double sellingPrice;
  final int stockQty;
  final int reorderThreshold;

  PartModel({
    required this.id,
    required this.name,
    required this.partNumber,
    required this.category,
    this.hsnCode = '',
    required this.costPrice,
    required this.sellingPrice,
    required this.stockQty,
    this.reorderThreshold = 5,
  });

  factory PartModel.fromMap(Map<String, dynamic> data, String documentId) {
    return PartModel(
      id: documentId,
      name: data['name'] ?? '',
      partNumber: data['partNumber'] ?? '',
      category: data['category'] ?? 'Other',
      hsnCode: data['hsnCode'] ?? '',
      costPrice: (data['costPrice'] ?? 0).toDouble(),
      sellingPrice: (data['sellingPrice'] ?? 0).toDouble(),
      stockQty: data['stockQty'] ?? 0,
      reorderThreshold: data['reorderThreshold'] ?? 5,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'partNumber': partNumber,
      'category': category,
      'hsnCode': hsnCode,
      'costPrice': costPrice,
      'sellingPrice': sellingPrice,
      'stockQty': stockQty,
      'reorderThreshold': reorderThreshold,
    };
  }

  bool get isLowStock => stockQty <= reorderThreshold;

  PartModel copyWith({
    String? name,
    String? partNumber,
    String? category,
    String? hsnCode,
    double? costPrice,
    double? sellingPrice,
    int? stockQty,
    int? reorderThreshold,
  }) {
    return PartModel(
      id: id,
      name: name ?? this.name,
      partNumber: partNumber ?? this.partNumber,
      category: category ?? this.category,
      hsnCode: hsnCode ?? this.hsnCode,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      stockQty: stockQty ?? this.stockQty,
      reorderThreshold: reorderThreshold ?? this.reorderThreshold,
    );
  }
}

class PartUsed {
  final String partId;
  final String name;
  final String hsnCode;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  PartUsed({
    required this.partId,
    required this.name,
    this.hsnCode = '',
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory PartUsed.fromMap(Map<String, dynamic> data) {
    return PartUsed(
      partId: data['partId'] ?? '',
      name: data['name'] ?? '',
      hsnCode: data['hsnCode'] ?? '',
      quantity: data['quantity'] ?? 1,
      unitPrice: (data['unitPrice'] ?? 0).toDouble(),
      totalPrice: (data['totalPrice'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'partId': partId,
      'name': name,
      'hsnCode': hsnCode,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
    };
  }
}
