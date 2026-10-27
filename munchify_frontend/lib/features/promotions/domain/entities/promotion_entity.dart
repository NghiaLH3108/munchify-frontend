import 'package:equatable/equatable.dart';

class PromotionEntity extends Equatable {
  final int promotionId;
  final String promotionCode;
  final String promotionName;
  final String? description;
  final String discountType; // 'PERCENTAGE' or 'FIXED_AMOUNT'
  final double discountValue;
  final double? minimumOrderAmount;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  const PromotionEntity({
    required this.promotionId,
    required this.promotionCode,
    required this.promotionName,
    this.description,
    required this.discountType,
    required this.discountValue,
    this.minimumOrderAmount,
    required this.startDate,
    required this.endDate,
    required this.isActive,
  });

  @override
  List<Object?> get props => [
        promotionId, promotionCode, promotionName, description, discountType, discountValue,
        minimumOrderAmount, startDate, endDate, isActive,
      ];
}

class PromotionDetailEntity extends PromotionEntity {
  final List<dynamic> products;

  const PromotionDetailEntity({
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
    required this.products,
  });

  @override
  List<Object?> get props => [
        ...super.props,
        products,
      ];
}
