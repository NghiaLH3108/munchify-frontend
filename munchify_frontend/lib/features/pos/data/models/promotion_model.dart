import '../../domain/entities/promotion_entity.dart';

class PromotionModel extends PromotionEntity {
  const PromotionModel({
    required super.promotionCode,
    required super.promotionName,
    required super.discountType,
    required super.discountValue,
    required super.discountAmount,
  });

  factory PromotionModel.fromJson(Map<String, dynamic> json) {
    return PromotionModel(
      promotionCode: json['promotionCode'] ?? '',
      promotionName: json['promotionName'] ?? '',
      discountType: json['discountType'] ?? 'FIXED_AMOUNT',
      discountValue: (json['discountValue'] ?? 0).toDouble(),
      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
    );
  }
}
