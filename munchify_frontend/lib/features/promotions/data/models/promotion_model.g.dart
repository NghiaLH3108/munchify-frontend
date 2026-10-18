// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'promotion_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PromotionModel _$PromotionModelFromJson(Map<String, dynamic> json) =>
    PromotionModel(
      promotionId: (json['promotionId'] as num).toInt(),
      promotionCode: json['promotionCode'] as String,
      promotionName: json['promotionName'] as String,
      description: json['description'] as String?,
      discountType: json['discountType'] as String,
      discountValue: (json['discountValue'] as num).toDouble(),
      minimumOrderAmount: (json['minimumOrderAmount'] as num?)?.toDouble(),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      isActive: json['isActive'] as bool,
    );

Map<String, dynamic> _$PromotionModelToJson(PromotionModel instance) =>
    <String, dynamic>{
      'promotionId': instance.promotionId,
      'promotionCode': instance.promotionCode,
      'promotionName': instance.promotionName,
      'description': instance.description,
      'discountType': instance.discountType,
      'discountValue': instance.discountValue,
      'minimumOrderAmount': instance.minimumOrderAmount,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'isActive': instance.isActive,
    };

PromotionDetailModel _$PromotionDetailModelFromJson(
  Map<String, dynamic> json,
) => PromotionDetailModel(
  promotionId: (json['promotionId'] as num).toInt(),
  promotionCode: json['promotionCode'] as String,
  promotionName: json['promotionName'] as String,
  description: json['description'] as String?,
  discountType: json['discountType'] as String,
  discountValue: (json['discountValue'] as num).toDouble(),
  minimumOrderAmount: (json['minimumOrderAmount'] as num?)?.toDouble(),
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: DateTime.parse(json['endDate'] as String),
  isActive: json['isActive'] as bool,
  products: json['products'] as List<dynamic>,
);

Map<String, dynamic> _$PromotionDetailModelToJson(
  PromotionDetailModel instance,
) => <String, dynamic>{
  'promotionId': instance.promotionId,
  'promotionCode': instance.promotionCode,
  'promotionName': instance.promotionName,
  'description': instance.description,
  'discountType': instance.discountType,
  'discountValue': instance.discountValue,
  'minimumOrderAmount': instance.minimumOrderAmount,
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate.toIso8601String(),
  'isActive': instance.isActive,
  'products': instance.products,
};
