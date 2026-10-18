import 'package:equatable/equatable.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/entities/promotion_entity.dart';

class CartState extends Equatable {
  final List<CartItemEntity> items;
  final PromotionEntity? appliedPromotion;
  final bool isApplyingPromotion;
  final String? promotionError;

  const CartState({
    this.items = const [],
    this.appliedPromotion = null,
    this.isApplyingPromotion = false,
    this.promotionError,
  });

  // ─── Computed totals ─────────────────────────────────────────────────────────
  double get subtotal =>
      items.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get discountAmount => appliedPromotion?.discountAmount ?? 0.0;

  double get totalAmount => (subtotal - discountAmount).clamp(0.0, double.infinity);

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  bool get isEmpty => items.isEmpty;

  CartState copyWith({
    List<CartItemEntity>? items,
    PromotionEntity? Function()? appliedPromotion,
    bool? isApplyingPromotion,
    String? Function()? promotionError,
  }) {
    return CartState(
      items: items ?? this.items,
      appliedPromotion: appliedPromotion != null
          ? appliedPromotion()
          : this.appliedPromotion,
      isApplyingPromotion:
          isApplyingPromotion ?? this.isApplyingPromotion,
      promotionError:
          promotionError != null ? promotionError() : this.promotionError,
    );
  }

  @override
  List<Object?> get props => [
        items,
        appliedPromotion,
        isApplyingPromotion,
        promotionError,
      ];
}
