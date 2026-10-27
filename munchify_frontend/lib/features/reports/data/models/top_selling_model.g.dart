// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'top_selling_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TopSellingModel _$TopSellingModelFromJson(Map<String, dynamic> json) =>
    TopSellingModel(
      productId: (json['productId'] as num?)?.toInt() ?? 0,
      productName: json['productName'] as String? ?? '',
      isCombo: json['isCombo'] as bool? ?? false,
      totalQuantity: (json['totalQuantity'] as num?)?.toInt() ?? 0,
      totalRevenue: json['totalRevenue'] as num? ?? 0,
    );
