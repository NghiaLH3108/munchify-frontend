import 'package:equatable/equatable.dart';

/// Entity đại diện cho một khuyến mãi trong danh sách catalog (GET /api/promotions).
/// Khác với [PromotionEntity] (kết quả apply), entity này chứa metadata đầy đủ.
class CatalogPromotionEntity extends Equatable {
  final int promotionId;
  final String promotionCode;
  final String promotionName;
  final String? description;
  final String discountType; // PERCENTAGE | FIXED_AMOUNT
  final double discountValue;
  final double? minimumOrderAmount;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  const CatalogPromotionEntity({
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

  /// Có thể áp dụng hiện tại không (active + trong khoảng thời gian)
  bool get isCurrentlyValid {
    final now = DateTime.now();
    return isActive && now.isAfter(startDate) && now.isBefore(endDate);
  }

  /// Label hiển thị giảm giá
  String get discountLabel {
    if (discountType == 'PERCENTAGE') {
      return '-${discountValue.toStringAsFixed(discountValue % 1 == 0 ? 0 : 1)}%';
    }
    return '-${_formatCurrency(discountValue)}';
  }

  String _formatCurrency(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(value % 1000000 == 0 ? 0 : 1)}tr';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)}k';
    return value.toStringAsFixed(0);
  }

  @override
  List<Object?> get props => [
        promotionId,
        promotionCode,
        promotionName,
        discountType,
        discountValue,
        minimumOrderAmount,
        startDate,
        endDate,
        isActive,
      ];
}
