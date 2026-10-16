import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/apply_promotion_usecase.dart';
import 'cart_state.dart';

/// CartCubit quản lý giỏ hàng LOCAL (không gọi API trừ apply promotion).
///
/// Dùng Cubit (không phải Bloc) vì phần lớn thao tác là đồng bộ.
class CartCubit extends Cubit<CartState> {
  final ApplyPromotionUseCase applyPromotionUseCase;

  CartCubit({required this.applyPromotionUseCase})
      : super(const CartState());

  // ─── Cart operations ──────────────────────────────────────────────────────

  /// Thêm sản phẩm vào giỏ. Nếu đã có → tăng số lượng thêm 1.
  void addItem(ProductEntity product) {
    final existingIndex =
        state.items.indexWhere((i) => i.productId == product.id);

    if (existingIndex >= 0) {
      final updated = List<CartItemEntity>.from(state.items);
      updated[existingIndex] = updated[existingIndex]
          .copyWith(quantity: updated[existingIndex].quantity + 1);
      emit(state.copyWith(items: updated));
    } else {
      emit(state.copyWith(
        items: [...state.items, CartItemEntity.fromProduct(product)],
      ));
    }
  }

  /// Cập nhật số lượng theo [productId]. Nếu quantity ≤ 0 → xóa khỏi giỏ.
  void updateQuantity(int productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }
    final updated = state.items.map((item) {
      return item.productId == productId
          ? item.copyWith(quantity: quantity)
          : item;
    }).toList();
    emit(state.copyWith(items: updated));
  }

  /// Xóa sản phẩm khỏi giỏ.
  void removeItem(int productId) {
    final updated =
        state.items.where((i) => i.productId != productId).toList();
    emit(state.copyWith(
      items: updated,
      // Nếu giỏ rỗng sau khi xóa → bỏ luôn khuyến mãi
      appliedPromotion: updated.isEmpty ? () => null : null,
      promotionError: updated.isEmpty ? () => null : null,
    ));
  }

  /// Xóa toàn bộ giỏ hàng (dùng sau khi thanh toán xong).
  void clearCart() {
    emit(const CartState());
  }

  // ─── Promotion ────────────────────────────────────────────────────────────

  /// Áp dụng mã khuyến mãi. Kết quả từ server.
  Future<void> applyPromotion(String code) async {
    if (code.trim().isEmpty) return;

    emit(state.copyWith(
      isApplyingPromotion: true,
      promotionError: () => null,
    ));

    final result = await applyPromotionUseCase.execute(
      promotionCode: code.trim().toUpperCase(),
      subtotal: state.subtotal,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        isApplyingPromotion: false,
        appliedPromotion: () => null,
        promotionError: () => failure.message,
      )),
      (promo) => emit(state.copyWith(
        isApplyingPromotion: false,
        appliedPromotion: () => promo,
        promotionError: () => null,
      )),
    );
  }

  /// Gỡ mã khuyến mãi đang áp dụng.
  void removePromotion() {
    emit(state.copyWith(
      appliedPromotion: () => null,
      promotionError: () => null,
    ));
  }
}
