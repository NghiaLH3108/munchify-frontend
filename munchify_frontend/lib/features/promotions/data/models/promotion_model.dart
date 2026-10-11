import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/promotion_entity.dart';

part 'promotion_model.g.dart';

@JsonSerializable()
class PromotionModel extends PromotionEntity {
  const PromotionModel({
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

  factory PromotionModel.fromJson(Map<String, dynamic> json) => _$PromotionModelFromJson(json);
  Map<String, dynamic> toJson() => _$PromotionModelToJson(this);
}

@JsonSerializable()
class PromotionDetailModel extends PromotionDetailEntity {
  const PromotionDetailModel({
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
    required super.products,
  });

  factory PromotionDetailModel.fromJson(Map<String, dynamic> json) => _$PromotionDetailModelFromJson(json);
  Map<String, dynamic> toJson() => _$PromotionDetailModelToJson(this);
}
