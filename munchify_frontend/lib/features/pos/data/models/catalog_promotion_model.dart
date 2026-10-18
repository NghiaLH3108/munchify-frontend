import '../../domain/entities/catalog_promotion_entity.dart';

/// Model ánh xạ từ JSON [PromotionDto] của backend (GET /api/promotions).
class CatalogPromotionModel extends CatalogPromotionEntity {
  const CatalogPromotionModel({
    required super.promotionId,
    required super.promotionCode,
    required super.promotionName,
    super.description,
    required super.discountType,
    required super.discountValue,
    super.minimumOrderAmount,
    required super.startDate,
    required super.endDate,
    required super.isActive,
  });

  factory CatalogPromotionModel.fromJson(Map<String, dynamic> json) {
    return CatalogPromotionModel(
      promotionId: json['promotionId'] ?? 0,
      promotionCode: json['promotionCode'] ?? '',
      promotionName: json['promotionName'] ?? '',
      description: json['description'],
      discountType: json['discountType'] ?? 'FIXED_AMOUNT',
      discountValue: (json['discountValue'] ?? 0).toDouble(),
      minimumOrderAmount: json['minimumOrderAmount'] != null
          ? (json['minimumOrderAmount'] as num).toDouble()
          : null,
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      isActive: json['isActive'] ?? false,
    );
  }
}
