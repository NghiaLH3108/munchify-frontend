import '../../domain/entities/supplier_entity.dart';

class SupplierModel extends SupplierEntity {
  const SupplierModel({
    required super.supplierId,
    required super.supplierName,
    super.contactName,
    super.phone,
    super.address,
    required super.isActive,
    required super.createdAt,
    super.categoryIds,
    super.categoryNames,
  });

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    var rawCatIds = json['categoryIds'] ?? json['CategoryIds'];
    List<int> catIds = [];
    if (rawCatIds is List) {
      catIds = rawCatIds.map((e) => (e as num).toInt()).toList();
    }

    var rawCatNames = json['categoryNames'] ?? json['CategoryNames'];
    List<String> catNames = [];
    if (rawCatNames is List) {
      catNames = rawCatNames.map((e) => e.toString()).toList();
    }

    return SupplierModel(
      supplierId: (json['supplierId'] ?? json['SupplierId'] ?? 0) as int,
      supplierName: (json['supplierName'] ?? json['SupplierName'] ?? '') as String,
      contactName: json['contactName'] ?? json['ContactName'],
      phone: json['phone'] ?? json['Phone'],
      address: json['address'] ?? json['Address'],
      isActive: (json['isActive'] ?? json['IsActive'] ?? true) as bool,
      createdAt: json['createdAt'] != null || json['CreatedAt'] != null
          ? DateTime.tryParse((json['createdAt'] ?? json['CreatedAt']).toString()) ?? DateTime.now()
          : DateTime.now(),
      categoryIds: catIds,
      categoryNames: catNames,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'supplierName': supplierName,
      'contactName': contactName,
      'phone': phone,
      'address': address,
      'isActive': isActive,
      'categoryIds': categoryIds,
    };
  }
}
