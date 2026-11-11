// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'combo_option_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ComponentProductModel _$ComponentProductModelFromJson(
  Map<String, dynamic> json,
) => ComponentProductModel(
  id: (json['productId'] as num).toInt(),
  code: json['productCode'] as String? ?? '',
  name: json['productName'] as String? ?? '',
  price: json['price'] as num? ?? 0,
  stockQuantity: (json['stockQuantity'] as num?)?.toInt() ?? 0,
  unitName: json['unitName'] as String? ?? '',
);
