// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'combo_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ComboItemModel _$ComboItemModelFromJson(Map<String, dynamic> json) =>
    ComboItemModel(
      componentProductId: (json['componentProductId'] as num).toInt(),
      componentProductName: json['componentProductName'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      unitPrice: json['unitPrice'] as num? ?? 0,
      unitName: json['unitName'] as String? ?? '',
      componentStockQuantity:
          (json['componentStockQuantity'] as num?)?.toInt() ?? 0,
    );

ComboModel _$ComboModelFromJson(Map<String, dynamic> json) => ComboModel(
  id: (json['productId'] as num).toInt(),
  code: json['productCode'] as String? ?? '',
  name: json['productName'] as String? ?? '',
  description: json['description'] as String?,
  price: json['price'] as num? ?? 0,
  basePrice: json['basePrice'] as num? ?? 0,
  categoryId: (json['categoryId'] as num?)?.toInt() ?? 0,
  categoryName: json['categoryName'] as String? ?? '',
  unitId: (json['unitId'] as num?)?.toInt() ?? 0,
  unitName: json['unitName'] as String? ?? '',
  imageUrl: json['imageUrl'] as String?,
  isActive: json['isActive'] as bool? ?? true,
  comboItems:
      (json['comboItems'] as List<dynamic>?)
          ?.map((e) => ComboItemModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);
