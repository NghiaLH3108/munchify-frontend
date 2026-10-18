import 'package:equatable/equatable.dart';

/// Kết quả áp dụng mã khuyến mãi từ POST /api/promotions/apply.
class PromotionEntity extends Equatable {
  final String promotionCode;
  final String promotionName;
  final String discountType; // PERCENTAGE | FIXED_AMOUNT
  final double discountValue;
  final double discountAmount; // Số tiền giảm thực tế

  const PromotionEntity({
    required this.promotionCode,
    required this.promotionName,
    required this.discountType,
    required this.discountValue,
    required this.discountAmount,
  });

  @override
  List<Object?> get props => [
        promotionCode,
        promotionName,
        discountType,
        discountValue,
        discountAmount,
      ];
}
